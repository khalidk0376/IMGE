/**
* Created By  :  Mahesh (Girikon)
* Created On  :  08/07/2018
* Modified By :
* Modified On :
* @description : This test class covers the Trigger : AssignFormsManualsToStandContractor
* Apex Class:    AssignFormsManualsToStandContractor(85%)
**/
@isTest
public class AssignFormsManualsToStandContractor_Test 
{
    /**
* @description : For data setup and test methods.
* @return
*/
    public static testMethod void trgDeleteServicesMapTest() 
    {      
        //Create exhibitor user type
        User_Type__c uType = new User_Type__c(Name ='Stand Contractor');
        insert uType;
        
        System.AssertEquals(uType.Name, 'Stand Contractor','The user type should be Stand Contractor');
        
        //Create Account
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'Account should not be null');
        
        //Create contact
        Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com', Type__c=uType.Id,AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null,'Contact should not be null');
        set<Id> conIds = new set<Id>();
        conIds.add(con.id);   
        
        //create ExpocadBooth__c
        ExpocadBooth__c eB = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.',Matched_Product_Name__c='Space Only',Booth_Product_Type_EE__c='Test1',Booth_Type__c='BoothTest',Booth_Classes__c='test');
        insert eB;
        
        //Create event edition
        Event_Edition__c oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Currency__c='INR');
        insert oEve;
        
        //Create Questionnaire record
        Questionnaire__c oQnaire = new Questionnaire__c();
        oQnaire.Name='Template 1';
        oQnaire.Category__c='Healthcare';
        oQnaire.Description__c='Template 1';
        oQnaire.Community_URL__c=URL.getSalesforceBaseUrl().toExternalForm();       
        oQnaire.isMerge__c=false;
        insert oQnaire;
                
        //Create Form    
        Form__c oForm = new Form__c(Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today(),Template_Form_Name__c=oQnaire.id);
        insert oForm;
        
        Form__c oForm2 = new Form__c(Doc_Type__c='Online',Form__c=10,Deadline__c=System.Today(),Template_Form_Name__c=oQnaire.id);
        insert oForm2;
        // System.assertEquals(oForm2.SKUID_Template__c,skuidPage.id, 'checking SKUID_Template__c Id');
        
        //Create Event_Edition_Form
        Event_Edition_Form__c oEEForm = new Event_Edition_Form__c(Event_Edition__c = oEve.id,Forms__c =oForm.id,Expocad_Booth_Class__c='test', Expocad_Booth_Type__c='test2', Expocad_Product_Type__c='test1', User_Type__c ='Stand Contractor');        
        insert oEEForm;
        
        //Create FormPermission 
        Forms_Permission__c formPermission = new Forms_Permission__c(Active__c=True,Event_Edition_Form__c =oEEForm.Id,User_Type__c = uType.Id,PreventStandContractForm__c = true);
        insert formPermission;
        
        
        oEEForm.Expocad_Booth_Type__c ='Corner';
        update oEEForm;
        
        User_Form_Action__c uFAction = new User_Form_Action__c(Form_Permission__c =formPermission.Id, User_Form_Contact__c =con.Id, Account__c=acc.Id,User_Type__c=uType.Id);
        insert uFAction;
        System.assertNotEquals(uFAction,null,'User Form Action should not be null');
        //System.assert(uFAction != null, 'checking User_Form_Action');
        
        List<Manual__c> manualList = new List<Manual__c>();
        Manual__c  manual = new Manual__c (Event_Edition__c=oEve.id,name='text',Expocad_Booth_Class__c='test1',Expocad_Booth_Type__c='test2',Expocad_Product_Type__c='test3', User_Type__c ='Stand Contractor');
        manualList.Add(manual);
        
        Manual__c  manual2 = new Manual__c (Event_Edition__c=oEve.id,name='text',Expocad_Booth_Class__c='test2',Expocad_Booth_Type__c='test4',Expocad_Product_Type__c='test5', User_Type__c ='Stand Contractor');
        manualList.Add(manual2);
        insert manualList;
        
        //Create Manual Permission  
        Manuals_Permission__c manualPermission = new Manuals_Permission__c();
        manualPermission.Active__c = True;
        manualPermission.Manuals__c = manual.Id;
        manualPermission.User_Type__c = uType.Id;
        manualPermission.PreventStandContractManual__c = true;
        Test.StartTest();
        insert manualPermission;
        
        manual.Expocad_Booth_Type__c = 'Island';
        update manual;
        
        // Create User Manual Action
        User_Manual_Action__c uma = new User_Manual_Action__c();
        uma.User_Manual_Contact__c = con.id; 
        uma.Account__c = acc.id;
        uma.User_Type__c = uType.Id;
        uma.Manual_Permission__c = manualPermission.Id;
        insert uma;
        
        //Create BoothContractorMapping
        List<BoothContractorMapping__c> lstBoothCon = new List<BoothContractorMapping__c>();
        BoothContractorMapping__c boothConMap= new BoothContractorMapping__c (ContractorRequestStatus__c='Pending',ExpocadBooth__c=eB.id,Contact__c=con.id,Event_Edition__c=oEve.id);
        lstBoothCon.add(boothConMap);   
        insert lstBoothCon; 
        lstBoothCon=[Select Id, ContractorRequestStatus__c, ExpocadBooth__r.Booth_Type__c, ExpocadBooth__r.Matched_Product_Name__c, ExpocadBooth__r.Booth_Product_Type_EE__c, ExpocadBooth__r.Booth_Classes__c, 
                     Contact__c, Contact__r.AccountId, Event_Edition__c FROM BoothContractorMapping__c];
        
        lstBoothCon[0].ContractorRequestStatus__c = 'Accepted';
        update lstBoothCon;
        system.assertNotEquals(lstBoothCon.size(), 0 ,'BoothContractorMapping should be inserted');
        
    /*    Set<String> uTypeAndEEFormSet = new Set<String>();
        AssignFormsManualsToStandContractor  assignFormManualToStand = new AssignFormsManualsToStandContractor();
        uTypeAndEEFormSet = assignFormManualToStand.setUTypeAndEEForm;
        uTypeAndEEFormSet.add(formPermission.User_Type__r.Name);
        system.debug('uTypeAndEEFormSet' + uTypeAndEEFormSet);
        system.debug('uTypeAndEEFormSet ize' + uTypeAndEEFormSet.size());  */
        Test.stopTest(); 
    }
    public static testMethod void formPermissionTest(){
        Questionnaire__c oQnaire = new Questionnaire__c();
        oQnaire.Name='Template 1';
        oQnaire.Category__c='Healthcare';
        oQnaire.Description__c='Template 1';
        oQnaire.Community_URL__c=URL.getSalesforceBaseUrl().toExternalForm();       
        oQnaire.isMerge__c=false;
        insert oQnaire;
        Form__c oForm = new Form__c(Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today(),Template_Form_Name__c=oQnaire.id);
        insert oForm;
        Event_Edition__c oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Currency__c='INR');
        insert oEve;
        Event_Edition_Form__c oEEForm = new Event_Edition_Form__c(Event_Edition__c = oEve.id,Forms__c =oForm.id,Expocad_Booth_Class__c='test', Expocad_Booth_Type__c='test2', Expocad_Product_Type__c='test1');        
        insert oEEForm;
        User_Type__c uType = new User_Type__c(Name ='test');
        insert uType;
        System.AssertEquals(uType.Name, 'test','The user type should be test');
        Forms_Permission__c formPermissiondata = new Forms_Permission__c(Active__c=false,Event_Edition_Form__c =oEEForm.Id,User_Type__c = uType.Id,PreventStandContractForm__c = true);
        insert formPermissiondata;
        Test.startTest();
        AssignFormsManualsToStandContractor  assignFormManualToStand = new AssignFormsManualsToStandContractor();
        Test.stopTest();
    }    
}