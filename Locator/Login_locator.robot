*** Comments ***
Locators for https://the-internet.herokuapp.com/login (Question 2).
Browser library selectors: css= is the default engine, so the prefix is kept
explicit to make each locator obvious at a glance.


*** Variables ***
${LOGIN_FORM}               css=form#login
${LOGIN_USERNAME_INPUT}     css=input#username
${LOGIN_PASSWORD_INPUT}     css=input#password
${LOGIN_SUBMIT_BUTTON}      css=button[type="submit"]
${LOGIN_PAGE_HEADING}       css=div.example h2
${FLASH_MESSAGE}            css=div#flash
${SECURE_AREA_HEADING}      css=div.example h2
${LOGOUT_BUTTON}            css=a[href="/logout"]
