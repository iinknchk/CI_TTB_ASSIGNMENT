*** Settings ***
Documentation       Question 2 - business keywords for the-internet login page.
...                 Uses Browser library (Playwright), not SeleniumLibrary.

Resource            ${CURDIR}/../../Import/Library_import.robot
Resource            ${CURDIR}/../../Locator/Login_locator.robot


*** Keywords ***
Open Login Page
    [Documentation]    Step 1 of every test case: open the browser and go to the login page.
    Set Browser Timeout    ${BROWSER_TIMEOUT}
    IF    '${BROWSER_EXECUTABLE}' == '${EMPTY}'
        New Browser    browser=${BROWSER}    headless=${HEADLESS}    args=${BROWSER_ARGS}
    ELSE
        New Browser    browser=${BROWSER}    headless=${HEADLESS}    args=${BROWSER_ARGS}
        ...    executablePath=${BROWSER_EXECUTABLE}
    END
    New Context    viewport={'width': 1366, 'height': 768}
    New Page    ${WEB_LOGIN_URL}
    Log Step Result    OPEN    ${WEB_LOGIN_URL}

Close Login Page
    Run Keyword And Ignore Error    Take Screenshot    fullPage=${TRUE}
    Close Browser    ALL

Login Page Should Be Shown
    [Documentation]    Expected result 1 of every test case.
    Get Url    contains       /login
    Wait For Elements State    ${LOGIN_FORM}              visible    timeout=${BROWSER_TIMEOUT}
    Wait For Elements State    ${LOGIN_USERNAME_INPUT}    visible
    Wait For Elements State    ${LOGIN_PASSWORD_INPUT}    visible
    Wait For Elements State    ${LOGIN_SUBMIT_BUTTON}     visible
    Get Text    ${LOGIN_PAGE_HEADING}    ==    Login Page
    Log Step Result    LOGIN PAGE    form, username, password and submit are all visible

Input Credentials
    [Arguments]    ${username}    ${password}
    Fill Text    ${LOGIN_USERNAME_INPUT}    ${username}
    Fill Text    ${LOGIN_PASSWORD_INPUT}    ${password}
    # an input holds its content in the value property, not in its text
    Get Property    ${LOGIN_USERNAME_INPUT}    value    ==    ${username}
    Get Property    ${LOGIN_PASSWORD_INPUT}    value    ==    ${password}
    Log Step Result    INPUT    username='${username}' password=***

Submit Login
    Click    ${LOGIN_SUBMIT_BUTTON}
    Wait For Elements State    ${FLASH_MESSAGE}    visible    timeout=${BROWSER_TIMEOUT}

Login With
    [Arguments]    ${username}    ${password}
    Input Credentials    ${username}    ${password}
    Submit Login

Flash Message Should Contain
    [Documentation]    The flash div also holds the close "x", so it is checked with
    ...                `contains` rather than an exact match.
    [Arguments]    ${expected}
    ${actual}=    Get Text    ${FLASH_MESSAGE}
    Should Contain    ${actual}    ${expected}
    ...    msg=flash message mismatch: expected to contain '${expected}' but the page shows '${actual}'
    Log Step Result    FLASH    ${expected}

Secure Area Should Be Shown
    Get Url    contains       /secure
    Get Text    ${SECURE_AREA_HEADING}    ==    Secure Area
    Wait For Elements State    ${LOGOUT_BUTTON}    visible
    Log Step Result    SECURE AREA    logout button is visible

Click Logout
    Click    ${LOGOUT_BUTTON}
    Wait For Elements State    ${FLASH_MESSAGE}    visible    timeout=${BROWSER_TIMEOUT}
    Log Step Result    LOGOUT    clicked

Should Still Be On Login Page
    [Documentation]    A failed login must not leave the user anywhere else.
    Get Url    contains       /login
    Wait For Elements State    ${LOGIN_FORM}    visible
