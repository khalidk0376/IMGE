/**
* Created By:  Girikon(Suraj, Sunil[CCEN-584 Jan 14,2018]) )
* Modified By  :  Girikon(Garima[CCEN-779]), [Modified By : Aishwarya 12 Aug 2020 BK-3751]
* Created On:  11/01/2019
* @description : This test class covers the apex class "ExportAllReportsCtrl" following methods:

* Methods:  exportToExcel
* Apex Class: ExportAllReportsCtrl (90%) 
**/
@isTest
public class ExportAllReportsCtrl_Test {
    
    // to test getMatchedproductType method
    public static testmethod void testMatchedPrductType()
    {    
        Product2 prd1 = new Product2(Name = 'Linear Booth', Family = 'Booth', Number_of_Corners__c = 0);
        insert prd1;      
        System.assertEquals(prd1.Name, 'Linear Booth' , 'name should equals to Linear Booth');
          
        Pricebook2 customPB = new Pricebook2(Name = 'ICRE', isActive = true);
        insert customPB;
        System.assertEquals(customPB.Name, 'ICRE' , 'name should equals to ICRE');
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry stndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id, UnitPrice = 100, IsActive = true);
        insert stndrdPrice;
        System.assertEquals(pricebookId,  Test.getStandardPricebookId() , 'pricebookId must be equals');
        
