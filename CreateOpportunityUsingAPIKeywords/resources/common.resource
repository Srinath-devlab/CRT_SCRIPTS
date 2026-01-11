*** Settings ***
Library                 QForce
Library                 BuiltIn
Library                 RequestsLibrary

*** Variables ***
${BROWSER}                chrome
${mfa}                    ${FALSE}                # True -> Run with App authentication.


*** Keywords ***
Setup Browser
    Open Browser          about:blank                 ${BROWSER}
    SetConfig             LineBreak                   ${EMPTY}               #\ue000
    SetConfig             DefaultTimeout              30s                    #sometimes salesforce is slow
    SetConfig             CSSSelectors                False    

End suite
    Close All Browsers


Login
    [Documentation]      Login to Salesforce instance
    GoTo                 ${sf_url}
    TypeText             Username                    ${sf_username}
    TypeSecret           Password                    ${sf_password}
    ClickText            Log In
    Run Keyword If       ${mfa}                      Fill MFA


Fill MFA
    ${mfa_code}=         GetOtp    ${sf_username}   ${sf_mfa}   ${sf_url}    
    TypeSecret           Verification Code       ${mfa_code}      
    ClickText            Verify 


Home
    GoTo                 ${sf_url}lightning/page/home  
    ${login_status} =    IsText                      To access this page, you have to log in to Salesforce.    2
    Run Keyword If       ${login_status}             Login            
    ClickText            Home
    VerifyTitle          Home | Salesforce

Get Access Token
    Create Session    auth        ${sf_url}
    ${response}=      POST        auth    /services/oauth2/token
    ...               data=grant_type=password
    ...               &client_id=${sf_clientid}
    ...               &client_secret=${sf_clientsecret}
    ...               &username=${sf_username}
    ...               &password=${sf_password}${sf_SECURITY_TOKEN}

    Should Be Equal As Integers           ${response.status_code}    200
    Set Suite Variable                    ${ACCESS_TOOKEN}           ${response.json()['access_token']}
