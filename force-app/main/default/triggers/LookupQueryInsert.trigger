/**
 * File:        LookupQueryInsert.apxt
 * Project:     GAP
 * Date:        12/17/2018
 * Created By: Muhammad Bangash
 * Test class: LookUpQueryInsert_Test
 * *************************************************************************
 * Description: [GRQ0243070] Fix for PMoover relted to deprecated field SBQQ_PriceRule__c. 
 *              Upgrade should have dropped it but it did not happen.
 *              This copies PriceRule2 to PriceRule, so that it does not fail while 
 *              cloning.  
 * *************************************************************************
 * History:
 */

trigger LookupQueryInsert on SBQQ__LookupQuery__c (before insert) 
{
   for ( SBQQ__LookupQuery__c slq : Trigger.new)
   {     
      slq.SBQQ__PriceRule__c = slq.SBQQ__PriceRule2__c;     
   }  
}