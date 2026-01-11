*** Settings ***
Library           QForce
#Library            QWeb
Library            BuiltIn
Library           FakerLibrary
Resource        ../resources/common.robot
Suite Setup       Setup Browser
Suite Teardown    End Suite

*** Variables ***
${OBJECT}                     Lead
${EXPECTED_OWNER_NAME}        Srinath Palakonda

*** Keywords ***
L#ogin To Salesforce
   # QForce.Login    ${SF_USERNAME}    ${SF_PASSWORD}    ${SF_URL}

#Logout From Salesforce
    #QForce.Logout

Create Random Lead
    ${fname}=    FakerLibrary.FirstName
    ${lname}=    FakerLibrary.LastName
    ${company}=  FakerLibrary.Company
    LaunchApp          Sales
    ClickText          Leads
    ClickText          New
    UseModal                    On              # only search the fields on model dialouge box
    #CreateRecord    ${OBJECT}
    TypeText        First Name                      ${fname}
    TypeText        Last Name                       ${lname}
    TypeText        Company                         ${company}
    PickList        Lead Source                     Web
     ClickText      Save                            partial_match=false
     UseModal                      off
    #Handle Duplicate Popup

Handle Duplicate Popup
    #Run Keyword If    Page Contains Element    
    #...    Click Text    Save Anyway
     ${is_duplicate}=    Run Keyword And Return Status
    ...    Verify Text    Potential Duplicate
    IF    ${is_duplicate}
        ClickText    Save
    END

Validate Lead
    ClickText     Details
    #VerifyText    Status         Open - Not Contacted
    VerifyField    Lead Status          Open - Not Contacted
    ${owner}=      GetFieldValue        Lead Owner
    Should Be Equal As Strings    ${owner}    ${EXPECTED_OWNER_NAME}

*** Test Cases ***
Create And Validate Lead
   #Login to Saleforce Env
    Login to Saleforce Env using job level variables
    Create Random Lead
    Handle Duplicate Popup
    Validate Lead
