"""Local launcher for CI_TTB_ASSIGNMENT.

Started by bat_file/Launcher/Start.bat. Serves Resources/Launcher/web/index.html on
127.0.0.1 and starts robot runs from the page, so nobody has to remember the robot
command line. Standard library only - no extra pip package to install.

    python Resources/Launcher/server.py            # opens the page in the browser
    LAUNCHER_PORT=8900 python ... /server.py       # another port
    RL_NO_BROWSER=1 python ... /server.py          # do not open a browser
"""
import json
import mimetypes
import os
import platform
import re
import subprocess
import sys
import threading
import time
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
WEB_DIR = os.path.join(HERE, "web")
RUN_ROOT = os.path.join(ROOT, "Results", "Launcher")
PORT = int(os.environ.get("LAUNCHER_PORT", "8810"))
IS_WINDOWS = platform.system() == "Windows"
RUN_ID_RE = re.compile(r"^[0-9]{8}_[0-9]{6}$")

SUITES = [
    {"key": "OFFLINE",        "label": "Q1 + Q6 (offline)",   "note": "no network, no browser - fastest check"},
    {"key": "Q1",             "label": "Q1 duplicate items",  "note": "list A / list B"},
    {"key": "Q2",             "label": "Q2 web login",        "note": "the-internet.herokuapp.com, needs a browser"},
    {"key": "Q3",             "label": "Q3 reqres API",       "note": "reqres.in, needs internet"},
    {"key": "Q4",             "label": "Q4 mobile todo",      "note": "needs Appium + an Android device"},
    {"key": "Q6",             "label": "Q6 simpleCipher",     "note": "A-Z wheel"},
    {"key": "ALL_BUT_MOBILE", "label": "Everything but Q4",   "note": "what CI runs"},
    {"key": "ALL",            "label": "Everything",          "note": "Q4 included - an emulator must be up"},
]


def new_run_id():
    return time.strftime("%Y%m%d_%H%M%S")


def run_dir_of(run_id):
    return os.path.join(RUN_ROOT, run_id)


def start_run(cfg):
    """Write input.json and start the run; returns the run id."""
    run_id = new_run_id()
    directory = run_dir_of(run_id)
    os.makedirs(directory, exist_ok=True)
    with open(os.path.join(directory, "input.json"), "w", encoding="utf-8") as stream:
        json.dump(cfg, stream, indent=2)

    if IS_WINDOWS:
        # a visible console window per run, exactly like the other bat runners
        bat = os.path.join(ROOT, "bat_file", "Launcher", "Run_Batch.bat")
        environment = dict(os.environ, LAUNCHER_PY=sys.executable)
        subprocess.Popen(["cmd", "/c", "start", "", bat, run_id], cwd=ROOT, env=environment)
    else:
        runner = os.path.join(HERE, "run_from_json.py")
        log = open(os.path.join(directory, "runner.log"), "w", encoding="utf-8")
        subprocess.Popen([sys.executable, runner, run_id], cwd=ROOT, stdout=log,
                         stderr=subprocess.STDOUT)
    return run_id


def read_run(run_id):
    """State of one run: queued / running / finished, plus the console tail."""
    directory = run_dir_of(run_id)
    if not os.path.isdir(directory):
        return None
    state = {"run_id": run_id, "status": "running", "console": "", "totals": {}, "tests": []}
    result_path = os.path.join(directory, "result.json")
    if os.path.isfile(result_path):
        with open(result_path, encoding="utf-8") as stream:
            summary = json.load(stream)
        state["status"] = "passed" if summary.get("return_code") == 0 else "failed"
        state["totals"] = summary.get("totals", {})
        state["tests"] = summary.get("tests", [])
        state["seconds"] = summary.get("seconds")
        state["finished_at"] = summary.get("finished_at")
    console_path = os.path.join(directory, "console.txt")
    if os.path.isfile(console_path):
        with open(console_path, encoding="utf-8", errors="replace") as stream:
            state["console"] = stream.read()[-8000:]
    elif state["status"] == "running":
        state["status"] = "queued"
    state["report"] = f"/results/{run_id}/report.html" if os.path.isfile(
        os.path.join(directory, "report.html")) else ""
    state["summary"] = f"/results/{run_id}/Test_Summary.html" if os.path.isfile(
        os.path.join(directory, "Test_Summary.html")) else ""
    return state


def recent_runs(limit=20):
    if not os.path.isdir(RUN_ROOT):
        return []
    names = sorted((n for n in os.listdir(RUN_ROOT) if RUN_ID_RE.match(n)), reverse=True)
    runs = []
    for name in names[:limit]:
        state = read_run(name)
        if state:
            runs.append({key: state[key] for key in
                         ("run_id", "status", "totals", "report", "summary")})
    return runs


