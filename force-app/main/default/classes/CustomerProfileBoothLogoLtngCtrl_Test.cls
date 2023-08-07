/**
 * Created/Modified By: Girikon(Shashank)
 * Created On:          09/04/2018, [Aishwarya BK-15072 9 Apr 2021]
 * @description  : This test class covers the apex class : CustomerProfileBoothLogoLtngCtrl 
 * Methods:             unitTest
 * Apex Class:          CustomerProfileBoothLogoLtngCtrl 
 **/
 @isTest
public class CustomerProfileBoothLogoLtngCtrl_Test {

    static testMethod void unitTest() 
    {
        Account a = new Account();
        a.Name = 'TestAcc';
        insert a;    
            
        ExpocadBooth__c oEB = new ExpocadBooth__c(Booth_Number__c='1234',Booth_Logo_Id__c='testId111',Status__c='Rented');
        insert oEB;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = a.Id, status__c = 'Active', Expocad_Booth__c = oEB.Id);
        insert oppExpoBoothMapping;
        System.assertNotEquals(oppExpoBoothMapping ,null,'Opportunity_ExpoCAD_Booth_Mapping__c should have some value');
        
        AllowedImageTypes__c oAllImg = new AllowedImageTypes__c(name='.img');
        insert oAllImg;
 
       // create Pricebook2
        Pricebook2 customPB = new Pricebook2(Name='ICRE', isActive=true);
        insert customPB;
        System.assertNotEquals(customPB.id,null, 'Pricebook2 cannot be null');
        
        Test.startTest();
        Event_Edition__c eventEditn = new Event_Edition__c(Name='World of Concrete 2017',Event_Price_Book__c=customPB.Id,Price_Rule_object_Name__c='TOC__c',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='50-50',X50_Cutoff_Date__c=System.Today(),Cutoff_Date_1__c=System.Today(),Cutoff_Date_2__c=System.Today(),Cutoff_Date_3__c=System.Today());
        insert eventEditn;
        string evntCode=eventEditn.Event_Code__c;
        // assert last argument
        Id uploadedfile = CustomerProfileBoothLogoLtngCtrl.saveChunk(oEB.Id,'test.pdf','dsdsdsdsd','text/pdf','');


        Id savefileId = CustomerProfileBoothLogoLtngCtrl.saveTheFile(oppExpoBoothMapping.Id,'test.pdf','dsdsdsdsd','text/pdf');
        String url =  CustomerProfileBoothLogoLtngCtrl.getBaseUrl();        


        ContentVersion cv = new ContentVersion(
        Title = 'Test',
        PathOnClient = 'Test.jpg',
        VersionData = blob.valueof('Test Content Data'),
        IsMajorVersion = true
        );
        insert cv;
        System.assertNotEquals(cv,null,'content version should have some value');
            
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
         ContentDocumentLink contentlink = new ContentDocumentLink();
         contentlink.LinkedEntityId =oppExpoBoothMapping.id;  
         contentlink.ShareType = 'V';               
         contentlink.ContentDocumentId =documents[0].Id;
         contentlink.Visibility = 'AllUsers'; 
         insert contentlink;
             
        ContentDistribution distribution = new ContentDistribution();
        distribution.Name = 'test name ' +  Date.today();
        distribution.ContentVersionId = cv.Id;
        distribution.PreferencesNotifyOnVisit = false;
        distribution.PreferencesNotifyRndtnComplete = false;
        insert distribution;
        ContentDocument condc = CustomerProfileBoothLogoLtngCtrl.fetchExistingAttachment(oppExpoBoothMapping.id);
        Test.stopTest();




    }
}