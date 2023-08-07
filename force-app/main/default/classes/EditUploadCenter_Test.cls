/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          9/8/2017
 * Description/Purpose: This test class covers the apex class : EditUploadCenter 
 * Methods:             EditUploadCenter_DataInsert
 * Apex Class:          EditUploadCenter 
 **/

@isTest
private class EditUploadCenter_Test
{
    public static testMethod void EditUploadCenter_DataInsert()
    {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='useriehiewio@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='useriehiewio@testorg.com');
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
            
            Event_Series__c es = new Event_Series__c(Name='World of Concrete1',Brand__c=br.ID,Event_Director__c=u.Id );
            insert es;
            
            OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Part_of_Series__c=es.Id);
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
            
            oUploadCenter = new Upload_Center__c(Contact__c = con.id,Name='UploadTest',Uploaded_Attachment_Id__c= attach.id,Uploaded_Attachment_Name__c = attach.Name);
            insert oUploadCenter;
            System.assert(oUploadCenter != null, 'checking Upload_Center__c record');
            
            oEventSeries = new Event_Series__c(Name='Fispal123323',Event_Website__c='www.test.com.br',Usual_Venue__c ='Test', Event_Series_Code__c = 'chdcdccdchcbbc');
            insert oEventSeries;
            System.assert(oEventSeries != null, 'checking Event_Series__c record');
            
            Operations_Team__c oOppTeam = new Operations_Team__c(CurrencyIsoCode ='USD',Event_Series__c =oEventSeries.id,Operations_Team_Description__c ='test');
            insert oOppTeam;
            System.assert(oOppTeam != null, 'checking Operations_Team__c record');
            
            Operations_Team_Member__c oOppTeamMember = new Operations_Team_Member__c(User_Name__c=u.id,Operations_Team__c = oOppTeam.id);
            insert oOppTeamMember;
            System.assert(oOppTeamMember != null, 'checking Operations_Team_Member__c record');
            
        }
        
        Test.startTest();
            PageReference testPage = Page.EditUploadCenter;
            ApexPages.currentPage().getParameters().put('eventCode',OEve.id);
            testPage.getParameters().put('eventCode',OEve.id);
            testPage.getParameters().put('UCId',oUploadCenter.id);
            testPage.getParameters().put('ufaID',ufaList[0].id); 
            testPage.getParameters().put('posId',oEventSeries.id); 
            Test.setCurrentPage(testPage);
            
            
            EditUploadCenter singleUploadCenter = new EditUploadCenter();
            
            //Call pageRef mymethod
            PageReference objPageRef =  singleUploadCenter.upload();
            //singleUploadCenter.upload();
           
            singleUploadCenter.nameFile ='test123.pdf';
            singleUploadCenter.contentFile =Blob.valueOf('HI Testing');
            
            singleUploadCenter.updateUserFormAction(ufaList[0].id);
            singleUploadCenter.updateAttOnUploadCenter(oUploadCenter.id, attach.id,attach.name);
            
        Test.stopTest();
    }
    
}