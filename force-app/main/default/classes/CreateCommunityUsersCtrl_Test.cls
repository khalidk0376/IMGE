/**
 * Created By: Girikon(Sunil)
 * Created On: 02/09/2018
 * Modified by :  
 * Modified On: 
 * Description/Purpose: This test class covers the apex class : CreateCommunityUsersCtrl
 * Apex Class:CreateCommunityUsersCtrl(85%)
**/

@isTest
public class CreateCommunityUsersCtrl_Test
{
    public static testMethod void CreateCommunityUsers() 
    {        
        User_Type__c UType = new User_Type__c(Name ='Exhibitor');
        insert UType;
        System.AssertEquals(UType.Name, 'Exhibitor','Not a Valid Usertype');
                
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'Account should not be null');
        
        Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com', Type__c=UType.Id,AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null,'Contact should not be null');
        set<Id> conIds = new set<Id>();
        conIds.add(con.id);
        
        Event_Edition__c OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert OEve;
            
        CreateCommunityUsersCtrl objcom =new CreateCommunityUsersCtrl();
        objcom.eventId=OEve.Id; 
        objcom.contIds=con.id;
        objcom.contIdsNewUser =Con.id;
        objcom.createUsers();
        objcom.createUsersforExistingMapping();
        objcom.CreateCommunityUser(conIds);
        
        objcom.contIds ='';
        objcom.contIdsNewUser ='';
        objcom.createUsersforExistingMapping();
        objcom.CreateCommunityUser(conIds);
    }
    
    public static testMethod void SendEmailToExistingUser() 
    { 
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'Account should not be null');
        
        User_Type__c UType = new User_Type__c(Name ='Exhibitor');
        insert UType;
        System.AssertEquals(UType.Name, 'Exhibitor','Not a Valid Usertype');
                
        Contact con11 = new Contact(LastName='User1',FirstName ='Test1',email='test2@test.com',Type__c=UType.Id,AccountId = acc.id);
        insert con11;
        System.AssertNotEquals(con11, null,'Contact should not be null');
        
        string commUsrProfile='';
        //Fetch community user profile from label
        If(Label.Community_User_Profile!= NULL) 
            commUsrProfile= Label.Community_User_Profile;
        else
            commUsrProfile='Customer Community Login User Custom';            
        //Fetch community user profile
        Profile p =[select id , Name from Profile Where Name =:commUsrProfile];
        
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, ContactID=con11.id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserjohn11@testorg.com', isactive = FALSE);
        insert u;
            
        Event_Edition__c OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert OEve;
        
        ContactEventEditionMapping__c oMapping = new ContactEventEditionMapping__c(SFContactID__c=con11.id,SFEventEditionID__c=OEve.id);
        insert oMapping;
        
        CreateCommunityUsersCtrl objcom =new CreateCommunityUsersCtrl();
        objcom.contIdsExistingUser = Con11.id;
        objcom.SendEmailtoExistingUsers();
        objcom.contIdsExistingUser ='';
        objcom.SendEmailtoExistingUsers();
    }
    public static testMethod void SendEmailToExistingUser1() 
    { 
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'Account should not be null');
        
        User_Type__c UType = new User_Type__c(Name ='Exhibitor');
        insert UType;
        System.AssertEquals(UType.Name, 'Exhibitor','Not a Valid Usertype');
                
        Contact con11 = new Contact(LastName='User1',FirstName ='Test1',email='test2@test.com',Type__c=UType.Id,AccountId = acc.id);
        insert con11;
        System.AssertNotEquals(con11, null,'Contact should not be null');
        
        string commUsrProfile='';
        //Fetch community user profile from label
        If(Label.Community_User_Profile!= NULL) 
            commUsrProfile= Label.Community_User_Profile;
        else
            commUsrProfile='Customer Community Login User Custom';            
        //Fetch community user profile
        Profile p =[select id , Name from Profile Where Name =:commUsrProfile];
        
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, ContactID=con11.id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserjohn11@testorg.com');
        insert u;
            
        Event_Edition__c OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert OEve;
        
        ContactEventEditionMapping__c oMapping = new ContactEventEditionMapping__c(SFContactID__c=con11.id,SFEventEditionID__c=OEve.id);
        insert oMapping;
        
        CreateCommunityUsersCtrl objcom =new CreateCommunityUsersCtrl();
        objcom.contIdsExistingUser = Con11.id;
        objcom.SendEmailtoExistingUsers();
        objcom.contIdsExistingUser ='';
        objcom.SendEmailtoExistingUsers();
    }
    public static testMethod void CreateUserActions() 
    {        
        User_Type__c UType = new User_Type__c(Name ='Exhibitor');
        insert UType;
        System.AssertEquals(UType.Name, 'Exhibitor','Not a Valid Usertype');
                
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'Account should not be null');
        
        Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com', Type__c=UType.Id,AccountId = acc.id);
        insert con;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User Custom']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,ContactId=con.id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserFirst1@testorg.com', isactive = False);
        insert u;
        
        Event_Edition__c OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert OEve;
        
  
        Form__c oForm = new Form__c(Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today());
        insert oForm;
        Event_Edition_Form__c oEEForm = new Event_Edition_Form__c(Event_Edition__c = OEve.id,Forms__c =oForm.id);
        insert oEEForm;
        System.assertEquals(oEEForm.Event_Edition__c,OEve.id, 'checking Event Id');
        Forms_Permission__c fPermission = new Forms_Permission__c(Event_Edition_Form__c = oEEForm.id, User_Type__c= UType.Id);
        insert fPermission;
        
        //Create manual permission record
        Manual__c man = new Manual__c(Section__c = 123, Name = 'Test Manual',Event_Edition__c=OEve.Id);
        insert man;
        System.assertEquals(man.Event_Edition__c,OEve.id, 'Event Id');
        
        Manuals_Permission__c mPermission = new Manuals_Permission__c(Manuals__c = man.id, User_Type__c= UType.Id);
        insert mPermission;
        System.assertEquals(mPermission.Manuals__c,man.id, 'Manuals Id');
            
        ContactEventEditionMapping__c oMapping = new ContactEventEditionMapping__c(SFContactID__c=con.id,SFEventEditionID__c=OEve.id);
        insert oMapping;
        
        CreateCommunityUsersCtrl objcom =new CreateCommunityUsersCtrl();  
        objcom.contIdsActions=con.id;
        objcom.eventIdActions=OEve.id;
        objcom.CreateUserActions();
    }
}