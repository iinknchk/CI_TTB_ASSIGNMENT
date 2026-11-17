*** Settings ***
Documentation       Question 3 - business keywords for the reqres.in user profile API.

Resource            ${CURDIR}/../../Import/Library_import.robot
Resource            ${CURDIR}/../Common/Api.robot


*** Keywords ***
Send Get User Profile Request
    [Documentation]    Step 1 of both test cases: GET ${API_BASE}/api/users/<id>
    [Arguments]    ${user_id}
    Create Api Session
    ${response}=    Get Api    ${USER_PATH}/${user_id}
    RETURN    ${response}

User Profile Should Match
    [Documentation]    Compares every field the assignment lists, one assertion per
    ...                field so a failure names the field that is wrong.
    [Arguments]    ${response}    ${id}    ${email}    ${first_name}    ${last_name}    ${avatar}
    ${data}=    Parse Json Field    ${response.text}    data
    Should Not Be Equal    ${data}    ${EMPTY}    msg=response has no 'data' object: ${response.text}[:300]
    Should Be Equal As Integers    ${data}[id]           ${id}            msg=id mismatch
    Should Be Equal As Strings     ${data}[email]        ${email}         msg=email mismatch
    Should Be Equal As Strings     ${data}[first_name]   ${first_name}    msg=first_name mismatch
    Should Be Equal As Strings     ${data}[last_name]    ${last_name}     msg=last_name mismatch
    Should Be Equal As Strings     ${data}[avatar]       ${avatar}        msg=avatar mismatch
    Log Step Result    USER PROFILE
    ...    id=${data}[id] ${data}[first_name] ${data}[last_name] <${data}[email]>

Response Should Be Empty Body
    [Arguments]    ${response}
    Response Body Should Be Empty Json    ${response.text}
    Log Step Result    BODY    '${response.text}' is the empty object the API returns for a missing user
