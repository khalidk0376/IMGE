/**
* File:        Rebook_Event_Edition_Ctrl_Test
* Project:     GAP
* Date:        Dec 02, 2016
* Created By:  Kumar Gaurav
* *************************************************************************
* @description Test class for Class Rebook_Event_Edition_Ctrl.
* *************************************************************************
* History: 
* Update By : Shiv Raghav Sharma
* Date :  Jan 17,2019
* description Updated code according to new feature of rebooking functionality - 'Rebook_Event_Edition_Ctrl' 
*/

@isTest(seeAlldata = false)
public class Rebook_Event_Edition_Ctrl_Test {
    
    static testMethod void unitTest() {
        Test.StartTest();
        Account oAccount = new Account(Name='Rebook_EE Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        
        Contact oCon = new Contact(LastName = 'Rebook_EECont', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='',MailingCountry='India');
        insert oCon;
        
        Contact oCon2 = new Contact(LastName = 'Rebook_EECont2', Email = 'test1contact2@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='',MailingCountry='India');
        insert oCon2;
        System.AssertEquals('Rebook_EECont', oCon.LastName,'Error Contact lastname should be equal');    
        User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        AccountTeamMember oAtm =new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
        insert oAtm;
        
        Event_Edition__c oEvent = new Event_Edition__c( Name = 'World of Concrete 2017',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Start_Date__c = Date.today(), Scheduled_Reebook__c = true, Scheduled_Date__c = Date.today());
        oEvent.Event_Edition_Code__c = 'Test1';
        insert oEvent;
        
        Event_Edition__c oEvent2 = new Event_Edition__c(Previous_Event_Edition__c=oEvent.id, Name = 'World of Concrete 2018',Approval_Service_Now_ID__c = '1234',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Start_Date__c = Date.today());
        oEvent2.Event_Edition_Code__c = 'Test2';
        insert oEvent2;
        
        Event_Edition__c oEvent3 = new Event_Edition__c(Previous_Event_Edition__c=oEvent.id, Name = 'World of Concrete 2020',Approval_Service_Now_ID__c = '1245',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt');
        oEvent3.Event_Edition_Code__c = 'Test3';
        insert oEvent3;  
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity',SBQQ__Contracted__c = True, CloseDate = Date.today(), StageName = 'Closed Booked', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id, Rebooked__c = false);
        insert oOpportunity; 
        
        Opportunity oOpportunity2 = new Opportunity(Name = 'Expocad Opportunity',SBQQ__Contracted__c = True, CloseDate = Date.today(), StageName = 'Closed Booked', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon2.Id, Rebooked__c = false);
        insert oOpportunity2;         
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oEvent2);
        Apexpages.currentpage().getparameters().put('id' , oEvent2.id);
        Rebook_Event_Edition_Ctrl oRebookEventEdition = new Rebook_Event_Edition_Ctrl(sc);
        oRebookEventEdition.returnToPP();
        
        try{
            oOpportunity.StageName = 'Closed Booked';
            update oOpportunity;
            
            oOpportunity2.StageName = 'Closed Booked';
            update oOpportunity2;
            
            oCon2.InActive__c = true;
            update oCon2;        
            oRebookEventEdition.rebookEE(); 
            
            ApexPages.StandardController sc1 = new ApexPages.StandardController(oEvent3);
            Apexpages.currentpage().getparameters().put('id' , oEvent3.id);
            Rebook_Event_Edition_Ctrl oRebookEventEdition1 = new Rebook_Event_Edition_Ctrl(sc);
            oRebookEventEdition1.returnToPP(); 
            oRebookEventEdition1.rebookEE();
        }
        catch(Exception ex){
            System.debug('Error from Test Class '+ex);
        }
        Test.StopTest();
    }
}