#!/usr/bin/env python3
"""Lightweight static checks for GitHub Actions workflows.

This intentionally avoids a YAML dependency. The workflow files in this repo
use regular two-space indentation, so a narrow scanner is enough for release
guardrails without adding a package manager dependency to CI.
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path


ALLOWED_EXPRESSION_CONTEXTS = {
    "env",
    "github",
    "inputs",
    "job",
    "jobs",
    "matrix",
    "needs",
    "runner",
    "secrets",
    "steps",
    "strategy",
    "vars",
}

ACTION_UPLOAD_ARTIFACT = "actions/upload-artifact"
ACTION_DOWNLOAD_ARTIFACT = "actions/download-artifact"
ACTION_ATTEST = "actions/attest"
ACTION_DEPLOY_PAGES = "actions/deploy-pages"
ACTION_UPLOAD_PAGES = "actions/upload-pages-artifact"
ACTION_RELEASE = "softprops/action-gh-release"
ACTION_DOCKER_BUILD = "docker/build-push-action"


@dataclass
class Step:
    line: int
    text: str
    name: str = ""
    step_id: str = ""
    uses: str = ""
    if_condition: str = ""
    with_fields: dict[str, str] = field(default_factory=dict)


@dataclass
class Job:
    job_id: str
    line: int
    text: str
    name: str = ""
    timeout: str = ""
    if_condition: str = ""
    permissions: dict[str, str] = field(default_factory=dict)
    steps: list[Step] = field(default_factory=list)


@dataclass
class Workflow:
    path: Path
    text: str
    permissions: dict[str, str]
    jobs: dict[str, Job]


def indent_of(line: str) -> int:
    return len(line) - len(line.lstrip(" "))


def strip_comment_value(value: str) -> str:
    value = value.strip()
    if not value:
        return ""
    if value[0] in {'"', "'"}:
        quote = value[0]
        end = value.rfind(quote)
        if end > 0:
            return value[1:end]
    return value.split(" #", 1)[0].strip()


def line_number_for_offset(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def extract_key(lines: list[str], key: str, indent: int) -> str:
    pattern = re.compile(rf"^ {{{indent}}}{re.escape(key)}:\s*(.*?)\s*$")
    for line in lines:
        match = pattern.match(line)
        if match:
            return strip_comment_value(match.group(1))
    return ""


def collect_block_scalar(lines: list[str], start_index: int, field_indent: int) -> str:
    values: list[str] = []
    for line in lines[start_index + 1 :]:
        if line.strip() and indent_of(line) <= field_indent:
            break
        if line.strip():
            values.append(line.strip())
    return "\n".join(values)


def parse_mapping(lines: list[str], key: str, indent: int) -> dict[str, str]:
    mapping: dict[str, str] = {}
    pattern = re.compile(rf"^ {{{indent}}}{re.escape(key)}:\s*(.*?)\s*$")
    for index, line in enumerate(lines):
        match = pattern.match(line)
        if not match:
            continue
        scalar = strip_comment_value(match.group(1))
        if scalar:
            mapping["__scalar__"] = scalar
            return mapping
        for child in lines[index + 1 :]:
            if child.strip() and indent_of(child) <= indent:
                break
            child_match = re.match(rf"^ {{{indent + 2}}}([A-Za-z0-9_-]+):\s*(.*?)\s*$", child)
            if child_match:
                mapping[child_match.group(1)] = strip_comment_value(child_match.group(2))
        return mapping
    return mapping


def parse_with_fields(step_lines: list[str]) -> dict[str, str]:
    fields: dict[str, str] = {}
    for index, line in enumerate(step_lines):
        if not re.match(r"^\s+with:\s*$", line):
            continue
        with_indent = indent_of(line)
        field_index = index + 1
        while field_index < len(step_lines):
            field_line = step_lines[field_index]
            if field_line.strip() and indent_of(field_line) <= with_indent:
                break
            field_match = re.match(rf"^ {{{with_indent + 2}}}([A-Za-z0-9_-]+):\s*(.*?)\s*$", field_line)
            if field_match:
                field_name = field_match.group(1)
                field_value = strip_comment_value(field_match.group(2))
                if field_value in {"|", ">"}:
                    field_value = collect_block_scalar(step_lines, field_index, with_indent + 2)
                fields[field_name] = field_value
            field_index += 1
        break
    return fields


def parse_step(step_lines: list[str], line_number: int) -> Step:
    text = "\n".join(step_lines)
    step = Step(line=line_number, text=text)
    for key, attr in (("name", "name"), ("id", "step_id"), ("uses", "uses"), ("if", "if_condition")):
        pattern = re.compile(rf"^\s*(?:-\s*)?{re.escape(key)}:\s*(.*?)\s*$")
        for line in step_lines:
            match = pattern.match(line)
            if match:
                setattr(step, attr, strip_comment_value(match.group(1)))
                break
    step.with_fields = parse_with_fields(step_lines)
    return step


def parse_steps(job_lines: list[str], job_line: int) -> list[Step]:
    steps: list[Step] = []
    start = -1
    for index, line in enumerate(job_lines):
        if re.match(r"^ {4}steps:\s*$", line):
            start = index + 1
            break
    if start < 0:
        return steps

    current_start: int | None = None
    for index in range(start, len(job_lines)):
        line = job_lines[index]
        if re.match(r"^ {6}-\s+", line):
            if current_start is not None:
                steps.append(parse_step(job_lines[current_start:index], job_line + current_start))
            current_start = index
    if current_start is not None:
        steps.append(parse_step(job_lines[current_start:], job_line + current_start))
    return steps


def parse_jobs(lines: list[str]) -> dict[str, Job]:
    jobs_start = -1
    for index, line in enumerate(lines):
        if re.match(r"^jobs:\s*$", line):
            jobs_start = index
            break
    if jobs_start < 0:
        return {}

    job_headers: list[tuple[int, str]] = []
    for index in range(jobs_start + 1, len(lines)):
        match = re.match(r"^ {2}([A-Za-z0-9_-]+):\s*(?:#.*)?$", lines[index])
        if match:
            job_headers.append((index, match.group(1)))

    jobs: dict[str, Job] = {}
    for header_index, (start, job_id) in enumerate(job_headers):
        end = job_headers[header_index + 1][0] if header_index + 1 < len(job_headers) else len(lines)
        job_lines = lines[start:end]
        job = Job(
            job_id=job_id,
            line=start + 1,
            text="\n".join(job_lines),
            name=extract_key(job_lines, "name", 4),
            timeout=extract_key(job_lines, "timeout-minutes", 4),
            if_condition=extract_key(job_lines, "if", 4),
            permissions=parse_mapping(job_lines, "permissions", 4),
            steps=parse_steps(job_lines, start + 1),
        )
        jobs[job_id] = job
    return jobs


def parse_workflow(path: Path) -> Workflow:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    return Workflow(
        path=path,
        text=text,
        permissions=parse_mapping(lines, "permissions", 0),
        jobs=parse_jobs(lines),
    )


def short_action(uses: str) -> str:
    return uses.split("@", 1)[0].strip()


def workflow_ref(workflow: Workflow, line: int | None = None) -> str:
    if line is None:
        return workflow.path.as_posix()
    return f"{workflow.path.as_posix()}:{line}"


def job_ref(workflow: Workflow, job: Job) -> str:
    return f"{workflow.path.as_posix()}:{job.line} job {job.job_id}"


def step_ref(workflow: Workflow, step: Step) -> str:
    label = step.name or step.uses or "<unnamed>"
    return f"{workflow.path.as_posix()}:{step.line} step {label}"


def check_expressions(workflow: Workflow) -> list[str]:
    errors: list[str] = []
    offset = 0
    while True:
        start = workflow.text.find("${{", offset)
        if start < 0:
            break
        end = workflow.text.find("}}", start + 3)
        line = line_number_for_offset(workflow.text, start)
        if end < 0:
            errors.append(f"{workflow_ref(workflow, line)}: unclosed GitHub expression")
            break
        expression = workflow.text[start + 3 : end].strip()
        if not expression:
            errors.append(f"{workflow_ref(workflow, line)}: empty GitHub expression")
        if "${{" in expression:
            errors.append(f"{workflow_ref(workflow, line)}: nested GitHub expression")
        for context in re.findall(r"(?<![.\w'\"-])([A-Za-z_][A-Za-z0-9_]*)\s*(?=[.\[])", expression):
            if context not in ALLOWED_EXPRESSION_CONTEXTS:
                errors.append(f"{workflow_ref(workflow, line)}: unknown expression context: {context}")
        offset = end + 2

    for match in re.finditer(r"\bneeds\.([A-Za-z0-9_-]+)\b", workflow.text):
        needed = match.group(1)
        if needed not in workflow.jobs:
            line = line_number_for_offset(workflow.text, match.start())
            errors.append(f"{workflow_ref(workflow, line)}: unknown needs job: {needed}")

    for job in workflow.jobs.values():
        step_ids = {step.step_id for step in job.steps if step.step_id}
        for match in re.finditer(r"\bsteps\.([A-Za-z0-9_-]+)\b", job.text):
            step_id = match.group(1)
            if step_id not in step_ids:
                line = job.line + job.text[: match.start()].count("\n")
                errors.append(f"{workflow_ref(workflow, line)}: job {job.job_id} references unknown step id: {step_id}")

    return errors


def permission_value(workflow: Workflow, job: Job | None, scope: str) -> str:
    permissions = workflow.permissions if job is None or not job.permissions else job.permissions
    scalar = permissions.get("__scalar__", "")
    if scalar == "write-all":
        return "write"
    if scalar == "read-all":
        return "read"
    return permissions.get(scope, "")


def has_permission(workflow: Workflow, job: Job | None, scope: str, required: str) -> bool:
    value = permission_value(workflow, job, scope)
    if required == "read":
        return value in {"read", "write"}
    return value == "write"


def check_permissions(workflow: Workflow) -> list[str]:
    errors: list[str] = []
    if not workflow.permissions:
        errors.append(f"{workflow_ref(workflow)}: workflow is missing top-level permissions")
    elif "__scalar__" in workflow.permissions:
        errors.append(f"{workflow_ref(workflow)}: workflow permissions must be explicit, not {workflow.permissions['__scalar__']}")
    elif not has_permission(workflow, None, "contents", "read"):
        errors.append(f"{workflow_ref(workflow)}: top-level contents permission must be read")
    elif workflow.permissions.get("contents") == "write":
        errors.append(f"{workflow_ref(workflow)}: top-level contents permission must not be write")

    for job in workflow.jobs.values():
        for step in job.steps:
            action = short_action(step.uses)
            if action == ACTION_ATTEST:
                if not has_permission(workflow, job, "id-token", "write"):
                    errors.append(f"{step_ref(workflow, step)}: attestation action requires id-token: write")
                if not has_permission(workflow, job, "attestations", "write"):
                    errors.append(f"{step_ref(workflow, step)}: attestation action requires attestations: write")
            elif action == ACTION_RELEASE:
                if not has_permission(workflow, job, "contents", "write"):
                    errors.append(f"{step_ref(workflow, step)}: GitHub release action requires contents: write")
            elif action in {ACTION_DEPLOY_PAGES, ACTION_UPLOAD_PAGES}:
                if not has_permission(workflow, job, "pages", "write"):
                    errors.append(f"{step_ref(workflow, step)}: Pages publish action requires pages: write")
                if action == ACTION_DEPLOY_PAGES and not has_permission(workflow, job, "id-token", "write"):
                    errors.append(f"{step_ref(workflow, step)}: Pages deploy action requires id-token: write")
            elif action == ACTION_DOCKER_BUILD:
                if "push: true" in step.text and not has_permission(workflow, job, "packages", "write"):
                    errors.append(f"{step_ref(workflow, step)}: pushed container image requires packages: write")
    return errors


def check_timeouts(workflow: Workflow, strict_timeouts: bool) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    for job in workflow.jobs.values():
        if not job.timeout:
            message = f"{job_ref(workflow, job)}: missing timeout-minutes"
            if strict_timeouts:
                errors.append(message)
            else:
                warnings.append(message)
            continue
        try:
            timeout = int(job.timeout)
        except ValueError:
            errors.append(f"{job_ref(workflow, job)}: timeout-minutes must be an integer")
            continue
        if timeout < 1 or timeout > 360:
            errors.append(f"{job_ref(workflow, job)}: timeout-minutes must be between 1 and 360")
    return errors, warnings


def artifact_paths(value: str) -> list[str]:
    paths: list[str] = []
    for raw in value.splitlines() or [value]:
        path = strip_comment_value(raw)
        if path:
            paths.append(path)
    return paths


def validate_path(workflow: Workflow, line: int, path: str, label: str) -> list[str]:
    errors: list[str] = []
    if path.startswith(("/", "~")):
        errors.append(f"{workflow_ref(workflow, line)}: {label} artifact path must be repo-relative: {path}")
    if path in {".", "./", "**", "**/*"}:
        errors.append(f"{workflow_ref(workflow, line)}: {label} artifact path is too broad: {path}")
    normalized = path.replace("\\", "/")
    if normalized == ".." or normalized.startswith("../") or "/../" in normalized:
        errors.append(f"{workflow_ref(workflow, line)}: {label} artifact path escapes repo: {path}")
    return errors


def check_artifact_paths(workflow: Workflow) -> list[str]:
    errors: list[str] = []
    for job in workflow.jobs.values():
        for step in job.steps:
            action = short_action(step.uses)
            if action == ACTION_UPLOAD_ARTIFACT:
                if step.with_fields.get("if-no-files-found") != "error":
                    errors.append(f"{step_ref(workflow, step)}: upload-artifact must set if-no-files-found: error")
                path_value = step.with_fields.get("path", "")
                if not path_value:
                    errors.append(f"{step_ref(workflow, step)}: upload-artifact is missing path")
                for path in artifact_paths(path_value):
                    errors.extend(validate_path(workflow, step.line, path, "upload"))
            elif action == ACTION_DOWNLOAD_ARTIFACT:
                path_value = step.with_fields.get("path", "")
                if not path_value:
                    errors.append(f"{step_ref(workflow, step)}: download-artifact is missing path")
                for path in artifact_paths(path_value):
                    errors.extend(validate_path(workflow, step.line, path, "download"))
            elif action == ACTION_UPLOAD_PAGES:
                path_value = step.with_fields.get("path", "")
                if not path_value:
                    errors.append(f"{step_ref(workflow, step)}: upload-pages-artifact is missing path")
                for path in artifact_paths(path_value):
                    errors.extend(validate_path(workflow, step.line, path, "pages"))
            elif action == ACTION_RELEASE:
                files_value = step.with_fields.get("files", "")
                if not files_value:
                    errors.append(f"{step_ref(workflow, step)}: release action is missing files")
                for path in artifact_paths(files_value):
                    errors.extend(validate_path(workflow, step.line, path, "release"))
    return errors


def require_text(workflow: Workflow, text: str, needle: str, message: str) -> list[str]:
    if needle in text:
        return []
    return [f"{workflow_ref(workflow)}: {message}"]


def require_order(workflow: Workflow, text: str, first: str, second: str, message: str) -> list[str]:
    first_pos = text.find(first)
    second_pos = text.find(second)
    if first_pos >= 0 and second_pos >= 0 and first_pos < second_pos:
        return []
    return [f"{workflow_ref(workflow)}: {message}"]


def workflow_has_tag_push(workflow: Workflow) -> bool:
    return "push:" in workflow.text and "tags:" in workflow.text and re.search(r"""['"]v\*['"]""", workflow.text)


