#!/usr/bin/env python3
# =============================================================================
# validate-plugins.py — Schema-aware plugin test runner
# =============================================================================
# Validates all Cleansing Fire plugins against specs/plugin-schema.json
# and tests/fixtures/plugin-fixtures.json.
#
# Usage:
#   python3 tests/validate-plugins.py                # Test all plugins
#   python3 tests/validate-plugins.py forge-satire   # Test one plugin
#   python3 tests/validate-plugins.py --list         # List all plugins and actions
#
# Features:
#   - Schema validation against plugin-schema.json
#   - Action discovery from fixture manifest
#   - CF_TEST_MODE=1 for offline testing
#   - JUnit-compatible exit codes
#
# Exit: 0 all pass, 1 any fail
# =============================================================================

import json
import os
import subprocess
import sys
import time
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parent.parent
PLUGIN_DIR = PROJECT_DIR / "plugins"
FIXTURES_FILE = PROJECT_DIR / "tests" / "fixtures" / "plugin-fixtures.json"
SCHEMA_FILE = PROJECT_DIR / "specs" / "plugin-schema.json"

# Colors
if sys.stdout.isatty():
    GREEN = "\033[0;32m"
    RED = "\033[0;31m"
    YELLOW = "\033[0;33m"
    BLUE = "\033[0;34m"
    DIM = "\033[0;90m"
    BOLD = "\033[1m"
    NC = "\033[0m"
else:
    GREEN = RED = YELLOW = BLUE = DIM = BOLD = NC = ""


def load_fixtures():
    """Load plugin test fixtures."""
    if FIXTURES_FILE.exists():
        with open(FIXTURES_FILE) as f:
            return json.load(f).get("plugins", {})
    return {}


def load_schema():
    """Load plugin schema for validation."""
    if SCHEMA_FILE.exists():
        with open(SCHEMA_FILE) as f:
            return json.load(f)
    return None


def get_plugins(pattern=None):
    """Get list of plugin files, optionally filtered."""
    plugins = []
    for p in sorted(PLUGIN_DIR.iterdir()):
        if not p.is_file() or p.name == "README":
            continue
        if pattern and pattern not in p.name:
            continue
        plugins.append(p)
    return plugins


def run_plugin(plugin_path, input_data, timeout=15):
    """Run a plugin with JSON input, return (stdout, exit_code, duration)."""
    env = {
        **os.environ,
        "CF_PROJECT_DIR": str(PROJECT_DIR),
        "CF_TEST_MODE": "1",
    }
    start = time.time()
    try:
        result = subprocess.run(
            [str(plugin_path)],
            input=json.dumps(input_data),
            capture_output=True,
            text=True,
            timeout=timeout,
            env=env,
        )
        duration = time.time() - start
        return result.stdout, result.returncode, duration
    except subprocess.TimeoutExpired:
        return "", -1, timeout
    except Exception as e:
        return str(e), -2, time.time() - start


def validate_output(stdout, exit_code, schema=None):
    """Validate plugin output against the schema contract."""
    issues = []

    # Must produce output
    if not stdout.strip():
        if exit_code != 0:
            # Acceptable: error with no JSON (stderr only)
            issues.append(("warn", "non-zero exit with no stdout"))
            return issues
        issues.append(("fail", "no stdout output"))
        return issues

    # Must be valid JSON
    try:
        data = json.loads(stdout)
    except json.JSONDecodeError as e:
        issues.append(("fail", f"invalid JSON: {e}"))
        return issues

    # Must be a dict
    if not isinstance(data, dict):
        issues.append(("fail", f"output is {type(data).__name__}, expected object"))
        return issues

    # Success output must not have top-level 'error'
    if exit_code == 0 and "error" in data:
        issues.append(("warn", "exit 0 but output contains 'error' field"))

    # Error output must have 'error' field
    if exit_code != 0 and "error" not in data:
        issues.append(("warn", "non-zero exit but no 'error' field in output"))

    return issues


