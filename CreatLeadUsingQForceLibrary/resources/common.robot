*** Settings ***
Library            QForce
Library            QWeb
Library            String


*** Variables ***
${login_url}            https://login.salesforce.com/
${username}             copadotraining07166@agentforce.com   
${password}             Copadotraining@2025
${secretmfa}            QFDZZ4C7JKZPNKHZ3NFTWWXAKEFD4XPU

*** Keywords ***
Setup Browser
    Set Library Search Order         QWeb            QForce
    OpenBrowser                      about:blank     chrome
    SetConfig                        LineBreak       ${EMPTY}          
    SetConfig                       DefaultTimeout  20s             # wait in case sales force time to load 

End Suite
        Set Library Search Order        QWeb            QForce
        CloseAllBrowsers

Login to Saleforce Env
    [Documentation]                         Login to sales force Env 
    [Tags]                                  salesforcelogin
    Set Library Search Order            QWeb            QForce
    GoTo                                                 ${login_url}
    #TypeText                            Username                copadotraining07-6uz4@force.com
    #TypeText                            Password                crt011225
    
    TypeText                               Username                ${username}
    TypeText                               Password                ${password}
    ClickText                              Log In
    #check if there is MFA enabled
    ${mfa_code}=                            GetOtp                  ${username}              ${secretmfa}     ${login_url} 
    TypeSecret                               Verification Code       ${mfa_code}
    ClickText                                 Verify


Login to Saleforce Env using job level variables
    [Documentation]                         Login to sales force Env using job level variable
    [Tags]                                  salesforceloginjobLevel

    Set Library Search Order            QWeb            QForce
    GoTo                                 ${sf_url}
    #TypeText                        Username                copadotraining07-6uz4@force.com
    #TypeText                        Password                crt011225
    
    TypeText                        Username                ${sf_username}
    TypeText                        Password                ${sf_password}
    ClickText                       Log In
    #check if there is MFA enabled
    ${mfa_code}=                    GetOtp                  ${sf_username}              ${sf_mfa}     ${sf_url} 
    TypeSecret                      Verification Code       ${mfa_code}
    ClickText                       Verify
                                              
