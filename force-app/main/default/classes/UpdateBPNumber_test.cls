/**
 * @Author      : 
 * @Date        : 
 * Apex Class : 
 * * Modified By : Rajesh kumar Yadav Bk-3751
 */

@isTest
public class UpdateBPNumber_test{
    static testMethod void unitTestMethod1(){
         // Create Trigger test record 
        Trigger__c trig = new Trigger__c(Name = 'UpdateBPNumber_Trg' , Trigger_Name_Unique__c='UpdateBPNumber_Trg',Enabled__c=true,Object__c='Account_Legal_Entity__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=1,
                                         After_Insert__c=true , After_Update__c = true);
        Insert trig;


        system.assertEquals(trig.Name, 'UpdateBPNumber_Trg', 'Both values should be the same.');

        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        //Call event edition trigger interface
        TriggerInterface_Account_Legal_Entities obj = new TriggerInterface_Account_Legal_Entities();
        //Call trigger app handler for insert event
        TriggerInterfaceHelper.runTrigger('UpdateBPNumber_Trg','Account_Legal_Entity__c',1, 'ai', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('UpdateBPNumber_Trg'); 
        Account acc=new Account(name='test');
        insert acc;
        blng__LegalEntity__c legalEntity=new blng__LegalEntity__c(Name='testLega entity');
        insert legalEntity;
        Account_Legal_Entity__c accEntity=new Account_Legal_Entity__c(Account__c=acc.Id,Business_Partner_Number__c ='123456',Legal_Entity__c=legalEntity.Id);
        insert accEntity;
        System.assertEquals(trig.Name, 'UpdateBPNumber_Trg' , 'Test Class Failed');
    }
}