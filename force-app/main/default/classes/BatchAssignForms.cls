/**
 * Created/Modified By: Girikon(Aishwarya)/Aishwarya
 * Created On:          30/09/2019
 * modified On:         
 * Description/Purpose: This Class is used for assigning the missing forms to the Accounts
 * Test Class:          BatchAssignFormManual_Test
 * Code Coverage:       78%
 * Last Modified By :   [Aishwarya BK-3759 27 Aug 2020]
**/
//Ticket No. BK-14521 Updating API Version

public class BatchAssignForms implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        List<Event_Settings__c> listEveSettings;
        Set<Id> SetEventIds = new Set<Id>();
        listEveSettings = [Select Event_Edition__c FROM Event_Settings__c WHERE Event_Edition__r.Event_Edition_Status__c ='Confirmed' AND Is_Event_Edition_Live__c = True AND Event_Edition__r.End_Date__c >= Today];
        if(!listEveSettings.isEmpty()){
            for(Event_Settings__c es :listEveSettings)
            {
                SetEventIds.add(es.Event_Edition__c);
            }
        }
        // query the Event Edition Form records for the matched event edition return by above query
        String query = 'Select Id, Expocad_Booth_Type__c, Expocad_Product_Type__c, Event_Edition__c FROM Event_Edition_Form__c WHERE Event_Edition__c IN:SetEventIds';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Event_Edition_Form__c> ListEventEditionForms){
        if(PreventRecursive.runOnceCreate() || (Test.isRunningTest())){
             Set<String> eventEditionIds=new Set<String>();
             Set<String> eventEditionFormIds=new Set<String>();
             Set<String> userTypeIDs=new Set<String>();
             Set<String> contactIDs=new Set<String>();
             Set<String> UFAAccountIds = new Set<String>();
             Set<String> UFAUserTypeIds = new Set<String>();
             Set<String> AccountAndUserTypeSet = new Set<String>();
             Set<String> PreventDupUserType = new Set<String>();
             List<String> FormPermissionIds=new List<String>();
             List<User_Form_Action__c> ufaList = new List<User_Form_Action__c>();
             List<Event_Edition_Form__c> eefList;
             List<ContactEventEditionMapping__c> conEventList;
             List<User_Form_Action__c> ListExistingUFA = new List<User_Form_Action__c>();
             Map<Id,Id> mapConatctUser = new Map<Id,Id>();
             Map<String,String> mapAccountContact = new Map<String,String>(); 
             /* This Map contains the UserType as key and FormPermissionId as value so that correct FormPermissionId could assign while
                creating the "UserFormAction" records according to the UserType*/
             Map<String,Id> mapFormPermission = new Map<String,Id>(); 
             /* This map contains ContactId as Key and UserId as value. It is used to get User on basis of the Contacts from the 
                ContactEventEditionMapping list and assign the correct User while creating the "UserFormAction" records */
             List<User> users;
             List<Forms_Permission__c> ListFormPermissions;
             ListFormPermissions =[select id, User_Type__c, Event_Edition_Form__c from Forms_Permission__c Where Event_Edition_Form__c IN:ListEventEditionForms];
             
             //Getting Event Edition Form Ids, User type ids and Form permission Id while setting a new Form Permission
             if(!ListFormPermissions.isEmpty()){
                 for(Forms_Permission__c fp :ListFormPermissions)
                 {
                     eventEditionFormIds.Add(fp.Event_Edition_Form__c);
                     userTypeIDs.Add(fp.User_Type__c);
                     FormPermissionIds.Add(fp.Id);
                     mapFormPermission.put(fp.User_Type__c, fp.Id);
                 }
             } 
             eefList = [Select Id, User_Type__c, Expocad_Booth_Type__c, Expocad_Product_Type__c, Event_Edition__c FROM Event_Edition_Form__c WHERE Id IN: eventEditionFormIds];
             //Putting Event Edition Ids into set
             Boolean ifExpocadFieldsBlank = false;
             Boolean ifExpocadFieldsNotBlank = false;
             List<String> listExpProductIds = new List<String>();
             List<String> listExpBoothIds = new List<String>();
             Set<String> setEEIds = new Set<String>();
             String productType;
             String boothType;
             //Putting Event Edition Ids into set
             if(!eefList.IsEmpty())
             {
                 for(Event_Edition_Form__c eef:eefList )
                 {
                     eventEditionIds.Add(eef.Event_Edition__c);
                     if(String.isBlank(eef.Expocad_Booth_Type__c) && String.isBlank(eef.Expocad_Product_Type__c)){
                         ifExpocadFieldsBlank = True;
                     }
                     else{
                         ifExpocadFieldsNotBlank = True;
                     }
                     if(eef.Expocad_Product_Type__c != null && eef.Expocad_Product_Type__c !=''){
                         productType = eef.Expocad_Product_Type__c.toLowerCase();
                     }            
                     if(productType != null){
                         listExpProductIds = productType.split(';');
                     }
                     if(eef.Expocad_Booth_Type__c != null && eef.Expocad_Booth_Type__c !=''){
                         boothType = eef.Expocad_Booth_Type__c.toLowerCase(); 
                     }          
                     if(boothType != null){
                         listExpBoothIds = boothType.split(';');
                     }
                 }
             
             //Getting List of Contacts for related Form Permission event edition and Usertype.
             if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible())
             {
                conEventList = [SELECT Id, Name, SFEventEditionID__c, SFContactID__c, User_Type__r.Name, SFContactID__r.Name, SFContactID__r.AccountId, User_Type__c, SFContactID__r.Account.IsCustomerPortal    
                                       FROM ContactEventEditionMapping__c WHERE SFEventEditionID__c IN: eventEditionIds AND User_Type__c IN:userTypeIDs AND SFContactID__r.AccountId != null AND Status__c =True order by SFEventEditionID__c, SFContactID__c];
             }
             //Getting User Ids
             if(!conEventList.isEmpty())
             {
                for(ContactEventEditionMapping__c ceeM:conEventList ){
                    contactIDs.Add(ceeM.SFContactID__c);
                    mapAccountContact.put(ceeM.SFContactID__r.AccountId, ceeM.SFContactID__c);
                    uFAAccountIds.add(ceeM.SFContactID__r.AccountId);
                    uFAUserTypeIds.add(ceeM.User_Type__c); 
                    setEEIds.add(ceeM.SFEventEditionID__c);
                }
             }
             if(Schema.sObjectType.User.isAccessible())
             {
                users=[Select Id, Contact.Type__c, ContactId from User where ContactId IN: contactIDs];
             }
             
             if(!users.isEmpty()){                 for(User u: users){                      mapConatctUser.put(u.ContactId, u.Id);
                 }
             }
            
            /**** If any of the expocad fields are not blank on EEForm then create User Form action records on basis of the matching Expocad Booth ****/
            if(ifExpocadFieldsNotBlank == True)
            {
                Set<String> setAccountForUFA = new Set<String>();
                Set<String> squoteIds = new Set<String>();
                List<opportunity> opp = new List<opportunity>();
                List<Opportunity_ExpoCAD_Booth_Mapping__c> expoBooths = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
                if(Schema.sObjectType.opportunity.isAccessible())
                {      
                    opp = [Select Id, Name, SBQQ__PrimaryQuote__c, AccountId FROM opportunity where EventEdition__c IN:setEEIds AND AccountId IN:uFAAccountIds
                                                AND (StageName='Closed Won' OR StageName='Closed Booked') AND SBQQ__PrimaryQuote__c!=null order by createdDate];
                }
                Set<String> setAccountIds = new Set<String>();
                if(opp != null && opp.size()>0)                {                     for(opportunity oppty: opp){ sQuoteIds.add(oppty.SBQQ__PrimaryQuote__c); }
                }
                
                if(sQuoteIds.size()>0)
                {
                    // Fetching all the booth information as per booth status(Rented) and opportunity
                    if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible())                    {                        expoBooths = [Select Id,Name ,Expocad_Booth__r.Booth_Type__c, Expocad_Booth__r.Matched_Product_Name__c, Opportunity__r.AccountId, Opportunity__r.Account.Name FROM Opportunity_ExpoCAD_Booth_Mapping__c where Status__c ='Active' AND Expocad_Booth__r.status__c='Rented' AND quote__c IN:sQuoteIds];
                    }
                }
                Map<String,String> mapAccFromExpocad = new Map<String,String>();
                if(expoBooths != null && expoBooths.size()>0)                {                     for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: expoBooths)                    {                        mapAccFromExpocad.put(ecb.Opportunity__r.AccountId, ecb.Opportunity__r.AccountId);                    }
                }
                if(expoBooths != null && expoBooths.size()>0)
                {
                    // Adding account id to set on basis of the matching boothType, booth product type from event edition form
                    for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: expoBooths)                    {                        if(!setAccountForUFA.contains(ecb.Opportunity__r.AccountId))                        {                            for(Event_Edition_Form__c eef : eefList)                            {                                if(String.isNotBlank(ecb.Expocad_Booth__r.Booth_Type__c) && String.isNotBlank(eef.Expocad_Booth_Type__c) && listExpBoothIds.size()>0 && listExpBoothIds.contains(ecb.Expocad_Booth__r.Booth_Type__c.toLowerCase()) && (mapAccFromExpocad.size()>0 && mapAccFromExpocad.containsKey(ecb.Opportunity__r.AccountId) && mapAccFromExpocad.get(ecb.Opportunity__r.AccountId) == ecb.Opportunity__r.AccountId)){
                                    setAccountForUFA.add(ecb.Opportunity__r.AccountId);
                                }
                                if(String.isNotBlank(ecb.Expocad_Booth__r.Matched_Product_Name__c) && String.isNotBlank(eef.Expocad_Product_Type__c) && listExpProductIds.size()>0 && listExpProductIds.contains(ecb.Expocad_Booth__r.Matched_Product_Name__c.toLowerCase()) && (mapAccFromExpocad.size()>0 && mapAccFromExpocad.containsKey(ecb.Opportunity__r.AccountId) && mapAccFromExpocad.get(ecb.Opportunity__r.AccountId) == ecb.Opportunity__r.AccountId)){
                                    setAccountForUFA.add(ecb.Opportunity__r.AccountId);
                                }
                            } 
                        }
                    }
                }
                
                List<User_Form_Action__c> listUFAForDelete = new List<User_Form_Action__c>();
                if(Schema.sObjectType.User_Form_Action__c.isAccessible())
                {
                    listUFAForDelete =[Select Id, Name FROM User_Form_Action__c where Account__c NOT IN:setAccountForUFA AND User_Type__c IN:uFAUserTypeIds AND Form_Permission__r.Event_Edition_Form__r.Event_Edition__c IN:eventEditionIds AND Form_Permission__r.Event_Edition_Form__c IN:eventEditionFormIds AND User_Type__r.Name != 'Stand Contractor'];
                }
                if(listUFAForDelete.size()>0 && User_Form_Action__c.sObjectType.getDescribe().isDeletable() && Opp.size()>0)                {                    delete listUFAForDelete;
                }
                 // Query existing UserFormAction records with matching Account and UserTypes In case of updating EEForm i.e modifying User Type
                listExistingUFA = [Select Id, Account__c, User_Form_Contact__c, User_Type__c, Form_Permission__r.Event_Edition_Form__c, Form_Permission__r.Event_Edition_Form__r.Event_Edition__c FROM User_Form_Action__c 
                                          where Account__c IN:setAccountForUFA AND Form_Permission__r.Event_Edition_Form__c IN:eventEditionFormIds AND Form_Permission__r.Event_Edition_Form__r.Event_Edition__c IN:eventEditionIds];
                
                 for(User_Form_Action__c ufa: listExistingUFA)                 {                     accountAndUserTypeSet.add(ufa.Account__c + '' +ufa.User_Type__c); 
                 }
             
                 // Inserting data of User Form Action.
                 for(Integer i=0;i<conEventList.size();i++)
                 {
                     if((((setAccountForUFA.contains(conEventList[i].SFContactID__r.AccountId)) && ((accountAndUserTypeSet.size() >0 && !accountAndUserTypeSet.contains(conEventList[i].SFContactID__r.AccountId + '' +conEventList[i].User_Type__c))))
                         || ((setAccountForUFA.contains(conEventList[i].SFContactID__r.AccountId)) && ((accountAndUserTypeSet.size() == 0))) 
                         || ((conEventList[i].User_Type__r.Name == 'Agent' && accountAndUserTypeSet.size() == 0 ) || ((conEventList[i].User_Type__r.Name == 'Agent' && accountAndUserTypeSet.size() >0 && !accountAndUserTypeSet.contains(conEventList[i].SFContactID__r.AccountId + '' +conEventList[i].User_Type__c))))  ) )                                                        
                     {
                         User_Form_Action__c ufa = new User_Form_Action__c();
                         ufa.User_Form_Contact__c = conEventList[i].SFContactID__c;
                         ufa.Account__c = conEventList[i].SFContactID__r.AccountId;  ufa.User_Type__c = conEventList[i].User_Type__c;
                         if(!mapFormPermission.isEmpty() && mapFormPermission.containsKey(conEventList[i].User_Type__c))
                         {
                             ufa.Form_Permission__c = mapFormPermission.get(conEventList[i].User_Type__c);
                         }
                         if(!mapConatctUser.isEmpty() && mapConatctUser.containsKey(conEventList[i].SFContactID__c)){ ufa.User__c = mapConatctUser.get(conEventList[i].SFContactID__c); }
                         if(!preventDupUserType.Contains(ufa.User_Type__c +''+ ufa.Account__c ))
                         {
                             preventDupUserType.add(ufa.User_Type__c +''+ ufa.Account__c);
                             ufaList.Add(ufa);
                         }
                     }
                 }   
            }
            
            /**** If all three expocad fields are blank on EEForm then create User Form action records for all accounts from matching CCE records ****/
            else if(ifExpocadFieldsBlank == True)            {
                //Query existing UserFormAction records with matching Account and UserTypes In case of updating EEForm i.e modifying User Type
                listExistingUFA = [Select Id, Account__c, User_Form_Contact__c, User_Type__c, Form_Permission__r.Event_Edition_Form__c, Form_Permission__r.Event_Edition_Form__r.Event_Edition__c FROM User_Form_Action__c 
                                   Where Account__c IN:uFAAccountIds AND User_Type__c IN:uFAUserTypeIds AND Form_Permission__r.Event_Edition_Form__r.Event_Edition__c IN:eventEditionIds AND Form_Permission__r.Event_Edition_Form__c IN:eventEditionFormIds];
                 
                for(User_Form_Action__c ufa: listExistingUFA){                    accountAndUserTypeSet.add(ufa.Account__c + '' +ufa.User_Type__c);
                }
                 
                 // Inserting data of User Form Action.
                 for(Integer i=0;i<conEventList.size();i++)                 {                     if( (accountAndUserTypeSet.size() >0 && !accountAndUserTypeSet.contains(conEventList[i].SFContactID__r.AccountId + '' +conEventList[i].User_Type__c))
                                                                 || (accountAndUserTypeSet.size() == 0 && conEventList.size()>0) )                                                        
                     {
                         User_Form_Action__c ufa = new User_Form_Action__c();                         ufa.User_Form_Contact__c = conEventList[i].SFContactID__c;
                         ufa.Account__c = conEventList[i].SFContactID__r.AccountId;                         ufa.User_Type__c = conEventList[i].User_Type__c;
                         if(!mapFormPermission.isEmpty() && mapFormPermission.containsKey(conEventList[i].User_Type__c))                         {                             ufa.Form_Permission__c = mapFormPermission.get(conEventList[i].User_Type__c);
                         }
                         if(!mapConatctUser.isEmpty() && mapConatctUser.containsKey(conEventList[i].SFContactID__c))                         {                             ufa.User__c = mapConatctUser.get(conEventList[i].SFContactID__c);
                         }
                         if(!preventDupUserType.Contains(ufa.User_Type__c +''+ ufa.Account__c ))                         {                             preventDupUserType.add(ufa.User_Type__c +''+ ufa.Account__c);                             ufaList.Add(ufa);                         }
                     }
                 }   
            }
            try{ 
                if(ufaList.size()>0 && Schema.sObjectType.User_Form_Action__c.IsCreateable()){
                    insert ufaList; 
                }
            }  
            catch(exception ex){                ex.getMessage();            }
         }
      }
    }
    public void finish(Database.BatchableContext bc){ 
        // Added by Palla Kishore for the ticket Bk-19604
        system.debug('Batch job completed successfully');
}
}