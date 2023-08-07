/**
* Project:         GAP
* Date:            26/12/2018
* Test Class For:  OpportunityNotesAttachmentActivityClass
* Code Coverage:   100%
* Created By:      Yash Gupta
* Modified Date:   26/12/2018
* Modified By:     Yash Gupta
* *************************************************************************
* @Description:     This test class covers "OpportunityNotesAttachmentActivityClass" class.
* *************************************************************************
* History: 
*/


@isTest
public class OpportunityNotesAttachmentActivity_Test {
    @isTest static void oppNotesAttachmentActivityMethodOne() {     
        
        //@Description: Insert Account.
        Account acc = new Account();
        acc.Name = 'Testing Account'; 
        acc.CurrencyIsoCode = 'USD';
        insert acc;
        System.assertEquals('Testing Account', acc.name,'Error Account is not created');
        
        //@Description: Insert Contact.
        Contact ocontact = new Contact();
        ocontact.FirstName = 'Testing First Name';
        ocontact.LastName = 'Testing Last Name';
        ocontact.Email = 'test.test@gmail.com';
        ocontact.AccountId = acc.Id;
        insert ocontact;
        
        //@Description: Insert Event Edition.
        Event_Edition__c eventEdition = new Event_Edition__c();
        eventEdition.Name = 'Testing Event Edition';
        eventEdition.Tab1__c = 'Tab1';
        eventEdition.Tab4__c = 'Tab4';
        eventEdition.Tab8__c = 'Tab8';
        insert eventEdition;
        
        //@Description: Insert Opportunity.
        Opportunity opp = new Opportunity();
        opp.Name = 'Testing Opportunity';
        opp.EventEdition__c = eventEdition.Id;
        opp.Opportunity_Contact__c = ocontact.Id;
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.Today().addDays(1);
        opp.StageName = 'Customise';
        insert opp;
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Testing Opportunity';
        opp1.EventEdition__c = eventEdition.Id;
        opp1.Opportunity_Contact__c = ocontact.Id;
        opp1.AccountId = acc.Id;
        opp1.CloseDate = Date.Today().addDays(1);
        opp1.StageName = 'Customise';
        insert opp1;
        
        //@Description: Get Sales user Id. 
        Id userId = [select Id from User where Profile.Name = 'Sales' Limit 1].Id;
        
        //@Description: Insert Note.
        Note nT = new Note();
        nT.Title = 'Testing Title';  
        nT.Body = 'Testing Note Body';
        nT.IsPrivate = false;
        nT.OwnerId = userId!=null?userId:UserInfo.getUserId();
        nT.ParentId = opp1.Id;
        insert nT;

        Blob b3 = Blob.valueOf('Test Data record');
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'Complete.pdf';//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion.Title ='Completed Test Signed Files for Parent Manual';//Name of the file
        cVersion.VersionData = b3;//File content
        insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId =  opp1.Id;//Add Files parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;         
        
        //@Description: Insert Task.
        Task tK = new Task();
        tK.Subject = 'Testing Subject';
        tK.Status = 'Not Started';
        tK.Priority = 'Normal';
        tK.WhatId = opp1.Id;
        insert tK;      
        
        //@Description: Calling WebService method into test class along with the required parameters.         
        Test.startTest();
        String sPickVal = 'Notes;Files;Activities';
        OpportunityNotesAttachmentActivityClass.oppNotesAttachActivity(opp.Id, sPickVal, opp1.Id);
        
        PaymentSchedule_class.getallDataRecord(opp.Id);
        PaymentSchedule_class.saveData(opp);
        PaymentSchedule_class.saveData(opp);
        PaymentSchedule_class.validateLoggedInUsr(opp.Id);
        
        OpportunityRecallModal_Class.updateOpp(opp.Id);
        Test.stopTest();
        
    }
}