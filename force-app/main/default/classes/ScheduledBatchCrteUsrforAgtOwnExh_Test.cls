/*
* Created By:  Mahesh Kumar (Girikon)
* Created on :  08/10/2018
* Modified by : 
* Modified On : 
* Description : This test class covers the apex class scheduledBatchCreateUserforAgentOwnExh.
* Apex Class: scheduledBatchCreateUserforAgentOwnExh(100%) 
*/
@isTest
private class ScheduledBatchCrteUsrforAgtOwnExh_Test
{

    static testmethod void schedulerTest() {
        String cRON_EXP = '0 45 19 * * ?';
        
        //Create exhibitor user type
        User_Type__c uType = new User_Type__c(Name ='Agent Owned Exhibitor');
        insert uType;
        System.AssertEquals(uType.Name, 'Agent Owned Exhibitor','Invalid User type');
                
        //Create Account
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'Account must not be null');
        
        //Create contact
        Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com', Type__c=uType.Id,AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null,'Contact must not be null');
        set<Id> conIds = new set<Id>();
        conIds.add(con.id);
        
        //Create EventEdition 
        Event_Edition__c eventEdition1 = new Event_Edition__c(Name='TOC 2018',Event_Code__c='TOC18',Event_Currency__c='USD',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert eventEdition1;
        System.assertEquals(eventEdition1.Event_Code__c,'TOC18', 'Event Code');
       
        //Create AgentExhibitorsContact
        AgentExhibitorsContact__c   agentExCon = New AgentExhibitorsContact__c(AgentContactId__c=con.id, ExhibitorContactId__c=con.id,IsUserCreated__c=false,EventEdition__c=eventEdition1.id);
        insert AgentExCon;
        Test.startTest();

            String jobId = System.schedule('scheduledBatchCreateUserforAgentOwnExhTest',  CRON_EXP, new scheduledBatchCreateUserforAgentOwnExh());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression,'CRONEXP should be equal');
            System.assertEquals(0, ct.TimesTriggered,'Condition should be equal');

        Test.stopTest();
    }
}