*** Settings ***
Library    SeleniumLibrary
Variables    ../Variables/loginpage.py
Library    ../Libraries/CommonLibrary.py
# Variables    ../Variables/navigate_to_submenus.py

*** Variables ***
@{sales_submenu}    Orders    Invoices
@{catalog_submenu}    Posters    Categories
@{customers_submenu}   Customers    Segments
@{users}
&{MENU}    sales=${sales_submenu}    Catalog=${catalog_submenu}    Customers=${customers_submenu}


*** Keywords ***

Launch Browser
    [Arguments]    ${url}=${TEST_URL}
    Open Browser    ${url}    chrome    options=add_argument("--start-maximized");
    Wait Until Page Contains Element    ${username_input}

Login User
    [Arguments]    ${username}=demo    ${password}=demo
    Input Text    locator=${login_txt_username}    text=${username}
    Input Text    locator=${login_txt_password}    text=${password}
    Capture Page Screenshot
    Click Button    ${login_btn_submit}
    Wait Until Element Is Visible    ${main_content}
    # Sleep    5s

Get Parameter Menu
    [Arguments]    ${sub_menu}
    FOR    ${key}    IN    @{MENU.keys()}
    
        Return From Keyword If    "${sub_menu}" in ${MENU['${key}']}    //li[descendant::p[text()="${key}"]]

    END
    
    RETURN    ${None}

Navigate
    [Arguments]  ${sub_menu}

    # Get the navigation elemets    
    ${status}    Run Keyword And Return Status    Element Should Be Visible    //a[descendant::p[text()="${sub_menu}"]]

    IF    not ${status}
        ${parent_menu}    Get Parameter Menu    ${sub_menu}
        Click Element   ${parent_menu}
        Wait Until Element Is Visible    //a[descendant::p[text()="${sub_menu}"]]    timeout=5s
    END
    
    # Final click and verification
    Click Element    //a[descendant::p[text()="${sub_menu}"]]
    Wait Until Element Is Visible    //h6[.//span[text()="${sub_menu}"]]    timeout=10s
    Run Keyword If    "${sub_menu}"=="Customers"    Sleep    2s