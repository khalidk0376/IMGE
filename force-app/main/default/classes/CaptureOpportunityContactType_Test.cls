/**
 * Created/Modified By: Girikon (Raj)
 * Created On:          06/29/2018 
 * Description/Purpose: This test class covers the apex class : captureOpportunityContactType
 * Methods:             captureOpportunityContactType_Test1
 * Apex Class:          captureOpportunityContactType
**/

@isTest
public class CaptureOpportunityContactType_Test {

    public static testMethod void CaptureOpportunityContactType_Test1(){
        
        
        User_Type__c uType = new User_Type__c(Name ='Exhibitor');
        insert UType;
        System.AssertEquals(uType.Name, 'Exhibitor', 'Usertype must not be null');
        
        account acc = new account(Name='Account LName');
        insert acc;
        System.AssertNotEquals(acc, null, 'Account not equal null');
        
        Contact con = new Contact(LastName='Contact LName',FirstName ='FName', Type__c=UType.Id,AccountId = acc.id);
        insert con;
        
        Event_Edition__c oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert oEve;
        
        opportunity opp = new opportunity();
        opp.Name='World of Concrete 2017';
        opp.EventEdition__c=OEve.id;
        opp.AccountId = acc.id;
        opp.Paid_Amount__c=10.00;
        opp.Amount=20.00;
        opp.CloseDate=System.Today();
        opp.StageName='Needs Assessment';
        opp.CurrencyIsoCode=OEve.EventCurrency__r.Name;
        opp.Billing_Contact__c = con.id;
        opp.Marketing_Contact__c = con.id;
        opp.Opportunity_Contact__c = con.id;
        opp.Operations_Contact__c = con.id;
        opp.Safety_Contact__c = con.id;
        opp.Agreement_Contact__c = con.id;
        opp.Stand_Contractor__c = con.id;
        
        Test.startTest();
         insert opp;
            opp.StageName='Closed Won';
            update opp;
            System.assertEquals(opp.StageName, 'Closed Won', 'StageName should is Closed Won');

        CaptureOpportunityContactType.captureOpportunityContactTypes(String.valueOf(OEve.id),String.valueOf(acc.id),String.valueOf(con.id));
        
        Test.stopTest();
        
        
    }
}