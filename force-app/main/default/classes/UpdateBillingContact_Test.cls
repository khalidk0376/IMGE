/**
 * Created/Modified By  :  
 * Created On:          :  
 * @description         : 
 * Modification log --
 * * Modified By : Rajesh kumar Yadav Bk-3751
**/
@isTest(seeAlldata = false)
public class UpdateBillingContact_Test {
  static testMethod void unitTest() {
     
    Account oacc = new Account (Name = 'Testrajesh');
    insert oacc;
    system.assertNotEquals(oacc.id, null, 'Id cannot be blank');
    Contact newContact = new Contact(Lastname='testLastName', AccountId = oacc.Id, LeadSource='Cold call');
    insert newContact;
    system.assertNotEquals(newContact.id, null, 'Id cannot be blank');
    Opportunity opp = new opportunity (name = 'test' , closeDate = Date.Today(), StageName= 'Qalification' , AccountId = oacc.id , Billing_Contact__c = newContact.Id);
    insert opp;
    system.assertEquals(opp.name, 'test', 'Both values should be the same.');
    OpportunityContactRole oOpportunityContactRole  = new OpportunityContactRole(OpportunityId = opp.Id, ContactId = newContact.id);
    insert oOpportunityContactRole;
    system.assertNotEquals(oOpportunityContactRole.id, null, 'Id cannot be blank');
    PageReference pageRef = Page.UpdateOpportunityField;
    pageRef.getParameters().put('id',opp.id);
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(opp);
    UpdateBillingContact oUpdateBillingContact = new UpdateBillingContact(sc);
    oUpdateBillingContact.updatePrimaryContacteName();
  }
}