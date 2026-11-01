#!/usr/bin/env python3
"""stage した Swift の差分で、空行のインデントが消えていないかを確かめる。

このリポの Swift の多くは Xcode の書き方で、空行にもインデントがある（105 ファイル中 86 ファイル）。
Claude の Edit ツールで書き換えると、近くの空行のインデントが消え、意図しない差分になることがある
（#73 の PR、#80 の PR、#73 の 2 歩目の PR）。

ルール: 変更したファイルの元の版（HEAD）で、空行の大半がインデント付きなら、
インデントなしの空行を足した差分を止める（次の行がインデントされているときだけ。一番外側の空行は対象外）。
差分の取り方によっては、元のインデント付きの空行が「残った」扱いになり、削除行が出てこない
（#73 の 2 歩目）ので、削除行ではなく「足した空行」とファイルの書き方で判定する。
新しいファイルと、空行にインデントがない書き方のファイル（テストの多く）は止めない。

使い方: scripts/git-hooks/pre-commit から呼ばれる（git config core.hooksPath scripts/git-hooks）。
止まったら --fix で、足した空行に次の行と同じインデントを入れられる。
意図した書き直しなら git commit --no-verify で通せる。
"""

import re
import subprocess
import sys

HUNK_HEADER = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@")


def git(*args: str) -> str:
    return subprocess.run(["git", *args], capture_output=True, text=True, check=True).stdout


def uses_indented_blank_lines(text: str) -> bool:
    """中の空行（次の行がインデントされている空行）の大半がインデント付きか。
    一番外側の空行はどちらの書き方でもインデントなしなので数えない"""
    lines = text.split("\n")
    inner_blank_lines = [
        line for number, line in enumerate(lines, start=1) if line.strip(" \t") == "" and next_line_is_indented(lines, number)
    ]
    indented = sum(1 for line in inner_blank_lines if line)
    return indented > len(inner_blank_lines) - indented


def added_empty_lines(diff: str) -> list[int]:
    """-U0 の差分から、足したインデントなしの空行の行番号（新しい版）を返す"""
    result: list[int] = []
    new_line = 0
    for raw in diff.splitlines():
        if match := HUNK_HEADER.match(raw):
            new_line = int(match.group(1))
        elif raw.startswith(("+++", "---")):
            continue
        elif raw.startswith("+"):
            if raw == "+":
                result.append(new_line)
            new_line += 1
    return result


def next_line_is_indented(lines: list[str], line_number: int) -> bool:
    """空行の次の（空行でない）行がインデントされているか。一番外側の空行はインデントなしが正しい"""
    for line in lines[line_number:]:
        if line.strip(" \t"):
            return line.startswith((" ", "\t"))
    return False


def find_problems(base: str, new_version: str, paths: list[str], diff_for) -> list[str]:
    problems: list[str] = []
    for path in paths:
        if not uses_indented_blank_lines(git("show", f"{base}:{path}")):
            continue
        lines = git("show", f"{new_version}:{path}").split("\n")
        problems.extend(
            f"{path}:{line}" for line in added_empty_lines(diff_for(path)) if next_line_is_indented(lines, line)
        )
    return problems


def indentation_of_next_line(lines: list[str], line_number: int) -> str:
    for line in lines[line_number:]:
        if line.strip(" \t"):
            return line[: len(line) - len(line.lstrip(" \t"))]
    return ""


def fix_working_tree() -> int:
    """作業中のファイル（HEAD との差分）で、足したインデントなしの空行に次の行と同じインデントを入れる"""
    paths = git("diff", "HEAD", "--name-only", "--diff-filter=M", "--", "*.swift").split()
    root = git("rev-parse", "--show-toplevel").strip()
    fixed = 0
    for path in paths:
        if not uses_indented_blank_lines(git("show", f"HEAD:{path}")):
            continue
        full_path = f"{root}/{path}"
        with open(full_path, encoding="utf-8") as file:
            lines = file.read().split("\n")
        for line_number in added_empty_lines(git("diff", "HEAD", "-U0", "--", path)):
            indent = indentation_of_next_line(lines, line_number)
            if indent and lines[line_number - 1] == "":
                lines[line_number - 1] = indent
                fixed += 1
                print(f"  {path}:{line_number}")
        with open(full_path, "w", encoding="utf-8") as file:
            file.write("\n".join(lines))
    print(f"{fixed} 行にインデントを入れました。git add してから commit し直してください。")
    return 0


def main() -> int:
    if "--fix" in sys.argv[1:]:
        return fix_working_tree()
    paths = git("diff", "--cached", "--name-only", "--diff-filter=M", "--", "*.swift").split()
    # 新しい版は stage した内容（":path"）
    problems = find_problems("HEAD", "", paths, lambda path: git("diff", "--cached", "-U0", "--", path))
    if not problems:
        return 0
    print("空行のインデントが消えています（このファイルの空行はインデント付きの書き方です）:", file=sys.stderr)
    for problem in problems:
        print(f"  {problem}", file=sys.stderr)
    print(
        "直すには: python3 scripts/check-blank-line-indent.py --fix → git add → commit し直す。\n"
        "意図した書き直しなら git commit --no-verify で通せます。",
        file=sys.stderr,
    )
    return 1


if __name__ == "__main__":
    sys.exit(main())
