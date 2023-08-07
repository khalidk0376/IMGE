/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          12/20/2017
 * LastModified By :    Amish CCEN-739)
 * LastModifiedDate:    04/16/2019
 * @description      : This test class covers the apex class : EventEditionAccountContact
 * Methods:             EventEditionAccountContactTest1, EventEditionAccountEventBoothTest
 * Apex Class:          EventEditionAccountContact
**/

@isTest
public class EventEditionAccountContact_Test{
  public static testMethod void eventEditionAccountContactTest1()
    {        
        Account acc1 = new Account();
        acc1.Name='acc1';
        acc1.BillingCity ='Dallas' ;
        acc1.BillingCountry='USA';
        acc1.BillingPostalCode='75068';
        acc1.BillingState='Texas';
        acc1.BillingStreet='water well street';              
        insert acc1;
        
        Contact con = new Contact(LastName='User',FirstName ='Test1',AccountId=acc1.id, Contact_Type__c = 'Primary Contact');
        insert con;
        System.assertEquals(con.AccountId, acc1.id,'Error Contact is not created');
        
      /*  Contact con2 = new Contact(LastName='User',FirstName ='Test2',AccountId=acc1.id, Contact_Type__c = 'Billing');
        insert con2;
        System.assertEquals(con2.AccountId, acc1.id);
      
       /* Contact con3 = new Contact(LastName='User',FirstName ='Test3',AccountId=acc1.id, Contact_Type__c = 'Accounting Contact');
        insert con3; 
        System.assertEquals(con3.AccountId, acc1.id); */
       
     /*   Contact con4 = new Contact(LastName='User',FirstName ='Test4',AccountId=acc1.id, Contact_Type__c = 'Invoice Contact');
        insert con4;
        System.assertEquals(con4.AccountId, acc1.id);
       
       /* Contact con5 = new Contact(LastName='User',FirstName ='Test5',AccountId=acc1.id, Contact_Type__c = 'Sales');
        insert con5;
        System.assertEquals(con5.AccountId, acc1.id);  */
        
        Event_Edition__c  sOEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='10-40-50',X50_Cutoff_Date__c=Date.today(),Cutoff_Date_1__c=Date.today(),Cutoff_Date_2__c=Date.today(),CutoffDate_3__c=Date.today());
        sOEve.Event_Edition_Status__c= 'Inactive';
        insert sOEve;
        System.assertEquals(sOEve.Event_Code__c, 'WOC17','Event Code should be equal');
        
     /*   EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=sOEve.id);
        insert eventCurrency;
        System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');   */
        
        opportunity opp = new opportunity();
        opp.Name='World of Concrete 2017';
        opp.EventEdition__c=sOEve.id;
        opp.AccountId = acc1.id;
        opp.Paid_Amount__c=10.00;
        opp.Amount=20.00;
        opp.CloseDate=System.Today();
        opp.StageName='Needs Assessment';
        opp.CurrencyIsoCode = 'USD'; 
        opp.Billing_Contact__c = con.id;
        opp.Marketing_Contact__c = con.id;
        opp.Opportunity_Contact__c = con.id;
        opp.Operations_Contact__c = con.id;
        opp.Operation_Contact_2__c = con.id;
        opp.Operation_Contact_3__c = con.id;
        opp.Operation_Contact_4__c = con.id;
        opp.Operation_Contact_5__c = con.id;
        opp.Safety_Contact__c = con.id;
        opp.Agreement_Contact__c = con.id;
        opp.Stand_Contractor__c = con.id;
        
