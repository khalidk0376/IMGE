/**
* File:            AccountCreditStatusHold_Test
* Project:         GAP
* Date:            May 16, 2018
* Test Class For:  AccountCreditStatusHold_Trig Trigger 
* Created By:      Rajesh Kumar
* Modified By:     Adarsh Sharma
* **********************************************************************************************************************************************
* Description:     Test class for Trigger_Account(96%), TriggerInterface_Account(100%), AccountCreditStatusHold_Trig trigger(87%). 
* **********************************************************************************************************************************************
* History:         Test class coverage increased to 87% [BK-3700 (Adarsh)]
*/

@isTest
public class AccountCreditStatusHold_Test
{
    static testMethod  void accountCredtiStatusHold()
    {
        // Create Trigger test record 
        Trigger__c trig = new Trigger__c(Name = 'AccountCreditStatusHold_Trig' , Trigger_Name_Unique__c='AccountCreditStatusHold_Trig',Enabled__c=true,Object__c='Account',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                         After_Update__c=true , Before_Update__c = true);
        Insert trig;
        System.AssertEquals(trig.Name,'AccountCreditStatusHold_Trig','Invalid trigger record');
        
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        System.AssertNotEquals(rt.Enabled__c,false, 'test class failed');
        //Call event edition trigger interface
        AccountCreditStatusHold_Trig obj = new AccountCreditStatusHold_Trig();
        TriggerInterface_Account obj2 = new TriggerInterface_Account();
        
        //Call trigger app handler for insert event
        TriggerInterfaceHelper.runTrigger('AccountCreditStatusHold_Trig','Account',1, 'au', null,null,'All');
        TriggerInterfaceHelper.runTrigger('AccountCreditStatusHold_Trig','Account',1, 'bu', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('AccountCreditStatusHold_Trig');
        
        Account acc = new Account();
        acc.Name = 'Girikon';
        acc.Accounting_Credit_Hold__c = 'Hold';
        acc.CurrencyIsoCode = 'USD';
        acc.Inactive__c = true;
        insert acc;
        System.AssertEquals(acc.Name,'Girikon','Invalid Account');
        
        Contact con = new Contact();
        con.LastName = 'LastName';
        con.AccountId = acc.Id;
        con.Email = 'abc@abc.com';
        insert con;
        System.AssertEquals(con.AccountId,acc.id,'Wrong Account Id');
        
        acc.Accounting_Credit_Hold__c = 'OK';
        update acc;
    }
    static testMethod void myTest() {
        // Create Trigger test record 
        Trigger__c trig = new Trigger__c(Name = 'AccountCreditStatusHold_Trig' , Trigger_Name_Unique__c='AccountCreditStatusHold_Trig',Enabled__c=true,Object__c='Account',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                         After_Update__c=true , Before_Update__c = true);
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        //Call event edition trigger interface
        AccountCreditStatusHold_Trig obj = new AccountCreditStatusHold_Trig();
        
        //Call trigger app handler for insert event
        TriggerInterfaceHelper.runTrigger('AccountCreditStatusHold_Trig','Account',1, 'au', null,null,'All');
        TriggerInterfaceHelper.runTrigger('AccountCreditStatusHold_Trig','Account',1, 'bu', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('AccountCreditStatusHold_Trig');
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.CurrencyIsoCode = 'USD';
        acc.BillingStreet= 'Noida 34';
        acc.BillingCountrycode= 'US';
        acc.BillingState= 'Arizona';
        acc.BillingCity= 'Tempe';
        acc.BillingPostalCode= '201301';
        acc.Accounting_Credit_Hold__c = 'Hold';
        insert acc;
        
        System.AssertEquals(acc.Name,'Test','Invalid Billing Account');
        
        Contact con = new Contact();
        con.Email = 'test@gmail.com';
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.Contact_Type__c = 'Invoice Contact';
        insert con;
        
        acc.BillingCity= 'US';
        acc.IsFromBillingAddress__c = true;
        update acc;
        
        acc.IsFromShippingAddress__c = true;
        acc.Inactive__c = true;
        update acc;
    }
}