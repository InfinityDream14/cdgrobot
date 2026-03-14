*** Settings ***
Library    SeleniumLibrary
Variables    ../Variables/customers.py
Resource    app.resource
Library    DateTime
Library    Collections

*** Variables ***
@{locators}    ${cust_txt_first_name}    ${cust_txt_last_name}    ${cust_txt_email}    
...            ${cust_txt_birthday}      ${cust_txt_address}      ${cust_txt_city}    
...            ${cust_txt_stateAbbr}     ${cust_txt_zip}    
...            ${cust_txt_password}      ${cust_txt_confirm_password}
${total}      0.0
${buyers}     []

*** Keywords ***
Format Birthday
    [Arguments]    ${date}
    ${val}    Evaluate    "".join($date.split("-")[1:] + [$date.split("-")[0]])
    RETURN    ${val}

Verify Customer Is Added
    [Arguments]    ${user}
    Wait Until Element Is Visible    ${cust_txt_first_name}
    ${expected}    Create List    ${user['first_name']}    ${user['last_name']}    ${user['email']}    
    ...    ${user['birthday']}    ${user['address']['street']} ${user['address']['suite']}    
    ...    ${user['address']['city']}    ${user['address']['stateAbbr']}    ${user['zipcode']}    
    ...    ${user['password']}    ${user['password']}

    FOR    ${i}    ${locator}    IN ENUMERATE    @{locators}
        IF    $locator in [$cust_txt_password, $cust_txt_confirm_password, $cust_txt_birthday]    CONTINUE
        ${actual}    Get Value    ${locator}
        Should Be Equal As Strings    ${actual}    ${expected[${i}]}
    END

Add A Customer
    [Arguments]    ${user}
    Click Element    //a[text()="Create"]
    Wait Until Element Is Visible    //h6[.//span[text()="Create Customer"]]
    
    ${values}    Create List    ${user['first_name']}    ${user['last_name']}    ${user['email']}    
    ...    ${user['birthday']}    ${user['address']['street']} ${user['address']['suite']}    
    ...    ${user['address']['city']}    ${user['address']['stateAbbr']}    ${user['zipcode']}    
    ...    ${user['password']}    ${user['password']}

    FOR    ${i}    ${locator}    IN ENUMERATE    @{locators}
        ${val}    Set Variable    ${values[${i}]}
        IF    $locator == $cust_txt_birthday
            ${val}    Format Birthday    ${val}
        END
        Input Text    ${locator}    ${val}
    END
    Click Button    ${cust_btn_save}
    Wait Until Element Is Visible    //div[contains(text(), "created")]

Add Multiple Customers
    [Arguments]    ${customers}    ${start}=0    ${end}=1
    FOR    ${i}    IN RANGE    ${start}    ${end}
        Navigate    Customers
        Add A Customer    ${customers[${i}]}
        Wait Until Page Contains    ${customers[${i}]['first_name']}
    END

