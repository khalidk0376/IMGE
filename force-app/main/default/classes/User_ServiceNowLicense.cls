/**************************************************************************
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2016-10-31
** Modified by Jeff Lup - 2015.06.29 - CHG0067072 - exclude Chatter External Users 
** Modified by Hailey Niemand - 31/10/2019 - Amendments of P1 SCA violations
***************************************************************************/
public  class User_ServiceNowLicense 
{
    public static boolean inFuture = false;
    public ServiceNowUtils snu = new ServiceNowUtils();
    
    public String snApiBase64Encoding = null;
    public String snOrgIndentifier = null;
    public String snUserDivisionFilter = null;
    public String snOrgWideEmailId = null;
    public String snEmails = 'Do_Not_Reply.SFDC@informausa.com';
    public Map<String,String> salesforceLic = new Map<String,String>();
    
    public User_ServiceNowLicense()
    { 
        if(snApiBase64Encoding == null || salesforceLic == null)
        {
            List<Setting_Item__c>  settingItems= [SELECT Id,Setting__c,Setting__r.Name,Encrypted_1__c,Text_1__c,Text_2__c,Text_3__c,Text_4__c,Text_5__c,Text_6__c,Text_7__c FROM Setting_Item__c WHERE Setting__r.Name LIKE 'ServiceNow -%'];
            for(Setting_Item__c si : settingItems)
            {  
                if(si.Setting__r.Name == 'ServiceNow - Setup')
                {
                    snApiBase64Encoding =si.Text_2__c;
                    snOrgIndentifier = si.Text_3__c;
                    snUserDivisionFilter = si.Text_4__c;
                    snOrgWideEmailId = si.Text_6__c;
                    snEmails += ';' + si.Text_5__c;
                    System.debug('####snApiBase64Encoding='+ snApiBase64Encoding);
                }
                
                if(si.Setting__r.Name == 'ServiceNow - Licensing')
                {
                    salesforceLic.put(si.Text_2__c.toLowerCase(), si.Text_1__c);
                    System.debug('####salesforceLic('+ si.Text_2__c.toLowerCase() + ',' + si.Text_1__c + ')');
                }
            }
        }
    }
    
