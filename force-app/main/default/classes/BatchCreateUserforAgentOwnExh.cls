/*
* Created By:  Mahesh Kumar (Girikon)
* Created on :  08/02/2018
* Modified by : 
* Modified On : 
* @description : The purpose of this Batch class to create user(s) for "Agent Owned Exhibitor" userType.
* Test Class: BatchCreateUserforAgentOwnExh_Test(94%)
* Last Modified By:    [Ashish/CCEN-585 (8 Jan 2019)],Ashish[C2E - 5(18 Sep 2019), Aishwarya[C2E - 109(20 Nov 2019)]
*/
    public class BatchCreateUserforAgentOwnExh implements Database.Batchable<sObject>,Database.Stateful
    {    
        public  List<AgentExhibitorsContact__c> agentExhFinal = new List<AgentExhibitorsContact__c>();
        public  List<ContactEventEditionMapping__c> lstContactEvenvMapFinal=new List<ContactEventEditionMapping__c>();
        public  Set<Id> setContactIds= new Set<Id>();
        public  Set<Id> setEventnEditIds= new Set<Id>();
        public  Set<String> setUserTypes = new Set<String>();
        // In Start methoid querying on AgentExhibitorsContact.
        public Database.QueryLocator start(Database.BatchableContext bc)
        {          
            String query= 'select Id, AgentContactId__c,ExhibitorContactId__c,IsUserCreated__c,EventEdition__c from AgentExhibitorsContact__c WHERE IsUserCreated__c=false AND '; 
                   query += ' EventEdition__r.Event_Edition_Status__c =\'Confirmed\' AND EventEdition__c IN (Select Event_Edition__c FROM Event_Settings__c WHERE Event_Edition__r.Event_Edition_Status__c =\'Confirmed\' AND Is_Event_Edition_Live__c = True) ';
        //  system.debug('query====='+query);
            return Database.getQueryLocator(query);
        }
        // In Execute method if the ContactEventEditionMapping is Existing in AgentExhibitorsContact then send out a mail else create new ContactEventEditionMapping.
        Public void execute(Database.BatchableContext bc, List<AgentExhibitorsContact__c> agentlst)
        {      
            set<Id> contactIdLst= new set<Id>();

            for(AgentExhibitorsContact__c conId: agentlst)
            {
                contactIdLst.add(conId.ExhibitorContactId__c);
            }  
            
            set<Id> eventEditionIdLst= new set<Id>();
            for(AgentExhibitorsContact__c evntedition: agentlst)
            {
                eventEditionIdLst.add(evntedition.EventEdition__c);
            }  
    
            User_Type__c userType =[select id from User_Type__c where name ='Agent Owned Exhibitor' Limit 1];  
                
            List<ContactEventEditionMapping__c> lstConEnvMap=new List<ContactEventEditionMapping__c>();
            lstConEnvMap = [SELECT Id,SFContactID__c,SFEventEditionID__c,User_Type__c  FROM ContactEventEditionMapping__c WHERE SFContactID__c IN :contactIdLst and SFEventEditionID__c IN:eventEditionIdLst ];  //C2E-5 Chnages made for all user types 
            
            map <Id,  ContactEventEditionMapping__c>   mapConEvntEdition  = new  map<Id,  ContactEventEditionMapping__c>();
            for(ContactEventEditionMapping__c  conEvntEdition : lstConEnvMap)
            {   mapConEvntEdition.put(conEvntEdition.SFContactID__c, conEvntEdition);
            }
            Set<Id> setConIds= new Set<Id>();
            Set<Id> setEvnEditIds= new Set<Id>();
            Set<String> setUserType = new Set<String>();
            setUserType.add(userType.id); 
            List<ContactEventEditionMapping__c> lstConEnvMapinsrt=new List<ContactEventEditionMapping__c>();
            for(AgentExhibitorsContact__c agentExhCon: agentlst)
            {                  
                if(MapConEvntEdition.containsKey(agentExhCon.ExhibitorContactId__c))
                { 
                    this.lstContactEvenvMapFinal.add(MapConEvntEdition.get(agentExhCon.ExhibitorContactId__c));
                }
                else 
                {
                    ContactEventEditionMapping__c conEventMap = new ContactEventEditionMapping__c();
                    conEventMap.SFContactID__c= agentExhCon.ExhibitorContactId__c;
                    conEventMap.SFEventEditionID__c= agentExhCon.EventEdition__c; 
                    conEventMap.User_Type__c= userType.id; 
                    lstConEnvMapinsrt.add(conEventMap);
                }
                setConIds.add(agentExhCon.ExhibitorContactId__c);
                setEvnEditIds.add(agentExhCon.EventEdition__c);
            }
            if(!lstConEnvMapinsrt.isEmpty())
            { 
                insert lstConEnvMapinsrt;
            }
            this.agentExhFinal.AddAll(agentlst);
            this.setContactIds.addAll(setConIds);
            this.setEventnEditIds.addAll(setEvnEditIds);
            this.setUserTypes.addAll(setUserType);
            this.lstContactEvenvMapFinal.addAll(lstConEnvMapinsrt); 
            system.debug('lstConEnvMap===='+lstConEnvMap.size());
        
        } 
        // Updating field IsUserCreated True. 
        Public void finish(Database.BatchableContext bc)
        {
            //For Change of parameter in User making 
            set<String> conEEIds = new Set<String>();  
            for(ContactEventEditionMapping__c conEEM:lstContactEvenvMapFinal)
            {
                conEEIds.add(conEEM.Id);
            }
            try
            {
                ContactEventEditionMappingTriggerHandler objHendler= new ContactEventEditionMappingTriggerHandler();                
                //objHendler.createCommunityUser(setContactIds);  // old Methord 
                objHendler.createCommunityUser(conEEIds);       // [CCEN-585] 
                //objHendler.createUserActions(setEventnEditIds,setContactIds,lstContactEvenvMapFinal,setUserTypes);
                List<AgentExhibitorsContact__c> lstAgentExCon=new List<AgentExhibitorsContact__c>();

                for(AgentExhibitorsContact__c  agtExUpdate : agentExhFinal)
                {   
                    agtExUpdate.IsUserCreated__c=true ;
                    lstAgentExCon.add(agtExUpdate);
                }
                if (!lstAgentExCon.isEmpty())
                {
                    update lstAgentExCon;
                }
            } 
            catch(Exception e)
            {   String sMessage='Exception Details<br>';sMessage += '<br><b>Contact List:</b> '+JSON.serialize(conEEIds) ;
                sMessage += '<br><b>Logged In User:</b> '+UserInfo.getName()+'[ '+ UserInfo.getUserId()+']';
                sMessage += '<br><b>Org:</b> '+UserInfo.getOrganizationName();sMessage += '<br><b>ERROR TYPE:</b> '+e.getTypeName();
                sMessage += '<br><b>ERROR MESSAGE:</b> '+e.getMessage(); sMessage += '<br><b>ERROR LINE NUMBER:</b> '+e.getLineNumber();
                sMessage += '<br><b>Error Details:</b> '+e.getStackTraceString();
                String[] toAddresses = new String[] {Label.Admin_Email_Address_CC};
                string subject='Exception occurred while creating community user';
                UtilityMethods.SendEmailNotification(toAddresses,subject,sMessage);
            }            
            
        }
}