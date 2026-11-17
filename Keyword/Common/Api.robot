*** Settings ***
Documentation       Shared HTTP keywords. Every request goes through here so the
...                 headers, the timeout and the "never raise on 4xx" rule are
...                 decided in one place.

Resource            ${CURDIR}/../../Import/Library_import.robot


*** Keywords ***
Api Headers
    [Documentation]    reqres.in has required an API key since 2025; without it
    ...                every call answers 401 and the test would look like a
    ...                product bug instead of a missing key.
    ${headers}=    Create Dictionary
    ...    Accept=application/json
    ...    x-api-key=${REQRES_API_KEY}
    RETURN    ${headers}

Create Api Session
    [Arguments]    ${alias}=api_session    ${base_url}=${API_BASE}
    Create Session    ${alias}    ${base_url}    verify=${TRUE}    max_retries=0
    RETURN    ${alias}

Get Api
    [Documentation]    GET that returns the response whatever the status code is,
    ...                so the test itself asserts on 200 / 404.
    [Arguments]    ${path}    ${alias}=api_session
    ${headers}=    Api Headers
    ${response}=    GET On Session    ${alias}    ${path}
    ...    headers=${headers}    expected_status=any    timeout=${API_TIMEOUT}
    Log Step Result    GET ${path}    status=${response.status_code}
    RETURN    ${response}

Status Code Should Be
    [Arguments]    ${response}    ${expected}
    Should Be Equal As Integers    ${response.status_code}    ${expected}
    ...    msg=expected HTTP ${expected} but got ${response.status_code} - body: ${response.text}[:300]