    public void GetValidateUser(List<User> usersNew, List<User> usersOld)
    {
        Boolean isSandbox = snu.org.IsSandbox;
        
        system.debug('####Org Name:' + system.UserInfo.getOrganizationName());
        system.debug('####Org Id:' + system.UserInfo.getOrganizationId());
        system.debug('####Org Url:' + system.Url.getSalesforceBaseUrl());

        set<string> userSFADUsername = new set<string>();
        list<User> u = new list<User>();
 		
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Chatter External User' LIMIT 1].Id; //querying for Profile Id to remove hardcoded Id in line 106
        
        //Get au information and nullify not active users fedid
        for (Integer i=0;i<usersNew.size();i++) 
        {
            system.debug('####New ' + usersNew[i].Id + ' LightningExperiencePreferred:' + usersNew[i].UserPreferencesLightningExperiencePreferred);
            if (usersOld != null && usersOld.size() > 0) system.debug('####Old ' + usersOld[i].Id + ' LightningExperiencePreferred:' + usersOld[i].UserPreferencesLightningExperiencePreferred);

            if (usersNew[i].ProfileId != profileId) { //Don't perform for Chatter External Users - CHG0067072
                //Get AU to match with servicenow
                if(usersNew[i].isActive && usersNew[i].Active_Directory_Username__c != Null)
                {
                    userSFADUsername.add(usersNew[i].Name_for_Service_Now__c.toLowerCase());
                }
                if(!usersNew[i].isActive && usersNew[i].FederationIdentifier !=null)//Clear out FedId
                {
                     u.add(new user(Id=usersNew[i].Id,FederationIdentifier=null));
                }
            }                
        }
        system.debug('####userSFADUsername.size():' + userSFADUsername.size());
        
        if (userSFADUsername.size()>0)
        {
            //Get Service Now AD Details
            List<Active_Directory_Details__c> adDetails =[SELECT Id, USER_Name__c, sys_id__c,u_office_365__c FROM Active_Directory_Details__c WHERE USER_Name__c IN : userSFADUsername];
            system.debug('####adDetails.Size():' + adDetails.Size());
            
            Map<String,String> userSNSysId = new Map<String,String>();
            Map<String,String> userSNFedId = new Map<String,String>();
            //Map ServiceNow Id and Fed Id for lookups
            for (Active_Directory_Details__c adMatch: adDetails)
            {
                userSNSysId.put(adMatch.USER_Name__c.toLowerCase(),adMatch.sys_id__c);
                userSNFedId.put(adMatch.USER_Name__c.toLowerCase(),adMatch.u_office_365__c);
            }
            system.debug('####userSNSysId.Size():' + userSNSysId.Size());

            //Loop through user list to avalidate fedid
            for (Integer i=0;i<usersNew.size();i++) 
            {
                if (usersOld == null || usersOld.size() == 0 || !(usersOld[i].UserPreferencesLightningExperiencePreferred == true && usersNew[i].UserPreferencesLightningExperiencePreferred == false))//Fix for Lighting
                {
                    if (usersNew[i].ProfileId != profileId ) { //Don't perform for Chatter External Users - CHG0067072
                        if (usersNew[i].isActive)
                        {
                            if(usersNew[i].FederationIdentifier == null && userSNSysId.get(usersNew[i].Name_for_Service_Now__c.toLowerCase()) != null)// no existing fed id and one was found in AD.
                            {
                                u.add(new user(Id=usersNew[i].Id, FederationIdentifier=userSNFedId.get(usersNew[i].Name_for_Service_Now__c.toLowerCase())));
                            }
                            else if (userSNSysId.get(usersNew[i].Name_for_Service_Now__c.toLowerCase()) == null)// Validation... no match in AD
                            {
                                system.debug('#### Please add/fix your Active Directory information.');
                                
                                if(!isSandbox && !Test.isRunningTest())usersNew[i].addError('Please add/fix your Active Directory information.' );  
                            }
                            else if (usersNew[i].FederationIdentifier == null )// Validation... No fed id can be found
                            {
                                system.debug('#### Please contact your Salesforce Administrator. The user is missing an Active Directory Federation Id and won’t be able to login until it has been resolved.' );
                                if(!isSandbox && !Test.isRunningTest())usersNew[i].addError('Please contact your Salesforce Administrator. The user is missing an Active Directory Federation Id and won’t be able to login until it has been resolved.');
                            }
                        }
                    }
				}                    
            }
        }
        
       if (u.size()>0)
       {
         Update u;
       }
    }

    public void ServiceNowDeleteAllSalesforceUserLicense(String lic)
    {
          String snDeleteQuery = '{"sysparm_query":"license='+ lic +'^reason=SFDC ORG: ' + snOrgIndentifier+'"}';
          system.debug('####snDeleteQuery:' + snDeleteQuery); 
          
          String snURLLicDelete = 'slm_license_usage_sys_user_m2m.do?JSONv2&sysparm_action=deleteMultiple';//deleteMultiple deleteRecord
          
          if(!Test.isRunningTest())
                {HttpResponse snDeleteResponse = snu.ServiceNowRequest(snURLLicDelete, 'POST',snDeleteQuery ,'json'); 
                 system.debug('####snDeleteResponse.getBody() =' + snDeleteResponse.getBody());}
    }
    
    public String GetSNLicQueryString()
    {
        String snLicQuery=''; 
        //SET<String> snLicIds = new SET<String>();
        List<String> snLicIds = salesforceLic.values();
        
        for (String snLicId: snLicIds)
        {
            String qLic = 'license='+ snLicId ;
            if (snLicQuery=='')
            {
                snLicQuery= qLic;
            }
            else
            {
                snLicQuery= snLicQuery + '^OR' + qLic;
            }
        }
            
         return snLicQuery;
    }
    
