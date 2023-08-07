@isTest
public class Tst_btch_updateAssociation{
    static testMethod void method1(){
        Account acc = new Account();
        acc.name = 'Test Account';
        insert acc;
        System.assertNotEquals('Test Account', acc.Id,'Account Id should not be null');
        
        Account_Associations__c accAsc = new Account_Associations__c();
        accAsc.Association_ID__c  = '12345';
        accAsc.Member_Status__c = 'A';
        accAsc.Expiry_Date__c = Date.today();
        insert accAsc;
        
        Association_List__c assLst = new Association_List__c();
        asslst.Exhibitor_Account_Name__c = acc.name;
        asslst.Association_ID__c  = '12345';       
        insert asslst;
        
        btch_updateAssociation obj = new btch_updateAssociation();
        DataBase.executeBatch(obj);

        schedulerUpdateAssociation sh1 = new schedulerUpdateAssociation();
        schedulerUpdateAssociation.updateAssociations();
        String sch = '0 0 23 * * ?'; system.schedule('Association Update', sch, sh1); 
        
    }
    
    static testMethod void method2(){
        Account acc = new Account();
        acc.name = 'Test Account';
        acc.BillingCountry= 'India';
        acc.BillingCity = 'Noida';
        acc.BillingState = 'Uttar Pradesh';
        acc.BillingPostalCode = '201301';
        insert acc;
        System.assertNotEquals('Test Account', acc.Id,'Account Id should not be null');
        
        Account_Associations__c accAsc = new Account_Associations__c();
        accAsc.Association_ID__c  = '12345';
        accAsc.Member_Status__c = 'A';
        accAsc.Expiry_Date__c = Date.today();
        insert accAsc;
        
        Association_List__c assLst = new Association_List__c();
        asslst.Exhibitor_Account_Name__c = acc.name;
        asslst.Association_ID__c  = '123456789';
        asslst.City__c = 'Noida';
        asslst.Country_Region__c = 'India';
        asslst.Expiry_Date__c = Date.newInstance(2020, 01, 24);
        insert asslst;
              
        btch_updateAssociation obj = new btch_updateAssociation();
        DataBase.executeBatch(obj);

        schedulerUpdateAssociation sh1 = new schedulerUpdateAssociation();
        schedulerUpdateAssociation.updateAssociations();
        String sch = '0 0 23 * * ?'; system.schedule('Association Update 2', sch, sh1); 
        
    }
}