#!/usr/bin/env python3
"""stage した Swift の差分で、触っていない空行のインデントが消えていないかを確かめる。

このリポの Swift は Xcode の書き方で、空行にもインデントがある（105 ファイル中 86 ファイル）。
Claude の Edit ツールで書き換えると、近くの空行のインデントが消え、意図しない差分になることがある
（#73 の PR、#80 の PR で 2 か所）。

ルール: 同じ hunk の中に「インデント付きの空行の削除」と「インデントなしの空行の追加」が
両方あれば止める。コードを移動して空行もインデント付きで書き直した場合や、新しいファイルは止めない。

使い方: scripts/git-hooks/pre-commit から呼ばれる（git config core.hooksPath scripts/git-hooks）。
意図した変更なら git commit --no-verify で通せる。
"""

import re
import subprocess
import sys

HUNK_HEADER = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@")


def staged_diff() -> str:
    return subprocess.run(
        ["git", "diff", "--cached", "-U0", "--diff-filter=M", "--", "*.swift"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout


def find_problems(diff: str) -> list[str]:
    problems: list[str] = []
    path = ""
    removed_indented_blank = False
    added_empty_lines: list[int] = []
    new_line = 0

    def close_hunk() -> None:
        if removed_indented_blank and added_empty_lines:
            for line in added_empty_lines:
                problems.append(f"{path}:{line}")

    for raw in diff.splitlines():
        if raw.startswith("diff --git"):
            close_hunk()
            removed_indented_blank, added_empty_lines = False, []
        elif raw.startswith("+++ "):
            path = raw[6:] if raw.startswith("+++ b/") else raw[4:]
        elif raw.startswith("--- "):
            continue
        elif match := HUNK_HEADER.match(raw):
            close_hunk()
            removed_indented_blank, added_empty_lines = False, []
            new_line = int(match.group(1))
        elif raw.startswith("-"):
            if raw[1:] and raw[1:].strip(" \t") == "":
                removed_indented_blank = True
        elif raw.startswith("+"):
            if raw == "+":
                added_empty_lines.append(new_line)
            new_line += 1
    close_hunk()
    return problems


def main() -> int:
    problems = find_problems(staged_diff())
    if not problems:
        return 0
    print("空行のインデントが消えています（触っていない行の差分になります）:", file=sys.stderr)
    for problem in problems:
        print(f"  {problem}", file=sys.stderr)
    print(
        "元のインデント（前後の行と同じ数のスペース）に戻してから commit してください。\n"
        "意図した変更なら git commit --no-verify で通せます。",
        file=sys.stderr,
    )
    return 1


if __name__ == "__main__":
    sys.exit(main())
