*** Settings ***
Documentation       Question 4 - business keywords for the Minimal-Todo Android app.
...                 Robot Framework + Appium (AppiumLibrary), as the assignment requires.

Resource            ${CURDIR}/../../Locator/Todo_locator.robot
Resource            ${CURDIR}/../../Resources/Settings/Settings.robot


*** Keywords ***
Open Todo App
    [Documentation]    Starts a fresh install so every suite begins with an empty list.
    ...                `noReset=False` wipes app data between runs, which is what makes
    ...                the empty-state and persistence cases trustworthy.
    [Arguments]    ${no_reset}=${FALSE}
    ${app}=    Set Variable If    ${no_reset}    ${EMPTY}    ${APP_PATH}
    Set Appium Timeout    ${APPIUM_TIMEOUT}
    Open Application    ${APPIUM_SERVER}
    ...    platformName=${PLATFORM_NAME}
    ...    platformVersion=${PLATFORM_VERSION}
    ...    deviceName=${DEVICE_NAME}
    ...    automationName=${AUTOMATION_NAME}
    ...    appPackage=${APP_PACKAGE}
    ...    appActivity=${APP_ACTIVITY}
    ...    app=${app}
    ...    noReset=${no_reset}
    ...    autoGrantPermissions=${TRUE}
    ...    newCommandTimeout=${120}
    Wait Until Page Contains Element    ${TODO_ADD_FAB}    timeout=${APPIUM_TIMEOUT}

Close Todo App
    Run Keyword And Ignore Error    Capture Page Screenshot
    Close Application

Restart Todo App
    [Documentation]    Used by the persistence case: stop the app and start it again
    ...                WITHOUT wiping data.
    Close Application
    Open Todo App    no_reset=${TRUE}

Empty List Should Be Shown
    Wait Until Page Contains Element    ${TODO_EMPTY_VIEW}    timeout=${APPIUM_TIMEOUT}
    Element Should Be Visible    ${TODO_EMPTY_VIEW}
    Element Text Should Be    ${TODO_EMPTY_VIEW}    ${TXT_EMPTY_LIST}

Add Todo
    [Arguments]    ${title}    ${description}=${EMPTY}
    Click Element    ${TODO_ADD_FAB}
    Wait Until Page Contains Element    ${TODO_TITLE_INPUT}    timeout=${APPIUM_TIMEOUT}
    Input Text    ${TODO_TITLE_INPUT}    ${title}
    IF    '${description}' != '${EMPTY}'
        Input Text    ${TODO_DESCRIPTION_INPUT}    ${description}
    END
    Click Element    ${TODO_SAVE_FAB}
    Wait Until Page Contains Element    ${TODO_RECYCLER_VIEW}    timeout=${APPIUM_TIMEOUT}

Save Todo Without Title
    [Documentation]    Negative case: the save button must refuse an empty title.
    Click Element    ${TODO_ADD_FAB}
    Wait Until Page Contains Element    ${TODO_TITLE_INPUT}    timeout=${APPIUM_TIMEOUT}
    Click Element    ${TODO_SAVE_FAB}

Todo Should Be In List
    [Arguments]    ${title}
    Wait Until Page Contains    ${title}    timeout=${APPIUM_TIMEOUT}
    Page Should Contain Text    ${title}

Todo Should Not Be In List
    [Arguments]    ${title}
    Wait Until Page Does Not Contain    ${title}    timeout=${APPIUM_TIMEOUT}
    Page Should Not Contain Text    ${title}

Open Todo
    [Arguments]    ${title}
    Click Text    ${title}
    Wait Until Page Contains Element    ${TODO_TITLE_INPUT}    timeout=${APPIUM_TIMEOUT}

Edit Todo Title
    [Arguments]    ${old_title}    ${new_title}
    Open Todo    ${old_title}
    Clear Text    ${TODO_TITLE_INPUT}
    Input Text    ${TODO_TITLE_INPUT}    ${new_title}
    Click Element    ${TODO_SAVE_FAB}
    Wait Until Page Contains Element    ${TODO_RECYCLER_VIEW}    timeout=${APPIUM_TIMEOUT}

Delete Todo By Swipe
    [Documentation]    The app has no delete button - a row is removed by swiping it
    ...                (ItemTouchHelperClass: swipeFlags = START | END).
    [Arguments]    ${title}
    ${element}=    Get WebElement    //*[@text="${title}"]
    ${location}=    Get Element Location    ${element}
    ${size}=    Get Element Size    ${element}
    ${start_x}=    Evaluate    ${location}[x] + int(${size}[width] * 0.90)
    ${end_x}=      Evaluate    ${location}[x] + int(${size}[width] * 0.05)
    ${y}=          Evaluate    ${location}[y] + int(${size}[height] / 2)
    # AppiumLibrary 3.x takes named arguments only
    Swipe    start_x=${start_x}    start_y=${y}    end_x=${end_x}    end_y=${y}    duration=800

Undo Delete
    Wait Until Page Contains Element    ${SNACKBAR_UNDO}    timeout=10
    Click Element    ${SNACKBAR_UNDO}

Delete Snackbar Should Be Shown
    [Arguments]    ${title}
    Wait Until Page Contains Element    ${SNACKBAR_TEXT}    timeout=10
    Element Text Should Be    ${SNACKBAR_TEXT}    Deleted ${title}

Set Reminder On New Todo
    [Documentation]    Turns the reminder switch on while adding a todo and leaves the
    ...                date/time pickers at their defaults (today), which is enough to
    ...                prove the reminder row appears on the list item.
    [Arguments]    ${title}
    Click Element    ${TODO_ADD_FAB}
    Wait Until Page Contains Element    ${TODO_TITLE_INPUT}    timeout=${APPIUM_TIMEOUT}
    Input Text    ${TODO_TITLE_INPUT}    ${title}
    Click Element    ${TODO_REMINDER_SWITCH}
    Wait Until Page Contains Element    ${TODO_DATE_INPUT}    timeout=${APPIUM_TIMEOUT}
    Click Element    ${TODO_SAVE_FAB}
    Wait Until Page Contains Element    ${TODO_RECYCLER_VIEW}    timeout=${APPIUM_TIMEOUT}

Reminder Should Be Shown On Todo
    Wait Until Page Contains Element    ${TODO_ITEM_TIME}    timeout=${APPIUM_TIMEOUT}
    Element Should Be Visible    ${TODO_ITEM_TIME}

Open Settings
    Click Element    ${MENU_MORE_OPTIONS}
    Wait Until Page Contains Element    ${MENU_SETTINGS}    timeout=${APPIUM_TIMEOUT}
    Click Element    ${MENU_SETTINGS}
    Wait Until Page Contains Element    ${SETTING_NIGHT_MODE}    timeout=${APPIUM_TIMEOUT}

Toggle Night Mode
    Click Element    ${SETTING_NIGHT_MODE}

Night Mode Summary Should Be
    [Arguments]    ${expected}
    Element Text Should Be    ${SETTING_NIGHT_SUMMARY}    ${expected}

Validation Error Should Be Shown
    [Documentation]    The app shows a Toast ("Please enter a Todo"). A Toast is not in
    ...                the view hierarchy on every Android version, so the real
    ...                assertion is that we are still on the add screen.
    Page Should Contain Element    ${TODO_TITLE_INPUT}
    Run Keyword And Ignore Error    Page Should Contain Text    ${TXT_TODO_ERROR}
