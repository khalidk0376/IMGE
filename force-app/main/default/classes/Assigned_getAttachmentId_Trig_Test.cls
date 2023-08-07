/*
Created By: {Girikon(Rajeev Mishra)}
Created On: 24/03/2020
Description/Purpose: Test class for Assigned_getAttachmentId_Trig_Test class 
Methods: 
Test Class: Assigned_getAttachmentId_Trig_Test(91%)

*/

@isTest
public class Assigned_getAttachmentId_Trig_Test {
   @isTest static void evntAttchTest(){
       Test.startTest();
       
        Trigger__c trig = new Trigger__c(Name = 'Assigned_getAttachmentId_Trig' , Trigger_Name_Unique__c='Assigned_getAttachmentId_Trig',Enabled__c=true,Object__c='attachment',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                         After_Insert__c=true , After_Delete__c = true);
        insert trig;
        Trigger_Recordtype__c rrrt = new Trigger_Recordtype__c(Recordtype_Id__c=trig.Id , Trigger__c=trig.Id,Enabled__c=true, Parameters__c='param=1;param=2');
        Insert rrrt; 
         
        TriggerInterface_Attachment obj=new TriggerInterface_Attachment();
       
        TriggerInterfaceHelper.runTrigger('Assigned_getAttachmentId_Trig','attachment', 2, 'ai', rrrt.id ,rrrt.Parameters__c,'All');
        TriggerInterfaceHelper.runTrigger('Assigned_getAttachmentId_Trig','attachment', 2, 'ad', rrrt.id ,rrrt.Parameters__c,'All');
        Event_Edition__c oedi = new Event_Edition__c(Name='Test Informa Event',Event_Code__c='TIE17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert oedi;        
        Blob b1 = Blob.valueOf('Data');
        
        Attachment oAtt = new Attachment();  
        oAtt.ParentId = oedi.id;  
        oAtt.Name = 'Attachment for Parent Manual';  
        oAtt.Body = b1;   
        insert oAtt;
        System.assertNotEquals('', oAtt.id,'attId should not be null');
       Test.stopTest();
   }
      
    @isTest static void evntAttdelTest(){
       Test.startTest();
       
        Trigger__c trig = new Trigger__c(Name = 'Assigned_getAttachmentId_Trig' , Trigger_Name_Unique__c='Assigned_getAttachmentId_Trig',Enabled__c=true,Object__c='attachment',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                         After_Insert__c=true , After_Delete__c = true);
        insert trig;
        Trigger_Recordtype__c rrrt = new Trigger_Recordtype__c(Recordtype_Id__c=trig.Id , Trigger__c=trig.Id,Enabled__c=true, Parameters__c='param=1;param=2');
        Insert rrrt; 
         
        TriggerInterface_Attachment obj=new TriggerInterface_Attachment();
       
        TriggerInterfaceHelper.runTrigger('Assigned_getAttachmentId_Trig','attachment', 2, 'ai', rrrt.id ,rrrt.Parameters__c,'All');
        
        Event_Edition__c oedi= new Event_Edition__c(Name='Test Informa Event',Event_Code__c='TIE17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert oedi;        
        Blob b1 = Blob.valueOf('Data');
        
        Attachment oAtt = new Attachment();  
        oAtt.ParentId = oedi.id;  
        oAtt.Name = 'Attachment for Parent Manual';  
        oAtt.Body = b1;   
        insert oAtt;
        TriggerInterfaceHelper.runTrigger('Assigned_getAttachmentId_Trig','attachment', 2, 'ad', rrrt.id ,rrrt.Parameters__c,'All');
        delete oAtt;
        System.assertNotEquals('', oAtt.id,'attId should not be null');
       Test.stopTest();
   }
}