/**
* File:            UpdateQuoteDocReleaseBooth_Test.cls
* Project:         GAP
* Date:            5th Feb 2019
* Created By:      Yash Gupta
* *************************************************************************
* @Description     UpdateQuoteDocReleaseBooth Class
* Code Coverage: 
* *************************************************************************
* History: [Modified By : Aishwarya 12 Aug 2020 BK-3751]
*/
@isTest
public class UpdateQuoteDocReleaseBooth_Test {
    
    @testSetup static void setup() {
        
        Account oacc = new Account (Name = 'testAccount');
        insert oacc ;
        System.assertEquals('testAccount', oacc.name, 'Account should not be null');
        
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oacc.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='',MailingCountry='India');
        insert oCon;
        
        Brand__c oBrand = new Brand__c(Name='World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c=oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        system.assertEquals(oEventseries.Name , 'World Of Concrete', 'Both values should be the same.');
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal Approved', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oacc.Id, Billing_Contact__c = oCon.Id);
        insert oOpportunity;
        system.assertEquals(oOpportunity.Name , 'Expocad Opportunity', 'Both values should be the same.');
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oacc.Id, SBQQ__Primary__c = true);
        insert oQuote;
        system.assertEquals(oQuote.SBQQ__Status__c, 'Quote Sent', 'Both values should be the same.');
        
        SBQQ__Quote__c oQuote2 = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oacc.Id, SBQQ__Primary__c = false);
        insert oQuote2;
        system.assertEquals(oQuote2.SBQQ__Status__c, 'Quote Sent', 'Both values should be the same.');
        
        ExpocadBooth__c oeb = new ExpocadBooth__c(Quote__c = oQuote2.Id, Status__c = 'On Hold');
        oeb.Opportunity__c = oOpportunity.id;
        insert oeb;
        system.assertEquals(oeb.Opportunity__c, oOpportunity.id, 'Both values should be the same.');
       
        Sbqq__quotedocument__c sbqqquotedocumentcObj = new Sbqq__quotedocument__c ( SBQQ__SignatureStatus__c ='Pending', SBQQ__Template__c = 'test value');
        sbqqquotedocumentcObj.Name = 'test';
        sbqqquotedocumentcObj.SBQQ__Quote__c = oQuote.Id;
        sbqqquotedocumentcObj.CurrencyIsoCode = 'USD';
        sbqqquotedocumentcObj.SBQQ__Version__c = 1.0;
        insert sbqqquotedocumentcObj;
      
    }
    
    @isTest
    static void updateQuoteDocReleaseBoothMtdOne() {
        set<Id> sIds = new set<id>();
        List<Opportunity> oppList = [select Id, CloseDate, StageName, EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c from Opportunity];
        System.assertEquals('Discover', oppList[0].StageName, 'Opportunity should be inserted');
        // This code runs as the system user
        String uniqueUserName = 'Adminuser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id, Name FROM Profile WHERE Name='System Administrator'];
        system.assertEquals(p.Name, 'System Administrator', 'Both values should be the same.');
        User u = new User(Alias = 'standt', Email='adminuser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        System.runAs(u) {
            System.test.startTest();
            sIds.add(oppList[0].Id);
            UpdateQuoteDocReleaseBooth updater = new UpdateQuoteDocReleaseBooth(sIds);
            System.enqueueJob(updater );
            ID jobID = System.enqueueJob(updater );
            system.debug('oppList' + oppList); 
            //SBQQ__Quote__c oQuote = [select id, SBQQ__Status__c, SBQQ__Type__c , SBQQ__Opportunity2__c , SBQQ__Account__c , SBQQ__Primary__c from SBQQ__Quote__c];
            
       /*     Map<Id,SBQQ__Quote__c > lstmapQuote = new Map<Id,SBQQ__Quote__c >();
            lstmapQuote.put(oQuote.Id, oQuote);
            UpdateQuoteDocReleaseBooth objInstance = new UpdateQuoteDocReleaseBooth();
            objInstance.mapQuoteList = lstmapQuote;  */
            System.test.stopTest();
        }
    }
}