/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          11/2/2017
 * Description/Purpose: This test class covers the apex class : UploadCenterInsuranceCtrl
 * Methods:             UploadCenterDataInsertWithTemplate, UploadCenterDataInsert
 * Apex Class:          UploadCenterInsuranceCtrl
**/

@isTest
public class UploadCenterInsuranceCtrl_Test
{
     public static testMethod void UploadCenterDataInsertWithTemplate()
     {
            
             Account acc = new Account(name='acc1');
            insert acc;
            
            User_Type__c UType = new User_Type__c(Name ='Contractor');
            insert UType;        
            Contact con = new Contact(LastName='User',FirstName ='Test', Type__c=UType.Id,AccountId =acc.Id);
            insert con;
            Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User Custom']; 
            
            User u = new User(Alias = 'standt', Email='dev123@test.com', 
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
                 
                 Event_Series__c evntSeries=new Event_Series__c();
                 evntSeries.name='World of Concrete';
                 insert evntSeries;
                 // Added by Palla Kishore for the ticket BK-19602 code coverage.
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
                ApexPages.currentPage().getParameters().put('eventId',eventEdt.id);
                ApexPages.currentPage().getParameters().put('eventCode',eventEdt.Event_Code__c); 
                ApexPages.currentPage().getParameters().put('posId',evntSeries.Id);  
                ApexPages.currentPage().getParameters().put('docType','1');
                 
               
                 AllowedFileTypes__c cs = new AllowedFileTypes__c();
                 cs.Name='pdf';
                 //cs.Other fiels values
                 insert cs;
                 UploadCenterInsuranceCtrl uploadCen=new UploadCenterInsuranceCtrl();
                    
                 uploadCen.attName='Test,pdf';
                 uploadCen.attBody=Blob.valueOf('Unit Test Attachment Body');
                 uploadCen.saveDocument();
                 
                 Email_Templates__c emailTemp1=new Email_Templates__c();
                 emailTemp1.Template_Code__c='BDGAPRtt';
                 insert emailTemp1;
                 
                 Event_Edition_Email_Template__c evntEmailTmp1=new Event_Edition_Email_Template__c();
                 evntEmailTmp1.Content__c='Operation_Admin_Name';
                 evntEmailTmp1.Subject__c='Test';
                 evntEmailTmp1.Event_Edition__c=eventEdt.id;
                 evntEmailTmp1.Email_Template_Code__c='DUNTOA';
                 evntEmailTmp1.Email_Template__c=emailTemp1.id;
                 insert evntEmailTmp1;
                 uploadCen.saveDocument();
                 
             }
          
         
     }
     public static testMethod void UploadCenterDataInsert()
     {
         // Insert Contact
             Contact con = new Contact(LastName='User',FirstName ='Test');
             insert con;
             System.assertEquals('User', con.LastName, 'Here value is not same');
         
             // Insert Event edition
             Event_Edition__c eventEdt=new Event_Edition__c();
             eventEdt.Name='Test';
             eventEdt.Event_Code__c='WOC17';
             insert eventEdt;
             
             Event_Series__c evntSeries=new Event_Series__c();
             evntSeries.name='World of Concrete';
             insert evntSeries;
             
             Operations_Team__c oprtnTeam=new Operations_Team__c();
             oprtnTeam.Event_Series__c=evntSeries.id;
             oprtnTeam.Operations_Team_Description__c='testOps';
             insert oprtnTeam;
              
             Operations_Team_Member__c oprtn=new Operations_Team_Member__c();
             oprtn.Operations_Team__c=oprtnTeam.id;
             insert oprtn;
             
              ApexPages.currentPage().getParameters().put('ContactId',con.id);
              ApexPages.currentPage().getParameters().put('checkRender','');
              ApexPages.currentPage().getParameters().put('eventId',eventEdt.id);
              ApexPages.currentPage().getParameters().put('eventCode',eventEdt.Event_Code__c); 
              ApexPages.currentPage().getParameters().put('posId',evntSeries.Id);
         		ApexPages.currentPage().getParameters().put('docType','2');
              UploadCenterInsuranceCtrl uploadCen2=new UploadCenterInsuranceCtrl();
              uploadCen2.saveDocument();
     }
}