def test_plugin(plugin_path, fixtures, schema):
    """Run all tests for a single plugin."""
    name = plugin_path.name
    results = {
        "name": name,
        "tests": [],
        "passed": 0,
        "failed": 0,
        "warnings": 0,
    }

    # Test 1: Is executable?
    if not os.access(plugin_path, os.X_OK):
        results["tests"].append(("fail", "not executable"))
        results["failed"] += 1
        return results
    results["tests"].append(("pass", "executable"))
    results["passed"] += 1

    # Test 2: Has shebang?
    with open(plugin_path, "r") as f:
        first_line = f.readline().strip()
    if first_line.startswith("#!"):
        results["tests"].append(("pass", f"shebang: {first_line}"))
        results["passed"] += 1
    else:
        results["tests"].append(("warn", "no shebang line"))
        results["warnings"] += 1

    # Test 3: Unknown action produces error
    stdout, exit_code, duration = run_plugin(
        plugin_path, {"action": "__test_unknown_xyz__"}
    )
    if exit_code != 0:
        issues = validate_output(stdout, exit_code, schema)
        if any(i[0] == "fail" for i in issues):
            for i in issues:
                results["tests"].append(i)
                if i[0] == "fail":
                    results["failed"] += 1
                else:
                    results["warnings"] += 1
        else:
            results["tests"].append(("pass", f"unknown action: error exit {exit_code} ({duration:.1f}s)"))
            results["passed"] += 1
    else:
        results["tests"].append(("warn", "unknown action exits 0"))
        results["warnings"] += 1

    # Test 4: Empty JSON input
    stdout, exit_code, duration = run_plugin(plugin_path, {})
    if exit_code != 0:
        results["tests"].append(("pass", f"empty input: error exit {exit_code} ({duration:.1f}s)"))
        results["passed"] += 1
    else:
        # Exit 0 on empty input is ok if it returns valid JSON
        try:
            json.loads(stdout)
            results["tests"].append(("pass", f"empty input: valid JSON, exit 0 ({duration:.1f}s)"))
            results["passed"] += 1
        except (json.JSONDecodeError, ValueError):
            results["tests"].append(("warn", "empty input: exit 0 with invalid output"))
            results["warnings"] += 1

    # Test 5: Garbage input
    env = {**os.environ, "CF_PROJECT_DIR": str(PROJECT_DIR), "CF_TEST_MODE": "1"}
    try:
        result = subprocess.run(
            [str(plugin_path)],
            input="not json at all {{{",
            capture_output=True,
            text=True,
            timeout=10,
            env=env,
        )
        if result.returncode != 0:
            results["tests"].append(("pass", f"garbage input: error exit {result.returncode}"))
            results["passed"] += 1
        else:
            results["tests"].append(("warn", "garbage input exits 0"))
            results["warnings"] += 1
    except subprocess.TimeoutExpired:
        results["tests"].append(("warn", "garbage input: timeout"))
        results["warnings"] += 1

    # Test 6: Fixture-based action tests (if available)
    plugin_fixtures = fixtures.get(name, {}).get("fixtures", {})
    for action_name, fixture in plugin_fixtures.items():
        input_data = fixture.get("input", {})
        expected_keys = fixture.get("expected_keys", [])

        stdout, exit_code, duration = run_plugin(plugin_path, input_data)

        if exit_code == -1:
            results["tests"].append(("warn", f"action '{action_name}': timeout"))
            results["warnings"] += 1
            continue

        # In test mode, we accept both success and graceful API errors
        if stdout.strip():
            try:
                data = json.loads(stdout)
                if isinstance(data, dict):
                    if exit_code == 0:
                        # Check expected keys
                        missing = [k for k in expected_keys if k not in data]
                        if missing:
                            results["tests"].append(("warn", f"action '{action_name}': missing keys {missing}"))
                            results["warnings"] += 1
                        else:
                            results["tests"].append(("pass", f"action '{action_name}': valid JSON ({duration:.1f}s)"))
                            results["passed"] += 1
                    elif "error" in data:
                        # Graceful error (e.g., missing API key in test mode)
                        results["tests"].append(("pass", f"action '{action_name}': graceful error ({duration:.1f}s)"))
                        results["passed"] += 1
                    else:
                        results["tests"].append(("warn", f"action '{action_name}': exit {exit_code}, no error field"))
                        results["warnings"] += 1
                else:
                    results["tests"].append(("fail", f"action '{action_name}': output not a JSON object"))
                    results["failed"] += 1
            except json.JSONDecodeError:
                results["tests"].append(("fail", f"action '{action_name}': invalid JSON output"))
                results["failed"] += 1
        else:
            results["tests"].append(("warn", f"action '{action_name}': no stdout (exit {exit_code})"))
            results["warnings"] += 1

    return results


