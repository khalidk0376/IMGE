/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          10/23/2017
 * @description : This test class covers the apex class : BoothPickListCtrl
 * Methods:             unitTest
 * Apex Class:          BoothPickListCtrl(100%)
**/

@isTest
public class BoothPickListCtrl_Test 
{
  static testMethod void unitTest() 
  {
    Event_Edition__c oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='10-40-50',X50_Cutoff_Date__c=Date.today(),Cutoff_Date_1__c=Date.today(),Cutoff_Date_2__c=Date.today(),CutoffDate_3__c=Date.today());
    insert oEve;
    System.assertEquals(oEve.Event_Code__c,'WOC17', 'Event Code');
    
    EventCurrecies__c eventCurrency = new EventCurrecies__c (Name=UserInfo.getDefaultCurrency(),Event_Edition__c=oEve.id);
    insert eventCurrency;
    System.assertEquals(eventCurrency.Name,UserInfo.getDefaultCurrency(), 'Event Currency');
    oEve.EventCurrency__c = eventCurrency.id;
    update oEve;
    System.assert(oEve.EventCurrency__c != null, 'Event Currency');
    
    Account acc1 = new Account();
    acc1.Name='acc1';             
    insert acc1;
      
    Contact con = new Contact(LastName='User',FirstName ='Test',AccountId=acc1.id);
    insert con;
    
    Opportunity testOpportunity = new Opportunity();
    testOpportunity.StageName = 'Closed Won';
    testOpportunity.AccountId = acc1.id;
    testOpportunity.Name = 'Test Opportunity';
    testOpportunity.EventEdition__c = oEve.id;
    testOpportunity.CloseDate = system.today();
    insert testOpportunity;
    
    SBQQ__Quote__c quote = new SBQQ__Quote__c();
    quote.SBQQ__Primary__c = true;
    quote.SBQQ__PrimaryContact__c = con.id;
    quote.SBQQ__EndDate__c=Date.today();
    quote.SBQQ__EndDate__c=Date.today().addDays(-1);
    quote.SBQQ__Opportunity2__c=testOpportunity.id;
    insert quote;
    
    testOpportunity.SBQQ__PrimaryQuote__c = quote.id;
    testOpportunity.StageName ='Closed Won';
    update testOpportunity;
      
    Profile_Package_Setting__c pPS = new Profile_Package_Setting__c();
    pPS.Booth_Contact_Info__c = true;
    pPS.Booth_Schedule__c = true;
    pPS.Press_Release__c = true;
    insert pPS;
      
    User_Package__c uP = new User_Package__c();
    uP.Profile_Package_Setting__c = pPS.Id;
    uP.Event_Edition__c = oEve.id;
    uP.Account__c = acc1.id;
    insert uP;
      
    Profile_Option_Visibility__c pOVisibility = new Profile_Option_Visibility__c();
    pOVisibility.Booth_Contact_Info__c = true;
    pOVisibility.Booth_Schedule__c = true;
    pOVisibility.Press_Release__c = true;
    pOVisibility.Event_Edition__c = oEve.id;
    insert pOVisibility;
     
    ExpocadBooth__c oEB = new ExpocadBooth__c(Booth_Number__c='1234',Booth_Logo_Id__c='testId111',Status__c='Rented',quote__c=quote.id,Opportunity__c=testOpportunity.id);
    insert oEB;
    
    ApexPages.currentPage().getParameters().put('accountId',acc1.id);
    ApexPages.currentPage().getParameters().put('eventId',oEve.id);
    
    Test.StartTest();
        BoothPickListCtrl obj = new BoothPickListCtrl();
        obj.getOppBoothDetails();
        obj.getBoothItems();
      	BoothPickListCtrl.getProfilePackageSetting(oEve.id, oEB.Id, acc1.id);
      	BoothPickListCtrl.getOppBoothDetailsForExhProfile(acc1.id, oEve.Id);
      	BoothPickListCtrl.getProfileOptionVisibility(oEve.id);
      	BoothPickListCtrl.getCurrentUserType(oEve.id);
      	
    Test.StopTest();
  }
}