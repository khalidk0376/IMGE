/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          11/2/2017 
 * Description/Purpose: This test class covers the apex class : UPloadCenterInsStandCtrlEdit
 * Methods:             UploadCenterInsertEdit
 * Apex Class:          UPloadCenterInsStandCtrlEdit
**/

@isTest
public class UPloadCenterInsStandCtrlEdit_Test
{
    public static testMethod void UploadCenterInsertEdit()
    {
        Account acc = new Account(name='acc1');
        insert acc;
        
        User_Type__c UType = new User_Type__c(Name ='Contractor');
        insert UType;        
        Contact con = new Contact(LastName='User',FirstName ='Test', Type__c=UType.Id,AccountId =acc.Id);
        insert con;
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User Custom']; 
        
        User u = new User(Alias = 'standt', Email='shane12@test.com', 
        EmailEncodingKey='UTF-8', LastName='Kumar', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,ContactID=con.id,
        TimeZoneSidKey='America/Los_Angeles', UserName='CommunityUser1@testorg.com');
        insert u; 
        System.assertEquals(u.ContactID,con.id, 'Same contact');
        Event_Edition__c OEve;
        System.runAs(u) 
        {
            
             // Insert Event edition
             Event_Edition__c eventEdt=new Event_Edition__c();
             eventEdt.Name='Test';
             eventEdt.Event_Code__c='WOC17';
             insert eventEdt;
             
             System.assertEquals(eventEdt.Event_Code__c,'WOC17', 'Event Code');
            
            // Added by Palla Kishore for the ticket EMEA-208
            Event_Settings__c eset = new Event_Settings__c();
            eset.Name ='event Setting Test';
            eset.Event_Edition__c = eventEdt.Id;
            eset.Branding_Color__c = 'yellow';
            eset.Badge_FName_Character_Limit__c = 500;           
            eset.Badge_LName_Character_Limit__c = 500;
            eset.Badge_JobTitle_Character_Limit__c = 500;
            eset.Badge_Email_Character_Limit__c = 500;
            eset.Badge_Mobile_Character_Limit__c = 500;
            eset.Badge_City_Character_Limit__c = 500;
            eset.Badge_Address_Character_Limit__c = 500;
            eset.Company_Name_on_Badge_Character_Limit__c = 500;
            eset.Allotment_By_Booth_Type__c=false;
            eset.Allotment_By_Booth_Size__c=true;
            eset.Agent_Badge_limit__c='10';
            insert eset;
            
             Form__c oForm = new Form__c(Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today());
            insert oForm;
            
            Event_Edition_Form__c oEEForm = new Event_Edition_Form__c(Event_Edition__c = eventEdt.id,Forms__c =oForm.id);
            insert oEEForm;
            System.assertEquals(oEEForm.Event_Edition__c,eventEdt.id, 'checking Event Id');
            
            Forms_Permission__c fPermission = new Forms_Permission__c(Event_Edition_Form__c = oEEForm.id, User_Type__c= UType.Id, Active__c= True);
            insert fPermission;
            System.assertEquals(fPermission.Event_Edition_Form__c,oEEForm.id, 'checking Event_Edition_Form Id');
            
            
            ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c(SFEventEditionID__c=eventEdt.Id, SFContactID__c=con.Id);
            insert cEEM;
            
            
            User_Form_Action__c UFAction = new User_Form_Action__c(Form_Permission__c =fPermission.id, User_Form_Contact__c =cEEM.SFContactID__c,CurrencyIsoCode='USD');
            insert UFAction;
            
            // END of EMEA-208
             
             Event_Series__c evntSeries=new Event_Series__c();
             evntSeries.name='World of Concrete';
             insert evntSeries;
             
             Upload_Center__c uc=new Upload_Center__c();
             uc.name='Test';
             uc.Event_Edition__c =eventEdt.id;
             uc.Contact__c=con.id;
             insert uc;
            
             Attachment attach=new Attachment();     
             attach.Name='Unit Test Attachment';
             Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
             attach.body=bodyBlob;
             attach.parentId=uc.id;
             insert attach;
             
             Operations_Team__c oprtnTeam=new Operations_Team__c();
             oprtnTeam.Event_Series__c=evntSeries.id;
             oprtnTeam.Operations_Team_Description__c='testOps';
             insert oprtnTeam;
              
             Operations_Team_Member__c oprtn=new Operations_Team_Member__c();
             oprtn.Operations_Team__c=oprtnTeam.id;
             oprtn.User_Name__c=NULL;
             insert oprtn;
            
             Email_Templates__c emailTemp=new Email_Templates__c();
             emailTemp.Template_Code__c='BDGAPRt';
             insert emailTemp;
             
             Event_Edition_Email_Template__c evntEmailTmp=new Event_Edition_Email_Template__c();
             evntEmailTmp.Content__c='Operation_Admin_Name';
             evntEmailTmp.Subject__c='test';
             evntEmailTmp.Event_Edition__c=eventEdt.id;
             evntEmailTmp.Email_Template_Code__c='DUNTC';
             evntEmailTmp.Email_Template__c=emailTemp.id;
             insert evntEmailTmp;
            
            ApexPages.currentPage().getParameters().put('check','Test');
            ApexPages.currentPage().getParameters().put('docId',uc.id);
            ApexPages.currentPage().getParameters().put('eventId',eventEdt.id);
            ApexPages.currentPage().getParameters().put('posId',evntSeries.id);
            UPloadCenterInsStandCtrlEdit uploadcenterEdit=new UPloadCenterInsStandCtrlEdit();
            
            AllowedFileTypes__c cs = new AllowedFileTypes__c();
             cs.Name='pdf';
             //cs.Other fiels values
             insert cs;
             
            uploadcenterEdit.fileName='Test,pdf';
            uploadcenterEdit.Photo=Blob.valueOf('Unit Test Attachment Body');
            uploadcenterEdit.saveDocument();
            
            uploadcenterEdit.fileName='Test';
            uploadcenterEdit.Photo=null;
            uploadcenterEdit.saveDocument();
            
            uploadcenterEdit.fileName='';
            uploadcenterEdit.Photo=null;
            uploadcenterEdit.saveDocument();
            
            Email_Templates__c emailTemp1=new Email_Templates__c();
             emailTemp1.Template_Code__c='BDGAPRtr';
             insert emailTemp1;
             
             Event_Edition_Email_Template__c evntEmailTmp1=new Event_Edition_Email_Template__c();
             evntEmailTmp1.Content__c='Operation_Admin_Name';
             evntEmailTmp1.Event_Edition__c=eventEdt.id;
             evntEmailTmp1.Email_Template_Code__c='DUNTC';
             evntEmailTmp1.Email_Template__c=emailTemp1.id;
             insert evntEmailTmp1;
            uploadcenterEdit.saveDocument();
            
            uploadcenterEdit.saveDocument();
            
            uploadcenterEdit.fileName='';
            uploadcenterEdit.saveDocument();
            
            uploadcenterEdit.fileName='Test';
            uploadcenterEdit.Photo=Blob.valueOf('Unit Test Attachment Body');
            uploadcenterEdit.saveDocument();
        }
        
    }
    
}