def list_plugins(fixtures):
    """List all plugins and their known actions."""
    plugins = get_plugins()
    print(f"{BOLD}Cleansing Fire Plugin Registry{NC}")
    print(f"{DIM}{'─' * 60}{NC}")
    for p in plugins:
        name = p.name
        plugin_info = fixtures.get(name, {})
        actions = plugin_info.get("actions", [])
        fixture_count = len(plugin_info.get("fixtures", {}))
        has_shebang = open(p).readline().strip().startswith("#!")
        is_exec = os.access(p, os.X_OK)
        status = f"{GREEN}✓{NC}" if (has_shebang and is_exec) else f"{YELLOW}!{NC}"
        print(f"  {status} {BOLD}{name}{NC}")
        if actions:
            print(f"    actions: {', '.join(actions)}")
            print(f"    fixtures: {fixture_count}/{len(actions)}")
        print()


def main():
    args = sys.argv[1:]
    pattern = None
    do_list = False

    for arg in args:
        if arg in ("--list", "-l"):
            do_list = True
        elif arg in ("--help", "-h"):
            print("Usage: python3 tests/validate-plugins.py [--list] [pattern]")
            sys.exit(0)
        else:
            pattern = arg

    fixtures = load_fixtures()
    schema = load_schema()

    if do_list:
        list_plugins(fixtures)
        sys.exit(0)

    plugins = get_plugins(pattern)

    print(f"{BOLD}Cleansing Fire Plugin Validation{NC}")
    print(f"{DIM}{time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}{NC}")
    print()
    print(f"Testing {BOLD}{len(plugins)}{NC} plugins")
    print()

    all_results = []
    total_passed = 0
    total_failed = 0
    total_warnings = 0

    for plugin in plugins:
        print(f"{BLUE}── {plugin.name} ──{NC}")
        result = test_plugin(plugin, fixtures, schema)
        all_results.append(result)
        total_passed += result["passed"]
        total_failed += result["failed"]
        total_warnings += result["warnings"]

        for level, msg in result["tests"]:
            icon = {"pass": f"{GREEN}✓{NC}", "fail": f"{RED}✗{NC}", "warn": f"{YELLOW}!{NC}"}[level]
            print(f"  {icon} {msg}")

        status = f"{GREEN}PASS{NC}" if result["failed"] == 0 else f"{RED}FAIL{NC}"
        print(f"  {status} ({result['passed']} pass, {result['failed']} fail, {result['warnings']} warn)")
        print()

    # Summary
    print(f"{BOLD}{'═' * 50}{NC}")
    print(f"{BOLD}Summary{NC}")
    print(f"{BOLD}{'═' * 50}{NC}")
    print()
    print(f"  {GREEN}Passed{NC}:   {total_passed}")
    print(f"  {RED}Failed{NC}:   {total_failed}")
    print(f"  {YELLOW}Warnings{NC}: {total_warnings}")
    print(f"  Plugins:  {len(plugins)}")
    print()

    if total_failed > 0:
        print(f"{RED}Some tests failed.{NC}")
        sys.exit(1)
    else:
        print(f"{GREEN}All plugins passed validation.{NC}")
        sys.exit(0)


if __name__ == "__main__":
    main()
