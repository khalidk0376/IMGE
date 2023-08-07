/**
 * Created/Modified By  :  Mahesh (Girikon)
 * Created On:          :  June 12 2019
 * @description         : [This is a Utility class for data setup]
 * Modification log --
 * * Modified By : Rajesh kumar Yadav Bk-3751,[Modified By : Aishwarya 12 Aug 2020 BK-3751]
**/
@isTest

public class TestUtility {
    //----------------------------------------------------------------------------------------------------------------
    //Method to create a account for testing
    //@param boolean, string
    //@return Account
    //----------------------------------------------------------------------------------------------------------------
    public static Account createTestAccount(Boolean isInsert, String accName) {
        Account account = new Account();
        account.Name = accName;
        if(isInsert) {
            insert account;
        }
        system.assertNotEquals(account.Name, 'Test-IM-Idp1', 'Both values should be the same.');
        return account;
    }
    //----------------------------------------------------------------------------------------------------------------
    //Method to create a contact for testing
    //@param boolean, string, String, accId
    //@return contact
    //----------------------------------------------------------------------------------------------------------------
    public static Contact createTestContact(Boolean isInsert, String firstName, String lastName, Id accId) {
        Contact contact = new Contact();
        contact.FirstName = firstName;
        contact.LastName = lastName;
        contact.AccountId = accId;
        if(isInsert) {
            insert contact;
        }
        system.assertNotEquals(contact.FirstName, 'Test-IM-Idp1', 'Both values should be the same.');
        return contact;
    }
    //----------------------------------------------------------------------------------------------------------------
    //Method to create test User
    //@param string, boolean
    //@return user
    //----------------------------------------------------------------------------------------------------------------
    public static User createUser(String profileName, Boolean isInsert){
        Profile p;
        List<Profile> listProfile = [SELECT Id FROM profile WHERE Name = :profileName];
         
         
        if(listProfile.size() > 0) {
            p = listProfile[0];
        } else {
            return null;
        }
        User testUser = new User(alias = 'testUser', email='standarduser' + Math.random()  + '@testorg.com',
                                emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
                                username='teststandarduser' + Math.random() + '@testorg.com', IsActive=true,
                                Extension='1234', CompanyName = 'test Company');
        if(isInsert){
            insert testUser;
        }
        system.assertEquals(testUser.alias, 'testUser', 'Both values should be the same.');
        return testUser;
    }
    //----------------------------------------------------------------------------------------------------------------
    //Method to create AccountTeamMember
    //@param boolean, string, string, string
    //@return AccountTeamMember
    //----------------------------------------------------------------------------------------------------------------
   /*public static AccountTeamMember createAccountTeamMember(Boolean isInsert, string idAccount, string idUser, string role){
            AccountTeamMember accTeamMember = new AccountTeamMember(AccountId = idAccount, UserId = idUser);
            accTeamMember.TeamMemberRole = role;
         
            if(isInsert){
              insert accTeamMember;
            }
            return accTeamMember;
    }
    //----------------------------------------------------------------------------------------------------------------
    //Method to create a Lead record for testing
    //@param boolean, string, string, string, string
    //@return Lead
    //----------------------------------------------------------------------------------------------------------------
    public static Lead createTestLead(Boolean isInsert, String leadName, String leadStatus, String leadCompany, String leadType) {
        Lead leadRec = new Lead(LastName = leadName,Status = leadStatus,Company = leadCompany,
                                Type__c = leadType);
        if(isInsert) {
            insert leadRec;
        }
        return leadRec;
    }
    //----------------------------------------------------------------------------------------------------------------
    //Method to create a Campaign record for testing
    //@param boolean, string, string
    //@return Campaign
    //----------------------------------------------------------------------------------------------------------------
     public static Campaign createTestCampaign(Boolean isInsert, String cmpName, String cmpStatus,String campCurrency) {
        Campaign cmpRec = new Campaign(Name = cmpName,Status = cmpStatus,CurrencyIsoCode=campCurrency);
        if(isInsert) {
            insert cmpRec;
        }
        return cmpRec;
    }
    //----------------------------------------------------------------------------------------------------------------
    //Method to create a Product Family Mapping record for testing
    //@param boolean, string, string
    //@return Product_Family_Mapping__c
    //----------------------------------------------------------------------------------------------------------------
    public static Product_Family_Mapping__c createTestProdFamilyMapping(Boolean isInsert, String pName) {
        Product_Family_Mapping__c pRec = new Product_Family_Mapping__c(Name = pName);
        if(isInsert) {
            insert pRec;
        }
        return pRec;
    }
     
     
    //----------------------------------------------------------------------------------------------------------------
    //Method to create a Asset for testing
    //@param boolean, string, Account, Opportunity, Integer, Date
    //@return asset
    //----------------------------------------------------------------------------------------------------------------   
    public static Asset createTestAsset (Boolean isInsert, String assetName, Id oppId, Account accName){
       Asset asset = new Asset();
       asset.Name = assetName;
       asset.Opportunity__c = oppId;
       asset.Account= accName;      
       if(isInsert) {
           insert asset;
       }
       return asset;    
    }
     
     
    //----------------------------------------------------------------------------------------------------------------
    //Method to create Case for testing
    //@param boolean, string, Account, Opportunity, Integer, Date
    //@return case
    //----------------------------------------------------------------------------------------------------------------   
    public static Case createTestCase (Boolean isInsert, Contact conName){       
       Case testcase = new Case();
       testcase.Contact = conName;        
       if(isInsert) {
           insert testcase;
       }
       return testcase;       
    }*/
 
     
    //----------------------------------------------------------------------------------------------------------------
    //Method to create an Opportunity Record for Testing
    //@param boolean, string, string
    //@return Opportunity
    //----------------------------------------------------------------------------------------------------------------
    public static Opportunity createTestOpportunity (Boolean isInsert, String oppName, Id accId) {
        Opportunity opp = new Opportunity(Name = oppName);
        opp.AccountId = accId;
        opp.Type = 'New';
        opp.StageName = 'Initiating';
        opp.Probability = 5.0;
        opp.ForecastCategoryName = 'Pipeline';
        opp.CloseDate = Date.today() + 30;
        if(isInsert) {
            insert opp;
        }
        system.assertEquals(opp.Type, 'New', 'Both values should be the same.');
        return opp;
    }
     
     
    //----------------------------------------------------------------------------------------------------------------
    //Method to create a CampaignMember record for testing
    //@param boolean, id, id
    //@return CampaignMember
    //----------------------------------------------------------------------------------------------------------------
  /* public static CampaignMember createTestCampaignMember(Boolean isInsert,Campaign campRec,Lead leadRec)
    {
        CampaignMember campMem=new CampaignMember(CampaignId=campRec.Id,LeadId=leadRec.Id);
        if(isInsert){
            insert campMem;
        }
        return campMem;
    } 
     
    //----------------------------------------------------------------------------------------------------------------
    //Method to create a Product Record for Testing
    //@param boolean, string, string, string
    //@return Product
    //----------------------------------------------------------------------------------------------------------------
    public static Product2 createProduct(Boolean isInsert , String productName , String productCode , string prodType){
         Product2 prod = new Product2(
            Name = productName,
            ProductCode = productCode,
            isActive = true,
            CurrencyIsoCode='GBP',
            Product_Type__c = prodType
        );
        if(isInsert){
            insert prod;
        }
         
        return prod;
    }
     
    //----------------------------------------------------------------------------------------------------------------
    //Method to create a PriceBook Record for Testing
    //@param boolean, Id
    //@return PriceBook
    //----------------------------------------------------------------------------------------------------------------
    public static PriceBookEntry createPriceBook( Boolean isInsert , Id prodId ){
        //Create standard pricebookid
        Id pricebookId = Test.getStandardPricebookId();
         
        //Create pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prodId,
            UnitPrice = 100.00,
            IsActive = true
        );
         
        if(isInsert){
            insert pbEntry;
        }
         
        return pbEntry;
    }
     
    //----------------------------------------------------------------------------------------------------------------
    //Method to create an OpportunityLineItem Record for Testing
    //@param boolean, Id, Id
    //@return OpportunityLineItem
    //----------------------------------------------------------------------------------------------------------------
     public static OpportunityLineItem createOpportunityLineItem( Boolean isInsert , Id oppId, Id pbEntryId){
         
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.PricebookEntryId = pbEntryId;
        oli.OpportunityId = oppId;
        oli.Start_Date__c = Date.Today();
        oli.End_Date__c = Date.Today() + 10;
        oli.Quantity = 5;
        oli.TotalPrice = 100;
        oli.Licence_Type__c = 'Banded Seat';
        oli.Banded_Seat__c = '26 - 30';
         
        if(isInsert){
            insert oli;
        }
         
        return oli;
    }
     
    //----------------------------------------------------------------------------------------------------------------
    //Method to create OpportunityContactRole  Record for Testing
    //@param boolean, Id, Id, string, boolean
    //@return OpportunityContactRole
    //----------------------------------------------------------------------------------------------------------------
    public static OpportunityContactRole createOpportunityContactRole( Boolean isInsert , Id conId, Id oppId, String role , Boolean isPrimary){
        OpportunityContactRole oppConRole = new OpportunityContactRole(
                                                ContactId = conId , OpportunityId = oppId,
                                                Role = role , IsPrimary = isPrimary);
                                                 
        if(isInsert){
            insert oppConRole;
        }
         
        return oppConRole;
    }
     
    //----------------------------------------------------------------------------------------------------------------
    //Method to create Region_Mapping  Record for Testing
    //@param String, String , String, String, boolean
    //@return Region_Mapping__c
    //----------------------------------------------------------------------------------------------------------------
    public static Region_Mapping__c createRegionMapping(String countryName, String curr, String region, String subRegion, Boolean isInsert){
        Region_Mapping__c regionMap = new Region_Mapping__c(Name = countryName, CurrencyIsoCode = curr, Region__c = region, Sub_Region__c = subRegion);
        if(isInsert){
            insert regionMap;
        }
        return regionMap;
    }*/
 
