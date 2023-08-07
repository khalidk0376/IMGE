/*
*Created By Shiv Raghav Girikon
*Date :23/5/2018
*Discription - [GRQ0243070]Test Class for "LookupQueryInsert" trigger. 
* Modified By : Rajesh kumar Yadav Bk-3751
*/

@isTest
public class LookUpQueryInsert_Test {
     
    @isTest public static void testLookupQuery()
    {
        SBQQ__PriceRule__c prcrule = new SBQQ__PriceRule__c();  
        prcrule.Name = 'Test Price Rule';
        prcrule.SBQQ__Active__c = true;        
        prcrule.SBQQ__TargetObject__c = 'Calculator';
        prcrule.SBQQ__ConditionsMet__c = 'All';
        prcrule.CurrencyIsoCode = 'EUR';
        insert prcrule;
        system.assertEquals(prcrule.Name, 'Test Price Rule', 'Both values should be the same.');
        List<SBQQ__LookupQuery__c> lookupqueryrecords = new List<SBQQ__LookupQuery__c>();
        for(Integer i = 0 ; i < 100 ; i++)
        {
          SBQQ__LookupQuery__c lqobj = new SBQQ__LookupQuery__c();
          lqobj.SBQQ__LookupField__c = 'Active__c' ;
          lqobj.SBQQ__PriceRule2__c = prcrule.id;          
          lqobj.SBQQ__Operator__c = 'equals';
          lookupqueryrecords.add(lqobj);            
        }
       insert lookupqueryrecords; 
    }
}