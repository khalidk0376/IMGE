/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          7/3/2017
 * Description/Purpose: This test class covers the apex class : UploadCenter
 * Methods:             UploadCenter_DataInsert
 * Apex Class:          UploadCenter
**/

@isTest
private class UploadCenter_Test
{
    public static testMethod void UploadCenter_DataInsert()
    {
        // Setup test data
        // This code runs as the system user
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        Profile CompanyCustomUserProfile = [SELECT Id FROM Profile WHERE Name='Company Communities User Custom'];
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserChrist1@testorg.com');
            
            Event_Edition__c OEve;
            ExpocadBooth__c oExpBooth;
            Upload_Center__c oUploadCenter ;
            List <User_Form_Action__c> ufaList = new List<User_Form_Action__c >();
            Event_Series__c oEventSeries;
            Attachment attach=new Attachment(); 
        System.runAs(u) 
        {
            // The following code runs as user 'u' 
            Contact con = new Contact(LastName='User',FirstName ='Test',Email='test@test.com');
            insert con;
            Brand__c br = new Brand__c(Name = 'World od Concrete', SSC_Email_Distribution_ID__c = 'test@gmail.com');
            insert br;
            
           /* Event_Series__c es = new Event_Series__c(Name='World of Concrete',Brand__c=br.ID,Event_Director__c=u.Id );
            es.Status__c = 'Active';
            insert es;  */
            
            
            oEventSeries = new Event_Series__c(Name='Fispal1',Event_Website__c='www.test.com.br',Usual_Venue__c ='Test');
            oEventSeries.Status__c = 'Active';
            insert oEventSeries;
            System.assert(oEventSeries != null, 'checking Event_Series__c record');
            
            OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Part_of_Series__c=oEventSeries.Id);
            OEve.Event_Edition_Status__c = 'Confirmed';
            OEve.Event_Edition_Code__c = 'Test1';
            insert OEve;
            System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
            
            oExpBooth = new ExpocadBooth__c(Booth_Number__c='17', Area__c='1100',Unit_Type__c='SqFt');
            insert oExpBooth;
            System.assertEquals(oExpBooth.Unit_Type__c,'SqFt', 'Unit type');
            
            Booth_Size_Badge_Limit__c oBoothSizeBadgeLimit = new Booth_Size_Badge_Limit__c(Event_Edition__c =OEve.id,Name='test',Badges_Allowed__c=3.0,Booth_Size_From__c=1100.0,Booth_Size_To__c=1200.0);
            insert oBoothSizeBadgeLimit;
            System.assert(oBoothSizeBadgeLimit != null , 'Booth size');
            
            Email_Templates__c et = new Email_Templates__c(Name='Test Email Template For Upload', Content__c='This is the testing Content', Subject__c='Test Email Template For Upload', Template_Code__c='DUNTOA', Group_Name__c='Forms');
            insert et;
            Event_Edition_Email_Template__c eet = new Event_Edition_Email_Template__c(Name='Test Email Template For Upload', Content__c='This is the testing Content For Upload', Subject__c='Test Email Template', Email_Template_Code__c='DUNTOA', Email_Template__c= et.Id, Event_Edition__c=OEve.Id);
            insert eet;
            Email_Templates__c et1 = new Email_Templates__c(Name='Test Email Template', Content__c='This is the testing Content', Subject__c='Test Email Template', Template_Code__c='DUNTC', Group_Name__c='Forms');
            insert et1;
            Event_Edition_Email_Template__c eet1 = new Event_Edition_Email_Template__c(Name='Test Email Template', Content__c='This is the testing Content', Subject__c='Test Email Template', Email_Template_Code__c='DUNTC', Email_Template__c= et.Id, Event_Edition__c=OEve.Id);
            insert eet1;
            
           
            User_Type__c UType = new User_Type__c(Name ='Exhibitor');
            insert UType;
            
            Form__c oForm = new Form__c(Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today());
            insert oForm;
           
            Event_Edition_Form__c oEEForm = new Event_Edition_Form__c(Event_Edition__c = OEve.id,Forms__c =oForm.id);
            insert oEEForm;
            System.assertEquals(oEEForm.Event_Edition__c,OEve.id, 'checking Event Id');
            Forms_Permission__c fPermission = new Forms_Permission__c(Event_Edition_Form__c = oEEForm.id, User_Type__c= UType.Id);
            insert fPermission;
            System.assertEquals(fPermission.Event_Edition_Form__c,oEEForm.id, 'checking Event_Edition_Form Id');
            
            
            List <ContactEventEditionMapping__c> conList = new List<ContactEventEditionMapping__c >(); 
           
            ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c(SFEventEditionID__c=OEve.Id, SFContactID__c=con.Id);
            conList.Add(cEEM);
            ContactEventEditionMapping__c cEEM2 = new ContactEventEditionMapping__c(SFEventEditionID__c=OEve.Id, SFContactID__c=con.Id);
            conList.Add(cEEM2);
            insert conList;
            System.assert(conList != null, 'checking conList');
            system.debug('conList===='+conList);
            
            
            
            for(Integer i=0;i<conList.size();i++){
                system.debug('conList===='+conList);
            
                User_Form_Action__c UFAction = new User_Form_Action__c(Form_Permission__c =fPermission.id, User_Form_Contact__c =conList[i].SFContactID__c,CurrencyIsoCode='USD');
                ufaList.Add(UFAction);
            }
            
            system.debug('ufaList===='+ufaList);
            insert ufaList;
            System.assert(ufaList != null, 'checking User_Form_Action');
            
                
            attach.Name='Unit Test Attachment.pdf';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.ContentType='application/pdf';
            attach.parentId=OEve.id;
            insert attach;
            System.assertEquals(attach.parentId, OEve.id,'Parent is Event Edition');
            
            attachment attach1 = new attachment();
            attach1.Name='Unit Test Attachment.csv';
            Blob bodyBlob1=Blob.valueOf('Attachment Body');
            attach1.body=bodyBlob1;
            attach1.ContentType='application/pdf';
            attach1.parentId=OEve.id;
            insert attach1;
            
            
            System.assertEquals(attach1.parentId, OEve.id,'Parent is Event Edition only');
            
            oUploadCenter = new Upload_Center__c(Contact__c = con.id,Name='UploadTest',Uploaded_Attachment_Id__c= attach.id,Uploaded_Attachment_Name__c = attach.Name);
            insert oUploadCenter;
            System.assert(oUploadCenter != null, 'checking Upload_Center__c record');
            ApexPages.currentPage().getParameters().put('ContactId' , con.id);
            ApexPages.currentPage().getParameters().put('eventCode' , OEve.event_code__C);
            ApexPages.currentPage().getParameters().put('eventId' , OEve.Id);
            //ApexPages.currentPage().getParameters().put('ContactId' , con.id);
            //ApexPages.currentPage().getParameters().put('eventCode' , OEve.event_code__C);
            //ApexPages.currentPage().getParameters().put('eventId' , OEve.Id);
            ApexPages.currentPage().getParameters().put('ufaID' , ufaList[0].id);
            ApexPages.currentPage().getParameters().put('posId' , oEventSeries.Id);
        
            UploadCenter upload = new UploadCenter();
            upload.upload();
            attachment attach2 = new attachment();
            attach2.Name='attName';
            Blob bodyBlob2=Blob.valueOf('attBody');
            attach2.body=bodyBlob2;
            attach2.ContentType='application/pdf';
            attach2.parentId=oUploadCenter.id;
            attach2.OwnerId=UserInfo.getUserId();
            insert attach2;
            
           /* attachment attach2 = new attachment();
            attach2.Name='Unit Test Attachment.csv';
            Blob bodyBlob2=Blob.valueOf('Attachment Body');
            attach2.body=bodyBlob2;
            attach2.ContentType='application/pdf';
            attach2.parentId=OEve.id;
            attach2.OwnerId=UserInfo.getUserId();
            insert attach2;
        
            list<attachment> att=[select name from attachment where name=:'Unit Test Attachment.csv'];
            system.assert(att.size()>0);
            uploadCenter uc=new uploadCenter();             
            uc.updateAttOnUploadCenter(oUploadCenter.Id,attach2.Name,attach2.id);
            list< Upload_Center__c> ucc=[select id,name from Upload_Center__c where name=:attach2.name];
            system.assert(ucc.size()>0);*/
            
            Operations_Team__c oOppTeam = new Operations_Team__c(CurrencyIsoCode ='USD',Event_Series__c =oEventSeries.id,Operations_Team_Description__c='test');
            insert oOppTeam;
            System.assert(oOppTeam != null, 'checking Operations_Team__c record');
            
            Operations_Team_Member__c oOppTeamMember = new Operations_Team_Member__c(User_Name__c=u.id,Operations_Team__c = oOppTeam.id);
            insert oOppTeamMember;
            System.assert(oOppTeamMember != null, 'checking Operations_Team_Member__c record');
        
        
            Test.startTest();
            /*ApexPages.currentPage().getParameters().put('eventCode',OEve.id);
            ApexPages.currentPage().getParameters().put('UCId',oUploadCenter.id);
            ApexPages.currentPage().getParameters().put('ufaID',ufaList[0].id);
            
            */
            ApexPages.currentPage().getParameters().put('ContactId' , con.id);
            ApexPages.currentPage().getParameters().put('eventCode' , OEve.event_code__C);
            ApexPages.currentPage().getParameters().put('eventId' , OEve.Id);
            //ApexPages.currentPage().getParameters().put('ContactId' , con.id);
            //ApexPages.currentPage().getParameters().put('eventCode' , OEve.event_code__C);
            //ApexPages.currentPage().getParameters().put('eventId' , OEve.Id);
            ApexPages.currentPage().getParameters().put('ufaID' , ufaList[0].id);
            ApexPages.currentPage().getParameters().put('posId' , oEventSeries.Id);
            
            
            UploadCenter singleUploadCenter = new UploadCenter();
            //singleUploadCenter.attName = 'TestAttachment.pdf';
            singleUploadCenter.checkFileFormat(attach.name);
            singleUploadCenter.attName = 'test';
            PageReference objPageRef =  singleUploadCenter.upload();
            singleUploadCenter.checkFileFormat(attach1.name);
            singleUploadCenter.getItems();
            //Call pageRef mymethod
                //PageReference objPageRef =  singleUploadCenter.upload();
            //singleUploadCenter.upload();
           
            singleUploadCenter.nameFile ='test123.pdf';
            singleUploadCenter.contentFile =Blob.valueOf('HI Testing');
            
            singleUploadCenter.sendEmailToOpsAdmin(oEventSeries.id,oUploadCenter.id,attach.id,attach.name,OEve.id);
            singleUploadCenter.sendEmailToCustomer(oUploadCenter.id, attach.id,attach.name,OEve.id);
            singleUploadCenter.updateUserFormAction(ufaList[0].id);
            singleUploadCenter.updateAttOnUploadCenter(oUploadCenter.id, attach.id,attach.name);
            singleUploadCenter.eventEditionId = OEve.Id;
    }
        Test.stopTest();
    }
    public static testMethod void UploadCenter_DataInsert2()
    {
        // Setup test data
        // This code runs as the system user
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        Profile CompanyCustomUserProfile = [SELECT Id FROM Profile WHERE Name='Company Communities User Custom'];
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = CompanyCustomUserProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserChrist1@testorg.com');
            
            Event_Edition__c OEve;
            ExpocadBooth__c oExpBooth;
            Upload_Center__c oUploadCenter ;
            List <User_Form_Action__c> ufaList = new List<User_Form_Action__c >();
            Event_Series__c oEventSeries;
            Attachment attach=new Attachment(); 
      //  System.runAs(u) 
       // {
            // The following code runs as user 'u' 
            Contact con = new Contact(LastName='User',FirstName ='Test',Email='test@test.com');
            insert con;
            Brand__c br = new Brand__c(Name = 'World od Concrete', SSC_Email_Distribution_ID__c = 'test@gmail.com');
            insert br;
            
           /* Event_Series__c es = new Event_Series__c(Name='World of Concrete',Brand__c=br.ID,Event_Director__c=u.Id );
            es.Status__c = 'Active';
            insert es;  */
            
            
            oEventSeries = new Event_Series__c(Name='Fispal1',Event_Website__c='www.test.com.br',Usual_Venue__c ='Test');
            oEventSeries.Status__c = 'Active';
            insert oEventSeries;
            System.assert(oEventSeries != null, 'checking Event_Series__c record');
            
            OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Part_of_Series__c=oEventSeries.Id);
            OEve.Event_Edition_Status__c = 'Confirmed';
            OEve.Event_Edition_Code__c = 'Test1';
            insert OEve;
            System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
            
            oExpBooth = new ExpocadBooth__c(Booth_Number__c='17', Area__c='1100',Unit_Type__c='SqFt');
            insert oExpBooth;
            System.assertEquals(oExpBooth.Unit_Type__c,'SqFt', 'Unit type');
            
            Booth_Size_Badge_Limit__c oBoothSizeBadgeLimit = new Booth_Size_Badge_Limit__c(Event_Edition__c =OEve.id,Name='test',Badges_Allowed__c=3.0,Booth_Size_From__c=1100.0,Booth_Size_To__c=1200.0);
            insert oBoothSizeBadgeLimit;
            System.assert(oBoothSizeBadgeLimit != null , 'Booth size');
            
            Email_Templates__c et = new Email_Templates__c(Name='Test Email Template For Upload', Content__c='This is the testing Content', Subject__c='Test Email Template For Upload', Template_Code__c='DUNTOA', Group_Name__c='Forms');
            insert et;
            Event_Edition_Email_Template__c eet = new Event_Edition_Email_Template__c(Name='Test Email Template For Upload', Content__c='This is the testing Content For Upload', Subject__c='Test Email Template', Email_Template_Code__c='DUNTOA', Email_Template__c= et.Id, Event_Edition__c=OEve.Id);
            insert eet;
            Email_Templates__c et1 = new Email_Templates__c(Name='Test Email Template', Content__c='This is the testing Content', Subject__c='Test Email Template', Template_Code__c='DUNTC', Group_Name__c='Forms');
            insert et1;
            Event_Edition_Email_Template__c eet1 = new Event_Edition_Email_Template__c(Name='Test Email Template', Content__c='This is the testing Content', Subject__c='Test Email Template', Email_Template_Code__c='DUNTC', Email_Template__c= et.Id, Event_Edition__c=OEve.Id);
            insert eet1;
            
           
            User_Type__c UType = new User_Type__c(Name ='Exhibitor');
            insert UType;
            
            Form__c oForm = new Form__c(Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today());
            insert oForm;
           
            Event_Edition_Form__c oEEForm = new Event_Edition_Form__c(Event_Edition__c = OEve.id,Forms__c =oForm.id);
            insert oEEForm;
            System.assertEquals(oEEForm.Event_Edition__c,OEve.id, 'checking Event Id');
            Forms_Permission__c fPermission = new Forms_Permission__c(Event_Edition_Form__c = oEEForm.id, User_Type__c= UType.Id);
            insert fPermission;
            System.assertEquals(fPermission.Event_Edition_Form__c,oEEForm.id, 'checking Event_Edition_Form Id');
            
            
            List <ContactEventEditionMapping__c> conList = new List<ContactEventEditionMapping__c >(); 
           
            ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c(SFEventEditionID__c=OEve.Id, SFContactID__c=con.Id);
            conList.Add(cEEM);
            ContactEventEditionMapping__c cEEM2 = new ContactEventEditionMapping__c(SFEventEditionID__c=OEve.Id, SFContactID__c=con.Id);
            conList.Add(cEEM2);
            insert conList;
            System.assert(conList != null, 'checking conList');
            system.debug('conList===='+conList);
            
            
            
            for(Integer i=0;i<conList.size();i++){
                system.debug('conList===='+conList);
            
                User_Form_Action__c UFAction = new User_Form_Action__c(Form_Permission__c =fPermission.id, User_Form_Contact__c =conList[i].SFContactID__c,CurrencyIsoCode='USD');
                ufaList.Add(UFAction);
            }
            
            system.debug('ufaList===='+ufaList);
            insert ufaList;
            System.assert(ufaList != null, 'checking User_Form_Action');
            
                
            attach.Name='Unit Test Attachment.pdf';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.ContentType='application/pdf';
            attach.parentId=OEve.id;
            insert attach;
            System.assertEquals(attach.parentId, OEve.id,'Parent is Event Edition');
            
            attachment attach1 = new attachment();
            attach1.Name='Unit Test Attachment.csv';
            Blob bodyBlob1=Blob.valueOf('Attachment Body');
            attach1.body=bodyBlob1;
            attach1.ContentType='application/pdf';
            attach1.parentId=OEve.id;
            insert attach1;
            System.assertEquals(attach1.parentId, OEve.id,'Parent is Event Edition only');
            
            oUploadCenter = new Upload_Center__c(Contact__c = con.id,Name='UploadTest',Uploaded_Attachment_Id__c= attach.id,Uploaded_Attachment_Name__c = attach.Name);
            insert oUploadCenter;
            System.assert(oUploadCenter != null, 'checking Upload_Center__c record');
            
            
            
            Operations_Team__c oOppTeam = new Operations_Team__c(CurrencyIsoCode ='USD',Event_Series__c =oEventSeries.id,Operations_Team_Description__c='test');
            insert oOppTeam;
            System.assert(oOppTeam != null, 'checking Operations_Team__c record');
            
            Operations_Team_Member__c oOppTeamMember = new Operations_Team_Member__c(User_Name__c=u.id,Operations_Team__c = oOppTeam.id);
            insert oOppTeamMember;
            System.assert(oOppTeamMember != null, 'checking Operations_Team_Member__c record');
       // }
        
            Test.startTest();
            ApexPages.currentPage().getParameters().put('ContactId' , con.id);
            ApexPages.currentPage().getParameters().put('eventCode' , OEve.event_code__C);
            ApexPages.currentPage().getParameters().put('eventId' , OEve.Id);
            //ApexPages.currentPage().getParameters().put('ContactId' , con.id);
            //ApexPages.currentPage().getParameters().put('eventCode' , OEve.event_code__C);
            //ApexPages.currentPage().getParameters().put('eventId' , OEve.Id);
            ApexPages.currentPage().getParameters().put('ufaID' , ufaList[0].id);
            ApexPages.currentPage().getParameters().put('posId' , oEventSeries.Id);
            
            
            UploadCenter singleUploadCenter = new UploadCenter();
            //singleUploadCenter.attName = 'TestAttachment.pdf';
            singleUploadCenter.checkFileFormat(attach.name);
            singleUploadCenter.attName = 'test';
            PageReference objPageRef =  singleUploadCenter.upload();
            singleUploadCenter.checkFileFormat(attach1.name);
            singleUploadCenter.getItems();
            //Call pageRef mymethod
                //PageReference objPageRef =  singleUploadCenter.upload();
            //singleUploadCenter.upload();
           
            singleUploadCenter.nameFile ='test123.pdf';
            singleUploadCenter.contentFile =Blob.valueOf('HI Testing');
            singleUploadCenter.attBody = Blob.valueOf('HI Testing');
            
            singleUploadCenter.sendEmailToOpsAdmin(oEventSeries.id,oUploadCenter.id,attach.id,attach.name,OEve.id);
            singleUploadCenter.sendEmailToCustomer(oUploadCenter.id, attach.id,attach.name,OEve.id);
            singleUploadCenter.updateUserFormAction(ufaList[0].id);
            singleUploadCenter.updateAttOnUploadCenter(oUploadCenter.id, attach.id,attach.name);
            
        Test.stopTest();
    }
}