/**
 * Project:     GAP
 * Date:        16/07/2018
 * Created By:  Rajesh Kumar
 * Test Class:  OpportunityDuplicateCheckTrigger_Test 
 * *************************************************************************
 * Description:   We have used this class for cancel opportunity and update resonse lost field and we have also sent email to opportuntiy owen after cancel opportuntiy.
 * *************************************************************************
 * History:
 **/
@isTest
public class Cls_cancelOpportunity_Test 
{
    static testMethod void unitTest() {
        Account acc = new Account();
        acc.Name = 'test';
        acc.CurrencyIsoCode = 'USD';
        insert acc;
        System.assertEquals('test', acc.name,'Error account is not created');
        
        Brand__c objbrnd = new Brand__c();
        objbrnd.name = 'test brand';
        objbrnd.SSC_Email_Distribution_ID__c = 'anuj.sahu@girikon.com';
        insert objbrnd;
        
        Event_Series__c objes = new Event_Series__c();
        objes.name = 'test name';
        objes.Brand__c = objbrnd.id;
        objes.Event_Edition_Pool__c = 'WOC';
        insert objes;
        
        Event_Edition__c oEventEdition = new Event_Edition__c (name = 'test' , 
                                                               Part_of_Series__c = objes.id,End_Date__C =date.today()+7, Event_Code__c='KDB,KDB2',
                                                               Approval_Service_Now_ID__c = 'test',Tab1__c ='Test',Tab7__c='test');
        insert oEventEdition;
        
        opportunity opp = new opportunity();
        opp.AccountId = acc.Id;
        opp.EventEdition__c = oEventEdition.id;
        opp.Name ='test';
        opp.CurrencyIsoCode = 'USD';
        opp.CloseDate = System.Today();
        opp.StageName = 'Need Assessment';
        opp.Contract_Attached__c = True;
        insert opp;
        
        ApexPages.currentPage().getParameters().put('id',opp.id);
        cls_cancelOpportunity cls = new cls_cancelOpportunity ();
        cls.redirectPopup(opp.id);
        
    }
}