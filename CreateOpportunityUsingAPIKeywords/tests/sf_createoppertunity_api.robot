*** Settings ***
Library    QForce
Resource   ../resources/common.resource
Library    FakerLibrary
Library    BuiltIn
Library    Collections
Library    RequestsLibrary
Suite Setup             Setup Browser
Suite Teardown          End Suite

*** Variables ***
${OBJECT}        Opportunity
#${sf_username}                   # SHOULD BE GIVEN IN CRT VARIABLES SECTION
#${login_url}                    # SHOULD BE GIVEN IN CRT VARIABLES SECTION
#${password}                     # SHOULD BE GIVEN IN CRT SENSITIVE VARIABLES SECTION
#${client_id}                    # SHOULD BE GIVEN IN CRT SENSITIVE VARIABLES SECTION
#${client_secret}                # SHOULD BE GIVEN IN CRT SENSITIVE VARIABLES SECTION
${tokenUrl}                      https://login.salesforce.com/services/oauth2/callback
#${tokenUrl}                       https://orgfarm-448dfa1156-dev-ed.develop.lightning.force.com/lightning/page/home


*** Keywords ***
Authenticate
    #${resp}=           Authenticate  ${sf_username}    ${sf_password}    ${sf_url}
    #${resp}=           Authenticate
    #${resp}=      ClientAuthenticate                ${sf_clientid}                ${sf_clientsecret}    ${sf_username}           ${sf_password}     sandbox=True
    ${resp}=      ClientAuthenticate                ${sf_clientid}                ${sf_clientsecret}    ${tokenUrl}          
    Run Keyword If    '${resp.status_code}' in ['401','403']    Fail    Authentication failed

Create Opportunity
    ${oppName}=    FakerLibrary.Company
    ${payload}=    Create Dictionary    Name=${oppName}    StageName=Prospecting    CloseDate=2026-01-31    Amount=5000
    ${resp}=       Create Record    ${OBJECT}    ${payload}
    Run Keyword If    '${resp.status_code}' in ['401','403']    Fail    Create failed
    ${oppId}=    Set Variable    ${resp.id}
    Set Global Variable    ${oppId}

Update Opportunity Stage
    ${payload}=    Create Dictionary    StageName=Proposal
    ${resp}=        Update Record    ${OBJECT}    ${oppId}    ${payload}
    Run Keyword If    '${resp.status_code}' in ['401','403']    Fail    Update failed

Retrieve Opportunity
    ${resp}=           Get Record    ${OBJECT}    ${oppId}    fields= Id,Amount,StageName,OwnerId
    Run Keyword If    '${resp.status_code}' in ['401','403']    Fail    Retrieval failed
    [Return]    ${resp}

Validate Opportunity
    ${record}=    Retrieve Opportunity
    Should Be Equal    ${record.Amount}    5000
    Should Be Equal    ${record.StageName}    Proposal

UI Validation
    #Open Record    ${OBJECT}    ${oppId}
    GetRecord    ${OBJECT}    ${oppId}
    #Verify Field Value    StageName    Proposal
    VerifyField                StageName    Proposal
    #Verify Field Value    Amount       5000
    VerifyField    Amount       5000
    #Verify Field Value    Owner        ${sf_username}
    VerifyField    Owner        ${sf_username}

*** Test Cases ***
API And UI Opportunity Flow
    Login
    Fill MFA
    Home
    Authenticate
    Create Opportunity
    Update Opportunity Stage
    Validate Opportunity
    UI Validation
