*** Settings ***
Documentation       Question 6 - simpleCipher(encrypted, k) on the A-Z alphabet wheel.
...                 Each letter is replaced by the letter k steps counter-clockwise
...                 (backwards) on the wheel, wrapping A -> Z.

Resource            ${CURDIR}/../Import/Path_import.robot

Force Tags          Q6    cipher    offline


*** Test Cases ***
Decrypt The Example From The Assignment
    [Documentation]    encrypted = 'VTAOG', k = 2  ->  'TRYME'
    [Tags]    1
    ${plain}=    Simple Cipher    VTAOG    ${2}
    Should Be Equal    ${plain}    TRYME    msg=the worked example in the assignment must decrypt to TRYME

Decrypt Wraps Around The Wheel
    [Documentation]    'A' with k=1 must wrap to 'Z', not fall off the alphabet.
    [Tags]    1
    ${plain}=    Simple Cipher    ABC    ${1}
    Should Be Equal    ${plain}    ZAB

Decrypt With K Of Zero Returns The Input
    [Tags]    2
    ${plain}=    Simple Cipher    HELLO    ${0}
    Should Be Equal    ${plain}    HELLO

Decrypt With A Full Turn Of The Wheel Returns The Input
    [Documentation]    k = 26 is one complete turn, and k = 28 is one turn plus 2.
    [Tags]    2
    ${full_turn}=    Simple Cipher    ZAB    ${26}
    Should Be Equal    ${full_turn}    ZAB
    ${turn_plus_two}=    Simple Cipher    VTAOG    ${28}
    Should Be Equal    ${turn_plus_two}    TRYME

Decrypt The Whole Alphabet
    [Documentation]    k = 1 shifts every letter back by one across the full wheel.
    [Tags]    2
    ${plain}=    Simple Cipher    ABCDEFGHIJKLMNOPQRSTUVWXYZ    ${1}
    Should Be Equal    ${plain}    ZABCDEFGHIJKLMNOPQRSTUVWXY

Decrypt Table Driven Cases
    [Documentation]    Runs every case listed in Settings.robot @{CIPHER_CASES}
    ...                (format: encrypted:k:expected).
    [Tags]    2
    FOR    ${case}    IN    @{CIPHER_CASES}
        @{parts}=    Split String    ${case}    :
        ${plain}=    Simple Cipher    ${parts}[0]    ${parts}[1]
        Should Be Equal    ${plain}    ${parts}[2]
        ...    msg=simpleCipher('${parts}[0]', ${parts}[1]) gave '${plain}' but '${parts}[2]' was expected
        Log Step Result    CIPHER    simpleCipher('${parts}[0]', ${parts}[1]) = ${plain}
    END
