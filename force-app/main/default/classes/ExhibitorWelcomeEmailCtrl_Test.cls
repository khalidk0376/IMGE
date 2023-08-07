/**
 * Created/    : Girikon(Sunil)
 * Modified By : Girikon(Garima)
 * Created On:          20 Feb 2018
 * @description      : This test class covers the apex class : ExhibitorWelcomeEmailCtrl
 * Methods Cover:       getOppBoothDetails
 * Apex Class:          ExhibitorWelcomeEmailCtrl
**/

@isTest
public class ExhibitorWelcomeEmailCtrl_Test{
    public static testMethod void exhibitorWelcomeEmailCtrlTest() 
    {        
        List<User_Type__c> lstUserTypes=new List<User_Type__c>();
        User_Type__c uType = new User_Type__c(Name ='Exhibitor');
        lstUserTypes.Add(uType);
        System.AssertEquals(uType.Name, 'Exhibitor','Not a Valid Usertype');
        
        User_Type__c uTypestand = new User_Type__c(Name ='Stand Contractor');
        lstUserTypes.Add(uTypestand);
        
        User_Type__c uTypeCo = new User_Type__c(Name ='Co-Exhibitor');
        lstUserTypes.Add(uTypeCo);

        User_Type__c uTypeAgent = new User_Type__c(Name ='Agent');
        lstUserTypes.Add(uTypeAgent);
        
        User_Type__c uTypeAgentExh = new User_Type__c(Name ='Agent Owned Exhibitor');
        lstUserTypes.Add(uTypeAgentExh );
        
        Insert lstUserTypes;
        
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'Account should not be null');
        
