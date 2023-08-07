/**
* Created/Modified By:  [Aishwarya Kumar 4 Aug 2020]
* Class:   ClonefromPreviousEE
*/
@isTest
public class ClonefromPreviousEE_Test {
    static testMethod void cloneCCData (){
        Account acc1 = new Account();
        acc1.Name='acc1';
        acc1.BillingCity ='Dallas' ;
        acc1.BillingCountry='USA';
        acc1.BillingPostalCode='75068';
        acc1.BillingState='Texas';
        acc1.BillingStreet='water well street';              
        insert acc1;
        
        Contact con = new Contact(LastName='User',FirstName ='Test1',AccountId=acc1.id, Contact_Type__c = 'Primary Contact');
        insert con;
        
        Event_Series__c evntSeries = new Event_Series__c( name='World of Concrete' );
        evntSeries.Status__c = 'Active';
        insert evntSeries;
        
        Event_Edition__c  sOEve1 = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        sOEve1.Event_Edition_Status__c = 'Confirmed';
        sOEve1.Event_Edition_Code__c = 'WOC17';
        sOEve1.Part_of_Series__c = evntSeries.Id;
        insert sOEve1;
        
        Event_Edition__c  sOEve2 = new Event_Edition__c(Name='World of Concrete 2018',Event_Code__c='WOC18',End_Date__c=System.Today(),Start_Date__c=System.Today(),Previous_Event_Edition__c =sOEve1.Id);
        sOEve2.Event_Edition_Status__c= 'Confirmed';
        sOEve2.Previous_Event_Edition__c = sOEve1.Id;
        sOEve2.Event_Edition_Code__c = 'WOC18';
        sOEve2.Part_of_Series__c = evntSeries.Id;
        insert sOEve2;
        Test.startTest();
        System.assertEquals(sOEve2.Event_Code__c, 'WOC18', 'This event edition must be World of concrete 2018');
        
        Event_Settings__c eveSetting = new Event_Settings__c();
        eveSetting.isAlreadyCloned__c = false;
        eveSetting.Event_Edition__c = sOEve2.Previous_Event_Edition__c;
        insert eveSetting;
        
        Manual__c man = new Manual__c(Section__c = 123, Name = 'testManual',Event_Edition__c=sOEve2.Previous_Event_Edition__c);
        insert man;
        System.assertEquals(man.Event_Edition__c,sOEve2.Previous_Event_Edition__c, 'Event Id');
        Blob b3 = Blob.valueOf('Test Data record');
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'Completed Test Signed Attachment for Parent Manual.pdf';//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion.Title ='Completed Test Signed Attachment for Parent Manual';//Name of the file
        cVersion.VersionData = b3;//File content
        insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = man.id;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        Form__c form = new Form__c(Name = 'testForm',Form__c=2);
        insert form;
        System.AssertNotEquals(form, null, 'Here Value is same');
        
        Event_Edition_Form__c eDF = new Event_Edition_Form__c(Forms__c=Form.id,Name='testEDF',Event_Edition__c=sOEve2.Previous_Event_Edition__c);
        insert eDF;
        System.AssertEquals(eDF.Forms__c, Form.id, 'Here value is not same');
        
        Manual__c manual = new Manual__c(Name='testManual',Event_Edition__c=sOEve2.id,User_Type__c ='Agent');
        insert Manual;
        
        Email_Templates__c email = new Email_Templates__c(Name='testEmail',Template_Code__c='XX01');
        insert email;
        System.AssertEquals(email.Template_Code__c, 'XX01', 'Here value is not same');
        
        Event_Edition_Email_Template__c eventEmail = new Event_Edition_Email_Template__c(name='testEventEmail',Event_Edition__c=sOEve2.Previous_Event_Edition__c,Email_Template__c=email.id);
        insert eventEmail;
        System.AssertEquals(eventEmail.Email_Template__c, email.id, 'Here value is not same');
        
        Booth_Size_Badge_Limit__c boothSize = new Booth_Size_Badge_Limit__c(Name='testBoothSize',Event_Edition__c=sOEve2.Previous_Event_Edition__c,Badges_Allowed__c=3,Booth_Size_From__c=3,Booth_Size_To__c=3, Booth_Type__c =null);
        insert boothSize;
        System.AssertEquals(boothSize.Badges_Allowed__c, 3, 'Here value is not same');
        
        User_Type__c uType = new User_Type__c(Name ='Exhibitor');
        insert uType;
        System.AssertEquals(uType.Name , 'Exhibitor', 'Here value is not same');
        
        ComponentUserTypeMapping__c compUsrMap = new ComponentUserTypeMapping__c(Event_Edition__c = sOEve2.Previous_Event_Edition__c, User_Type__c= uType.Id);
        insert compUsrMap;
        System.AssertEquals(compUsrMap.User_Type__c, uType.Id, 'Here value is not same');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(sOEve2);
        Apexpages.currentpage().getparameters().put('id' , sOEve2.id);
        ClonefromPreviousEE ccData = new ClonefromPreviousEE(sc);
        try{
            ccData.cloneData();
            ccData.sErrorMsg = 'sErrorMsg';
            ccData.returnToPT();
            eveSetting.isAlreadyCloned__c = true;
            update eveSetting;
            ccData.cloneData();
            ccData.cloneDataFirstTime();
            ccData.cloneOverwrite();
        }
        catch(Exception ex){
            System.debug('Error from Test Class '+ex);
        }
        Test.stopTest();
    }
}