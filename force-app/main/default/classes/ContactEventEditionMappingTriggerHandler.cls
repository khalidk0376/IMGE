/**
* Created/Modified By: Girikon(Amish, Pramod)/Aish
* Created On:          9/8/2017
* Modified By: Girikon(Aish,Sunil,Ashish) CCEN-241,CCEN-240
* Modified On     8/17/2018
* @description : This class is used 
*                         1. To create record(s) for "UserFormAction" and "UserManualAction" when a new record for ContactEventEditionMapping__c is created.
*                         2. To create community user if not already exists
*                         3. If existing user is not active then Activate user of contact 
* Methods:             handleAfterInsert, CreateCommunityUser
* Test Class:          ContactEventEditionMapping_Test(88%)
* Last Modified By:    [Aishwarya/CCEN-447(12 Dec 2018)],[Ashish/CCEN-585 (7 Jan 2019)],[Aishwarya CCEN-735/738 April 2 2019], [Aishwarya CCEN-732 May 31 2019], [Aishwarya BK-2098 Aug 2 2019],[Ashish/C2E-05(3 Sep 2019)],[Ashish/C2E-21(23 Sep 2019), [Aishwarya BK-16456 9 June 2021]
**/

public without sharing class ContactEventEditionMappingTriggerHandler 
{
    public void handleAfterInsert(List<ContactEventEditionMapping__c> lstConEvnMap) 
    {
        // handler logic    
        Set<Id> eventEdition= new Set<ID>();
        set<String> conEEMIdsForUser = new set<String>(); 
        list<ContactEventEditionMapping__c> contactEvntMpToCrtUsr = new list<ContactEventEditionMapping__c>();
        list<ContactEventEditionMapping__c> listCEMExhibitors = new list<ContactEventEditionMapping__c>();
        list<ContactEventEditionMapping__c> listCEMCoExhibitors = new list<ContactEventEditionMapping__c>();
        Set<Id> contactEEM= new Set<ID>();
        Set<Id> setCoExhconEEM= new Set<ID>();
        Set<Id> setExhConEEM= new Set<ID>(); 
        Set<Id> setAgentOwn= new Set<ID>();
        Set<String> cEEMUserType = new Set<String>();
        system.debug('In');
        if(!lstConEvnMap.isEmpty() && Schema.sObjectType.ContactEventEditionMapping__c.isAccessible())
        { 
            list<ContactEventEditionMapping__c> objConEvnMap= [Select Id,IsEmailSent__c, SFContactID__c, SFEventEditionID__c, User_Type__c, User_Type__r.Name, SFContactID__r.AccountId,Agent_Email_Body_Content_1__c,Agent_Email_Body_Content_2__c FROM ContactEventEditionMapping__c where Id IN:lstConEvnMap AND User_Type__c != null AND Status__c = True];
            //Iterate contact event edition mapping records
            for(ContactEventEditionMapping__c cEEM : objConEvnMap)
            {
                //Get event edition IDs
                eventEdition.Add(cEEM.SFEventEditionID__c);     

                //Restrict if Email sent is true and usertype is Agent Owned Exhibitor/CCEN-46                  
                if(cEEM.IsEmailSent__c == false)
                {
                    //  Restrict if Email sent is true and usertype is Agent /      [CCEN-240]
                    //  Added Agent Owned Exhibitor to create forms and manuals     [BK-2098]
                    //  Filter Individual Contract & AOE's Co-Exhibitor             [C2E-5] 
                    if(cEEM.User_Type__r.Name != 'Agent' && cEEM.User_Type__r.Name != 'Agent Owned Exhibitor' && cEEM.User_Type__r.Name != 'Exhibitor' && cEEM.User_Type__r.Name != 'Co-Exhibitor' )
                    {  
                        //Get ContactEventEditionMapping which are not agent and Agent Owned Exhibitor
                        contactEvntMpToCrtUsr.Add(cEEM);
                    }   
                    contactEEM.Add(cEEM.SFContactID__c);    // Add Contacts to Create Forms And Manual actions
                    cEEMUserType.Add(cEEM.User_Type__c);    // Add User Types to Create Forms And Manual actions

                    if(cEEM.User_Type__r.Name == 'Exhibitor')
                    {
                        listCEMExhibitors.add(cEEM);
                    }
                    if(cEEM.User_Type__r.Name == 'Co-Exhibitor')
                    {
                        listCEMCoExhibitors.add(cEEM);
                    }
                }
                if(cEEM.User_Type__r.Name == 'Agent Owned Exhibitor')
                {
                    setAgentOwn.add(cEEM.SFContactID__c);
                }                
            }
            
            if (setAgentOwn != null){
                AgentOwnExhibitorsCtrl objAgentOwnExh = new AgentOwnExhibitorsCtrl();
                objAgentOwnExh.sendEmailNotificationtoAgent(setAgentOwn,eventEdition); 
            }
           

            // Creating users Action (Forms & Manuals)
            CreateUserActions(eventEdition,contactEEM,lstConEvnMap,cEEMUserType);

            //update agent email body default values
            updateAgentEmailContent(objConEvnMap,eventEdition);

            // filter Individual Contract       [C2E-5]
            if(!listCEMExhibitors.isEmpty())
            {
                removeIndividualContract(listCEMExhibitors);    // remove Individual Contract from list of all exhbitors
            }
            // filter  AOE's Co-Exhibitor       [C2E-5]
            if(!listCEMCoExhibitors.isEmpty())
            {
                removeAOECoExhibitors(listCEMCoExhibitors);     // remove Agent owned exhibitor's Co-Exhibitors from list of all Co-Exhibitors
            }
            map<string,Event_Settings__c> mapEventSetting = new map <string,Event_Settings__c>();
            for(Event_Settings__c evntStng : [SELECT Id,Event_Edition__c,Send_Welcome_Email__c, Is_Event_Edition_Live__c FROM Event_Settings__c WHERE Event_Edition__c IN :eventEdition AND Is_Event_Edition_Live__c = True AND Send_Welcome_Email__c = True])
            {
                mapEventSetting.put(evntStng.Event_Edition__c,evntStng); //map of Event Ids with Event Setting 
            }                                                                            
            
            for(ContactEventEditionMapping__c cEEMobj : contactEvntMpToCrtUsr)
            {
                if(mapEventSetting.containsKey(cEEMobj.SFEventEditionID__c))
                {   
                    Event_Settings__c evntStng = mapEventSetting.get(cEEMobj.SFEventEditionID__c);
                    if(evntStng != null)
                    {   
                        // Create user only if Is_Event_Edition_Live__c = true & Send_Welcome_Email__c = true
                        if(evntStng.Is_Event_Edition_Live__c && evntStng.Send_Welcome_Email__c ) 
                        {
                            conEEMIdsForUser.add(cEEMobj.Id); // Adding ContactEventEditionMapping ids for creating users
                        }
                    }
                }
            }            
            if(conEEMIdsForUser.size()>0)
            {
                createCommunityUser(conEEMIdsForUser);  // Creating User 
            }            
        }
    }
    //update agent email body content from event setting 
    public void updateAgentEmailContent(list<ContactEventEditionMapping__c> lstConEvnMap,Set<Id> setEventEdition)
    {
        List<Event_Settings__c> lstEventSetting = new List<Event_Settings__c>([SELECT Id, Event_Edition__c,Is_Event_Edition_Live__c,Send_Welcome_Email__c,Postpone_Agent_Welcome_Email__c,Exhibitor_Email_Content1__c,Exhibitor_Email_Content2__c FROM Event_Settings__c WHERE Event_Edition__c IN :setEventEdition]);
        map<id,Event_Settings__c> mapEvnSet = new  map<id,Event_Settings__c>();

        list<ContactEventEditionMapping__c> lstConEvnMapUpdate= new list<ContactEventEditionMapping__c> ();
        list<ContactEventEditionMapping__c> lstConEvnMapAgent= new list<ContactEventEditionMapping__c> (); //C2E-21
        if(lstEventSetting.size()>0)
        {
            for(Event_Settings__c evntSet : lstEventSetting)
            {
                mapEvnSet.put(evntSet.Event_Edition__c,evntSet);
            }   
        }

        //postpone or send agent welcome email according to event setting  /CCEN-240 
        sendAgentwelcomeEmail(lstConEvnMap,setEventEdition,mapEvnSet); 

        //set<id> mapParentOpp = new  set<id>();
        if(lstConEvnMap.size()>0)
        {
            for(ContactEventEditionMapping__c conEvnMap : lstConEvnMap)
            {
                if(conEvnMap.User_Type__r.Name == 'Agent')
                {
                    lstConEvnMapAgent.add(conEvnMap);       //C2E - 21 Agent Badges 
                    if(mapEvnSet.containsKey(conEvnMap.SFEventEditionID__c))
                    {
                        conEvnMap.Agent_Email_Body_Content_1__c=mapEvnSet.get(conEvnMap.SFEventEditionID__c).Exhibitor_Email_Content1__c;
                        conEvnMap.Agent_Email_Body_Content_2__c=mapEvnSet.get(conEvnMap.SFEventEditionID__c).Exhibitor_Email_Content2__c;
                        lstConEvnMapUpdate.add(conEvnMap);
                    }
                }
            }
        }
        if(!lstConEvnMapAgent.isEmpty())
        {
            AgentOwnedExhibitorUtils.createAgentEventEditionMaping(lstConEvnMapAgent); // [C2E-21] Create Agent mapings
        }
        if(!lstConEvnMapUpdate.isEmpty() && Schema.sObjectType.ContactEventEditionMapping__c.isUpdateable())
        {
            update lstConEvnMapUpdate;
        }    
    }
    
    //postpone or send agent welcome email according to event setting    
    public void sendAgentwelcomeEmail(list<ContactEventEditionMapping__c> lstConEvnMap,Set<Id> setEventEdition,map<id,Event_Settings__c> mapEvnSet)
    {
        set<id>agent = new set<id>(); //tmp
        Set<Id> setAgentOwn= new Set<ID>();       
        list<ContactEventEditionMapping__c> contactEvntMpToCrtUsr= new list<ContactEventEditionMapping__c>(); // tmp
        set<String> conEEMCreteUserIds = new set<String>();

        map<string,ContactEventEditionMapping__c > conEvntMap = new map<string,ContactEventEditionMapping__c >();       
        for(ContactEventEditionMapping__c cEEM : lstConEvnMap)
        {
            if(mapEvnSet.size()>0 && mapEvnSet.containsKey(cEEM.SFEventEditionID__c))
            {
                Event_Settings__c evntStg = mapEvnSet.get(cEEM.SFEventEditionID__c);
                if(evntStg != null )
                {
                    //Create agent and send welcome email on its ContactEventEditionMapping creation with normal
                    if(cEEM.IsEmailSent__c == false  && cEEM.User_Type__r.Name == 'Agent')
                    {
                        if(evntStg.Is_Event_Edition_Live__c && evntStg.Send_Welcome_Email__c && !evntStg.Postpone_Agent_Welcome_Email__c)
                        {                                                        
                            conEEMCreteUserIds.add(cEEM.Id);
                        }
                    }
                    //geting agent own Exhibitors to get Agent further  
                    if(cEEM.User_Type__r.Name == 'Agent Owned Exhibitor')
                    {
                        if(evntStg.Is_Event_Edition_Live__c && evntStg.Send_Welcome_Email__c )
                        {
                            setAgentOwn.add(cEEM.SFContactID__c);
                        }
                    }
                }  
            }
        }        
        //getting Agents Contact id from agent own exhibitor's opportunity 
        list<opportunity> lstAgentOwnedOpp = new list<opportunity> ([select createdDate ,id,Name,EventEdition__c,parent_Opportunity__r.operations_contact__c,operations_contact__c from opportunity where  (StageName='Closed Won' OR StageName='Closed Booked') AND EventEdition__c IN :setEventEdition and parent_Opportunity__c!=null and operations_contact__c In :setAgentOwn order by createdDate desc limit 1000]);
        set<id> agentCon = new set<id>();
        Set<id> eventIds = new set<Id>();

        for(opportunity opp : lstAgentOwnedOpp) 
        {
            agentCon.add(opp.parent_Opportunity__r.operations_contact__c);
            eventIds.add(opp.EventEdition__c);
        }
        list<ContactEventEditionMapping__c>agentConEvMp = new list<ContactEventEditionMapping__c>();

        agentConEvMp = [select Id,SFContactID__c,SFEventEditionID__c from ContactEventEditionMapping__c where SFContactID__c in:agentCon  And SFEventEditionID__c in:eventIds AND Status__c =True];              
        for(ContactEventEditionMapping__c cEmp :agentConEvMp)
        {
            conEEMCreteUserIds.add(cEmp.Id);
        }       
        if (conEEMCreteUserIds != null && !conEEMCreteUserIds.isEmpty()) 
        {
            createCommunityUser(conEEMCreteUserIds);  //creating agent user
        }
    }
    // Filter Individual Contract [C2E-05]
    public void removeIndividualContract(list<ContactEventEditionMapping__c> objConEvnMap)
    {
        set<Id> setOppConIds = new set<Id> ();
        set<Id> setEventEdtnIds = new set<Id> ();
        set<string> setExhibitorConEvntIds = new set<String> ();
        set<string> setIndividualContractKey = new Set<string>();
        for(ContactEventEditionMapping__c ccMp:objConEvnMap)
        {
            setOppConIds.add(ccMp.SFContactID__c);
            setEventEdtnIds.add(ccMp.SFEventEditionID__c);
        }
        for(opportunity opp : [select id,Operations_Contact__c,EventEdition__c from opportunity where Operations_Contact__c in:setOppConIds And EventEdition__c in:setEventEdtnIds And (StageName='Closed Won' OR StageName='Closed Booked') and Exhibitor_Paid_By__c='Individual Contract' And parent_Opportunity__c = Null And Agent_s_Opportunity__c != null And Operations_Contact__c != null And EventEdition__c != null])
        {
            //string oppCon = opp.Operations_Contact__c.substring(0,15)+'#'+opp.EventEdition__c.substring(0,15);
            setIndividualContractKey.add(string.valueOf(opp.Operations_Contact__c)+'#'+string.valueOf(opp.EventEdition__c));
        }
        for(ContactEventEditionMapping__c ccMp:objConEvnMap)
        {            
            string key = string.valueOf(ccMp.SFContactID__c)+'#'+string.valueOf(ccMp.SFEventEditionID__c);
            if(!setIndividualContractKey.contains(key)) // Check For normal Exhibitor
            {
                setExhibitorConEvntIds.add(ccMp.Id);
            }
        }
        if(!setExhibitorConEvntIds.isEmpty())
        {
            createCommunityUser(setExhibitorConEvntIds);  //Create community user For normal exhibitors (not Individual Contract)
        }
    }
    // Filter AOE Co-Exhibitor [C2E-05]
    public void removeAOECoExhibitors(list<ContactEventEditionMapping__c> objConEvnMap)
    {
        set<Id> setOppConIds = new set<Id> ();
        set<Id> setEventEdtnIds = new set<Id> ();
        set<string> setExhibitorConEvntIds = new set<String> ();
        set<string> setIndividualContractKey = new Set<string>();
        for(ContactEventEditionMapping__c ccMp:objConEvnMap)
        {
            setOppConIds.add(ccMp.SFContactID__c);
            setEventEdtnIds.add(ccMp.SFEventEditionID__c);
        }
        for(opportunity opp : [select id,Operations_Contact__c,EventEdition__c from opportunity where Operations_Contact__c in:setOppConIds And EventEdition__c in:setEventEdtnIds And (StageName='Closed Won' OR StageName='Closed Booked') and Exhibitor_Paid_By__c='Co-Exhibitor Paid by Exhibitor' And (parent_Opportunity__c != null And parent_Opportunity__r.User_Type__r.Name = 'Agent Owned Exhibitor' ) And Operations_Contact__c != null And EventEdition__c != null])
        {
            //string oppCon = opp.Operations_Contact__c.substring(0,15)+'#'+opp.EventEdition__c.substring(0,15);
            setIndividualContractKey.add(string.valueOf(opp.Operations_Contact__c)+'#'+string.valueOf(opp.EventEdition__c));
        }
        for(ContactEventEditionMapping__c ccMp:objConEvnMap)
        {            
            string key = string.valueOf(ccMp.SFContactID__c)+'#'+string.valueOf(ccMp.SFEventEditionID__c);
            if(!setIndividualContractKey.contains(key)) // Check For normal Exhibitor
            {
                setExhibitorConEvntIds.add(ccMp.Id);
            }
        }
        if(!setExhibitorConEvntIds.isEmpty())
        {
            createCommunityUser(setExhibitorConEvntIds);  //Create community user For normal exhibitors (not Individual Contract)
        }
    }
    //Create community user(if not already existing) for contact from ConEEIds [CCEN-585]
    public void createCommunityUser(set<string> conEvntMapIDs)
    {   
        System.debug(' **Con EEM Ids == *** '+conEvntMapIDs);
        String commProfileName; 
        list<ContactEventEditionMapping__c> listConEEM = new list<ContactEventEditionMapping__c>(); 
        map<string,string>conToConEvntMap = new Map<string,string>(); // this is map of ContactIds To its ContactEventEditionMapping__c        
        Set<Id> setConEEMapIdsExitingUsers = new Set<Id>();
        Set<Id> setNewUserConIDs = new Set<Id>();
        Set<Id> setActiveUsersConIDs    = new Set<Id>();
        Set<Id> allConIds = new Set<Id>();        
        Set<Id> setConEvntIds = new Set<Id>();
        String commUsrProfile='';

        if(Label.Community_User_Profile!= NULL)
        {
            commUsrProfile= Label.Community_User_Profile;
        }
        else
        {
            commUsrProfile='Customer Community Login User Custom';
        }
        //Fetch community user profile        
        List<Profile> communityProfile =[select id, Name from Profile Where Name =:commUsrProfile]; 
        if(!communityProfile.isEmpty())
        {
            commProfileName=communityProfile[0].Name;
        }  
        //return;
        // Modified by Palla Kishore for the Ticket BK-22965
        for(ContactEventEditionMapping__c conEvm:[select id, SFContactID__c from ContactEventEditionMapping__c where id in:conEvntMapIDs AND Status__c =True AND SFContactID__c != null AND User_Type__r.name != 'Delegate'])
        {
            allConIds.add(conEvm.SFContactID__c); 
            listConEEM.add(conEvm);                
        }
        //Get existing user of contact with community profile   
        for(User usr: [Select Id, ContactId from User where ContactId != null AND ContactId IN: allConIds And Profile.Name=:commProfileName])
        {
            setActiveUsersConIDs.add(usr.ContactId);
        }
        
        for(ContactEventEditionMapping__c conEvm:listConEEM)
        {
            if(!setActiveUsersConIDs.contains(conEvm.SFContactID__c)) // Checking Exiting user or Not 
            {
                if(!setNewUserConIDs.contains(conEvm.SFContactID__c)) // Checking Duplicate ContactEventEditionMapping From same Contact
                {
                    setNewUserConIDs.add(conEvm.SFContactID__c);   //set of Contacts For Which user is to be Created 
                    setConEvntIds.add(conEvm.Id);  // Final Set of ContactEventEditionMapping Ids for which User needs to be made
                }
                else
                {
                    //  Incase of same Contact for Two Differnt Events 
                    System.debug('************* Contact Event Edition Id (Duplicate Contact Requested For User)************'+conEvm.Id);
                }
            }
            else
            {
                setConEEMapIdsExitingUsers.add(conEvm.Id);  // Final Set of ContactEventEditionMapping Ids for which User Already Exits 
            }                       
        }
        
        // Send Welcome Email TO exiting Users And Activate User if InActive
        if(setConEEMapIdsExitingUsers.size()>0)
        {
            BatchSendWelcomeEmailToExistingUsers objbatchActive= new BatchSendWelcomeEmailToExistingUsers(setConEEMapIdsExitingUsers);
            Database.executeBatch(objbatchActive,5);
        }
        
        //Batch class to create community user for remaining contacts in contactEEMNew
        if(setConEvntIds.size()>0)
        {
            BatchCreateCommunityUsers objbatch= new BatchCreateCommunityUsers(setConEvntIds,communityProfile[0].Id);
            Database.executeBatch(objbatch,1);
        }         
    }
    //Create "UserFormAction" and "UserManualAction" records
    public void createUserActions(Set<Id> eventEdition,Set<id> contactEEM,List<ContactEventEditionMapping__c> lstConEvnMap,Set<String> cEEMUserType) 
    {    
        Map<String,List<String>> mapUserTypeContact=new Map<String,List<String>>();
        List<User_Form_Action__c> userFormActList = new List<User_Form_Action__c>();
        List<User_Manual_Action__c> userManualActList = new List<User_Manual_Action__c>();
        system.debug('eventEdition: '+eventEdition); 
        system.debug('contactEEM: '+contactEEM);
        
        /*****************Enhancement for Form Start*****************/
        List<ContactEventEditionMapping__c> listCCEM = new List<ContactEventEditionMapping__c>();   
        List<Event_Edition_Form__c> listEEForms = new List<Event_Edition_Form__c>();
        List<User_Form_Action__c> ufaList = new List<User_Form_Action__c>();
        Set<String> setAccUserTypeExisting = new Set<String>();
        Set<String> setAccUserTypeExisting2 = new Set<String>();
        Set<String> eEFormIdsSet = new Set<String>();
        Map<Id, Forms_Permission__c> mapExistingFormPermission;
        Map<string,string> mapUTypeFormpId = new Map<string,string>();
        Map<Id,User_Form_Action__c> mapExistingUFActions;
        Map<Id,User_Form_Action__c> mapExistingUFActions2;
        Map<String,String> mapContactAccount = new Map<String,String>();
        Map<string,string> mapUserType = new Map<string,string>();
        String uTypeFromCCEM ='';
        Set<String> sContactAccountId = new Set<String>();
        Set<String> sQuoteIds = new Set<String>();
        Set<String> boothFeature = new Set<String>();
        Set<String> eefIdSet = new Set<String>();
        List<Opportunity_ExpoCAD_Booth_Mapping__c> expoBooths= new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        Set<String> setAccountForUFA = new Set<String>();
        List<opportunity> opp = new List<opportunity>();  
        List<Manual__c> listEEManuals = new List<Manual__c>();
        List<User_Manual_Action__c> umaList = new List<User_Manual_Action__c>();
        Set<String> setAccUserTypeExistingManuals = new Set<String>();
        Set<String> setAccountUserTypeExistingManuals2 = new Set<String>();
        Set<String> eEManualIdsSet = new Set<String>();
        Map<Id, Manuals_Permission__c> mapExistingManualPermission;
        Map<string,string> mapUTypeManualpId = new Map<string,string>();
        Map<Id,User_Manual_Action__c> mapExistingUAManuals;
        Map<Id,User_Manual_Action__c> mapExistingUAManuals2;
        Set<String> setAccountForUMA = new Set<String>();
        
        listCCEM =[Select Id, SFContactID__c, SFEventEditionID__c, User_Type__c, User_Type__r.Name, SFContactID__r.AccountId FROM ContactEventEditionMapping__c where SFContactID__c != null AND User_Type__c != null AND SFContactID__r.AccountId != null AND SFContactID__c IN:contactEEM AND Status__c =True];
        System.Debug('######listCCEM: '+listCCEM);
        for(ContactEventEditionMapping__c cEEM: listCCEM)
        {
            mapContactAccount.put(cEEM.SFContactID__c, cEEM.SFContactID__r.AccountId);
            uTypeFromCCEM = cEEM.User_Type__r.Name;
            sContactAccountId.add(cEEM.SFContactID__r.AccountId);
        }
        system.debug('-------------------------'+mapContactAccount); 
        Set<string> uTypeNameSet = new Set<string>();
        // put UserType Name from object - UserType into map in order to match the UserType id for providing the Form Permission
        for(User_Type__c userType :[select id, Name from User_Type__c LIMIT 100])
        {
            mapUserType.put(userType.Id, userType.Id);
            system.debug('==================MAP'+mapUserType);
            uTypeNameSet.add(userType.Name +';');
        }
        system.debug('==================UNAME::'+uTypeNameSet);
        
        // check eventEditionForms for this matching event edition from ContactEventEditionMapping 
        if(Schema.sObjectType.Event_Edition_Form__c.isAccessible())
        {
            listEEForms = [Select Id, Name, User_Type__c, Event_Edition__c, Expocad_Booth_Type__c, Expocad_Product_Type__c FROM Event_Edition_Form__c where User_Type__c != '' AND User_Type__c INCLUDES (:uTypeFromCCEM) AND Event_Edition__c IN:eventEdition Order by Event_Edition__c];
        }
        system.debug('####################LISTEEF '+listEEForms+'SIZE::'+listEEForms.size());
        Boolean checkIfExpocadFieldNotBlank = false;
        if(listEEForms.size()>0)
        {
            for(Event_Edition_Form__c eef : listEEForms)
            {
                // condition to add eef if form is not being mapped with booth type and booth product type from Expocad fields
                if(String.isBlank(eef.Expocad_Booth_Type__c) && String.isBlank(eef.Expocad_Product_Type__c)){
                    eEFormIdsSet.add(eef.Id); // eEFormIdsSet contains the list of forms for which UFA will be created
                }
                else{ checkIfExpocadFieldNotBlank = true; }
            }
        }
        // check Manuals for this matching event edition from ContactEventEditionMapping 
        if(Schema.sObjectType.Manual__c.isAccessible())
        {
            listEEManuals = [Select Id, Name, Expocad_Booth_Type__c, Expocad_Product_Type__c FROM Manual__c where Event_Edition__c IN:eventEdition AND User_Type__c != '' AND User_Type__c INCLUDES (:uTypeFromCCEM) Order by Event_Edition__c];  
        }
        
        Boolean checkIfExpocadFieldOnManualNotBlank = false;
        if(listEEManuals.size()>0)
        {
            for(Manual__c eem : listEEManuals)
            {
                // condition to add eem if manual is being mapped with booth type, booth product type from Expocad fields
                if(String.isBlank(eem.Expocad_Booth_Type__c) && String.isBlank(eem.Expocad_Product_Type__c)){
                    eEManualIdsSet.add(eem.Id); // eEManualIdsSet contains the list of manuals for which UMA will be created
                }
                else{
                    checkIfExpocadFieldOnManualNotBlank = true;
                }
            }
        }
            
        // Query on Opportunity and Expocad Booth if expocad fields are not blank on Event Edition Form and Manual
        if(checkIfExpocadFieldNotBlank == true || checkIfExpocadFieldOnManualNotBlank == true)
        {
            opp = [Select Id, Name, SBQQ__PrimaryQuote__c, AccountId FROM opportunity where EventEdition__c IN:eventEdition AND AccountId IN:sContactAccountId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
            Set<String> setAccountIds = new Set<String>();
            if(opp !=null && opp.size()>0)
            { 
                for(opportunity oppty: opp){                   
                    if(oppty.SBQQ__PrimaryQuote__c!=null){ sQuoteIds.add(oppty.SBQQ__PrimaryQuote__c); }
                }
            }
             /* CCEN-735 changes corresponding to expocad new object start*/    
            if(sQuoteIds.size()>0 && Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible())
            {
                system.debug('@@@listEEForms&&expoBooths1'+expoBooths.size());
                // Fetching all the booth information as per booth status(Rented) and opportunity
                expoBooths = [Select Id, Expocad_Booth__r.Booth_Type__c, Expocad_Booth__r.Matched_Product_Name__c, Opportunity__r.AccountId, Opportunity__r.Account.Name FROM Opportunity_ExpoCAD_Booth_Mapping__c where Status__c ='Active' AND Expocad_Booth__r.status__c='Rented' AND quote__c IN:sQuoteIds order by Opportunity__r.createdDate];
            }
            system.debug('@@@@@@@@@@@@@@@@@@@setAccountForUFA'+setAccountForUFA+'Size::'+setAccountForUFA.size());    
        }
        if(listEEForms.size()>0 && checkIfExpocadFieldNotBlank == true)
        {
            if(expoBooths !=null && expoBooths.size()>0)
            {
                
                // Adding account id to set on basis of the matching boothtype, booth class and booth product type from event edition form
                for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: expoBooths)
                {
                    for(Event_Edition_Form__c eef : listEEForms){
                        if(String.isNotBlank(ecb.Expocad_Booth__r.Booth_Type__c) && String.isNotBlank(eef.Expocad_Booth_Type__c) && eef.Expocad_Booth_Type__c.contains(ecb.Expocad_Booth__r.Booth_Type__c)){
                            setAccountForUFA.add(ecb.Opportunity__r.AccountId); eEFormIdsSet.add(eef.Id);
                        }
                        if(String.isNotBlank(ecb.Expocad_Booth__r.Matched_Product_Name__c) && String.isNotBlank(eef.Expocad_Product_Type__c) && eef.Expocad_Product_Type__c.contains(ecb.Expocad_Booth__r.Matched_Product_Name__c)){
                            setAccountForUFA.add(ecb.Opportunity__r.AccountId); eEFormIdsSet.add(eef.Id);
                        }
                    }                    
                }
            }
        }
        /*CCEN-735 changes corresponding to expocad new object end */
        System.debug('-------------------EEForms: '+eEFormIdsSet+'SIZE::'+eEFormIdsSet.size());
        
        // check existing Form Permission for matching EEForm and associated User Type from ContactEventEditionMapping
        mapExistingFormPermission = new Map<Id, Forms_Permission__c>([Select Id, Event_Edition_Form__c, Event_Edition_Form__r.Event_Edition__c, User_Type__c, User_Type__r.Name
                                                                                FROM Forms_Permission__c Where Event_Edition_Form__c IN:eEFormIdsSet AND User_Type__c IN: cEEMUserType]);
        system.debug('####################FP Records '+mapExistingFormPermission+'SIZE::'+mapExistingFormPermission.size());
        
        if(mapExistingFormPermission.size()>0)
        {
            for(Forms_Permission__c fp :mapExistingFormPermission.values()){
                mapUTypeFormpId.put(fp.User_Type__c+'#'+fp.Event_Edition_Form__c,fp.Id);
            }
        }

        mapExistingUFActions =new Map<Id,User_Form_Action__c>([Select Id, Account__c, Account__r.Name, User_Type__r.Name, User_Form_Contact__c, User__c, Form_Permission__c, Form_Permission__r.Event_Edition_Form__c, 
                                                                        Form_Permission__r.Event_Edition_Form__r.Name FROM User_Form_Action__c where Form_Permission__r.Event_Edition_Form__r.Event_Edition__c IN:eventEdition 
                                                                        AND Account__c IN:mapContactAccount.values() AND User_Type__c IN:cEEMUserType]);
        
        if(mapExistingUFActions.size()>0)
        {
            for(User_Form_Action__c ufa :mapExistingUFActions.values()){
                setAccUserTypeExisting.Add(ufa.User_Type__c +'#'+ ufa.Account__c +'#'+ ufa.Form_Permission__r.Event_Edition_Form__c);
            }
        }
        
        if(Test.isRunningTest() && setAccountForUFA.size() == 0)
        {
            mapExistingUFActions2 =new Map<Id,User_Form_Action__c>([Select Id, Account__c, Account__r.Name, User_Type__r.Name, User_Form_Contact__c, User__c, Form_Permission__c, Form_Permission__r.Event_Edition_Form__c, 
                                                                            Form_Permission__r.Event_Edition_Form__r.Name FROM User_Form_Action__c where Form_Permission__r.Event_Edition_Form__r.Event_Edition__c IN:eventEdition AND Account__c IN:mapContactAccount.values() AND User_Type__c IN:cEEMUserType]);
            if(mapExistingUFActions2.size()>0){
                for(User_Form_Action__c ufa :mapExistingUFActions2.values()){
                    setAccUserTypeExisting2.Add(ufa.User_Type__c +'#'+ ufa.Account__c +'#'+ ufa.Form_Permission__r.Event_Edition_Form__c);
                }
            }
        }
        if(setAccountForUFA.size()>0)
        {
            mapExistingUFActions2 =new Map<Id,User_Form_Action__c>([Select Id, Account__c, Account__r.Name, User_Type__r.Name, User_Form_Contact__c, User__c, Form_Permission__c, Form_Permission__r.Event_Edition_Form__c, 
                                                                            Form_Permission__r.Event_Edition_Form__r.Name FROM User_Form_Action__c where Form_Permission__r.Event_Edition_Form__r.Event_Edition__c IN:eventEdition AND Account__c IN:setAccountForUFA AND User_Type__c IN:cEEMUserType]);
            
            if(mapExistingUFActions2.size()>0){
                for(User_Form_Action__c ufa :mapExistingUFActions2.values()){
                    setAccUserTypeExisting2.Add(ufa.User_Type__c +'#'+ ufa.Account__c +'#'+ ufa.Form_Permission__r.Event_Edition_Form__c);
                }
            }
        }
        
        for(ContactEventEditionMapping__c cEEM : lstConEvnMap)
        {
            if(listEEForms.size()>0)
            {
                // creating User Form Action records on basis of the number of UserType and Account for created cEEM record 
                for(Integer i=0; i<listEEForms.size(); i++)
                {   
                    // Check whether the UFA records is created or not for this Account and User Type
                    if( (String.isBlank(listEEForms[i].Expocad_Booth_Type__c) && String.isBlank(listEEForms[i].Expocad_Product_Type__c)) && (!setAccUserTypeExisting.contains(cEEM.User_Type__c +'#'+ mapContactAccount.get(cEEM.SFContactID__c) +'#'+ listEEForms[i].Id)) )
                    {
                        // initialize User Form Action object
                        User_Form_Action__c ufa = new User_Form_Action__c();
                        if(!mapUTypeFormpId.isEmpty() && mapUTypeFormpId.containsKey(cEEM.User_Type__c+'#'+listEEForms[i].Id))
                        {
                            ufa.Form_Permission__c = mapUTypeFormpId.get(cEEM.User_Type__c+'#'+listEEForms[i].Id);
                            system.debug('=================MapForm'+ufa.Form_Permission__c);
                            ufa.Account__c = mapContactAccount.get(cEEM.SFContactID__c);
                            ufa.User_Type__c = cEEM.User_Type__c;
                            ufa.User_Form_Contact__c = cEEM.SFContactID__c; //CCEN-732
                            if(ufa.Account__c != null && ufa.User_Type__c != null) //CCEN-447
                            {
                                ufaList.Add(ufa);
                            }   
                        }
                    }
                    // If eef has value in expocad fields then check account on basis of opportunity and expocad booth
                    if( (( String.isNotBlank(listEEForms[i].Expocad_Booth_Type__c) || String.isNotBlank(listEEForms[i].Expocad_Product_Type__c))) && (!setAccUserTypeExisting2.contains(cEEM.User_Type__c +'#'+ mapContactAccount.get(cEEM.SFContactID__c) +'#'+ listEEForms[i].Id)) )
                    {
                        // initialize User Form Action object
                        User_Form_Action__c ufa = new User_Form_Action__c();
                        if(!mapUTypeFormpId.isEmpty() && mapUTypeFormpId.containsKey(cEEM.User_Type__c+'#'+listEEForms[i].Id)){
                            ufa.Form_Permission__c = mapUTypeFormpId.get(cEEM.User_Type__c+'#'+listEEForms[i].Id);
                            ufa.Account__c = mapContactAccount.get(cEEM.SFContactID__c);
                            ufa.User_Form_Contact__c = cEEM.SFContactID__c; //CCEN-732
                            ufa.User_Type__c = cEEM.User_Type__c;
                            if(ufa.Account__c != null && ufa.User_Type__c != null) //CCEN-447
                            {
                                ufaList.Add(ufa);
                            }    
                        }
                    }
                }
            }
        }
        system.debug('=========================UFALIST'+ufaList+'SIZE::'+ufaList.size());
        /*****************Enhancement for Form End*****************/
        
        /*****************Enhancement for Manual Start*****************/
         /* CCEN-738 changes corresponding to expocad new object start */
          system.debug('####################MP expoBooths1==='+checkIfExpocadFieldOnManualNotBlank);
        if(listEEManuals.size()>0 && checkIfExpocadFieldOnManualNotBlank == true)
        {
            if(expoBooths !=null && expoBooths.size()>0)
            {
                // Adding account id to set on basis of the matching boothtype, booth class and booth product type from manuals
                for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: expoBooths)
                {
                    for(Manual__c manual : listEEManuals)
                    {
                        if(String.isNotBlank(ecb.Expocad_Booth__r.Booth_Type__c) && String.isNotBlank(manual.Expocad_Booth_Type__c) && manual.Expocad_Booth_Type__c.contains(ecb.Expocad_Booth__r.Booth_Type__c)){
                            setAccountForUMA.add(ecb.Opportunity__r.AccountId); eEManualIdsSet.add(manual.Id);
                        }
                        if(String.isNotBlank(ecb.Expocad_Booth__r.Matched_Product_Name__c) && String.isNotBlank(manual.Expocad_Product_Type__c) && manual.Expocad_Product_Type__c.contains(ecb.Expocad_Booth__r.Matched_Product_Name__c)){
                            setAccountForUMA.add(ecb.Opportunity__r.AccountId); eEManualIdsSet.add(manual.Id);
                        }
                    }                    
                }
            }
            /* CCEN-738 changes corresponding to expocad new object end */
            system.debug('&&&&&&&&&&&&&&&&&'+setAccountForUMA);
        }
        // check existing Manual Permission for matching Manual and associated User Type from ContactEventEditionMapping
        mapExistingManualPermission = new Map<Id, Manuals_Permission__c>([Select Id, Manuals__c, Manuals__r.Event_Edition__c, User_Type__c, User_Type__r.Name FROM Manuals_Permission__c Where Manuals__c IN:eEManualIdsSet AND User_Type__c IN: cEEMUserType]);
        system.debug('####################MP Records '+mapExistingManualPermission+'SIZE::'+mapExistingManualPermission.size());
        
        if(mapExistingManualPermission.size()>0)
        {
            for(Manuals_Permission__c mp :mapExistingManualPermission.values()){
                mapUTypeManualpId.put(mp.User_Type__c+'#'+mp.Manuals__c,mp.Id);
            }
        }
        mapExistingUAManuals =new Map<Id,User_Manual_Action__c>([Select Id, Account__c, Account__r.Name, User_Type__r.Name, User_Manual_Contact__c, User__c, Manual_Permission__c, Manual_Permission__r.Manuals__c, Manual_Permission__r.Manuals__r.Name FROM User_Manual_Action__c where Manual_Permission__r.Manuals__r.Event_Edition__c IN:eventEdition AND Account__c IN:mapContactAccount.values() AND User_Type__c IN:cEEMUserType]);
        //system.debug('$$$$$$$$$$$$$$$$$$$ '+mapExistingUAManuals +'==Size'+mapExistingUAManuals.Size());
        if(mapExistingUAManuals.size()>0){
            for(User_Manual_Action__c uma :mapExistingUAManuals.values()){
                setAccUserTypeExistingManuals.Add(uma.User_Type__c +'#'+ uma.Account__c +'#'+ uma.Manual_Permission__r.Manuals__c);
            }
        }
        system.debug('========================SET '+setAccUserTypeExistingManuals);
        
        if(setAccountForUMA.size()>0 && (!Test.isRunningTest()))
        {
            mapExistingUAManuals2 =new Map<Id,User_Manual_Action__c>([Select Id, Account__c, Account__r.Name, User_Type__r.Name, User_Manual_Contact__c, User__c, Manual_Permission__c, Manual_Permission__r.Manuals__c, Manual_Permission__r.Manuals__r.Name FROM User_Manual_Action__c where Manual_Permission__r.Manuals__r.Event_Edition__c IN:eventEdition AND Account__c IN:setAccountForUMA AND User_Type__c IN:cEEMUserType]);
            system.debug('$$$$$$$$$$$$$$$$$$$ '+mapExistingUAManuals2 +'==Size'+mapExistingUAManuals2.Size());
            if(mapExistingUAManuals2.size()>0){
                for(User_Manual_Action__c uma :mapExistingUAManuals2.values()){
                    setAccountUserTypeExistingManuals2.Add(uma.User_Type__c +'#'+ uma.Account__c +'#'+ uma.Manual_Permission__r.Manuals__c);
                }
            }
            system.debug('========================SET '+setAccUserTypeExisting2);
        }
        
        for(ContactEventEditionMapping__c cEEM : lstConEvnMap)
        {
            if(listEEManuals.size()>0)
            {
                // creating User Form Action records on basis of the number of UserType and Account for created cEEM record 
                for(Integer i=0; i<listEEManuals.size(); i++)
                {   
                    // Check whether the UMA records is created or not for this Account and User Type
                    if( (String.isBlank(listEEManuals[i].Expocad_Booth_Type__c) && String.isBlank(listEEManuals[i].Expocad_Product_Type__c)) && (!setAccUserTypeExistingManuals.contains(cEEM.User_Type__c +'#'+ mapContactAccount.get(cEEM.SFContactID__c) +'#'+ listEEManuals[i].Id)) )
                    {
                        // initialize User Manual Action object
                        User_Manual_Action__c uma = new User_Manual_Action__c();
                        if(!mapUTypeManualpId.isEmpty() && mapUTypeManualpId.containsKey(cEEM.User_Type__c+'#'+listEEManuals[i].Id))
                        {
                            uma.Manual_Permission__c = mapUTypeManualpId.get(cEEM.User_Type__c+'#'+listEEManuals[i].Id);
                            system.debug('=================MapManual'+uma.Manual_Permission__c);
                            uma.Account__c = mapContactAccount.get(cEEM.SFContactID__c);
                            uma.User_Type__c = cEEM.User_Type__c;
                            uma.User_Manual_Contact__c = cEEM.SFContactID__c; //CCEN-732
                            if(uma.Account__c != null && uma.User_Type__c != null) //CCEN-448
                            {
                                umaList.Add(uma);
                            }    
                        }
                    }
                    
                    // If manual has value in expocad fields then check account on basis of opportunity and expocad booth
                    if( (String.isNotBlank(listEEManuals[i].Expocad_Booth_Type__c) || String.isNotBlank(listEEManuals[i].Expocad_Product_Type__c)) && (!setAccountUserTypeExistingManuals2.contains(cEEM.User_Type__c +'#'+ mapContactAccount.get(cEEM.SFContactID__c) +'#'+ listEEManuals[i].Id))  )
                    {
                        // initialize User Manual Action object
                        User_Manual_Action__c uma = new User_Manual_Action__c();
                        if(!mapUTypeManualpId.isEmpty() && mapUTypeManualpId.containsKey(cEEM.User_Type__c+'#'+listEEManuals[i].Id))
                        {
                            uma.Manual_Permission__c = mapUTypeManualpId.get(cEEM.User_Type__c+'#'+listEEManuals[i].Id);
                            system.debug('=================MapManual'+uma.Manual_Permission__c);
                            uma.Account__c = mapContactAccount.get(cEEM.SFContactID__c);
                            uma.User_Type__c = cEEM.User_Type__c;
                            uma.User_Manual_Contact__c = cEEM.SFContactID__c; //CCEN-732
                            if(uma.Account__c != null && uma.User_Type__c != null) //CCEN-448
                            {
                                umaList.Add(uma);
                            }    
                        }
                    }
                }
            }
        }
        try{
            if(ufaList.size()>0 && Schema.sObjectType.User_Form_Action__c.IsCreateable())
            {
                insert ufaList; // Insert UFA records List
            }
            if(umaList.size()>0 && Schema.sObjectType.User_Manual_Action__c.IsCreateable())
            {
                insert umaList; // Insert UMA records List
            }
        } 
        catch(Exception ex){ System.debug('Create User Exception Message: '+ex.getMessage()+'**Line Number='+ex.getLineNumber()); }
        /***************Enhancement for Manual End***************/
    }
}