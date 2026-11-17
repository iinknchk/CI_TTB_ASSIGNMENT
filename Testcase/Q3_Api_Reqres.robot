*** Settings ***
Documentation       Question 3 - GET user profile tests for https://reqres.in
...                 reqres.in requires the header x-api-key since 2025; the free key
...                 reqres-free-v1 is the default in Resources/Library/env_config.py.

Resource            ${CURDIR}/../Import/Path_import.robot

Suite Setup         Log Step Result    SUITE    target=${API_BASE}${USER_PATH}
Suite Teardown      Delete All Sessions

Force Tags          Q3    api    reqres


*** Test Cases ***
Get User Profile Success
    [Documentation]    Objective: verify the get user profile API returns the correct
    ...                data for an existing user.
    ...
    ...                Steps  : 1. GET https://reqres.in/api/users/12
    ...                Expected: 1. status code 200
    ...                          2. id == 12, email == rachel.howell@reqres.in,
    ...                             first name == Rachel, last name == Howell,
    ...                             avatar == https://reqres.in/img/faces/12-image.jpg
    [Tags]    1    positive
    ${response}=    Send Get User Profile Request    ${EXISTING_USER_ID}
    Status Code Should Be    ${response}    200
    User Profile Should Match    ${response}
    ...    id=${EXISTING_USER_ID}
    ...    email=${EXP_EMAIL}
    ...    first_name=${EXP_FIRST_NAME}
    ...    last_name=${EXP_LAST_NAME}
    ...    avatar=${EXP_AVATAR}

Get User Profile But User Not Found
    [Documentation]    Objective: verify the get user profile API returns 404 not found
    ...                when asked for a user that does not exist.
    ...
    ...                Steps  : 1. GET https://reqres.in/api/users/1234
    ...                Expected: 1. status code 404
    ...                          2. response body is '{}'
    [Tags]    1    negative
    ${response}=    Send Get User Profile Request    ${MISSING_USER_ID}
    Status Code Should Be    ${response}    404
    Response Should Be Empty Body    ${response}
