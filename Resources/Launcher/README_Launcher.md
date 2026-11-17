# Launcher

หน้าเว็บเล็ก ๆ ที่รันบนเครื่องตัวเอง ไว้กดรัน test โดยไม่ต้องจำคำสั่ง `robot`
ใช้เฉพาะ standard library ของ Python ไม่ต้องลง package เพิ่ม

## เปิดใช้งาน

```
bat_file\Launcher\Start.bat
```

หรือรันตรง ๆ:

```bash
python Resources/Launcher/server.py
```

เปิดที่ `http://127.0.0.1:8810/` และเปิด browser ให้อัตโนมัติ

ตัวแปรที่ตั้งได้:

| ตัวแปร | ความหมาย |
|---|---|
| `LAUNCHER_PORT` | เปลี่ยน port (default 8810) |
| `RL_NO_BROWSER` | ตั้งค่าใด ๆ = ไม่ต้องเปิด browser ให้ |

## หน้าเว็บทำอะไรได้

1. **เลือก suite** — Q1 / Q2 / Q3 / Q4 / Q6, ชุด offline (Q1+Q6), ทุกอย่างยกเว้น Q4, หรือทุกอย่าง
2. **ตั้งค่า** — ENV, browser ของ Q2, headless, และกรอง `--include <tag>`
3. **Run** — ทุกรอบได้โฟลเดอร์ของตัวเองใน `Results/Launcher/<yyyymmdd_hhmmss>/`
4. **ดู console สด** — หน้าเว็บ poll ทุก 1.5 วินาที
5. **Check machine** — รัน `setup_check.py` แล้วแสดงผลในหน้าเดียวกัน
6. **Recent runs** — ลิงก์ `report.html` และ `Test_Summary.html` ของรอบก่อน ๆ

## ไฟล์ในโฟลเดอร์นี้

| ไฟล์ | หน้าที่ |
|---|---|
| `server.py` | HTTP server + API (`/api/state`, `/api/run`, `/api/run/<id>`, `/api/check`) |
| `web/index.html` | หน้าเว็บทั้งหมด (HTML + CSS + JS ในไฟล์เดียว) |
| `run_from_json.py` | อ่าน `input.json` ของรอบนั้นแล้วสั่ง `robot`, เขียน `console.txt` + `result.json` |
| `result_parser.py` | แปลง `output.xml` เป็น `Test_Summary.html` + ตารางใน console |
| `setup_check.py` | ตรวจเครื่อง: Python, package, rfbrowser, appium, adb, apk, network |
| `requirements.txt` | pip package ที่ pin เวอร์ชันแล้ว |

## การรันบน Windows กับ Linux ต่างกันอย่างไร

- **Windows** — หน้าเว็บสั่ง `bat_file\Launcher\Run_Batch.bat <run_id>` เปิดหน้าต่าง console
  ใหม่ 1 หน้าต่างต่อ 1 รอบ (ปิดหน้าต่าง = หยุดรอบนั้น)
- **Linux / macOS** — เรียก `run_from_json.py` ตรง ๆ เป็น background process, log ไปที่
  `Results/Launcher/<run_id>/runner.log`

## ความปลอดภัย

- bind เฉพาะ `127.0.0.1` ไม่เปิดออกนอกเครื่อง
- `/results/` และ `/web/` ผ่าน `safe_join()` — path ที่พยายามออกนอกโฟลเดอร์ได้ `403`
- `run_id` ต้องตรง pattern `yyyymmdd_hhmmss` และ tag ต้องเป็น `[\w.-]+` เท่านั้น
- ไม่มี credential ใด ๆ อยู่ในหน้าเว็บหรือใน API
