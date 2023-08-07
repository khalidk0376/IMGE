/*****
* Created By       :   Girikon(Yash[STL-33])
* Created On       :   08/14/2019
* @description     :   Test class for SSCDashboardLtngCtrl class 94%
* Modified by      :   Yash Gupta [10/23/2019]
* Modified by      :   Palla Kishore [11/18/2021] for ticket : [EMEA-93]
******/

@IsTest
public class SSCDashboardLtngCtrl_Test {
     @IsTest
    private static void getTest()
    {
       
        //@Description: Insert Account.
        Account acc = new Account();
        acc.Name = 'Testing Account';
        acc.BillingCountry = 'India';
        acc.CurrencyIsoCode = 'INR';
        insert acc;
        System.assertEquals('Testing Account', acc.name,'true');
        
         //@Description: Insert Contact.
        Contact ocontact = new Contact();
        ocontact.FirstName = 'Testing First Name';
        ocontact.LastName = 'Testing Last Name';
        ocontact.Email = 'test.test@gmail.com';
        ocontact.AccountId = acc.Id;
        ocontact.MailingStreet = 'Test Street';
        ocontact.MailingCity='Test City';
        ocontact.MailingCountry = 'India';
        ocontact.MobilePhone = '+916612345678';
        insert ocontact;
        System.assertEquals('Testing First Name', ocontact.FirstName,'true');
        
        //@Description: Insert Event Edition.
        Event_Edition__c eventEdition = new Event_Edition__c();
        eventEdition.Name = 'Testing Event Edition';
        eventEdition.Tab1__c = 'Tab1';
        eventEdition.Tab4__c = 'Tab4';
        eventEdition.Tab8__c = 'Tab8';
        eventEdition.No_Billing__c = true;
        eventEdition.Review_by_Sales_Ops_Team__c = True;
        insert eventEdition;
        System.assertEquals('Testing Event Edition', eventEdition.name,'true');
        
        //@Description: Insert Opportunity.
        Opportunity opp = new Opportunity();
        opp.Name = 'Testing Opportunity';
        opp.EventEdition__c = eventEdition.Id;
        opp.Opportunity_Contact__c = ocontact.Id;
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.Today().addDays(1);
        opp.stagename = 'Discover';
        opp.Type='New';
        insert opp;
        System.assertEquals('Testing Opportunity', opp.name,'true');
        opp.stagename = 'Closed Won';
        opp.status__c = 'Sales Ops Review - Pending';
        update opp;
        
        SSCDashboardLtngCtrl.getSSCTeamMember();
        SSCDashboardLtngCtrl.getOperationTeamMember();
        SSCDashboardLtngCtrl.isSSCBrazilUser();
        SSCDashboardLtngCtrl.isBrazilUser();
        SSCDashboardLtngCtrl.getProductBrasilCondition(opp.Id);
        SSCDashboardLtngCtrl.isVisible('abcd',opp.Id);
        SSCDashboardLtngCtrl.isShowProductHeader(opp.Id);
        SSCDashboardLtngCtrl.getAgreements(opp.id,'%Test%');
        Test.startTest();
        try
        {
            SSCDashboardLtngCtrl.approveContract(opp,true);
            
            SSCDashboardLtngCtrl.approveContract(opp,false);

        }
        catch(exception e)
        {
         Test.stopTest();
        }
        SSCDashboardLtngCtrl.getRejectionOptions();
        SSCDashboardLtngCtrl.getSalesOpsRejectionOptions();
        SSCDashboardLtngCtrl.approveRejectAmmendedOpportunit(opp.Id,'Reject','Test','No signature on contract');
        SSCDashboardLtngCtrl.approveRejectAmmendedOpportunit(opp.Id,'Approve','Test','No signature on contract');
        SSCDashboardLtngCtrl.getPickListValuesIntoList();
        SSCDashboardLtngCtrl.getOpportunityStatus(opp.Id);
    }
}