"""Check that this machine can run every suite - installs nothing.

Called by bat_file/Launcher/Setup.bat step 4 and by Check_Machine.bat.
Exit code 0 = everything a suite needs is there, 1 = at least one [FAIL].
"""
import importlib
import os
import shutil
import socket
import subprocess
import sys
import urllib.error
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
REPORT_DIR = os.path.join(ROOT, "Results", "Launcher")

# (import name, what breaks without it)
PACKAGES = [
    ("robot", "every suite"),
    ("RequestsLibrary", "Q3 api"),
    ("Browser", "Q2 web"),
    ("AppiumLibrary", "Q4 mobile"),
    ("requests", "Q3 api"),
    ("openpyxl", "Excel_sync_robot_files"),
    ("yaml", "Resources/Settings/Api_body"),
]

HOSTS = [
    ("the-internet.herokuapp.com", "Q2 web"),
    ("reqres.in", "Q3 api"),
]

lines = []
failures = 0


def report(level, what, detail=""):
    global failures
    if level == "FAIL":
        failures += 1
    line = f"[{level:4}] {what}"
    if detail:
        line += f" - {detail}"
    print(line)
    lines.append(line)


def check_python():
    version = sys.version_info
    text = f"{version.major}.{version.minor}.{version.micro} ({sys.executable})"
    if version[:2] >= (3, 10):
        report("OK", "Python", text)
    else:
        report("FAIL", "Python", f"{text} - 3.10 or newer is required")


def check_packages():
    for name, used_by in PACKAGES:
        try:
            importlib.import_module(name)
        except ImportError:
            report("FAIL", f"package {name}", f"missing - needed by {used_by}. Run Setup.bat")
        else:
            report("OK", f"package {name}", used_by)


def check_browser_node_side():
    """Browser library only works once `rfbrowser init` has installed its node side."""
    try:
        import Browser  # noqa: F401
    except ImportError:
        report("SKIP", "rfbrowser", "Browser library is not installed")
        return
    node_dir = os.path.join(os.path.dirname(importlib.import_module("Browser").__file__),
                            "wrapper", "node_modules")
    if os.path.isdir(node_dir):
        report("OK", "rfbrowser node side", "installed")
    else:
        report("FAIL", "rfbrowser node side", "run: rfbrowser init  (needed by Q2 web)")


def check_appium():
    appium = shutil.which("appium")
    if not appium:
        report("WARN", "appium", "not on PATH - Q4 mobile cannot run (npm install -g appium)")
        return
    try:
        version = subprocess.run([appium, "--version"], capture_output=True, text=True,
                                 timeout=60).stdout.strip()
    except (OSError, subprocess.SubprocessError) as error:
        report("WARN", "appium", f"found but did not answer: {error}")
        return
    report("OK", "appium", f"{version} ({appium})")
    adb = shutil.which("adb")
    if not adb:
        report("WARN", "adb", "not on PATH - no Android device can be reached")
        return
    try:
        devices = subprocess.run([adb, "devices"], capture_output=True, text=True, timeout=60).stdout
    except (OSError, subprocess.SubprocessError) as error:
        report("WARN", "adb", f"did not answer: {error}")
        return
    attached = [l.split()[0] for l in devices.splitlines()[1:] if l.strip() and "device" in l]
    if attached:
        report("OK", "android device", ", ".join(attached))
    else:
        report("WARN", "android device", "none attached - start an emulator for Q4")


def check_apk():
    apk = os.path.join(ROOT, "Upload_file", "Minimal-Todo.apk")
    if os.path.isfile(apk):
        size = os.path.getsize(apk) / (1024 * 1024)
        report("OK", "Minimal-Todo.apk", f"{size:.1f} MB")
    else:
        report("WARN", "Minimal-Todo.apk", "not in Upload_file - see README.md for how to build it")


def check_hosts():
    for host, used_by in HOSTS:
        url = f"https://{host}"
        try:
            request = urllib.request.Request(url, method="HEAD",
                                             headers={"User-Agent": "setup-check"})
            with urllib.request.urlopen(request, timeout=20) as answer:
                report("OK", f"https://{host}", f"HTTP {answer.status} ({used_by})")
        except urllib.error.HTTPError as error:
            # any answer at all means the host is reachable
            report("OK", f"https://{host}", f"HTTP {error.code} ({used_by})")
        except (urllib.error.URLError, socket.timeout, OSError) as error:
            report("FAIL", f"https://{host}", f"not reachable: {error} - needed by {used_by}")


def main():
    print("=" * 66)
    print(" CI_TTB_ASSIGNMENT - machine check")
    print(f" Project: {ROOT}")
    print("=" * 66)
    check_python()
    check_packages()
    check_browser_node_side()
    check_appium()
    check_apk()
    check_hosts()
    print("=" * 66)
    verdict = "READY" if failures == 0 else f"{failures} BLOCKING PROBLEM(S)"
    print(f" {verdict}   (WARN = only that one suite is affected)")
    print("=" * 66)

    os.makedirs(REPORT_DIR, exist_ok=True)
    path = os.path.join(REPORT_DIR, f"setup_check_{os.environ.get('COMPUTERNAME', 'local')}.txt")
    with open(path, "w", encoding="utf-8") as stream:
        stream.write("\n".join(lines) + f"\n\n{verdict}\n")
    print(f" Report: {path}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
