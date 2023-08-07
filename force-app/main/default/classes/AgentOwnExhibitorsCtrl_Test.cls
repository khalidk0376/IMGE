/**
* Created By   :  Girikon(Sunil)
* Created On   :  04/16/2018
* @description :  [This test class provide code coverage to "AgentOwnExhibitorsCtrl" class.]
* Apex Class   :  AgentOwnExhibitorsCtrl
* Modified by  :  Girikon(Rajeev[CCEN-745 April 02 2019], Prashant[C2E-1 August 20 2019])
**/
@isTest
public class AgentOwnExhibitorsCtrl_Test
{ 
    private static string sEventCodeNew;
    @isTest
    static void dataSetUp() 
    {
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'].Id; 
        
        //Create account
        
        account objAcc = new account(Name='TestLName');
        insert objAcc;
        System.AssertNotEquals(objAcc, null, 'account must not be null');
        
        //Create User_Type__c
        User_Type__c uTypeAgn = new User_Type__c(Name='Agent');
        insert uTypeAgn;
        System.AssertNotEquals(uTypeAgn, null, 'User_Type__c must not be null');
        
        User_Type__c uTypeAOE = new User_Type__c(Name='Agent Owned Exhibitor');
        insert uTypeAOE;
        System.AssertNotEquals(uTypeAOE, null, 'User_Type__c must not be null');
        
        //Create contact
        Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com', Type__c=uTypeAgn.Id,AccountId = objAcc.id);
        insert con;
        System.AssertNotEquals(con, null, 'Contact must not be null');
        
        Contact conTest = new Contact(LastName='Test',FirstName ='Test',email='test1@test.com', Type__c=uTypeAgn.Id,AccountId = objAcc.id);
        insert conTest;
        System.AssertNotEquals(conTest, null, 'Contact must not be null');
        
        //create ExpocadBooth__c
        ExpocadBooth__c expBooth = new ExpocadBooth__c(Booth_Number__c='TestBoothNo',Dimensions__c = '5M x 10M',Area__c ='50 m²',status__c='Rented');
        insert expBooth;
        System.AssertNotEquals(expBooth, null, 'ExpocadBooth__c must not be null');  
        
        
        
        //Create event edition
        Event_Edition__c eventEdition = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert eventEdition;
        System.AssertNotEquals(eventEdition, null, 'Event_Edition__c must not be null');
        
        //Create Event_Settings__c
        Event_Settings__c eventSettings = new Event_Settings__c(Name='Test',About_Show__c='Test',ShowHours1__c='test',ShowHours2__c='Test',Branding_Color__c='Black',Link_1__c='http://m.www.google.com/',Is_Stand_Design_Visible__c=True,Is_Stand_Detail_Visible__c=True,Is_SubContractors_Visible__c=True,Is_Amount_Visible__c=True,
                                                                Link_2__c='http://m.www.google.com/',Link_3__c='http://m.www.google.com/',Link_4__c='http://m.www.google.com/',Link_1_Label__c='TestLink1',Link_2_Label__c='TestLink2',Link_3_Label__c='TestLink3',Link_4_Label__c='TestLink4',
                                                                FaceBook__c='http://m.www.facebook.com/',LinkedIn__c='http://m.www.linkedin.com/',Twitter__c='http://m.www.Twitter.com/',YouTube__c='http://m.www.youtube.com/',Custom_1_Title__c='CstmTitle',Event_Edition__c=eventEdition.Id,E_Commerce_Title__c='EC Title',Welcome_Stand_Contractor__c='WSC Test',Disable_this_information__c=True,
                                                               Is_Event_Edition_Live__c = true, Send_Welcome_Email__c = true,   Send_email_notification_to_Agents__c  =true);
        eventSettings.Allotment_By_Booth_Type__c=true; 
        insert eventSettings;
        System.AssertNotEquals(eventSettings, null, 'Event_Settings__c must not be null');
        
        //Create parent opportunity
        Opportunity oOpportunity1 = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(),StageName = 'Closed Won', 
                                                   EventEdition__c = eventEdition.Id, Operations_Contact__c=con.Id,  AccountId = objAcc.Id, Billing_Contact__c = con.Id, Opportunity_Contact__c=con.id); 
        insert oOpportunity1;
        System.AssertNotEquals(oOpportunity1, null, 'Parent Opportunity must not be null');
        
