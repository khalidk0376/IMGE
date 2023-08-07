/**
 * Created/Modified By: Girikon(Pramod)
 * Created On:          7 June 2018
*  @description   : This test class covers the apex class : BatchCreateCommunityUsers
 * Methods: BatchCreateCommunityUsersTest
 * Apex Class: BatchCreateCommunityUsers
 * Last Modified By: Aishwarya/CCEN-454 (11 Nov 2018)
**/

@isTest
public class BatchCreateCommunityUsers_Test
{
    public static testMethod void batchCreateCommunityUsersTest() 
    {  
         //Create exhibitor user type
        User_Type__c uType = new User_Type__c(Name ='Exhibitor');
        insert uType;
        System.AssertEquals(uType.Name, 'Exhibitor','User Type should be inserted');
                
         //Create Account
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'account should not be null');
        
         //Create contact
        Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com', Type__c=uType.Id,AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null,'Contact should not be null');
        set<Id> conIds = new set<Id>();
        conIds.add(con.id);
        
        //Create event edition
        Event_Edition__c eventEdition = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert eventEdition;
        System.AssertNotEquals(eventEdition, null,' Event Edition should not be null');
        
        //Create Event_Settings__c
        Event_Settings__c eventSettings = new Event_Settings__c(Name='Test',About_Show__c='Test',ShowHours1__c='test',Send_Welcome_Email__c =true,Is_Event_Edition_Live__c =true,ShowHours2__c='Test',Branding_Color__c='Black',Link_1__c='http://m.www.google.com/',Is_Stand_Design_Visible__c=True,Is_Stand_Detail_Visible__c=True,Is_SubContractors_Visible__c=True,Is_Amount_Visible__c=True,Link_2__c='http://m.www.google.com/',Link_3__c='http://m.www.google.com/',Link_4__c='http://m.www.google.com/',Link_1_Label__c='TestLink1',Link_2_Label__c='TestLink2',Link_3_Label__c='TestLink3',Link_4_Label__c='TestLink4',FaceBook__c='http://m.www.facebook.com/',LinkedIn__c='http://m.www.linkedin.com/',Twitter__c='http://m.www.Twitter.com/',YouTube__c='http://m.www.youtube.com/',Custom_1_Title__c='CstmTitle',Event_Edition__c=eventEdition.Id,E_Commerce_Title__c='EC Title',Welcome_Stand_Contractor__c='WSC Test',Disable_this_information__c=True);
        insert eventSettings;
        System.AssertNotEquals(eventSettings, null,'Event Settings should not be null');

    
        set<Id> conEEMIds = new set<Id>();
        ContactEventEditionMapping__c cEEMApping= new ContactEventEditionMapping__c();
        cEEMApping.SFContactID__c       = con.id;
        cEEMApping.SFEventEditionID__c  = eventEdition.id;
        cEEMApping.User_Type__c         = uType.id;
        Insert cEEMApping;
        conEEMIds.add(cEEMApping.Id);
        
        
        
        Contact conex = new Contact(LastName='UserEx',FirstName ='TestEx',Type__c=uType.Id, AccountId = acc.id);
        insert conex;
        System.AssertNotEquals(conex, null,'Contact should not be null');
        
        ContactEventEditionMapping__c cEEMApping1 = new ContactEventEditionMapping__c();
        cEEMApping1.SFContactID__c      = conex.id;
        cEEMApping1.SFEventEditionID__c = eventEdition.id;
        cEEMApping1.User_Type__c        = uType.id;
        Insert cEEMApping1;
        
        conEEMIds.add(cEEMApping1.Id);
        
        //Batch class to create community user 
        test.startTest();
        BatchCreateCommunityUsers objbatch= new BatchCreateCommunityUsers(conEEMIds,UtilityMethods.getProfileid().Id);
        Database.executeBatch(objbatch,2); 
        test.stopTest();
    
        //Batch class call to execute exception code
       // BatchCreateCommunityUsers objbatchex= new BatchCreateCommunityUsers(UtilityMethods.getProfileid().Id,conids);
        //Database.executeBatch(objbatchex,1);
    }
}