/**
 * Created/Modified By: Girikon(Pramod)
 * Created On:          10/25/2017
 * Description/Purpose: This class provides following functionalities:
 *                      Get Freeman SSO url from custom settings
 *                      Allow login to valid user (with or without event code) else show proper error message
 *                      Allow valid user to put the request for new password.
 * Methods:             sso_record, getEncodeValue
 * Test Class:          SSO_FreemanCtrl_Test
**/

public class SSO_FreemanCtrl
{
    public string strFreemanUrl{get; set;}
    public SSOWrap oSSOWrap{get;set;}
    
    //Freeman SSO url from custom settings in class constructor
    public SSO_FreemanCtrl()
    {
          /*IntegrationUrls__c oIntegrationURL = IntegrationUrls__c.getValues('URL'); 
        strFreemanUrl= String.valueOf(oIntegrationURL.Freeman_Url__c); //Getting Freeman Url
        oSSOWrap = new SSOWrap();*/
        
        string freemanshowid= ApexPages.currentPage().getParameters().get('freemanshowid');
        if(String.isNotBlank(freemanshowid))
        {
            List<Event_Settings__c> eventSettings=[Select Freeman_Redirect_Url__c FROM Event_Settings__c Where Event_Settings__c.Event_Edition__r.Freeman_Show_ID__c=:Decimal.ValueOf(freemanshowid) Limit 1];
            if(!eventSettings.IsEmpty() && eventSettings[0].Freeman_Redirect_Url__c !=null)
                strFreemanUrl=eventSettings[0].Freeman_Redirect_Url__c;
            oSSOWrap = new SSOWrap();
        }
        if(String.isBlank(strFreemanUrl))
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Freeman redirect url doesn\'t exist.'));        
    }
    public class SSOWrap
    {
        public String ssoId{get;set;}
        public String email{get;set;}
        public String showId{get;set;}
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String phoneNumber{get;set;}
        public String phoneExtension{get;set;}
        public SSOWrap()
        {
            //Test data setup
            /*ssoId ='776101';
            email ='test.customer@freemanco.com';
            showId ='242051';
            firstName ='John';
            lastName='Doe';
            phoneNumber ='2147589685';*/
            ssoId ='';
            email ='';
            showId ='';
            firstName ='';
            lastName='';
            phoneNumber ='';
            phoneExtension ='';
        }
    }
    //Creating SSO Freeman Data.
    public SSOWrap getSSOData()
    {        
       return oSSOWrap; 
    }
    
    //Getting required data to populate in Frreman HTML fields
    public void sso_record()
    {
        List<User> lstUser = new List<User>([Select ContactId,id FROM User WHERE id=:UserInfo.getUserId()]);
        String sFreemanShowId = ApexPages.currentPage().getParameters().get('freemanshowid').escapeHtml4();
        if(lstUser != null && lstUser.size()>0)
        {
            List<Contact> lstContact = new List<Contact>([SELECT LastName, AccountId, Account.SSO_ID__c, FirstName, Phone, Email FROM Contact WHERE Id=:lstUser[0].ContactId]);
            for(Contact con:lstContact)
            {
                oSSOWrap.lastName=con.LastName;
                if(String.IsNotBlank(con.Account.SSO_ID__c))
                {
                    oSSOWrap.ssoId =con.Account.SSO_ID__c;
                }
                else
                {
                    oSSOWrap.ssoId =getEncodeValue(con.AccountId);
                }
                if(con.Email != null){
                    oSSOWrap.email =con.Email;
                }
                if(String.isNotBlank(sFreemanShowId))
                {
                    oSSOWrap.showId =sFreemanShowId;
                }
                if(con.FirstName != null){
                    oSSOWrap.firstName =con.FirstName;
                }
                if(con.Phone != null){
                    oSSOWrap.phoneNumber =con.Phone.replaceAll('\\D','');
                }
                
                //oSSOWrap.phoneExtension ='';
            } 
        }
    }
    
    //Getting SSO ID from account
    //And if its blank then encrypting account id and updating the same in SSO ID
    public String getEncodeValue(String AccountId){
        String b64Data='';
        if(String.isNotBlank(AccountId))
        {
            try{
                List<Account> lstAccount = new List<Account>([SELECT Id,SSO_ID__c FROM Account WHERE Id =:AccountId LIMIT 1]);
                if(lstAccount != null && lstAccount.size()>0 )
                {
                    Blob encryptedData = Crypto.generateDigest('MD5',Blob.valueOf(AccountId));
                    b64Data = EncodingUtil.base64Encode(encryptedData);
                    lstAccount[0].SSO_ID__c =b64Data;
                    update lstAccount;
                }
            }
            catch(Exception e){
                System.debug('EE ='+e.getMessage()+' LINE :'+e.getLineNumber()); 
            }
            
        }        
        return b64Data;
    }
}