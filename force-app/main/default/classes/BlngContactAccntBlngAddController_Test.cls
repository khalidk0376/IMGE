/**
 * File:        BlngContactAccntBlngAddController_Test.cls
 * Project:     GAP
 * Date:        17/10/2017
 * Created By:  Abdul Kadir
 * *************************************************************************
 * Description: test class for BlngContactAccntBlngAddController.cls.
 * Code Coverage : 88%
 * *************************************************************************
 * History:
 */
@isTest
public class BlngContactAccntBlngAddController_Test{
    
    private static String RESPONSE_STRING = '{'+
            '  \"Header\": {'+
            '    \"Systems\": {'+
            '      \"CallingApplication\": \"SFDC\",'+
            '      \"MessageDate\": \"2017-04-13\",'+
            '      \"MessageStatus\": \"OK\",'+
            '      \"MessageStatusText\": \"\"'+
            '    }'+
            '  },'+
            '  \"CustomerInterface\": {'+
            '    \"Item\": {'+
            '      \"PartnerRole\": \"SP\",'+
            '      \"CustomerNumber\": \"\",'+
            '      \"ExternalReference\": \"SFDC123456\",'+
            '      \"SalesOrg\": \"IN02\",'+
            '      \"BusinessPartnerType\": \"2\",'+
            '      \"Division\": \"IO\",'+
            '      \"DistributionChannel\": \"IN\",'+
            '      \"Title\": \"\",'+
            '      \"CompanyName1\": \"Informa\",'+
            '      \"CompanyName2\": \"\",'+
            '      \"CompanyName3\": \"\",'+
            '      \"LastName\": \"Informa\",'+
            '      \"FirstName\": \"MuleSoft\",'+
            '      \"FullName\": \"MuleSoft Informa\",'+
            '      \"Department\": \"Agile solutions team\",'+
            '      \"City\": \"Las Vegas\",'+
            '      \"PostalCode\": \"89131\",'+
            '      \"AddressLine1\": \"1Z, Dane Street\",'+
            '      \"AddressLine2\": \"\",'+
            '      \"Country\": \"United States\",'+
            '      \"State\": \"Nevada\",'+
            '      \"PhoneNumber\": \"+44 1279 123456\",'+
            '      \"FaxNumber\": \"+44 1279 234567\",'+
            '      \"EmailAddress\": \"mulesoft@informa.com\"'+
            '    }'+
            '  }'+
            '}';
            
            private static String RESPONSE_STRING2 = '{'+
            '  \"Header\": {'+
            '    \"Systems\": {'+
            '      \"CallingApplication\": \"SFDC\",'+
            '      \"MessageDate\": \"2017-04-13\",'+
            '      \"MessageStatus\": \"ERROR\",'+
            '      \"MessageStatusText\": \"\"'+
            '    }'+
            '  },'+
            '  \"CustomerInterface\": {'+
            '    \"Item\": {'+
            '      \"PartnerRole\": \"SP\",'+
            '      \"CustomerNumber\": \"\",'+
            '      \"ExternalReference\": \"SFDC123456\",'+
            '      \"SalesOrg\": \"IN02\",'+
            '      \"BusinessPartnerType\": \"2\",'+
            '      \"Division\": \"IO\",'+
            '      \"DistributionChannel\": \"IN\",'+
            '      \"Title\": \"\",'+
            '      \"CompanyName1\": \"Informa\",'+
            '      \"CompanyName2\": \"\",'+
            '      \"CompanyName3\": \"\",'+
            '      \"LastName\": \"Informa\",'+
            '      \"FirstName\": \"MuleSoft\",'+
            '      \"FullName\": \"MuleSoft Informa\",'+
            '      \"Department\": \"Agile solutions team\",'+
            '      \"City\": \"Las Vegas\",'+
            '      \"PostalCode\": \"89131\",'+
            '      \"AddressLine1\": \"1Z, Dane Street\",'+
            '      \"AddressLine2\": \"\",'+
            '      \"Country\": \"United States\",'+
            '      \"State\": \"Nevada\",'+
            '      \"PhoneNumber\": \"+44 1279 123456\",'+
            '      \"FaxNumber\": \"+44 1279 234567\",'+
            '      \"EmailAddress\": \"mulesoft@informa.com\"'+
            '    }'+
            '  }'+
            '}';
            
      @testSetup
    public static void setupData() {
        TestUtilities.createCSIntegrationSettings();
    }
    
