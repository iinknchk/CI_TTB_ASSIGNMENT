"""Find, start and stop the Android stack that question 4 needs.

The batch files call this instead of doing it themselves, because waiting for an
emulator to finish booting and for Appium to answer is more than `timeout /t` can
do reliably.

    python Resources/Library/android_tools.py status
    python Resources/Library/android_tools.py ensure          # emulator + appium
    python Resources/Library/android_tools.py ensure-emulator
    python Resources/Library/android_tools.py ensure-appium
    python Resources/Library/android_tools.py stop            # only what it started

Exit code 0 = ready, 1 = could not get there (the reason is printed).
"""
import argparse
import json
import os
import platform
import shutil
import subprocess
import sys
import time
import urllib.error
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
STATE_FILE = os.path.join(ROOT, "Results", "Launcher", "android_state.json")
IS_WINDOWS = platform.system() == "Windows"
EXE = ".exe" if IS_WINDOWS else ""
BAT = ".bat" if IS_WINDOWS else ""

APPIUM_HOST = os.environ.get("APPIUM_HOST", "127.0.0.1")
APPIUM_PORT = int(os.environ.get("APPIUM_PORT", "4723"))
APPIUM_URL = f"http://{APPIUM_HOST}:{APPIUM_PORT}"
DEFAULT_AVD = os.environ.get("TTB_AVD", "ttb_test")


# ---------------------------------------------------------------- locating the SDK
def sdk_root():
    """Where the Android SDK is. The env vars win; then the usual install folders."""
    for name in ("ANDROID_HOME", "ANDROID_SDK_ROOT"):
        value = os.environ.get(name)
        if value and os.path.isdir(value):
            return value
    candidates = []
    if IS_WINDOWS:
        local = os.environ.get("LOCALAPPDATA", "")
        if local:
            candidates.append(os.path.join(local, "Android", "Sdk"))
        candidates.append(r"C:\Android\Sdk")
    else:
        home = os.path.expanduser("~")
        candidates += [os.path.join(home, "Android", "Sdk"),
                       os.path.join(home, "Library", "Android", "sdk"),
                       "/usr/lib/android-sdk"]
    for path in candidates:
        if os.path.isdir(path):
            return path
    return ""


def sdk_tool(*relative):
    """Absolute path of an SDK tool, or '' when the SDK or the tool is missing."""
    root = sdk_root()
    if not root:
        return ""
    path = os.path.join(root, *relative)
    return path if os.path.isfile(path) else ""


def adb():
    return sdk_tool("platform-tools", "adb" + EXE) or shutil.which("adb") or ""


def emulator():
    return sdk_tool("emulator", "emulator" + EXE) or shutil.which("emulator") or ""


def appium():
    return shutil.which("appium" + BAT) or shutil.which("appium") or ""


def run(command, timeout=60):
    """Run and return (returncode, stdout+stderr); never raises."""
    try:
        done = subprocess.run(command, capture_output=True, text=True, timeout=timeout,
                              errors="replace")
        return done.returncode, (done.stdout or "") + (done.stderr or "")
    except (OSError, subprocess.SubprocessError) as error:
        return 1, str(error)


# ---------------------------------------------------------------- state
def devices():
    """Serials of devices that adb reports as ready (not 'offline'/'unauthorized')."""
    binary = adb()
    if not binary:
        return []
    code, output = run([binary, "devices"])
    if code != 0:
        return []
    found = []
    for line in output.splitlines()[1:]:
        parts = line.split()
        if len(parts) >= 2 and parts[1] == "device":
            found.append(parts[0])
    return found


def avds():
    binary = emulator()
    if not binary:
        return []
    code, output = run([binary, "-list-avds"], timeout=90)
    if code != 0:
        return []
    return [line.strip() for line in output.splitlines()
            if line.strip() and " " not in line.strip()]


def appium_up():
    try:
        with urllib.request.urlopen(f"{APPIUM_URL}/status", timeout=5) as answer:
            return answer.status == 200
    except (urllib.error.URLError, OSError):
        return False


def read_state():
    try:
        with open(STATE_FILE, encoding="utf-8") as stream:
            return json.load(stream)
    except (OSError, ValueError):
        return {}


def write_state(state):
    os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
    with open(STATE_FILE, "w", encoding="utf-8") as stream:
        json.dump(state, stream, indent=2)


# ---------------------------------------------------------------- starting things
def spawn(command, log_name):
    """Start a long-running process that outlives this script."""
    os.makedirs(os.path.join(ROOT, "Results", "Launcher"), exist_ok=True)
    log_path = os.path.join(ROOT, "Results", "Launcher", log_name)
    log = open(log_path, "a", encoding="utf-8")
    log.write(f"\n===== {time.strftime('%Y-%m-%d %H:%M:%S')} {' '.join(command)}\n")
    log.flush()
    flags = 0
    if IS_WINDOWS:
        flags = subprocess.CREATE_NEW_PROCESS_GROUP | getattr(subprocess, "DETACHED_PROCESS", 8)
    process = subprocess.Popen(command, stdout=log, stderr=subprocess.STDOUT,
                               stdin=subprocess.DEVNULL, cwd=ROOT, creationflags=flags)
    return process.pid, log_path


