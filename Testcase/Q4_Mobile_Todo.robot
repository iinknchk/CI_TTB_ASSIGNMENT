*** Settings ***
Documentation       Question 4 - Minimal-Todo Android app (Robot Framework + Appium).
...                 App under test: https://github.com/avjinder/Minimal-Todo
...                 appPackage  com.avjindersinghsekhon.minimaltodo
...                 appActivity com.example.avjindersinghsekhon.minimaltodo.Main.MainActivity
...
...                 Needs a running Appium server and an Android device/emulator.
...                 The test case design is in Test_Case_Design.md.

Resource            ${CURDIR}/../Import/Mobile_import.robot

Test Setup          Open Todo App
Test Teardown       Close Todo App

Force Tags          Q4    mobile    appium


*** Variables ***
${TODO_TITLE}           Buy milk
${TODO_TITLE_EDITED}    Buy milk and eggs
${TODO_DESCRIPTION}     2 litres, low fat
${TODO_SECOND}          Pay electricity bill


*** Test Cases ***
TC01 - Empty State Is Shown On First Launch
    [Documentation]    A fresh install has no todos, so the empty view and its
    ...                message must be the first thing the user sees.
    [Tags]    1    smoke
    Empty List Should Be Shown

TC02 - Add Todo With Title Only
    [Documentation]    The core feature: FAB -> type a title -> save -> the todo is
    ...                in the list and the empty view is gone.
    [Tags]    1    smoke    crud
    Empty List Should Be Shown
    Add Todo    ${TODO_TITLE}
    Todo Should Be In List    ${TODO_TITLE}

TC03 - Add Todo With Title And Description
    [Tags]    1    crud
    Add Todo    ${TODO_TITLE}    ${TODO_DESCRIPTION}
    Todo Should Be In List    ${TODO_TITLE}

TC04 - Add Todo Is Rejected When The Title Is Empty
    [Documentation]    Negative case: saving with an empty title must not create a
    ...                todo; the app keeps the user on the add screen.
    [Tags]    1    negative
    Save Todo Without Title
    Validation Error Should Be Shown

TC05 - Add Several Todos
    [Documentation]    Both todos must be listed - adding the second must not replace
    ...                the first.
    [Tags]    2    crud
    Add Todo    ${TODO_TITLE}
    Add Todo    ${TODO_SECOND}
    Todo Should Be In List    ${TODO_TITLE}
    Todo Should Be In List    ${TODO_SECOND}

TC06 - Edit The Title Of An Existing Todo
    [Tags]    2    crud
    Add Todo    ${TODO_TITLE}
    Edit Todo Title    ${TODO_TITLE}    ${TODO_TITLE_EDITED}
    Todo Should Be In List        ${TODO_TITLE_EDITED}
    Todo Should Not Be In List    ${TODO_TITLE}

TC07 - Delete A Todo By Swiping It Away
    [Documentation]    The app has no delete button; a row is removed by swiping
    ...                (ItemTouchHelperClass: swipeFlags = START | END).
    [Tags]    2    crud
    Add Todo    ${TODO_TITLE}
    Delete Todo By Swipe    ${TODO_TITLE}
    Todo Should Not Be In List    ${TODO_TITLE}

TC08 - Undo Brings A Deleted Todo Back
    [Documentation]    After a swipe the app shows 'Deleted <title>' with an UNDO
    ...                action; UNDO must restore the row.
    [Tags]    2    crud
    Add Todo    ${TODO_TITLE}
    Delete Todo By Swipe    ${TODO_TITLE}
    Delete Snackbar Should Be Shown    ${TODO_TITLE}
    Undo Delete
    Todo Should Be In List    ${TODO_TITLE}

TC09 - Deleting The Last Todo Shows The Empty State Again
    [Tags]    2
    Add Todo    ${TODO_TITLE}
    Delete Todo By Swipe    ${TODO_TITLE}
    Empty List Should Be Shown

TC10 - Set A Reminder While Adding A Todo
    [Documentation]    Turning the reminder switch on reveals the date and time fields
    ...                and the saved row then carries a time.
    [Tags]    2    reminder
    Set Reminder On New Todo    ${TODO_TITLE}
    Todo Should Be In List    ${TODO_TITLE}
    Reminder Should Be Shown On Todo

TC11 - Todos Survive An App Restart
    [Documentation]    The app stores todos in a local file, so closing and reopening
    ...                must not lose them.
    [Tags]    2    persistence
    Add Todo    ${TODO_TITLE}
    Todo Should Be In List    ${TODO_TITLE}
    Restart Todo App
    Todo Should Be In List    ${TODO_TITLE}

TC12 - Night Mode Can Be Turned On From Settings
    [Documentation]    Settings holds a Night Mode checkbox whose summary changes with
    ...                the state ("Night mode is on" / "Night mode is off").
    [Tags]    3    settings
    Open Settings
    Night Mode Summary Should Be    Night mode is off
    Toggle Night Mode
    Night Mode Summary Should Be    Night mode is on
