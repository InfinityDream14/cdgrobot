*** Settings ***
Resource    Resource/app.resource
Resource    Resource/Customers.resource

Suite Setup    Suite Init
Suite Teardown    Capture Page Screenshot

# Test - Single Test Case
# Suite = Collection of multiple test cases
# Sout Setup - Keyword performed before executing initial test case
# Test Teadown - Keyword Performed after execution of all test cases (Test Data Cleanup)
# Test Setup - Keyword performed vefore every test cases
# Test Teardown - Keyword Performed after every Test Cases

*** Variables ***
${total}      0.0
@{buyers}


*** Test Cases ***

TEST-00001
    [Documentation]    Add Multiple Users
    Add Multiple Customers    customers=${users}    start=0    end=5
TEST-00002
    [Documentation]    Update Customers
    Update Customers    customers=${users}    start=6    end=10
TEST-00003
    [Documentation]    Log the columns and store data in Suite Scope
    Log Table Columns

TEST-00004
    [Documentation]    Display the summary and results
    Display Purchase Summary and Result    ${total}    ${buyers}
    
    
    
    
    # Verify If Customer Is Added In The Tale    ${users[0]}
    # Get Table Rows
    # Verify Customer Is Added    ${users[0]}

# TEST-00002
#     Navigate    Customers
#     Get Table Rows    

*** Keywords ***
Suite Init
    Launch Browser
    Login User
    ${users}    Get Users
    Set Suite Variable    ${USERS}    ${users}
    