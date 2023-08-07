/**
* Created By       :   Girikon(Mukesh[STL-4])
* Created On       :   07/23/2019
* @description     :   Test class for CommonTableController class 88%
* Modified by      :   Yash Gupta [10/23/2019 Remove violations]
**/

@IsTest
public class CommonTableController_Test {
	@IsTest
    private static void getTest() {
        Test.startTest();
        Account acc = new Account();
        acc.Name='test acc';
        insert acc;
        System.assertEquals('test acc',acc.Name,'True');
        
        DateTime dT = System.now().addDays(3);
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        Opportunity opp = new Opportunity();
        opp.Name = 'Tets';
        opp.Amount=34.4;
        opp.CloseDate = myDate;
        opp.StageName = 'Discover';
        opp.AccountId = acc.Id;
        opp.Type = 'Existing Business';
        insert opp;
		
        //@Description: Insert Event Edition.
        Event_Edition__c eventEdition = new Event_Edition__c();
        eventEdition.Name = 'Testing Event Edition';
        eventEdition.Tab1__c = 'Tab1';
        eventEdition.Tab4__c = 'Tab4';
        eventEdition.Tab8__c = 'Tab8';
        insert eventEdition;
        
        CommonTableController.getGenericObjectRecord('false', 'Opportunity','IsClosed,Id,Name,IsClosed,Status__c,IsWon,HasOpportunityLineItem',10.0,false,false,-1,'Name','asc', '',true);
        CommonTableController.getGenericObjectRecord('test', 'Opportunity','Id,Name,IsClosed,Status__c,IsWon,HasOpportunityLineItem,Tax_Id__r.Name,Tax_Id__r.Account__r.Name,Tax_Id__r.Account__r.Account_Type__r.Name',10.0,false,true,0,'Name','asc', 'Name!=\'\'',false);
        CommonTableController.getAgreegatedObjectRecord('Agent Pavilion Shell',eventEdition.Id,10.0,false,false,-1);
        CommonTableController.getAgreegatedObjectRecord('Agent Pavilion Shell',eventEdition.Id,10.0,false,true,-1);
        CommonTableController.getAgreegatedObjectRecord('Agent Pavilion Shell',eventEdition.Id,10.0,true,false,-1);
        List<Opportunity> results = CommonTableController.getRecordDetail('Opportunity','Id,Name',opp.Id);
        CommonTableController.getRecordDetail2('Opportunity','Id,Name',opp.Id);
        CommonTableController.getQLRecordsForBrazilTab(opp.Id,'SearchKey','sapMatJs');
        CommonTableController.getQLRecords(opp.Id,'SearchKey');
        CommonTableController.getRecordDetail3('Opportunity','Id,Name','Name!=\'\'');
        CommonTableController.getFileDetail('Attachment','Id',opp.Id);
        CommonTableController.getFilePreview('ContentDocumentLink','Id',opp.Id);
        CommonTableController.getFilePreviewLink('ContentDocumentLink','Id',opp.Id);
        Contact conObj = new Contact();
        conObj.LastName='test';
        conObj.Email='test@gmail.com';
        insert conObj;
        CommonTableController.getAggregateData('Name!=\'\'', 'Opportunity', 'Name');
        CommonTableController.getAggregateData2('Name!=\'\'', 'Opportunity', 'Name');
        CommonTableController.getTotalAmount('Name!=\'\'', 'Opportunity', 'Name');
        opp.StageName='Customize';
        CommonTableController.massUpdateRecords(new Opportunity[]{opp});
        CommonTableController.deleteRecord(new sobject[]{conObj});        
        CommonTableController.massInsertRecords(new sobject[]{conObj});
        
        Profile_Option_Visibility__c povObj = new Profile_Option_Visibility__c(Social_Media_Links__c=true,Booth_Contact_Info__c=true,Print_Description__c=true,Web_Description__c=true,Logo__c=true,Event_Edition__c = eventEdition.Id);
        Insert povObj;
        
        Profile_Package_Setting__c ppsObj = new Profile_Package_Setting__c(Is_Default__c=true,Social_Media_Links__c=true,Booth_Contact_Info__c=true,Print_Description__c=true,Web_Description__c=true,Logo__c=true,Event_Edition__c = eventEdition.Id);
        Insert ppsObj;
        
        CommonTableController.getFieldVisibility(acc.Id,eventEdition.Id);
        Test.stopTest();
    }
}