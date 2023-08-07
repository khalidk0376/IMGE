/**
* Created/Modified By: Girikon(Himanshu Jasuja)
* Created On:          27/11/2019      
* @description : This test class covers the apex class : ExportExhibitorProfile(88%)
* Apex Class:          ExportExhibitorProfile 
**/ 

@isTest
public class ExportExhibitorProfile_test {

 // to test ExportExhibitorProfile method
    public static testmethod void testExportExhibitorProfile()
    {    
        Product2 prd1 = new Product2(Name = 'Linear Booth', Family = 'Booth', Number_of_Corners__c = 0);
        insert prd1;
        System.AssertNotEquals(prd1, null, 'false');
        
        Pricebook2 customPB = new Pricebook2(Name = 'ICRE', isActive = true);
        insert customPB;
        System.AssertNotEquals(customPB, null, 'false');
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry stndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id, UnitPrice = 100, IsActive = true);
        insert stndrdPrice;
        System.AssertNotEquals(stndrdPrice, null, 'false');
        
        PricebookEntry iCREPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id, UnitPrice = 200, IsActive = true);
        insert iCREPrice;
        System.AssertNotEquals(prd1, null, 'false');
        
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        System.AssertNotEquals(oAccount, null, 'false');
        
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingState = '', MailingCountry = 'India', MobilePhone = '2121212145');
        insert oCon;
        System.AssertNotEquals(oCon, null, 'false');
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Payment_Schedule__c = '50-50', cutoff_date_1__c = date.today(), Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt' , Expocad_API_URL__c = 'https://expocad.api.com');
        insert oEvent;
        System.AssertNotEquals(oEvent, null, 'false');
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Need Assessment', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id , IsCreatedByReviewProcess__c = false, CurrencyIsoCode = 'USD' , Operations_Contact__C = oCon.Id);
        insert oOpportunity;
               
        System.AssertNotEquals(oOpportunity, null, 'false');
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Primary__c = true, CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id);
        insert oQuote;
        System.AssertNotEquals(oQuote, null, 'false');
        
        
        ExpocadBooth__c oExpocadBooth = new ExpocadBooth__c(Status__c = 'Rented', Released__c = false, Booth_Number__c = 'TESTBN2', Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Booth_Product_Type_EE__c = 'Space Only', Area__c = '18 m²');
        insert oExpocadBooth;
        System.AssertNotEquals(oExpocadBooth, null, 'false');
        
        oOpportunity.StageName='Closed Won';
        update oOpportunity;
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
        cDocLink.LinkedEntityId =  oOpportunity.id;//Add Files parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMap = new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppExpoBoothMap.Status__c = 'Active';
        oppExpoBoothMap.Relation__c = 'Exhibitor';
        oppExpoBoothMap.Is_Parent_Mapping__c = True;
        oppExpoBoothMap.Expocad_Booth__c = oExpocadBooth.Id;
        oppExpoBoothMap.Account__c = oAccount.Id;
        oppExpoBoothMap.Primary_Contact__c = oCon.Id;
        oppExpoBoothMap.Opportunity__c = oOpportunity.id;
        oppExpoBoothMap.Booth_Logo_Id__c = conDocument;
        insert oppExpoBoothMap;
        System.AssertNotEquals(oppExpoBoothMap, null, 'false');
        
         //get  Profile
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'];
        //Create  User
        User u = new User();
        
        u.FirstName = 'Sunil';
        u.LastName = 'Bajoliya';
        u.Email = 'test@wexeurope.com';
        u.Username = 'astest@wexeurope.com';
        u.Alias = 'astest';
        u.ProfileId = pro.Id;
        u.ContactId = oCon.id;
        u.TimeZoneSidKey    = 'America/Denver';
        u.LocaleSidKey      = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        system.debug('u contains ' + u);
        insert u;
        System.AssertNotEquals(u, null, 'false');
        
        User_Type__c uType = new User_Type__c(Name='test');
        insert uType;
        System.AssertNotEquals(uType, null, 'false');
        
        ContactEventEditionMapping__c objnewmap= new ContactEventEditionMapping__c(SFContactID__c=oCon.Id,SFEventEditionID__c=oEvent.Id,User_Type__c=uType.Id);
        insert objnewmap;
        System.AssertNotEquals(objnewmap, null, 'false');

        Profile_Package_Setting__c pps = new Profile_Package_Setting__c(Name = 'test',Priority__c = '1',Event_Edition__c = oEvent.Id);
        insert pps;
        System.AssertNotEquals(pps, null, 'false');
        
        User_Package__c up = new User_Package__c();
        up.Name = 'test';
        up.Account__c = oAccount.Id; 
        up.Event_Edition__c = oEvent.Id;
        up.Profile_Package_Setting__c = pps.Id ;
        insert up;
        System.AssertNotEquals(up, null, 'false');
        
        Levels_Master__c lm = new Levels_Master__c();
        lm.Name = 'test';
        lm.LevelValue__c  = 'test';
        lm.CurrencyIsoCode = 'USD';
        insert lm;
        System.AssertNotEquals(lm, null, 'false');
        
        Event_Edition_Product_Category_Mapping__c eepcm = new Event_Edition_Product_Category_Mapping__c();
        eepcm.CurrencyIsoCode = 'USD';
        eepcm.Event_Edition__c = oEvent.Id;
        eepcm.Levels_Master__c= lm.Id;
        insert eepcm;
        System.AssertNotEquals(eepcm, null, 'false');
        
        Customer_Product_Category__c cpc = new Customer_Product_Category__c();
        cpc.Event_Edition_Product_Category_Mapping__c = eepcm.Id;
        cpc.CurrencyIsoCode = 'USD';
        cpc.Account__c = oAccount.Id;
        cpc.Contact__c = oCon.Id;
        cpc.ExpocadBooth__c= oExpocadBooth.Id; 
        cpc.Opp_Booth_Mapping__c = oppExpoBoothMap.Id;
        cpc.Event_Edition__c = oEvent.id;
        insert cpc;
        System.AssertNotEquals(cpc, null, 'false');
 
        BoothContactInfo__c bci = new BoothContactInfo__c();
        bci.Name = 'test';
        bci.First_Name__c = 'test';
        bci.Last_Name__c = 'test';               
        bci.CurrencyIsoCode = 'USD';
        bci.Contact__c = oCon.Id;
        bci.ExpocadBooth__c= oExpocadBooth.Id;
        bci.Event_Edition__c= oEvent.Id;
        bci.Opportunity_Booth_Mapping__c= oppExpoBoothMap.Id;
        insert bci;
        System.AssertNotEquals(bci, null, 'false');
       
        GoMed2Med__c gmm = new GoMed2Med__c();
        gmm.Account__c = oAccount.Id;
        gmm.Event_Edition__c = oEvent.Id;
        gmm.Are_you_a_distributor__c = 'test';
        gmm.Are_you_a_manufacturer_supplying_to_End__c = 'test';
        gmm.Are_you_a_manufacturer_supplying_to_Dist__c = 'test';
        insert gmm;
        System.AssertNotEquals(gmm, null, 'false');
        
       
        Test.setCurrentPage(Page.ExhibitorProfileVF);
            
        test.startTest();  
                   
        apexpages.currentpage().getparameters().put('eventId' , oEvent.id);
        apexpages.currentpage().getparameters().put('reportName' , 'ExhibitorProfile');
        ExportExhibitorProfile obj = new ExportExhibitorProfile();        
        obj.exportToExcel();       
        ExportExhibitorProfile.wrapperClass wrap = new ExportExhibitorProfile.wrapperClass();
        wrap.firstname = 'testing value ';
        wrap.lastname= 'testing value ';
        wrap.country = 'testing value ';
        wrap.address = 'testing value ';
        wrap.city = 'testing value ';
        wrap.state= 'testing value ';
        wrap.pobox= 'testing value ';
        wrap.telephone= 'testing value ';
        wrap.fax= 'testing value ';
        wrap.email= 'testing value ';
        wrap.Website= 'testing value ';
        wrap.productcategories= 'testing value ';    
        test.stopTest();
    }
    
}