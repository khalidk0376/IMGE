/**
* Created By:  Girikon(Shashank)
* Created On:  20/08/2018
* @description : test class for StandDetailTrigger(100%)  , StandDetailTriggerHandler(100%)

* Modification Log----- 
* Modified by : 
* Ticket No   : BK-14521 Updating API Version
**/
@isTest
public class StandDetailTrigger_Test 
{
    public static  testMethod void makeData()
    {
        //create Account record
        Account acc = new Account(Name='TestAcc' );
        insert acc;
        System.assertNotEquals(null, acc.Name,'Invalid Account');
        
        //create contact record
        Contact con = new Contact(AccountId =acc.Id, FirstName = 'TestConFirst', LastName = 'TestConLast', Email='abc@test.com');
        insert con;

        //create BoothContractorMapping__c record
        BoothContractorMapping__c boothConMap = new BoothContractorMapping__c(Approved__c=True, Contact__c=con.Id, 
                                                                        status__c='Rejected');
        insert boothConMap;                                                              

        //create Stand_Detail__c record
        Stand_Detail__c standDetail = new Stand_Detail__c(Account__c=acc.Id,Amount__c = '25',IsRigging__c=true,IsDoubleDecker__c=true,
                                                          Contractor_Agreement_CA__c=true, Is_Heavy_Machinery__c=true,Receipt__c= '27',
                                                     Riggering_Options__c = 'Truss with logo',IsReceived__c = true,BoothContractorMapping__c=boothConMap.id);
        insert standDetail;
    }
    
}