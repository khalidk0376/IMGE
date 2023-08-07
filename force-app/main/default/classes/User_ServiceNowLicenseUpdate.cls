/**************************************************************************
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2016-10-31 
** Set<Id> batchProcessIds = new Set<Id>();
** User_ServiceNowLicenseUpdate x = new User_ServiceNowLicenseUpdate();
** batchProcessIds.add(Database.executeBatch(x)); 
***************************************************************************/
global class User_ServiceNowLicenseUpdate implements Database.Batchable<Sobject>, Database.AllowsCallouts
{
	public Boolean isTesting;
	
    
	global database.querylocator start(Database.BatchableContext BC)  
	{ 
		//Delete Licensing
		User_ServiceNowLicense usnl = new User_ServiceNowLicense();

		Set<String> snLicIds = usnl.salesforceLic.keySet();
    	String userLic = '';
    	Integer counter = 0;
        //#####NOTE: 2016-04-06 Delete all SFDC Licensing in SN before implementing
    	for (String snLicId: snLicIds)
	    {
	        counter += 1;
	        system.debug('####Delete snLicId:' + snLicId);
	        userLic += '\'' + snLicId + '\'';
			usnl.ServiceNowDeleteAllSalesforceUserLicense(usnl.salesforceLic.get(snLicId)); 
				
			if (counter != snLicIds.size()) userLic +=',';
	    }
		
		String query; 
		system.debug('####userLic:' + userLic);
		query='SELECT Active_Directory_OU__c,Active_Directory_Username__c,FederationIdentifier,Id,IsActive,License_Type__c,Name_for_Service_Now__c,ServiceNow_Lic_Id__c, SystemModstamp, Username FROM User Where (FederationIdentifier != null OR Active_Directory_Username__c != null) AND License_Type__c in ('+ userLic +')';// WHERE ProfileId = \'00e30000000guhi\' LIMIT 400
        //Testing-----query='SELECT Active_Directory_OU__c,Active_Directory_Username__c,FederationIdentifier,Id,IsActive,License_Type__c,Name_for_Service_Now__c,ServiceNow_Lic_Id__c, SystemModstamp, Username FROM User Where (Active_Directory_Username__c = \'spoonmores\') AND License_Type__c in ('+ userLic +')';// WHERE ProfileId = \'00e30000000guhi\' LIMIT 400		 
		if(Test.isRunningTest()) query += 'order by SystemModstamp Desc LIMIT 25';
	
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
        
        ServiceNowUtils snu = new ServiceNowUtils();//Licensing and API Info
        User_ServiceNowLicense usnl = new User_ServiceNowLicense();
		User_ServiceNowLicense.inFuture= true;
		List<User> Users= (List<User>) scope;
		List<User> userUpdate = new List<User>();
		
		//Get matched AD
		set<string> userSFADUsername = new set<string>();
		
		for(User user : Users)
		{
			
			if(user.isActive && user.Active_Directory_Username__c != Null)
	        {
	        	userSFADUsername.add(user.Name_for_Service_Now__c.toLowerCase());
	        }
	        else if((!user.isActive && user.FederationIdentifier != null) || (!user.isActive && user.Active_Directory_Username__c != null)) // clean up none active users
			{
				
				userUpdate.add(new User(Id=user.Id, FederationIdentifier = null, Active_Directory_Username__c = null ));
			}
			
		}
		
		
		if (userSFADUsername.size()>0)
	    {
	    	
	    	//Get Service Now AD Details
	        List<Active_Directory_Details__c> adDetails =[SELECT Id, USER_Name__c, sys_id__c,u_office_365__c FROM Active_Directory_Details__c WHERE USER_Name__c IN : userSFADUsername];
	        system.debug('####adDetails.Size():' + adDetails.Size());
	        
	        Map<String,String> userSNSysId = new Map<String,String>();
	        Map<String,String> userSNFedId = new Map<String,String>();
	        //String snLicQuery= '';
	        //Map ServiceNow Id and Fed Id for lookups and SN Query
	        for (Active_Directory_Details__c adMatch: adDetails)
	        {
	            userSNSysId.put(adMatch.USER_Name__c.toLowerCase(),adMatch.sys_id__c);
	            userSNFedId.put(adMatch.USER_Name__c.toLowerCase(),adMatch.u_office_365__c);
	            
	            //if(snLicQuery== '')
	       		//{snLicQuery= 'user=' + adMatch.sys_id__c;}
	       		//else
	       		//{snLicQuery=snLicQuery + '^ORuser=' + adMatch.sys_id__c;}
	            
	        }
	        
	        String snCreateLicBody= ''; 
	        
	        for(User user : Users)
			{
				String servicenowUserId = userSNSysId.get(user.Name_for_Service_Now__c.toLowerCase());
				System.debug('####servicenowUserId='+ servicenowUserId);
                
				
				
				if (user.isActive && servicenowUserId != null && servicenowUserId.Trim().Length() > 0)
				{
					String au = user.Name_for_Service_Now__c;
					String createLic = '{"compliant":"true", "license":"'+ usnl.salesforceLic.get(user.License_Type__c.toLowerCase()) + '", "user":"' + servicenowUserId  +'", "reason":"SFDC ORG: ' + usnl.snOrgIndentifier + '" , "u_note":"'+ user.Id + '; SFDC ORG: ' + usnl.snOrgIndentifier + '(' + System.UserInfo.getOrganizationName()+ ': '+ System.UserInfo.getOrganizationId() + '); '+ au.replace('\\', '\\\\') + '; '+ user.Username + '; '+ URL.getSalesforceBaseUrl().getHost()+'"}';
	       			System.debug('####createLic='+ createLic);
	       		//String createLic = '<slm_license_usage_sys_user_m2m><compliant>true</compliant><license>'+ snLicenseId + '</license><reason>'+ sfId + '; ' + adUser.replace('\\', '\\\\') + '</reason><user>' + snUserId   +'</user></slm_license_usage_sys_user_m2m>';
		       		if(snCreateLicBody== '')
		       		{
		       			snCreateLicBody=createLic;
		       		}
		       		else
		       		{
		       			snCreateLicBody = snCreateLicBody + ', ' + createLic ;
		       			
		       		}
					
				}
				
				
				
			}
	        
	       
	       System.debug('####snCreateLicBody='+ snCreateLicBody);
	       
	          //Create SN LIc
	       if(snCreateLicBody != '')
	       {
	       	
	       	JSONParser parser ;
	       	System.debug('##2Test.isRunningTest()='+ Test.isRunningTest());
        	if(Test.isRunningTest())
        		{ 
	       			parser	= JSON.createParser(usnl.TestLicUserJson());
        		}
	       	else
	       		{
	       			//SAMPLE RESPONSE: ={"records":[{"compliant":"true","license":"76a8a6ca5542948096348ccfdc7a89c0","reason":"00530000000taxnAAA nacorplan\\spoonmores","sys_created_by":"wsdl.soap","sys_created_on":"2013-04-02 22:16:07","sys_id":"52fc717cdc6cc940688fa3dbef039aff","sys_mod_count":"0","sys_updated_by":"wsdl.soap","sys_updated_on":"2013-04-02 22:16:07","u_revoked":"false","user":"4c0bb1a60a0aa01101898f65df0427e7"}]}
	       	
	       			String snLicInsert = 'slm_license_usage_sys_user_m2m.do?JSONv2&sysparm_action=insert';
	       			HttpResponse snInsertResponse = snu.ServiceNowRequest(snLicInsert, 'POST','{"records":[' + snCreateLicBody +']}','json');
	       			//String snLicInsert = 'slm_license_usage_sys_user_m2m.do?XML&sysparm_action=insert';
	       			//HttpResponse snInsertResponse = ServiceNowUser.ServiceNowRequest(snLicInsert, 'POST','<?xml version="1.0" encoding="UTF-8"?><xml>' + snCreateLicBody +'</xml>'); 
	       			system.debug('####snCreateResponse =' + snInsertResponse .getBody());                       
        	 		parser = JSON.createParser(snInsertResponse.getBody());
	       		}
        	
        	//MAP<String,String> snMapNewLicId= New MAP<String,String>();
        	
        	while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                        while (parser.nextToken() != null) {
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                User_ServiceNowLicense.snLicResponse snLic = (User_ServiceNowLicense.snLicResponse)parser.readValueAs(User_ServiceNowLicense.snLicResponse.class);
                                system.debug('####snlic.user =' + snlic.user);
                                ///snMapNewLicId.put(snlic.user+ '@@' + snlic.license, snlic.sys_id);
                                system.debug('####snlic.u_note =' + snlic.u_note);
                                
                                string userId = snLic.u_note.split(';')[0];
                                system.debug('####snLic.reason =' + snLic.reason);
                                if (userId != null && userId.Trim().Length() > 0)
                                {
                                	system.debug('####userId =' + userId);
                                userUpdate.add(new User(Id=userId,ServiceNow_Lic_Id__c=snLic.license));
                                }
								
								
                                parser.skipChildren();
                            }
                        }
                    }
                }
        	
	       }
	       
	    }
		
		
		if(userUpdate.Size() >0)
        {
        	if(Test.isRunningTest())
        	{ 
        	for(User u : userUpdate)
			{
				system.debug('####userId =' + u.id + '; ServiceNow_Lic_Id__c=' + u.ServiceNow_Lic_Id__c);
			}
        	}
        	
        	update userUpdate;
        }
	
		
	}


	global void finish(Database.BatchableContext BC)
	{
        
		system.debug('####BC.getJobId():' + BC.getJobId());
		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
						TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id =:BC.getJobId()];
			// Send an email to the Apex job's submitter notifying of job completion.
		system.debug('####a.NumberOfErrors:' + a.NumberOfErrors);	
		if ((a.NumberOfErrors != null && a.NumberOfErrors > 0) || (a.NumberOfErrors != null && isTesting))
		{
		
		SendErrorEmail(a.CreatedBy.Email + ';Shay.Spoonmore@informaUSA.com;Do_Not_Reply.SFDC@informausa.com','Salesforce - Update User License ' + a.Status, BC.getJobId() + ' The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.\n\n' + a.ExtendedStatus);
		}
        
        //Send Licensing Report
		User_ServiceNowLicenseReport slr = new User_ServiceNowLicenseReport();
		slr.EmailReport();
		        
        
	}
	
	public static void SendErrorEmail(string emailTo,String emailSubject, String emailMessage )
    {
        // Added by Palla Kishore for the ticket BK-19604
        system.debug('SendErrorEmail Method is Invoked');
        /**
        if (Limits.getEmailInvocations() < Limits.getLimitEmailInvocations())
        {
                        //Send Error Email
                        Messaging.SingleEmailMessage errorEmail = new Messaging.SingleEmailMessage();
                        //Build Email Error Message
                        errorEmail = new Messaging.SingleEmailMessage();
                        String[] toAddresses = emailTo.split(';',-1); 
                        errorEmail.setToAddresses(toAddresses);
                        errorEmail.setSubject(emailSubject); 
                        errorEmail.setBccSender(false);
                        errorEmail.setEmailPriority('High');
                        errorEmail.setUseSignature(false);
                        errorEmail.setPlainTextBody('Org: ' + UserInfo.getOrganizationName() + '(' +UserInfo.getOrganizationId() +')\n' + emailMessage);
                        
                        
                        Messaging.SendEmailResult[] sendEmailErrorResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { errorEmail });
         }
        **/
    }
	
	
	
	
	
	
	
	
	
}