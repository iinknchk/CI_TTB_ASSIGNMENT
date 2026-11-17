"""Started by bat_file/Launcher/Run_Batch.bat <run_id> (and by server.py on non-Windows).

Reads Results/Launcher/<run_id>/input.json - written by the launcher web page - and
runs robot with those settings, so the bat file never has to deal with quoting.
Writes console.txt, and result.json when the run ends.
"""
import json
import os
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))

# suite key -> (robot target, extra robot options)
SUITES = {
    "Q1": ("Testcase/Q1_Duplicate_Items.robot", []),
    "Q2": ("Testcase/Q2_Web_Login.robot", []),
    "Q3": ("Testcase/Q3_Api_Reqres.robot", []),
    "Q4": ("Testcase/Q4_Mobile_Todo.robot", []),
    "Q6": ("Testcase/Q6_Simple_Cipher.robot", []),
    "OFFLINE": ("Testcase", ["--include", "offline"]),
    "ALL_BUT_MOBILE": ("Testcase", ["--exclude", "Q4"]),
    "ALL": ("Testcase", []),
}


def build_command(cfg, run_dir):
    suite = cfg.get("suite", "ALL_BUT_MOBILE")
    if suite not in SUITES:
        raise SystemExit(f"unknown suite {suite!r} - pick one of {', '.join(SUITES)}")
    target, extra = SUITES[suite]
    command = [sys.executable, "-m", "robot",
               "-v", f"ENV:{cfg.get('env', 'PUBLIC')}",
               "-d", run_dir,
               "-N", f"{suite} {cfg.get('run_id', '')}".strip(),
               "--xunit", "xunit.xml"]
    if cfg.get("browser"):
        command += ["-v", f"BROWSER:{cfg['browser']}"]
    if cfg.get("headless") is not None:
        command += ["-v", f"HEADLESS:{'True' if cfg['headless'] else 'False'}"]
    if cfg.get("browser_executable"):
        command += ["-v", f"BROWSER_EXECUTABLE:{cfg['browser_executable']}"]
    if cfg.get("tags"):
        for tag in cfg["tags"]:
            command += ["--include", tag]
    command += extra
    command.append(os.path.join(ROOT, target))
    return command


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: run_from_json.py <run_id>")
    run_id = os.path.basename(sys.argv[1])
    run_dir = os.path.join(ROOT, "Results", "Launcher", run_id)
    with open(os.path.join(run_dir, "input.json"), encoding="utf-8") as stream:
        cfg = json.load(stream)
    cfg["run_id"] = run_id

    # Q4 needs a booted device and a running Appium before robot starts
    if cfg.get("suite") in ("Q4", "ALL"):
        sys.path.insert(0, os.path.join(ROOT, "Resources", "Library"))
        import android_tools
        print("[launcher] Q4 selected - making sure the emulator and appium are up")
        if android_tools.ensure_emulator(cfg.get("avd", "ttb_test")) or android_tools.ensure_appium():
            print("[launcher] the Android stack is not ready - see the lines above")
            with open(os.path.join(run_dir, "result.json"), "w", encoding="utf-8") as stream:
                json.dump({"run_id": run_id, "return_code": 1,
                           "error": "android stack not ready"}, stream, indent=2)
            return 1

    command = build_command(cfg, run_dir)
    print("=" * 60)
    print(f" CI_TTB_ASSIGNMENT LAUNCHER   run {run_id}")
    print(f" Suite : {cfg.get('suite')}    ENV {cfg.get('env', 'PUBLIC')}")
    print(f" Robot : {' '.join(command[2:])}")
    print(" Closing this window stops the run.")
    print("=" * 60, flush=True)

    started = time.time()
    console_path = os.path.join(run_dir, "console.txt")
    with open(console_path, "w", encoding="utf-8") as console:
        process = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE,
                                   stderr=subprocess.STDOUT, text=True, bufsize=1,
                                   errors="replace")
        for line in process.stdout:
            sys.stdout.write(line)
            sys.stdout.flush()
            console.write(line)
            console.flush()
        code = process.wait()

    output_xml = os.path.join(run_dir, "output.xml")
    summary = {"run_id": run_id, "return_code": code,
               "seconds": round(time.time() - started, 1),
               "finished_at": time.strftime("%Y-%m-%d %H:%M:%S")}
    if os.path.isfile(output_xml):
        sys.path.insert(0, HERE)
        import result_parser  # local module, imported after sys.path is set
        rows, totals = result_parser.collect(output_xml)
        summary["totals"] = totals
        summary["tests"] = rows
        with open(os.path.join(run_dir, "Test_Summary.html"), "w", encoding="utf-8") as stream:
            stream.write(result_parser.to_html(rows, totals, output_xml))
    with open(os.path.join(run_dir, "result.json"), "w", encoding="utf-8") as stream:
        json.dump(summary, stream, indent=2)
    return code


if __name__ == "__main__":
    sys.exit(main())
