# CI_TTB_ASSIGNMENT

Test automation สำหรับโจทย์ **ttb (Spark) — Test Automation assignment** ทั้ง 6 ข้อ
ใช้ **Python + Robot Framework** ชุดเดียวทั้งโปรเจค

| ข้อ | โจทย์ | ที่อยู่ | เครื่องมือ |
|---|---|---|---|
| 1 | หา duplicate ระหว่าง List A / List B | `Testcase/Q1_Duplicate_Items.robot` | Python |
| 2 | Login the-internet.herokuapp.com | `Testcase/Q2_Web_Login.robot` | **Browser library (Playwright)** |
| 3 | GET API reqres.in | `Testcase/Q3_Api_Reqres.robot` | RequestsLibrary |
| 4 | Mobile: Minimal-Todo | `Testcase/Q4_Mobile_Todo.robot` | **Appium** (AppiumLibrary) |
| 5 | Jenkins pipeline | `Jenkinsfile` | Declarative pipeline |
| 6 | simpleCipher | `Testcase/Q6_Simple_Cipher.robot` | Python |

เอกสารออกแบบ test case อยู่ที่ **[Test_Case_Design.md](Test_Case_Design.md)**

---

## 1. ติดตั้ง (เครื่องใหม่ที่ยังไม่มีอะไรเลย)

### Windows — ทางลัด

```
bat_file\Launcher\Setup.bat
```

ไฟล์เดียวจบ ทำให้ 5 อย่าง:

1. หา Python 3.10+ ถ้าไม่เจอจะติดตั้งจาก `bat_file\Launcher\installer\python-3*.exe` ให้เอง (ไม่ต้องใช้สิทธิ์ admin)
2. `pip install -r Resources\Launcher\requirements.txt` (ถ้ามีโฟลเดอร์ `wheelhouse` จะติดตั้งแบบ offline)
3. `rfbrowser init` — ติดตั้งฝั่ง node ของ Browser library พร้อมดาวน์โหลด chromium
4. ตรวจเครื่องด้วย `setup_check.py`
5. สร้าง shortcut **"TTB Automation Launcher"** บน Desktop

> **เครื่องที่ไม่มีอินเทอร์เน็ตเลย:** ไปที่เครื่องที่มีเน็ตก่อน รัน `bat_file\Launcher\Make_Wheelhouse.bat`
> จะได้โฟลเดอร์ `bat_file\Launcher\wheelhouse` แล้ว copy ทั้งโปรเจคไปเครื่องปลายทาง
> จากนั้น `Setup.bat` จะติดตั้งได้โดยไม่ต้องต่อเน็ต
> (ยกเว้น chromium ของ Playwright ที่ต้อง copy แยก หรือชี้ `BROWSER_EXECUTABLE` ไปที่ chromium ที่มีอยู่แล้ว)

### Linux / macOS

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r Resources/Launcher/requirements.txt
rfbrowser init
python Resources/Launcher/setup_check.py
```

### เพิ่มเติมเฉพาะข้อ 4 (mobile)

```bash
npm install -g appium
appium driver install uiautomator2
```

แล้วต้องมี Android SDK platform-tools (`adb`) + emulator หรือเครื่องจริง และไฟล์ APK:

```bash
git clone https://github.com/avjinder/Minimal-Todo.git
cd Minimal-Todo && ./gradlew assembleDebug
# คัดลอก app/build/outputs/apk/debug/app-debug.apk มาไว้ที่ Upload_file/Minimal-Todo.apk
```

> ⚠️ repo นี้เก่า (2017) ใช้ Gradle 4.6 + compileSdk 23 ต้อง build ด้วย **JDK 8**
> ถ้า build ไม่ผ่านให้อัปเดต `gradle-wrapper.properties` และ `build.gradle` ก่อน

### ตรวจว่าเครื่องพร้อมหรือยัง

```
bat_file\Launcher\Check_Machine.bat
```

```bash
python Resources/Launcher/setup_check.py
```

ตัวอย่างผลลัพธ์:

```
[OK  ] Python - 3.13.18
[OK  ] package robot - every suite
[OK  ] package Browser - Q2 web
[OK  ] rfbrowser node side - installed
[WARN] appium - not on PATH - Q4 mobile cannot run
[OK  ] https://reqres.in - HTTP 200 (Q3 api)
 READY   (WARN = only that one suite is affected)
```

`WARN` = กระทบแค่ suite นั้น, `FAIL` = ต้องแก้ก่อนถึงจะรันได้

---

## 2. วิธีรัน

### 2.1 Launcher (แนะนำ — ไม่ต้องจำคำสั่ง)

```
bat_file\Launcher\Start.bat
```

หรือ `python Resources/Launcher/server.py` → เปิดหน้าเว็บที่ `http://127.0.0.1:8810/`

ในหน้าเว็บ: เลือก suite → ตั้งค่า (ENV / browser / headless / tag) → กด **Run**
ดู console สด ๆ ได้ทันที และมีลิงก์ `report.html` กับ `Test_Summary.html` ให้เมื่อจบ
ปุ่ม **Check machine** รันตรวจเครื่องได้จากหน้าเดียวกัน

