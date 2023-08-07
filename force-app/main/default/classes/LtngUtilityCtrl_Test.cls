/**
* Created By       :   Girikon(Sunil)
* Created On       :   
* @description     :   Test class to provide code coverage.          
* Apex Class       :   LtngUtilityCtrl

* Modification log --
* Modified by      :  
**/

@isTest
public class LtngUtilityCtrl_Test {
    
    @isTest
    public static void callTest() {
        Test.startTest();
        Account acc=new Account();
        acc.Name='test account';
        insert acc;
        System.assertNotEquals(null, acc.Id,'test');
        
        opportunity opp= new opportunity();
        opp.AccountId=acc.id;
        opp.Name='test';
        opp.StageName='Prospecting';
        opp.CloseDate=system.today();
        insert opp;
        
        Contact con = new Contact();
        con.LastName='test';
        insert con;
        Blob b3 = Blob.valueOf('Test Data record');
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'Complete.pdf';//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion.Title ='Completed';//Name of the file
        cVersion.VersionData = b3;//File content
        insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId =  con.id;//Add Files parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        Form__c oForm = new Form__c(Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today());
        insert oForm;
        
        //create Event_Edition__c
        Event_Edition__c ee = new Event_Edition__c(Name='TestName',Event_Currency__c='USD',Event_Code__c='XYZ',Event_Edition_Code__c='abx');
        insert ee;
        
        //Create Event_Settings__c
        Event_Settings__c oEvntSttng = new Event_Settings__c(Name='Test',Event_Edition__c=ee.Id,Welcome_Stand_Contractor__c='WSC Test');
        insert oEvntSttng;
        
        Event_Edition_Form__c oEEReqForm = new Event_Edition_Form__c(Event_Edition__c = ee.id,Forms__c =oForm.id,Expocad_Booth_Class__c='', Expocad_Booth_Type__c='', Expocad_Product_Type__c='', Mandatory__c = true);
        insert oEEReqForm;
        
        string recordId = con.Id;
        list<contact> conList =  LtngUtilityCtrl.getRecord(recordId,'Contact','LastName');
        
        String evtSettingid = oEvntSttng.Id;
        String evtFormid = oEEReqForm.Id;
        
        LtngUtilityCtrl.getCurrentUserDtls();
        LtngUtilityCtrl.getCommunityURL();
        LtngUtilityCtrl.getEventEditionSettings(evtSettingid);
        LtngUtilityCtrl.getEventEditionForm(evtFormid);
        
        LtngUtilityCtrl.RecordDataTableWrapper getObjRecords = LtngUtilityCtrl.getRecords('Contact','LastName','Id' , recordId, 3, 2);
        
        LtngUtilityCtrl.RecordDataTableWrapper getsObjRecords = LtngUtilityCtrl.getSobjectRecords('Contact','LastName','LastName','test','Where Id != null','LastName','DESC',3,2);
        
        LtngUtilityCtrl.agentEventDetails(ee.Event_Code__c);
        
        
        Id saveFile = LtngUtilityCtrl.saveFile(recordId, 'Abc', 'xyz');
        Test.stopTest();
    }
    
}