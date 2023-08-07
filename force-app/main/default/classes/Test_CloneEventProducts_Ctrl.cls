//Ticket No. BK-14521 Updating API Version
@isTest
public class Test_CloneEventProducts_Ctrl{
    
    static testMethod void unitTest() {
        
        Test.StartTest();
        Account oAccount = new Account(Name='Rebook_EE Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        System.assertEquals('Rebook_EE Account',oAccount.name,'Error account is not created');
        
        Contact oCon = new Contact(LastName='Rebook_EECont', Email='test1contact@sforce.com', AccountId = oAccount.Id,MailingCountry='United Arab Emirates', MailingStreet = 'Suite 22 Bora Bora Towers Al Abraj Street Business Bay',MailingCity ='Dubai',MailingState='Abu Dhabi');
        insert oCon;
        
        User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        AccountTeamMember oAtm =new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
        insert oAtm;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB1', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4',Tab1__c = 'test' ,Tab7__c = 'test', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Start_Date__c = Date.newInstance(2017,01,26),End_Date__c = Date.newInstance(2017,01,30));
        oEvent.Event_Edition_Status__c = 'Completed';
        oEvent.Event_Edition_Code__c = 'Test1';
        insert oEvent;
        
        Event_Edition__c oEvent3 = new Event_Edition__c(Name = 'World of Concrete 2018',Approval_Service_Now_ID__c = '1234', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4',Tab1__c = 'test' ,Tab7__c = 'test', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Start_Date__c = Date.newInstance(2018,01,26),End_Date__c = Date.newInstance(2018,01,30));
        oEvent3.Event_Edition_Status__c = 'Completed';
        oEvent3.Event_Edition_Code__c = 'Test2';
        insert oEvent3;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Closed Booked', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id, Rebooked__c = false);
        insert oOpportunity;    
        
        //Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];
        Id stdPb = Test.getStandardPricebookId();
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true);
        insert pb;
        
        
        Product2 prod = new Product2(Name = 'Floor Graphic', Event_Edition_TISE__c ='The International Surface Event',Event_Edition_TOC__c = 'TOC Americas 2017', Event_Edition_LFSC__c ='Arab Health',End_Date__c = system.today()+1,ProductCode ='Floor',Start_Date__c = system.today(), Family = 'Event',Brand__c='World of Concrete', Event_Edition__c = oEvent3.Id ,Event_Edition_Pool__c='WOC', Event_Edition_WOC__c='World of Concrete 2017',CurrencyIsoCode='USD', IsActive = true, Cloned__c = TRUE);
        insert prod;
        
        Product2 prod1 = new Product2(Name = 'Cool Package', Family = 'Package',Brand__c='Arab Health',Event_Edition_LFSC__c='Arab Health 2017', Event_Edition__c = oEvent3.Id ,Event_Edition_Pool__c='LFSC',CurrencyIsoCode='BRL', IsActive = true, Cloned__c = TRUE);
        insert prod1;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = stdPb, Product2Id = prod.Id, UnitPrice = 100, IsActive = true);
        insert standardPrice;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPb, Product2Id = prod1.Id, UnitPrice = 100, IsActive = true, UseStandardPrice = false);
        insert pbe;
        
        
        
        SBQQ__ProductRule__c objPRule = new SBQQ__ProductRule__c();
        objPRule.name= 'Test P Rule';
        objPRule.SBQQ__Type__c = 'Filter';
        objPRule.SBQQ__ConditionsMet__c = 'All';
        objPRule.SBQQ__Scope__c = 'Product';
        insert objPRule;
        
        SBQQ__ProductFeature__c objFeature = new SBQQ__ProductFeature__c();
        objFeature.name='Core Product';
        objFeature.SBQQ__Number__c = 10;
        objFeature.SBQQ__ConfiguredSKU__c = prod.id;
        objFeature.SBQQ__MinOptionCount__c = 1;
        insert objFeature;
        
        SBQQ__ProductOption__c objOptions = new SBQQ__ProductOption__c();
        objOptions.SBQQ__Number__c =5;
        objOptions.SBQQ__ConfiguredSKU__c = prod.id;
        objOptions.SBQQ__OptionalSKU__c = prod.id;
        objOptions.SBQQ__Feature__c = objFeature.id;
        insert objOptions;
        
        SBQQ__ConfigurationRule__c objCRules = new SBQQ__ConfigurationRule__c();
        objCRules.SBQQ__Product__c = prod.id;
        objCRules.SBQQ__ProductRule__c = objPRule.id;
        insert objCRules;
        
        CPQ_Product_Clone__c objClone = new CPQ_Product_Clone__c();
        objClone.Event_Series__c ='World of Concrete';
        objClone.Cloned__c = false;
        objClone.Source_Event_Edition__c = 'World of Concrete 2017';
        objClone.Target_Event_Edition__c = 'World of Concrete 2018';
        objClone.Price_Lookup_Table__c= 'ICRE';
        insert objClone;
        
        prod.Event_Edition__c = oEvent.Id;
        update prod;
        
        PageReference pgRef = Page.PrdCloneWithRelated; //Create Page Reference - 'Appt_New' is the name of Page
        Test.setCurrentPage(pgRef); //Set the page for Test Method
        ApexPages.currentPage().getParameters().put('CPC_Id', objClone.Id);//Pass Id to page
        CloneEventProducts_Ctrl cloneProd = new CloneEventProducts_Ctrl();
        
        cloneProd.dynamicQuery('product2');
        cloneProd.clonePrdwithRealted();
        cloneProd.deleteRecord();
        cloneProd.cancelRecord();
                
        Test.StopTest();
        
        
    }
}