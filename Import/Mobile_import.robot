*** Settings ***
Documentation       Mobile suites import this instead of Path_import.robot.
...                 AppiumLibrary and Browser both own keywords such as
...                 `Click Element` / `Get Text`, so they are kept in separate
...                 import files and never loaded into the same suite.

Library             Collections
Library             String
Library             OperatingSystem
Library             AppiumLibrary
Variables           ${CURDIR}/../Resources/Library/env_config.py
Resource            ${CURDIR}/../Resources/Settings/Settings.robot
Resource            ${CURDIR}/../Keyword/Mobile/Todo.robot