def check_release_packages_gate(workflow: Workflow) -> list[str]:
    errors: list[str] = []
    if not workflow_has_tag_push(workflow):
        errors.append(f"{workflow_ref(workflow)}: release workflow must run on v* tag pushes")
    errors.extend(require_text(workflow, workflow.text, "workflow_dispatch:", "release workflow must allow manual dispatch"))

    for required_job in ("linux", "macos", "windows", "release"):
        if required_job not in workflow.jobs:
            errors.append(f"{workflow_ref(workflow)}: release workflow is missing job: {required_job}")
    release = workflow.jobs.get("release")
    if not release:
        return errors

    if "github.ref_type == 'tag'" not in release.if_condition and 'github.ref_type == "tag"' not in release.if_condition:
        errors.append(f"{job_ref(workflow, release)}: release job must run only for tag refs")
    for dependency in ("linux", "macos", "windows"):
        if not re.search(rf"^\s+-\s+{re.escape(dependency)}\s*$", release.text, re.MULTILINE):
            errors.append(f"{job_ref(workflow, release)}: release job must need {dependency}")

    release_checks = {
        "tag/version match gate": '"${GITHUB_REF_NAME}" != "v${version}"',
        "exact release artifact set gate": "Release artifact set must exactly match",
        "flattened artifact gate": "Release artifacts must be flattened",
        "non-empty artifact gate": "Release artifact is missing or empty",
        "checksum verification": "sha256sum -c SHA256SUMS",
        "release evidence generation": "--mode release-assets",
        "release evidence validation": "release-matrix-validate",
        "provenance attestation": "actions/attest@",
        "GitHub release upload": "softprops/action-gh-release@",
    }
    for label, needle in release_checks.items():
        errors.extend(require_text(workflow, release.text, needle, f"release job is missing {label}"))
    errors.extend(
        require_order(
            workflow,
            release.text,
            "release-matrix-validate",
            "softprops/action-gh-release@",
            "release evidence validation must run before GitHub release upload",
        )
    )
    return errors


