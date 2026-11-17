*** Comments ***
Locators for the Minimal-Todo Android app (Question 4).
Taken from the app source (res/layout/*.xml, res/menu/menu_main.xml), so the ids
are the real ones, not guesses. Appium needs the applicationId as the id prefix:
applicationId = com.avjindersinghsekhon.minimaltodo
(the java package com.example... is different - do not use it for ids)


*** Variables ***
${PKG}                      com.avjindersinghsekhon.minimaltodo

# ------------------------------------------------- main list screen (fragment_main.xml)
${TODO_ADD_FAB}             id=${PKG}:id/addToDoItemFAB
${TODO_RECYCLER_VIEW}       id=${PKG}:id/toDoRecyclerView
${TODO_EMPTY_VIEW}          id=${PKG}:id/toDoEmptyView
${TODO_COORDINATOR}         id=${PKG}:id/myCoordinatorLayout

# ------------------------------------------------- list row (list_item_view_future.xml)
${TODO_ITEM_TITLE}          id=${PKG}:id/toDoListItemTextview
${TODO_ITEM_TIME}           id=${PKG}:id/todoListItemTimeTextView
${TODO_ITEM_COLOR}          id=${PKG}:id/toDoListItemColorImageView

# ------------------------------------------------- add / edit screen (fragment_add_to_do.xml)
${TODO_TITLE_INPUT}         id=${PKG}:id/userToDoEditText
${TODO_DESCRIPTION_INPUT}   id=${PKG}:id/userToDoDescription
${TODO_SAVE_FAB}            id=${PKG}:id/makeToDoFloatingActionButton
${TODO_REMINDER_SWITCH}     id=${PKG}:id/toDoHasDateSwitchCompat
${TODO_DATE_INPUT}          id=${PKG}:id/newTodoDateEditText
${TODO_TIME_INPUT}          id=${PKG}:id/newTodoTimeEditText
${TODO_REMINDER_SUMMARY}    id=${PKG}:id/newToDoDateTimeReminderTextView

# ------------------------------------------------- menu (menu_main.xml) + settings
${MENU_MORE_OPTIONS}        xpath=//android.widget.ImageView[@content-desc="More options"]
${MENU_SETTINGS}            xpath=//android.widget.TextView[@text="Settings"]
${MENU_ABOUT}               xpath=//android.widget.TextView[@text="About"]
${SETTING_NIGHT_MODE}       xpath=//android.widget.TextView[@text="Night Mode"]
${SETTING_NIGHT_SUMMARY}    xpath=//android.widget.TextView[@text="Night Mode"]/following-sibling::android.widget.TextView

# ------------------------------------------------- snackbar / toast
${SNACKBAR_TEXT}            id=android:id/snackbar_text
${SNACKBAR_UNDO}            xpath=//android.widget.Button[@text="UNDO"]
${TOAST_ANY}                xpath=//android.widget.Toast

# ------------------------------------------------- expected app strings (res/values/strings.xml)
${TXT_EMPTY_LIST}           You don't have any todos
${TXT_TODO_ERROR}           Please enter a Todo
${TXT_DATE_IN_PAST}         The date you entered is in the past.
