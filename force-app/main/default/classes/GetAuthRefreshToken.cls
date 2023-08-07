/* Create Date : 16/07/2020
* Created By : Himanshu Rana
* */
public with sharing class GetAuthRefreshToken {
    private String INTEGRATION_SERVICE_NAME = 'GetAuthRefreshToken';
    public  String RecordId;
    public GetAuthRefreshToken(ApexPages.StandardController stdController) 
    {
        Salesforce_Org__c org = (Salesforce_Org__c)stdController.getRecord();
        this.RecordId = org.Id;
    }
    
    public  PageReference ReturnAuthToken() {
        String clientId = System.Label.OauthConnectedAppClientId;
        String clientsecret = System.Label.OauthConnectedAppClientSecret;
        String orgInstanceUrl = System.Label.OrgInstanceUrl;
        Salesforce_Org__c saleforceOrgData = [select id,ClientKey__c,Salesforce_Org_Type__c,ClientSecret__c from Salesforce_Org__c where id=:RecordId];
        
        String OrgType = saleforceOrgData.Salesforce_Org_Type__c;
        String redirectionurl = orgInstanceUrl+'/apex/OauthRedirection';
        String URLPrefix='';
        
        if(OrgType =='Sandbox'){
            URLPrefix ='https://test.salesforce.com';
        }
        else{
            URLPrefix ='https://login.salesforce.com';
        }
        String reqbody = URLPrefix+'/services/oauth2/authorize?response_type=code&display=popup&client_id=' + clientId + '&redirect_uri=' + redirectionurl + '&response_type=code&scope=' + encodingUtil.URLEncode('full refresh_token','UTF-8');
        Http h = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setBody(reqbody);
        req1.setMethod('GET');
        
        req1.setEndpoint(URLPrefix+'/services/oauth2/authorize');
        HttpResponse res = h.send(req1);
        String location = '';
        if(res.getStatusCode() == 302){
            location = res.getHeader('Location');
        }
        PageReference pageRef = new PageReference(location);
        
        //fetches or creates a Custom Setting at the organization level 
        try{
            AuthTempData__c setting = AuthTempData__c.getOrgDefaults();
            setting.SalesforceOrg_RecordId__c = RecordId;
            upsert setting;
        }
        catch(exception e){
            insert new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = INTEGRATION_SERVICE_NAME, Description__c = e.getMessage() + ' ' + e.getStackTraceString());
            System.debug(LoggingLevel.ERROR, 'error: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
        return pageRef;
        
    }
}