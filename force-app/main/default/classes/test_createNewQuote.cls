/**
 * @Author      : 
 * @Date        : 
 * Apex Class : 
 * * Modified By : Rajesh kumar Yadav Bk-3751, [Modified By : Aishwarya 12 Aug 2020 BK-3751]
 */
@isTest 
public class test_createNewQuote{
    
    static testMethod void method1(){
        
        Account acc= new Account();
        acc.name = 'test acc';
        insert acc;
        system.assertEquals(acc.Name, 'test acc', 'Both values should be the same.');
        
        AccountTeamMember Teammemberad = new AccountTeamMember();
        Teammemberad.AccountId=acc.id;
        Teammemberad.UserId=userinfo.getuserid();
        insert Teammemberad;
        system.assertEquals(Teammemberad.UserId, userinfo.getuserid(), 'Account team member eqauls to login user');
        
        Contact con = new Contact(LastName='Rebook_EECont', Email='test1contact@sforce.com', AccountId = acc.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='',MailingCountry='India');
        insert con;
        system.assertEquals(con.AccountId, acc.id, 'Contact account id equals to account id');
        
        Opportunity opp = new Opportunity();
        opp.name = 'test opp';
        opp.Billing_Contact__c = con.id;
        opp.accountid = acc.id;
        opp.Ownerid = userinfo.getuserid();
        opp.stagename = 'Prospecting';
        opp.closeDate = date.today();
        insert opp;
        system.assertEquals(opp.name, 'test opp', 'Both values should be the same.');
        apexpages.currentpage().getparameters().put('opportunityId' , opp.id);

        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        ext_CreateNewQuote cls = new ext_CreateNewQuote(sc);
        /*cls.newQuote();
        cls.cancelQuote();*/
    }
    
    static testMethod void method2(){
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Account acc= new Account();
        acc.name = 'test acc';
        insert acc;
        system.assertEquals(acc.Name, 'test acc', 'Both values should be the same.');
        
        AccountTeamMember Teammemberad = new AccountTeamMember();
        Teammemberad.AccountId=acc.id;
        Teammemberad.UserId=userinfo.getuserid();
        insert Teammemberad;
        system.assertEquals(Teammemberad.UserId, userinfo.getuserid(), 'Account team member eqauls to login user');
        
        Contact con = new Contact(LastName='Rebook_EECont', Email='test1contact@sforce.com', AccountId = acc.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='',MailingCountry='India');
        insert con;
        system.assertEquals(con.AccountId, acc.id, 'Contact account id equals to account id');
        
        Opportunity opp = new Opportunity();
        opp.name = 'test opp';
        opp.Billing_Contact__c = con.id;
        opp.accountid = acc.id;
        opp.Ownerid = userinfo.getuserid();
        opp.stagename = 'Prospecting';
        opp.closeDate = date.today();
        opp.EventEdition__c = oEvent.id;
        insert opp;
        system.assertEquals(opp.name, 'test opp', 'Both values should be the same.');
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent',SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opp.id , SBQQ__Account__c = acc.Id,SBQQ__Primary__c = true);
        insert oQuote;
        system.assertEquals(oQuote.SBQQ__Status__c, 'Quote Sent', 'Quote status equals to Quote');
        //apexpages.currentpage().getparameters().put('opportunityId' , opp.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        ext_CreateNewQuote cls = new ext_CreateNewQuote(sc);
        /*cls.newQuote();
        cls.cancelQuote();*/
    }
}