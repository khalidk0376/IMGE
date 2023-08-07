/*Created By: {Girikon(Mukesh Gupta)}
Created On: 8/23/2018
@description : This is the test class for HomeAccountSummeryCtr.
Methods: testGetOppBoothDetails
Apex Class: HomeAccountSummeryCtr
Modification log --
Modified By: [Aishwarya BK-5809 7 july 2020]
*/

@isTest
public class HomeAccountSummeryCtr_Test {
    /**
    * @description : test class method 
    **/
    public static testMethod void testGetOppBoothDetails()
    {
        Utility.isRebookInProcess = True ;
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserFirst1@testorg.com');
        Event_Edition__c eventEdition;
        Account acc1;
        blng__Invoice__c invoiceObj;
        ExpocadBooth__c oExpocadBooth;
        Contract oContract;
        Event_Settings__c oSetting;
        
        System.runAs(u) 
        {
            // The following code runs as user 'u'             
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            acc1 = new Account();
            acc1.Name='acc1';              
            insert acc1;
            
            Contact con = new Contact(LastName='User',FirstName ='Test',AccountId=acc1.id);
            insert con;
            
            eventEdition = new Event_Edition__c(Event_Currency__c='USD',Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='10-40-50',X50_Cutoff_Date__c=Date.today(),Cutoff_Date_1__c=Date.today(),Cutoff_Date_2__c=Date.today(),CutoffDate_3__c=Date.today());
            insert eventEdition;
            System.assertEquals(eventEdition.Event_Code__c,'WOC17', 'Event Code');
            EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=eventEdition.id);
            insert eventCurrency;
            System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
            eventEdition.EventCurrency__c = eventCurrency.id;
            update eventEdition;
            System.assert(eventEdition.EventCurrency__c != null, 'Event Currency');
            opportunity opp = new opportunity(Name='World of Concrete 2017',EventEdition__c=eventEdition.id,AccountId = acc1.id,Paid_Amount__c=10.00,Amount=20.00,CloseDate=System.Today(),StageName='Needs Assessment',CurrencyIsoCode=eventEdition.EventCurrency__r.Name);
            insert opp;
            System.assert(opp != null, 'opportunity');
            SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c ='Draft',SBQQ__Primary__c =true, CurrencyIsoCode=eventCurrency.name,SBQQ__Type__c='Quote',SBQQ__StartDate__c=System.Today(),SBQQ__Opportunity2__c=opp.id);
            insert oQuote;
            System.assert(oQuote != null, 'SBQQ__Quote');
            System.assert(oQuote.SBQQ__Opportunity2__c == opp.id, 'SBQQ__Quote oppId');
            oExpocadBooth = new ExpocadBooth__c(Booth_Number__c='Test booth 1',Area__c='201',Unit_Type__c='Test Unit',quote__c=oQuote.id,Status__c='Rented');
            insert oExpocadBooth;
            
            Opportunity_ExpoCAD_Booth_Mapping__c oppEBM = new Opportunity_ExpoCAD_Booth_Mapping__c();
            oppEBM.Expocad_Booth__c = oExpocadBooth.Id;
            oppEBM.Account__c = acc1.Id;
            oppEBM.Opportunity__c = Opp.Id;
            oppEBM.Quote__c = oQuote.Id;
            oppEBM.Status__c = 'Active';
            insert oppEBM;
            
            Booth_Size_Badge_Limit__c boothSizeBadgeLimit = new Booth_Size_Badge_Limit__c(Badges_Allowed__c=1.0,Booth_Size_From__c=201.0, Booth_Size_To__c=201.0,Event_Edition__c=eventEdition.id);
            insert boothSizeBadgeLimit;
            Order o = new Order(name='Test1',AccountId=acc1.id,EffectiveDate=system.today(),status='draft', OpportunityId = opp.id);
            insert o;

            invoiceObj = new blng__Invoice__c(blng__Order__c =o.id,blng__InvoiceDate__c=Date.today(),blng__Account__c=acc1.id);
            //insert invoiceObj;
            oContract = new Contract(SBQQ__Opportunity__c=opp.id,AccountId=acc1.id);
            insert oContract;
            
            oSetting = new Event_Settings__c();
            oSetting.Branding_Color__c='Red';
            oSetting.Event_Edition__c=eventEdition.id;
            insert oSetting;
                
            opp.StageName='Closed Won';
            update opp;
            
            System.assert(opp.StageName =='Closed Won', 'StageName is Clsoed Won');
            
            
            Agreement__c agrmnt = new Agreement__c();
            agrmnt.Name='Agreement 1';
            agrmnt.Opportunity__c=Opp.id;
            insert agrmnt;
            
        }
        Test.startTest();
        HomeAccountSummeryCtr.getOppBoothDetails(acc1.id,eventEdition.id);
        HomeAccountSummeryCtr.getCurrentUserType(eventEdition.Event_Code__c);
        Test.stopTest();
    }
}