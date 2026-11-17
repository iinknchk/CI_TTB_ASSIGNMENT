"""Small helpers for reading API responses - same role as in CI_API_RL_SYSTEM."""
import json

from robot.api.deco import keyword


@keyword("Parse Json Field")
def parse_json_field(text, *path):
    """Walk ``path`` through a JSON string and return the value, '' when absent.

    | ${id}= | Parse Json Field | ${res.text} | data | id |
    """
    try:
        node = json.loads(text)
    except (TypeError, ValueError):
        return ""
    if isinstance(node, str):
        node = json.loads(node)
    for step in path:
        if isinstance(node, list):
            node = node[int(step)]
        elif isinstance(node, dict):
            if step not in node:
                return ""
            node = node[step]
        else:
            return ""
    return node


@keyword("Response Body Should Be Empty Json")
def response_body_should_be_empty_json(text):
    """Pass only when the body is an empty JSON object - reqres 404 returns '{}'."""
    raw = (text or "").strip()
    if raw in ("{}", ""):
        return
    try:
        parsed = json.loads(raw)
    except ValueError:
        raise AssertionError("response body is not JSON: %r" % raw[:200])
    if parsed not in ({}, None):
        raise AssertionError("expected an empty body '{}' but got: %r" % raw[:200])
