/**
 * Created/Modified By  : Mahesh (Girikon)
 * Created On:          : June 12 2019
 * @description         : [ This test class covers the apex class : RegistrationHandler]
 * Modification log --
 * Modified By          :
**/
//Ticket No. BK-14521 Updating API Version
@isTest
private class RegistrationHandlerTest {
 
  private static void setupData(){
    TestUtility.createSiteBranding('Informa', 'Informa', 'Informa', 'Informa Markets Identity', true);
  }
   
 /* @isTest static void createEntitledUsersTest(){
 
    // Create site branding data
    setupData();
 
    Account acc = TestUtility.createTestAccount(true, 'TestAcc');
    Contact con = TestUtility.createTestContact(false, 'Joe', 'bloggs', acc.Id);
    con.Email = 'apex.unit.test@registration.com';
    insert con;
    Opportunity opp = TestUtility.createTestOpportunity(true, 'Initiating', acc.Id);
     
    // Create CS Service data
    Map<Id, csord__Service__c> serviceMap = TestUtility.createCSData(acc.Id, opp.Id);
    csord__Service__c service = serviceMap.values().get(0);
 
    csord__Order__c order = new csord__Order__c(
      csord__Account__c = acc.Id,
      csord__Identification__c = '123'
    );
    insert order;
 
    Id productServiceRecTypeId = Utility.getRecordTypeByName('Product Service', 'csord__Service__c');
    service.RecordTypeId = productServiceRecTypeId;
    service.csord__Order__c = order.Id;
    service.Purchased_Licences__c = 1;
    service.Registration_Method__c = 'Site Licence';
    update service;
 
    csord__Service__c servTest = [SELECT ID, Name, Status__c FROM csord__Service__c where Id = :service.Id];
    System.debug('Service_Status: ' + servTest.Status__c);
 
        //IP range correction because of changes in validation, reserved IP range excluded. IEP-597, Zarko Ament
    IP_Range__c ipRange = new IP_Range__c(
      Account_ID__c = acc.id,
      IP_Range_To__c = '199.168.1.1',
      IP_Range_From__c = '199.168.1.1',
      IP_Type__c = 'Single',
      IP_Version__c = 'IPV4',
      Active__c = true
    );
    insert ipRange;
 
    Service_IP_Range__c srvIpRange = new Service_IP_Range__c(
      Active__c = true,
      IP_Range_ID__c = ipRange.Id,
      Service_ID__c = service.Id,
      Type__c = 'Site Licence'
    );
    insert srvIpRange;
 
    User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' AND IsActive = true LIMIT 1];
 
    Test.setCurrentPage(Page.Registration);
 
    User communityUser  = new User(alias = 'communit', Email = con.Email,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_US', ProfileId = CommunityUtility.getCommunityUserProfile('End User').Id,
                                    timezonesidkey='America/Los_Angeles', username= con.Email, ContactId = con.id, Self_Registration_IP_Address__c = '199.168.1.1');
    insert communityUser;
 
    System.runAs(guestSiteUser){
 
      CommunityBaseController controller = new CommunityBaseController();
 
      // Get matching account data first
      Id accountId = RegistrationHandler.getMatchingAccountId(communityUser.Self_Registration_IP_Address__c, communityUser.Username);
       
      RegistrationHandler.runPostRegistrationLogic(communityUser.Id);
    }
 
    System.assertEquals(1, [SELECT COUNT() FROM Entitled_User__c WHERE Active__c = true AND Service_ID__c = :service.Id]);
    //System.assertEquals(acc.Id, [SELECT AccountId FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id = :communityUser.Id) LIMIT 1].AccountId);
  }
 
  @isTest static void getMatchingAccountIdTest(){
 
    // Create site branding data
    setupData();
 
    Account acc = TestUtility.createTestAccount(true, 'Vertical Account');
    Contact con = TestUtility.createTestContact(false, 'Joe', 'bloggs', acc.Id);
    con.Email = 'apex.unit.test@registration.com';
    insert con;
     
    // Create CS Service data
    Account ipAccount = TestUtility.createTestAccount(true, 'IP Account');
    Opportunity opp = TestUtility.createTestOpportunity(true, 'Initiating', ipAccount.Id);
    Map<Id, csord__Service__c> serviceMap = TestUtility.createCSData(acc.Id, opp.Id);
    csord__Service__c service = serviceMap.values().get(0);
 
    csord__Order__c order = new csord__Order__c(
      csord__Account__c = ipAccount.Id,
      csord__Identification__c = '123'
    );
    insert order;
 
    Id productServiceRecTypeId = Utility.getRecordTypeByName('Product Service', 'csord__Service__c');
    service.RecordTypeId = productServiceRecTypeId;
    service.csord__Order__c = order.Id;
    service.Purchased_Licences__c = 1;
    service.Registration_Method__c = 'Site Licence';
    update service;
 
        //IP range correction because of changes in validation, reserved IP range excluded. IEP-597, Zarko Ament
    IP_Range__c ipRange = new IP_Range__c(
      Account_ID__c = ipAccount.id,
      IP_Range_To__c = '199.168.1.1',
      IP_Range_From__c = '199.168.1.1',
      IP_Type__c = 'Single',
      IP_Version__c = 'IPV4',
      Active__c = true
    );
    insert ipRange;
 
    Service_IP_Range__c srvIpRange = new Service_IP_Range__c(
      Active__c = true,
      IP_Range_ID__c = ipRange.Id,
      Service_ID__c = service.Id,
      Type__c = 'Site Licence'
    );
    insert srvIpRange;
 
    User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' AND IsActive = true LIMIT 1];
 
    User communityUser  = new User(alias = 'communit', Email = con.Email,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_US', ProfileId = CommunityUtility.getCommunityUserProfile('End User').Id,
                                    timezonesidkey='America/Los_Angeles', username= con.Email, ContactId = con.id, Self_Registration_IP_Address__c = '199.168.1.1');
    insert communityUser;
 
    System.runAs(guestSiteUser){
      Id accountId = RegistrationHandler.getMatchingAccountId(communityUser.Self_Registration_IP_Address__c, communityUser.Username);
      System.assertEquals(accountId, ipAccount.Id);
    }
  }
 
  @isTest static void registerUserEmailDomainEntitle() {
    // Create site branding data
    setupData();
 
    Account acc = TestUtility.createTestAccount(true, 'Vertical Account');
    Contact con = TestUtility.createTestContact(false, 'Joe', 'bloggs', acc.Id);
    con.Email = 'apex.unit.test@registration.com';
    insert con;
     
    // Create CS Service data
    Account ipAccount = TestUtility.createTestAccount(true, 'IP Account');
    Opportunity opp = TestUtility.createTestOpportunity(true, 'Initiating', ipAccount.Id);
    Map<Id, csord__Service__c> serviceMap = TestUtility.createCSData(acc.Id, opp.Id);
    csord__Service__c service = serviceMap.values().get(0);
 
    csord__Order__c order = new csord__Order__c(
      csord__Account__c = ipAccount.Id,
      csord__Identification__c = '123'
    );
    insert order;
 
    Id productServiceRecTypeId = Utility.getRecordTypeByName('Product Service', 'csord__Service__c');
    service.RecordTypeId = productServiceRecTypeId;
    service.csord__Order__c = order.Id;
    service.Purchased_Licences__c = 1;
    service.Registration_Method__c = 'Email Domain';
    update service;
 
    Email_Domain__c eDomain = new Email_Domain__c(
      Name     = 'registration.com',
      Account__c   = acc.Id);
    insert eDomain;
 
    Service_Email_Domain__c servEDomain = new Service_Email_Domain__c(
      Service__c     = service.Id,
      Email_Domain__c = eDomain.Id,
      Active__c     = TRUE);
    insert servEDomain;
 
    User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' AND IsActive = true LIMIT 1];
 
    User communityUser  = new User(alias = 'communit', Email = con.Email,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_US', ProfileId = CommunityUtility.getCommunityUserProfile('End User').Id,
                                    timezonesidkey='America/Los_Angeles', username= con.Email, ContactId = con.id, Self_Registration_IP_Address__c = '199.168.1.1');
    insert communityUser;
 
    System.runAs(guestSiteUser){
      Id accountId = RegistrationHandler.getMatchingAccountId(communityUser.Self_Registration_IP_Address__c, communityUser.Username);
      RegistrationHandler.runPostRegistrationLogic(communityUser.Id);
    }
  }
 
  @isTest static void getMatchingAccountIdTestWithIpAndEmailDomain(){
 
    // Create site branding data
    setupData();
 
    Account acc = TestUtility.createTestAccount(true, 'Vertical Account');
    Contact con = TestUtility.createTestContact(false, 'Joe', 'bloggs', acc.Id);
    con.Email = 'apex.unit.test@registration.com';
    insert con;
     
    // Create CS Service data
    Account ipAccount = TestUtility.createTestAccount(true, 'IP Account');
    Opportunity ipOpp = TestUtility.createTestOpportunity(true, 'Initiating', ipAccount.Id);
    Map<Id, csord__Service__c> serviceMap = TestUtility.createCSData(ipAccount.Id, ipOpp.Id);
    csord__Service__c service = serviceMap.values().get(0);
 
    csord__Order__c order = new csord__Order__c(
      csord__Account__c = ipAccount.Id,
      csord__Identification__c = '123'
    );
    insert order;
 
    Id productServiceRecTypeId = Utility.getRecordTypeByName('Product Service', 'csord__Service__c');
    service.RecordTypeId = productServiceRecTypeId;
    service.csord__Order__c = order.Id;
    service.Purchased_Licences__c = 10;
    service.Registration_Method__c = 'Any';
    update service;
 
    //IP range correction because of changes in validation, reserved IP range excluded. IEP-597, Zarko Ament
    IP_Range__c ipRange = new IP_Range__c(
      Account_ID__c = ipAccount.id,
      IP_Range_To__c = '199.168.1.1',
      IP_Range_From__c = '199.168.1.1',
      IP_Type__c = 'Single',
      IP_Version__c = 'IPV4',
      Active__c = true
    );
    insert ipRange;
 
    Service_IP_Range__c srvIpRange = new Service_IP_Range__c(
      Active__c = true,
      IP_Range_ID__c = ipRange.Id,
      Service_ID__c = service.Id,
      Type__c = 'Site Licence'
    );
    insert srvIpRange;
 
    // Create CS Service data
    Account eDomainAccount = TestUtility.createTestAccount(true, 'Email Domain Account');
    Opportunity emailOpp = TestUtility.createTestOpportunity(true, 'Initiating', eDomainAccount.Id);
    Map<Id, csord__Service__c> emailServiceMap = TestUtility.createCSData(eDomainAccount.Id, emailOpp.Id);
    csord__Service__c emailService = emailServiceMap.values().get(0);
 
    emailService.Purchased_Licences__c = 10;
    emailService.Registration_Method__c = 'Any';
    update emailService;
 
        Email_Domain__c eDomain = new Email_Domain__c(
      Name     = 'registration.com',
      Account__c   = eDomainAccount.Id);
    insert eDomain;
 
    Service_Email_Domain__c servEDomain = new Service_Email_Domain__c(
      Service__c     = emailService.Id,
      Email_Domain__c = eDomain.Id,
      Active__c     = TRUE);
    insert servEDomain;
 
    User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' AND IsActive = true LIMIT 1];
 
    User communityUser  = new User(alias = 'communit', Email = con.Email,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_US', ProfileId = CommunityUtility.getCommunityUserProfile('End User').Id,
                                    timezonesidkey='America/Los_Angeles', username= con.Email, ContactId = con.id, Self_Registration_IP_Address__c = '199.168.1.1');
    insert communityUser;
 
    System.runAs(guestSiteUser){
 
      Id accountId = RegistrationHandler.getMatchingAccountId(communityUser.Self_Registration_IP_Address__c, communityUser.username);
       
      // Assert email domain takes presidence for account
      System.assertEquals(accountId, eDomainAccount.Id);
 
      RegistrationHandler.runPostRegistrationLogic(communityUser.Id);
 
      // Assert user was entitled to both IP and Email Domain services
      System.assertEquals(2, [SELECT COUNT() FROM Entitled_User__c WHERE Active__c = true AND User_ID__c = :communityUser.Id]);
    }
  }
 
  @isTest static void getMatchingAccountIdTestWithEmailDomain(){
 
    // Create site branding data
    setupData();
 
    Account acc = TestUtility.createTestAccount(true, 'Vertical Account');
    Contact con = TestUtility.createTestContact(false, 'Joe', 'bloggs', acc.Id);
    con.Email = 'apex.unit.test@registration.com';
    insert con;
     
    // Create CS Service data
    Account eDomainAccount = TestUtility.createTestAccount(true, 'Email Domain Account');
    Opportunity opp = TestUtility.createTestOpportunity(true, 'Initiating', eDomainAccount.Id);
    Map<Id, csord__Service__c> serviceMap = TestUtility.createCSData(eDomainAccount.Id, opp.Id);
    csord__Service__c service = serviceMap.values().get(0);
 
    csord__Order__c order = new csord__Order__c(
      csord__Account__c = eDomainAccount.Id,
      csord__Identification__c = '123'
    );
    insert order;
 
    Id productServiceRecTypeId = Utility.getRecordTypeByName('Product Service', 'csord__Service__c');
    service.RecordTypeId = productServiceRecTypeId;
    service.csord__Order__c = order.Id;
    service.Purchased_Licences__c = 10;
    service.Registration_Method__c = 'Email Domain';
    update service;
 
        Email_Domain__c eDomain = new Email_Domain__c(
      Name     = 'registration.com',
      Account__c   = eDomainAccount.Id);
    insert eDomain;
 
    Service_Email_Domain__c servEDomain = new Service_Email_Domain__c(
      Service__c     = service.Id,
      Email_Domain__c = eDomain.Id,
      Active__c     = TRUE);
    insert servEDomain;
 
    User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' AND IsActive = true LIMIT 1];
 
    System.runAs(guestSiteUser){
      Id accountId = RegistrationHandler.getMatchingAccountId('199.168.1.1', con.Email);
      System.assertEquals(accountId, eDomainAccount.Id);
    }
  } */
 
