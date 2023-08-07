/**
* Created By: Girikon(Hemendra)
* Created On: May 15 2018
* Modified by :  
* Modified On: 
* @description  : Test Class for "EmailConfirmToContractorForBoothStatus":
* Test Class:  EmailConfirmToContractorForBoothStatus(88%)
* Modification Log----- 
* Modified by   : Girikon(Prashant) [CCEN-326], Girikon(Aishwarya) [CCEN-389 March 19 2019]
* Modified On   : Oct 5 2018
**/    


@isTest
private class EmailCtoCforBS_Test {
     
    @testSetup
    static void dataSetUp() {
        //Create user record
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User[] userList = new User[]{};
            User u = new User();
        
        u.FirstName = 'Alex';
        u.LastName = 'Sherwood';
        u.Email = 'test@wexeurope.com';
        u.Username = 'astest@wexeurope.com';
        u.Alias = 'astest';
        u.ProfileId = pro.Id;
        u.TimeZoneSidKey    = 'America/Denver';
        u.LocaleSidKey      = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        userList.add(u);
        system.debug('u contains ' + u);
        insert userList;
        
        //Create User_Type__c
        
        User_Type__c uT = new User_Type__c(Name='Stand Contractor');
        insert uT;
        
        //Create Account
        List<Account> accounts = new List<Account>();
        for(Integer i=0;i<3;i++)
        {
            Account a = new Account(Name='TstAccFrst' + i);
            accounts.add(a);    
        }
        insert accounts;
        
        //create some contacts
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0;i<3;i++)
        {
            Contact c = new Contact(AccountId = accounts[i].Id, FirstName = 'TstConFrst'+i, LastName = 'TstConLst1'+i, Email='abc@test.com');
            contacts.add(c);    
        }
        insert contacts;
        
        //create ExpocadBooth__c
        List<ExpocadBooth__c> lstExpoBooth = new List<ExpocadBooth__c>();
        for(Integer i=0;i<3;i++)
        {
            ExpocadBooth__c eB = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.'+i);
            lstExpoBooth.add(eB);   
        }
        insert lstExpoBooth;
        
        //create Event_Edition__c
      /*  List<Event_Edition__c> lstEE = new List<Event_Edition__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Edition__c eE = new Event_Edition__c(Name='TestName'+i,CurrencyIsoCode='USD',Tab1__c='Booth Application',Tab4__c='Contact Information', Tab8__c='Transfer & Payments',Event_Currency__c ='USD',Event_Code__c='abc');
            lstEE.add(eE);  
        }
        insert lstEE; */
        
    //    Event_Edition__c eE = new Event_Edition__c(Name='TestName',CurrencyIsoCode='USD',Tab1__c='Booth Application',Tab4__c='Contact Information', Tab8__c='Transfer & Payments',Event_Currency__c ='USD',Event_Code__c='abc');
     //   insert eE;
        
        Event_Edition__c eE1 = new Event_Edition__c(Name='test',CurrencyIsoCode='EUR',Tab1__c='Booth Application',Tab4__c='Contact Information', Tab8__c='Transfer & Payments',Event_Currency__c ='EUR',Event_Code__c='test');
        insert eE1;
        
