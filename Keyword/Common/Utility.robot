*** Settings ***
Documentation       Keywords that belong to no single channel.

Resource            ${CURDIR}/../../Import/Library_import.robot


*** Keywords ***
Lists Should Be Equal In Order
    [Documentation]    Fails with both lists in the message when they differ.
    [Arguments]    ${actual}    ${expected}    ${label}=list
    ${actual_text}=    Convert To String    ${actual}
    ${expected_text}=    Convert To String    ${expected}
    Log To Console    \n[${label}] actual=${actual_text} expected=${expected_text}
    Lists Should Be Equal    ${actual}    ${expected}
    ...    msg=${label} mismatch: actual=${actual_text} expected=${expected_text}
    ...    values=${FALSE}

Log Step Result
    [Arguments]    ${step}    ${detail}
    Log To Console    \n[${step}] ${detail}
    Log    ${step}: ${detail}