  @isTest static void generateCommunityNicknameTest1(){
     
    Account acc = TestUtility.createTestAccount(true, 'Vertical Account');
    Profile endUserPrfl= [Select Id,Name From Profile Where Name='Informa Markets Identity' Limit 1];  
    User communityUser  = new User(alias = 'communit', Email = 'apex.unit.test@registration.com',
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_US', ProfileId = endUserPrfl.Id,
                                    timezonesidkey='America/Los_Angeles', username= 'apex.unit.test@registration.com');
     
    String nickname = RegistrationHandler.generateCommunityNickname(communityUser);
    System.assert(String.isNotBlank(nickname),'It should be return nickname');
    System.assert(nickname.containsIgnoreCase(communityUser.LastName),'It should be return lastname');
    System.assert(nickname.length() <= 40,'nickname length should be <=40');
  }
 
  @isTest static void generateCommunityNicknameTest2(){
     
    Account acc = TestUtility.createTestAccount(true, 'Vertical Account');
    Contact con = TestUtility.createTestContact(false, 'Joe', 'bloggs', acc.Id);
    con.Email = 'apex.unit.test@registration.com';
    insert con;
    Profile endUserPrfl= [Select Id,Name From Profile Where Name='Informa Markets Identity' Limit 1];  
    User communityUser  = new User(alias = 'communit', Email = con.Email,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_US', ProfileId = endUserPrfl.Id,
                                    timezonesidkey='America/Los_Angeles', username= con.Email, ContactId = con.id);
    insert communityUser;
 
    String nickname = RegistrationHandler.generateCommunityNickname(communityUser);
    System.assert(String.isNotBlank(nickname),'It should be return nickname');
    System.assert(nickname.startsWithIgnoreCase(communityUser.ContactId),'It should be return lastname');
    System.assert(nickname.length() <= 40,'nickname length should be <=40');
  }
 
