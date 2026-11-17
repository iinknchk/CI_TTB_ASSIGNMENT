*** Settings ***
Documentation       Every external library and variables file the project uses.
...                 Keyword files import THIS file, test cases import Path_import.robot.

Library             Collections
Library             String
Library             DateTime
Library             OperatingSystem
Library             Process
Library             RequestsLibrary
Library             Browser
Library             ${CURDIR}/../Resources/Library/list_helper.py
Library             ${CURDIR}/../Resources/Library/simple_cipher.py
Library             ${CURDIR}/../Resources/Library/response_helper.py
Variables           ${CURDIR}/../Resources/Library/env_config.py
Resource            ${CURDIR}/../Resources/Settings/Settings.robot