    public String TestLicUserJson()
    {
        String x = '{"records":[';
        Integer counter= 0;
        LIst<User> newUsers = [SELECT Id, Username, Active_Directory_Username__c,Active_Directory_OU__c, isActive, Name_for_Service_Now__c,License_Type__c, ServiceNow_Lic_Id__c, FederationIdentifier  FROM USER WHERE isactive = true order by SystemModstamp DESC LIMIT 15];
        for (User u: newUsers)
        {counter +=1;
        x=x + '{"compliant":"true","license":"7afff7dd25f528c49634b1d7d09b5455","reason":"SFDC ORG: ' + snOrgIndentifier + '","sys_created_by":"wsdl.soap","sys_created_on":"2013-04-04 19:48:41","sys_id":"9abeef9ddc200d40688fa3dbef039a93","sys_mod_count":"0","sys_updated_by":"wsdl.soap","sys_updated_on":"2013-04-04 19:48:41","u_revoked":"false","u_note":"' + u.Id + '; '+ u.Active_Directory_OU__c +'\\\\'+ u.Active_Directory_Username__c +'; ' + u.Username + '","user":"4c0bb1a60a0aa01101898f65df0427e7"}';
            if (counter != newUsers.size())x += ',';
        }
        x = x + ']}';
        System.debug(x);
        return x;
     }
    
    public class snLicResponse {  
    public String license{ get; set; }
    public String user{ get; set; }
    public String sys_id{ get; set; }
    public String u_note{ get; set; }    
    public String reason{ get; set; }
    }
}

