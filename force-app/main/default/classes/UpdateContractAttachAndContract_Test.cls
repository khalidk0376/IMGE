/**
 * Project:         GAP
 * Date:            28/12/2018
 * Test Class For:  UpdateContractAttachAndContract_Class
 * Code Coverage:   95%
 * Created By:      Rajesh Kumar
 * Modified Date:   28/12/2018
 * Modified By:     Rajesh Kumar
 * *************************************************************************
 * @Description     This test class covers "UpdateContractAttachAndContract_Class" class.
 * *************************************************************************
 * History: 
 */
 @isTest
public class UpdateContractAttachAndContract_Test {
     @isTest static void updateContractAttachMethodOne() {    
           
      //@Description List and Map Declaration
      Set<Id> sids = new Set<Id>();
      Map<Id, SBQQ__Quote__c> mapOldQuote = new map<Id, SBQQ__Quote__c>();
      
      //@Description Insert Account.
      Account acc = new Account();
      acc.Name = 'Testing Account'; 
      acc.CurrencyIsoCode = 'USD';
      insert acc;
      System.assertNotEquals('Testing Account', acc.Id,'Account Id should not be null');
      
      //@Description Insert Contact.
      Contact ocontact = new Contact();
      ocontact.FirstName = 'Testing First Name';
      ocontact.LastName = 'Testing Last Name';
      ocontact.Email = 'test.test@gmail.com';
      ocontact.AccountId = acc.Id;
      insert ocontact;
      
      //@Description Insert Event Edition.
      Event_Edition__c eventEdition = new Event_Edition__c();
      eventEdition.Name = 'Testing Event Edition';
      eventEdition.Tab1__c = 'Tab1';
      eventEdition.Tab4__c = 'Tab4';
      eventEdition.Tab8__c = 'Tab8';
      insert eventEdition;
        
      //@Description Insert Opportunity.
      Opportunity opp = new Opportunity();
      opp.Name = 'Testing Opportunity';
      opp.EventEdition__c = eventEdition.Id;
      opp.Opportunity_Contact__c = ocontact.Id;
      opp.AccountId = acc.Id;
      opp.CloseDate = Date.Today().addDays(1);
      opp.StageName = 'Customize';
      insert opp;
         
      opp.SBQQ__Contracted__c = true;
      opp.Contract_Attached__c = true;
      update opp;
         
      //@Description Insert Quote.
      SBQQ__Quote__c qtObj1 = new SBQQ__Quote__c();
      qtObj1.SBQQ__Account__c = acc.Id;
      qtObj1.SBQQ__Status__c = 'Draft';
      qtObj1.SBQQ__Type__c = 'Quote';
      qtObj1.SBQQ__StartDate__c = date.today();
      qtObj1.Alternate_Currency2__c = 'EUR';
      qtObj1.SBQQ__Opportunity2__c = opp.Id;
      qtObj1.Billing_Contact__c = ocontact.Id;
      //qtObj1.CurrencyIsoCode='GBP';
      qtObj1.IsNotGeneralDocument__c = True;
      insert qtObj1;
      mapOldQuote.put(qtObj1.Id, qtObj1);
      sids.add(qtObj1.SBQQ__Opportunity2__c);
      opp.SBQQ__Contracted__c = true;
      opp.Contract_Attached__c = true;
      update opp;
      
      UpdateContractAttachAndContract_Class updClass = new UpdateContractAttachAndContract_Class();
      updClass.updateContractAttachAndContractMethod(sids);
     }
}