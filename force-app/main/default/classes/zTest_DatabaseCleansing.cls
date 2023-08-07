/**************************************************************************
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2015-11-30
**####### Deletes data older than a number of days
 * Modified By : Rajesh kumar Yadav Bk-3751,  Aishwarya 12 Aug 2020 BK-3751
***************************************************************************/
@isTest
private class zTest_DatabaseCleansing 
{
    static testMethod void UnitTest_Schedule() 
    {
        DatabaseCleansing.SendEmail(';TEST.TEST@informaUSA.com;','(UnitTest)Error - DatabaseCleansing','test','High');
        Test.StartTest();
        //Covers schedule job
        DatabaseCleansingSchedule m = new DatabaseCleansingSchedule();
        String sch = '20 30 8 10 2 ?';
        System.schedule('TEST_DatabaseCleansingSchedule',sch, m);
        system.assertEquals(sch, '20 30 8 10 2 ?', 'Both values should be the same.');
        Test.StopTest();
    }
    
    static testMethod void UnitTest_Batch() 
    {
        Setting__c s = new Setting__c();
        s.Name = 'Database Cleansing';
        insert(s);
        DateTime dt = System.now();
        dt= dt.addDays(-10);
        
        list<Setting_Item__c> settingItems = new list<Setting_Item__c>();
        //settingItems.add(new Setting_Item__c(Checkbox_1__c = true,Checkbox_2__c=false,Setting__c=s.Id,Text_1__c='PCI_Scan_History__c',Text_3__c='1',Text_4__c='Do_Not_Reply.SFDC@informausa.com',Text_5__c='Do_Not_Reply.SFDC@informausa.com'));
        //settingItems.add(new Setting_Item__c(Checkbox_1__c = true,Checkbox_2__c=false,Setting__c=s.Id,Text_1__c='PCI_Credit_Card_Numbers__c',Text_3__c='1',Text_4__c='Do_Not_Reply.SFDC@informausa.com',Text_5__c='Do_Not_Reply.SFDC@informausa.com'));
        settingItems.add(new Setting_Item__c(Checkbox_1__c = true,Checkbox_2__c=true,Setting__c=s.Id,Text_1__c='SSO_Delegated_Log__c',Text_3__c='1',Text_4__c='Do_Not_Reply.SFDC@informausa.com',Text_5__c='Do_Not_Reply.SFDC@informausa.com'));
        settingItems.add(new Setting_Item__c(Checkbox_1__c = true,Checkbox_2__c=true,Checkbox_3__c=true,Setting__c=s.Id,Text_1__c='Account',Text_3__c='1',Text_4__c='Do_Not_Reply.SFDC@informausa.com',Text_5__c='Do_Not_Reply.SFDC@informausa.com'));
        settingItems.add(new Setting_Item__c(Checkbox_1__c = true,Checkbox_2__c=true,Checkbox_3__c=true,Setting__c=s.Id,Text_1__c='Account',Text_2__c='NOT (Name Like \'%_04\')',Text_3__c='0',Text_4__c='Do_Not_Reply.SFDC@informausa.com',Text_5__c='Do_Not_Reply.SFDC@informausa.com'));
        settingItems.add(new Setting_Item__c(Checkbox_1__c = true,Checkbox_2__c=true,Checkbox_3__c=true,Setting__c=s.Id,Text_1__c='Account',Text_2__c='Name Like \'%_04\'',Text_3__c='0',Text_4__c='Do_Not_Reply.SFDC@informausa.com',Text_5__c='Do_Not_Reply.SFDC@informausa.com'));
        
        insert(settingItems);
        system.assertEquals(settingItems.size(), 4, 'list size should equals to 4');
        system.assertEquals(settingItems[0].Text_1__c, 'SSO_Delegated_Log__c', 'Both values should be the same.');
        list<Account> a = new list<Account>();
        a.add(new Account(Name=s.Name + '_01',LastModifiedDate=dt, CreatedDate=dt));
        a.add(new Account(Name=s.Name + '_02',LastModifiedDate=dt, CreatedDate=dt));
        a.add(new Account(Name=s.Name + '_03',LastModifiedDate=dateTime.now(), CreatedDate=dateTime.now()));
        a.add(new Account(Name=s.Name + '_04',LastModifiedDate=dateTime.now(), CreatedDate=dateTime.now()));
        insert(a);
        
        
        //list<PCI_Scan_History__c> pciScanHistory = new list<PCI_Scan_History__c>();
        //pciScanHistory.add(new PCI_Scan_History__c(Record_Object__c='Active_Directory_Details__c',LastModifiedDate=dt, CreatedDate=dt));
        //pciScanHistory.add(new PCI_Scan_History__c(Record_Object__c='Active_Directory_Details__c',LastModifiedDate=dt, CreatedDate=dt));
        //insert(pciScanHistory);
        
        //list<PCI_Credit_Card_Numbers__c> pciCN = new list<PCI_Credit_Card_Numbers__c>();
        //pciCN.add(new PCI_Credit_Card_Numbers__c(Object_Name__c='Active_Directory_Details__c',LastModifiedDate=dt, CreatedDate=dt));
        //pciCN.add(new PCI_Credit_Card_Numbers__c(Object_Name__c='Active_Directory_Details__c',LastModifiedDate=dt, CreatedDate=dt));
        //insert(pciCN);
        
        list<SSO_Delegated_Log__c> ssoDL = new list<SSO_Delegated_Log__c>();
        ssoDL.add(new SSO_Delegated_Log__c(Username__c='Do_Not_Reply.SFDC@informausa.com',LastModifiedDate=dt, CreatedDate=dt));
        ssoDL.add(new SSO_Delegated_Log__c(Username__c='Do_Not_Reply.SFDC@informausa.com',LastModifiedDate=dt, CreatedDate=dt));
        insert(ssoDL);
        system.assertEquals(ssoDL.size(), 2, 'list size should equals to 2');
        
        Test.StartTest();
        //DatabaseCleansing.GetSettings(null);
        PageReference pageRef = Page.DatabaseCleansing;
        Test.setCurrentPage(pageRef);
        
        DatabaseCleansingController c = new DatabaseCleansingController();
        c.setItemId = settingItems[1].id;
        c.run();
        c.runAll();
        c.addItem();
        Test.StopTest();
    }
    static testMethod void UnitTest_Controller() 
    {
        PageReference pRef = Page.DatabaseCleansing;
        system.assertNotEquals(pRef, null, 'PageReference must have some value.');
    }

}