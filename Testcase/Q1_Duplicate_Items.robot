*** Settings ***
Documentation       Question 1 - check duplicate items from list A and list B and
...                 append them to a new list.
...
...                 List A : [1,2,3,5,6,8,9]
...                 List B : [3,2,1,5,6,0]
...                 Expected new list : [1,2,3,5,6]

Resource            ${CURDIR}/../Import/Path_import.robot

Force Tags          Q1    duplicate    offline


*** Test Cases ***
Find Duplicate Items From List A And List B
    [Documentation]    The duplicates are appended to a NEW list; both input lists
    ...                must come back unchanged.
    [Tags]    1
    ${duplicates}=    Find Duplicate Items    ${LIST_A}    ${LIST_B}
    Lists Should Be Equal In Order    ${duplicates}    ${EXPECTED_DUPLICATES}    duplicates
    Lists Should Be Equal In Order    ${LIST_A}    ${{ [1,2,3,5,6,8,9] }}    list A unchanged
    Lists Should Be Equal In Order    ${LIST_B}    ${{ [3,2,1,5,6,0] }}      list B unchanged

Nested Loop Version Gives The Same Answer
    [Documentation]    Proves the O(n+m) set version and the plain O(n*m) nested loop
    ...                agree, so the faster one can be used with confidence.
    [Tags]    1
    ${fast}=    Find Duplicate Items          ${LIST_A}    ${LIST_B}
    ${naive}=   Find Duplicate Items Naive    ${LIST_A}    ${LIST_B}
    Lists Should Be Equal In Order    ${fast}    ${naive}    fast vs naive

Duplicate Items Edge Cases
    [Documentation]    Repeated values are appended once, an empty list gives an empty
    ...                result, and strings work as well as numbers.
    [Tags]    2
    ${repeated}=    Find Duplicate Items    ${{ [1,1,2,2,3] }}    ${{ [1,2] }}
    Lists Should Be Equal In Order    ${repeated}    ${{ [1,2] }}    repeated values appended once
    ${none}=    Find Duplicate Items    ${{ [] }}    ${{ [1,2] }}
    Lists Should Be Equal In Order    ${none}    ${{ [] }}    empty list A
    ${no_overlap}=    Find Duplicate Items    ${{ [1,2] }}    ${{ [7,8] }}
    Lists Should Be Equal In Order    ${no_overlap}    ${{ [] }}    no overlap
    ${words}=    Find Duplicate Items    ${{ ['a','b','c'] }}    ${{ ['c','a'] }}
    Lists Should Be Equal In Order    ${words}    ${{ ['a','c'] }}    strings follow list A order
