/**
 * Created/Modified By: Girikon(Shashank) [CCEN-341]
 * Created On:          09/26/2018   
 * @description : This test class covers the apex class : AddCustomerProductCategoryLtngCtrl
 * Methods:             
 * Apex Class:          AddCustomerProductCategoryLtngCtrl (84%)

 * Modification Log---
 * Modified By:         Girikon(Sunil) [CCEN-744 April 19 2019]
**/
@isTest
public class AddCustomerProductCategoryLtngCtrl_Test
{
       //SetUp data for test class
       @isTest static void addCustomerProductCategoryLtngCtrl() {
        
        //Create user
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User[] userList = new User[]{};
            User usr = new User();
        
        usr.FirstName = 'Alex';
        usr.LastName = 'Sherwood';
        usr.Email = 'test@wexeurope.com';
        usr.Username = 'astest@wexeurope.com';
        usr.Alias = 'astest';
        usr.ProfileId = pro.Id;
        usr.TimeZoneSidKey    = 'America/Denver';
        usr.LocaleSidKey      = 'en_US';
        usr.EmailEncodingKey  = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        userList.add(usr);
        insert userList;
        System.assertNotEquals(null, userList[0].Id, 'userList must not be null');
        
        //Create User_Type__c
        User_Type__c oUT = new User_Type__c(Name='Stand Contractor');
        insert oUT;
        
        //Create Account
        List<Account> accounts = new List<Account>();
        for(Integer i=0;i<3;i++)
        {
            Account acc = new Account(Name='TestAcc' + i);
            accounts.add(acc);    
        }
        insert accounts;
        
        //create some contacts
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0;i<3;i++)
        {
            Contact con = new Contact(AccountId = accounts[i].Id, FirstName = 'TestConFirst'+i, LastName = 'TestConLast'+i, Email='abc@test.com', MobilePhone = '2121212145');
            contacts.add(con);    
        }
        insert contacts;