def check_public_package_gate(workflow: Workflow) -> list[str]:
    errors: list[str] = []
    if not workflow_has_tag_push(workflow):
        errors.append(f"{workflow_ref(workflow)}: public package workflow must run on v* tag pushes")
    errors.extend(require_text(workflow, workflow.text, "workflow_dispatch:", "public package workflow must allow manual dispatch"))

    package_web = workflow.jobs.get("package-web")
    deploy_pages = workflow.jobs.get("deploy-pages")
    if not package_web:
        errors.append(f"{workflow_ref(workflow)}: public package workflow is missing package-web job")
        return errors
    if not deploy_pages:
        errors.append(f"{workflow_ref(workflow)}: public package workflow is missing deploy-pages job")
    for dependency in ("linux", "macos", "windows"):
        if not re.search(rf"^\s+-\s+{re.escape(dependency)}\s*$", package_web.text, re.MULTILINE):
            errors.append(f"{job_ref(workflow, package_web)}: package-web job must need {dependency}")

    package_checks = {
        "publish output": "publish: ${{ steps.package_site_mode.outputs.publish }}",
        "tag-only publish gate": '"$REF_TYPE" != "tag"',
        "private signing key gate": "SSHFLING_REPO_GPG_PRIVATE_KEY",
        "fingerprint gate": "SSHFLING_REPO_GPG_FINGERPRINT",
        "ephemeral key publish block": "Ephemeral repository signing keys are not allowed",
        "public package verification": "packaging/verify-public-web.sh",
        "package-site evidence generation": "--mode package-site",
        "package-site evidence validation": "release-matrix-validate",
        "publish-gated attestation": "steps.package_site_mode.outputs.publish == 'true'",
        "package web artifact upload": "public-package-web",
    }
    for label, needle in package_checks.items():
        errors.extend(require_text(workflow, package_web.text, needle, f"package-web job is missing {label}"))

    if deploy_pages:
        if "needs.package-web.outputs.publish == 'true'" not in deploy_pages.if_condition:
            errors.append(f"{job_ref(workflow, deploy_pages)}: deploy-pages job must be gated by package-web publish output")
        deploy_checks = {
            "Pages upload": "actions/upload-pages-artifact@",
            "Pages deploy": "actions/deploy-pages@",
            "post-deploy install script check": "fetch install.sh",
            "APT signature check": "BEGIN PGP SIGNED MESSAGE",
            "RPM signature check": "repomd.xml.asc",
            "signed apt source check": "signed-by=/usr/share/keyrings/sshfling-repo.gpg",
            "RPM repo_gpgcheck check": "repo_gpgcheck=1",
            "download checksum check": "downloads/SHA256SUMS",
        }
        for label, needle in deploy_checks.items():
            errors.extend(require_text(workflow, deploy_pages.text, needle, f"deploy-pages job is missing {label}"))
    return errors


