*** Settings ***
Documentation       The single resource every test case imports.

Resource            ${CURDIR}/Library_import.robot
Resource            ${CURDIR}/../Keyword/Common/Utility.robot
Resource            ${CURDIR}/../Keyword/Common/Api.robot
Resource            ${CURDIR}/../Keyword/Web/Login.robot
Resource            ${CURDIR}/../Keyword/Api/Reqres.robot
