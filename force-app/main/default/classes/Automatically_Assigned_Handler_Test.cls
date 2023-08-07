/*
Created By: {Girikon(Rajesh Kumar)}
Created On: 02/02/2018
Description/Purpose: Test class for Automatically_Assigned_Handler class 
Methods: getOppBoothDetails
Test Class: Automatically_Assigned_Handler_Test(91%)

Modified By: {Girikon(Amish/Pramod)} ( JIRA # CCEN 380 )
Modified On: 10/11/2018

Modified By: Shiv Raghav Sharma (BK-3234)
Modified On: 31/1/2020
Modified By : Rajesh Kumar (BK-3665)
Modified On : 17/03/2020
*/


@isTest
private class Automatically_Assigned_Handler_Test {    
    @isTest static void FederationIdentifierTest (){
        
        Trigger__c trig = new Trigger__c(Name = 'Automatically_Assigned_PS_Trg' , Trigger_Name_Unique__c='Automatically_Assigned_PS_Trg',Enabled__c=true,Object__c='User',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=1,
                                         After_Insert__c=true , After_Update__c = true);
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        System.AssertEquals(rt.Enabled__c, true, 'true value'); 
        TriggerInterface_user obj=new TriggerInterface_user();
        TriggerInterfaceHelper.runTrigger('Automatically_Assigned_PS_Trg','User', 9, 'ai', null,null,'All');
        TriggerInterfaceHelper.runTrigger('Automatically_Assigned_PS_Trg','User', 9, 'au', null,null,'All');
        Profile oProfile =[Select id , Name  from Profile where name = 'System Administrator' ];
        User ouser = new User(Alias = 'Test253', Email='TestuserGiriinforma@testorg.com', IsActive = true,
                              EmailEncodingKey='UTF-8',FirstName='Testing', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = oProfile.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='TestuserGiriinforma@testorg.com' 
                             );
        insert ouser;
        ouser.FederationIdentifier = 'testtestingclass@gmail.com';
        update ouser;
        System.AssertNotEquals(ouser.FederationIdentifier, null, 'test class method failed');
        PermissionSet ps = [SELECT ID, Label From PermissionSet WHERE Label = 'DocuSign User' limit 1];
        // Create PermissionSet with Custom Permission and assign to test user
        Permission_Set_Mapping__c oPermission_Set_Mapping = new Permission_Set_Mapping__c(Permission_Set__c = ps.Label , Profile__c = oProfile.Name);
        insert oPermission_Set_Mapping;
  
   }
    @isTest static void FederationIdentifierDELTest (){
        
        Trigger__c trig = new Trigger__c(Name = 'Automatically_Assigned_PS_Trg' , Trigger_Name_Unique__c='Automatically_Assigned_PS_Trg',Enabled__c=true,Object__c='User',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=1,
                                         After_Insert__c=true , After_Update__c = true);
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt; 
        TriggerInterface_user obj=new TriggerInterface_user();
        TriggerInterfaceHelper.runTrigger('Automatically_Assigned_PS_Trg','User', 9, 'ai', null,null,'All');
        TriggerInterfaceHelper.runTrigger('Automatically_Assigned_PS_Trg','User', 9, 'au', null,null,'All');
        Profile oProfile =[Select id , Name  from Profile where name = 'System Administrator' ];
        User ouser = new User(Alias = 'Test253', Email='TestuserGiriinforma@testorg.com', IsActive = true,
                              EmailEncodingKey='UTF-8',FirstName='Testing', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = oProfile.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='TestuserGiriinforma@testorg.com' ,FederationIdentifier = 'testtestingclass@gmail.com'
                             );
        insert ouser;
        ouser.FederationIdentifier = '';
        update ouser;
         System.AssertNotEquals(ouser.FederationIdentifier, 'Test@gail.com', 'test class method failed');
        PermissionSet ps = [SELECT ID, Label From PermissionSet WHERE Label = 'DocuSign User' limit 1];
        // Create PermissionSet with Custom Permission and assign to test user
        Permission_Set_Mapping__c oPermission_Set_Mapping = new Permission_Set_Mapping__c(Permission_Set__c = ps.Label , Profile__c = oProfile.Name);
        insert oPermission_Set_Mapping;
   }
    @isTest static void updateContactOnUser(){
        Trigger__c trig = new Trigger__c(Name = 'Automatically_Assigned_PS_Trg' , Trigger_Name_Unique__c='Automatically_Assigned_PS_Trg',Enabled__c=true,Object__c='User',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=1,
                                         After_Insert__c=true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt; 
        TriggerInterface_user obj=new TriggerInterface_user();
        TriggerInterfaceHelper.runTrigger('Automatically_Assigned_PS_Trg','User', 1, 'ai', null,null,'All');
        Account acc = new account();
        acc.Name = 'TestLName';
        insert acc;
        System.AssertNotEquals(acc, null, 'Error Account Not Created');
        
        Contact con = new Contact();
        con.LastName = 'User';
        con.FirstName = 'Test';
        con.AccountId = acc.id;
        insert con;
        System.AssertNotEquals(con, null, 'Error Contact Not Created');
        
        Profile oProfile =[Select id , Name  from Profile where name = 'Customer Community Login User Custom'];
        User ouser = new User(Alias = 'Test253', Email='Testinforma@testorg.com', 
                              EmailEncodingKey='UTF-8',FirstName='Testing', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = oProfile.Id, contactID=con.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='Testinforma@testorg.com');
        insert ouser;
    }
}