    //----------------------------------------------------------------------------------------------------------------
    //Method to create Site_Branding__c  Record for Testing
    //@param String, String , String, String, boolean
    //@return Site_Branding__c
    //----------------------------------------------------------------------------------------------------------------
     public static esso_Site_Branding__c createSiteBranding(String brandName, String referralId, String productName, String division, Boolean isInsert){
 
        esso_Site_Branding__c siteBrandingObject = new esso_Site_Branding__c(
            Name = brandName,
            Footer_Background_Colour__c = '#000000',
            Footer_Font_Colour__c  = '#FFFFFF',
            Footer_Logo_File_Name__c = 'logo.jpeg',
            Headings_Font_Colour__c = '#AAAAAA',
            Page_Background_Colour__c = '#FFFFFF',
            Page_Image__c = 'pageImage.jpeg',
            Product_Logo_File_Name__c = 'productImage.jpeg',
            Primary_Colour__c = '#BBBBBB',
            Referral_Id__c = referralId,
            Secondary_Colour__c = '#CCCCCC',
            Standard_Font_Colour__c = '#000000',
            Product_Name__c = productName,
            Division__c = division,
            Language__c='en_US',
            Branding_Type__c = 'Vertical',
           // Client_Services_Contact_Email__c = 'help@informa.com',
            Default_Landing_Page__c = 'https://www.informa.com',
            Registration_Contact_Source__c = 'A55_Website Registrant (FREE)',
            Customer_Support_Page__c = 'https://informa.com/contact-us'
        );
        if(isInsert){
            insert siteBrandingObject;
 
            Attachment verticalLogo = new Attachment(Name = 'logo.jpeg', Body = Blob.valueOf('test'), ParentId = siteBrandingObject.Id);
            insert verticalLogo;
 
            Attachment pageImage = new Attachment(Name = 'pageImage.jpeg', Body = Blob.valueOf('test'), ParentId = siteBrandingObject.Id);
            insert pageImage;
 
            Attachment productImage = new Attachment(Name = 'productImage.jpeg', Body = Blob.valueOf('test'), ParentId = siteBrandingObject.Id);
            insert productImage;
        }
         system.assertEquals(siteBrandingObject.Footer_Background_Colour__c, '#000000', 'Both values should be the same.');
        return siteBrandingObject;
    }
 
