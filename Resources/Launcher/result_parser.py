"""Turn a Robot output.xml into a one-page HTML summary + a console table.

Called at the end of every bat runner and by the launcher page.
Usage: result_parser.py <path to output.xml>
Writes Test_Summary.html next to the output.xml and prints the same table.
"""
import html
import os
import sys
import xml.etree.ElementTree as ET

STATUS_COLOR = {"PASS": "#1a7f37", "FAIL": "#c3272b", "SKIP": "#9a6700"}


def collect(output_xml):
    """Return (rows, totals). One row per test case, in the order they ran."""
    tree = ET.parse(output_xml)
    rows = []
    for suite in tree.iter("suite"):
        suite_name = suite.get("name")
        for test in suite.findall("test"):
            status = test.find("status")
            rows.append({
                "suite": suite_name,
                "name": test.get("name"),
                "status": status.get("status", "") if status is not None else "",
                "message": (status.text or "").strip() if status is not None else "",
                "start": status.get("start", "") if status is not None else "",
                "elapsed": status.get("elapsed", "") if status is not None else "",
                "tags": [tag.text for tag in test.findall("tag") if tag.text],
            })
    totals = {"PASS": 0, "FAIL": 0, "SKIP": 0}
    for row in rows:
        totals[row["status"]] = totals.get(row["status"], 0) + 1
    return rows, totals


def to_html(rows, totals, output_xml):
    cards = "".join(
        f'<div class="card {key.lower()}"><b>{totals.get(key, 0)}</b><span>{key}</span></div>'
        for key in ("PASS", "FAIL", "SKIP")
    )
    body = []
    for row in rows:
        colour = STATUS_COLOR.get(row["status"], "#555")
        seconds = f'{float(row["elapsed"]):.2f}s' if row["elapsed"] else ""
        body.append(
            "<tr>"
            f'<td>{html.escape(row["suite"])}</td>'
            f'<td>{html.escape(row["name"])}</td>'
            f'<td><span style="color:{colour};font-weight:600">{row["status"]}</span></td>'
            f'<td class="num">{seconds}</td>'
            f'<td class="tags">{html.escape(", ".join(row["tags"]))}</td>'
            f'<td class="msg">{html.escape(row["message"][:400])}</td>'
            "</tr>"
        )
    return f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Test Summary</title>
<style>
  :root {{ color-scheme: light dark; --bg:#fff; --fg:#1a1a1a; --line:#e3e3e3; --soft:#666; }}
  @media (prefers-color-scheme: dark) {{
    :root {{ --bg:#15171a; --fg:#e8e8e8; --line:#2b2f35; --soft:#9aa0a6; }}
  }}
  body {{ margin:0; padding:24px 16px; background:var(--bg); color:var(--fg);
         font:14px/1.5 -apple-system,Segoe UI,Roboto,sans-serif; }}
  .wrap {{ max-width:1100px; margin:0 auto; }}
  h1 {{ font-size:20px; margin:0 0 4px; }}
  p.src {{ color:var(--soft); margin:0 0 20px; font-size:12px; word-break:break-all; }}
  .cards {{ display:flex; gap:12px; flex-wrap:wrap; margin-bottom:20px; }}
  .card {{ flex:1 1 120px; border:1px solid var(--line); border-radius:10px;
           padding:14px; text-align:center; }}
  .card b {{ display:block; font-size:26px; }}
  .card span {{ color:var(--soft); font-size:12px; letter-spacing:.06em; }}
  .card.pass b {{ color:#1a7f37; }} .card.fail b {{ color:#c3272b; }}
  .card.skip b {{ color:#9a6700; }}
  table {{ width:100%; border-collapse:collapse; }}
  th, td {{ text-align:left; padding:8px 10px; border-bottom:1px solid var(--line);
            vertical-align:top; }}
  th {{ font-size:12px; text-transform:uppercase; letter-spacing:.05em; color:var(--soft); }}
  td.num {{ text-align:right; white-space:nowrap; }}
  td.tags, td.msg {{ color:var(--soft); font-size:12px; }}
</style></head>
<body><div class="wrap">
<h1>CI_TTB_ASSIGNMENT &mdash; test summary</h1>
<p class="src">{html.escape(output_xml)}</p>
<div class="cards">{cards}</div>
<table><thead><tr><th>Suite</th><th>Test case</th><th>Status</th><th>Time</th>
<th>Tags</th><th>Message</th></tr></thead><tbody>{''.join(body)}</tbody></table>
</div></body></html>"""


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: result_parser.py <output.xml>")
    output_xml = os.path.abspath(sys.argv[1])
    if not os.path.isfile(output_xml):
        print(f"[result_parser] not found: {output_xml}")
        return 1
    rows, totals = collect(output_xml)

    width = max([len(r["name"]) for r in rows] + [20])
    print("-" * (width + 22))
    for row in rows:
        print(f' {row["status"]:4}  {row["name"]:<{width}}  {row["tags"] and ",".join(row["tags"]) or ""}')
    print("-" * (width + 22))
    print(f' PASS {totals.get("PASS", 0)}   FAIL {totals.get("FAIL", 0)}   SKIP {totals.get("SKIP", 0)}')

    target = os.path.join(os.path.dirname(output_xml), "Test_Summary.html")
    with open(target, "w", encoding="utf-8") as stream:
        stream.write(to_html(rows, totals, output_xml))
    print(f" [REPORT] {target}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
