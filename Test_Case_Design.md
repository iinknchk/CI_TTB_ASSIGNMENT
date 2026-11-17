# Test Case Design

เอกสารออกแบบ test coverage ของ assignment ทั้ง 6 ข้อ
ข้อ 4 (mobile) เป็นข้อที่โจทย์สั่งให้ "design test coverage" โดยตรง จึงลงรายละเอียดมากที่สุด

---

## ข้อ 1 — Duplicate items (`Testcase/Q1_Duplicate_Items.robot`)

| # | Test case | สิ่งที่พิสูจน์ | Expected |
|---|---|---|---|
| 1 | Find Duplicate Items From List A And List B | โจทย์หลัก + input list ต้องไม่ถูกแก้ | `[1,2,3,5,6]`, A และ B เท่าเดิม |
| 2 | Nested Loop Version Gives The Same Answer | วิธี set O(n+m) ให้ผลเท่ากับ nested loop O(n×m) | ผลตรงกัน |
| 3 | Duplicate Items Edge Cases | ค่าซ้ำใส่ครั้งเดียว, list ว่าง, ไม่มีค่าร่วม, string | ตามตารางในเทสต์ |

**เหตุผลที่ใช้ set:** โจทย์ไม่ได้บอกขนาด list ถ้าเจอ list ใหญ่ nested loop จะช้าแบบกำลังสอง
เลยทำทั้งสองวิธีแล้วเทียบกันในเทสต์ เพื่อพิสูจน์ว่าวิธีเร็วให้ผลถูกต้อง

---

## ข้อ 2 — Web login (`Testcase/Q2_Web_Login.robot`)

ตรงตามตารางในโจทย์ 3 เคส ไม่เพิ่ม ไม่ลด

| # | Test case | Steps | Expected |
|---|---|---|---|
| 1 | Login Success | เปิดหน้า → `tomsmith`/`SuperSecretPassword!` → กด Logout | หน้า login แสดง → `You logged into a secure area!` → กลับหน้า login พร้อม `You logged out of the secure area!` |
| 2 | Login Failed - Password Incorrect | เปิดหน้า → `tomsmith`/`Password!` | หน้า login แสดง → `Your password is invalid!` |
| 3 | Login Failed - Username Not Found | เปิดหน้า → `tomholland`/`Password!` | หน้า login แสดง → `Your username is invalid!` |

**สิ่งที่ตรวจเพิ่มจากที่โจทย์เขียน** (เพื่อให้เทสต์จับ bug ได้จริง ไม่ใช่แค่หา text เจอ):

- `Login Page Should Be Shown` ตรวจว่า form, username, password, submit มองเห็นได้จริง และ heading = `Login Page` ไม่ใช่แค่ URL
- `Input Credentials` อ่านค่ากลับจาก `value` property ยืนยันว่าพิมพ์ลงไปจริง
- เคส success ตรวจ `Secure Area Should Be Shown` (URL `/secure` + ปุ่ม Logout) ก่อนกด Logout
- เคส fail ตรวจ `Should Still Be On Login Page` — login ที่ล้มเหลวต้องไม่พาไปหน้าอื่น

---

## ข้อ 3 — REST API (`Testcase/Q3_Api_Reqres.robot`)

| # | Test case | Request | Expected |
|---|---|---|---|
| 1 | Get User Profile Success | `GET /api/users/12` | 200 + `id=12`, `email=rachel.howell@reqres.in`, `first_name=Rachel`, `last_name=Howell`, `avatar=https://reqres.in/img/faces/12-image.jpg` |
| 2 | Get User Profile But User Not Found | `GET /api/users/1234` | 404 + body `{}` |

**หมายเหตุสำคัญ:** reqres.in บังคับ header `x-api-key` ตั้งแต่ปี 2025 ถ้าไม่ส่งจะได้ 401
โปรเจคใส่ค่า default `reqres-free-v1` ไว้ใน `env_config.py` (เป็น key สาธารณะ ไม่ใช่ความลับ)
ถ้าไม่ handle เรื่องนี้ เทสต์จะ fail ทั้งที่ API ปกติดี

ตรวจทีละ field แยกกัน เพื่อให้ตอน fail บอกได้ว่า field ไหนผิด แทนที่จะเทียบ JSON ทั้งก้อนแล้วอ่าน diff ไม่ออก

---

## ข้อ 4 — Mobile: Minimal-Todo (`Testcase/Q4_Mobile_Todo.robot`)

**App under test:** https://github.com/avjinder/Minimal-Todo
**appPackage:** `com.avjindersinghsekhon.minimaltodo`
**appActivity:** `com.example.avjindersinghsekhon.minimaltodo.Main.MainActivity`

> ⚠️ `applicationId` (จาก `build.gradle`) กับ java package (จาก `AndroidManifest.xml`) **ไม่เหมือนกัน**
> resource id ของ Appium ต้องใช้ `applicationId` เป็น prefix แต่ appActivity ต้องใช้ java package เต็ม

### Feature ที่แอปมี (อ่านจาก source)