        //Create another opportunity
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(),StageName = 'Closed Won', 
                                                   EventEdition__c = eventEdition.Id, parent_Opportunity__c = oOpportunity1.id, Operations_Contact__c=con.Id,  AccountId = objAcc.Id, Billing_Contact__c = con.Id, Opportunity_Contact__c=con.id); 
        insert oOpportunity;
        System.AssertNotEquals(oOpportunity, null, 'Opportunity must not be null');
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c =objAcc.Id, SBQQ__Primary__c = true);
        insert oQuote;
        
        oOpportunity.StageName='Closed Won';
        update oOpportunity;
        
        expBooth.Opportunity__c=oOpportunity.Id;
        update expBooth;
        
        //CCEN-745
        //create Opportunity_ExpoCAD_Booth_Mapping__c
        Opportunity_ExpoCAD_Booth_Mapping__c oppBooth=new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppBooth.Account__c=objAcc.Id;
        oppBooth.Status__c='Active';
        oppBooth.Expocad_Booth__c=expBooth.id;
        oppBooth.Opportunity__c=oOpportunity.id;
        insert oppBooth;
        System.AssertNotEquals(oppBooth, null, 'Opportunity_ExpoCAD_Booth_Mapping__c must not be null'); 
        
        //Create Booth Size Badge Limit
        Booth_Size_Badge_Limit__c objBoothLimit = new Booth_Size_Badge_Limit__c(Badges_Allowed__c=10,Booth_Size_From__c=10,Booth_Size_To__c=20,Event_Edition__c=eventEdition.Id);
        insert objBoothLimit;
        System.AssertNotEquals(objBoothLimit, null, 'Booth_Size_Badge_Limit__c must not be null');
        
        
        //Create user
        User usr = new User();
        usr.FirstName = 'Sunil';
        usr.LastName = 'Bajoliya';
        usr.Email = 'test@wexeurope.com';
        usr.Username = 'astest@wexeurope.com';
        usr.Alias = 'astest';
        usr.ProfileId = profileId;
        usr.TimeZoneSidKey    = 'America/Denver';
        usr.LocaleSidKey      = 'en_US';
        usr.EmailEncodingKey  = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.ContactId=con.id;
        insert usr;
        System.AssertNotEquals(usr, null, 'usr must not be null ');
        
        system.runAs(usr)
        {
            //usr.Email = 'test@test.com';
            //update usr;
            test.startTest();
            string sEventCode=eventEdition.Event_Code__c;
            sEventCodeNew=eventEdition.Event_Code__c;
            
            list<Contact> lstCon=[SELECT Id, Name from contact];
            Set<Id> setConIds= new  Set<Id>(); 
            for(contact con1 :lstCon){
                setConIds.add(con1.Id);
            }
            List<String> lstConIds= new  List<String>(); 
            for(contact con1 :lstCon){
                lstConIds.add(con1.Id);
            }
            Set<Id> eventEdId = new Set<Id>();
            list<Event_Edition__c> lstEvent=[SELECT Id, Name from Event_Edition__c];
            for(Event_Edition__c eventId: lstEvent)
            {
                eventEdId.add(eventId.Id);
            }
             
            //Event_Settings__c testEvntSttng=AgentOwnExhibitorsCtrl.getEventDetails(sEventCode); 
            //System.AssertNotEquals(testEvntSttng, null);  
            AgentOwnExhibitorsCtrl agentOwned = new AgentOwnExhibitorsCtrl();
            agentOwned.sendEmailNotificationtoAgent(setConIds, eventEdId);
            
            list<AggregateResult> lstBoothDimeisions = AgentOwnExhibitorsCtrl.getBoothDimensions();
            System.AssertNotEquals(lstBoothDimeisions, null, 'lstBoothDimeisions must not be null'); 
            
            Opportunity opp = AgentOwnExhibitorsCtrl.getAccccountContacts(objAcc.Id,eventEdition.Id);
            System.AssertNotEquals(opp, null, 'opp must not be null'); 
            
            ContactEventEditionMapping__c objmap = AgentOwnExhibitorsCtrl.getContactEventEditionMapping(eventEdition.Id);
            System.AssertNotEquals(objmap, null, 'ContactEventEditionMapping__c must not be null'); 
            
            ContactEventEditionMapping__c objnewmap= new ContactEventEditionMapping__c(SFContactID__c=lstCon[0].Id,SFEventEditionID__c=eventEdition.Id,User_Type__c=uTypeAOE.Id);
            insert objnewmap;
            System.AssertNotEquals(objnewmap, null, 'ContactEventEditionMapping__c must not be null');
            
            AgentOwnExhibitorsCtrl.updateContactEventEditionMapping(objnewmap);
            
            String result = AgentOwnExhibitorsCtrl.sendEmailtoExhibitors(lstConIds,eventEdition.Id);
            System.AssertNotEquals(result, null, 'result must not be null');
             
            //CCEN-745
            AgentOwnExhibitorsCtrl.exhibitorsWrapperClass  lstBooth =  AgentOwnExhibitorsCtrl.getBoothDetails(oppBooth.Id,sEventCode,'Agent Owned Exhibitor'); 
            System.AssertNotEquals(lstBooth, null, 'lstBooth must not be null');
            
            list<User_Form_Action__c> objUserFrm = AgentOwnExhibitorsCtrl.getRequiredForms(objAcc.Id,eventEdition.Id);
            System.AssertNotEquals(objUserFrm, null, 'User_Form_Action__c must not be null');
            
            //Create User_Type__c
            User_Type__c uType = new User_Type__c(Name='Agent Owned Exhibitor');
            insert uType;
            System.AssertNotEquals(uType, null, 'User_Type__c must not be null');
            
            AgentExhibitorsContact__c newAgnExhCon= new AgentExhibitorsContact__c();
            newAgnExhCon.AgentContactId__c=conTest.Id;
            newAgnExhCon.ExhibitorContactId__c=conTest.Id;
            newAgnExhCon.EventEdition__c=eventEdition.Id;
            insert newAgnExhCon;
            System.AssertNotEquals(newAgnExhCon, null, 'AgentExhibitorsContact__c must not be null');
            
            list<AgentExhibitorsContact__c> lstResult = AgentOwnExhibitorsCtrl.createUser(newAgnExhCon);
            System.AssertNotEquals(lstResult, null, 'lstResult must not be null');
            
            set<id> setConNonExs = new set<id>();   
            setConNonExs.add(lstCon[0].Id);  
            AgentOwnExhibitorsCtrl.updateEmailDate(setConNonExs);
            //  Test method for getAllCustomers [C2E-1]
            list<AgentOwnExhibitorsCtrl.exhibitorsWrapperClass> objExh2= AgentOwnExhibitorsCtrl.getAllCustomers(sEventCodeNew, '','All', '', '', '', false);
            //list<AgentOwnExhibitorsCtrl.exhibitorsWrapperClass> objExh= AgentOwnExhibitorsCtrl.getExhibitors(sEventCodeNew, '','', '', false,false,false,false,false);
            //System.AssertNotEquals(objExh, null, 'objExh must not be null');
            list<AgentOwnExhibitorsCtrl.exhibitorsWrapperClass> objExh1=  AgentOwnExhibitorsCtrl.getSubAgents(sEventCode);
            //list<AgentOwnExhibitorsCtrl.exhibitorsWrapperClass> objExhs= AgentOwnExhibitorsCtrl.getExhibitors(sEventCodeNew, 'test', 'test', true,true,true,true);
            //System.AssertNotEquals(objExhs, null);
            
            test.stopTest();
        }
    }
    @isTest static void validateEmailForAgent()
    {        
        
        // *******Data Setup**********
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'].Id; 
        
        //Create account
        account objAcc = new account(Name='TestLName');
        insert objAcc;
        System.assertNotEquals(objAcc, null, 'objAcc must not be null');

        
        //Create User_Type__c
        User_Type__c uTypeAgn = new User_Type__c(Name='Agent');
        insert uTypeAgn;
        
        
        //Create contact
        Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com', Type__c=uTypeAgn.Id,AccountId = objAcc.id);
        insert con;
        
        //Create user
        User usr = new User();
        usr.FirstName = 'Sunil';
        usr.LastName = 'Bajoliya';
        usr.Email = 'test@wexeurope.com';
        usr.Username = 'astest@wexeurope.com';
        usr.Alias = 'astest';
        usr.ProfileId = profileId;
        usr.TimeZoneSidKey    = 'America/Denver';
        usr.LocaleSidKey      = 'en_US';
        usr.EmailEncodingKey  = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.ContactId=con.id;
        insert usr;
        
        //Create event edition
        Event_Edition__c eventEdition = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        eventEdition.Event_Edition_Status__c = 'Completed';
        insert eventEdition;
        
        //Create global email template
        Email_Templates__c testET = new Email_Templates__c();
        testET.name = 'test email template';
        testET.Template_Code__c = 'SETA';
        testET.Content__c = 'testContent';
        testET.Subject__c = 'Test Template';
        insert testET;
        
        //Create event edition email template using global email template
        Event_Edition_Email_Template__c testEEET = new Event_Edition_Email_Template__c();
        testEEET.Event_Edition__c = eventEdition.id;
        testEEET.Subject__c = 'Test Template';
        testEEET.Email_Template__c = testET.id;
        testEEET.Email_Template_Code__c = 'SETA';
        testEEET.Content__c = 'test{Agent.Name} {Exhibitor.Name} email template';
        insert testEEET;
        
        
        contact oContac = [select id,email,Name,Account.Name from contact limit 1];
        map<id,contact> mapAgentCon = new map<id,contact>();
        map<id,contact> mapExhCon = new map<id,contact>();
        map<string,string> exhibitorAgentMap = new map<string,string>();
        mapExhCon.put(oContac.Id,oContac);
        mapAgentCon.put(oContac.Id,oContac);
        exhibitorAgentMap.put(oContac.Id,oContac.Id);
        AgentOwnExhibitorsCtrl.sendEmailByCode(eventEdition.id,'SETA',mapAgentCon,mapExhCon,exhibitorAgentMap);
        list<AgentOwnExhibitorsCtrl.exhibitorsWrapperClass> objExh=  AgentOwnExhibitorsCtrl.getSubAgents(eventEdition.Event_Code__c);
    }
    //CCEN-745 For Covering BoothType
    @isTest static void validateBoothtype()
    {
        //Create account
        account objAcc = new account(Name='TestLName');
        insert objAcc;
        System.AssertNotEquals(objAcc, null, 'Account must not be null');
        
        //Create Event_Edition__c
        Event_Edition__c eventEdition = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert eventEdition;
        System.AssertNotEquals(eventEdition, null, 'Event_Edition__c must not be null');
        
        //Create Event_Settings__c
        Event_Settings__c eventSettings = new Event_Settings__c(Name='Test',About_Show__c='Test',ShowHours1__c='test',ShowHours2__c='Test',Branding_Color__c='Black',Link_1__c='http://m.www.google.com/',Is_Stand_Design_Visible__c=True,Is_Stand_Detail_Visible__c=True,Is_SubContractors_Visible__c=True,Is_Amount_Visible__c=True,
                                                                Link_2__c='http://m.www.google.com/',Link_3__c='http://m.www.google.com/',Link_4__c='http://m.www.google.com/',Link_1_Label__c='TestLink1',Link_2_Label__c='TestLink2',Link_3_Label__c='TestLink3',Link_4_Label__c='TestLink4',
                                                                FaceBook__c='http://m.www.facebook.com/',LinkedIn__c='http://m.www.linkedin.com/',Twitter__c='http://m.www.Twitter.com/',YouTube__c='http://m.www.youtube.com/',Custom_1_Title__c='CstmTitle',Event_Edition__c=eventEdition.Id,E_Commerce_Title__c='EC Title',Welcome_Stand_Contractor__c='WSC Test',Disable_this_information__c=True, 
                                                               Is_Event_Edition_Live__c = true, Send_Welcome_Email__c = true,   Send_email_notification_to_Agents__c  =true);
        eventSettings.Allotment_By_Booth_Type__c=true; 
        insert eventSettings;
        System.AssertNotEquals(eventSettings, null, 'Event_Settings__c must not be null');
        
        //create ExpocadBooth__c
        ExpocadBooth__c expBooth = new ExpocadBooth__c(Booth_Number__c='TestBoothNo',Dimensions__c = '5M x 10M',Area__c ='50 m²',status__c='Rented',Matched_Product_Name__c='Pavilion Space');
        insert expBooth;
        System.AssertNotEquals(expBooth, null, 'ExpocadBooth__c must not be null');  
        
        //create Opportunity_ExpoCAD_Booth_Mapping__c
        Opportunity_ExpoCAD_Booth_Mapping__c oppBooth=new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppBooth.Account__c=objAcc.Id;
        oppBooth.Status__c='Active';
        oppBooth.Expocad_Booth__c=expBooth.id;
        insert oppBooth;
        System.AssertNotEquals(oppBooth, null, 'Opportunity_ExpoCAD_Booth_Mapping__c must not be null');
        
        //Create Booth Size Badge Limit
        Booth_Size_Badge_Limit__c objBoothLimit = new Booth_Size_Badge_Limit__c();
        objBoothLimit.Event_Edition__c=eventEdition.Id;
        objBoothLimit.Badges_Allowed__c=10;
        objBoothLimit.Booth_Type__c='Pavilion Space';
        objBoothLimit.Match_Product_Entry_Type__c='Fixed';
        insert objBoothLimit;
        System.AssertNotEquals(objBoothLimit, null, 'Booth_Size_Badge_Limit__c must not be null');
        
        test.startTest();
        string sEventCode=eventEdition.Event_Code__c;
        sEventCodeNew=eventEdition.Event_Code__c;
        AgentOwnExhibitorsCtrl.exhibitorsWrapperClass  lstBooth =  AgentOwnExhibitorsCtrl.getBoothDetails(oppBooth.Id,sEventCode,'Agent Owned Exhibitor'); 
        System.AssertNotEquals(lstBooth, null, 'lstBooth must not be null');
        test.stopTest();
    }
}