        Test.startTest();
        System.debug('opp' + opp);
            insert opp;
            System.assert(opp != null, 'opportunity');
            opp.StageName='Closed Won';
            update opp;
            System.assert(opp.StageName =='Closed Won', 'StageName is Clsoed Won');
            EventEditionAccountContact.EventEditionAccountContact(String.valueOf(sOEve.id),String.valueOf(acc1.id));  
        Test.stopTest();
    }

    public static testMethod void eventEditionAccountEventBoothTest()
    {
        Account acc1 = new Account();
        acc1.Name='acc1';
        acc1.BillingCity ='Dallas' ;
        acc1.BillingCountry='USA';
        acc1.BillingPostalCode='75068';
        acc1.BillingState='Texas';
        acc1.BillingStreet='water well street';              
        insert acc1;
        
        Contact con = new Contact(LastName='User',FirstName ='Test1',AccountId=acc1.id);
        insert con;
        System.assertEquals(con.AccountId, acc1.id,'Error Contact is not Created');
        
        Event_Edition__c  sOEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='10-40-50',X50_Cutoff_Date__c=Date.today(),Cutoff_Date_1__c=Date.today(),Cutoff_Date_2__c=Date.today(),CutoffDate_3__c=Date.today());
        insert sOEve;
        System.assertEquals(sOEve.Event_Code__c, 'WOC17','Event Code should be equal');
        
     /*   EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=sOEve.id);
        insert eventCurrency;
        System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');  */
        
        opportunity opp = new opportunity();
        opp.Name='World of Concrete 2017';
        opp.EventEdition__c=sOEve.id;
        opp.AccountId = acc1.id;
        opp.Paid_Amount__c=10.00;
        opp.Amount=20.00;
        opp.CloseDate=System.Today();
        opp.StageName='Needs Assessment';
        opp.CurrencyIsoCode = 'USD';
        opp.Billing_Contact__c = con.id;
        opp.Marketing_Contact__c = con.id;
        opp.Opportunity_Contact__c = con.id;
        opp.Operations_Contact__c = con.id;
        opp.Safety_Contact__c = con.id;
        opp.Agreement_Contact__c = con.id;
        opp.Stand_Contractor__c = con.id;
        insert opp;
        System.assert(opp != null, 'opportunity');
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c ='Draft',SBQQ__Primary__c =true, CurrencyIsoCode='USD' , SBQQ__Type__c='Quote',SBQQ__StartDate__c=System.Today(),SBQQ__Opportunity2__c=opp.id);
        insert oQuote;
        System.assert(oQuote != null, 'SBQQ__Quote');
        System.assert(oQuote.SBQQ__Opportunity2__c == opp.id, 'SBQQ__Quote oppId');
        
        ExpocadBooth__c oExpocadBooth = new ExpocadBooth__c(Status__c='Rented',Booth_Number__c='Test booth 1',BoothContact__c = con.id, Area__c='201',Unit_Type__c='Test Unit');//,quote__c=oQuote.id);
        insert oExpocadBooth;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpo= new  Opportunity_ExpoCAD_Booth_Mapping__c();
        oppExpo.Quote__c=oQuote.id;
        oppExpo.Expocad_Booth__c=oExpocadBooth.id;
        oppExpo.Status__c='Active';
        insert oppExpo;

            Test.startTest();
            
            opp.StageName='Closed Won';
            update opp;
            System.assert(opp.StageName =='Closed Won', 'StageName is Clsoed Won');
            EventEditionAccountContact.EventEditionAccountEventBooth(String.valueOf(sOEve.id),String.valueOf(acc1.id));
        Test.stopTest();
        
      /*  SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c ='Draft',SBQQ__Primary__c =true, CurrencyIsoCode=eventCurrency.name,SBQQ__Type__c='Quote',SBQQ__StartDate__c=System.Today(),SBQQ__Opportunity2__c=opp.id);
        insert oQuote;
        System.assert(oQuote != null, 'SBQQ__Quote');
        System.assert(oQuote.SBQQ__Opportunity2__c == opp.id, 'SBQQ__Quote oppId');
        
        ExpocadBooth__c oExpocadBooth = new ExpocadBooth__c(Booth_Number__c='Test booth 1',Area__c='201',Unit_Type__c='Test Unit',quote__c=oQuote.id);
        insert oExpocadBooth;
        
        Booth_Size_Badge_Limit__c boothSizeBadgeLimit = new Booth_Size_Badge_Limit__c(Badges_Allowed__c=1.0,Booth_Size_From__c=201.0, Booth_Size_To__c=201.0,Event_Edition__c=sOEve.id);
        insert boothSizeBadgeLimit;
        Test.StartTest();
            
            System.assert(opp.StageName =='Closed Won', 'StageName is Clsoed Won');
            Order o = new Order(name='Test1',AccountId=acc1.id,EffectiveDate=system.today(),status='draft', OpportunityId = opp.id);
            insert o;
            
            blng__Invoice__c invoiceObj = new blng__Invoice__c(blng__Order__c =o.id,blng__InvoiceDate__c=Date.today(),blng__Account__c=acc1.id);
            insert invoiceObj;
            
            Contract oContract = new Contract(SBQQ__Opportunity__c=opp.id,AccountId=acc1.id);
            insert oContract;
            
            EventEditionAccountContact.EventEditionAccountEventBooth(String.valueOf(sOEve.id),String.valueOf(acc1.id));
        Test.StopTest();  
*/
    }    

}