def ensure_emulator(avd=DEFAULT_AVD, timeout=300):
    existing = devices()
    if existing:
        print(f"[android] device already up: {', '.join(existing)}")
        return 0

    binary = emulator()
    if not binary:
        print("[android] FAIL emulator not found. Run bat_file\\Launcher\\Setup_Android.bat")
        return 1
    available = avds()
    if not available:
        print("[android] FAIL no AVD on this machine. Run Setup_Android.bat to create one,")
        print("          or create it in Android Studio > Device Manager.")
        return 1
    if avd not in available:
        print(f"[android] AVD {avd!r} not found, using {available[0]!r} instead")
        avd = available[0]

    print(f"[android] starting emulator {avd} (this takes 1-3 minutes the first time)")
    command = [binary, "-avd", avd, "-no-snapshot-save", "-no-boot-anim"]
    if os.environ.get("TTB_EMULATOR_HEADLESS"):
        command += ["-no-window"]
    pid, log_path = spawn(command, "emulator.log")
    state = read_state()
    state["emulator_pid"] = pid
    state["emulator_avd"] = avd
    state["emulator_started_by_us"] = True
    write_state(state)
    print(f"[android] emulator pid {pid}, log {log_path}")

    binary_adb = adb()
    deadline = time.time() + timeout
    while time.time() < deadline:
        serials = devices()
        if serials:
            code, output = run([binary_adb, "-s", serials[0], "shell",
                                "getprop", "sys.boot_completed"], timeout=20)
            if code == 0 and output.strip() == "1":
                print(f"[android] emulator ready: {serials[0]}")
                return 0
        time.sleep(5)
        print(f"[android]   waiting... {int(deadline - time.time())}s left")
    print(f"[android] FAIL the emulator did not finish booting in {timeout}s - see {log_path}")
    return 1


def ensure_appium(timeout=90):
    if appium_up():
        print(f"[android] appium already answering on {APPIUM_URL}")
        return 0
    binary = appium()
    if not binary:
        print("[android] FAIL appium not found. Run bat_file\\Launcher\\Setup_Android.bat")
        print("          or install it yourself: npm install -g appium")
        return 1
    print(f"[android] starting appium on {APPIUM_URL}")
    pid, log_path = spawn([binary, "--address", APPIUM_HOST, "--port", str(APPIUM_PORT)],
                          "appium.log")
    state = read_state()
    state["appium_pid"] = pid
    state["appium_started_by_us"] = True
    write_state(state)
    deadline = time.time() + timeout
    while time.time() < deadline:
        if appium_up():
            print(f"[android] appium ready (pid {pid})")
            return 0
        time.sleep(2)
    print(f"[android] FAIL appium did not answer in {timeout}s - see {log_path}")
    return 1


def stop():
    """Stop only what this script started, so a device you opened yourself survives."""
    state = read_state()
    if state.get("emulator_started_by_us"):
        binary = adb()
        for serial in devices():
            if serial.startswith("emulator-"):
                run([binary, "-s", serial, "emu", "kill"], timeout=30)
                print(f"[android] stopped emulator {serial}")
    if state.get("appium_started_by_us") and state.get("appium_pid"):
        pid = state["appium_pid"]
        if IS_WINDOWS:
            run(["taskkill", "/PID", str(pid), "/T", "/F"], timeout=30)
        else:
            try:
                os.kill(pid, 15)
            except OSError:
                pass
        print(f"[android] stopped appium (pid {pid})")
    write_state({})
    return 0


def status():
    root = sdk_root()
    print("=" * 62)
    print(" Android stack")
    print("=" * 62)
    print(f" SDK          : {root or 'NOT FOUND'}")
    print(f" adb          : {adb() or 'NOT FOUND'}")
    print(f" emulator     : {emulator() or 'NOT FOUND'}")
    print(f" appium       : {appium() or 'NOT FOUND'}")
    print(f" AVDs         : {', '.join(avds()) or 'none'}")
    print(f" devices up   : {', '.join(devices()) or 'none'}")
    print(f" appium up    : {'yes' if appium_up() else 'no'}  ({APPIUM_URL})")
    apk = os.path.join(ROOT, "Upload_file", "Minimal-Todo.apk")
    print(f" apk          : {'yes' if os.path.isfile(apk) else 'MISSING ' + apk}")
    print("=" * 62)
    ready = bool(devices()) and appium_up() and os.path.isfile(apk)
    print(" READY to run Q4" if ready else " NOT ready - run Start_Android_Stack.bat")
    return 0 if ready else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["status", "ensure", "ensure-emulator",
                                           "ensure-appium", "stop"])
    parser.add_argument("--avd", default=DEFAULT_AVD)
    parser.add_argument("--timeout", type=int, default=300)
    args = parser.parse_args()

    if args.action == "status":
        return status()
    if args.action == "stop":
        return stop()
    if args.action == "ensure-emulator":
        return ensure_emulator(args.avd, args.timeout)
    if args.action == "ensure-appium":
        return ensure_appium()
    code = ensure_emulator(args.avd, args.timeout)
    if code:
        return code
    return ensure_appium()


if __name__ == "__main__":
    sys.exit(main())
