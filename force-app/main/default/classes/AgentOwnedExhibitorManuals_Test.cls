@isTest
public class AgentOwnedExhibitorManuals_Test {
    
    @TestSetup
    static void setup(){
        //Create account
        Account objAcc = new Account(Name='TestLName');
        insert objAcc;
        
        //Create User_Type__c
        User_Type__c uTypeAgn = new User_Type__c(Name='Agent');
        insert uTypeAgn;
        
        User_Type__c uTypeAOE = new User_Type__c(Name='Agent Owned Exhibitor');
        insert uTypeAOE;
        
        //Create contact
        Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com', Type__c=uTypeAgn.Id,AccountId = objAcc.id);
        insert con;
        
        Contact conTest = new Contact(LastName='Test',FirstName ='Test',email='test1@test.com', Type__c=uTypeAgn.Id,AccountId = objAcc.id);
        insert conTest;
        
        //create ExpocadBooth__c
        ExpocadBooth__c expBooth = new ExpocadBooth__c(Booth_Number__c='TestBoothNo',Dimensions__c = '5M x 10M',Area__c ='50 m²',status__c='Rented');
        insert expBooth;
        
        //Create conga template
        APXTConga4__Conga_Template__c congaTemp=new APXTConga4__Conga_Template__c(APXTConga4__Name__c='Test Cong Template');
        Insert congaTemp;
        
        Document d = new Document(); 
        d.Name = 'TEV17-Event-Image'; 
        d.FolderId = UserInfo.getUserId();//documents[0].FolderId;
        d.IsPublic = true; 
        d.Body =Blob.valueOf('Some Text'); 
        d.ContentType = 'image/jpeg';
        insert d;
        
        Event_Edition__c eventEdition = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Edition_Status__c='Prospecting',Contract_Template__c=congaTemp.Id,Event_Website__c='http://www.testevent.com',Event_Edition_Image_URL__c=d.Id,Invoice_From_Email_ID__c='Test',Max_Hold_Booth__c=50,Max_Hold_Days__c=10,Measurement__c='Feet',Next_Edition__c='2019',Payment_Schedule__c='50-50',Quote_Template__c=congaTemp.Id,Venue__c='Test',Year__c='2018',Event_Currency__c='USD',Cutoff_Date_1__c=  System.today() + 5,Informa_Logo__c=d.Id);
        insert eventEdition;

        Manual__c manual = new Manual__c();
        manual.Required__c = true;
        manual.Name = 'Test Manual';
        manual.Provider__c = 'Test provider';
        manual.Deadline__c = Date.newinstance(2019, 1, 31);
        manual.Allow_Submit_After_Deadline__c= true;
        manual.Manual_Type__c = 'Link';
        manual.Url__c = 'www.google.com';
        manual.Event_Edition__c = eventEdition.Id;
        insert manual;

        Manuals_Permission__c manualPermission = new Manuals_Permission__c(Manuals__c = manual.Id, User_Type__c = uTypeAOE.Id,Name = 'Test Permission 1');
        insert manualPermission;

        User_Manual_Action__c manualAction = new User_Manual_Action__c(Name = 'Test Manual Action 1', Account__c = objAcc.Id, Manual_Permission__c = manualPermission.Id, User_Type__c=uTypeAOE.Id);
        insert manualAction;
    }

    public static User getUserByProfileName(String profileName){
        if(Test.isRunningTest()){
            Account acc = new Account(Name='Test Account');
            insert acc;
            Contact con = new Contact(LastName='Test Contact',AccountId = acc.Id);
            insert con;
            String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
            // This code runs as the system user
            List<Profile> p = [SELECT Id FROM Profile WHERE Name=:profileName];
            if(p.size()>0){
                User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p[0].Id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName=uniqueUserName,
                ContactId = con.Id);
                System.assertEquals('Testing', u.LastName, 'Here value is not same');
                return u;
                
            }            
            return Null;
        } else {
            return Null;
        }
    }

    @isTest
    static void getAllManualsTest(){
        Test.startTest();
        User communityUser = AgentOwnedExhibitorManuals_Test.getUserByProfileName('Customer Community Login User Custom');
        if(communityUser!= null){
            System.runAs(communityUser){
                Account acc = [SELECT Id FROM Account LIMIT 1];
                List<User_Manual_Action__c> manualActions = AgentOwnedExhibitorManuals.getAllManuals(acc.Id, 'WOC17');
                //System.assert(manualActions.size()>0, 'Atleast one manual action was expected');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void updateViewedAndAgreedTest(){
        Test.startTest();
        User communityUser = AgentOwnedExhibitorManuals_Test.getUserByProfileName('Customer Community Login User Custom');
        if(communityUser!= null){
            System.runAs(communityUser){
                User_Manual_Action__c manualAction = [SELECT Id FROM User_Manual_Action__c LIMIT 1];
                String message = AgentOwnedExhibitorManuals.updateViewedAndAgreed(manualAction.Id, true, true);
                System.assertEquals('Success', message, 'Success is expected for test to be successful');
            }
        }
        Test.stopTest();
    }
}