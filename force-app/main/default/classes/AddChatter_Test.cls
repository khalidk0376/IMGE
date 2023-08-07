/**
* File:        AddChatter_Test.cls
* Project:     GAP
* Created Date: 31/8/2017 3:32 PM
* Created By:  
* Modified By:  Rajesh Kumar
* covered Class: 
* Coverage: 
*
* *************************************************************************
* @description This class is using in "WorkOrderTriggerMerge" Trigger.
* *************************************************************************
* History:Ticket :GGCkB-76 
* * Last Modified :BK-10856 Rajesh Kumar Yadav
*/



@isTest
public class AddChatter_Test{
    static testMethod void addchatterTest(){
        
        // Create Trigger test record 
        Trigger__c trig = new Trigger__c(Name = 'AddChatter_Trig' , Trigger_Name_Unique__c='AddChatter_Trig',Enabled__c=true,Object__c='WorkOrder',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=1,
                                         After_Insert__c=true , After_Update__c = true);
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        //Call event edition trigger interface
        TriggerInterface_WorkOrder obj = new TriggerInterface_WorkOrder();
        
        //Call trigger app handler for insert event
        TriggerInterfaceHelper.runTrigger('AddChatter_Trig','WorkOrder',1, 'ai', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('AddChatter_Trig');
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'GHNN');
        oEventseries.Status__c = 'Active';
        insert oEventseries;
        
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name='World of Concrete 2017';
        ee.Part_of_Series__c = oEventseries.Id;
        ee.Tab1__c='testt';
        ee.Tab7__c='ttttt';
        ee.Event_Edition_Status__c = 'Confirmed';    
        insert ee;
        System.AssertEquals(ee.Event_Edition_Status__c, 'Confirmed', 'Event Edition must be confirmed and Event Series must be Active');
        Account acc = new Account();
        acc.Name = 'test';
        acc.CurrencyIsoCode = 'USD';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.OwnerId = userInfo.getUserId();
        opp.CloseDate = system.Today();
        opp.StageName = 'Need Assessment';
        opp.CurrencyIsoCode = 'USD';
        system.debug('opp>>>> '+opp);
        insert opp;
        
        Agreement__c agg=new Agreement__c();
        agg.Name='Test';
        agg.Opportunity__c=opp.Id;
        insert agg;
        
        /*Attachment oAttachment = new Attachment();
oAttachment.parentid = agg.id;
oAttachment.Name = 'Test';
oAttachment.Body = Blob.valueOf('testing body');
insert oAttachment;*/
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=agg.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        
        
        
        Work_Order_Template__c wot = new Work_Order_Template__c();
        wot.Name = 'test';
        wot.CurrencyIsoCode = 'USD';
        //wot.Operations_Team__c = objTeam.id;
        insert wot;
        //System.assertEquals('test' , wot.Name); 
        WorkOrder wo = new WorkOrder();
        wo.Work_Order_Name__c='Test';
        wo.Opportunity__c = opp.Id;
        wo.AccountId = acc.Id;
        wo.Work_Order_Template__c = wot.Id;
        wo.Event_SeriesL__c = oEventseries.Id;
        wo.Event_Edition__c =ee.Id;
        wo.OwnerID = UserInfo.getUserId();
        insert wo;
        wo.Work_Order_Name__c='Test2';
        //wo.OwnerID = '0051F000000p8lI';
        update wo;
        TriggerInterfaceHelper.runTrigger('AddChatter_Trig','WorkOrder',1, 'au', null,null,'All');
        delete wo;
        opp.StageName='Close Won';
        update opp;
        TriggerInterfaceHelper.runTrigger('AddChatter_Trig','WorkOrder',1, 'bd', null,null,'All');
    }
}