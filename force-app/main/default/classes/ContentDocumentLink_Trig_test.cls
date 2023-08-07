@isTest
public class ContentDocumentLink_Trig_test{
    
    static testMethod void testMethod_01(){
        Trigger__c trig = new Trigger__c(Name = 'ContentDocumentLink_Trig' , Trigger_Name_Unique__c='ContentDocumentLink_Trig',Enabled__c=true,Object__c='ContentDocumentLink',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=1,
                                         Before_Insert__c = true);
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        
        TriggerInterface_ContentDocumentLink TriggerInterfaceObj = new TriggerInterface_ContentDocumentLink();
        
        TriggerInterfaceHelper.runTrigger('ContentDocumentLink_Trig','ContentDocumentLink',1, 'ai', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('ContentDocumentLink_Trig');
        
        Event_Edition__c oEventEdition = new Event_Edition__c(name = 'test',Event_Code__c='tw17', Tab1__c='test',Tab7__c='testtt',
        Payment_Schedule__c= '50-50',Cutoff_Date_1__c=date.today(), Approval_Service_Now_ID__c = 'test');
        insert oEventEdition;
        
        Product2 prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC',Event_Edition__c = oEventEdition.Id);
        insert prd1;
        System.assertEquals('Linear Booth', prd1.Name, 'Here value is not same');
        string before = 'Testing base 64 encode';            
        Blob beforeblob = Blob.valueOf(before);
        //Insert contentdocument data
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;          
        insert cv;         
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        
        ContentDocumentLink newFileShare = new ContentDocumentLink();
        newFileShare.contentdocumentid = testcontent.contentdocumentid;
        newFileShare.LinkedEntityId = prd1.id;
        newFileShare.ShareType= 'V';
        insert newFileShare;
        
    }
}