  @isTest static void generateCommunityNicknameTest3(){
     
    Account acc = TestUtility.createTestAccount(true, 'Vertical Account');
    Profile endUserPrfl= [Select Id,Name From Profile Where Name='Informa Markets Identity' Limit 1]; 
    User communityUser  = new User(alias = 'communit', Email = 'apex.unit.test@registration.com',
                                    emailencodingkey='UTF-8', lastname='Testing_with_a_very_long_name_above_40_Characters', languagelocalekey='en_US',
                                    localesidkey='en_US', ProfileId = endUserPrfl.Id,
                                    timezonesidkey='America/Los_Angeles', username= 'apex.unit.test@registration.com');
     
    String nickname = RegistrationHandler.generateCommunityNickname(communityUser);
    System.assert(String.isNotBlank(nickname),'It should be return nickname');
    System.assert(nickname.length() <= 40,'nickname length should be <=40');
    String address = RegistrationHandler.getUserIpAddress(); 
  }
 
 
 /*@isTest static void validateInternalUserRegistration_Test(){
 
    for(Internal_End_User_Registration_Domain__mdt domain : [SELECT Email_Domain__c FROM Internal_End_User_Registration_Domain__mdt WHERE Active__c = true]){
     
      System.assertEquals(false, RegistrationHandler.validateInternalUserRegistration('test@' + domain.Email_Domain__c));
      System.assertEquals(false, RegistrationHandler.validateInternalUserRegistration('test@' + domain.Email_Domain__c.toLowerCase()));
      System.assertEquals(false, RegistrationHandler.validateInternalUserRegistration('test@' + domain.Email_Domain__c.toUpperCase()));
      System.assertEquals(true, RegistrationHandler.validateInternalUserRegistration('test@' + domain.Email_Domain__c + RegistrationHandler.internalUserSuffix));
      System.assertEquals(true, RegistrationHandler.validateInternalUserRegistration('test@' + domain.Email_Domain__c.toLowerCase() + RegistrationHandler.internalUserSuffix));
      System.assertEquals(true, RegistrationHandler.validateInternalUserRegistration('test@' + domain.Email_Domain__c.toUpperCase() + RegistrationHandler.internalUserSuffix));
      System.assertEquals(false, RegistrationHandler.validateInternalUserRegistration('test@' + domain.Email_Domain__c + '.badsuffix'));
      System.assertEquals(false, RegistrationHandler.validateInternalUserRegistration('test@' + domain.Email_Domain__c.toLowerCase() + '.badsuffix'));
      System.assertEquals(false, RegistrationHandler.validateInternalUserRegistration('test@' + domain.Email_Domain__c.toUpperCase() + '.badsuffix'));
    }
 
    System.assertEquals(true, RegistrationHandler.validateInternalUserRegistration('test@test.com'));
    System.assertEquals(true, RegistrationHandler.validateInternalUserRegistration('test@TEST.com'));
    System.assertEquals(true, RegistrationHandler.validateInternalUserRegistration('test@TEST.com.123'));
  }*/
}