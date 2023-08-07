/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          11/2/2017
 * Description/Purpose: This test class covers the apex class : UploadCenterPDFFormCtrl
 * Methods:             UploadCenterPDFFormDataWithTemplate, UploadCenterPDFFormDataInsert
 * Apex Class:          UploadCenterPDFFormCtrl
**/

@isTest
public class UploadCenterPDFFormCtrl_Test
{
    public static testMethod void UploadCenterPDFFormDataWithTemplate()
    {
        Account acc = new Account(name='acc1');
        insert acc;
        
        User_Type__c UType = new User_Type__c(Name ='Contractor');
        insert UType;        
        Contact con = new Contact(LastName='User',FirstName ='Test', Type__c=UType.Id,AccountId =acc.Id);
        insert con;
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User Custom']; 
        
        User u = new User(Alias = 'standt', Email='testUser1@tet.com', 
        EmailEncodingKey='UTF-8', LastName='Kumar', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,ContactID=con.id,
        TimeZoneSidKey='America/Los_Angeles', UserName='CommunityUser1@testorg.com');
        insert u; 
        System.assertEquals(u.ContactID,con.id, 'Same contact');
          System.runAs(u) 
          {
              
             // Insert Event edition
             Event_Edition__c eventEdt=new Event_Edition__c();
             eventEdt.Name='Test';
             eventEdt.Event_Code__c='WOC17';
             insert eventEdt;
             System.assertEquals(eventEdt.Event_Code__c,'WOC17', 'Event Code');
             Form__c frm=new Form__c();
             frm.name='Test';
             //frm.CurrencyIsoCode='USD';
             frm.Form__c   =22;
             insert frm; 
             
             Event_Edition_Form__c evntEdtnFrm=new Event_Edition_Form__c();
             evntEdtnFrm.name='Test';
             evntEdtnFrm.Forms__c=frm.id;
             //evntEdtnFrm.Currency__c='USD';
             insert evntEdtnFrm; 
             
             Event_Series__c evntSeries=new Event_Series__c();
             evntSeries.name='World of Concrete';
             insert evntSeries;
              
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
            Attachment attach=new Attachment();   
            attach.Name='Unit Test Attachment.pdf';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.ContentType='application/pdf';
            attach.parentId=eventEdt.id;
            insert attach;
            System.assertEquals(attach.parentId, eventEdt.id,'Parent is Event Edition');
             
             Forms_Permission__c frmPermsn=new Forms_Permission__c();
             frmPermsn.Active__c=true;
             frmPermsn.Event_Edition_Form__c=evntEdtnFrm.id;
             insert frmPermsn;
             
             ContactEventEditionMapping__c cEEMNew = new ContactEventEditionMapping__c(SFEventEditionID__c=eventEdt.Id, SFContactID__c=con.Id, User_Type__c=uType.Id);
             insert cEEMNew;
             
            Upload_Center__c oUploadCenter = new Upload_Center__c(Contact__c = con.id,Name='UploadTest',Uploaded_Attachment_Id__c= attach.id,Uploaded_Attachment_Name__c = attach.Name, Event_Edition__c=eventEdt.id, Event_Edition_Form__c=evntEdtnFrm.id);
            insert oUploadCenter;
            System.assert(oUploadCenter != null, 'checking Upload_Center__c record');
              
             User_Form_Action__c userFrm=new User_Form_Action__c();
             userFrm.User__c=u.id;
             userFrm.User_Form_Contact__c=con.id;
             userFrm.Form_Permission__c=frmPermsn.id;
             userFrm.CurrencyIsoCode='USD';
             insert userFrm;
             
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
             evntEmailTmp.Subject__c='Operation_Admin_Name';
             evntEmailTmp.Event_Edition__c=eventEdt.id;
             evntEmailTmp.Email_Template_Code__c='DUNTC';
             evntEmailTmp.Email_Template__c=emailTemp.id;
             insert evntEmailTmp;
             

             
            ApexPages.currentPage().getParameters().put('ContactId',con.id);
            ApexPages.currentPage().getParameters().put('checkRender','true');
            ApexPages.currentPage().getParameters().put('posId',evntSeries.id); 
            ApexPages.currentPage().getParameters().put('checkRender','');
            ApexPages.currentPage().getParameters().put('eventId',eventEdt.id);
            ApexPages.currentPage().getParameters().put('eventCode',eventEdt.Event_Code__c);
            ApexPages.currentPage().getParameters().put('docType','pdf');
            UploadCenterPDFFormCtrl uploadPdf=new UploadCenterPDFFormCtrl();
            
           // UploadCenterPDFForm
            uploadPdf.attName='Test,pdf';
            uploadPdf.attBody=Blob.valueOf('Unit Test Attachment Body');
            uploadPdf.eventEditionId=eventEdt.id;
            uploadPdf.saveDocument();
            uploadPdf.getItems();
            uploadPdf.updateUserFormAction(userFrm.id);
          }
        
    }
    public static testMethod void UploadCenterPDFFormDataInsert()
    {
        // Insert Contact
        Contact con = new Contact(LastName='User',FirstName ='Test');
        insert con;
        Event_Edition__c eventEdt=new Event_Edition__c();
        eventEdt.Name='Test';
        eventEdt.Event_Code__c='WOC17';
        insert eventEdt;
        User_Type__c UType = new User_Type__c(Name ='Contractor');
        insert UType; 
        ContactEventEditionMapping__c cEEMNew = new ContactEventEditionMapping__c(SFEventEditionID__c=eventEdt.Id, SFContactID__c=con.Id, User_Type__c=uType.Id);
        insert cEEMNew;
        Event_Series__c evntSeries=new Event_Series__c();
        evntSeries.name='World of Concrete';
        insert evntSeries;
        System.assertEquals(eventEdt.id , eventEdt.id, 'Same contact');
         ApexPages.currentPage().getParameters().put('ContactId',con.id);
         ApexPages.currentPage().getParameters().put('checkRender','false');
         ApexPages.currentPage().getParameters().put('eventId',eventEdt.id);
         ApexPages.currentPage().getParameters().put('posId',evntSeries.id); 
         
        UploadCenterPDFFormCtrl uploadPdf=new UploadCenterPDFFormCtrl();
    }
}