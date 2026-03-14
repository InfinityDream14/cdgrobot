*** Settings *** 
Library    SeleniumLibrary
Library    Collections

*** Variables ***
${var_1}    1
*** Test Cases ***
TEST-00001
    [Documentation]    Test Descriptions
    
    # Log To Console    Hello World!
    # Log    Hello World!

    # It will sum the var_1 and var_2 and will save on the sum variable
    ${var_2}    Set Variable    3
    ${sum}    Evaluate    ${var_1}+${var_2}
    Log    ${sum}

    # The var_3 value will be 1+3
    ${var_3}    Set Variable   ${var_1}+${var_2}
    Log    ${var_3}

    # This will concat var_1 and var_2
    ${cancat}    Evaluate   "${var_1}"+"${var_2}"
    Log    ${cancat}

    Log To Console    ${${var_1} + ${var_2}}
    Log To Console    ${${var_1} - ${var_2}}

TEST-00002
    [Documentation]    String concatination
    ${var_1}    Set Variable    ${10}
    ${var_2}    Set Variable    8
    ${var_3}    Set Variable    ABC   
    ${var_4}    Set Variable    AVCZXC
    

    ${result}    Evaluate    "${var_1}" + " " + "${var_2}"
    ${result}    Set Variable    ${var_1}    ${var_2}

    Log To Console    ${result}
    Log To Console    ${var_1} ${var_2} ${SPACE} ${var_3} ${var_4}

TEST-00003
    [Documentation]    List Examples
    ${list_1}    Create List    value_1    value_2    value_3
    Log To Console    ${list_1}[0]
    Append To List    ${list_1}    value_4

TEST-00004
    [Documentation]    Dictionary Examples
    ${dict_1}    Create Dictionary    key_1=value1    key_2=value2     key_3=value3
    Set To Dictionary    ${dict_1}    key_2=value_4
    Log To Console    ${dict_1}

TEST-00005
    [Documentation]    For Loop Examples
    ${list_1}    Create List    value_1    value_2    value_3
    FOR    ${element}    IN    @{list_1}
        Log To Console    ${element}
    END
    
    FOR    ${element}    IN    value_1    value_2    value_3
        Log To Console     ${element}
    END
    

    # for in range from 0 to 10, with a steps of 2
    FOR    ${1}    IN RANGE    0    10    2
        Log To Console    ${1}        
    END

    ${len}    Get Length    ${list_1}
    Log To Console    \n IN RANGE loop for lists
    FOR    ${i}    IN RANGE    0    ${len}
        Log To Console    ${list_1[${i}]}       
    END
    
    FOR    ${index}    ${element}    IN ENUMERATE    @{list_1}
        Log To Console    ${{ ${index} + 1 }}. ${element}
    END
    

    ${dict_1}    Create Dictionary    key_1=value_1    key_2=value_2    key_3=value_3    key_4=value_4
    FOR    ${key}    IN    @{dict_1}
        Log To Console    ${key}
        Log To Console    ${dict_1["${key}"]}
    END

    FOR    ${key}    ${value}    IN    &{dict_1}
        Log To Console    Key: ${key}, Value: ${value}
    END


    FOR    ${i}    IN RANGE    1    4
        FOR    ${j}    IN    A    B    C    
            Log To Console    ${i}:${j}
        END    
    END
    
TEST_00006
    [Documentation]    Asssertion
    Log To Console    Test
    ${ans}    Evaluate    1+1
    # Should Be Equal    ${ans}    2
    Should Be Equal As Integers    ${ans}    2
    # Should Be Equal As Strings    ${ans}    2

TEST-00007
    [Documentation]    IF STATEMEMTS
    Log To Console    This is an if statement
    # ${ans}    Evaluate    1+1
    # IF    ${ans} != 3
    #     Fail    Failed
    # END

TEST-00008
    ${num}    Evaluate    random.randint(1, 100)    random
    ${remainder}    Evaluate    ${num}    % 2

    IF    ${remainder} == 0
        Pass Execution    PASS: ${num} is an even number.
    ELSE
        Fail    FAIL: ${num} is an odd number.
    END
    
    

*** Keywords ***
# Log Console
    # [Documentation]    ${text}    ${level}=INFO
    # Log    ${text}
    # Log To Console    \n${text}    level=${level}

Clear Test Field
    [Arguments]    ${locatior}
    Press Keys    ${locatior}    CNTR+a    BACKSPACE
    Input Text    ${locatior}    ${text}
