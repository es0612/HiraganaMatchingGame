#!/usr/bin/env python3
"""stage した Swift の差分で、空行のインデントが消えていないかを確かめる（Python 3.9 以上）。

このリポの Swift の多くは Xcode の書き方で、空行にもインデントがある（105 ファイル中 86 ファイル）。
Claude の Edit ツールで書き換えると、近くの空行のインデントが消え、意図しない差分になることがある
（#73 の PR、#80 の PR、#73 の 2 歩目の PR）。

ルール: 変更したファイルの元の版（HEAD）で、中の空行の大半がインデント付きなら、
インデントなしの空行を足した差分を止める（次の行がインデントされているときだけ。一番外側の空行は対象外）。
差分の取り方によっては、元のインデント付きの空行が「残った」扱いになり、削除行が出てこない
（#73 の 2 歩目）ので、削除行ではなく「足した空行」とファイルの書き方で判定する。
新しいファイルと、空行にインデントがない書き方のファイル（テストの多く）は止めない。

使い方: scripts/git-hooks/pre-commit から呼ばれる（git config core.hooksPath scripts/git-hooks）。
止まったら --fix で、足した空行に次の行と同じインデントを入れられる。
--fix は作業中のファイル（HEAD との差分）を直す。一部だけ stage しているときは、直した後に stage し直す。
意図した書き直しなら git commit --no-verify で通せる。
判定部分のテスト: python3 -I -m unittest discover -s scripts/tests
"""

import re
import subprocess
import sys

HUNK_HEADER = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@")


# MARK: - 判定（純粋な関数）


def indentation_of_next_line(lines: list[str], line_number: int) -> str:
    """line_number 行目（1 始まり）より後ろで、最初の空行でない行のインデント。なければ空文字"""
    for line in lines[line_number:]:
        if line.strip(" \t\r"):
            return line[: len(line) - len(line.lstrip(" \t"))]
    return ""


def uses_indented_blank_lines(text: str) -> bool:
    """中の空行（次の行がインデントされている空行）の大半がインデント付きか。
    一番外側の空行はどちらの書き方でもインデントなしなので数えない"""
    lines = text.split("\n")
    inner_blank_lines = [
        line.rstrip("\r")
        for number, line in enumerate(lines, start=1)
        if line.strip(" \t\r") == "" and indentation_of_next_line(lines, number)
    ]
    indented = sum(1 for line in inner_blank_lines if line)
    return indented > len(inner_blank_lines) - indented


def added_empty_lines(diff: str) -> list[int]:
    """-U0 の差分から、足したインデントなしの空行の行番号（新しい版）を返す。
    ファイルの見出し（--- / +++）は最初の @@ より前だけにある。ハンクの中の「+++」「---」は中身の行"""
    result: list[int] = []
    new_line = None
    for raw in diff.splitlines():
        if match := HUNK_HEADER.match(raw):
            new_line = int(match.group(1))
        elif raw.startswith("diff --git"):
            new_line = None
        elif new_line is None or raw.startswith("\\"):
            continue
        elif raw.startswith("+"):
            if raw.rstrip("\r") == "+":
                result.append(new_line)
            new_line += 1
    return result


def problem_lines(base_text: str, new_text: str, diff: str) -> list[int]:
    """止める行番号（新しい版）。元の版がインデント付きの書き方で、次の行がインデントされている足した空行"""
    if not uses_indented_blank_lines(base_text):
        return []
    lines = new_text.split("\n")
    return [number for number in added_empty_lines(diff) if indentation_of_next_line(lines, number)]


def fixed_text(text: str, line_numbers: list[int]) -> str:
    """指定した行（1 始まり）に、次の行と同じインデントを入れる。改行コードはそのまま"""
    lines = text.split("\n")
    for number in line_numbers:
        ending = "\r" if lines[number - 1].endswith("\r") else ""
        lines[number - 1] = indentation_of_next_line(lines, number) + ending
    return "\n".join(lines)


# MARK: - git とのやりとり


def git(root: str, *args: str) -> str:
    return subprocess.run(["git", "-C", root, *args], capture_output=True, text=True, check=True).stdout


def changed_swift_files(root: str, *diff_args: str) -> list[str]:
    output = git(root, "diff", *diff_args, "--name-only", "-z", "--diff-filter=M", "--", ":(top)*.swift")
    return [path for path in output.split("\0") if path]


def check_staged(root: str) -> list[str]:
    problems: list[str] = []
    for path in changed_swift_files(root, "--cached"):
        diff = git(root, "diff", "--cached", "-U0", "--", f":(top){path}")
        lines = problem_lines(git(root, "show", f"HEAD:{path}"), git(root, "show", f":{path}"), diff)
        problems.extend(f"{path}:{number}" for number in lines)
    return problems


def fix_working_tree(root: str) -> int:
    fixed = 0
    for path in changed_swift_files(root, "HEAD"):
        full_path = f"{root}/{path}"
        with open(full_path, encoding="utf-8", newline="") as file:
            text = file.read()
        diff = git(root, "diff", "HEAD", "-U0", "--", f":(top){path}")
        lines = problem_lines(git(root, "show", f"HEAD:{path}"), text, diff)
        if not lines:
            continue
        with open(full_path, "w", encoding="utf-8", newline="") as file:
            file.write(fixed_text(text, lines))
        fixed += len(lines)
        for number in lines:
            print(f"  {path}:{number}")
    print(f"{fixed} 行にインデントを入れました。git add してから commit し直してください。")
    return 0


def main() -> int:
    root = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True, check=True
    ).stdout.strip()
    if "--fix" in sys.argv[1:]:
        return fix_working_tree(root)
    problems = check_staged(root)
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
