/**
 * File:            Automatically_Assigned_PS_Test 
 * Project:         GAP
 * Date:            02/02/2018
 * Test Class For:  Automatically_Assigned_PS.tgr
 * Code Coverage:   84%
 * Created By:      Rajesh Kumar
 * *************************************************************************
 * Description:     Test class for Automatically_Assigned_PS Trigger.
 * *************************************************************************
 * History:
 */
 
@isTest(seeAlldata = false)
private class Automatically_Assigned_PS_Test {
  @testSetup static void setup() {
    Profile oProfile =[Select id , Name  from Profile where name = 'Sales'];
    User ouser = new User(Alias = 'Test12', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = oProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestclassuserGiriInforma@testorg.com', isactive = true);
    insert ouser;
      System.AssertEquals(ouser.Alias,'Test12','Both values should be the same.');
  }
  
  @isTest static void createUserTestMethod() {
    Set<id> sUserId = new Set<id>();
    string sUserIdname;
    User ouser1 = [Select Id , name from User limit 1];
    sUserId.add(ouser1.Id);
    sUserIdname = ouser1.Name;
    system.debug('sUserIdname' + sUserIdname);
    System.AssertEquals(sUserIdname,'Automated Process','Both values should be the same.');
    //Automatically_Assigned_Handler.AddPermissionSetAssigned (sUserId);
  }
  
}