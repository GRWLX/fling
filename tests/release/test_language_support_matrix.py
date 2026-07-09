from __future__ import annotations

import importlib.util
import re
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
GENERATOR_PATH = REPO_ROOT / "tools" / "generate_language_support_matrix.py"


def load_generator():
    if not GENERATOR_PATH.exists():
        return None

    spec = importlib.util.spec_from_file_location("generate_language_support_matrix", GENERATOR_PATH)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


generate_language_support_matrix = load_generator()


def language_name(row: dict) -> str:
    for key in ("language", "name"):
        value = row.get(key)
        if isinstance(value, str) and value:
            return value
    raise AssertionError(f"language support row is missing a language/name field: {row!r}")


def status_value(row: dict) -> str:
    value = row.get("status")
    if isinstance(value, str) and value:
        return value
    raise AssertionError(f"language support row is missing a status field: {row!r}")


def allowed_statuses(module) -> set[str]:
    statuses = getattr(module, "ALLOWED_STATUSES", None)
    if statuses is None:
        statuses = getattr(module, "STATUS_ORDER", None)
    if statuses is None:
        raise AssertionError("generator must expose ALLOWED_STATUSES or STATUS_ORDER")
    return {str(status) for status in statuses}


def evidence_value(row: dict):
    for key in ("evidence", "evidence_url", "evidence_urls", "evidence_path", "evidence_paths"):
        if key in row:
            return row[key]
    return None


def has_evidence(row: dict) -> bool:
    evidence = evidence_value(row)
    if isinstance(evidence, str):
        return bool(evidence.strip())
    if isinstance(evidence, (list, tuple, set)):
        return any(bool(str(item).strip()) for item in evidence)
    return bool(evidence)


def is_unsupported(row: dict) -> bool:
    if row.get("supported") is False:
        return True
    if row.get("shipped") is False:
        return True
    for key in ("support", "tier", "category"):
        value = row.get(key)
        if isinstance(value, str) and value.upper() in {"UNSUPPORTED", "NOT_SUPPORTED"}:
            return True
    return status_value(row).upper() in {"UNSUPPORTED", "NOT_SUPPORTED"}


@unittest.skipIf(
    generate_language_support_matrix is None,
    "tools/generate_language_support_matrix.py is not present yet",
)
class LanguageSupportMatrixTests(unittest.TestCase):
    def test_language_support_has_no_duplicate_languages(self) -> None:
        languages = [language_name(row) for row in generate_language_support_matrix.LANGUAGE_SUPPORT]

        duplicates = sorted({language for language in languages if languages.count(language) > 1})

        self.assertEqual(duplicates, [])

    def test_language_support_uses_allowed_statuses_only(self) -> None:
        allowed = allowed_statuses(generate_language_support_matrix)
        statuses = {status_value(row) for row in generate_language_support_matrix.LANGUAGE_SUPPORT}

        self.assertEqual(statuses - allowed, set())

    def test_validate_language_support_accepts_current_matrix(self) -> None:
        result = generate_language_support_matrix.validate_language_support()

        self.assertIn(result, (None, True, []))

    def test_pass_languages_have_evidence(self) -> None:
        missing_evidence = [
            language_name(row)
            for row in generate_language_support_matrix.LANGUAGE_SUPPORT
            if status_value(row).upper() == "PASS" and not has_evidence(row)
        ]

        self.assertEqual(missing_evidence, [])

    def test_priority_languages_are_ordered_for_release_docs(self) -> None:
        languages = [language_name(row) for row in generate_language_support_matrix.LANGUAGE_SUPPORT]

        self.assertGreater(len(languages), 0)
        self.assertEqual(languages[0], "Python")
        self.assertLess(languages.index("TypeScript"), languages.index("JavaScript"))
        self.assertLess(languages.index("TypeScript"), languages.index("Java"))

    def test_powershell_is_blocked(self) -> None:
        rows_by_language = {
            language_name(row): row for row in generate_language_support_matrix.LANGUAGE_SUPPORT
        }

        self.assertEqual(status_value(rows_by_language["PowerShell"]).upper(), "BLOCKED")

    def test_unsupported_languages_are_not_pass(self) -> None:
        unsupported_pass = [
            language_name(row)
            for row in generate_language_support_matrix.LANGUAGE_SUPPORT
            if is_unsupported(row) and status_value(row).upper() == "PASS"
        ]

        self.assertEqual(unsupported_pass, [])

    def test_render_markdown_includes_generated_markers_and_table(self) -> None:
        markdown = generate_language_support_matrix.render_markdown()

        self.assertIn("<!-- BEGIN GENERATED LANGUAGE SUPPORT MATRIX -->", markdown)
        self.assertIn("<!-- END GENERATED LANGUAGE SUPPORT MATRIX -->", markdown)
        self.assertRegex(markdown, re.compile(r"^\|[^\n]*Language[^\n]*\|", re.MULTILINE))
        self.assertRegex(markdown, re.compile(r"^\|[ :|-]+\|$", re.MULTILINE))


if __name__ == "__main__":
    unittest.main()
