/**
 * Created/Modified By: Girikon(Aishwarya)/Aishwarya
 * Created On:          30/09/2019
 * modified On:         
 * Description/Purpose: This Class is used for assigning the missing manuals to the Accounts
 * Test Class:          BatchAssignFormManual_Test
 * Code Coverage:       85%
 * Last Modified By :   [Aishwarya BK-3759 27 Aug 2020]
**/

    public class BatchAssignManuals implements Database.Batchable<sObject>{
    
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
        String query = 'Select Id, Expocad_Booth_Type__c, Expocad_Product_Type__c, Event_Edition__c FROM Manual__c WHERE Event_Edition__c IN:SetEventIds';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Manual__c> ListManuals){
        System.debug('#### EventFormList'+ListManuals.size());
        if(PreventRecursive.runOnceCreate() || Test.isRunningTest())
        {
             Set<String> eventEditionIds=new Set<String>();
             Set<String> manualIds=new Set<String>();
             Set<String> userTypeIDs=new Set<String>();
             Set<String> contactIDs=new Set<String>();
             Set<String> uMAAccountIds = new Set<String>();
             Set<String> uMAUserTypeIds = new Set<String>();
             Set<String> accountAndUserTypeSet = new Set<String>();
             Set<String> preventDupUserType = new Set<String>();
             List<String> manualPermissionIds=new List<String>();
             List<User_Manual_Action__c> umaList = new List<User_Manual_Action__c>();
             List<Manual__c> manualList;
             List<ContactEventEditionMapping__c> conEventList = new List<ContactEventEditionMapping__c>();
             List<User_Manual_Action__c> listExistingUMA = new List<User_Manual_Action__c>();
             Map<Id,Id> mapConatctUser = new Map<Id,Id>();
             Map<String,String> mapAccountContact = new Map<String,String>(); 
             /*This Map contains the UserType as key and ManualPermissionId as value so that correct ManualPermissionId could assign while
                    creating the "UserManualAction" records according to the UserType */
             Map<String,Id> mapManualPermission = new Map<String,Id>(); 
             /* This map contains ContactId as Key and UserId as value. It is used to get User on basis of the Contacts from the 
                ContactEventEditionMapping list and assign the correct User while creating the "UserManualAction" records */
             List<String> listExpProductIds = new List<String>();
             List<String> listExpBoothIds = new List<String>();
             List<Manuals_Permission__c> ListManualPermission;
             Boolean ifExpocadFieldsBlank = false;
             Boolean ifExpocadFieldsNotBlank = false;
             String productType;
             String boothType;
             listManualPermission = [Select Id, User_Type__c, Manuals__c FROM Manuals_Permission__c Where Manuals__c IN:ListManuals];
             //Getting Manual Ids, User type ids and Manual permission Id while setting a new Manual Permission
             if(!listManualPermission.isEmpty()){
                 for(Manuals_Permission__c mp : listManualPermission){
                     manualIds.Add(mp.Manuals__c);
                     userTypeIDs.Add(mp.User_Type__c);
                     manualPermissionIds.Add(mp.Id);
                     mapManualPermission.put(mp.User_Type__c, mp.Id);
                 }
             } 
             if(Schema.sObjectType.Manual__c.isAccessible()){
                manualList = [Select Id, User_Type__c , Expocad_Booth_Type__c, Expocad_Product_Type__c, Event_Edition__c from Manual__c where Id IN: manualIds];
             }
             
             //Putting Event Edition Ids into set
             if(!manualList.isEmpty())
             {
                 for(Manual__c manual: manualList)
                 {
                     eventEditionIds.Add(manual.Event_Edition__c);
                     if(String.isBlank(manual.Expocad_Booth_Type__c) && String.isBlank(manual.Expocad_Product_Type__c))
                     {
                         ifExpocadFieldsBlank = True;
                     }
                    else{
                         ifExpocadFieldsNotBlank = True;
                     }
                     if(manual.Expocad_Product_Type__c !=null && manual.Expocad_Product_Type__c !='')
                     {
                         productType = manual.Expocad_Product_Type__c.toLowerCase();
                     }            
                     if(productType != null){
                         listExpProductIds = productType.split(';');
                     }
                     if(manual.Expocad_Booth_Type__c !=null && manual.Expocad_Booth_Type__c !=''){
                         boothType = manual.Expocad_Booth_Type__c.toLowerCase(); 
                     }          
                     if(boothType != null){
                         listExpBoothIds = boothType.split(';');
                     }
                 }
             }
             
             //Getting List of Contacts for related Form Permision event edition and Usertype.
             conEventList = [SELECT Id, Name, SFEventEditionID__c, SFContactID__c, User_Type__r.Name, SFContactID__r.Name, SFContactID__r.AccountId, User_Type__c, SFContactID__r.Account.IsCustomerPortal , SFContactID__r.Account.Name   
                                    FROM ContactEventEditionMapping__c WHERE SFEventEditionID__c IN: eventEditionIds AND User_Type__c IN:userTypeIDs AND SFContactID__r.AccountId!=null AND Status__c =True order by SFEventEditionID__c, SFContactID__c];
             Set<String> setEEIds = new Set<String>();
             //Getting User Ids
             if(conEventList!=null && !conEventList.IsEmpty()){
                for(ContactEventEditionMapping__c ceeM:conEventList){
                    contactIDs.Add(ceeM.SFContactID__c);
                    mapAccountContact.put(ceeM.SFContactID__r.AccountId, ceeM.SFContactID__c);
                    uMAAccountIds.add(ceeM.SFContactID__r.AccountId);
                    uMAUserTypeIds.add(ceeM.User_Type__c);
                    setEEIds.add(ceeM.SFEventEditionID__c);
                }
             }
             List<User> users=[Select Id, Contact.Type__c, ContactId from User where ContactId IN: contactIDs];
             if(!users.isEmpty()){
                 for(User u: users){
                     mapConatctUser.put(u.ContactId, u.Id);
                 }
             }
             
             /**** If any of the expocad fields are not blank on EEForm then create User Form action records on basis of the matching Expocad Booth ****/
             if(ifExpocadFieldsNotBlank == True)
             {
                 Set<String> setAccountForUMA = new Set<String>();
                 Set<string> squoteIds = new Set<string>();
                 Map<Id,Id> mapExpoAndAccountId = new Map<Id,Id>();
                 List<opportunity> opp = new List<opportunity>();
                 List<Opportunity_ExpoCAD_Booth_Mapping__c> expoBooths = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();  
                 opp = [Select Id, Name, SBQQ__PrimaryQuote__c,User_Type__c ,User_Type__r.Name, AccountId FROM opportunity where EventEdition__c IN:setEEIds AND AccountId IN:uMAAccountIds
                                                AND (StageName='Closed Won' OR StageName='Closed Booked') AND SBQQ__PrimaryQuote__c!=null order by createdDate];
                 system.debug('======================OPPLIST'+opp+'==SIZE'+opp.Size());
               
                 Set<String> setAccountIds = new Set<String>();
                 if(opp.size()>0){ 
                    for(opportunity oppty: opp){ 
                        sQuoteIds.add(oppty.SBQQ__PrimaryQuote__c); 
                    }
                 }
                 if(squoteIds.size()>0){
                     
                     // Fetching all the booth information as per booth status(Rented) and opportunity
                     expoBooths = [Select Id, Expocad_Booth__r.Booth_Type__c, Expocad_Booth__r.Matched_Product_Name__c, Opportunity__r.AccountId, Opportunity__r.Account.Name FROM Opportunity_ExpoCAD_Booth_Mapping__c where Status__c ='Active' AND Expocad_Booth__r.status__c='Rented' AND quote__c IN:sQuoteIds];
                 }
                 Map<String,String> mapAccFromExpocad = new Map<String,String>();
                 if(expoBooths != null && expoBooths.size()>0){ 
                     for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: expoBooths){
                         mapAccFromExpocad.put(ecb.Opportunity__r.AccountId, ecb.Opportunity__r.AccountId);
                     }
                 }
                 
                 if(expoBooths != null && expoBooths.size()>0)
                 {
                    // Adding account id to set on basis of the matching boothType, booth class and booth product type from event edition form
                    for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: expoBooths)
                    {
                        if(!setAccountForUMA.contains(ecb.Opportunity__r.AccountId))
                        {
                            for(Manual__c manual : manualList){
                                if(String.isNotBlank(ecb.Expocad_Booth__r.Booth_Type__c) && String.isNotBlank(manual.Expocad_Booth_Type__c) && listExpBoothIds.size()>0 && listExpBoothIds.contains(ecb.Expocad_Booth__r.Booth_Type__c.toLowerCase()) && (mapAccFromExpocad.size()>0 && mapAccFromExpocad.containsKey(ecb.Opportunity__r.AccountId) && mapAccFromExpocad.get(ecb.Opportunity__r.AccountId) == ecb.Opportunity__r.AccountId)){
                                    setAccountForUMA.add(ecb.Opportunity__r.AccountId);
                                }
                                if(String.isNotBlank(ecb.Expocad_Booth__r.Matched_Product_Name__c) && String.isNotBlank(manual.Expocad_Product_Type__c) && listExpProductIds.size()>0 && listExpProductIds.contains(ecb.Expocad_Booth__r.Matched_Product_Name__c.toLowerCase()) && (mapAccFromExpocad.size()>0 && mapAccFromExpocad.containsKey(ecb.Opportunity__r.AccountId) && mapAccFromExpocad.get(ecb.Opportunity__r.AccountId) == ecb.Opportunity__r.AccountId)){
                                    setAccountForUMA.add(ecb.Opportunity__r.AccountId);
                                }
                            }
                        }
                    }
                 }
                system.debug('&&&&&&&&&&&&&&&&&'+setAccountForUMA);
                List<User_Manual_Action__c> listUMAForDelete;
                if(Schema.sObjectType.User_Manual_Action__c.isAccessible()){
                    listUMAForDelete =[Select Id, Name FROM User_Manual_Action__c where Account__c NOT IN:setAccountForUMA AND User_Type__c IN:uMAUserTypeIds AND Manual_Permission__r.Manuals__r.Event_Edition__c IN:eventEditionIds AND Manual_Permission__r.Manuals__c IN:manualIds AND User_Type__r.Name != 'Stand Contractor'];
                }
                
                if(!listUMAForDelete.isEmpty() && User_Manual_Action__c.sObjectType.getDescribe().isDeletable()){
                    delete listUMAForDelete;
                } 
                // Query existing UserManualAction records with matching Account and UserTypes In case of updating EEManual i.e modifying User Type
                listExistingUMA = [Select Id, Account__c, User_Manual_Contact__c, User_Type__c, Manual_Permission__r.Manuals__c, Manual_Permission__r.Manuals__r.Event_Edition__c FROM User_Manual_Action__c 
                                          Where Account__c IN:setAccountForUMA AND Manual_Permission__r.Manuals__r.Event_Edition__c IN:eventEditionIds AND Manual_Permission__r.Manuals__c IN:manualIds];
                
                for(User_Manual_Action__c uma: listExistingUMA){
                    accountAndUserTypeSet.add(uma.Account__c + '' +uma.User_Type__c);
                }
                System.debug('###################SET '+accountAndUserTypeSet);
                // Inserting data of User Manual Action.
                for(Integer i=0;i<conEventList.size();i++){
                    if((((setAccountForUMA.contains(conEventList[i].SFContactID__r.AccountId)) && ((accountAndUserTypeSet.size() >0 && !accountAndUserTypeSet.contains(conEventList[i].SFContactID__r.AccountId + '' +conEventList[i].User_Type__c))))
                         || ((setAccountForUMA.contains(conEventList[i].SFContactID__r.AccountId)) && ((accountAndUserTypeSet.size() == 0))) 
                         || ((conEventList[i].User_Type__r.Name == 'Agent' && accountAndUserTypeSet.size() == 0) || ((conEventList[i].User_Type__r.Name == 'Agent' && accountAndUserTypeSet.size() >0 && !accountAndUserTypeSet.contains(conEventList[i].SFContactID__r.AccountId + '' +conEventList[i].User_Type__c)))) ) )                                                   
                    {
                        User_Manual_Action__c uma = new User_Manual_Action__c();
                        uma.User_Manual_Contact__c = conEventList[i].SFContactID__c;
                        uma.Account__c = conEventList[i].SFContactID__r.AccountId; 
                        uma.User_Type__c = conEventList[i].User_Type__c;
                        if(!mapManualPermission.isEmpty() && mapManualPermission.containsKey(conEventList[i].User_Type__c)){
                            uma.Manual_Permission__c = mapManualPermission.get(conEventList[i].User_Type__c);
                        }
                        if(!mapConatctUser.isEmpty() && mapConatctUser.containsKey(conEventList[i].SFContactID__c)){ uma.User__c = mapConatctUser.get(conEventList[i].SFContactID__c); }
                        if(!preventDupUserType.Contains(uma.User_Type__c +''+ uma.Account__c )){
                            preventDupUserType.add(uma.User_Type__c +''+ uma.Account__c);
                            umaList.Add(uma);
                        } 
                    }
                }   
            }
            /**** If all three expocad fields are blank on Manusl then create User Manual action records for all accounts from matching CCE records ****/
            if(ifExpocadFieldsBlank == True)
            {
                // Query existing UserManualAction records with matching Account and UserTypes In case of updating EEManual i.e modifying User Type
                listExistingUMA = [Select Id, Account__c, User_Manual_Contact__c, User_Type__c,User_Type__r.Name, Manual_Permission__r.Manuals__c, Manual_Permission__r.Manuals__r.Event_Edition__c FROM User_Manual_Action__c 
                                          WHERE Account__c IN:uMAAccountIds AND User_Type__c IN:uMAUserTypeIds AND Manual_Permission__r.Manuals__r.Event_Edition__c IN:eventEditionIds AND Manual_Permission__r.Manuals__c IN:manualIds];
                 
                 for(User_Manual_Action__c uma: listExistingUMA){
                     accountAndUserTypeSet.add(uma.Account__c + '' +uma.User_Type__c);
                 }

                 // Inserting data of User Manual Action.
                 for(Integer i=0;i<conEventList.size();i++)
                 {
                     if( ( (accountAndUserTypeSet.size() >0 && !accountAndUserTypeSet.contains(conEventList[i].SFContactID__r.AccountId + '' +conEventList[i].User_Type__c))
                                                                 || (accountAndUserTypeSet.size() == 0 && conEventList.size()>0) )  )                                                        
                     {
                         User_Manual_Action__c uma = new User_Manual_Action__c();
                         uma.User_Manual_Contact__c = conEventList[i].SFContactID__c;
                         uma.Account__c = conEventList[i].SFContactID__r.AccountId;
                         uma.User_Type__c = conEventList[i].User_Type__c;
                         if(!mapManualPermission.isEmpty() && mapManualPermission.containsKey(conEventList[i].User_Type__c)){
                             uma.Manual_Permission__c = mapManualPermission.get(conEventList[i].User_Type__c);
                         }
                         if(!mapConatctUser.isEmpty() && mapConatctUser.containsKey(conEventList[i].SFContactID__c)){
                             uma.User__c = mapConatctUser.get(conEventList[i].SFContactID__c);
                         }
                         if(!preventDupUserType.Contains(uma.User_Type__c +''+ uma.Account__c )){
                             preventDupUserType.add(uma.User_Type__c +''+ uma.Account__c);
                             umaList.Add(uma);
                         }
                     }
                 }   
             } 
             system.debug('umaList==='+umaList+'Size::'+umaList.size());
             try{    
                if(umaList.size()>0 && Schema.sObjectType.User_Manual_Action__c.IsCreateable()){
                    insert umaList;
                }  
             }  
             catch(exception ex){
                ex.getMessage();
             }
         }
    }

    public void finish(Database.BatchableContext bc){
        // Added by Palla Kishore for the ticket Bk-19604
          system.debug('Batch job completed successfully');
    }
}