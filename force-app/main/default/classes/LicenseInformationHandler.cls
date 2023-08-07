/* Create Date : 04/04/2018
* Created By : Avinash
* */
public with sharing class LicenseInformationHandler{
    
    public String getAccessToken(Salesforce_Org__c tu){
        
        String clientId = System.Label.OauthConnectedAppClientId;
        String clientsecret = System.Label.OauthConnectedAppClientSecret;
        String URLPrefix='';
        String OrgType = tu.Salesforce_Org_Type__c;
        String refresh = tu.RefreshToken__c;
        
        if(OrgType =='Sandbox'){
            URLPrefix ='https://test.salesforce.com';
        }
        else{
            URLPrefix ='https://login.salesforce.com';
        }      
        
        String reqbody = 'client_id='+clientId+'&client_secret='+clientsecret+'&grant_type=refresh_token&refresh_token='+refresh;
        
        HttpRequest req1 = new HttpRequest();    
        //req1.setTimeout(120000);
        req1.setHeader('Accept', 'application/json');
        req1.setHeader('Content-type', 'application/x-www-form-urlencoded');
        
        req1.setBody(reqbody);
        req1.setMethod('POST');
        req1.setEndpoint(URLPrefix+'/services/oauth2/token');
        String response = '';
        jsonWrapper Jsondatawrapper=new jsonWrapper();
        
        try{
            Http h = new Http();
            HttpResponse httpResponse = h.send(req1);
            if (httpResponse.getStatusCode() == 200 ) {  
                response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) ); 
                Jsondatawrapper = (jsonWrapper)JSON.deserialize(response,jsonWrapper.class);
            } else {  
                System.debug(' httpResponse ' + httpResponse.getBody() );  
                throw new CalloutException( httpResponse.getBody() );  
            }  
        } catch( System.Exception e) {  
            System.debug('ERROR: '+ e);  
            throw e;  
        } 
        return Jsondatawrapper.access_token;
    }
    
    public String getToken(Salesforce_Org__c tu){
        
        
        String reqbody = 'grant_type=password'+'&client_id='+tu.ClientKey__c+'&client_secret='+tu.ClientSecret__c+'&username='+tu.User_Name__c+'&password='+tu.PasswordE__c;
        
        Http h = new Http();
        
        HttpRequest tokenRequest = new HttpRequest();
        tokenRequest.setBody(reqbody);
        
        tokenRequest.setMethod('POST');
        tokenRequest.setEndpoint(tu.domain__c + '/services/oauth2/token'); 
        
        HttpResponse tokenResponse;
        deserializeResponse objAuthenticationInfo;
        
        if(test.isrunningtest()){
            tokenResponse = getTestResponse(tokenRequest,'token');
        }
        else{
            tokenResponse = h.send(tokenRequest);        
        }
        
        system.debug('tokenResponse : ' + tokenResponse);        
        System.debug('Body ' + tokenResponse.getBody());        
        
        objAuthenticationInfo =(deserializeResponse)JSON.deserialize(tokenResponse.getbody(), deserializeResponse.class);
        
        system.debug('Body'+ tokenResponse.getbody());
        system.debug('objAuthenticationInfotest'+objAuthenticationInfo);
        system.debug('objAuthenticationInfo'+ objAuthenticationInfo.access_token);
        
        return objAuthenticationInfo.access_token;
    }
    
    public HTTPResponse getTestResponse(HTTPRequest req,String strObj) {
        HttpResponse res = new HttpResponse(); 
        
        if(req.getMethod().contains('POST'))
        {
            if(req.getEndpoint().contains('/services/oauth2/token'))
            {
                res.setBody('{"access_token":"00D28000001OkO8!ARcAQOe8RnFO8mVASOR_QA2u1snuPT.nuOfxVI0VpsuE0l6qkdfzZnlTQ9fobrta_DD_h3TjZx08LqV70A83F39Nq43I8B1q","instance_url":"https://quicksilver-dev-ed.my.salesforce.com","id":"https://login.salesforce.com/id/00D28000001OkO8EAK/00528000003nx4mAAA","token_type":"Bearer","issued_at":"1491893489576","signature":"Py9jEYzcZ7noPaAYO/Sd87uTzPh8UGxn30VZPKQm0Tc="}');
            }
        }
        
        else if(req.getMethod().contains('GET'))
        {
            res.setBody('{"totalSize":4,"done":true,"records":[{"attributes":{"type":"UserLicense","url":"/services/data/v42.0/sobjects/UserLicense/10012000000kApBAAU"},"Id":"'+String.valueof(DateTime.now().getTime())+strObj+'","Name":"Guest User License","Status":"Active","TotalLicenses":25,"UsedLicenses":0}]}');
        }
        res.setStatus('OK');
        res.setStatusCode(200);
        return res;
    }
    
    public String getMonthText(Integer month){
        
        switch on month {
            when 1 {
                return 'January';
            }
            when 2 {
                return 'February';
            }
            when 3 {
                return 'March';
            }
            when 4 {
                return 'April';
            }
            when 5 {
                return 'May';
            }
            when 6 {
                return 'June';
            }
            when 7 {
                return 'July';
            }
            when 8 {
                return 'August';
            }
            when 9 {
                return 'September';
            }
            when 10 {
                return 'October';
            }
            when 11 {
                return 'November';
            }
            when 12 {
                return 'December';
            }
            when else {
                return '';
            }
        }
    }
    public Class deserializeResponse
    {
        public String id;
        public String access_token;
    }
    public class jsonWrapper
    {
        // here rows is the name of field in json this variable should be
        public string access_token ;
    }
    
}