        Opportunity op = new Opportunity(Name='Testopp',EventEdition__c = eE1.id,AccountId=accounts[0].id,CloseDate=date.today()+19,Opportunity_Contact__c=contacts[0].id, StageName='Closed Won');
        op.Operations_Contact__c = contacts[0].id;
        insert op;
        
        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = accounts[0].Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = op.Id;
        qtObj.CurrencyIsoCode='BRL';
        insert qtObj;
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = accounts[0].Id, Badge_Limit__c = 2, status__c = 'Active', quote__c=qtObj.Id, Expocad_Booth__c = lstExpoBooth[0].Id, Primary_Contact__c = contacts[0].id);
        oppExpoBoothMapping.Opportunity__c = op.Id;
        insert oppExpoBoothMapping;
        
        // insert Event Setting
        List<Event_Settings__c> lstESetting = new List<Event_Settings__c>();
        Event_Settings__c eS = new Event_Settings__c();
        eS.Name = 'EsTest';
        eS.Event_Edition__c = eE1.Id;
        eS.Stand_Contractor_notification_recipient__c = 'johncarner@gmail.com';
        lstESetting.add(eS);
        insert lstESetting;
        
        //create Email_Templates__c
        List<Email_Templates__c> lstETemp = new List<Email_Templates__c>();
        for(Integer i=0;i<1;i++)
        {
            Email_Templates__c eTemp = new Email_Templates__c(Name='TestName'+i,Template_Code__c='BDTA');
            lstETemp.add(eTemp);    
        }
        insert lstETemp;
        Email_Templates__c eTemp1 = new Email_Templates__c(Name='TestNamenew',Template_Code__c='OADC');
        insert eTemp1;
        
        //create Event_Edition_Email_Template__c
        List<Event_Edition_Email_Template__c> lstEEETemp = new List<Event_Edition_Email_Template__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Edition_Email_Template__c eEEt = new Event_Edition_Email_Template__c(Name='TestName'+i,Content__c='TestContent'+i,Email_Template_Code__c='BDTA', 
                                                                                       Subject__c='test'+i,Email_Template__c=LstETemp[0].Id,Event_Edition__c=eE1.Id);
            lstEEETemp.add(eEEt); 
        }
        insert lstEEETemp;
    /*    Event_Edition_Email_Template__c eEEt1 = new Event_Edition_Email_Template__c(Name='event1',Content__c='TestContent',Email_Template_Code__c='OADC', 
                                                                                       Subject__c='test',Email_Template__c=eTemp1.Id,Event_Edition__c=eE1.Id);
        insert eEEt1;    */
        //create TempAccount__c
        List<TempAccount__c> lstTempAcc = new List<TempAccount__c>();
        for(Integer i=0;i<3;i++)
        {
            TempAccount__c tA = new TempAccount__c(Name='TestTC'+i,Address__c='Address'+i,State__c='Delhi',Country__c='India',City__c='test', Zip__c='111111');
            lstTempAcc.add(tA); 
        }
        insert lstTempAcc;
        
        //create TempContact__c
        List<TempContact__c> lstTempCon = new List<TempContact__c>();
        for(Integer i=0;i<3;i++)
        {
            TempContact__c tC = new TempContact__c(FirstName__c='TCFrst'+i,LastName__c='TCLst'+i, Account__c=accounts[i].Id,TempAccount__c=LstTempAcc[i].Id, 
                                                   Phone__c='1234567890',Fax__c='1234567890',Email__c='abc@test.com');
            lstTempCon.add(tC); 
        }
        insert lstTempCon;
        
        //create BoothContractorMapping__c
        List<BoothContractorMapping__c> lstBoothCM = new List<BoothContractorMapping__c>();
        for(Integer i=0;i<3;i++)
        {
            BoothContractorMapping__c bCM = new BoothContractorMapping__c(Approved__c=True, ExpocadBooth__c=lstExpoBooth[i].Id, Contact__c=contacts[i].Id, 
                                                                          TempContact__c=lstTempCon[i].Id,Event_Edition__c=eE1.Id, status__c='Pending', IsManagedbyAgent__c = true);
            lstBoothCM.add(bCM);    
        }
        insert lstBoothCM;
        
        
        //create Stand_Design__c
        List<Stand_Design__c> lstStndDesign = new List<Stand_Design__c>();
        for(Integer i=0;i<3;i++)
        {
            Stand_Design__c oDesign = new Stand_Design__c(Account__c=accounts[i].Id,ExpocadBooth__c=lstBoothCM[i].ExpocadBooth__c,Booth_Design_Status__c='Tentative Approval',
                                                          Booth_Design_Submitted_On__c=system.today(),Submitted_to_Venue_On__c=system.today(),Is_Rejected__c=false);
            lstStndDesign.add(oDesign);
        }
        insert lstStndDesign;
        //create Stand_Detail__c
        List<Stand_Detail__c> lstStndDtail = new List<Stand_Detail__c>();
        for(Integer i=0;i<3;i++)
        {
            Stand_Detail__c oDetail = new Stand_Detail__c(Account__c=accounts[i].Id,ExpocadBooth__c=lstBoothCM[i].ExpocadBooth__c,IsRigging__c=true,IsDoubleDecker__c=true,
                                                          Contractor_Agreement_CA__c=true, Is_Heavy_Machinery__c=true);
            lstStndDtail.add(oDetail);
        }
        insert lstStndDtail;
        
    }
    
    @isTest 
    static void validateBoothContractorMapping()
    {
        list<BoothContractorMapping__c> bCM=[select id, ExpocadBooth__c, Contact__c,Contact__r.AccountId, Event_Edition__c, status__c, Agent_Contact__r.Account.Name, IsManagedbyAgent__c  
                                             from BoothContractorMapping__c LIMIT 1];
        list<Stand_Design__c> objSdesign=[SELECT Id,File_Name__c,AttachmentId__c,Stand_Type__c,Booth_Design_Status__c,ExpocadBooth__c  
                                          from Stand_Design__c ];
        string mailCC = null;
        string accId=bCM[0].Contact__r.AccountId;
        string  boothStatus=objSdesign[0].Booth_Design_Status__c;
        string boothId=bCM[0].ExpocadBooth__c;
        string eEId=bCM[0].Event_Edition__c;
        string boothContMappingId = bCM[0].Id;
        string agentId = '';
        list<string> lststatus=new list<string>{'Pending Review','Pending Sales Approval','Contractor Resubmit (Incomplete)','Pending Venue Approval','Submit to Venue',
            'Tentative Approval','Cancelled','No Design','Test','Edited Stand Details'};
                for(string bStatus:lststatus)
            {   
                EmailConfirmToContractorForBoothStatus.wrapperClass objWrpr=new EmailConfirmToContractorForBoothStatus.wrapperClass();
                objWrpr=EmailConfirmToContractorForBoothStatus.captureEmailTemplate(bStatus,eEId,accId,boothId,agentId);
                system.assertNotEquals(null, objWrpr,'check for null');
            }
        
        List<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpoBoothMaping =[SELECT Id from Opportunity_ExpoCAD_Booth_Mapping__c];
        list<string> lstEBoothId = new list<string>();
        for(Opportunity_ExpoCAD_Booth_Mapping__c eb: lstExpoBoothMaping)
        {
            lstEBoothId.add(string.valueOf(eb.id)); 
        }
        System.debug('lstExpoBoothMaping' + lstExpoBoothMaping );
        
        EmailConfirmToContractorForBoothStatus.sendEmailToContractoForBoothStatus(eEId,accId,boothStatus,boothId,boothContMappingId,mailCC,'');
        //CCEN-389 calling the method sendEmailToOpsAdmin
        EmailConfirmToContractorForBoothStatus.sendEmailToOpsAdmin('abc',eEId,lstEBoothId);
        EmailConfirmToContractorForBoothStatus.sendRejectMailToExh(boothContMappingId, 'Reject Email');
        // adding below check for covering the code of method sendRejectMailToExh
        bcm[0].IsManagedbyAgent__c = false;
        update bcm;
        boothContMappingId = bCM[0].Id;
        EmailConfirmToContractorForBoothStatus.sendRejectMailToExh(boothContMappingId, 'Reject Email');
        
        // Insert Stand_Design_Message_History__c
        Stand_Design_Message_History__c sDMH = new Stand_Design_Message_History__c(Content__c ='this is reject email', BoothContractorMapping__c=bCM[0].Id,
                                               Email_Template_Code__c='OBC',Is_Forwarded__c = True, CCEmail__c ='johntest@gmail.com', ToEmail__c='carter13@test.com',Subject__c='TestSubject');
        insert sDMH;
        EmailConfirmToContractorForBoothStatus.forwardEmailToCon(sDMH);
        
    }
    
}