/**
 * @Author      : 
 * @Date        : 
 * Apex Class : 
 * * Modified By : Rajesh kumar Yadav Bk-3751,[Modified By : Aishwarya 12 Aug 2020 BK-3751]
 */
@isTest
public class test_updateContractNumber{
    static testMethod void testMethod1(){
        
        Account acc = new Account();
        acc.name='Test Acc';
        insert acc;
        System.assertEquals(acc.Name, 'Test Acc', 'Both values should be the same.');
        
        Event_Edition__c ee = new Event_Edition__c();
        ee.name = 'test value';
        ee.Payment_Schedule__c = '50-50';
        ee.cutoff_date_1__c = date.today();
        insert ee;
        System.assertEquals(ee.Payment_Schedule__c, '50-50', 'Both values should be the same.');
        
        Opportunity opp = new Opportunity();
        opp.name = 'test opp';
        //opp.Billing_Contact__c = con.id;
        opp.EventEdition__c = ee.id;
        opp.accountid = acc.id;
        opp.Ownerid = userinfo.getuserid();
        opp.stagename = 'Prospecting';
        opp.closeDate = date.today();
        insert opp;
        System.assertEquals(opp.Ownerid, userinfo.getuserid(), 'Owner id equals to Login user');
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote',SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opp.id , SBQQ__Primary__c = true);
        insert oQuote;
        system.assertEquals(oQuote.SBQQ__Status__c, 'Quote', 'Both values should be the same.');        
        Contract con = new Contract();
        con.Status = 'Draft';
        con.accountid = acc.id;
        con.SBQQ__Quote__c = oQuote.id;
        insert con;
        System.assertEquals(con.Status, 'Draft', 'Contract status equals to Draft.');
    } 
}