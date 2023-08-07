@IsTest
public class LightningTableController_Test {
	@IsTest
    private static void getTest() {
        Test.startTest();
        Account acc = new Account();
        acc.Name='test acc';
        insert acc;
        
        Contact conObj = new Contact();
        conObj.LastName='test';
        conObj.Email='test@gmail.com';
        insert conObj;
        
        DateTime dT = System.now().addDays(3);
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        Opportunity opp = new Opportunity();
        opp.Name = 'Tets';
        opp.CloseDate = myDate;
        opp.StageName = 'Discover';
        opp.AccountId = acc.Id;
        insert opp;
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Tets';
        opp1.CloseDate = myDate;
        opp1.StageName = 'Discover';
        opp1.AccountId = acc.Id;
        opp1.Parent_Opportunity__c = opp.Id;
        insert opp1;
      
        
        LightningTableController.getGenericObjectRecord('Opportunity','Id,Name',10.0,false,false,0,'Name','tet',false,'AND');
        LightningTableController.getGenericObjectRecord('Opportunity','Id,Name',10.0,false,false,0,'Name,StageName','tet,Discover',false,'AND');
        List<Opportunity> results = LightningTableController.getRecordDetail('Opportunity','Id,Name',opp.Id);
     //   List<Opportunity> results2 = LightningTableController.getFileDetail('Attachment', attach.Id, attach.parentId);
        
        LightningTableController.deleteRecord(conObj);
        System.assertEquals('Tets',results[0].Name, 'There must be at least one Opportunity');
        LightningTableController.getFileDetail('Attachment','Id','');
        LightningTableController.getFilePreview ('ContentDocumentLink', 'Id' , '');
        Test.stopTest();
    }
}