def check_github_packages_gate(workflow: Workflow) -> list[str]:
    errors: list[str] = []
    if not workflow_has_tag_push(workflow):
        errors.append(f"{workflow_ref(workflow)}: GitHub Packages workflow must run on v* tag pushes")
    if not has_permission(workflow, None, "packages", "write"):
        errors.append(f"{workflow_ref(workflow)}: GitHub Packages workflow requires packages: write")
    errors.extend(require_text(workflow, workflow.text, "GITHUB_REF_TYPE", "GitHub Packages workflow is missing tag/version gate"))
    errors.extend(require_text(workflow, workflow.text, "GITHUB_REF_NAME", "GitHub Packages workflow is missing tag/version gate"))
    errors.extend(
        require_text(
            workflow,
            workflow.text,
            "type=raw,value=latest,enable=${{ github.ref_type == 'tag' }}",
            "GitHub Packages latest tag must only be enabled for tag refs",
        )
    )
    return errors


def check_release_gates(workflow: Workflow) -> list[str]:
    name = workflow.path.name
    if name == "release-packages.yml":
        return check_release_packages_gate(workflow)
    if name == "public-package-web.yml":
        return check_public_package_gate(workflow)
    if name == "github-packages.yml":
        return check_github_packages_gate(workflow)
    return []


