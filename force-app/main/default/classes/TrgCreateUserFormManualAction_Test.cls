/**
 * Created/Modified By: Girikon(Pramod)
 * Created On:          02/22/2018
 * Description/Purpose: This test class for After Insert trigger ContactEventEditionMapping__c
 * trigger name:        trgCreateUserFormManualAction
**/

@isTest
public class TrgCreateUserFormManualAction_Test
{
    public static testMethod void trgCreateUserFormManualActionTest()
    {
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'Account not equal null');
                
        Contact con11 = new Contact(LastName='User1',FirstName ='Test1',email='test2@test.com',AccountId = acc.id);
        insert con11;
        System.AssertNotEquals(con11, null,'Contact not equal null');
            
        Event_Edition__c oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert oEve;
        
        ContactEventEditionMapping__c oMapping = new ContactEventEditionMapping__c(SFContactID__c=con11.id,SFEventEditionID__c=OEve.id);
        insert oMapping;
    }
}