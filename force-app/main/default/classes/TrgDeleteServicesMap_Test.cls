/**
 * Created By: Mahesh (Girikon)
 * Created On: 08/06/2018
 * Modified By :
 * Modified On :
 * Description/Purpose: This test class covers the Trigger : trgDeleteServicesMap
 * Apex Class:          trgDeleteServicesMap(90%)
**/
@isTest
public class TrgDeleteServicesMap_Test 
{
   public static testMethod void trgDeleteServicesMapTest() 
    {      
        //Create exhibitor user type
        User_Type__c uType = new User_Type__c(Name ='Stand Contractor');
        insert uType;
        System.AssertEquals(uType.Name, 'Stand Contractor','Invalid User Type');
                
        //Create Account
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'Account not equal null');
        
        //Create contact
        Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com', Type__c=uType.Id,AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null,'Contact not equal null');
        set<Id> conIds = new set<Id>();
        conIds.add(con.id);   
         
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab7__c = 'Test',Tab1__c = 'Test', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Barter Shell Scheme', Start_Date__c = Date.today(),Part_of_Series__c = oEventseries.id, Event_Edition_Code__c = 'test12340');
        insert oEvent;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = acc.Id, Billing_Contact__c = con.Id,Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor');
        insert oOpportunity;
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = acc.Id, SBQQ__Primary__c = true);
        insert oQuote;
        //create ExpocadBooth__c
        ExpocadBooth__c oEB = new ExpocadBooth__c(Selected__c = true, Status__c = 'Rented', Opportunity__c = oOpportunity.Id, Booth_Type__c = 'Corner', ShowInShow__c = 'TestShowInShow', Open_Corners__c = 23, Booth_Classes__c='tset2;;test4', Booth_Product_Type_EE__c = 'Space Only', Area__c = '400 SqFt',Quote__c=oQuote.Id,Pavilion__c='test');
        insert oEB;
        Opportunity_ExpoCAD_Booth_Mapping__c oEM = new Opportunity_ExpoCAD_Booth_Mapping__c(Opportunity__c = oOpportunity.Id, Quote__c=oQuote.Id,Expocad_Booth__c=oEB.ID);
        insert oEM;
        Opportunity_ExpoCAD_Booth_Mapping__c oEM1 = new Opportunity_ExpoCAD_Booth_Mapping__c(Opportunity__c = oOpportunity.Id, Quote__c=oQuote.Id,Expocad_Booth__c=oEB.ID);
        insert oEM1;
        //Create event edition
        Event_Edition__c oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Currency__c='INR');
        insert OEve;
        System.Debug('oEve: '+OEve); 
        Test.StartTest();
        //Create BoothContractorMapping
        List<BoothContractorMapping__c> lstBoothCon = new List<BoothContractorMapping__c>();
        BoothContractorMapping__c boothConMap= new BoothContractorMapping__c (ContractorRequestStatus__c='Declined',ExpocadBooth__c=oEB.id,Contact__c=con.id,Event_Edition__c=OEve.id, Opp_Booth_Mapping__c=oEM.Id);
        lstBoothCon.add(BoothConMap);   
        insert lstBoothCon; 
        lstBoothCon=[Select Id, ContractorRequestStatus__c, ExpocadBooth__r.Booth_Type__c, ExpocadBooth__r.Booth_Product_Type__c, ExpocadBooth__r.Booth_Product_Type_EE__c, ExpocadBooth__r.Booth_Classes__c, 
                                       Contact__c, Contact__r.AccountId, Event_Edition__c FROM BoothContractorMapping__c];
        lstBoothCon[0].ContractorRequestStatus__c='Accepted';
        lstBoothCon[0].Opp_Booth_Mapping__c= oEM1.Id ;
        update lstBoothCon;            
        system.assertEquals(lstBoothCon.size(),1,'BoothContractorMapping must not be null');
        delete lstBoothCon;
        Exhibitor_Badge__c oExhibitor = new Exhibitor_Badge__c (ExpocadBooth__c=oEB.id, Event_Edition__c=OEve.id, Opp_Booth_Mapping__c=oEM.Id);
        insert oExhibitor; 
        oExhibitor.Opp_Booth_Mapping__c = oEM1.Id;
        update oExhibitor;
        Test.StopTest();
     
    }    
}