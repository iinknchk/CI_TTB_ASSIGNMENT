*** Settings ***
Documentation       Question 2 - login tests for https://the-internet.herokuapp.com/login
...                 Browser library (Playwright) drives the browser.
...                 Account from the assignment: tomsmith / SuperSecretPassword!

Resource            ${CURDIR}/../Import/Path_import.robot

Suite Setup         Log Step Result    SUITE    target=${WEB_LOGIN_URL} browser=${BROWSER} headless=${HEADLESS}
Test Setup          Open Login Page
Test Teardown       Close Login Page

Force Tags          Q2    web    login


*** Test Cases ***
Login Success
    [Documentation]    Objective: verify that users can login successfully when they
    ...                input a correct username and password.
    ...
    ...                Steps  : 1. open the login page
    ...                         2. input 'tomsmith' / 'SuperSecretPassword!'
    ...                         3. click the 'Logout' button
    ...                Expected: 1. login page is shown
    ...                          2. 'You logged into a secure area!' is shown
    ...                          3. back on the login page with
    ...                             'You logged out of the secure area!'
    [Tags]    1    positive
    # expected result 1
    Login Page Should Be Shown
    # step 2 -> expected result 2
    Login With    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Flash Message Should Contain    ${MSG_LOGIN_SUCCESS}
    Secure Area Should Be Shown
    # step 3 -> expected result 3
    Click Logout
    Flash Message Should Contain    ${MSG_LOGOUT_SUCCESS}
    Login Page Should Be Shown

Login Failed - Password Incorrect
    [Documentation]    Objective: verify that users cannot login when they input a
    ...                correct username but the wrong password.
    ...
    ...                Steps  : 1. open the login page
    ...                         2. input 'tomsmith' / 'Password!'
    ...                Expected: 1. login page is shown
    ...                          2. login fails with 'Your password is invalid!'
    [Tags]    1    negative
    Login Page Should Be Shown
    Login With    ${VALID_USERNAME}    ${WRONG_PASSWORD}
    Flash Message Should Contain    ${MSG_BAD_PASSWORD}
    Should Still Be On Login Page

Login Failed - Username Not Found
    [Documentation]    Objective: verify that users cannot login when they input a
    ...                username that does not exist.
    ...
    ...                Steps  : 1. open the login page
    ...                         2. input 'tomholland' / 'Password!'
    ...                Expected: 1. login page is shown
    ...                          2. login fails with 'Your username is invalid!'
    [Tags]    1    negative
    Login Page Should Be Shown
    Login With    ${UNKNOWN_USERNAME}    ${WRONG_PASSWORD}
    Flash Message Should Contain    ${MSG_BAD_USERNAME}
    Should Still Be On Login Page
