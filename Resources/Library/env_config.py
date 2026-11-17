"""Variables file: turns -v ENV:<name> into the URLs each suite uses.

Same role as env_config.py in CI_API_RL_SYSTEM. Robot loads it through
Import/Library_import.robot, so ${URL_MAP}, ${WEB_LOGIN_URL} and ${REQRES_API_KEY}
are available in every suite.
"""
import os
import re
import sys

DEFAULT_ENV = "PUBLIC"

ENVS = {
    # the only environment the assignment targets: the public demo sites
    "PUBLIC": {
        "WEB_BASE": "https://the-internet.herokuapp.com",
        "API_BASE": "https://reqres.in",
    },
}


def _env_from_argv():
    """Read ENV from the robot command line (-v ENV:PUBLIC / --variable ENV:PUBLIC)."""
    argv = sys.argv
    for index, arg in enumerate(argv):
        value = None
        if arg in ("-v", "--variable") and index + 1 < len(argv):
            value = argv[index + 1]
        elif arg.startswith("--variable="):
            value = arg.split("=", 1)[1]
        elif arg.startswith("-v") and len(arg) > 2:
            value = arg[2:]
        if value:
            match = re.match(r"ENV:(\S+)", value)
            if match:
                return match.group(1)
    return None


def get_variables(env=None):
    resolved = str(env or _env_from_argv() or os.environ.get("ROBOT_ENV") or DEFAULT_ENV).strip().upper()
    if resolved not in ENVS:
        raise ValueError("ENV must be one of %s (got: %r)" % (", ".join(ENVS), resolved))
    cfg = ENVS[resolved]
    sys.stderr.write("[env_config] ENV=%s WEB_BASE=%s API_BASE=%s\n"
                     % (resolved, cfg["WEB_BASE"], cfg["API_BASE"]))
    return {
        "ENV": resolved,
        "URL_MAP": {"WEB": cfg["WEB_BASE"], "API": cfg["API_BASE"]},
        "WEB_BASE": cfg["WEB_BASE"],
        "API_BASE": cfg["API_BASE"],
        "WEB_LOGIN_URL": cfg["WEB_BASE"] + "/login",
        # reqres.in rejects anonymous calls since 2025; the free key is public and
        # is NOT a secret, but it can still be overridden from credentials.env
        "REQRES_API_KEY": os.environ.get("REQRES_API_KEY", "reqres-free-v1"),
    }
