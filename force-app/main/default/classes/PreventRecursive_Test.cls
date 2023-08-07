/**
* Created/Modified By: Girikon(Sunil)
* Created On:          7/1/2018
* Description/Purpose: This test class covers the apex class:PreventRecursive 
* Apex Class:          PreventRecursive
**/
@isTest
public class PreventRecursive_Test {
    static testMethod void test(){
        boolean result =PreventRecursive.runOnceCreate();
        System.assertNotEquals(result,null,'Expected true on first run');      
       PreventRecursive.runOnceCreate();       
    }    
}