class Handler(BaseHTTPRequestHandler):
    server_version = "TTBLauncher/1.0"

    def log_message(self, fmt, *args):
        """Quieter console: the page polls /api/run/<id> every 1.5s and that would
        drown out everything else. send_error() also logs here with an int as the
        first argument, so the line is built first and filtered as text."""
        try:
            line = fmt % args
        except (TypeError, ValueError):
            line = fmt
        if "/api/run/" not in line:
            sys.stderr.write("  %s\n" % line)

    # ------------------------------------------------------------------ helpers
    def send_json(self, payload, code=200):
        body = json.dumps(payload).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def send_file(self, path):
        if not os.path.isfile(path):
            self.send_error(404, "not found")
            return
        kind = mimetypes.guess_type(path)[0] or "application/octet-stream"
        with open(path, "rb") as stream:
            body = stream.read()
        self.send_response(200)
        self.send_header("Content-Type", kind)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def safe_join(self, base, relative):
        """Join and refuse anything that escapes base - the server is local, but a
        path such as ../../etc/passwd must still not be served."""
        target = os.path.normpath(os.path.join(base, relative.lstrip("/")))
        if not (target == base or target.startswith(base + os.sep)):
            return None
        return target

    # ------------------------------------------------------------------ GET
    def do_GET(self):
        path = urlparse(self.path).path
        if path in ("/", "/index.html"):
            self.send_file(os.path.join(WEB_DIR, "index.html"))
        elif path == "/api/state":
            self.send_json({"suites": SUITES, "runs": recent_runs(),
                            "project": ROOT, "windows": IS_WINDOWS})
        elif path.startswith("/api/run/"):
            run_id = path[len("/api/run/"):]
            if not RUN_ID_RE.match(run_id):
                self.send_json({"error": "bad run id"}, 400)
                return
            state = read_run(run_id)
            self.send_json(state or {"error": "unknown run"}, 200 if state else 404)
        elif path.startswith("/results/"):
            target = self.safe_join(RUN_ROOT, path[len("/results/"):])
            if target is None:
                self.send_error(403, "forbidden")
            else:
                self.send_file(target)
        elif path.startswith("/web/"):
            target = self.safe_join(WEB_DIR, path[len("/web/"):])
            if target is None:
                self.send_error(403, "forbidden")
            else:
                self.send_file(target)
        else:
            self.send_error(404, "not found")

    # ------------------------------------------------------------------ POST
    def do_POST(self):
        path = urlparse(self.path).path
        length = int(self.headers.get("Content-Length") or 0)
        try:
            payload = json.loads(self.rfile.read(length) or b"{}")
        except ValueError:
            self.send_json({"error": "body is not JSON"}, 400)
            return

        if path == "/api/run":
            suite = payload.get("suite", "ALL_BUT_MOBILE")
            if suite not in {s["key"] for s in SUITES}:
                self.send_json({"error": f"unknown suite {suite}"}, 400)
                return
            cfg = {
                "suite": suite,
                "env": payload.get("env", "PUBLIC"),
                "browser": payload.get("browser", "chromium"),
                "headless": bool(payload.get("headless", True)),
                "browser_executable": payload.get("browser_executable", ""),
                "tags": [t for t in payload.get("tags", []) if re.match(r"^[\w.-]+$", t)],
            }
            run_id = start_run(cfg)
            self.send_json({"run_id": run_id})
        elif path == "/api/check":
            script = os.path.join(HERE, "setup_check.py")
            done = subprocess.run([sys.executable, script], cwd=ROOT, capture_output=True,
                                  text=True, timeout=180)
            self.send_json({"output": done.stdout + done.stderr, "ok": done.returncode == 0})
        else:
            self.send_error(404, "not found")


def main():
    os.makedirs(RUN_ROOT, exist_ok=True)
    url = f"http://127.0.0.1:{PORT}/"
    try:
        server = ThreadingHTTPServer(("127.0.0.1", PORT), Handler)
    except OSError as error:
        print(f"[launcher] cannot listen on {PORT}: {error}")
        print("[launcher] another launcher may already be running - open", url)
        return 1
    print("=" * 60)
    print(" CI_TTB_ASSIGNMENT LAUNCHER")
    print(f" Page    : {url}")
    print(f" Project : {ROOT}")
    print(" Keep this window open. Ctrl+C stops the launcher.")
    print("=" * 60, flush=True)
    if not os.environ.get("RL_NO_BROWSER"):
        threading.Timer(1.0, lambda: webbrowser.open(url)).start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[launcher] stopped")
    return 0


if __name__ == "__main__":
    sys.exit(main())
