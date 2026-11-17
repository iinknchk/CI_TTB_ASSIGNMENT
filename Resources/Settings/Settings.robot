*** Variables ***
# ---------------------------------------------------------------- paths
${ROOT}                     ${CURDIR}/../..
${PROJECT_ROOT}             ${ROOT}
${UPLOAD_DIR}               ${ROOT}/Upload_file
${EXCEL_DIR}                ${ROOT}/Excel_sync_robot_files
${RESULT_DIR}               ${ROOT}/Results
${API_BODY_DIR}             ${ROOT}/Resources/Settings/Api_body

# ---------------------------------------------------------------- timeouts
${API_TIMEOUT}              30
${BROWSER_TIMEOUT}          20s
${APPIUM_TIMEOUT}           20

# ---------------------------------------------------------------- Q1 data
@{LIST_A}                   ${1}    ${2}    ${3}    ${5}    ${6}    ${8}    ${9}
@{LIST_B}                   ${3}    ${2}    ${1}    ${5}    ${6}    ${0}
@{EXPECTED_DUPLICATES}      ${1}    ${2}    ${3}    ${5}    ${6}

# ---------------------------------------------------------------- Q2 web login
# ${WEB_LOGIN_URL} comes from Resources/Library/env_config.py (ENV=PUBLIC)
# the assignment prints http://, the site redirects to https:// - we ask for https
# directly so no proxy or corporate gateway has to follow the redirect
${BROWSER}                  chromium
${HEADLESS}                 ${TRUE}
# Leave empty on a normal machine: `rfbrowser init` downloads the browser Playwright
# wants and Browser library finds it by itself. Set it (-v BROWSER_EXECUTABLE:<path>)
# only where chromium is already installed by something else, e.g. a CI image.
${BROWSER_EXECUTABLE}       ${EMPTY}
# --no-sandbox is needed when the suite runs as root inside a container
@{BROWSER_ARGS}             --no-sandbox    --disable-dev-shm-usage
${VALID_USERNAME}           tomsmith
${VALID_PASSWORD}           SuperSecretPassword!
${WRONG_PASSWORD}           Password!
${UNKNOWN_USERNAME}         tomholland
${MSG_LOGIN_SUCCESS}        You logged into a secure area!
${MSG_LOGOUT_SUCCESS}       You logged out of the secure area!
${MSG_BAD_PASSWORD}         Your password is invalid!
${MSG_BAD_USERNAME}         Your username is invalid!

# ---------------------------------------------------------------- Q3 reqres api
# ${API_BASE} / ${REQRES_API_KEY} come from Resources/Library/env_config.py
${USER_PATH}                /api/users
${EXISTING_USER_ID}         12
${MISSING_USER_ID}          1234
${EXP_EMAIL}                rachel.howell@reqres.in
${EXP_FIRST_NAME}           Rachel
${EXP_LAST_NAME}            Howell
${EXP_AVATAR}               https://reqres.in/img/faces/12-image.jpg

# ---------------------------------------------------------------- Q4 mobile (Minimal-Todo)
${APPIUM_SERVER}            http://127.0.0.1:4723
${APP_PACKAGE}              com.avjindersinghsekhon.minimaltodo
${APP_ACTIVITY}             com.avjindersinghsekhon.minimaltodo.Main.MainActivity
${APP_PATH}                 ${UPLOAD_DIR}/Minimal-Todo.apk
${PLATFORM_NAME}            Android
${PLATFORM_VERSION}         13
${DEVICE_NAME}              emulator-5554
${AUTOMATION_NAME}          UiAutomator2

# ---------------------------------------------------------------- Q6 cipher
@{CIPHER_CASES}             VTAOG:2:TRYME    ABC:1:ZAB    ZAB:26:ZAB    HELLO:0:HELLO