Update Customers
    [Arguments]    ${customers}    ${start}=0    ${end}=1
    FOR    ${i}    IN RANGE    ${start}    ${end}
        Navigate    Customers
        Wait Until Element Is Visible    (//tbody//tr)[${i+1}]
        Click Element    (//tbody//tr)[${i+1}]//td[contains(@class, "column-last_name")]
        
        Wait Until Element Is Visible    ${cust_txt_first_name}
        ${user}    Set Variable    ${customers[${i}]}
        ${values}    Create List    ${user['first_name']}    ${user['last_name']}    ${user['email']}    
        ...    ${user['birthday']}    ${user['address']['street']} ${user['address']['suite']}    
        ...    ${user['address']['city']}    ${user['address']['stateAbbr']}    ${user['zipcode']}    
        ...    ${user['password']}    ${user['password']}

        FOR    ${j}    ${locator}    IN ENUMERATE    @{locators}
            ${val}    Set Variable    ${values[${j}]}
            IF    $locator == $cust_txt_birthday
                ${val}    Format Birthday    ${val}
            ELSE
                Press Keys    ${locator}    CTRL+a+BACKSPACE
            END
            Input Text    ${locator}    ${val}
        END
        Verify Customer Is Added    ${user}
        Click Button    ${cust_btn_save}
        Wait Until Element Is Visible    //div[contains(text(), "updated")]
    END

Log Table Columns
    Navigate    Customers
    Wait Until Element Is Visible    xpath://tbody//tr    timeout=10s
    ${row_count}    Get Element Count    xpath://tbody//tr
    
    ${running_total}    Set Variable    ${0.0}
    ${buyer_list}       Create List
    
    Log To Console    \n\n[ CUSTOMER DATA REPORT - PAGE 1 ]
    Log To Console    ========================================

    FOR    ${i}    IN RANGE    1    ${row_count} + 1
        ${row_xpath}    Set Variable    xpath:(//tbody//tr)[${i}]

        # --- Data Extraction ---
        ${raw_name}    Get Text    ${row_xpath}//td[2]
        ${name}        Evaluate    """${raw_name}""".split('\\n')[-1].strip()
        ${last_seen}   Get Text    ${row_xpath}//td[3]
        ${orders}      Get Text    ${row_xpath}//td[4]
        ${spent}       Get Text    ${row_xpath}//td[5]
        ${latest}      Get Text    ${row_xpath}//td[6]

        # News Logic (Yes/No)
        ${is_news}     Get Element Count    ${row_xpath}//td[7]//*[contains(@data-testid, 'CheckBoxIcon')]
        ${status}      Evaluate    "Yes" if ${is_news} > 0 else "No"
        
        # Segment Logic (Chips)
        ${seg_elements}    Get WebElements    ${row_xpath}//td[8]//span[contains(@class, 'MuiChip-label')]
        ${seg_list}        Create List
        FOR    ${el}    IN    @{seg_elements}
            ${val}    Get Text    ${el}
            Append To List    ${seg_list}    ${val}
        END
        ${segments}    Evaluate    ", ".join($seg_list)

        # --- Numeric Conversion for Filtering ---
        ${spent_num}    Evaluate    float("${spent}".replace('$', '').replace(',', '')) if "${spent}" else 0.0
        ${orders_num}   Evaluate    int("${orders}") if "${orders}" else 0

        # --- Running Total Calculation ---
        IF    ${spent_num} > 0
            ${running_total}    Evaluate    ${running_total} + ${spent_num}
            ${buyer_entry}      Catenate    SEPARATOR=    - ${name}: ${spent}
            Append To List      ${buyer_list}    ${buyer_entry}
        END

        # --- Detailed Console Output (Current Row) ---
        Log To Console    CUSTOMER #${i}
        ${line}    Catenate    SEPARATOR=    > Name:            ${name}
        Log To Console    ${line}
        
        IF    $last_seen    
            ${line}    Catenate    SEPARATOR=    > Last Seen:       ${last_seen}
            Log To Console    ${line}
        END

        # Filtered Field: Orders
        IF    ${orders_num} > 0
            ${line}    Catenate    SEPARATOR=    > Orders:          ${orders}
            Log To Console    ${line}
        END

        # Filtered Field: Total Spent
        IF    ${spent_num} > 0
            ${line}    Catenate    SEPARATOR=    > Total Spent:     ${spent}
            Log To Console    ${line}
        END

        IF    $latest       
            ${line}    Catenate    SEPARATOR=    > Latest Purchase: ${latest}
            Log To Console    ${line}
        END

        # News and Segments
        ${line}    Catenate    SEPARATOR=    > News:            ${status}
        Log To Console    ${line}
        
        IF    $segments     
            ${line}    Catenate    SEPARATOR=    > Segment:         ${segments}
            Log To Console    ${line}
        END
        
        Log To Console    ----------------------------------------
    END

    Set Suite Variable    ${total}     ${running_total}
    Set Suite Variable    ${buyers}    ${buyer_list}

    RETURN    ${running_total}    ${buyer_list}

Display Purchase Summary and Result
    [Arguments]    ${running_total}    ${buyer_list}
    
    Log To Console    \n[ PURCHASE SUMMARY - TOTALS ]
    Log To Console    ========================================
    
    FOR    ${entry}    IN    @{buyer_list}
        Log To Console    ${entry}
    END
    
    Log To Console    ----------------------------------------
    
    ${formatted_total}    Evaluate    "{:.2f}".format(${running_total})
    ${total_line}         Catenate    SEPARATOR=    GRAND TOTAL: $    ${formatted_total}
    Log To Console    ${total_line}

    IF    ${running_total} > 3500
        Log To Console    PASS: Total spending ($${formatted_total}) meets minimum threshold ($3,500)
    ELSE
        Log To Console    FAIL: Total spending ($${formatted_total}) is below minimum threshold ($3,500)
    END
    Log To Console    ========================================\n