/**
    public static String TestLicUserXML()
    {
        String x = '<?xml version="1.0" encoding="UTF-8"?><xml>';
        
        //for (Integer i = 0; i < 5; i++) { 
        x=x + '<slm_license_usage_sys_user_m2m><compliant>true</compliant><license>e5010fc925f1a4c49634b1d7d09b54df</license><reason>test insert from Salesforce - salesforceChatterFree</reason><sys_created_by>wsdl.soap</sys_created_by><sys_created_on>2013-04-04 19:56:27</sys_created_on><sys_id>08bfabdddc200d40688fa3dbef039a02</sys_id><sys_mod_count>0</sys_mod_count><sys_updated_by>wsdl.soap</sys_updated_by><sys_updated_on>2013-04-04 19:56:27</sys_updated_on><u_revoked>false</u_revoked><user>4c0bb1a60a0aa01101898f65df0427e7</user></slm_license_usage_sys_user_m2m>';
        x=x + '<slm_license_usage_sys_user_m2m><compliant>true</compliant><license>7afff7dd25f528c49634b1d7d09b5455</license><reason>005600000011i4QAAQ; nacorplan\\spoonmores</reason><sys_created_by>wsdl.soap</sys_created_by><sys_created_on>2013-04-04 21:26:11</sys_created_on><sys_id>66148c21dc600d40688fa3dbef039a1f</sys_id><sys_mod_count>0</sys_mod_count><sys_updated_by>wsdl.soap</sys_updated_by><sys_updated_on>2013-04-04 21:26:11</sys_updated_on><u_revoked>false</u_revoked><user>4c0bb1a60a0aa01101898f65df0427e7</user></slm_license_usage_sys_user_m2m>';
        x=x + '<slm_license_usage_sys_user_m2m><compliant>true</compliant><license>e5010fc925f1a4c49634b1d7d09b54df</license><reason>test insert from Salesforce - salesforceChatterFree</reason><sys_created_by>wsdl.soap</sys_created_by><sys_created_on>2013-04-04 19:16:09</sys_created_on><sys_id>f19623dddc200d40688fa3dbef039a8a</sys_id><sys_mod_count>0</sys_mod_count><sys_updated_by>wsdl.soap</sys_updated_by><sys_updated_on>2013-04-04 19:16:09</sys_updated_on><u_revoked>false</u_revoked><user>4c0bb1a60a0aa01101898f65df0427e7</user></slm_license_usage_sys_user_m2m>';
        x=x + '';
        
        //}
        x = x + '</xml>';
        System.debug(x);
        return x;
     }
**/
   /***
    @future (callout=true)
    public static void CheckUsersToDelete(SET <String> usersToDeleteSNLic, Map<String,String> userSNSysId)
    {
        //usersToDeleteSNLic.add(newUsers[i].Name_for_Service_Now__c.toLowerCase() + '@@' + newUsers[i].Id);
        //userExistingSNLicId = ADName + Splitter(@@) + SFID = SN License ID
        String snLicQuery= GetSNLicQueryString();
        system.debug('####snLicQuery=' + snLicQuery);    
        
        String snUserQuery='';
        for (String userSN_SfId: usersToDeleteSNLic)
            {
                    String adUser = userSN_SfId.split('@@')[0];
                    String sfId = userSN_SfId.split('@@')[1];
                    String snUserLicId = userSNSysId.get(adUser);
                    
                    system.debug('####adUser=' + adUser + '; sfId=' + sfId + '; snUserLicId=' + snUserLicId);
                    
                    String qUser = 'user='+ snUserLicId ;
                    if (snUserQuery=='')
                    {
                        snUserQuery=  qUser ;
                    }
                    else
                    {
                        snUserQuery= snUserQuery + '^OR' + qUser ;
                    }
                    
                    
            }
            
          system.debug('####snUserQuery=' + snUserQuery);
          
          String snDeleteQuery = '{"sysparm_query":"'+ snUserQuery + '^' + snLicQuery + '"}';
          system.debug('####snDeleteQuery:' + snDeleteQuery); 
          
          String snURLLicDelete = 'slm_license_usage_sys_user_m2m.do?JSON&sysparm_action=deleteMultiple';//deleteMultiple deleteRecord
          
          if(!Test.isRunningTest())
                {HttpResponse snDeleteResponse = ServiceNowUser.ServiceNowRequest(snURLLicDelete, 'POST',snDeleteQuery ,'json'); 
                 system.debug('####snDeleteResponse.getBody() =' + snDeleteResponse.getBody());}
          
            
    }
    
    @future (callout=true)
    public static void CheckUsersToUpdate(SET <String> usersToUpdateSNLic, Map<String,Id> userADtoSF,Map<String,String> userSFLicType, Map<String,String> userExistingSNLicId, Map<String,String> userSNSysId)
    {
        //userSFLicType =  ADName + Splitter(@@) + SFID = License Type
        //userExistingSNLicId = ADName + Splitter(@@) + SFID = SN License ID
        
        //build SN Query
        //String encoded = EncodingUtil.urlEncode(url,'UTF-8');
        String snLicQuery= '';
        String snExistingSysIds = '';
        for (String userSN_SfId: usersToUpdateSNLic)
           {
            
            //system.debug('####userSN_SfId.split(\'@@\', 0):' + userSN_SfId.split('@@'));
            String adUser = userSN_SfId.split('@@')[0];
            String sfId = userSN_SfId.split('@@')[1];
            String snUserLicId = userSNSysId.get(adUser);
            String snSfExistingLicenseId =  userExistingSNLicId.get( adUser + '@@' + sfId);
            if(snLicQuery== '')
            {snLicQuery= 'user=' + snUserLicId;}
            else
            {snLicQuery=snLicQuery + '^ORuser=' + snUserLicId;}
            
            //if (snSfExistingLicenseId != null) 
            //{
            //  if(snExistingSysIds == '')
            //  {snExistingSysIds = 'sys_id=' + snSfExistingLicenseId}
            //  else
            //  {
                //  snExistingSysIds = snExistingSysIds + '^ORsys_id=' + snSfExistingLicenseId
            //  }
            //}
            
            
           }
           
          //Build SN query 
          //snLicQuery = snLicQuery + '^license='+ ServiceNowUser.salesforceCRM +'^ORlicense=' + ServiceNowUser.salesforceOneApp ;//+ '^' + snExistingSysIds ; 
          snLicQuery = snLicQuery + '^' + GetSNLicQueryString();
     
          system.debug('####snLicQuery:' + snLicQuery); 
          //Encode the query
          snLicQuery = 'slm_license_usage_sys_user_m2m.do?XML&sysparm_query='  + EncodingUtil.urlEncode(snLicQuery,'UTF-8');
          system.debug('####snLicQueryEncode:' + snLicQuery);
          
          //Make SN Query
        Dom.Document doc = new Dom.Document();
        System.debug('##2Test.isRunningTest()='+ Test.isRunningTest());
        if(Test.isRunningTest())
        { 
            doc.load(TestLicUserXML());
        }
        else
        {
            HttpResponse response = ServiceNowUser.ServiceNowRequest(snLicQuery, 'GET', null, null);
            doc = response.getBodyDocument();
        }
        
        Dom.XMLNode xml = doc.getRootElement();
        LIST<Dom.Xmlnode> snGetExistingUserLic = xml.getChildElements();
        MAP<String,String> snExistingUsersLic = new MAp<String,String>();
        
            for(Dom.XMLNode child : snGetExistingUserLic) 
            { 
                String snUserId = child.getChildElement('user', null).getText();
                String snLicenseId = child.getChildElement('license', null).getText();
                String snSysId = child.getChildElement('sys_id', null).getText();
                
                snExistingUsersLic.put(snUserId + '@@' + snLicenseId, snSysId);
            
            }
          
        //build sn update
        String snCreateLicBody= ''; 
        String snDeleteLicBody= '';  
        for (String userSN_SfId: usersToUpdateSNLic)
           {
            
            
            String adUser = userSN_SfId.split('@@')[0];
            String sfId = userSN_SfId.split('@@')[1];
            String snUserId = userSNSysId.get(adUser);
            
            String snLicenseId ='';
            if (ServiceNowUser.salesforceLic.get(userSFLicType.get( adUser + '@@' + sfId)) != null)
            {snLicenseId =  ServiceNowUser.salesforceLic.get(userSFLicType.get( adUser + '@@' + sfId).tolowercase());}
            
            String snSfExistingLicId =  userExistingSNLicId.get( adUser + '@@' + sfId);
            system.debug('####adUser=' + adUser + '; sfId=' + sfId + '; snUserId=' + snUserId + '; snLicenseId=' + snLicenseId + '; snSfExistingLicId=' + snSfExistingLicId);
            
            //Build new Lic
            //String createLicBody= '';
            if (!snExistingUsersLic.containsKey(snUserId + '@@' + snLicenseId) )
            {
                 
                system.debug('####UPDATE SF USER WITH SN LIC:' + sfId + '; snLicenseId=' + snLicenseId);
                system.debug('####CREATE SN LIC RECORD:' + snUserId + '; snLicenseId=' + snLicenseId);
                
                String createLic = '{"compliant":"true", "license":"'+ snLicenseId + '", "user":"' + snUserId   +'", "reason":"'+ sfId + '; ' + adUser.replace('\\', '\\\\') + '" }';
                //String createLic = '<slm_license_usage_sys_user_m2m><compliant>true</compliant><license>'+ snLicenseId + '</license><reason>'+ sfId + '; ' + adUser.replace('\\', '\\\\') + '</reason><user>' + snUserId   +'</user></slm_license_usage_sys_user_m2m>';
                IF(snCreateLicBody== '')
                {
                    snCreateLicBody=createLic ;
                }
                else
                {
                    snCreateLicBody = snCreateLicBody + ', ' + createLic ;
                    
                }
            
            }
            
        
            //Build Old Lic to delete
            if (snSfExistingLicId != null && snExistingUsersLic.get(snUserId + '@@' + snLicenseId) != snSfExistingLicId)
            {
                system.debug('####DELETE SN LIC RECORD: snSfExistingLicId =' + snSfExistingLicId);
                //String deleteLic = '{"sysparm_sys_id":"'+ snSfExistingLicId +'x"}, {"sysparm_sys_id":"'+ snSfExistingLicId +'"}';
                //String deleteLic = '{"sysparm_query":"sys_id='+ snSfExistingLicId +'x"},{"sysparm_query":"sys_id='+ snSfExistingLicId +'"}';
                String deleteLic = 'sys_id='+ snSfExistingLicId ;
                IF(snDeleteLicBody== '')
                {
                    snDeleteLicBody=deleteLic ;
                }
                else
                {
                    //snDeleteLicBody = snDeleteLicBody + ' ,' + deleteLic ;
                    snDeleteLicBody = snDeleteLicBody + '^OR'+ deleteLic ;
                }
                 
            }
            
           } 
            
           
           List<User> updateUsers = new List<User>();
           system.debug('####snCreateLicBody =' + snCreateLicBody);
           system.debug('####snDeleteLicBody =' + snDeleteLicBody);
           
           
            //Delete old SN Lic
           if(snDeleteLicBody != '')
           {
            //EncodingUtil.urlEncode(snDeleteLicBody,'UTF-8')
            snDeleteLicBody = '{"sysparm_query":"' + snDeleteLicBody + '"}';//EncodingUtil.urlEncode(,'UTF-8')
            system.debug('####snDeleteLicBody =' + snDeleteLicBody);
            String snLicDelete = 'slm_license_usage_sys_user_m2m.do?JSON&sysparm_action=deleteMultiple';//deleteMultiple deleteRecord
            //HttpResponse snDeleteResponse = ServiceNowUser.ServiceNowRequest(snLicDelete, 'POST','{"records":[' + snDeleteLicBody  +']}','json'); 
            
            if(!Test.isRunningTest())
                {
            HttpResponse snDeleteResponse = ServiceNowUser.ServiceNowRequest(snLicDelete, 'POST',snDeleteLicBody ,'json'); 
            system.debug('####snDeleteResponse.getBody() =' + snDeleteResponse.getBody()); 
                }
           } 
           
           //**
           //Create SN LIc
           if(snCreateLicBody != '')
           {
            
            JSONParser parser ;
            System.debug('##2Test.isRunningTest()='+ Test.isRunningTest());
            if(Test.isRunningTest())
                { 
                    parser  = JSON.createParser(TestLicUserJson());
                }
            else
                {
                    //SAMPLE RESPONSE: ={"records":[{"compliant":"true","license":"76a8a6ca5542948096348ccfdc7a89c0","reason":"00530000000taxnAAA nacorplan\\spoonmores","sys_created_by":"wsdl.soap","sys_created_on":"2013-04-02 22:16:07","sys_id":"52fc717cdc6cc940688fa3dbef039aff","sys_mod_count":"0","sys_updated_by":"wsdl.soap","sys_updated_on":"2013-04-02 22:16:07","u_revoked":"false","user":"4c0bb1a60a0aa01101898f65df0427e7"}]}
            
                    String snLicInsert = 'slm_license_usage_sys_user_m2m.do?JSON&sysparm_action=insert';
                    HttpResponse snInsertResponse = ServiceNowUser.ServiceNowRequest(snLicInsert, 'POST','{"records":[' + snCreateLicBody +']}','json');
                    //String snLicInsert = 'slm_license_usage_sys_user_m2m.do?XML&sysparm_action=insert';
                    //HttpResponse snInsertResponse = ServiceNowUser.ServiceNowRequest(snLicInsert, 'POST','<?xml version="1.0" encoding="UTF-8"?><xml>' + snCreateLicBody +'</xml>'); 
                    system.debug('####snCreateResponse =' + snInsertResponse .getBody());                       
                    parser = JSON.createParser(snInsertResponse.getBody());
                }
            
            MAP<String,String> snMapNewLicId= New MAP<String,String>();
            while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                        while (parser.nextToken() != null) {
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                snLicResponse snLic = (snLicResponse)parser.readValueAs(snLicResponse.class);
                                system.debug('####snlic.user =' + snlic.user);
                                snMapNewLicId.put(snlic.user+ '@@' + snlic.license, snlic.sys_id);

                                parser.skipChildren();
                            }
                        }
                    }
                }
            
            
            system.debug('####snMapNewLicId.Size() =' + snMapNewLicId.Size()); 
            
            
            //Build Update User
            for (String userSN_SfId: usersToUpdateSNLic)
               {
                
                String adUser = userSN_SfId.split('@@')[0];
                String sfId = userSN_SfId.split('@@')[1];
                String fedId = userSN_SfId.split('@@')[2];
                String snUserId = userSNSysId.get(adUser);
                String snLicenseId = '';
                if (ServiceNowUser.salesforceLic.get(userSFLicType.get( adUser + '@@' + sfId)) != null)
                {
                snLicenseId =  ServiceNowUser.salesforceLic.get(userSFLicType.get( adUser + '@@' + sfId).tolowercase());
                }
                String snSfExistingLicId =  userExistingSNLicId.get( adUser + '@@' + sfId);
                String snNewLicSysId = snMapNewLicId.get(snUserId + '@@' + snLicenseId);
                system.debug('####BuildUpdate####adUser=' + adUser + '; sfId=' + sfId + '; snUserId=' + snUserId + '; snLicenseId=' + snLicenseId + '; snNewLicSysId=' + snNewLicSysId);
                if (snNewLicSysId != null)
                {
                
                    updateUsers.add(new user(Id = sfId,ServiceNow_Lic_Id__c=  snNewLicSysId, FederationIdentifier = fedId));
                }
                
               }
            
            
            
           }
           //**/
          
     /**     
          if (updateUsers.size()>0)
            {
                User_ServiceNowLicense.inFuture = true;
                Update updateUsers;
            }   
        
    }
    **/




