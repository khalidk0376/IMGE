/**
 * Created By       :   Girikon(Sunil)
 * Created On       :   Mar 11 2019
 * @description     :   This is the test class of OpportunityCtrl.    
 * Apex Class       :   OpportunityCtrl
 
 * Modification log --
 * Modified by      :   
 * Modified By      :  Rajesh Kumar For Jira Ticket : BK-1230
 * Modified By      :  Himanshu Jasuja For Jira Ticket : BK-1909
 **/

@isTest
public class OpportunityDetailsCtrl_Test {
    
    static testMethod void opportunityCtrlTest()
    {
        User usr = [Select id from User where Id =: userInfo.getUserId()];
        System.assertNotEquals(null, usr.Id , 'Hello');
        
        Account acc1 = new Account();
        acc1.Name='acc1';
        acc1.BillingCity ='Delhi' ;
        acc1.BillingCountry='india';
        acc1.BillingPostalCode='600075';
        acc1.BillingState='Delhi';
        acc1.BillingStreet='water well street';              
        insert acc1;
        System.assertNotEquals(null, acc1.Id  , 'Hello');
        
        Account acc2 = new Account();
        acc2.Name='acc2';
        acc2.BillingCity ='Delhi' ;
        acc2.BillingCountry='india';
        acc2.BillingPostalCode='600075';
        acc2.BillingState='Delhi';
        acc2.BillingStreet='water well street';              
        insert acc2;
        System.assertNotEquals(null, acc2.Id , 'Hello');
        
        Contact oCon1 = new Contact();
        oCon1.FirstName = 'test';
        oCon1.Contact_Type__c = 'Invoice Contact';
        oCon1.LastName = 'ContTest11';
        oCon1.Email = 'abcd1@gmail.com';
        oCon1.AccountId = acc1.Id;
        oCon1.MailingStreet = 'Test1';
        oCon1.MailingCity = 'Test1';
        oCon1.MailingState='';
        oCon1.MailingCountry='India';
        oCon1.Phone = '+12345564788'; 
        oCon1.Inactive__c = false;
        oCon1.AssistantPhone = '+12445567788'; 
        oCon1.HomePhone = '+12345567388'; 
        oCon1.MobilePhone = '+12335567788'; 
        oCon1.OtherPhone = '+12346567788';
        insert oCon1;
        
        Event_Series__c eentseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC');
        insert eentseries;
        
        Event_Edition__c ee = new Event_Edition__c( name='Test Edition' );
        ee.Part_of_Series__c = eentseries.id;
        ee.Event_Currency__c = 'USD';
        ee.Event_Code__c     = 'WOC17';
        insert ee;
        System.assertEquals(ee.Event_Code__c,'WOC17', 'Event Code');
        
        EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=ee.id);
        insert eventCurrency;
        System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
        ee.EventCurrency__c = eventCurrency.id;
        update ee; 
        
        opportunity opp = new opportunity(Name='World of Concrete 2017', EventEdition__c=ee.id,AccountId = acc1.id,Paid_Amount__c=10.00,Amount=20.00,CloseDate=System.Today(),StageName='Discover',CurrencyIsoCode=ee.EventCurrency__r.Name, IsExistingContactAccount__c = false);
        Utility.isReviewProcess = true; 
        Utility.isRebookInProcess = true;
        insert opp;
        
        //BK-2636
        exhibitor_paid_by_for_sales_after_cw__c csObj = new exhibitor_paid_by_for_sales_after_cw__c();
        csObj.Name = 'exhibitor1';
        insert csObj;
        
        Test.startTest();
        OpportunityDetailsCtrl.getLookupDatas('Contact','Name', 'ContTest11', acc1.Id, acc2.Id, true,1,0);
        OpportunityDetailsCtrl.getCurrentUserDtls();
        OpportunityDetailsCtrl.getRecord(oCon1.Id, 'Contact', 'Phone');
        OpportunityDetailsCtrl.getEventCurrency(ee.Id);
        OpportunityDetailsCtrl.updateOpportunity(opp);
        OpportunityDetailsCtrl.getUserRecordAccess(usr.Id);
        OpportunityDetailsCtrl.getRecordType(opp.Id);
        OpportunityDetailsCtrl.getAllExhibPaidByValues();
        OpportunityDetailsCtrl.getAllDatas(oCon1.Id, 'Contact', 'Phone');
        OpportunityDetailsCtrl.checkSalesOpsUser();
        OpportunityDetailsCtrl.checkSalesOpsExtraUser();
        OpportunityDetailsCtrl.checkBrasilSalesOpsUser();
        OpportunityDetailsCtrl.checkBrasilContactUser();
        Test.stopTest();
    }
}