| Feature | หลักฐานใน source |
|---|---|
| ดู todo list / empty state | `fragment_main.xml` → `toDoRecyclerView`, `toDoEmptyView` |
| เพิ่ม todo (title + description) | `fragment_add_to_do.xml` → `userToDoEditText`, `userToDoDescription` |
| บังคับกรอก title | `strings.xml` → `todo_error` = "Please enter a Todo" |
| แก้ไข todo | กดที่ row → เข้าหน้า add เดิม |
| ลบ todo = **swipe** (ไม่มีปุ่มลบ) | `ItemTouchHelperClass.java` → `swipeFlags = START \| END` |
| Undo การลบ | `MainFragment.java:465` → Snackbar `"Deleted " + title` + action `"UNDO"` |
| ตั้ง reminder (วัน/เวลา) | `toDoHasDateSwitchCompat`, `newTodoDateEditText`, `newTodoTimeEditText` |
| เรียงลำดับ (drag) | `listItemReorderImageView` |
| Night mode | `preferences_layout.xml` → CheckBoxPreference "Night Mode" |
| About | `menu_main.xml` → `aboutMeMenuItem` |
| เก็บข้อมูลลงไฟล์ local | todo ยังอยู่หลังปิดแอป |

### Test coverage ที่ออกแบบ (12 เคส)

| # | Test case | Priority | ครอบคลุม | Expected |
|---|---|---|---|---|
| TC01 | Empty State Is Shown On First Launch | 1 smoke | empty state | เห็นข้อความ "You don't have any todos" |
| TC02 | Add Todo With Title Only | 1 smoke | create | todo อยู่ใน list, empty view หาย |
| TC03 | Add Todo With Title And Description | 1 | create | todo อยู่ใน list |
| TC04 | Add Todo Is Rejected When The Title Is Empty | 1 negative | validation | ยังอยู่หน้า add, ไม่มี todo ถูกสร้าง |
| TC05 | Add Several Todos | 2 | create หลายรายการ | ทั้งสองรายการอยู่ครบ |
| TC06 | Edit The Title Of An Existing Todo | 2 | update | ชื่อใหม่อยู่ ชื่อเก่าหาย |
| TC07 | Delete A Todo By Swiping It Away | 2 | delete | todo หายจาก list |
| TC08 | Undo Brings A Deleted Todo Back | 2 | undo | Snackbar "Deleted X" → กด UNDO → todo กลับมา |
| TC09 | Deleting The Last Todo Shows The Empty State Again | 2 | delete + empty state | กลับไปหน้า empty |
| TC10 | Set A Reminder While Adding A Todo | 2 | reminder | เปิด switch แล้วมีช่องวัน/เวลา, row มีเวลาแสดง |
| TC11 | Todos Survive An App Restart | 2 persistence | storage | ปิด-เปิดแอปแล้ว todo ยังอยู่ |
| TC12 | Night Mode Can Be Turned On From Settings | 3 settings | theme | summary เปลี่ยนจาก "Night mode is off" เป็น "on" |

รันเฉพาะชุด smoke: `robot --include smoke Testcase/Q4_Mobile_Todo.robot`

### หลักการที่ใช้ออกแบบ

1. **ครอบ CRUD ให้ครบ** — create (TC02,03,05), read (TC01,02), update (TC06), delete (TC07,09)
2. **มี negative case** — TC04 บังคับ validation ไม่ใช่เทสต์แต่ทาง happy path
3. **เทสต์ state ที่ user เห็นจริง** — empty state มี 2 เคส (ตอนเริ่ม TC01 และตอนลบหมด TC09) เพราะเป็นคนละ code path
4. **Isolation** — ทุกเคสเริ่มจาก `noReset=False` คือล้าง app data ใหม่ทุกครั้ง เคสจึงไม่ขึ้นต่อกันและสั่งรันเคสเดียวได้
5. **TC11 เป็นข้อยกเว้น** — ใช้ `Restart Todo App` ที่ `noReset=True` เพราะถ้าล้าง data ก็ทดสอบ persistence ไม่ได้
6. **ยึด locator จาก source จริง** — ไม่เดา id, ไม่ใช้ xpath แบบ index (`//android.widget.TextView[3]`) ที่พังทันทีที่ layout เปลี่ยน

### สิ่งที่ไม่ได้ทำ และเหตุผล

| ไม่ได้ทดสอบ | เหตุผล |
|---|---|
| การยิง notification ตามเวลา reminder | ต้องรอเวลาจริงหรือแก้ system clock ของ device — ไม่เหมาะกับ CI, ควรแยกเป็น manual test |
| drag-and-drop เรียงลำดับ | Appium ทำได้แต่เปราะมากกับ RecyclerView เวอร์ชันเก่า (support lib 23) อาจ flaky |
| หน้า About | เป็น static text ไม่มี business logic |
| Google Analytics | ต้องมี backend จริง อยู่นอกขอบเขต assignment |

---

## ข้อ 6 — simpleCipher (`Testcase/Q6_Simple_Cipher.robot`)

| # | Test case | Input | Expected |
|---|---|---|---|
| 1 | Decrypt The Example From The Assignment | `VTAOG`, k=2 | `TRYME` |
| 2 | Decrypt Wraps Around The Wheel | `ABC`, k=1 | `ZAB` (A ต้องวนไป Z) |
| 3 | Decrypt With K Of Zero Returns The Input | `HELLO`, k=0 | `HELLO` |
| 4 | Decrypt With A Full Turn Of The Wheel | `ZAB` k=26 / `VTAOG` k=28 | `ZAB` / `TRYME` |
| 5 | Decrypt The Whole Alphabet | `A..Z`, k=1 | `ZABC...Y` |
| 6 | Decrypt Table Driven Cases | จาก `@{CIPHER_CASES}` ใน Settings.robot | ตามตาราง |

จุดที่มักพลาด: **การวน** (A ลบ 1 ต้องได้ Z ไม่ใช่ `@`) และ **k ใหญ่กว่า 26** จึงมีเทสต์แยกทั้งสองเรื่อง