/***    
    
    public static void GetValidateUser1(List<User> newUsers, Boolean runTest)
    {
        if ((runTest == false && Test.isRunningTest() ==false) || (runTest))//stops unit test running off of trigger
        {
            
            Map<String,Id> userADtoSF = new Map<String,Id>();
            Map<String,String> userADFedId = new Map<String,String>();
            Map<String,String> userExistingSNLicId = new Map<String,String>();// ADName + Splitter(@@) + SFID = SN License ID
            Map<String,Id> userDeleteSNLicInfo = new Map<String,Id>();
            Map<String,String> userSFLicType = new Map<String,String>();// ADName + Splitter(@@) + SFID = License Type
            set<string> userIsActive = new set<string>();
            set<string> userNotActive = new set<string>();
            set<string> userSFADUsername = new set<string>();
        
        
        for (Integer i=0;i<newUsers.size();i++) 
        {
            //if(newUsers[i].Active_Directory_Username__c == Null)
            //{
            //  newUsers[i].addError('Please Provide Active Directory Information!!');
            //}
            //else if (Trigger.isInsert && newUsers[i].Name_for_Service_Now__c != Null)
            //{
            //  userUpdateSNLicInfo.put( newUsers[i].Name_for_Service_Now__c, newUsers[i].Id);
            //}
            //else 
            
            if(newUsers[i].Active_Directory_Username__c != Null)
            {
                //build mappings to get lic information
                userSFADUsername.add(newUsers[i].Name_for_Service_Now__c.toLowerCase());
                userADFedId.put( newUsers[i].Name_for_Service_Now__c.toLowerCase(), newUsers[i].FederationIdentifier); 
                userADtoSF.put( newUsers[i].Name_for_Service_Now__c.toLowerCase() + '@@' + newUsers[i].Id, newUsers[i].Id);
                userSFLicType.put( newUsers[i].Name_for_Service_Now__c.toLowerCase() + '@@' + newUsers[i].Id, newUsers[i].License_Type__c);//Map AD to SF
                
                if(newUsers[i].isActive)
                {
                    userIsActive.add(newUsers[i].Name_for_Service_Now__c.toLowerCase());
                }
                else
                {
                    userDeleteSNLicInfo.put( newUsers[i].Name_for_Service_Now__c.toLowerCase() + '@@' + newUsers[i].Id, newUsers[i].Id);
                    userNotActive.add(newUsers[i].Name_for_Service_Now__c.toLowerCase());
                }
                
                
                if(newUsers[i].ServiceNow_Lic_Id__c != null)
                {
                    userExistingSNLicId.put(newUsers[i].Name_for_Service_Now__c.toLowerCase() + '@@' + newUsers[i].Id, newUsers[i].ServiceNow_Lic_Id__c);
                }
                
            }
             
            
        }
        
        system.debug('####userSFADUsername.size():' + userSFADUsername.size());
        if (userSFADUsername.size()>0)
        {
            //newUsers[i].Name_for_Service_Now__c.split('\\')[1]
            List<Active_Directory_Details__c> adMatches =[SELECT Id, USER_Name__c, sys_id__c,u_office_365__c FROM Active_Directory_Details__c WHERE USER_Name__c IN : userSFADUsername];
            system.debug('####adMatches.Size():' + adMatches.Size());
            //Identify AD users that dont exist
            Map<String,String> userSNSysId = new Map<String,String>();
            Map<String,String> userSNFedId = new Map<String,String>();
            set<string> userNotInAD = new set<string>();
            set<string> userNotFedId = new set<string>();
            set<string> userNotActiveNoAD = new set<string>();
            
            //Get ServiceNow Id
            for (Active_Directory_Details__c adMatch: adMatches)
            {
                userSNSysId.put(adMatch.USER_Name__c.toLowerCase(),adMatch.sys_id__c);
                userSNFedId.put(adMatch.USER_Name__c.toLowerCase(),adMatch.u_office_365__c);
            }
            system.debug('####userSNSysId.Size():' + userSNSysId.Size());
            //Get users not in active directory
            for (String x: userIsActive)
            {
                If(!userSNSysId.containsKey(x.toLowerCase()))
                {
                    userNotInAD.add(x.toLowerCase());
                }else if ((userADFedId.get(x.toLowerCase()) == null || userADFedId.get(x.toLowerCase()).Trim().length() == 0) 
                            && (userSNFedId.get(x.toLowerCase()) == null || userSNFedId.get(x.toLowerCase()).Trim().length() == 0))
                {
                    userNotFedId.add(x.toLowerCase());
                }
            }
            
            //get users not in AD and not active
            for (String x: userNotActive)
            {
                If(!userSNSysId.containsKey(x.toLowerCase()))
                {
                    userNotActiveNoAD.add(x.toLowerCase());
                }
            }
            
            system.debug('####userNotInAD.Size():' + userNotInAD.Size());
            //Error out active users that dont have AD and rebuild lists that need to be checked against SN
            SET <String> usersToUpdateSNLic = new SET <String> ();
            SET <String> usersToDeleteSNLic = new SET <String> ();
            
            
            for (Integer i=0;i<newUsers.size();i++) 
            {
                if(newUsers[i].Active_Directory_Username__c != Null)
                {   
                    if(userNotInAD.contains(newUsers[i].Name_for_Service_Now__c.toLowerCase()))
                    {
                           newUsers[i].addError('Please add/fix your Active Directory information.');
                    }
                    else if (userNotFedId.contains(newUsers[i].Name_for_Service_Now__c.toLowerCase()))
                    {
                        newUsers[i].addError('Please contact your Salesforce Administrator. The user is missing an Active Directory Federation Id and won’t be able to login until it has been resolved.');
                    }
                    else if(newUsers[i].isActive)
                    {
                        String fedId = String.ValueOf(userADFedId.get(newUsers[i].Name_for_Service_Now__c.toLowerCase())) ;
                        if (fedId == null || fedId.Trim().length() == 0 )
                        {
                            fedId = String.ValueOf(userSNFedId.get(newUsers[i].Name_for_Service_Now__c.toLowerCase()));
                        }
                        
                        
                        usersToUpdateSNLic.add(newUsers[i].Name_for_Service_Now__c.toLowerCase() + '@@' + newUsers[i].Id + '@@' + fedId);
                    }
                    else if(!newUsers[i].isActive && !userNotActiveNoAD.contains(newUsers[i].Name_for_Service_Now__c.toLowerCase()))
                    {
                        usersToDeleteSNLic.add(newUsers[i].Name_for_Service_Now__c.toLowerCase() + '@@' + newUsers[i].Id);
                    }
                }
            }
            
            //Call ServiceNow for licensing
            //SETs usersToUpdateSNLic,usersToDeleteSNLic,
            //Maps userADtoSF, userSFLicType, userDeleteSNLicInfo,userExistingSNLicId, userSNSysId
            if(usersToUpdateSNLic.size()>0)
            {
                CheckUsersToUpdate(usersToUpdateSNLic, userADtoSF,userSFLicType, userExistingSNLicId, userSNSysId);
            }
            
            if(usersToDeleteSNLic.size()>0)
            {
                CheckUsersToDelete(usersToDeleteSNLic, userSNSysId);
            }
            
            
        }
        
        }
        
        
        
        
        
    }
    **/