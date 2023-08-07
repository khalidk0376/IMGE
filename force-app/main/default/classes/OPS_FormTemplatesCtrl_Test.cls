@isTest
public class OPS_FormTemplatesCtrl_Test {
    
    @isTest
    static void dataSetUp() 
    {    
        List<Form__c> formList = new List<Form__c>();
        for(Integer i=0;i<3;i++)
        {
            Form__c form = new Form__c(Name = 'Test'+i,Business_Unit__c = 'Asia',Doc_Type__c='Link',Uploaded_Attachment_Id__c='test1',Uploaded_Attachment_Name__c='Test PDF',Url__c='google.com');
            formList.add(form);
        }
        insert formList;
        
        List<Event_Edition__c> lstEE = new List<Event_Edition__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Edition__c ee = new Event_Edition__c(Name='Arab Health Exhibition and Congress 2019'+i,Event_Code__c='sbah19',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='50-50',X50_Cutoff_Date__c=System.Today(),Cutoff_Date_1__c=System.Today(),Cutoff_Date_2__c=System.Today(),Event_Currency__c='USD',Cutoff_Date_3__c=System.Today());
            lstEE.add(ee);  
        }
        insert lstEE;
        
        List<Manual__c> manualList = new List<Manual__c>();
        for(Integer i=0;i<3;i++)
        {
            Manual__c manual = new Manual__c(Name = 'Test'+i,Uploaded_Attachment_Id__c='test1',Uploaded_Attachment_Name__c='Test PDF',Event_Edition__c=lstEE[0].id);
            manualList.add(manual);
        }
        insert manualList;
        
        ContentVersion contentVersion_1 = new ContentVersion(
      		Title = 'Penguins',
      		PathOnClient = 'Penguins.jpg',
      		VersionData = Blob.valueOf('Test Content'),
      		IsMajorVersion = true
    	);
    	insert contentVersion_1;
        
        List<ContentVersion> contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        System.assertEquals(contentVersion_2.size(), 1, 'Test');
        
        test.startTest();
        
        {   
            
            OPS_FormTemplatesCtrl.updateAttachOnForm(formList[0].id,formList[0].Uploaded_Attachment_Id__c,formList[0].Uploaded_Attachment_Name__c);
           	OPS_FormTemplatesCtrl.updateAndDeleteAttOnForm(formList[0].id,formList[0].Uploaded_Attachment_Id__c,formList[0].Uploaded_Attachment_Name__c);
            OPS_FormTemplatesCtrl.updateAttachOnManual(manualList[0].id,manualList[0].Uploaded_Attachment_Id__c,manualList[0].Uploaded_Attachment_Name__c);
           	OPS_FormTemplatesCtrl.updateAndDeleteAttOnManual(manualList[0].id,manualList[0].Uploaded_Attachment_Id__c,manualList[0].Uploaded_Attachment_Name__c);
            
            ContentVersion conVer1 = OPS_FormTemplatesCtrl.getContentVersionId(contentVersion_2[0].ContentDocumentId);
            
        }
        
        test.stopTest();
    }

}