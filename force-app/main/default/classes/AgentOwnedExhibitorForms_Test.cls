/**
 * Created By   :   Girikon(Prashant)
 * Created On   :   Sept 2 2018
 * @description :   Test Class for AgentOwnedExhibitorForms Apex class.
 * Test Class   :   AgentOwnedExhibitorForms_Test ()
 * Modification Log----- 
 * Modified by  :   
**/

@isTest
public with sharing class AgentOwnedExhibitorForms_Test 
{  
    @isTest
    static void getAoeForms()
    {
        //Create account
        account objAcc = new account(Name='TestLName');
        insert objAcc;
        System.assertNotEquals(objAcc, null, 'objAcc cannot be null');
        
        //Create Contact
        Contact objCon = new Contact(LastName='TestContactName', AccountId = objAcc.Id);
        insert objCon;
        System.assertNotEquals(objCon, null, 'objCon cannot be null');

        //Create conga template
        APXTConga4__Conga_Template__c congaTemp=new APXTConga4__Conga_Template__c(APXTConga4__Name__c='Test Cong Template');
        Insert congaTemp;
        
        //Create UserType
        User_Type__c uTypeAOE = new User_Type__c(Name='Agent Owned Exhibitor');
        insert uTypeAOE;
        
        // Insert Document
        Document d = new Document(); 
        d.Name = 'TEV17-Event-Image'; 
        d.FolderId = UserInfo.getUserId();//documents[0].FolderId;
        d.IsPublic = true; 
        d.Body =Blob.valueOf('Some Text'); 
        d.ContentType = 'image/jpeg';
        insert d;
        
        Event_Series__c eventSer = new Event_Series__c(Name ='Test',Status__c = 'Active');
        insert eventSer;
        
        //Create Event Edition
        Event_Edition__c eventEdition = new Event_Edition__c(Name='VitaFoods Europe 2019',Part_of_Series__c=eventSer.id,Event_Code__c='PSVITE9',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Edition_Status__c='Confirmed',Contract_Template__c=congaTemp.Id,Event_Website__c='http://www.testevent.com',Event_Edition_Image_URL__c=d.Id,Invoice_From_Email_ID__c='Test',Max_Hold_Booth__c=50,Max_Hold_Days__c=10,Measurement__c='Feet',Next_Edition__c='2019',Payment_Schedule__c='50-50',Quote_Template__c=congaTemp.Id,Venue__c='Test',Year__c='2018',Event_Currency__c='USD',Cutoff_Date_1__c=  System.today() + 5,Informa_Logo__c=d.Id);
        insert eventEdition;
        System.debug('eventEdition ' +eventEdition);
        System.debug('objAcc ' +objAcc);
        
        //Create Questionnaire record
        Questionnaire__c oQnaire = new Questionnaire__c();
        oQnaire.Name='Template 1';
        oQnaire.Category__c='Healthcare';
        oQnaire.Description__c='Template 1';
        oQnaire.Community_URL__c=URL.getSalesforceBaseUrl().toExternalForm();
        oQnaire.isMerge__c=true;
        insert oQnaire;
        
        Form__c oForm = new Form__c(Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today(),Template_Form_Name__c=oQnaire.id);
        insert oForm;
        
        Event_Edition_Form__c oEEReqForm = new Event_Edition_Form__c(Event_Edition__c = eventEdition.id,Forms__c =oForm.id,Expocad_Booth_Class__c='', Expocad_Booth_Type__c='', Expocad_Product_Type__c='', Mandatory__c = true,Template_Form__c=oQnaire.id);
        insert oEEReqForm;
        
        //Event_Edition_Form__c oEEAddForm = new Event_Edition_Form__c(Event_Edition__c = eventEdition.id,Forms__c =oForm.id,Expocad_Booth_Class__c='', Expocad_Booth_Type__c='', Expocad_Product_Type__c='', Mandatory__c = false,Template_Form__c=oQnaire.id);
        //insert oEEAddForm;
        
        Forms_Permission__c fPermission = new Forms_Permission__c(Event_Edition_Form__c = oEEReqForm.id, User_Type__c= uTypeAOE.Id, Active__c= true);
        insert fPermission;
        
        //Forms_Permission__c fAddPermission = new Forms_Permission__c(Event_Edition_Form__c = oEEAddForm.id, User_Type__c= uTypeAOE.Id, Active__c= true);
        //	insert fAddPermission;
        
        //Create Event_Settings__c
        Event_Settings__c eventSettings = new Event_Settings__c(Name='Test',About_Show__c='Test',ShowHours1__c='test',ShowHours2__c='Test',Branding_Color__c='Black',Link_1__c='http://m.www.google.com/',Is_Stand_Design_Visible__c=True,Is_Stand_Detail_Visible__c=True,Is_SubContractors_Visible__c=True,Is_Amount_Visible__c=True,
                                                                Link_2__c='http://m.www.google.com/',Link_3__c='http://m.www.google.com/',Link_4__c='http://m.www.google.com/',Link_1_Label__c='TestLink1',Link_2_Label__c='TestLink2',Link_3_Label__c='TestLink3',Deadline_Reached_Message_for_Forms__c='Form is Expired',Link_4_Label__c='TestLink4',
                                                                FaceBook__c='http://m.www.facebook.com/',LinkedIn__c='http://m.www.linkedin.com/',Twitter__c='http://m.www.Twitter.com/',YouTube__c='http://m.www.youtube.com/',Custom_1_Title__c='CstmTitle',Event_Edition__c=eventEdition.Id,E_Commerce_Title__c='EC Title',Welcome_Stand_Contractor__c='WSC Test',Disable_this_information__c=True);
        insert eventSettings;

        User_Form_Action__c oUserAction = new User_Form_Action__c(Form_Permission__c=fPermission.Id,Account__c=objAcc.Id,User_Type__c=uTypeAOE.Id, Is_Viewed__c=true, Is_Filled_Up__c= true);
        insert oUserAction;
        
        AgentOwnedExhibitorForms.customerFormList(objAcc.Id, eventEdition.Event_Code__c);
        AgentOwnedExhibitorForms.viewedRecord(oUserAction.Id, oUserAction.Is_Viewed__c, oUserAction.Is_Filled_Up__c);
    }
}