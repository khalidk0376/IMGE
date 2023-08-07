/**
* File:        ProductClonePageController_test.cls
* Project:     GAP
* Date:        11/17/2016 3:03 AM
* Created By: Rajesh Kumar
* *************************************************************************
* Description:ProductClonePageController class
* *************************************************************************
* History:
* Modified By : Rajesh kumar Yadav Bk-3751,[Modified By : Aishwarya 12 Aug 2020 BK-3751]
*/

@isTest(seeAlldata = false)
public class ProductClonePageController_test
{
    static testMethod void unitTest()
    {
        Account oacc = new Account(Name = 'Test');
        insert oacc;
        

        User usr = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        system.assertEquals(usr.Id, UserInfo.getUserId(), 'user id equals login user id');
        
        AccountTeamMember oatm = new AccountTeamMember(AccountId = oacc.id, userId = Usr.id);
        insert oatm;

        system.assertEquals(Oatm.AccountId, oacc.Id, 'Account id must be equals');
        
        Product2 prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth', Number_of_Corners__c = 0);
        insert prd1;
        system.assertEquals(prd1.Name, 'Linear Booth', 'Product name equals Linear Booth');
        
        Opportunity opp = new opportunity(name = 'test', closeDate = Date.Today(), StageName = 'Qalification', AccountId = oacc.id);
        insert opp;
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opp.id, SBQQ__Primary__c = true);
        insert oQuote;
        system.assertEquals(oQuote.SBQQ__Status__c, 'Quote', 'Status equals to Quote');
        
        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True,ServiceEndDate__c= Date.today());
        insert oQuoteLine ;
        system.assertEquals(oQuote.SBQQ__Status__c, 'Quote', 'Both values should be the same.');
        PageReference pageRef = Page.ProductClonePage;
        pageRef.getParameters().put('QuoteLineId', oQuoteLine.id);
        Test.setCurrentPage(pageRef);
        ProductClonePageController oProductClonePageController = new ProductClonePageController(); 
       
        oProductClonePageController.selectedContacts.add(new SelectOption('1', 'January(1)'));
       // oProductClonePageController.save();
        oProductClonePageController.salesPrice = '1234';
        oProductClonePageController.SelectedYear = '2016';
        oProductClonePageController.message = 'Selected Months: ';
        oProductClonePageController.save();
        String surl = 'test';
        oProductClonePageController.getURParameter(surl);
        oProductClonePageController.getLineItem();
    }
}