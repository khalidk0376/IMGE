/*
* Date:        June 6, 2018
* Created By:  Hemendra Kumar (Girikon)
* *************************************************************************
* @description :  The purpose of this class is to return opportunity's values in wrapper and send Email to contact
* Methods:      GetOpportunityCtr, SendEmails
* Test Class: AccountContactsCtr_Test
* *************************************************************************
* Modified Date: August 17, 2018 ,11/22/2018, April 12, 2019
* Modified By : Mahesh Gupta (Girikon),Ashish (Girikon)[CCEN-502], [Ashish/CCEN-585 (8 Jan 2019)], Amish [CCEN 758],Mahesh[BK-3030(Dec 16 2019)]
*/
public without sharing class AccountContactsCtr
{   
   
    // wrapper class to return Opportunity details since OpsAdmin does not have permissions on opportunity
    public class wrapperClass{

        // Ops admin.... Login as customer from ops portal. [CCEN-502]
        @AuraEnabled public string sOrgId;// Org Id  (login as user)
        @AuraEnabled public string sNetworkid ;//Network id  (login as user)[Customer Center Login]
        @AuraEnabled public String baseUrl; //org Salesforce base url
        @AuraEnabled public boolean allowLogInUser = false; // to allow log in as user or not on the basis of event setting and event status

        @AuraEnabled public boolean bOppConAgnOwnEx=false; //To hold whether user is Agent Owned Exhibitor or else

        @AuraEnabled public string sOppConId;//Opportunity_Contact__c
        @AuraEnabled public string sOppConName;//Opportunity_Contact__r.name
        @AuraEnabled public string sOppConPhone;//Opportunity_Contact__r.phone
        @AuraEnabled public string sOppConEmail;//Opportunity_Contact__r.Email
        @AuraEnabled public boolean bOppConAUser=false;// To hold whether Opportunity_Contact is an existing user or not
        @AuraEnabled public string bOperationConUserName;
        @AuraEnabled public boolean allowLogInOppConUser = false; // to allow log in as user1 or not on basis of Contact & Event Maping
        @AuraEnabled public string bOpportunityConUserID; //Operations_Contact__c user ID

        @AuraEnabled public string sBillConId;// Billing_Contact__c
        @AuraEnabled public string sBillConName;//Billing_Contact__r.name
        @AuraEnabled public string sBillConPhone;//Billing_Contact__r.phone
        @AuraEnabled public string sBillConEmail;//Billing_Contact__r.Email
        @AuraEnabled public boolean isBillConAUser=false;// To hold whether Billing_Contact is an existing user or not
        @AuraEnabled public string bBillingConUserName;
        @AuraEnabled public boolean allowLogInBillConUser = false; // to allow log in as user1 or not on basis of Contact & Event Maping
        @AuraEnabled public string bBillConUserID; //Operations_Contact__c user ID

        @AuraEnabled public string sOpprationConId;//Operations_Contact__c user ID
        @AuraEnabled public string sOpprationConName;//Operations_Contact__r.name
        @AuraEnabled public string sOpprationConPhone;//Operations_Contact__r.phone
        @AuraEnabled public string sOpprationConEmail;//Operations_Contact__r.Email
        @AuraEnabled public boolean bOpprationConAUser=false;// To hold whether Operations_Contact is an existing user or not
        @AuraEnabled public boolean allowLogInUser1 = false; // to allow log in as user1 or not on basis of Contact & Event Maping
        @AuraEnabled public string bOppConUserName;
        @AuraEnabled public string bOppConUserID; //Operations_Contact__c user ID

        @AuraEnabled public boolean allowLogInUser2 = false; // to allow log in as user2 or not on basis of Contact & Event Maping
        @AuraEnabled public string sOppration2ConId;//Operations2_Contact__c;
        @AuraEnabled public string bOppCon2UserID; //Operations_Contact2__c user ID
        @AuraEnabled public string sOppration2ConName;//Operations2_Contact__r.name;
        @AuraEnabled public string sOppration2ConPhone;//Operations2_Contact__r.phone;
        @AuraEnabled public string sOppration2ConEmail;//Operations2_Contact__r.Email;
        @AuraEnabled public boolean bOppration2ConAUser=false;
        @AuraEnabled public string bOperation2ConUserName;

        @AuraEnabled public boolean allowLogInUser3 = false; // to allow log in as user3 or not on basis of Contact & Event Maping
        @AuraEnabled public string sOppration3ConId;//Operations2_Contact__c;
        @AuraEnabled public string bOppCon3UserID; //Operations_Contact3__c user ID
        @AuraEnabled public string sOppration3ConName;//Operations2_Contact__r.name;
        @AuraEnabled public string sOppration3ConPhone;//Operations2_Contact__r.phone;
        @AuraEnabled public string sOppration3ConEmail;//Operations2_Contact__r.Email;
        @AuraEnabled public boolean bOppration3ConAUser=false;
        @AuraEnabled public string bOperation3ConUserName;

        @AuraEnabled public boolean allowLogInUser4 = false; // to allow log in as user4 or not on basis of Contact & Event Maping
        @AuraEnabled public string sOppration4ConId;//Operations2_Contact__c;
        @AuraEnabled public string bOppCon4UserID; //Operations_Contact4__c user ID
        @AuraEnabled public string sOppration4ConName;//Operations2_Contact__r.name;
        @AuraEnabled public string sOppration4ConPhone;//Operations2_Contact__r.phone;
        @AuraEnabled public string sOppration4ConEmail;//Operations2_Contact__r.Email;
        @AuraEnabled public boolean bOppration4ConAUser=false;
        @AuraEnabled public string bOperation4ConUserName;

        @AuraEnabled public boolean allowLogInUser5 = false; // to allow log in as user5 or not on basis of Contact & Event Maping
        @AuraEnabled public string sOppration5ConId;//Operations2_Contact__c;
        @AuraEnabled public string bOppCon5UserID; //Operations_Contact5__c user ID
        @AuraEnabled public string sOppration5ConName;//Operations2_Contact__r.name;
        @AuraEnabled public string sOppration5ConPhone;//Operations2_Contact__r.phone;
        @AuraEnabled public string sOppration5ConEmail;//Operations2_Contact__r.Email;
        @AuraEnabled public boolean bOppration5ConAUser=false;
        @AuraEnabled public string bOperation5ConUserName;

    }
    //GetContactsCtr will return the First 'Closed Won' or 'Closed Booked' opportunity on the basis of AccountId and EventEdition
    @AuraEnabled
    public static  wrapperClass getOpportunityCtr(String sAccountId, string sEventId, String suType)
    {

        /**  return opportunity's values in wrapper and send Email to contact  **/
        System.debug('sAccountId++++++++++++++++++++++++'+sAccountId);
        System.debug('sEventId++++++++++++++++++++++++'+sEventId);
        list<Opportunity>  lstOpp =[SELECT Id,
                                  Billing_Contact__c,Billing_Contact__r.name,Billing_Contact__r.phone,Billing_Contact__r.Email,StageName,
                                  Operations_Contact__c,Operations_Contact__r.name,Operations_Contact__r.phone,Operations_Contact__r.Email,
                                  Opportunity_Contact__c,Opportunity_Contact__r.name,Opportunity_Contact__r.phone,Opportunity_Contact__r.Email,User_Type__r.name,
                                  Operation_Contact_2__c,Operation_Contact_2__r.name,Operation_Contact_2__r.phone,Operation_Contact_2__r.Email, 
                                  Operation_Contact_3__c,Operation_Contact_3__r.name,Operation_Contact_3__r.phone,Operation_Contact_3__r.Email,
                                  Operation_Contact_4__c,Operation_Contact_4__r.name,Operation_Contact_4__r.phone,Operation_Contact_4__r.Email,
                                  Operation_Contact_5__c,Operation_Contact_5__r.name,Operation_Contact_5__r.phone,Operation_Contact_5__r.Email
                                  FROM Opportunity  WHERE AccountId=:sAccountId AND EventEdition__c=:sEventId And User_Type__r.name =: suType 
                                  AND(StageName='Closed Booked' OR StageName='Closed Won') ORDER BY createddate ASC limit 1];
        system.debug('Opportunity list+++++++++++++++++++++++++++++++'+lstOpp);
        List<User_Type__c> userType = new List<User_Type__c>();
        userType = [select Id,name from User_Type__c where name =:suType Limit 1];
        wrapperClass objWrapper= new wrapperClass();
        if(!lstOpp.isEmpty())
        {
            set<id>oppConIDs = new set<id>(); // set to contain all ids of opp contacts
            objWrapper.sOppConName=lstOpp[0].Opportunity_Contact__r.name;
            objWrapper.sOppConPhone=lstOpp[0].Opportunity_Contact__r.phone;
            objWrapper.sOppConEmail=lstOpp[0].Opportunity_Contact__r.Email;
            if(lstOpp[0].Opportunity_Contact__c!=null)
            {
                objWrapper.sOppConId=lstOpp[0].Opportunity_Contact__c;
                oppConIDs.add(lstOpp[0].Opportunity_Contact__c);
                list<user> objUsr=[SELECT Id, Name,username from User where ContactId=:lstOpp[0].Opportunity_Contact__c];// find out whether this contact is already an user or not
                if(!objUsr.isEmpty())
                {
                    objWrapper.bOppConAUser=true;
                    // added username for ticket [CCEN-364]
                    objWrapper.bOppConUserName=objUsr[0].username;
                    objWrapper.bOpportunityConUserID = objUsr[0].Id;
                }

            }
            objWrapper.sBillConName=lstOpp[0].Billing_Contact__r.name;
            objWrapper.sBillConPhone=lstOpp[0].Billing_Contact__r.phone;
            objWrapper.sBillConEmail=lstOpp[0].Billing_Contact__r.Email;
            if(lstOpp[0].Billing_Contact__c!=null)
            {
                objWrapper.sBillConId=lstOpp[0].Billing_Contact__c;
                oppConIDs.add(lstOpp[0].Billing_Contact__c);
                list<user> objUsr=[SELECT Id, Name,username from User where ContactId=:lstOpp[0].Billing_Contact__c];
                if(!objUsr.isEmpty())
                {
                    objWrapper.isBillConAUser=true;
                    objWrapper.bBillingConUserName=objUsr[0].username;
                    objWrapper.bBillConUserID = objUsr[0].Id;
                }
            }
            objWrapper.sOpprationConName=lstOpp[0].Operations_Contact__r.name;
            objWrapper.sOpprationConPhone=lstOpp[0].Operations_Contact__r.phone;
            objWrapper.sOpprationConEmail=lstOpp[0].Operations_Contact__r.Email;
            if(lstOpp[0].Operations_Contact__c!=null)
            {
                objWrapper.sOpprationConId=lstOpp[0].Operations_Contact__c;
                oppConIDs.add(lstOpp[0].Operations_Contact__c);
                list<user> objUsr=[SELECT Id, Name,username from User where ContactId=:lstOpp[0].Operations_Contact__c];
                if(!objUsr.isEmpty())
                {
                    objWrapper.bOpprationConAUser=true;
                    objWrapper.bOperationConUserName=objUsr[0].username;
                    objWrapper.bOppConUserID=objUsr[0].Id;
                }
            }
            objWrapper.sOppration2ConName=lstOpp[0].Operation_Contact_2__r.name;
            objWrapper.sOppration2ConPhone=lstOpp[0].Operation_Contact_2__r.phone;
            objWrapper.sOppration2ConEmail=lstOpp[0].Operation_Contact_2__r.Email;
            if(lstOpp[0].Operation_Contact_2__c!=null)
            {
                objWrapper.sOppration2ConId=lstOpp[0].Operation_Contact_2__c;
                oppConIDs.add(lstOpp[0].Operation_Contact_2__c);
                list<user> objUsr=[SELECT Id, Name,username from User where ContactId=:lstOpp[0].Operation_Contact_2__c];
                if(!objUsr.isEmpty())
                {
                    objWrapper.bOppration2ConAUser=true;
                    objWrapper.bOperation2ConUserName=objUsr[0].username;
                    objWrapper.bOppCon2UserID = objUsr[0].Id;
                }
            }

            objWrapper.sOppration3ConName=lstOpp[0].Operation_Contact_3__r.name;
            objWrapper.sOppration3ConPhone=lstOpp[0].Operation_Contact_3__r.phone;
            objWrapper.sOppration3ConEmail=lstOpp[0].Operation_Contact_3__r.Email;
            if(lstOpp[0].Operation_Contact_3__c!=null)
            {
                objWrapper.sOppration3ConId=lstOpp[0].Operation_Contact_3__c;
                oppConIDs.add(lstOpp[0].Operation_Contact_3__c);
                list<user> objUsr=[SELECT Id, Name,username from User where ContactId=:lstOpp[0].Operation_Contact_3__c];
                if(!objUsr.isEmpty())
                {
                    objWrapper.bOppration3ConAUser=true;
                    objWrapper.bOperation3ConUserName=objUsr[0].username;
                    objWrapper.bOppCon3UserID = objUsr[0].Id;
                }
            }

            objWrapper.sOppration4ConName=lstOpp[0].Operation_Contact_4__r.name;
            objWrapper.sOppration4ConPhone=lstOpp[0].Operation_Contact_4__r.phone;
            objWrapper.sOppration4ConEmail=lstOpp[0].Operation_Contact_4__r.Email;
            if(lstOpp[0].Operation_Contact_4__c!=null)
            {
                objWrapper.sOppration4ConId=lstOpp[0].Operation_Contact_4__c;
                oppConIDs.add(lstOpp[0].Operation_Contact_4__c);
                list<user> objUsr=[SELECT Id, Name,username from User where ContactId=:lstOpp[0].Operation_Contact_4__c];
                if(!objUsr.isEmpty())
                {
                    objWrapper.bOppration4ConAUser=true;
                    objWrapper.bOperation4ConUserName=objUsr[0].username;
                    objWrapper.bOppCon4UserID = objUsr[0].Id;
                }
            }


            objWrapper.sOppration5ConName=lstOpp[0].Operation_Contact_5__r.name;
            objWrapper.sOppration5ConPhone=lstOpp[0].Operation_Contact_5__r.phone;
            objWrapper.sOppration5ConEmail=lstOpp[0].Operation_Contact_5__r.Email;
            if(lstOpp[0].Operation_Contact_5__c!=null)
            {
                objWrapper.sOppration5ConId=lstOpp[0].Operation_Contact_5__c;
                oppConIDs.add(lstOpp[0].Operation_Contact_5__c);
                list<user> objUsr=[SELECT Id, Name,username from User where ContactId=:lstOpp[0].Operation_Contact_5__c];
                if(!objUsr.isEmpty())
                {
                    objWrapper.bOppration5ConAUser=true;
                    objWrapper.bOperation5ConUserName=objUsr[0].username;
                    objWrapper.bOppCon5UserID = objUsr[0].Id;
                }
            }
            if(lstOpp[0].User_Type__r.name == 'Agent Owned Exhibitor') // to dispaly note for Agent Owned Exhibitor [CCEN-270]
            {
                objWrapper.bOppConAgnOwnEx=true;
            }

            /** Login As User Setup **/ // Ops admin.... Login as customer from ops portal. [CCEN-502]
            //string communityName = 'Customer Center Login';
            string communityName = 'Customer Centre';
            Network n = [Select id from Network WHERE Name=:communityName];
            list<Event_Settings__c>evntStng = new list<Event_Settings__c>();
            evntStng = [select id ,Event_Edition__c from Event_Settings__c where
                        Is_Event_Edition_Live__c = true
                        And Event_Edition__r.Event_Edition_Status__c = 'Confirmed'
                        And Event_Edition__c =:sEventId];

            if(n!=null && evntStng.size()>0 )
            {
                objWrapper.sNetworkid = n.Id;
                objWrapper.sNetworkid = objWrapper.sNetworkid.subString(0,15);
                objWrapper.sOrgId =  UserInfo.getOrganizationId().subString(0,15);
                objWrapper.baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
                objWrapper.allowLogInUser = true;
            }

            Map<string,ContactEventEditionMapping__c> conEvtMap =  new map<string,ContactEventEditionMapping__c>();

            for(ContactEventEditionMapping__c cEEM : [select id,SFContactID__c,SFEventEditionID__c from
                                                       ContactEventEditionMapping__c where SFContactID__c in :oppConIDs
                                                       And SFEventEditionID__c = :sEventId] )
            {
                conEvtMap.put(cEEM.SFContactID__c,cEEM);
            }

            if(lstOpp[0].Opportunity_Contact__c!=null)
            {
                if(conEvtMap.containsKey(lstOpp[0].Opportunity_Contact__c)) 
                {
                    objWrapper.allowLogInOppConUser = true;
                }
            }
            if(lstOpp[0].Billing_Contact__c!=null)
            {
                if(conEvtMap.containsKey(lstOpp[0].Billing_Contact__c))
                {
                    objWrapper.allowLogInBillConUser = true;
                }
            }
            if(lstOpp[0].Operations_Contact__c!=null)
            {
                if(conEvtMap.containsKey(lstOpp[0].Operations_Contact__c))
                {
                    objWrapper.allowLogInUser1 = true;
                }
            }
            if(lstOpp[0].Operation_Contact_2__r!=null)
            {
                if(conEvtMap.containsKey(lstOpp[0].Operation_Contact_2__c))
                {
                    objWrapper.allowLogInUser2 = true;
                }
            }
            if(lstOpp[0].Operation_Contact_3__r!=null)
            {
                if(conEvtMap.containsKey(lstOpp[0].Operation_Contact_3__c))
                {
                    objWrapper.allowLogInUser3 = true;
                }
            }
            if(lstOpp[0].Operation_Contact_4__r!=null)
            {
                if(conEvtMap.containsKey(lstOpp[0].Operation_Contact_4__c))
                {
                    objWrapper.allowLogInUser4 = true;
                }
            }
            if(lstOpp[0].Operation_Contact_5__r!=null)
            {
                if(conEvtMap.containsKey(lstOpp[0].Operation_Contact_5__c))
                {
                    objWrapper.allowLogInUser5 = true;
                }
            }          

        }



        system.debug('Wrapper class+++++++++++++++++++++++++++++++'+objWrapper);
        return objWrapper;
    }
    //SendEmails will send the Email to Contact
    @AuraEnabled
    public static void sendEmails(String sContactId,string sEventId)
    {
        set<Id> setCon= new set<Id>();
        set<Id> setConEEmapIds= new set<Id>();
        set<Id> setEEdition = new set<Id>();
        list<user> lstUsr= [SELECT Id, Name from user WHERE ContactId=:sContactId];
        system.debug('lstUsr========================'+lstUsr);
       //checking if mapping is created for contact, if not it will create mapping for contact.
        Opportunity  objOpp =[SELECT Id, User_Type__c,User_Type__r.Name,parent_Opportunity__r.operations_contact__c FROM Opportunity  WHERE (Operations_Contact__c=:sContactId OR Opportunity_Contact__c=:sContactId OR Billing_Contact__c=:sContactId OR Operation_Contact_2__c=:sContactId OR Operation_Contact_3__c=:sContactId OR Operation_Contact_4__c=:sContactId OR Operation_Contact_5__c=:sContactId) AND EventEdition__c=:sEventId AND(StageName='Closed Booked' OR StageName='Closed Won') AND User_Type__c != null limit 1];
        List<ContactEventEditionMapping__c> lstConEnvMap=new List<ContactEventEditionMapping__c>();
        lstConEnvMap = [SELECT Id,SFContactID__c,SFEventEditionID__c,User_Type__c,User_Type__r.Name,Email_Sent__c  FROM ContactEventEditionMapping__c WHERE SFContactID__c=:sContactId and SFEventEditionID__c=:sEventId];
        if(lstConEnvMap.isEmpty() && objOpp!=null)
        {
            ContactEventEditionMapping__c conEventMap = new ContactEventEditionMapping__c();
            conEventMap.SFContactID__c= sContactId;
            conEventMap.SFEventEditionID__c= sEventId;
            conEventMap.User_Type__c= objOpp.User_Type__c;
            insert conEventMap;
            if(objOpp.User_Type__r.Name == 'Agent Owned Exhibitor')
            {
                setConEEmapIds.add(conEventMap.Id); // In Case of Agent Owned Exhibitor
            }
        }
        else 
        {
            if(lstUsr.isEmpty() && lstConEnvMap.size()>0)
            {   
                if(objOpp.User_Type__r.Name == 'Agent Owned Exhibitor')
                {
                    AgentExhibitorsContact__c newAgnExhCon= new AgentExhibitorsContact__c();
                    newAgnExhCon.AgentContactId__c=objOpp.parent_Opportunity__r.operations_contact__c;
                    newAgnExhCon.ExhibitorContactId__c=sContactId;
                    newAgnExhCon.EventEdition__c=sEventId;

                    insert newAgnExhCon;  

                    BatchCreateUserforAgentOwnExh batchCreateuser = new BatchCreateUserforAgentOwnExh(); 
                    database.executebatch(batchCreateuser,1);                        
                }
                else
                {
                    setConEEmapIds.add(lstConEnvMap[0].Id);
                    system.debug('setConEEmapIds========================'+setConEEmapIds); // In Case of not Agent Owned Exhibitor   
                    /* old user Creation methord
                    setCon.add(sContactId);
                    BatchCreateCommunityUsers objbatch= new BatchCreateCommunityUsers(UtilityMethods.getProfileid().Id,setCon);
                    Database.executeBatch(objbatch,1);// calling batch class to create community user if contact is not an existing user */                                   
                }    
            }
            else
            {   // Added Email_Sent__c update functionality for BK-3030
                if(lstConEnvMap.size()>0)
                {
                lstConEnvMap[0].Email_Sent__c= system.now();
                update lstConEnvMap[0];
                setEEdition.add(sEventId);
                setCon.add(sContactId);
                UtilityMethods.sendEmailToExistingUserAccCon(setCon,setEEdition);// Calling Utility method to send Email
                }
            }
            if(setConEEmapIds.size()>0)
            {
                BatchCreateCommunityUsers objbatch= new BatchCreateCommunityUsers(setConEEmapIds,UtilityMethods.getProfileid().Id);
                Database.executeBatch(objbatch,1);// calling batch class to create community user if contact is not an existing user [CCEN-585]
            }           
        } 
    }
    // reset Password method that is being called from Ops Admin portal. //CCEN 758
    @AuraEnabled
    public static void resetPasswords(String sContactId)
    {
        List<user > lstUser=new List<user >();
        lstUser = [Select Id,contactId, username from user where contactId =:sContactId];
        System.resetPassword(lstUser[0].Id,true);
    }
 }