ทุกรอบเก็บแยกที่ `Results/Launcher/<yyyymmdd_hhmmss>/`

### 2.2 ไฟล์ .bat (Windows)

| ไฟล์ | รันอะไร |
|---|---|
| `bat_file\TTB_ASSIGNMENT\Run_All.bat` | ทุก suite ยกเว้น Q4 |
| `bat_file\TTB_ASSIGNMENT\Run_Offline.bat` | Q1 + Q6 (ไม่ต้องใช้เน็ต) |
| `bat_file\TTB_ASSIGNMENT\Run_Q1_Duplicate.bat` | ข้อ 1 |
| `bat_file\TTB_ASSIGNMENT\Run_Q2_Web_Login.bat` | ข้อ 2 |
| `bat_file\TTB_ASSIGNMENT\Run_Q3_Api_Reqres.bat` | ข้อ 3 |
| `bat_file\TTB_ASSIGNMENT\Run_Q4_Mobile_Todo.bat` | ข้อ 4 |
| `bat_file\TTB_ASSIGNMENT\Run_Q6_Cipher.bat` | ข้อ 6 |

ทุกไฟล์รับ ENV เป็น argument ตัวแรก (default `PUBLIC`) เช่น `Run_All.bat PUBLIC`
ผลลัพธ์ลง `Results\<ชื่อ>_<hhmmss>\` พร้อมสร้าง `Test_Summary.html` ให้อัตโนมัติ

### 2.3 สั่ง robot ตรง ๆ

```bash
robot -v ENV:PUBLIC -d Results/manual Testcase/
```

```bash
robot -v ENV:PUBLIC --exclude Q4 -d Results/ci Testcase/
```

```bash
robot --include smoke -d Results/smoke Testcase/Q4_Mobile_Todo.robot
```

เปิด browser แบบเห็นหน้าจอ (ไม่ headless):

```bash
robot -v HEADLESS:False -d Results/visible Testcase/Q2_Web_Login.robot
```

ถ้าเครื่องมี chromium อยู่แล้วและไม่อยากให้ Playwright โหลดใหม่:

```bash
robot -v BROWSER_EXECUTABLE:/path/to/chrome -d Results/x Testcase/Q2_Web_Login.robot
```

### Tag ที่ใช้กรองได้

`Q1` `Q2` `Q3` `Q4` `Q6` · `offline` (ไม่ต้องใช้เน็ต) · `smoke` · `positive` `negative` · `crud` `reminder` `persistence` `settings` · `1` `2` `3` (priority)

---

## 3. Jenkins (ข้อ 5)

`Jenkinsfile` ที่ root มี 3 stage ตามโจทย์ (+ stage ติดตั้ง dependency):

1. **Checkout Code From Git**
2. **Install Dependencies**
3. **Run Test Automate**
4. **Send Result To Jenkins** — Robot Framework plugin (กราฟ trend) + JUnit + archive + publishHTML

> **หมายเหตุ:** โจทย์เขียน `stages { }` ซ้ำ 3 บล็อก ซึ่งผิด syntax ของ declarative pipeline
> (`Multiple occurrences of the stages section`) ไฟล์นี้รวมเป็น `stages` เดียวที่มี `stage` 3 ตัวตามเจตนาของโจทย์

ก่อนใช้งานจริง: แก้ `userRemoteConfigs` ให้ชี้ไป git repo ของคุณ และติดตั้ง plugin
**Robot Framework**, **JUnit**, **HTML Publisher** บน Jenkins

Q4 ไม่ถูกรวมใน CI (ต้องมี emulator) — ถ้าต้องการให้เลือก parameter `SUITES = all`

---

## 4. โครงสร้างโปรเจค

```
CI_TTB_ASSIGNMENT\
    bat_file\                       ไฟล์ .bat ทั้งหมด
        TTB_ASSIGNMENT\             ตัวรัน test แยกตามข้อ
        Launcher\                   Setup / Start / Check_Machine / Make_Wheelhouse
            installer\              วาง python-3*.exe สำหรับเครื่อง offline
        load_credentials.bat        โหลด credentials.env เข้า environment
    Excel_sync_robot_files\         ไฟล์ Excel สำหรับ data-driven (ยังไม่ใช้ในชุดนี้)
    Import\
        Library_import.robot        รวม Library + Variables ทั้งหมด
        Path_import.robot           รวม Resource ของ Keyword (ไฟล์เดียวที่ Testcase import)
        Mobile_import.robot         แยกสำหรับ Appium (กัน keyword ชนกับ Browser)
    Keyword\
        Common\                     Api.robot, Utility.robot
        Web\                        Login.robot          (ข้อ 2)
        Api\                        Reqres.robot         (ข้อ 3)
        Mobile\                     Todo.robot           (ข้อ 4)
    Locator\
        Login_locator.robot         CSS selector ของเว็บ
        Todo_locator.robot          resource id ของแอป Android
    Resources\
        Library\                    list_helper.py, simple_cipher.py, env_config.py, response_helper.py
        Settings\                   Settings.robot (ตัวแปรกลาง), credentials.env.example
        Launcher\                   server.py, web\index.html, result_parser.py, setup_check.py
    Results\                        ผลการรัน (อยู่ใน .gitignore)
    Testcase\                       Q1 / Q2 / Q3 / Q4 / Q6
    Upload_file\                    วาง Minimal-Todo.apk ที่นี่
    Current_version_<ddmmyyyy>_<hhmmss>.txt
    Jenkinsfile
    README.md  /  Test_Case_Design.md
