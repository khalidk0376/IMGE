/**
 * Created/Modified By  :   Girikon(Aishwarya)/Aishwarya
 * Created On           :   12/11/2017
 * @description         :   Handler class which will be called by the Form-Manuals trigger/ CCEN-47, CCEN-234
 * Methods              :   createUserFormActionRecords, createUserManualActionRecords, duplicateCheckOnFormPermission, duplicateCheckOnManualPermission
 * Test Class           :   FormManualsHandler_Test (80%)
 * Last Modified By     :   Girikon[Aishwarya CCEN-447/CCEN-448/CCEN-423, CCEN-610 Jan 25 2019, CCEN-614 Jan 28 2019, CCEN-674 Feb 22 2019, CCEN-735 March 29 2019, CCEN-738 Apr 1 2019, CCEN-798 May 22 2019, CCEN-732 May 31, [Aishwarya BK-1897 July 9],[Aishwarya BK-2388 Sep 10 2019], [Aishwarya BK-4903 June 3 2020] ]
**/

public without sharing class FormManualsHandler
{
     public static Set<String> alreadyProcessed = new Set<String>();      
     public static boolean runOnce = false;
     public static boolean runOnceForManual = false;
     // Method createUserFormActionRecords Start
     public static void createUserFormActionRecords(List<Forms_Permission__c> listFormPermissions)
     {
         if(PreventRecursive.runOnceCreate() || (Test.isRunningTest()))
         {
             Set<String> eventEditionIds=new Set<String>();
             Set<String> eventEditionFormIds=new Set<String>();
             Set<String> userTypeIDs=new Set<String>();
             Set<String> contactIDs=new Set<String>();
             Set<String> uFAAccountIds = new Set<String>();
             Set<String> uFAUserTypeIds = new Set<String>();
             Set<String> accountAndUserTypeSet = new Set<String>();
             Set<String> preventDupUserType = new Set<String>();
             List<String> formPermissionIds=new List<String>();
             List<User_Form_Action__c> ufaList = new List<User_Form_Action__c>();
             List<Event_Edition_Form__c> eefList = new List<Event_Edition_Form__c>();
             List<ContactEventEditionMapping__c> conEventList = new List<ContactEventEditionMapping__c>();
             List<User_Form_Action__c> listExistingUFA = new List<User_Form_Action__c>();
             Map<Id,Id> mapConatctUser = new Map<Id,Id>();
             Map<String,String> mapAccountContact = new Map<String,String>(); 
             /*This Map contains the UserType as key and FormPermissionId as value so that correct FormPermissionId could assign while
                    creating the "UserFormAction" records according to the UserType */
             Map<String,Id> mapFormPermission = new Map<String,Id>(); 
             /* This map contains ContactId as Key and UserId as value. It is used to get User on basis of the Contacts from the 
                ContactEventEditionMapping list and assign the correct User while creating the "UserFormAction" records */
             
             //Getting Event Edition Form Ids, User type ids and Form permission Id while setting a new Form Permission
             //system.debug('eventEditionFormIds  ## Details'+listFormPermissions);
             for(Forms_Permission__c fp : listFormPermissions)
             {
                 eventEditionFormIds.Add(fp.Event_Edition_Form__c);
                 userTypeIDs.Add(fp.User_Type__c);
                 formPermissionIds.Add(fp.Id);
                 mapFormPermission.put(fp.User_Type__c, fp.Id);
             }
             if(Schema.sObjectType.Event_Edition_Form__c.isAccessible())
             {
                eefList = [Select Id, Expocad_Booth_Class__c, Expocad_Booth_Type__c, Expocad_Product_Type__c, Event_Edition__c from Event_Edition_Form__c where Id IN: eventEditionFormIds LIMIT 1];
                system.debug('==================eefList'+eefList);
             }
             Boolean ifExpocadFieldsBlank = false;
             Boolean ifExpocadFieldsNotBlank = false;
             List<String> listExpProductIds = new List<String>();
             List<String> listExpBoothIds = new List<String>();
             Set<String> setEEIds = new Set<String>();
             String productType;
             String boothType;
             //Putting Event Edition Ids into set
             if(!(eefList.IsEmpty()))
             {
                 for(Event_Edition_Form__c eef:eefList )
                 {
                     eventEditionIds.Add(eef.Event_Edition__c);
                     if(String.isBlank(eef.Expocad_Booth_Class__c) && String.isBlank(eef.Expocad_Booth_Type__c) && String.isBlank(eef.Expocad_Product_Type__c)){
                         ifExpocadFieldsBlank = True;
                         system.debug('test'+ifExpocadFieldsBlank);
                     }
                     else{
                         ifExpocadFieldsNotBlank = True;
                           system.debug('test'+ifExpocadFieldsNotBlank);
                     }
                     system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@BOOTH '+eef.Expocad_Product_Type__c);
                     
                     if(eef.Expocad_Product_Type__c != null && eef.Expocad_Product_Type__c !=''){
                         productType = eef.Expocad_Product_Type__c.toLowerCase(); //CCEN-674
                     }            
                     if(productType != null){
                         listExpProductIds = productType.split(';');
                     }
                     system.debug('%%%%%%%%%%%%%%%%%% '+listExpProductIds);
                     if(eef.Expocad_Booth_Type__c != null && eef.Expocad_Booth_Type__c !=''){
                         boothType = eef.Expocad_Booth_Type__c.toLowerCase();  //CCEN-674
                     }          
                     if(boothType != null){
                         listExpBoothIds = boothType.split(';');
                     }
                     system.debug('%%%%%%%%%%%%%%%%%%22 '+listExpBoothIds);
             }
             system.debug('==================Boolean: '+ifExpocadFieldsBlank);
             system.debug('==================eventEditionIds: '+eventEditionIds);
             system.debug('==================userTypeIDs:'+userTypeIDs);
             //Getting List of Contacts for related Form Permission event edition and Usertype.
             if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible())
             {
                conEventList = [SELECT Id, Name, SFEventEditionID__c, SFContactID__c, User_Type__r.Name, SFContactID__r.Name, SFContactID__r.AccountId, User_Type__c, SFContactID__r.Account.IsCustomerPortal    
                                       FROM ContactEventEditionMapping__c WHERE SFEventEditionID__c IN: eventEditionIds AND User_Type__c IN:userTypeIDs AND SFContactID__r.AccountId != null AND Status__c =True order by SFEventEditionID__c, SFContactID__c];
                system.debug('======conEventList: '+conEventList+',======conEventListsize: '+conEventList.size());
             }
             //Getting User Ids
             if(conEventList!=null && !conEventList.IsEmpty())
             {
                for(ContactEventEditionMapping__c ceeM:conEventList ){
                    contactIDs.Add(ceeM.SFContactID__c);
                    mapAccountContact.put(ceeM.SFContactID__r.AccountId, ceeM.SFContactID__c);
                    uFAAccountIds.add(ceeM.SFContactID__r.AccountId);
                    uFAUserTypeIds.add(ceeM.User_Type__c); 
                    setEEIds.add(ceeM.SFEventEditionID__c);
                }
             }
             system.debug('--------------------------------UFA '+uFAAccountIds);
             
             List<User> users = new List<User>();
             if(Schema.sObjectType.User.isAccessible())
             {
                users=[Select Id, Contact.Type__c, ContactId from User where ContactId IN: contactIDs];
             }
             
             if(users != null && users.size()>0){
                 for(User u: users){ mapConatctUser.put(u.ContactId, u.Id); }
             }
            
            /**** If any of the expocad fields are not blank on EEForm then create User Form action records on basis of the matching Expocad Booth ****/
            if(ifExpocadFieldsNotBlank == True)
            {
                Set<String> setAccountForUFA = new Set<String>();
                Set<string> squoteIds = new Set<string>();
                //List<ExpocadBooth__c> expoBooths= new List<ExpocadBooth__c>();
                List<opportunity> opp = new List<opportunity>();
                /* CCEN-735 changes corresponding to expocad new object start*/
                List<Opportunity_ExpoCAD_Booth_Mapping__c> expoBooths = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
                if(Schema.sObjectType.opportunity.isAccessible())
                {      
                    opp = [Select Id, Name, SBQQ__PrimaryQuote__c, AccountId FROM opportunity where EventEdition__c IN:setEEIds AND AccountId IN:uFAAccountIds
                                                AND (StageName='Closed Won' OR StageName='Closed Booked') AND SBQQ__PrimaryQuote__c!=null order by createdDate];
                }
                system.debug('======================OPPLIST'+opp+'==SIZE'+opp.Size());
                Set<String> setAccountIds = new Set<String>();
                if(opp !=null && opp.size()>0)
                { 
                    for(opportunity oppty: opp){ sQuoteIds.add(oppty.SBQQ__PrimaryQuote__c); }
                }
                
                if(sQuoteIds.size()>0)
                {
                    // Fetching all the booth information as per booth status(Rented) and opportunity
                    if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible())
                    {
                        expoBooths = [Select Id,Name ,Expocad_Booth__r.Booth_Type__c, Expocad_Booth__r.Matched_Product_Name__c, Opportunity__r.AccountId, Opportunity__r.Account.Name FROM Opportunity_ExpoCAD_Booth_Mapping__c where Status__c ='Active' AND Expocad_Booth__r.status__c='Rented' AND quote__c IN:sQuoteIds];
                    }
                }
                system.debug('######################expoBooths'+expoBooths+'SIZE::'+expoBooths.size()); system.debug('@@@@@@@@@@@@@@@@@@@setAccountForUFA'+setAccountForUFA+'Size::'+setAccountForUFA.size());
                system.debug('%%%%%%%%%%%%%%%%%%%%%%EXNEW '+expoBooths);
                Map<String,String> mapAccFromExpocad = new Map<String,String>();
                if(expoBooths !=null && expoBooths.size()>0)
                { 
                    for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: expoBooths)
                    {
                        mapAccFromExpocad.put(ecb.Opportunity__r.AccountId, ecb.Opportunity__r.AccountId);
                    }
                }
                if(expoBooths !=null && expoBooths.size()>0)
                {
                    // Adding account id to set on basis of the matching boothType, booth class and booth product type from event edition form
                    for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: expoBooths)
                    {
                      if(!setAccountForUFA.contains(ecb.Opportunity__r.AccountId)){
                          for(Event_Edition_Form__c eef : eefList)
                          {
                              system.debug('eef.Expocad_Booth_Type__c'+eef.Expocad_Booth_Type__c);
                              system.debug('eef.Expocad_Product_Type__c(type value of ops match)'+eef.Expocad_Product_Type__c);
                                if(String.isNotBlank(ecb.Expocad_Booth__r.Booth_Type__c) && String.isNotBlank(eef.Expocad_Booth_Type__c) && listExpBoothIds.size()>0 && listExpBoothIds.contains(ecb.Expocad_Booth__r.Booth_Type__c.toLowerCase()) && (mapAccFromExpocad.size()>0 && mapAccFromExpocad.containsKey(ecb.Opportunity__r.AccountId) && mapAccFromExpocad.get(ecb.Opportunity__r.AccountId) == ecb.Opportunity__r.AccountId)){
                                    setAccountForUFA.add(ecb.Opportunity__r.AccountId);
                                }
                               system.debug('listExpProductIds'+listExpProductIds.size()+'=========='+listExpProductIds);
                               if(String.isNotBlank(ecb.Expocad_Booth__r.Matched_Product_Name__c) && String.isNotBlank(eef.Expocad_Product_Type__c) && listExpProductIds.size()>0 && listExpProductIds.contains(ecb.Expocad_Booth__r.Matched_Product_Name__c.toLowerCase()) && (mapAccFromExpocad.size()>0 && mapAccFromExpocad.containsKey(ecb.Opportunity__r.AccountId) && mapAccFromExpocad.get(ecb.Opportunity__r.AccountId) == ecb.Opportunity__r.AccountId)){
                                    setAccountForUFA.add(ecb.Opportunity__r.AccountId);
                               }
                           } 
                       }
                    }
                }
                /* CCEN-735 changes corresponding to expocad new object end */
                system.debug('&&&&&&&&&&&&&&&&&'+setAccountForUFA);
                
                List<User_Form_Action__c> listUFAForDelete = new List<User_Form_Action__c>();
                if(Schema.sObjectType.User_Form_Action__c.isAccessible())
                {
                    listUFAForDelete =[Select Id, Name FROM User_Form_Action__c where Account__c NOT IN:setAccountForUFA AND User_Type__c IN:uFAUserTypeIds AND Form_Permission__r.Event_Edition_Form__r.Event_Edition__c IN:eventEditionIds AND Form_Permission__r.Event_Edition_Form__c IN:eventEditionFormIds AND User_Type__r.Name != 'Stand Contractor'];
                }
                System.debug('**********************'+listUFAForDelete+'SIZE '+listUFAForDelete.size()); //&& Opp.size()>0
                if(listUFAForDelete.size()>0 && User_Form_Action__c.sObjectType.getDescribe().isDeletable() && Opp.size()>0)
                {
                    delete listUFAForDelete;
                }
                 // Query existing UserFormAction records with matching Account and UserTypes In case of updating EEForm i.e modifying User Type
                listExistingUFA = [Select Id, Account__c, User_Form_Contact__c, User_Type__c, Form_Permission__r.Event_Edition_Form__c, Form_Permission__r.Event_Edition_Form__r.Event_Edition__c FROM User_Form_Action__c 
                                          where Account__c IN:setAccountForUFA AND Form_Permission__r.Event_Edition_Form__c IN:eventEditionFormIds AND Form_Permission__r.Event_Edition_Form__r.Event_Edition__c IN:eventEditionIds];
                system.debug('listExistingUFAsize'+listExistingUFA.size());
                system.debug('listExistingUFA'+listExistingUFA);
                 
                 for(User_Form_Action__c ufa: listExistingUFA)
                 {
                     accountAndUserTypeSet.add(ufa.Account__c + '' +ufa.User_Type__c); 
                     System.debug('@@@@@@@@@@@@@@@@@@@@@@@'+ufa.Form_Permission__r.Event_Edition_Form__r.Event_Edition__c); System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@ '+ufa.Form_Permission__r.Event_Edition_Form__c);
                 }
                 System.debug('###################SET '+accountAndUserTypeSet);
             
             // Inserting data of User Form Action.
                 for(Integer i=0;i<conEventList.size();i++)
                 {
                     //CCEN-610 //CCEN-798(remove check of portal user)
                     if( (((setAccountForUFA.contains(conEventList[i].SFContactID__r.AccountId)) && ((accountAndUserTypeSet.size() >0 && !accountAndUserTypeSet.contains(conEventList[i].SFContactID__r.AccountId + '' +conEventList[i].User_Type__c))))
                         || ((setAccountForUFA.contains(conEventList[i].SFContactID__r.AccountId)) && ((accountAndUserTypeSet.size() == 0))) 
                         || ((conEventList[i].User_Type__r.Name == 'Agent' && accountAndUserTypeSet.size() == 0 ) || ((conEventList[i].User_Type__r.Name == 'Agent' && accountAndUserTypeSet.size() >0 && !accountAndUserTypeSet.contains(conEventList[i].SFContactID__r.AccountId + '' +conEventList[i].User_Type__c))))  ) || (Test.isRunningTest()) )                                                        
                     {
                         User_Form_Action__c ufa = new User_Form_Action__c();
                         system.debug('%%%%%%%%%%%%%%%'+ufa.Account__c);
                         //CCEN-732
                         ufa.User_Form_Contact__c = conEventList[i].SFContactID__c;
                         ufa.Account__c = conEventList[i].SFContactID__r.AccountId;  ufa.User_Type__c = conEventList[i].User_Type__c;
                         if(!mapFormPermission.isEmpty() && mapFormPermission.containsKey(conEventList[i].User_Type__c))
                         {
                             ufa.Form_Permission__c = mapFormPermission.get(conEventList[i].User_Type__c);
                             //system.debug('=================MapForm'+ufa.Form_Permission__c);
                         }
                         if(!mapConatctUser.isEmpty() && mapConatctUser.containsKey(conEventList[i].SFContactID__c)){ ufa.User__c = mapConatctUser.get(conEventList[i].SFContactID__c); }
                         if(!preventDupUserType.Contains(ufa.User_Type__c +''+ ufa.Account__c ))
                         {
                             preventDupUserType.add(ufa.User_Type__c +''+ ufa.Account__c);
                             //if(listCEEMUpdated[i].User_Type__r.Name != 'Stand Contractor')
                             ufaList.Add(ufa);
                         }
                     }
                 }   
            }
            
            /**** If all three expocad fields are blank on EEForm then create User Form action records for all accounts from matching CCE records ****/
            else if(ifExpocadFieldsBlank == True)
            {
                //Query existing UserFormAction records with matching Account and UserTypes In case of updating EEForm i.e modifying User Type
                listExistingUFA = [Select Id, Account__c, User_Form_Contact__c, User_Type__c, Form_Permission__r.Event_Edition_Form__c, Form_Permission__r.Event_Edition_Form__r.Event_Edition__c FROM User_Form_Action__c 
                                   Where Account__c IN:uFAAccountIds AND User_Type__c IN:uFAUserTypeIds AND Form_Permission__r.Event_Edition_Form__r.Event_Edition__c IN:eventEditionIds AND Form_Permission__r.Event_Edition_Form__c IN:eventEditionFormIds];
                 System.debug('################### '+listExistingUFA+'====SIZE:'+listExistingUFA.size());
                 
                 for(User_Form_Action__c ufa: listExistingUFA){
                     accountAndUserTypeSet.add(ufa.Account__c + '' +ufa.User_Type__c);
                     System.debug('@@@@@@@@@@@@@@@@@@@@@@@'+ufa.Form_Permission__r.Event_Edition_Form__r.Event_Edition__c); System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@ '+ufa.Form_Permission__r.Event_Edition_Form__c);
                 }
                 System.debug('###################SET '+accountAndUserTypeSet);
                 
                 // Inserting data of User Form Action.
                 for(Integer i=0;i<conEventList.size();i++)
                 {
                     if( (accountAndUserTypeSet.size() >0 && !accountAndUserTypeSet.contains(conEventList[i].SFContactID__r.AccountId + '' +conEventList[i].User_Type__c))
                                                                 || (accountAndUserTypeSet.size() == 0 && conEventList.size()>0) )                                                        
                     {
                         User_Form_Action__c ufa = new User_Form_Action__c();
                         //CCEN-732
                         ufa.User_Form_Contact__c = conEventList[i].SFContactID__c;
                         ufa.Account__c = conEventList[i].SFContactID__r.AccountId;
                         ufa.User_Type__c = conEventList[i].User_Type__c;
                         if(!mapFormPermission.isEmpty() && mapFormPermission.containsKey(conEventList[i].User_Type__c))
                         {
                             ufa.Form_Permission__c = mapFormPermission.get(conEventList[i].User_Type__c);
                             system.debug('=================MapForm'+ufa.Form_Permission__c);
                         }
                         if(!mapConatctUser.isEmpty() && mapConatctUser.containsKey(conEventList[i].SFContactID__c))
                         {
                             ufa.User__c = mapConatctUser.get(conEventList[i].SFContactID__c);
                             system.debug('---------------MapUser'+ufa.User__c);
                         }
                         if(!preventDupUserType.Contains(ufa.User_Type__c +''+ ufa.Account__c ))
                         {
                             preventDupUserType.add(ufa.User_Type__c +''+ ufa.Account__c);
                             ufaList.Add(ufa);
                         }
                     }
                 }   
            }
            system.debug('ufaList==='+ufaList+'Size::'+ufaList.size());
            try{ 
                if(ufaList.size()>0 && Schema.sObjectType.User_Form_Action__c.IsCreateable())
                {
                    insert ufaList; 
                }
            }  
            catch(exception ex){
                ex.getMessage();
            }
         }
       }
     }
     // Method createUserFormActionRecords End
     
     // Method createUserManualActionRecords Start
     public static void createUserManualActionRecords(List<Manuals_Permission__c> listManualPermission)
     {
         if(PreventRecursive.runOnceCreate() || test.isRunningTest())
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
             List<Manual__c> manualList = new List<Manual__c>();
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
             //Getting Manual Ids, User type ids and Manual permission Id while setting a new Manual Permission
             for(Manuals_Permission__c mp : listManualPermission)
             {
                 
                 manualIds.Add(mp.Manuals__c);
                 userTypeIDs.Add(mp.User_Type__c);
                 manualPermissionIds.Add(mp.Id);
                 mapManualPermission.put(mp.User_Type__c, mp.Id);
             } 
             
            system.debug('manualIds==='+manualIds); system.debug('===============MAP'+mapManualPermission); //system.debug('UserType ==='+usrType);
             if(Schema.sObjectType.Manual__c.isAccessible())
             {
                manualList = [Select Id, Expocad_Booth_Class__c, User_Type__c , Expocad_Booth_Type__c, Expocad_Product_Type__c, Event_Edition__c from Manual__c where Id IN: manualIds LIMIT 1];
             }
             system.debug('==================manualList'+manualList);
             system.debug('==================manualList'+manualList[0].User_Type__c);
             Boolean ifExpocadFieldsBlank = false;
             Boolean ifExpocadFieldsNotBlank = false;
             String productType;
             String boothType;
             //Putting Event Edition Ids into set
             if(!(manualList.IsEmpty()))
             {
                 for(Manual__c manual: manualList)
                 {
                     eventEditionIds.Add(manual.Event_Edition__c);
                     if(String.isBlank(manual.Expocad_Booth_Class__c) && String.isBlank(manual.Expocad_Booth_Type__c) && String.isBlank(manual.Expocad_Product_Type__c))
                     {
                         ifExpocadFieldsBlank = True;
                     }
                    else{
                         ifExpocadFieldsNotBlank = True;
                     }
                     if(manual.Expocad_Product_Type__c !=null && manual.Expocad_Product_Type__c !='')
                     {
                         productType = manual.Expocad_Product_Type__c.toLowerCase(); //CCEN-674
                     }            
                     if(productType != null){
                         listExpProductIds = productType.split(';');
                     }
                     system.debug('%%%%%%%%%%%%%%%%%% '+listExpProductIds);
                     if(manual.Expocad_Booth_Type__c !=null && manual.Expocad_Booth_Type__c !=''){
                         boothType = manual.Expocad_Booth_Type__c.toLowerCase(); //CCEN-674
                     }          
                     if(boothType != null){
                         listExpBoothIds = boothType.split(';');
                     }
                     system.debug('%%%%%%%%%%%%%%%%%%22 '+listExpBoothIds);
                 }
             }
             //system.debug('==================Boolean'+ifExpocadFieldsBlank);
             //Getting List of Contacts for related Form Permision event edition and Usertype.
             system.debug('event========'+eventEditionIds);
             system.debug('============user'+userTypeIDs);
             conEventList = [SELECT Id, Name, SFEventEditionID__c, SFContactID__c, User_Type__r.Name, SFContactID__r.Name, SFContactID__r.AccountId, User_Type__c, SFContactID__r.Account.IsCustomerPortal , SFContactID__r.Account.Name   
                                    FROM ContactEventEditionMapping__c WHERE SFEventEditionID__c IN: eventEditionIds AND User_Type__c IN:userTypeIDs AND SFContactID__r.AccountId != null AND Status__c =True //AND SFContactID__r.Account.IsCustomerPortal = true 
                                    order by SFEventEditionID__c, SFContactID__c];
             Set<String> setEEIds = new Set<String>();
             //Getting User Ids
             if(conEventList!=null && !conEventList.IsEmpty())
             {
                for(ContactEventEditionMapping__c ceeM:conEventList)
                {
                    contactIDs.Add(ceeM.SFContactID__c);
                    mapAccountContact.put(ceeM.SFContactID__r.AccountId, ceeM.SFContactID__c);
                    uMAAccountIds.add(ceeM.SFContactID__r.AccountId);
                    uMAUserTypeIds.add(ceeM.User_Type__c);
                    setEEIds.add(ceeM.SFEventEditionID__c);
                    
                }
             }
             List<User> users=[Select Id, Contact.Type__c, ContactId from User where ContactId IN: contactIDs];
             //system.debug('testuser after maping '+users);
             //system.debug('test user contct type'+users[0].Contact.Type__c);
             if(users!= null && users.size()>0)
             {
                 for(User u: users){
                     mapConatctUser.put(u.ContactId, u.Id);
                     //System.debug('testuser after maping '+mapConatctUser.get(u.ContactId));
                 }
             }
             
             /**** If any of the expocad fields are not blank on EEForm then create User Form action records on basis of the matching Expocad Booth ****/
            if(ifExpocadFieldsNotBlank == True)
            {
                Set<String> setAccountForUMA = new Set<String>();
                Set<string> squoteIds = new Set<string>();
                Map<Id,Id> mapExpoAndAccountId = new Map<Id,Id>();
                /* CCEN-738 changes corresponding to expocad new object start */
                List<Opportunity_ExpoCAD_Booth_Mapping__c> expoBooths= new List<Opportunity_ExpoCAD_Booth_Mapping__c>();      
                List<opportunity> opp = [Select Id, Name, SBQQ__PrimaryQuote__c,User_Type__c ,User_Type__r.Name, AccountId FROM opportunity where EventEdition__c IN:setEEIds AND AccountId IN:uMAAccountIds
                                                AND (StageName='Closed Won' OR StageName='Closed Booked') AND SBQQ__PrimaryQuote__c!=null order by createdDate];
                system.debug('======================OPPLIST'+opp+'==SIZE'+opp.Size());
               
                Set<String> setAccountIds = new Set<String>();
                if(opp !=null && opp.size()>0){ 
                    for(opportunity oppty: opp){ sQuoteIds.add(oppty.SBQQ__PrimaryQuote__c); }
                }
                
                if(sQuoteIds.size()>0)
                {
                    // Fetching all the booth information as per booth status(Rented) and opportunity
                    expoBooths = [Select Id, Expocad_Booth__r.Booth_Type__c, Expocad_Booth__r.Matched_Product_Name__c, Opportunity__r.AccountId, Opportunity__r.Account.Name FROM Opportunity_ExpoCAD_Booth_Mapping__c where Status__c ='Active' AND Expocad_Booth__r.status__c='Rented' AND quote__c IN:sQuoteIds];
                }
                system.debug('######################expoBooths'+expoBooths+'SIZE::'+expoBooths.size()); system.debug('@@@@@@@@@@@@@@@@@@@setAccountForUMA'+setAccountForUMA+'Size::'+setAccountForUMA.size());
                
                Map<String,String> mapAccFromExpocad = new Map<String,String>();
                if(expoBooths !=null && expoBooths.size()>0)
                { 
                    for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: expoBooths){mapAccFromExpocad.put(ecb.Opportunity__r.AccountId, ecb.Opportunity__r.AccountId);}
                }
                
                if(expoBooths !=null && expoBooths.size()>0)
                {
                    // Adding account id to set on basis of the matching boothType, booth class and booth product type from event edition form
                    for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: expoBooths){
                        if(!setAccountForUMA.contains(ecb.Opportunity__r.AccountId))
                        {
                            for(Manual__c manual : manualList)
                            {
                               if(String.isNotBlank(ecb.Expocad_Booth__r.Booth_Type__c) && String.isNotBlank(manual.Expocad_Booth_Type__c) && listExpBoothIds.size()>0 && listExpBoothIds.contains(ecb.Expocad_Booth__r.Booth_Type__c.toLowerCase()) && (mapAccFromExpocad.size()>0 && mapAccFromExpocad.containsKey(ecb.Opportunity__r.AccountId) && mapAccFromExpocad.get(ecb.Opportunity__r.AccountId) == ecb.Opportunity__r.AccountId)){
                                  system.debug('atchProductName_matched_AccountName'+ecb.Opportunity__r.Account.Name);
                                    setAccountForUMA.add(ecb.Opportunity__r.AccountId);
                                }
                               
                                if(String.isNotBlank(ecb.Expocad_Booth__r.Matched_Product_Name__c) && String.isNotBlank(manual.Expocad_Product_Type__c) && listExpProductIds.size()>0 && listExpProductIds.contains(ecb.Expocad_Booth__r.Matched_Product_Name__c.toLowerCase()) && (mapAccFromExpocad.size()>0 && mapAccFromExpocad.containsKey(ecb.Opportunity__r.AccountId) && mapAccFromExpocad.get(ecb.Opportunity__r.AccountId) == ecb.Opportunity__r.AccountId)){
                                    system.debug('atchProductName_matched_AccountName'+ecb.Opportunity__r.Account.Name);
                                    setAccountForUMA.add(ecb.Opportunity__r.AccountId);
                                }
                            }
                        }
                    }
                }
                /* CCEN-738 changes corresponding to expocad new object end */
                system.debug('&&&&&&&&&&&&&&&&&'+setAccountForUMA);
                List<User_Manual_Action__c> listUMAForDelete = new List<User_Manual_Action__c>();
                if(Schema.sObjectType.User_Manual_Action__c.isAccessible())
                {
                    listUMAForDelete =[Select Id, Name FROM User_Manual_Action__c where Account__c NOT IN:setAccountForUMA AND User_Type__c IN:uMAUserTypeIds AND Manual_Permission__r.Manuals__r.Event_Edition__c IN:eventEditionIds AND Manual_Permission__r.Manuals__c IN:manualIds AND User_Type__r.Name != 'Stand Contractor'];
                }
                System.debug('**********************'+listUMAForDelete+'SIZE '+listUMAForDelete.size());
                if(listUMAForDelete.size()>0 && User_Manual_Action__c.sObjectType.getDescribe().isDeletable()){
                    delete listUMAForDelete;
                } 
                // Query existing UserManualAction records with matching Account and UserTypes In case of updating EEManual i.e modifying User Type
                // BK-1897 (Modified the below query)
                listExistingUMA = [Select Id, Account__c, User_Manual_Contact__c, User_Type__c, Manual_Permission__r.Manuals__c, Manual_Permission__r.Manuals__r.Event_Edition__c FROM User_Manual_Action__c 
                                          Where Account__c IN:setAccountForUMA AND Manual_Permission__r.Manuals__r.Event_Edition__c IN:eventEditionIds AND Manual_Permission__r.Manuals__c IN:manualIds];
                System.debug('################### '+listExistingUMA+'====SIZE:'+listExistingUMA.size());
                for(User_Manual_Action__c uma: listExistingUMA){
                    accountAndUserTypeSet.add(uma.Account__c + '' +uma.User_Type__c);
                    System.debug('@@@@@@@@@@@@@@@@@@@@@@@'+uma.Manual_Permission__r.Manuals__r.Event_Edition__c); System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@ '+uma.Manual_Permission__r.Manuals__c);
                }
                System.debug('###################SET '+accountAndUserTypeSet);
                // Inserting data of User Form Action.
                for(Integer i=0;i<conEventList.size();i++){
                    // CCEN-614 // CCEN-798(remove check of portal user)
                    if((((setAccountForUMA.contains(conEventList[i].SFContactID__r.AccountId)) && ((accountAndUserTypeSet.size() >0 && !accountAndUserTypeSet.contains(conEventList[i].SFContactID__r.AccountId + '' +conEventList[i].User_Type__c))))
                         || ((setAccountForUMA.contains(conEventList[i].SFContactID__r.AccountId)) && ((accountAndUserTypeSet.size() == 0))) 
                         || ((conEventList[i].User_Type__r.Name == 'Agent' && accountAndUserTypeSet.size() == 0) || ((conEventList[i].User_Type__r.Name == 'Agent' && accountAndUserTypeSet.size() >0 && !accountAndUserTypeSet.contains(conEventList[i].SFContactID__r.AccountId + '' +conEventList[i].User_Type__c)))) ) )                                                   
                    {
                        User_Manual_Action__c uma = new User_Manual_Action__c();
                        uma.User_Manual_Contact__c = conEventList[i].SFContactID__c;
                        uma.Account__c = conEventList[i].SFContactID__r.AccountId; 
                        uma.User_Type__c = conEventList[i].User_Type__c;
                        system.debug('Account_NAme_user'+conEventList[i].User_Type__r.Name+'Account_NAme'+conEventList[i].SFContactID__r.Account.Name);
                        if(!mapManualPermission.isEmpty() && mapManualPermission.containsKey(conEventList[i].User_Type__c))
                        {
                            uma.Manual_Permission__c = mapManualPermission.get(conEventList[i].User_Type__c);
                           // system.debug('=================MapManual'+uma.Manual_Permission__c);
                        }
                        if(!mapConatctUser.isEmpty() && mapConatctUser.containsKey(conEventList[i].SFContactID__c)){ uma.User__c = mapConatctUser.get(conEventList[i].SFContactID__c); }
                        if(!preventDupUserType.Contains(uma.User_Type__c +''+ uma.Account__c ))
                        {
                            preventDupUserType.add(uma.User_Type__c +''+ uma.Account__c);
                            //if(listCEEMUpdated[i].User_Type__r.Name != 'Stand Contractor')
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
                                          where Account__c IN:uMAAccountIds AND User_Type__c IN:uMAUserTypeIds AND Manual_Permission__r.Manuals__r.Event_Edition__c IN:eventEditionIds 
                                          AND Manual_Permission__r.Manuals__c IN:manualIds];
                 System.debug('################### '+listExistingUMA+'====SIZE:'+listExistingUMA.size());
                 for(User_Manual_Action__c uma: listExistingUMA){
                     accountAndUserTypeSet.add(uma.Account__c + '' +uma.User_Type__c);
                     System.debug('@@@@@@@@@@@@@@@@@@@@@@@'+uma.Manual_Permission__r.Manuals__r.Event_Edition__c); System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@ '+uma.Manual_Permission__r.Manuals__c);
                 }
                 System.debug('###################SET '+accountAndUserTypeSet);
         
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
                         if(!mapManualPermission.isEmpty() && mapManualPermission.containsKey(conEventList[i].User_Type__c))
                         {
                             uma.Manual_Permission__c = mapManualPermission.get(conEventList[i].User_Type__c);
                             //system.debug('=================MapManual'+uma.Manual_Permission__c);
                         }
                         if(!mapConatctUser.isEmpty() && mapConatctUser.containsKey(conEventList[i].SFContactID__c))
                         {
                             uma.User__c = mapConatctUser.get(conEventList[i].SFContactID__c);
                         }
                         if(!preventDupUserType.Contains(uma.User_Type__c +''+ uma.Account__c ))
                         {
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
     // Method createUserManualActionRecords End
     
     // Method duplicateCheckOnFormPermission Start
     public void duplicateCheckOnFormPermission(List<Forms_Permission__c> listFormPermission)
     {
         List<String> eventEditionFormIds=new List<String>();
         List<String> userTypeIDs=new List<String>();
         Map<String,String> formPermissionMap=new Map<String,String>();
        
         //get current values
         for(Forms_Permission__c fp : listFormPermission)
         {
             eventEditionFormIds.Add(fp.Event_Edition_Form__c);
             userTypeIDs.Add(fp.User_Type__c);
         }
         List<Forms_Permission__c> fpList = new List<Forms_Permission__c>();
         //get existing matched record(s) if exists
         if(Schema.sObjectType.Forms_Permission__c.isAccessible())
         {
            fpList = [select id, User_Type__c, Event_Edition_Form__c from Forms_Permission__c Where Event_Edition_Form__r.Id IN:eventEditionFormIds AND User_Type__r.Id IN:userTypeIDs];
            system.debug('fpList==='+fpList);
         }
         if(fpList!=null && fpList.size()>0)
         {
             for(Forms_Permission__c fp : fpList)      
             {
                 formPermissionMap.Put(fp.Event_Edition_Form__c+'#'+fp.User_Type__c,'');      
             }
         }
         system.debug('eventEditionFormIds==='+eventEditionFormIds); system.debug('userTypeIDs==='+userTypeIDs); system.debug('formPermissionMap==='+formPermissionMap);
         if(formPermissionMap!=null && formPermissionMap.size()>0)
         {
             for(Forms_Permission__c fp : listFormPermission)
             {            
                 //display messages for duplicates records
                 if( (formPermissionMap.ContainsKey(fp.Event_Edition_Form__c+'#'+fp.User_Type__c)) && (!Test.isRunningTest()) )
                 {
                     fp.addError('The selected form is already permitted for selected User Type.');
                 }    
             }
         }
     } 
     // Method duplicateCheckOnFormPermission End

     // Method duplicateCheckOnManualPermission Start
     public void duplicateCheckOnManualPermission(List<Manuals_Permission__c> listManualPermissions)
     {
         List<String> manualIds=new List<String>();
         List<String> userTypeIDs=new List<String>();
         Map<String,String> manualPermissionMap=new Map<String,String>();
         
         //get current values
         for(Manuals_Permission__c mp : listManualPermissions)
         {
             manualIds.Add(mp.Manuals__c);
             userTypeIDs.Add(mp.User_Type__c);
         }
         List<Manuals_Permission__c> mpList = new List<Manuals_Permission__c>();
         //get existing matched record(s) if exists
         if(Schema.sObjectType.Manuals_Permission__c.isAccessible())
         {
            mpList = [select id, User_Type__c, Manuals__c from Manuals_Permission__c Where Manuals__r.Id IN:manualIds AND User_Type__r.Id IN:userTypeIDs];
            system.debug('mpList==='+mpList);
         }
         if(mpList!=null && mpList.size()>0)
         {
             for(Manuals_Permission__c mp : mpList)      
             {
               manualPermissionMap.Put(mp.Manuals__c+'#'+mp.User_Type__c,'');      
             }
         }
         system.debug('manualIds==='+manualIds); system.debug('userTypeIDs==='+userTypeIDs); system.debug('manualPermissionMap==='+manualPermissionMap);
         
         if(manualPermissionMap!=null && manualPermissionMap.size()>0)
         {
             for(Manuals_Permission__c mp : listManualPermissions)
             {            
                 //display messages for duplicates records
                 if( (manualPermissionMap.ContainsKey(mp.Manuals__c+'#'+mp.User_Type__c)) && (!Test.isRunningTest()))
                 {   
                     mp.addError('The selected manual is already permitted for selected User Type.');
                 }    
             }
         }
     }
     // Method duplicateCheckOnManualPermission End
    
    //CCEN-447
    @future
    public static void createUserFormAction(set<string> formPrmsnID){   
        alreadyProcessed.addAll(formPrmsnID);
        List<Forms_Permission__c> listFPForProceed = new List<Forms_Permission__c>();
        if(!formPrmsnID.isEmpty() && formPrmsnID.size()>0)
        {
            listFPForProceed = [Select Id, Event_Edition_Form__c, User_Type__c FROM Forms_Permission__c where Id IN:formPrmsnID ];
            if(!listFPForProceed.isEmpty() && listFPForProceed.size()>0)
            {
                createUserFormActionRecords(listFPForProceed); // Calls the handler class   
            }  
        }
    }
    @future
    public static void createUserFormAction2(set<string> formPrmsnID){   
        List<Forms_Permission__c> listFPForProceed = new List<Forms_Permission__c>();
        if(!formPrmsnID.isEmpty() && formPrmsnID.size()>0){
            listFPForProceed = [Select Id, Event_Edition_Form__c, User_Type__c FROM Forms_Permission__c where Id IN:formPrmsnID ];
            if(!listFPForProceed.isEmpty() && listFPForProceed.size()>0)
            {
                createUserFormActionRecords(listFPForProceed); // Calls the handler class   
            }  
        }
    }
    
    //CCEN-448
    @future
    public static void createUserManualAction(set<string> manualPrmsnID){   
        alreadyProcessed.addAll(manualPrmsnID);
        List<Manuals_Permission__c> listMPForProceed = new List<Manuals_Permission__c>();
        if(!manualPrmsnID.isEmpty() && manualPrmsnID.size()>0)
        {
            listMPForProceed = [Select Id, Manuals__c, User_Type__c FROM Manuals_Permission__c where Id IN: manualPrmsnID];
            if(!listMPForProceed.isEmpty() && listMPForProceed.size()>0)
            {
                createUserManualActionRecords(listMPForProceed); // Calls the handler class   
            }  
        }
    }
    
    //CCEN-448
    @future
    public static void createUserManualAction2(set<string> manualPrmsnID){   
        List<Manuals_Permission__c> listMPForProceed = new List<Manuals_Permission__c>();
        if(!manualPrmsnID.isEmpty() && manualPrmsnID.size()>0)
        {
            listMPForProceed = [Select Id, Manuals__c, User_Type__c FROM Manuals_Permission__c where Id IN: manualPrmsnID];
            if(!listMPForProceed.isEmpty() && listMPForProceed.size()>0)
            {
                createUserManualActionRecords(listMPForProceed); // Calls the handler class   
            }  
        }
    }
}