def check_workflow(workflow: Workflow, strict_timeouts: bool) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    errors.extend(check_expressions(workflow))
    errors.extend(check_permissions(workflow))
    timeout_errors, timeout_warnings = check_timeouts(workflow, strict_timeouts)
    errors.extend(timeout_errors)
    warnings.extend(timeout_warnings)
    errors.extend(check_artifact_paths(workflow))
    errors.extend(check_release_gates(workflow))
    return errors, warnings


def workflow_files(workflow_dir: Path) -> list[Path]:
    if not workflow_dir.exists():
        raise SystemExit(f"workflow directory not found: {workflow_dir}")
    return sorted(path for path in workflow_dir.iterdir() if path.suffix in {".yml", ".yaml"} and path.is_file())


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument("--workflow-dir", type=Path, default=Path(".github/workflows"))
    parser.add_argument("--strict-timeouts", action="store_true", help="fail jobs that omit timeout-minutes")
    parser.add_argument("--max-errors", type=int, default=50)
    args = parser.parse_args(argv)

    repo_root = args.repo_root.resolve()
    workflow_dir = args.workflow_dir
    if not workflow_dir.is_absolute():
        workflow_dir = repo_root / workflow_dir
    workflows = [parse_workflow(path) for path in workflow_files(workflow_dir)]

    errors: list[str] = []
    warnings: list[str] = []
    for workflow in workflows:
        workflow_errors, workflow_warnings = check_workflow(workflow, args.strict_timeouts)
        errors.extend(workflow_errors)
        warnings.extend(workflow_warnings)

    if warnings:
        print("workflow static check warnings:", file=sys.stderr)
        for warning in warnings:
            print(f"  - {warning}", file=sys.stderr)

    print(f"checked {len(workflows)} workflow file(s)")
    if errors:
        print("workflow static check failed:", file=sys.stderr)
        for error in errors[: args.max_errors]:
            print(f"  - {error}", file=sys.stderr)
        if len(errors) > args.max_errors:
            print(f"  - stopped after {args.max_errors} errors", file=sys.stderr)
        return 1

    print("workflow static check ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