        PricebookEntry iCREPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id, UnitPrice = 200, IsActive = true);
        insert iCREPrice;
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingState = '', MailingCountry = 'India', MobilePhone = '2121212145');
        insert oCon;
        System.assertEquals('ContTest1' , oCon.LastName , 'Test class failed');
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Payment_Schedule__c = '50-50', cutoff_date_1__c = date.today(), Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt' , Expocad_API_URL__c = 'https://expocad.api.com');
        insert oEvent;
        System.assertNotEquals(oEvent.Name, 'TOC' , 'name should not equals to TOC');
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Closed Won', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id , IsCreatedByReviewProcess__c = false, CurrencyIsoCode = 'USD' , Operations_Contact__C = oCon.Id);
        insert oOpportunity;
        System.assertEquals(oOpportunity.StageName, 'Closed Won' , 'Stage name should equals to Closed Won');
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Primary__c = true, CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id);
        insert oQuote;
        
        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True, SBQQ__Discount__c = 2.00, CurrencyIsoCode = 'USD');
        insert oQuoteLine ;
        
        ExpocadBooth__c oExpocadBooth = new ExpocadBooth__c(Status__c = 'Added To Quote/On Hold', Released__c = false, Booth_Number__c = 'TESTBN2', Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Booth_Product_Type_EE__c = 'Space Only', Area__c = '18 m²');
        insert oExpocadBooth;
        System.assertEquals(oExpocadBooth.Status__c, 'Added To Quote/On Hold' , 'Status should equals to Added To Quote/On Hold');
        
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMap = new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppExpoBoothMap.Status__c = 'Active';
        oppExpoBoothMap.Relation__c = 'Exhibitor';
        oppExpoBoothMap.Is_Parent_Mapping__c = True;
        oppExpoBoothMap.Opportunity__c=oOpportunity.id;
        oppExpoBoothMap.Expocad_Booth__c = oExpocadBooth.Id;        
        insert oppExpoBoothMap;
        
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
        System.assertEquals(u.ProfileId , pro.Id , 'Profile Id should equals');
        
        BoothContractorMapping__c bcm = new BoothContractorMapping__c();
        bcm.Opp_Booth_Mapping__c = oppExpoBoothMap.Id;
        bcm.Contact__c = oCon.Id;
        bcm.Event_Edition__c = oEvent.Id;
        bcm.Booth_Design_Status__c = 'No Design';
        insert bcm;
        
        //create stand design
        Stand_Design__c sdes = new Stand_Design__c(Opp_Booth_Mapping__c=oppExpoBoothMap.Id,Booth_Design_Status__c='No Design');
        insert sdes;
        
        //create stand detail
        Stand_Detail__c sdet = new Stand_Detail__c(Opp_Booth_Mapping__c=oppExpoBoothMap.Id,IsDoubleDecker__c=false,IsRigging__c=false,Is_Heavy_Machinery__c=false,Amount__c='750',IsReceived__c=false);
        insert sdet;
        
        Profile_Package_Setting__c pps = new Profile_Package_Setting__c(Name = 'test',Priority__c = '1',Event_Edition__c = oEvent.Id);
        insert pps;
        
        oOpportunity.Status__c = 'Closed Won';
        update oOpportunity;
        
        oExpocadBooth.Status__c = 'Rented';
        update oExpocadBooth;
               
        apexpages.currentpage().getparameters().put('event' , oEvent.id);
        apexpages.currentpage().getparameters().put('compName' , 'MatchProductType');
        ExportAllReportsCtrl obj = new ExportAllReportsCtrl();        
        obj.exportToExcel();       
    }
    
    // to test getLastLogin method   
    public static testmethod void testLastLogin()
    {    
        //Create Account
        Account acc = new Account(Name='TestAcc');
        insert acc;
        System.assertNotEquals(null, acc,true);
        
        //create contact
        Contact oCon = new Contact(AccountId = acc.Id, FirstName = 'TestConFirst', LastName = 'TestConLast', Email='abc@test.com', MobilePhone = '2121212145');
        insert oCon;
        System.assertEquals('TestConLast' , oCon.LastName , 'Test class failed');
        //create Event_Edition__c
        Event_Edition__c ee = new Event_Edition__c(Name='TestName',Event_Currency__c='USD',Event_Code__c='XYZ');
        insert ee;
        
        Opportunity oOpportunity = new Opportunity( Name = 'Expocad Opportunity', CloseDate = Date.today().addDays(7), StageName = 'Needs Assessment', EventEdition__c = ee.Id, AccountId = acc.Id, Billing_Contact__c = oCon.Id, Payment_Status__c='Not Paid' );
        oOpportunity.Exhibitor_Paid_By__c = 'Exhibitor Paid by Agent';
        oOpportunity.StageName = 'Closed Won';
        insert oOpportunity;
        
        //create ExpocadBooth__c
        ExpocadBooth__c eB = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.', status__c = 'Rented' , Opportunity__c = oOpportunity.Id);
        insert eB;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBooth = new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppExpoBooth.Opportunity__c = oOpportunity.Id;
        oppExpoBooth.Account__c = acc.Id;
        oppExpoBooth.Expocad_Booth__c = eB.Id;
        oppExpoBooth.Status__c = 'Active';
        oppExpoBooth.Related_Opportunity__c = null;
        insert oppExpoBooth;
        System.assertEquals(oppExpoBooth.Status__c, 'Active', 'Expobooth status must be active');
        
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
        System.assertEquals(u.ProfileId , pro.Id , 'Profile Id should equals');
        
        //Create User_Type__c
        User_Type__c oUT = new User_Type__c(Name='Stand Contractor');
        insert oUT;
        
        //Create ContactEventEditionMapping__c
        ContactEventEditionMapping__c ccem = new ContactEventEditionMapping__c(SFContactID__c =oCon.Id,SFEventEditionId__c=ee.Id,Email_Sent__c = DateTime.now());
        insert ccem;
        
        apexpages.currentpage().getparameters().put('event' , ee.id);
        apexpages.currentpage().getparameters().put('compName' , 'LastLogin');
        ExportAllReportsCtrl obj = new ExportAllReportsCtrl();               
        obj.exportToExcel();
    }
    
    // to test show category method
    public static testmethod void testshowCategory()
    {    
        Product2 prd1 = new Product2(Name = 'Linear Booth', Family = 'Booth', Number_of_Corners__c = 0);
        insert prd1;
        
        Pricebook2 customPB = new Pricebook2(Name = 'ICRE', isActive = true);
        insert customPB;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry stndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id, UnitPrice = 100, IsActive = true);
        insert stndrdPrice;
        
        PricebookEntry iCREPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id, UnitPrice = 200, IsActive = true);
        insert iCREPrice;
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingState = '', MailingCountry = 'India', MobilePhone = '2121212145');
        insert oCon;
        System.assertEquals('ContTest1' , oCon.LastName , 'Test class failed');
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Payment_Schedule__c = '50-50', cutoff_date_1__c = date.today(), Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt' , Expocad_API_URL__c = 'https://expocad.api.com');
        insert oEvent;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Closed Won', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id , IsCreatedByReviewProcess__c = false, CurrencyIsoCode = 'USD' , Operations_Contact__C = oCon.Id);
        insert oOpportunity;
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Primary__c = true, CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id);
        insert oQuote;
        
        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True, SBQQ__Discount__c = 2.00, CurrencyIsoCode = 'USD');
        insert oQuoteLine ;
        
        ExpocadBooth__c oExpocadBooth = new ExpocadBooth__c(Status__c = 'Added To Quote/On Hold', Released__c = false, Booth_Number__c = 'TESTBN2', Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Booth_Product_Type_EE__c = 'Space Only', Area__c = '18 m²');
        insert oExpocadBooth;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMap = new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppExpoBoothMap.Status__c = 'Active';
        oppExpoBoothMap.Relation__c = 'Exhibitor';
        oppExpoBoothMap.Is_Parent_Mapping__c = True;
        oppExpoBoothMap.Expocad_Booth__c = oExpocadBooth.Id;        
        insert oppExpoBoothMap;
        System.assertEquals(oppExpoBoothMap.Status__c, 'Active', 'Expobooth status must be active');
        
        oOpportunity.Status__c = 'Closed Won';
        update oOpportunity;
        
        oExpocadBooth.Status__c = 'Rented';
        update oExpocadBooth;
        
        apexpages.currentpage().getparameters().put('event' , oEvent.id);
        apexpages.currentpage().getparameters().put('compName' , 'ShowCategory');
        ExportAllReportsCtrl obj = new ExportAllReportsCtrl();               
        obj.exportToExcel();
        
        ExportAllReportsCtrl.wrapperClass objWrapperClass = new  ExportAllReportsCtrl.wrapperClass();
        objWrapperClass.companyName = 'Testing Value';
        objWrapperClass.boothconName = 'Testing Value';
        objWrapperClass.boothconPhone = 'Testing Value';
        objWrapperClass.boothconEmail = 'Testing Value';
        objWrapperClass.boothconWebsite = 'Testing Value';
        objWrapperClass.standNumber = 'Testing Value';
        objWrapperClass.displayName = 'Testing Value';
        objWrapperClass.country = 'Testing Value';
        objWrapperClass.contractorMobilePhone = 'Testing Value';
        objWrapperClass.contractorEmail = 'Testing Value';
        objWrapperClass.contractorCompany = 'Testing Value';
        objWrapperClass.sContactsName = 'Testing Value';
        objWrapperClass.contractorCountry = 'Testing Value';
        objWrapperClass.boolRigging = true;
        objWrapperClass.boolDblDckr = true;
        objWrapperClass.boolHevyMachin = true;
        objWrapperClass.dBoothDsnSbmttdOn = 'Testing Value';
        objWrapperClass.sBoothStatus = 'Testing Value';
        objWrapperClass.designationStatus = 'Testing Value';
        objWrapperClass.contrUsername = 'Testing Value';
        objWrapperClass.exhUsername = 'Testing Value';
        objWrapperClass.perfBond = true;
        objWrapperClass.standHeight = 1.2;
        objWrapperClass.riggingHeight = 1.2;
        objWrapperClass.isVehicles = true;
    } 
    
    
}