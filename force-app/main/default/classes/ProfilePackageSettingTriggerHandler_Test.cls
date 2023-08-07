/**
* Created/Modified By: Girikon(shashank)
* Created On:          02/09/2018
* @description : to test coverage of ProfilePackageSettingTriggerHandler
* Methods:             PrflPcgSettTriggHandOppTest,PrflPcgSettTriggHandPPSTest,PrflPcgSettTriggHandPPSBothMap,
* Test Class: ProfilePackageSettingTriggerHandler(Rajeev(Girikon) BK-3275)(90%)
**/
@isTest
public class ProfilePackageSettingTriggerHandler_Test 
{    
   @isTest
    static void prflPcgSettTriggHandOppTest()
    {
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD', Phone = '2423122323');
        insert oAccount;
        System.assertNotEquals(null, oAccount.Id,'Invalid AccountId');
        
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421');
        insert oCon;
        
        User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        AccountTeamMember oAtm =new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
        insert oAtm;
        
        Event_Edition__c oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert oEve; 
        
     	Product2 prd = new Product2(CurrencyIsoCode = 'USD',Name = 'Booth Package WOC',Family = 'Booth',Number_of_Corners__c = 0,Booth_Type__c='esc', Show_In_Show__c='Indoor', Booth_Class__c='fsdf', Event_Edition_Pool__c = 'WOC',Event_Edition__c = oEve.id);
        insert prd;        

        Pricebook2 customPB2 = new Pricebook2(CurrencyIsoCode = 'USD',Name='ICRE', isActive=true);
        insert customPB2;
        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pbStndrdPrice = new PricebookEntry(CurrencyIsoCode = 'USD',Pricebook2Id = pricebookId, Product2Id = prd.Id,UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice;
        
        List<Profile_Package_Setting__c> lstprflPckgSetting = new  List<Profile_Package_Setting__c>();
        for(Integer i=0;i<2;i++)
        {
             Profile_Package_Setting__c prflPckgSetting = new Profile_Package_Setting__c(Name='Profile'+i, Event_Edition__c=oEve.id ,Priority__c= String.valueOf(i+1),Product__c=prd.id );
             lstprflPckgSetting.add(prflPckgSetting);
        }
        insert lstprflPckgSetting;     
        
        opportunity opp = new opportunity();
        opp.Name='World of Concrete 2017';
        opp.EventEdition__c = lstprflPckgSetting[0].Event_Edition__c;
        opp.AccountId = oAccount.id;
        opp.Paid_Amount__c=20.00;
        //opp.Amount=20.00;
        opp.CloseDate=System.Today();
        opp.StageName='Needs Assessment';
        opp.CurrencyIsoCode= 'USD';
        opp.Billing_Contact__c = oCon.id;
        opp.Marketing_Contact__c = oCon.id;
        opp.Opportunity_Contact__c = oCon.id;
        opp.Operations_Contact__c = oCon.id;
        opp.Safety_Contact__c = oCon.id;
        opp.Agreement_Contact__c = oCon.id;
        opp.Stand_Contractor__c = oCon.id;
        insert opp;
        
        //---->Create OpportunityLineItem.
        OpportunityLineItem oppli = new OpportunityLineItem(); 
        oppli.PricebookEntryId=pbStndrdPrice.Id;
        oppli.OpportunityId =opp.Id;
        oppli.Quantity = 5;
        oppli.TotalPrice = oppli.Quantity * pbStndrdPrice.UnitPrice;
        oppli.Product2Id = lstprflPckgSetting[0].Product__c;
        insert oppli;  
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opp.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
        //insert oQuote;      
        
        opp.StageName='Closed Won';
        update opp;
            
        User_Package__c usrP = new User_Package__c(Name='Text',Account__c=opp.Accountid, Event_Edition__c=opp.EventEdition__c, Profile_Package_Setting__c=lstprflPckgSetting[0].id);// ,Contact__c=oCon.id
        insert usrP;

        ExpocadBooth__c oEB = new ExpocadBooth__c(Quote__c = oQuote.Id, Opportunity__c = opp.Id, Account__c = opp.AccountId,Status__c = 'Rented' ,Booth_Product_Type__c = 'Indoor');
        insert oEB;
        
        Test.startTest();
        Utility.isRebookInProcess = True ;
        
        Map<Id,opportunity> mapopp = new Map<Id,opportunity>();
        mapopp.put(opp.Id,opp);
        
        System.Debug('mapopp: '+mapopp);
        ProfilePackageSettingTriggerHandler.createOrUpdateUserPkg(mapopp,mapopp,NULL,NULL); // Proposal Sent
        ProfilePackageSettingTriggerHandler.getUpdatedStageOppMap(mapopp  , mapopp);
        Map<Id,Profile_Package_Setting__c> mapPrflPckgSet = new Map<Id,Profile_Package_Setting__c>(lstprflPckgSetting);
        System.Debug('lstprflPckgSetting: '+lstprflPckgSetting);
        ProfilePackageSettingTriggerHandler.createOrUpdateUserPkg(null,null,mapPrflPckgSet,null);
        ProfilePackageSettingTriggerHandler.getHigherProfilePcakageSettg(lstprflPckgSetting);
        ProfilePackageSettingTriggerHandler.getUpdatedProductMap(mapPrflPckgSet  , mapPrflPckgSet);
        System.Debug('lstprflPckgSetting: '+lstprflPckgSetting);
        ProfilePackageSettingTriggerHandler.createOrUpdateUserPkg(null,null,mapPrflPckgSet,mapPrflPckgSet);
        
        Test.stopTest();
    }
    @isTest
    static void prflPcgSettCustomTest(){
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD', Phone = '2423122323');
        insert oAccount;
        System.assertNotEquals(null, oAccount.Id,'Invalid AccountId');
        
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421');
        insert oCon;
        
        User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        AccountTeamMember oAtm =new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
        insert oAtm;
        
        Event_Edition__c oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert oEve; 
        
     	Product2 prd = new Product2(CurrencyIsoCode = 'USD',Name = 'Booth Package WOC',Family = 'Booth',Number_of_Corners__c = 0,Booth_Type__c='esc', Show_In_Show__c='Indoor', Booth_Class__c='fsdf', Event_Edition_Pool__c = 'WOC',Event_Edition__c = oEve.id);
        insert prd;        

        Pricebook2 customPB2 = new Pricebook2(CurrencyIsoCode = 'USD',Name='ICRE', isActive=true);
        insert customPB2;
        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pbStndrdPrice = new PricebookEntry(CurrencyIsoCode = 'USD',Pricebook2Id = pricebookId, Product2Id = prd.Id,UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice;
        
        List<Profile_Package_Setting__c> lstprflPckgSetting = new  List<Profile_Package_Setting__c>();
        for(Integer i=0;i<2;i++)
        {
             Profile_Package_Setting__c prflPckgSetting = new Profile_Package_Setting__c(Name='Profile'+i, Event_Edition__c=oEve.id ,Priority__c= String.valueOf(i+1),Product__c=prd.id );
             lstprflPckgSetting.add(prflPckgSetting);
        }
        insert lstprflPckgSetting;     
        
        opportunity opp = new opportunity();
        opp.Name='World of Concrete 2017';
        opp.EventEdition__c = lstprflPckgSetting[0].Event_Edition__c;
        opp.AccountId = oAccount.id;
        opp.Paid_Amount__c=20.00;
        //opp.Amount=20.00;
        opp.CloseDate=System.Today();
        opp.StageName='Needs Assessment';
        opp.CurrencyIsoCode= 'USD';
        opp.Billing_Contact__c = oCon.id;
        opp.Marketing_Contact__c = oCon.id;
        opp.Opportunity_Contact__c = oCon.id;
        opp.Operations_Contact__c = oCon.id;
        opp.Safety_Contact__c = oCon.id;
        opp.Agreement_Contact__c = oCon.id;
        opp.Stand_Contractor__c = oCon.id;
        insert opp;
        
        //---->Create OpportunityLineItem.
        OpportunityLineItem oppli = new OpportunityLineItem(); 
        oppli.PricebookEntryId=pbStndrdPrice.Id;
        oppli.OpportunityId =opp.Id;
        oppli.Quantity = 5;
        oppli.TotalPrice = oppli.Quantity * pbStndrdPrice.UnitPrice;
        oppli.Product2Id = lstprflPckgSetting[0].Product__c;
        insert oppli;  
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opp.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
        //insert oQuote;      
        
        opp.StageName='Closed Won';
        update opp;
            
        ExpocadBooth__c oEB = new ExpocadBooth__c(Quote__c = oQuote.Id, Opportunity__c = opp.Id, Account__c = opp.AccountId,Status__c = 'Rented' ,Booth_Product_Type__c = 'Indoor');
        insert oEB;
        
        Test.startTest();
        Utility.isRebookInProcess = True ;
        
        Map<Id,opportunity> mapopp = new Map<Id,opportunity>();
        mapopp.put(opp.Id,opp);
        
        System.Debug('mapopp: '+mapopp);
        ProfilePackageSettingTriggerHandler.createOrUpdateUserPkg(mapopp,mapopp,NULL,NULL); // Proposal Sent
        ProfilePackageSettingTriggerHandler.getUpdatedStageOppMap(mapopp  , mapopp);
        Map<Id,Profile_Package_Setting__c> mapPrflPckgSet = new Map<Id,Profile_Package_Setting__c>(lstprflPckgSetting);
        System.Debug('lstprflPckgSetting: '+lstprflPckgSetting);
        ProfilePackageSettingTriggerHandler.createOrUpdateUserPkg(null,null,mapPrflPckgSet,null);
        ProfilePackageSettingTriggerHandler.getHigherProfilePcakageSettg(lstprflPckgSetting);
        ProfilePackageSettingTriggerHandler.getUpdatedProductMap(mapPrflPckgSet  , mapPrflPckgSet);
        System.Debug('lstprflPckgSetting: '+lstprflPckgSetting);
        ProfilePackageSettingTriggerHandler.createOrUpdateUserPkg(null,null,mapPrflPckgSet,mapPrflPckgSet);
        
        Test.stopTest();
    }

}