        //create Event_Edition__c
        List<Event_Edition__c> lstEE = new List<Event_Edition__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Edition__c evtedtn = new Event_Edition__c(Name='TestName'+i,Event_Currency__c='USD',Event_Code__c='XYZ');
            lstEE.add(evtedtn);  
        }
        insert lstEE; 

        List<Opportunity> opps = new List<Opportunity>();
        for(Integer i=0;i<3;i++)
        {
            Opportunity op = new Opportunity(Name='Testopp'+i,EventEdition__c = lstEE[0].id,AccountId=accounts[0].id,CloseDate=date.today()+19,Opportunity_Contact__c=contacts[0].id, StageName='Closed Won');
            opps.add(op);
        }
        insert opps;

        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = accounts[0].Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = opps[0].Id;
        qtObj.CurrencyIsoCode='BRL';
        insert qtObj;

        //create ExpocadBooth__c
        List<ExpocadBooth__c> lstExpoBooth = new List<ExpocadBooth__c>();
        for(Integer i=0;i<3;i++)
        {
            ExpocadBooth__c eB = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.'+i, status__c = 'Rented');
            lstExpoBooth.add(eB);   
        }
        insert lstExpoBooth;

        //Create Opportunity_ExpoCAD_Booth_Mapping__c [CCEN-744]
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = accounts[0].Id, Badge_Limit__c = 2, status__c = 'Active', quote__c=qtObj.Id, Expocad_Booth__c = lstExpoBooth[0].Id, Primary_Contact__c = contacts[0].id);
        insert oppExpoBoothMapping;

        //create Levels_Master__c
        Levels_Master__c  lvlMstr = new Levels_Master__c (Level_Name__c='product', LevelValue__c='product' ); 
        insert lvlMstr;
        
        //create Event_Edition_Product_Category_Mapping__c
        Event_Edition_Product_Category_Mapping__c evtEdnPrdctCatMapp = new Event_Edition_Product_Category_Mapping__c (Event_Edition__c=lstEE[0].id,Levels_Master__c=lvlMstr.id);
        insert evtEdnPrdctCatMapp;
        
        //create Customer_Product_Category__c
        Customer_Product_Category__c  cstmrPrdctCtgry = new Customer_Product_Category__c(Account__c=accounts[0].id, Contact__c=contacts[0].id,Event_Edition__c=lstEE[0].id,Event_Edition_Product_Category_Mapping__c=evtEdnPrdctCatMapp.id,
                                                                                         ExpocadBooth__c=lstExpoBooth[0].id, Opp_Booth_Mapping__c = oppExpoBoothMapping.id, User__c=userList[0].id );
        
        //create Product2
        Product2 prd = new Product2(Name = 'Booth Package WOC',Family = 'Booth',Number_of_Corners__c = 0,Booth_Type__c='esc', Show_In_Show__c='Indoor', Booth_Class__c='fsdf', Event_Edition_Pool__c = 'WOC', Event_Edition__c = lstEE[0].id);
        insert prd; 
        
        //create Profile_Package_Setting__c
        List<Profile_Package_Setting__c> lstprflPckgSetting = new  List<Profile_Package_Setting__c>();
        for(Integer i=0;i<1;i++)
        {
             Profile_Package_Setting__c prflPckgSetting = new Profile_Package_Setting__c(Name='Profile'+i, Event_Edition__c=lstEE[0].id,Product__c=prd.id,Product_Categories__c=56,Is_Default__c=true);
             lstprflPckgSetting.add(prflPckgSetting);
        }
        insert lstprflPckgSetting;     
     
        //create User_Package__c
        User_Package__c usrP = new User_Package__c(Name='Text',Account__c=accounts[0].id, Event_Edition__c=lstEE[0].id, Profile_Package_Setting__c=lstprflPckgSetting[0].id);
        insert usrP;
        //create Customer_Product_Sub_Category__c
        Customer_Product_Sub_Category__c cstmrPrdctSbCtgry = new Customer_Product_Sub_Category__c(Account__c=accounts[0].id,Contact__c=contacts[0].id,ExpocadBooth__c=lstExpoBooth[0].id, Opp_Booth_Mapping__c = oppExpoBoothMapping.Id,Event_Edition__c=lstEE[0].id);
        //create Event_Edition_Sub_Category_Mapping__c 
        List<Event_Edition_Sub_Category_Mapping__c> evntEdtnSbCatgryMapping = new List<Event_Edition_Sub_Category_Mapping__c>();
        Event_Edition_Sub_Category_Mapping__c evntEdtnSbCatgryMapp = new Event_Edition_Sub_Category_Mapping__c (Event_Edition__c=lstEE[0].id,Event_Edition_Product_Category_Mapping__c=evtEdnPrdctCatMapp.id,Levels_Master__c=lvlMstr.id);
        insert evntEdtnSbCatgryMapp;             
        //Create Customer_Product_Category__c
         Customer_Product_Category__c cstmrProCtgry = new Customer_Product_Category__c(Account__c=accounts[0].id,Contact__c=contacts[0].id,Event_Edition__c=lstEE[0].id,Event_Edition_Product_Category_Mapping__c=evtEdnPrdctCatMapp.id,
                                        ExpocadBooth__c=lstExpoBooth[0].id, Opp_Booth_Mapping__c = oppExpoBoothMapping.id);
          insert cstmrProCtgry;                                 
        //Create Customer_Product_Sub_Category__c   
         Customer_Product_Sub_Category__c    cstmrProSbCtgry = new Customer_Product_Sub_Category__c(Account__c=accounts[1].id,Contact__c=contacts[1].id,Event_Edition__c=lstEE[1].id,
                                           Customer_Product_Category__c=cstmrProCtgry.id );
        
        insert cstmrProSbCtgry; 
           
           Event_Edition__c oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',Event_Edition_Code__c ='test',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Currency__c='USD');
           insert oEve;
           
           Event_Settings__c eset = new Event_Settings__c();
           eset.Name ='event Setting Test';
           eset.Event_Edition__c = oEve.Id;
           eset.Branding_Color__c = 'yellow';
           eset.Badge_FName_Character_Limit__c = 5;            
           eset.Badge_LName_Character_Limit__c = 2;
           eset.Badge_JobTitle_Character_Limit__c = 25;
           eset.Badge_Email_Character_Limit__c = 10;
           eset.Badge_Mobile_Character_Limit__c = 2;
           eset.Badge_City_Character_Limit__c = 2;
           eset.Badge_Address_Character_Limit__c = 9;
           eset.Company_Name_on_Badge_Character_Limit__c = 9;
           eset.Allotment_By_Booth_Type__c = false;
           eset.Allotment_By_Booth_Size__c = true;
           eset.Allow_VIP_Badges__c=true;
           insert eset;
           
        
        Test.startTest();
        
        AddCustomerProductCategoryLtngCtrl  addCustomerProductCategoryLtng = new AddCustomerProductCategoryLtngCtrl();
        AddCustomerProductCategoryLtngCtrl.fetchClassValue(lstEE[0].id,accounts[0].id,userList[0].id,contacts[0].id,oppExpoBoothMapping.id);
        AddCustomerProductCategoryLtngCtrl.packageInformation(lstEE[0].id,accounts[0].id,userList[0].id,contacts[0].id,oppExpoBoothMapping.id);
        AddCustomerProductCategoryLtngCtrl.getProductSize(accounts[0].id, contacts[0].id, oppExpoBoothMapping.id, lstEE[0].id);
         
           string listSelected ='[{"EEPCMid":"'+evtEdnPrdctCatMapp.id+'","fakeL3L1Value":"","fakeL3Value":"","isChecked":true,"isFakeL3":false,"isFakeL3Checked":false,"ObjEESCM":{"Event_Edition_Product_Category_Mapping__c":"'+evtEdnPrdctCatMapp.id+'","Event_Edition__c":"'+lstEE[0].id+'","Id":"'+evntEdtnSbCatgryMapp.id+'","Levels_Master__c":"'+lvlMstr.id+'","Name":"'+evntEdtnSbCatgryMapp.id+'","Levels_Master__r":{"LevelValue__c":"Received conference brochure","Level_Name__c":"L3","Mapped_To_Level__c":"'+lvlMstr.id+'","Id":"'+lvlMstr.id+'","Mapped_To_Level__r":{"Level_Name__c":"L2","LevelValue__c":"How did you hear about the event","Mapped_To_Level__c":"'+lvlMstr.id+'","Id":"'+lvlMstr.id+'","Mapped_To_Level__r":{"LevelValue__c":"DQ for Health & Nutrition","Level_Name__c":"L1","Id":"'+lvlMstr.id+'"}}}}}]';
           AddCustomerProductCategoryLtngCtrl.savingOps(listSelected, accounts[0].id, userList[0].id, lstEE[0].id,oppExpoBoothMapping.id);
           AddCustomerProductCategoryLtngCtrl.saving(listSelected,accounts[0].id,userList[0].id,contacts[0].id,lstEE[0].id,oppExpoBoothMapping.id);
           AddCustomerProductCategoryLtngCtrl.deleteCategories(cstmrProCtgry.id,cstmrProSbCtgry.id );
           AddCustomerProductCategoryLtngCtrl.getEventDetails('WOC17');

        Test.stopTest();
    }             
}