    /*static testmethod void testBlngContactAccntBlngAddController(){
        Account acc = new Account();
        acc.name='TestAccount';
        acc.BillingStreet='456 Zepplin Avenue';
        acc.BillingCity='Las Vegas';
        acc.BillingState='Delhi';
        acc.BillingPostalCode='110025';
        acc.BillingCountry='India';
        acc.Phone='1234567890';
        acc.Fax='1234567890';
        insert acc;
        
        Contact con = new Contact();
        con.Email='test.test@gmail.com';
        con.Phone='1234567890';
        con.Title='Mr.';
        con.FirstName='TestFN';
        con.LastName='testLN';
        con.AccountId=acc.Id;
        con.MailingStreet='TestStreet';
        con.MailingCity='Las Vegas';
        con.MailingPostalCode='89131';
        con.MailingState='Delhi';
        con.MailingCountry='India';
        con.Fax='1234567890';
        insert con;
        system.assertEquals('testLN', con.LastName) ;
        system.debug('--contact in test class---'+con);
         Pricebook2 pb=new Pricebook2(Name='TestPricebook');
        insert pb;
        Event_Edition__c ee=new Event_Edition__c();
        ee.Name='TestEvent';
        ee.Tab1__c='tab1';
        ee.Tab4__c='tab4';
        ee.Tab7__c='tab7';
        ee.Tab8__c='Tab8__c';
        ee.Event_Price_Book__c=pb.Id;
        ee.Event_Currency__c='USD';
        ee.Event_Code__c='woc17';
        insert ee;
        system.debug('--ee---'+ee );
                
        Opportunity oppty=new Opportunity(Name='testOpp',EventEdition__c=ee.Id);
        oppty.AccountId=acc.Id;
        oppty.StageName='Discover';
        oppty.CloseDate=date.today();
        insert oppty;
      
        
        SBQQ__Quote__c qtObj=new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c=acc.Id;
        qtObj.SBQQ__Status__c='Draft';
        qtObj.SBQQ__Type__c='Quote';
        qtObj.SBQQ__StartDate__c=date.today();
        qtObj.Alternate_Currency2__c='EUR';
        qtObj.SBQQ__Opportunity2__c=oppty.Id;
        qtObj.Billing_Contact__c = con.Id;
        insert qtObj;
        
        SBQQ__Quote__c qtObj1=new SBQQ__Quote__c();
        qtObj1.SBQQ__Account__c=acc.Id;
        qtObj1.SBQQ__Status__c='Draft';
        qtObj1.SBQQ__Type__c='Quote';
        qtObj1.SBQQ__StartDate__c=date.today();
        qtObj1.Alternate_Currency2__c='EUR';
        qtObj1.SBQQ__Opportunity2__c=oppty.Id;
        insert qtObj1;
         
        Event_Edition__c oEventEdition = new Event_Edition__c();
        oEventEdition.Price_Rule_object_Name__c = 'ICRE__c';
        oEventEdition.Thank_You_Description__c = '@RefNo';
        oEventEdition.Event_Currency__c = 'AED';
        oEventEdition.name = 'World of Concrete';
        oEventEdition.Event_Code__c='woc16';
        oEventEdition.currencyIsoCode = 'USD';
        oEventEdition.Payment_Schedule__c= '50-50';
        oEventEdition.Cutoff_Date_1__c=date.today();
        oEventEdition.Approval_Service_Now_ID__c = 'test';
        oEventEdition.PreferredArea__c = 'PreferredArea';
        oEventEdition.Tab1__c='esttt';
        oEventEdition.Tab2__c='test';
        oEventEdition.Tab3__c='test';
        oEventEdition.Tab4__c='test';
        oEventEdition.Tab5__c='test';
        oEventEdition.Tab6__c='test';
        oEventEdition.Tab7__c='testtt';
        oEventEdition.Tab8__c='testtt';
        oEventEdition.Answer_s__c = 'TestArea';
        oEventEdition.Is_OBC_Mandatory_Media_Product__c = true;
        insert oEventEdition;
        
        Online_Booth_Capture__c objOBC = new Online_Booth_Capture__c();
        objOBC.Total_In_Cart__c = 11.22;
        objOBC.Event_Edition_Name__c = oEventEdition.id;
        objOBC.Contract_Completed__c = FALSE;
        objOBC.Single_Current_Step__c = ',Step 2';
        insert objOBC;
        
        RecordType rt = [select id, Name, DeveloperName from RecordType where SobjectType='Online_Booth_Contact_Info__c' and DeveloperName ='Invoice_Contact' Limit 1];
        
        Online_Booth_Contact_Info__c objOCI = new Online_Booth_Contact_Info__c();
        objOCI.Name = 'test Name';
        objOCI.recordtypeid= rt.id;
        objOCI.Online_Booth_Capture__c = objOBC.id;
        insert objOCI; 
        
        Online_Booth_Published_Profile__c objPF = new Online_Booth_Published_Profile__c();
        objPF.Website__c = 'www.google.com';
        objPF.Legal_Name__c = 'legal name';
        objPF.Published_Name__c= 'Published Name';
        objPF.ContactNumber__c ='8826470883';
        objPF.Mailing_Address__c = 'test';
        objPF.Company_Information__c ='test';
        objPF.Booth_Capture__c = objOBC.id;
        objPF.Insurance_Requirement_Check_box_1__c = true;
        insert objPF;
            
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING));
            BlngContactAccntBlngAddController obj = new BlngContactAccntBlngAddController();
            PageReference pageRef = Page.ValidateBlngContactAccntBlngAdd;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('contactId',con.Id);
            obj.validateAccountBillingAddress();
            obj.back2Contact();
            
            OnlineBoothPrimaryContactValidateCtrl booth = new OnlineBoothPrimaryContactValidateCtrl();
            PageReference pageRef1 = Page.OBC_Address_Validation;
            Test.setCurrentPage(pageRef1);
            pageRef1.getParameters().put('Id',objOBC.Id);
            booth.BoothId = objOBC.Id;
            booth.BoothPublishProfile  = objPF;
            booth.ReturnOBC = 'Test';
            Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING));
            booth.validateAccountBillingAddress();
            booth.ReturnToOBC();
            
        Test.stopTest();
    } */
     static testmethod void testBlngContactAccntBlngAddControllerOne(){
        Account acc = new Account();
        acc.name='TestAccount';
        acc.BillingStreet='456 Zepplin Avenue';
        acc.BillingCity='Las Vegas';
        acc.BillingState='Delhi';
        acc.BillingPostalCode='89131';
        acc.BillingCountry='India';
        acc.Phone='1234567890';
        acc.Fax='1234567890';
        insert acc;
        
        Contact con = new Contact();
        con.Email='test.test@gmail.com';
        con.Phone='1234567890';
        con.Title='Mr.';
        con.FirstName='TestFN';
        con.LastName='testLN';
        con.AccountId=acc.Id;
        con.MailingStreet='TestStreet';
        con.MailingCity='Las Vegas';
        con.MailingPostalCode='89131';
        con.MailingState='Delhi';
        con.MailingCountry='India';
        con.Fax='1234567890';
        insert con;
        system.assertEquals('testLN', con.LastName, 'Contact must be inserted') ;
         Pricebook2 pb=new Pricebook2(Name='TestPricebook');
        insert pb;
        Event_Edition__c ee=new Event_Edition__c();
        ee.Name='TestEvent';
        ee.Tab1__c='tab1';
        ee.Tab4__c='tab4';
        ee.Tab7__c='tab7';
        ee.Tab8__c='Tab8__c';
        ee.Event_Price_Book__c=pb.Id;
        ee.Event_Currency__c='USD';
        ee.Event_Code__c='woc18';
        insert ee;
        system.debug('--ee---'+ee );
                
        Opportunity oppty=new Opportunity(Name='testOpp',EventEdition__c=ee.Id);
        oppty.AccountId=acc.Id;
        oppty.StageName='Discover';
        oppty.CloseDate=date.today();
        insert oppty;
      
        
        SBQQ__Quote__c qtObj=new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c=acc.Id;
        qtObj.SBQQ__Status__c='Draft';
        qtObj.SBQQ__Type__c='Quote';
        qtObj.SBQQ__StartDate__c=date.today();
        qtObj.Alternate_Currency2__c='EUR';
        qtObj.SBQQ__Opportunity2__c=oppty.Id;
        qtObj.Billing_Contact__c = con.Id;
        insert qtObj;
         
        SBQQ__Quote__c qtObj1=new SBQQ__Quote__c();
        qtObj1.SBQQ__Account__c=acc.Id;
        qtObj1.SBQQ__Status__c='Draft';
        qtObj1.SBQQ__Type__c='Quote';
        qtObj1.SBQQ__StartDate__c=date.today();
        qtObj1.Alternate_Currency2__c='EUR';
        qtObj1.SBQQ__Opportunity2__c=oppty.Id;
        insert qtObj1;
       
        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING2));
           
            BlngContactAccntBlngAddController obj = new BlngContactAccntBlngAddController();
            PageReference pageRef = Page.ValidateBlngContactAccntBlngAdd;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('contactId',con.Id);
            obj.validateAccountBillingAddress();
            obj.back2Contact();
            obj.validateAccountBillingAddress(acc.Id);
            
         Test.stopTest();
      
    }
     
     
}