   /*public static Integration_Bypass__c createIntegrationBypassSettings(Boolean bypassLightningProcesses, Boolean bypassTriggers, Boolean bypassValidationRules, Boolean bypassWorkflowRules, Boolean isInsert){
        Integration_Bypass__c settings = Integration_Bypass__c.getOrgDefaults();
 
        settings.Bypass_Lightning_Processes__c = bypassLightningProcesses;
        settings.Bypass_Triggers__c = bypassTriggers;
        settings.Bypass_Validation_Rules__c = bypassValidationRules;
        settings.Bypass_Workflow_Rules__c = bypassWorkflowRules;
 
        if(isInsert){
            upsert settings;
        }
        return settings;
    } */
 
  /*  public static Map<Id, csord__Service__c> createCSData(String accId, String oppId){
         
        Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>();
         
        cscfga__Product_Category__c productCategory = new cscfga__Product_Category__c(Name = 'Test category');
        insert productCategory;
         
        cscfga__Product_Definition__c prodDefintion = new cscfga__Product_Definition__c (Name = 'Test definition 1'
            , cscfga__Product_Category__c = productCategory.Id
            , cscfga__Description__c = 'Test definition 1');
        insert prodDefintion;
         
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(cscfga__Opportunity__c = oppId);
        insert basket;
         
        cscfga__Product_Configuration__c config = new cscfga__Product_Configuration__c(Name = 'Test config '
            , cscfga__Product_Definition__c = prodDefintion.Id
            , cscfga__Product_Basket__c = basket.Id); 
        insert config;
 
        csord__Order_Request__c orderRequest = new csord__Order_Request__c(Name = 'Test request'
            , csord__Module_Version__c = 'test orderRequest'
            , csord__Module_Name__c = 'test orderRequest');
        insert orderRequest;
         
        csord__Order__c ord = new csord__Order__c(csordtelcoa__Opportunity__c = oppId
            , csord__Account__c = accId
            , csord__Identification__c = 'Order-' + oppId
            , csord__Order_Request__c = orderRequest.Id);
        insert ord;
         
        csord__Subscription__c subscription = new csord__Subscription__c(Name = 'Test subscription'
            , csord__Identification__c = 'test subscription'
            , csord__Order_Request__c = orderRequest.Id
            , csord__Account__c = accId
            , csord__Order__c = ord.Id);
        insert subscription;
         
        csord__Service__c parentService = new csord__Service__c(Name = 'Parent service'
            , Type__c = 'Parent Service Type'
            , csordtelcoa__Product_Configuration__c = config.Id
            , csordtelcoa__Product_Basket__c = basket.Id
            , csord__Identification__c = 'ParentService_' + config.Id
            , csord__Subscription__c = subscription.Id
            , csord__Order_Request__c = orderRequest.Id
            , csord__Order__c = ord.Id
            , Purchased_Licences__c = 8
            , Service_Start_Date__c = system.today());
        insert parentService;
        serviceMap.put(parentService.Id, parentService);
         
        csord__Service__c service1 = new csord__Service__c(Name = 'Child service 1'
            , Type__c = 'Service1 Type'
            , csordtelcoa__Product_Configuration__c = config.Id
            , csordtelcoa__Product_Basket__c = basket.Id
            , csord__Service__c = parentService.Id
            , csord__Identification__c = 'ChildService1_' + config.Id
            , csord__Subscription__c = subscription.Id
            , csord__Order_Request__c = orderRequest.Id
            , csord__Order__c = ord.Id
            , Service_Start_Date__c = system.today());
        insert service1;
        serviceMap.put(service1.Id, service1);
 
        csord__Service__c service2 = new csord__Service__c(Name = 'Child service 2'
            , Type__c = 'Service2 Type'
            , csordtelcoa__Product_Configuration__c = config.Id
            , csordtelcoa__Product_Basket__c = basket.Id
            , csord__Service__c = parentService.Id
            , csord__Identification__c = 'ChildService2_' + config.Id
            , csord__Subscription__c = subscription.Id
            , csord__Order__c = ord.Id
            , csord__Order_Request__c = orderRequest.Id
            , Service_Start_Date__c = system.today());
        insert service2;
        serviceMap.put(service2.Id, service2);
         
        return serviceMap;
    }*/ 

@isTest static void test_method()
{
        Account a = TestUtility.createTestAccount(true, 'Test-IM-Idp');
        system.assertNotEquals(a.id, null, 'Id cannot be blank');
        Contact c = TestUtility.createTestContact(true, 'Test-IM-Idp', 'Test-IM-Idp', a.Id );
        system.assertNotEquals(c.id, null, 'Id cannot be blank');
        TestUtility.createTestOpportunity(true, 'Test-IM-Idp', a.Id );
        TestUtility.createSiteBranding('Test-IM-Idp', 'Test-IM-Idp', 'Test-IM-Idp', 'informa markets', true);
        User u = TestUtility.createUser('Standard User', true);
}

}