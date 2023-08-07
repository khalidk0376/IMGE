/* Create Date : 16/07/2020
* Created By : Himanshu Rana
* */

public with sharing class OauthRedirectionCtrl {
    public String  authId {get;set;}
    public OauthRedirectionCtrl(){
        authId = ApexPages.currentPage().getParameters().get('code'); 
    }
    
    public PageReference RedirectBack(){
        // fetch org id from custom setting
        String orgInstanceUrl = System.Label.OrgInstanceUrl;
        String orgRecordId = [select name ,SalesforceOrg_RecordId__c from AuthTempData__c].SalesforceOrg_RecordId__c;
        Salesforce_Org__c org = new Salesforce_Org__c();
        org = [select id,name,AuthId__c,Salesforce_Org_Type__c,Instance_URL__c from Salesforce_Org__c  where id=:orgRecordId];
        
        jsonWrapper wrapperResponse = new jsonWrapper();
        wrapperResponse=ReturnAccessToken(org,authId);
        
        // update Salesforce Org Authid Field
        org.AuthId__c = authId;
        org.AccessToken__c =wrapperResponse.access_token;
        org.RefreshToken__c=wrapperResponse.refresh_token;
        org.domain__c = wrapperResponse.instance_url;
        update org;
        
        String redirectionUrl = orgInstanceUrl+'/'+org.id;
        PageReference pageRedirect = new PageReference(redirectionUrl);
        pageRedirect.setRedirect(false);
        return pageRedirect;
      
    }
    public jsonWrapper ReturnAccessToken(Salesforce_Org__c tu,string authorizationCode){
        
        String clientId = System.Label.OauthConnectedAppClientId;
        String clientsecret = System.Label.OauthConnectedAppClientSecret;
        String orgInstanceUrl = System.Label.OrgInstanceUrl;
        string redirectionurl = orgInstanceUrl+'/apex/OauthRedirection';
        String reqbody ='client_id='+clientId+'&client_secret='+clientsecret+'&grant_type=authorization_code&code='+authorizationCode+'&redirect_uri='+redirectionurl;
        
        String URLPrefix='';
        String OrgType = tu.Salesforce_Org_Type__c;
        if(OrgType =='Sandbox'){
            URLPrefix ='https://test.salesforce.com';
        }
        else{
            URLPrefix ='https://login.salesforce.com';
        }
        System.debug('URLPrefix  '+URLPrefix);
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
                System.debug('aaa'+ Jsondatawrapper);
                
                String name =Jsondatawrapper.instance_url.substringAfter('//');
                name=name.substringBefore('.');
                List<String> res = name.split('-');
                String domainName='';
                for(integer i=0;i<res.size();i++){
                    domainName=domainName+res.get(i)+'_';
                }
                domainName = domainName+'LicenseApp';
            } else {  
                System.debug(' httpResponse ' + httpResponse.getBody() );  
                throw new CalloutException( httpResponse.getBody() );  
            }  
        } catch( System.Exception e) {  
            System.debug('ERROR: '+ e);  
            throw e;  
        } 
        System.debug(' ** response ** : ' + response );  
        
        return Jsondatawrapper;
    }
    
    public   class jsonWrapper
    {
        public string access_token ;
        public string refresh_token;
        public string instance_url ; 
    }
    
}