```

### หลักการของโครงสร้างนี้

- **Testcase import `Path_import.robot` ไฟล์เดียว** — เพิ่ม library หรือ keyword ใหม่ แก้ที่ `Import/` ที่เดียว
- **ทุก path ใช้ `${CURDIR}/..`** ไม่มี absolute path เลย ย้ายโฟลเดอร์แล้วยังรันได้
- **`${ROOT}` ประกาศที่ `Settings.robot` ที่เดียว** แล้ว derive `${UPLOAD_DIR}`, `${EXCEL_DIR}` ต่อ
- **Locator แยกจาก Keyword** — UI เปลี่ยนแก้ไฟล์เดียว ไม่ต้องแตะ logic
- **Mobile แยก import** — `AppiumLibrary` กับ `Browser` มี keyword ชื่อซ้ำกัน (`Click Element`, `Get Text`) จึงไม่โหลดเข้า suite เดียวกัน

---

## 5. Config และ secret

| ไฟล์ | ใช้ทำอะไร | commit ไหม |
|---|---|---|
| `Resources/Settings/Settings.robot` | ตัวแปรกลาง: URL, test data, timeout, locator ของแอป | ✅ |
| `Resources/Library/env_config.py` | แปลง `-v ENV:PUBLIC` เป็น URL ของแต่ละ environment | ✅ |
| `Resources/Settings/credentials.env.example` | template ของ credential | ✅ |
| `Resources/Settings/credentials.env` | ค่าจริง — โหลดโดย `load_credentials.bat` | ❌ อยู่ใน .gitignore |

โปรเจคนี้ไม่มี secret จริง (username/password ของ the-internet เป็นข้อมูลสาธารณะในโจทย์,
`reqres-free-v1` เป็น public key) แต่วางโครงไว้แบบเดียวกับโปรเจคจริงเพื่อให้ขยายต่อได้ทันที

เพิ่ม environment ใหม่: แก้ `ENVS` ใน `Resources/Library/env_config.py` แล้วเรียกด้วย `-v ENV:<ชื่อ>`

---

## 6. ผลการรันบนเครื่องที่พัฒนา

| Suite | ผล |
|---|---|
| Q1 Duplicate Items | 3/3 PASS |
| Q6 Simple Cipher | 6/6 PASS |
| Q3 Api Reqres | 2/2 PASS |
| Q2 Web Login | 3/3 PASS |
| Q4 Mobile Todo | 12 tests — `--dryrun` ผ่านหมด (ยังไม่ได้รันจริงเพราะไม่มี Android device บนเครื่องที่พัฒนา) |
| **รวม** | **14/14 PASS + 12 dryrun** |

---

## 7. ปัญหาที่เจอบ่อย

| อาการ | สาเหตุ / วิธีแก้ |
|---|---|
| `Executable doesn't exist at .../headless_shell` | ยังไม่ได้ `rfbrowser init` หรือ chromium คนละเวอร์ชัน → รัน `rfbrowser init` หรือใช้ `-v BROWSER_EXECUTABLE:<path ของ chrome>` |
| Q3 ได้ 401 ทุกเคส | reqres.in ไม่ได้รับ header `x-api-key` → ตรวจ `REQRES_API_KEY` ใน `env_config.py` |
| Q2 ต่อเว็บไม่ได้ | เครือข่ายองค์กรบล็อก → ใช้ `https://` (โปรเจคตั้งไว้แล้ว) และเปิด allowlist ของ `the-internet.herokuapp.com` |
| `Keyword with same name defined multiple times` | โหลด AppiumLibrary กับ Browser พร้อมกัน → Q4 ต้อง import `Mobile_import.robot` เท่านั้น |
| Q4 `Could not find a connected Android device` | ยังไม่ได้เปิด emulator หรือ `appium` ไม่ได้รัน → เปิด emulator แล้วสั่ง `appium` ก่อน |
| Launcher เปิดไม่ขึ้น / port ชน | ตั้ง `LAUNCHER_PORT=8900` แล้วรันใหม่ |
| ติดตั้ง `robotframework-appiumlibrary==2.1.0` ไม่ผ่านบน Python 3.12+ | เวอร์ชันเก่าดึง `kitchen` ที่ build ไม่ได้ → ใช้ `3.2.1` ตาม `requirements.txt` |
