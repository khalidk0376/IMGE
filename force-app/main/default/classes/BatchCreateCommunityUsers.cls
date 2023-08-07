/**
 * Created/Modified By: Girikon(Sunil)
 * Created On:          15 Feb 2018
 * Description/Purpose: Create community user for contacts.
 * Test Class:  BatchCreateCommunityUsers_Test
 * Code Coverage: 100%
 * Last Modified By: Aishwarya/CCEN-454 (11 Nov 2018),Ashish/CCEN-585 (7 Jan 2019),Garima/CCEN-748 (6 May 2019),Garima/CCEN-725 (6 June 2019),[Aishwarya BK-3759 27 Aug 2020]
**/
public with sharing class BatchCreateCommunityUsers implements Database.Batchable<sObject>,Database.Stateful
{    
    public final id profileId;
    public set<String> conEvntEdnIdsForUpdate;  // ContactEventEditionMapping for which users are created Succesfully
    public final set<id> conEvntMapIds;         // input parameter ContactEventEditionMapping Ids [CCEN-585]

    public BatchCreateCommunityUsers (set<id> conEvntMapIds,Id profileId)
    {
        this.profileId=profileId;
        this.conEvntMapIds=conEvntMapIds;
        conEvntEdnIdsForUpdate = new set<String>();
    }
    // Start Method
    public Database.QueryLocator start(Database.BatchableContext bthContext)
    {
       return Database.getQueryLocator('Select Id,SFContactID__c,SFEventEditionID__c,IsEmailSent__c from ContactEventEditionMapping__c where IsEmailSent__c = False And id in:conEvntMapIds'); 
    }
  
    //Execute Logic
    public void execute(Database.BatchableContext bthContext, List<ContactEventEditionMapping__c> contactEventEditionMapping) 
    {
        //map<string,string> mapNewUserContactAndConatctEEMp = new map<string,string>(); // map to keep new User's Contact with it's ContactEventEditionMapping
        map<string,ContactEventEditionMapping__c> mapNewUserContactAndConatctEEMp = new map<string,ContactEventEditionMapping__c>();   // map to keep new User's Contact with it's ContactEventEditionMapping
        map<string,Event_Settings__c> mapEventSetting = new map <string,Event_Settings__c>(); // map of EventId with Event Setting
        List<User> commUserLst          =   new List<User>();       // new User list to be Inserted
        list<contact> newUserContacts   =   new list<contact>();    // list of contacts for which the new user is being Created
        set<id> eventIds                =   new set<id>();          // Set of contacts for which users are alredy created (Duplicate Contacts)
        set<id> duplicateUserConLst     =   new set<id>();          // Set of contacts for which users are alredy created (Duplicate Contacts)
        set<id> newUserConIds           =   new set<id>();          // set of contacts for which user not is created (valid Contacts)
        set<id> newConIds               =   new set<id>();          // set of contacts for which new user creation is requested (All requested Contacts)

        List<Contact> updateCon = new list<Contact>();      // update Contact list After user Creation 

        String msgUsrCreationErr        =   ''; 
        for (ContactEventEditionMapping__c cEEM:contactEventEditionMapping)
        {
            newConIds.add(cEEM.SFContactID__c);         // Creating set of contacts for new user creation is requested (All requested Contacts)
            eventIds.add(cEEM.SFEventEditionID__c);     // Creating set of EventIds for Which new user creation is requested
        }

        for(Event_Settings__c evntStng : [SELECT Id,Event_Edition__c,Send_Welcome_Email__c, Is_Event_Edition_Live__c FROM Event_Settings__c WHERE  Event_Edition__c IN :eventIds AND Send_Welcome_Email__c = true And Is_Event_Edition_Live__c = true])
        {
            mapEventSetting.put(evntStng.Event_Edition__c,evntStng); //map of Event Ids with Event Setting 
        }

        for(user usr:[select id,contactid from user where contactid in:newConIds])
        {
            duplicateUserConLst.add(usr.contactid);     // Creating Set of contacts for which users are alredy created (Duplicate Contacts)
        }
        
        for (ContactEventEditionMapping__c cEEM:contactEventEditionMapping)
        {
            if(!newUserConIds.contains(cEEM.SFContactID__c) && !duplicateUserConLst.contains(cEEM.SFContactID__c))
            {   
                if(mapEventSetting.containsKey(cEEM.SFEventEditionID__c)) // check if welcome Email can be Sent for this event Or not 
                {
                    newUserConIds.add(cEEM.SFContactID__c); // Creating set of contacts for which user not is created (valid Contacts)   
                    //mapNewUserContactAndConatctEEMp.put(cEEM.SFContactID__c,cEEM.Id);
                    mapNewUserContactAndConatctEEMp.put(cEEM.SFContactID__c,cEEM);  //CCEN-748
                }
            }
            else
            {
                //neeed add logic for queuable opration 
                System.debug('************* Contact Event Edition Id (Duplicate Contact Requested For User)************'+cEEM.Id);
            }        
        }
        //geting Contacts From ConIds to Prepare Community Users
        newUserContacts = [select Id,Email,FirstName,LastName,Account.Name from contact where id in : newUserConIds ];

        if(newUserContacts.size()>0)
        {
            commUserLst=UtilityMethods.PrepareCommunityUser(profileId,newUserContacts);

            for(contact con:newUserContacts)
            {
                if(mapNewUserContactAndConatctEEMp.containsKey(con.Id))
                {
                    ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c (); //Added for CCEN-725
                    cEEM = mapNewUserContactAndConatctEEMp.get(con.Id);
                    con.User_Created_for_Event_Edition__c  = cEEM.SFEventEditionID__c;
                    updateCon.add(con);
                }
            }
        }

        if(!commUserLst.isEmpty())
        {
            try
            {
                //update Contact before user to Avoid Mixed Dml Execption
                if(updateCon != null && !updateCon.IsEmpty())
                {
                    Database.SaveResult[] conUpdateList = Database.update(updateCon, false);
                    system.debug('Update community user Contact Upadte Result ============================== '+conUpdateList);
                }

                //Create new community users  
                //Start : Code updated for CCEN-454
                List<Database.SaveResult> res = Database.insert(commUserLst, false); // inserting New Users
                for (Integer i = 0; i < commUserLst.size(); i++) 
                {
                    Database.SaveResult s = res[i];
                    User origRecord = commUserLst[i];
                    if(s.isSuccess())   
                    {
                        if(mapNewUserContactAndConatctEEMp.containsKey(origRecord.ContactId))
                        {
                            //conEvntEdnIdsForUpdate.add(mapNewUserContactAndConatctEEMp.get(origRecord.ContactId));
                            ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c ();
                            cEEM = mapNewUserContactAndConatctEEMp.get(origRecord.ContactId);                            
                            conEvntEdnIdsForUpdate.add(cEEM.Id);

                            
                        }                        
                    } 
                    else
                    {
                        msgUsrCreationErr += '<br><br><b>User:</b> '+origRecord;
                        // Operation failed, so get all errors   
                        for(Database.Error err : s.getErrors()) 
                        {
                            msgUsrCreationErr += '<br><b>Status Code: </b> '+err.getStatusCode();
                            msgUsrCreationErr += '<br><b>ERROR MESSAGE: </b> '+err.getMessage();
                            msgUsrCreationErr += '<br><b>Account fields that affected this error: </b> '+err.getFields();
                        }
                    }
                }
                if(String.isNotBlank(msgUsrCreationErr))
                {
                    String sMessage='User Creation Exception Details<br>';
                    sMessage += '<br><b>Logged In User:</b> '+UserInfo.getName()+'[ '+ UserInfo.getUserId()+']';
                    sMessage += '<br><b>Org:</b> '+UserInfo.getOrganizationName();
                    sMessage += msgUsrCreationErr;
                    String[] toAddresses = new String[] {Label.Admin_Email_Address_CC};
                    string subject='Exception occurred while creating community user';
                    UtilityMethods.SendEmailNotification(toAddresses,subject,sMessage);                 
                }
                // if(updateCon != null && !updateCon.IsEmpty())
                // {
                //     Database.SaveResult[] conUpdateList = Database.update(updateCon, false);
                //     system.debug('Update community user Contact Upadte Result ============================== '+conUpdateList);
                // }
                //End : Code updated for CCEN-454
            }
            catch(Exception e)
            {
                String sMessage='Exception Details<br>';
                sMessage += '<br><b>User List:</b> '+commUserLst;
                sMessage += '<br><b>Logged In User:</b> '+UserInfo.getName()+'[ '+ UserInfo.getUserId()+']';
                sMessage += '<br><b>Org:</b> '+UserInfo.getOrganizationName();
                sMessage += '<br><b>ERROR TYPE:</b> '+e.getTypeName();
                sMessage += '<br><b>ERROR MESSAGE:</b> '+e.getMessage();
                sMessage += '<br><b>ERROR LINE NUMBER:</b> '+e.getLineNumber();
                sMessage += '<br><b>Error Details:</b> '+e.getStackTraceString();
                String[] toAddresses = new String[] {Label.Admin_Email_Address_CC};
                string subject='Exception occurred while creating community user';
                UtilityMethods.SendEmailNotification(toAddresses,subject,sMessage);
            }                
        }
    }
 
    public void finish(Database.BatchableContext bthContext)
    {
        //  Logic to be Executed at finish        
        //  Start : Code added for CCEN-454
        //  system.debug('===================conIdsForCCEM'+conIdsForCCEM);
        List<ContactEventEditionMapping__c> updateCEEMApping = new List<ContactEventEditionMapping__c>();
        //List<Contact> updateCon = new list<Contact>();
        if(conEvntEdnIdsForUpdate != null && !conEvntEdnIdsForUpdate.isEmpty())
        {
            List<ContactEventEditionMapping__c> lstCEEMApping = [SELECT id, SFContactID__c,SFEventEditionID__c,IsEmailSent__c, Email_Sent__c FROM ContactEventEditionMapping__c WHERE Id IN :conEvntEdnIdsForUpdate];
            if(lstCEEMApping != null && !lstCEEMApping.IsEmpty()) 
            {
                for(ContactEventEditionMapping__c oCEEMapping : lstCEEMApping)
                {
                    oCEEMapping.IsEmailSent__c = true;
                    oCEEMapping.Email_Sent__c = system.now();
                    updateCEEMApping.add(oCEEMapping);  
                    // updating Event Edition on Contact for which the Community User was created And First Welcome Email was Sent  [CCEN-585]         
                  /*if( oCEEMapping.SFContactID__c != null) 
                    {
                        Contact con =  new Contact();
                        con.Id      =  oCEEMapping.SFContactID__c;
                        con.User_Created_for_Event_Edition__c  = oCEEMapping.SFEventEditionID__c;
                        updateCon.add(con);
                    }*/                
                }
                if(updateCEEMApping != null && !updateCEEMApping.IsEmpty())
                {
                    Update updateCEEMApping;
                }
            /*  if(updateCon != null && !updateCon.IsEmpty())
                {
                    Database.SaveResult[] conUpdateList = Database.update(updateCon, false);
                    system.debug('Update community user Contact Upadte Result ============================== '+conUpdateList);
                }   */
            }
        }
        //Start : Code added for CCEN-454
    }
}