        Event_Edition__c oEve = new Event_Edition__c(Name='TOC Europe 2018',Event_Code__c='18toce',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert oEve;
        
        List<Contact> lstContacts=new List<Contact>();
        Contact con = new Contact(LastName='UserLast',FirstName ='Test',email='test1@test.com', Type__c=uType.Id,AccountId = acc.id,User_Created_for_Event_Edition__c=oEve.id);
        lstContacts.Add(con);
        System.AssertNotEquals(con, null,'Contact should not be null');
        
        Contact constand = new Contact(LastName='UserStand',FirstName ='Test',email='test11@test.com', Type__c=uTypestand.Id,AccountId = acc.id,User_Created_for_Event_Edition__c=oEve.id);
        lstContacts.Add(constand);
        
        Contact conCo  = new Contact(LastName='UserCo',FirstName ='Test',email='test11@test.com', Type__c=uTypeCo.Id,AccountId = acc.id,User_Created_for_Event_Edition__c=oEve.id);
        lstContacts.Add(conCo);
        
        Contact conAgent   = new Contact(LastName='UserAgent',FirstName ='Test',email='test11@test.com', Type__c=uTypeAgent.Id,AccountId = acc.id,User_Created_for_Event_Edition__c=oEve.id);
        lstContacts.Add(conAgent);
        
        Contact conAgentExh   = new Contact(LastName='UserAgent',FirstName ='Test',email='test11@test.com', Type__c=uTypeAgentExh.Id,AccountId = acc.id,User_Created_for_Event_Edition__c=oEve.id);
        lstContacts.Add(conAgentExh );
        
        Insert lstContacts;
        
        
        
        EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=oEve.id);
        insert eventCurrency;
        System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
        oEve.EventCurrency__c = eventCurrency.id;
        update oEve;
        System.assertNotEquals(oEve.EventCurrency__c, null, 'Event Currency must not be null');
        opportunity opp = new opportunity(Name='TOC Europe 2018 opp',EventEdition__c=oEve.id,AccountId = acc.id,Paid_Amount__c=10.00,Amount=20.00,CloseDate=System.Today(),StageName='Closed Won',CurrencyIsoCode=oEve.EventCurrency__r.Name);
        insert opp;
        //System.assert(opp != null, 'opportunity');
        System.assertNotEquals(opp,null,'opportunity should not be null' );
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c ='Draft',SBQQ__PrimaryContact__c=con.Id,SBQQ__Primary__c =true, CurrencyIsoCode=eventCurrency.name,SBQQ__Type__c='Quote',SBQQ__StartDate__c=System.Today(),SBQQ__Opportunity2__c=opp.id);
        insert oQuote;
       // System.assert(oQuote != null, 'SBQQ__Quote');
         System.assertNotEquals(oQuote,null, 'SBQQ__Quote must not be null ');
        // System.assert(oQuote.SBQQ__Opportunity2__c == opp.id, 'SBQQ__Quote oppId');
          System.assertEquals(oQuote.SBQQ__Opportunity2__c,opp.id, 'SBQQ__Quote oppId');
         ExpocadBooth__c oExpocadBooth = new ExpocadBooth__c(Booth_Number__c='Test booth 1',Area__c='201',Unit_Type__c='Test Unit',quote__c=oQuote.id);
        insert oExpocadBooth;
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBooth = new Opportunity_ExpoCAD_Booth_Mapping__c(Expocad_Booth__c=oExpocadBooth.id, Quote__c=oQuote.id, Opportunity__c=opp.id);
        insert oppExpoBooth;
        Booth_Size_Badge_Limit__c boothSizeBadgeLimit = new Booth_Size_Badge_Limit__c(Badges_Allowed__c=1.0,Booth_Size_From__c=201.0, Booth_Size_To__c=201.0,Event_Edition__c=oEve.id);
        insert boothSizeBadgeLimit;
        
        Order o = new Order(name='Test1',AccountId=acc.id,EffectiveDate=system.today(),status='draft', OpportunityId = opp.id);
        insert o;
        
        blng__Invoice__c invoiceObj = new blng__Invoice__c(blng__Order__c =o.id,blng__InvoiceDate__c=Date.today(),blng__Account__c=acc.id);
        //insert invoiceObj;
        Contract oContract = new Contract(SBQQ__Opportunity__c=opp.id,AccountId=acc.id);
        insert oContract;
        
        List<ContactEventEditionMapping__c> lstCEEMs=new List<ContactEventEditionMapping__c>();
        ContactEventEditionMapping__c conevmap = new ContactEventEditionMapping__c(SFContactID__c=con.id,SFEventEditionID__c=lstContacts[0].User_Created_for_Event_Edition__c, User_Type__c=uType.Id);
        lstCEEMs.Add(conevmap);
        
        ContactEventEditionMapping__c conevmapstand = new ContactEventEditionMapping__c(SFContactID__c=constand.id,SFEventEditionID__c=lstContacts[0].User_Created_for_Event_Edition__c, User_Type__c=uTypestand.Id);
        lstCEEMs.Add(conevmapstand);
        
        ContactEventEditionMapping__c conevCo = new ContactEventEditionMapping__c(SFContactID__c=conCo.id,SFEventEditionID__c=lstContacts[0].User_Created_for_Event_Edition__c, User_Type__c=uTypeCo.Id);
        lstCEEMs.Add(conevCo);
        
        ContactEventEditionMapping__c conevmapAgent = new ContactEventEditionMapping__c(SFContactID__c=conAgent.id,SFEventEditionID__c=lstContacts[0].User_Created_for_Event_Edition__c, User_Type__c=uTypeAgent.Id);
        lstCEEMs.Add(conevmapAgent);
        
        ContactEventEditionMapping__c conevmapAgentExh = new ContactEventEditionMapping__c(SFContactID__c=conAgentExh .id,SFEventEditionID__c=lstContacts[0].User_Created_for_Event_Edition__c, User_Type__c=uTypeAgentExh .Id);
        lstCEEMs.Add(conevmapAgentExh );
        
        Insert lstCEEMs;
        
        AgentExhibitorsContact__c oExh = new AgentExhibitorsContact__c(ExhibitorContactId__c=conAgentExh.id); 
        insert oExh ;
        
        Event_Settings__c oEventSett = new Event_Settings__c(Co_Exhibitor_Email_Content1__c='test Co Exh1',Co_Exhibitor_Email_Content2__c='test Co Exh2',Exhibitor_Email_Content1__c='testExh1',Exhibitor_Email_Content2__c='testExh2',Agent_Email_Content1__c='Test Agent1', Agent_Email_Content2__c='Test Agent 2', Stand_Contractor_Content1__c='stantcon1', Stand_Contractor_Content2__c='standcon2', Event_Edition__c=oEve.id);
        insert oEventSett;

        opp.StageName = 'Closed Won';
        update opp;
        
        System.assertEquals(opp.StageName , 'Closed Won', 'StageName is Clsoed Won');
        Test.startTest();
        ExhibitorWelcomeEmailCtrl objcom =new ExhibitorWelcomeEmailCtrl();
        //Exhibitor type user
        objcom.sContactId=con.id;
        objcom.sIdContact=con.id;
        objcom.getOppBoothDetails();
        objcom.getCommunityURL();
        objcom.getemailBodyTwo();
        objcom.getemailBodyOne();
        objcom.geteventUrl();
        
        //Stand Contractor type user        
        objcom.sContactId=constand.id;
        objcom.getemailBodyTwo();
        objcom.getemailBodyOne();
        
        //Co-Exhibitor  type user  
        objcom.sContactId=conCo.id;
        objcom.getEmailBodyTwo();
        objcom.getEmailBodyOne();
        
        //Agent type user  
        objcom.sContactId=conAgent.id;
        objcom.getemailBodyTwo();
        objcom.getemailBodyOne();
        
        //AgentExhibitor type user  
        objcom.sContactId=conAgentExh.id;
        objcom.getemailBodyTwo();
        objcom.getemailBodyOne();
        Test.stopTest();
    }
}