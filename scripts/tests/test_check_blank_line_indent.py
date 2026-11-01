"""scripts/check-blank-line-indent.py の判定部分のテスト。

実行: python3 -I -m unittest discover -s scripts/tests
"""

import importlib.util
import pathlib
import unittest

_SCRIPT = pathlib.Path(__file__).resolve().parents[1] / "check-blank-line-indent.py"
_spec = importlib.util.spec_from_file_location("check_blank_line_indent", _SCRIPT)
check = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(check)

INDENTED_STYLE = "struct A {\n    let a = 1\n    \n    let b = 2\n}\n"


class AddedEmptyLinesTests(unittest.TestCase):
    def test_counts_new_line_numbers(self):
        diff = "diff --git a/A.swift b/A.swift\n--- a/A.swift\n+++ b/A.swift\n@@ -3 +3 @@\n-    \n+\n"
        self.assertEqual(check.added_empty_lines(diff), [3])

    def test_added_line_starting_with_plus_plus_is_not_a_header(self):
        # ハンクの中の「++」で始まる追加行（差分では「+++」）を見出し扱いすると、行番号がずれる
        diff = "--- a/A.swift\n+++ b/A.swift\n@@ -1,0 +2,3 @@\n+++x\n+\n+    let y = 1\n"
        self.assertEqual(check.added_empty_lines(diff), [3])

    def test_removed_line_starting_with_minus_minus_is_not_a_header(self):
        diff = "--- a/A.swift\n+++ b/A.swift\n@@ -2 +2,2 @@\n---x\n+    let x = 1\n+\n"
        self.assertEqual(check.added_empty_lines(diff), [3])

    def test_no_newline_marker_does_not_shift_lines(self):
        diff = "--- a/A.swift\n+++ b/A.swift\n@@ -5 +5,2 @@\n-}\n\\ No newline at end of file\n+\n+}\n"
        self.assertEqual(check.added_empty_lines(diff), [5])


class StyleTests(unittest.TestCase):
    def test_indented_style(self):
        self.assertTrue(check.uses_indented_blank_lines(INDENTED_STYLE))

    def test_empty_style(self):
        self.assertFalse(check.uses_indented_blank_lines("struct A {\n    let a = 1\n\n    let b = 2\n}\n"))

    def test_top_level_blank_lines_are_not_counted(self):
        text = "import A\n\nstruct S {\n    let a = 1\n    \n    let b = 2\n}\n\nstruct P {}\n"
        self.assertTrue(check.uses_indented_blank_lines(text))

    def test_indentation_of_next_line(self):
        lines = ["struct A {", "", "    let a = 1", "}"]
        self.assertEqual(check.indentation_of_next_line(lines, 2), "    ")
        self.assertEqual(check.indentation_of_next_line(["", "", "struct B {}"], 1), "")


class ProblemLinesTests(unittest.TestCase):
    def test_reports_empty_line_before_indented_code_in_indented_file(self):
        new = "struct A {\n    let a = 1\n\n    let b = 2\n}\n"
        diff = "@@ -3 +3 @@\n-    \n+\n"
        self.assertEqual(check.problem_lines(INDENTED_STYLE, new, diff), [3])

    def test_ignores_top_level_empty_line(self):
        base = "struct A {\n    let a = 1\n    \n    let b = 2\n}\n"
        new = base + "\nstruct B {}\n"
        diff = "@@ -5,0 +6,2 @@\n+\n+struct B {}\n"
        self.assertEqual(check.problem_lines(base, new, diff), [])

    def test_ignores_files_in_empty_style(self):
        base = "struct A {\n    let a = 1\n\n    let b = 2\n}\n"
        new = "struct A {\n    let a = 1\n\n    let c = 3\n\n    let b = 2\n}\n"
        diff = "@@ -3,0 +4,2 @@\n+    let c = 3\n+\n"
        self.assertEqual(check.problem_lines(base, new, diff), [])


class FixTests(unittest.TestCase):
    def test_fix_indents_reported_lines_only(self):
        new = "struct A {\n    let a = 1\n\n    let b = 2\n}\n"
        self.assertEqual(check.fixed_text(new, [3]), INDENTED_STYLE)

    def test_fix_keeps_crlf(self):
        new = "struct A {\r\n    let a = 1\r\n\r\n    let b = 2\r\n}\r\n"
        self.assertEqual(check.fixed_text(new, [3]), "struct A {\r\n    let a = 1\r\n    \r\n    let b = 2\r\n}\r\n")


if __name__ == "__main__":
    unittest.main()
