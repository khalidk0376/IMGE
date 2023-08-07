@isTest
Public class updateClosedLost_Test
{   
    // Method name is changed by Palla Kishore for the ticket BK-19606
    static testMethod void updateClosedLost_TestMethod()
    {
        Brand__c oBrand = new Brand__c(Name='World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        
        Account acc1 = new Account();
        acc1.Name='acc1';
        acc1.BillingCity ='Delhi' ;
        acc1.BillingCountry='india';
        acc1.BillingPostalCode='600075';
        acc1.BillingState='Delhi';
        acc1.BillingStreet='water well street';              
        insert acc1;
        System.assertEquals('acc1', acc1.name, 'account must be inserted');
        
        Contact con = new Contact(LastName='User',FirstName ='Test',AccountId=acc1.id , MailingState = 'Delhi' ,MailingCountry = 'India');
        insert con;
        
        Event_Series__c eentseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c=oBrand.id);
        insert eentseries;
        
        Event_Edition__c ee = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(), Part_of_Series__c = eentseries.Id , Tab1__c='testt' , Tab7__c='ttttt');
        insert ee;
  
        System.assertEquals(ee.Event_Code__c,'WOC17', 'Event Code');
        EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=ee.id);
        insert eventCurrency;
        System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
        ee.EventCurrency__c = eventCurrency.id;
        update ee; 

        opportunity opp = new opportunity(Name='World of Concrete 2017',EventEdition__c=ee.id,AccountId = acc1.id,Paid_Amount__c=10.00,Amount=20.00,CloseDate=System.Today(),StageName='Closed Won', CurrencyIsoCode=ee.EventCurrency__r.Name , Reason_Lost__c = 'AR Cancel / Re-bill');
        Test.startTest();
        insert opp;
        String soppid = opp.id; 
        updateClosedLost.updateClosedLostInOpp (soppid );
        Test.stopTest();
    
    }
    
}