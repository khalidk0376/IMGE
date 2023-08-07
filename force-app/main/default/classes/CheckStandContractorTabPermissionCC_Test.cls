/**
 * Created/Modified By : Girikon(Aishwarya)
 * Created On          :          6/12/2018
 * @description        : This test class covers the apex class : CheckStandContractorTabPermissionCC
 * Methods             :             dataInsertForStandContctor
 * Apex Class          :          CheckStandContractorTabPermissionCC
**/
@isTest
public class CheckStandContractorTabPermissionCC_Test
{
    /**
    @description :test class method 
    **/
    public static testMethod void dataInsertForStandContctor()
    {
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'account should not be null');
        
        //contact con = new Contact(LastName='User',FirstName ='Test', Type__c=uType.Id,AccountId = acc.id);
        //insert con;
        //System.AssertNotEquals(con, null);
        
        Event_Edition__c oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Currency__c='USD');
        insert oEve;
        System.assertEquals(oEve.Event_Code__c,'WOC17', 'Event Code');
        
        Event_Settings__c eset = new Event_Settings__c();
        eset.Name ='event Setting Test';
        eset.Event_Edition__c = oEve.Id;
        eset.Allowed_Expocad_Product_Types__c ='Space Only';
        insert eset;
        
        //SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote',SBQQ__Account__c = acc.Id,SBQQ__Primary__c = true);
        //insert oQuote;
        Opportunity oOpportunity2 = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.Today(), StageName = 'Needs Assessment', EventEdition__c = oEve.Id, AccountId = acc.Id);
        insert oOpportunity2;
        System.assertNotEquals(oOpportunity2,null,'Opportunity should not be null');         
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity2.Id, SBQQ__Account__c = acc.Id, SBQQ__Primary__c = true);
        insert oQuote;
                   
        oOpportunity2.StageName ='Closed Won';
        update oOpportunity2;

        Opportunity oOpportunity3 = new Opportunity(Name = 'Expocad Opportunity',Parent_Opportunity__c =oOpportunity2.Id,  CloseDate = Date.Today(), StageName = 'Closed Won', EventEdition__c = oEve.Id, AccountId = acc.Id, SBQQ__PrimaryQuote__c= oQuote.Id);
        insert oOpportunity3;
        System.assertNotEquals(oOpportunity3,null,'Opportunity should not be null'); 
        
        //oOpportunity2.StageName ='Closed Won';
       // update oOpportunity3;
        
        
        ExpocadBooth__c oExpBooth = new ExpocadBooth__c(Booth_Number__c='17', Area__c='1100',Unit_Type__c='SqFt');
        insert oExpBooth;
        System.assertEquals(oExpBooth.Unit_Type__c,'SqFt','Unit type'); 
        
        CheckStandContractorTabPermissionCC.checkPermission(oEve.Event_Code__c, acc.Id);        
    }    
}