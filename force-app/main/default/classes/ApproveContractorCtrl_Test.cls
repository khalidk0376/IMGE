/**
* Created By    :  Girikon(Hemendra)
* Created On    :  05/14/2018
* @description  : This test class covers the apex class "ApproveContractorCtrl" and "ApproveContractorExtensionCntr" following methods:
                  Requests,getSingleApprovalRequest,getContractorList,getContractorByStatus,getapproval,rejectContarctor,getStandDetailsCtr,getStandDesignCtr,submitDesignCtr,
                  SaveStandDetailCtr,getBaseUrl,returnStandDesignStatusData,updateRecordAndSendEmail,
                  findSubcontractors,getNotes,saveNote,getPicklistValues,getEventDetails,getStandDesignAttTypes,saveChunk,saveTheFile
* Methods       : DataSetUp,validate_BoothContractor,validate_Contractorbyfilter,validate_ContractorbyfilterCtr,validate_BoothContractorMapp,validate_BoothContractorMapping,validate_BoothContractorMapping_StandDesign
* Apex Class    : ApproveContractorCtrl (86%) 
*
* Modification Log----- 
* Modified by   : Girikon(Garima,Sunil[CCEN-589 (Jan 10 2019)]),Girikon(Ashish) [CCEN-314 (Sept 26 2018),CCEN-430 (Dec 17 2018)],Girikon(Prashant) [CCEN-326 (Oct 3 2018),CCEN-682(Mar 22 2019),Girikon(Rajeev [BK-2876 15 Dec 2019]],[Aishwarya - [BK-10223] 23 Dec 2020]
**/
@isTest
private class ApproveContractorCtrl_Test{
    
    //SetUp data for test class
    @testSetup
    static void dataSetUp(){
        //Create user
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User[] userList = new User[]{};
        User usr = new User();       
        usr.FirstName = 'Alex';
        usr.LastName = 'Sherwood';
        usr.Email = 'test@wexeurope.com';
        usr.Username = 'astest@wexeurope.com';
        usr.Alias = 'astest';
        usr.ProfileId = pro.Id;
        usr.TimeZoneSidKey    = 'America/Denver';
        usr.LocaleSidKey      = 'en_US';
        usr.EmailEncodingKey  = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        userList.add(usr);
        insert userList;
        
        //Create User_Type__c
        User_Type__c oUT = new User_Type__c(Name='Stand Contractor');
        insert oUT;
        
        //Create Account
        List<Account> accounts = new List<Account>();
        for(Integer i=0;i<3;i++)
        {
            Account a = new Account(Name='TestAcc' + i);
            accounts.add(a);    
        }
        insert accounts;
        
        //create some contacts
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0;i<3;i++)
        {
            Contact c = new Contact(AccountId = accounts[i].Id, FirstName = 'TestConFirst'+i, LastName = 'TestConLast'+i, Email='abc@test.com',MobilePhone='9876598765');
            contacts.add(c);    
        }
        insert contacts;
        
        //create Event_Edition__c
        List<Event_Edition__c> lstEE = new List<Event_Edition__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Edition__c ee = new Event_Edition__c(Name='TestName'+i,Event_Currency__c='USD',Event_Code__c='XYZ');
            lstEE.add(ee);  
        }
        insert lstEE;
        
        Opportunity oOpportunity = new Opportunity( Name = 'Expocad Opportunity', CloseDate = Date.today().addDays(7), StageName = 'Discover', EventEdition__c = lstEE[0].Id, AccountId = accounts[1].Id, Billing_Contact__c = contacts[1].Id, Payment_Status__c='Not Paid' );
        insert oOpportunity;
        
        oOpportunity.Exhibitor_Paid_By__c = 'Exhibitor Paid by Agent';
        oOpportunity.StageName = 'Closed Won';
        oOpportunity.Operations_Contact__c = contacts[1].Id; 
        update oOpportunity;
        
        //create ExpocadBooth__c
        List<ExpocadBooth__c> lstExpoBooth = new List<ExpocadBooth__c>();
        for(Integer i=0;i<3;i++)
        {
            ExpocadBooth__c eB = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.'+i, status__c = 'Rented', Opportunity__c =oOpportunity.id ,Dimensions__c='abc');
            lstExpoBooth.add(eB);   
        }
        insert lstExpoBooth;
        
        //create ExpocadBooth__c
        List<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpoBoothMap = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        for(Integer i=0;i<3;i++)
        {
            Opportunity_ExpoCAD_Booth_Mapping__c eBm = new Opportunity_ExpoCAD_Booth_Mapping__c(Expocad_Booth__c =lstExpoBooth[i].id, status__c = 'Active', Opportunity__c =oOpportunity.id);
            lstExpoBoothMap .add(eBm);   
        }
        insert lstExpoBoothMap ;
        
        //create Email_Templates__c
        List<Email_Templates__c> lstETemp = new List<Email_Templates__c>();
        for(Integer i=0;i<1;i++)
        {
            Email_Templates__c eTemp = new Email_Templates__c(Name='TestName'+i,Template_Code__c='BDTA');
            lstETemp.add(eTemp);    
        }
        insert lstETemp;
        //create Event_Edition_Email_Template__c
        List<Event_Edition_Email_Template__c> lstEEETemp = new List<Event_Edition_Email_Template__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Edition_Email_Template__c eeet = new Event_Edition_Email_Template__c(Name='TestName'+i,Content__c='TestContent'+i,Email_Template_Code__c='BDTA', Subject__c='test'+i,Email_Template__c=LstETemp[0].Id,Event_Edition__c=LstEE[i].Id);
            lstEEETemp.add(eeet);   
        }
        insert lstEEETemp;
        
        //create TempAccount__c
        List<TempAccount__c> lstTempAcc = new List<TempAccount__c>();
        for(Integer i=0;i<3;i++)
        {
            TempAccount__c ta = new TempAccount__c(Name='TestTC'+i,Address__c='Address'+i,State__c='DL',Country__c='IN',City__c='test', Zip__c='111111');
            lstTempAcc.add(ta); 
        }
        insert lstTempAcc;
        
        //create TempContact__c
        List<TempContact__c> lstTempCon = new List<TempContact__c>();
        for(Integer i=0;i<3;i++)
        {
            TempContact__c tc = new TempContact__c(FirstName__c='TCFrst'+i,LastName__c='TCLst'+i, Account__c=Accounts[i].Id,TempAccount__c=LstTempAcc[i].Id, Phone__c='1234567890',Fax__c='1234567890',Email__c='abc@test.com');
            lstTempCon.add(tc); 
        }
        insert lstTempCon;
        
        //create BoothContractorMapping__c list
        List<BoothContractorMapping__c> lstBoothCM = new List<BoothContractorMapping__c>();
        for(Integer i=0;i<3;i++)
        {
            BoothContractorMapping__c bcm = new BoothContractorMapping__c(Approved__c=True, ExpocadBooth__c=LstExpoBooth[i].Id,Opp_Booth_Mapping__c=lstExpoBoothMap[i].Id, Contact__c=contacts[i].Id,Booth_Design_Status__c='No Design',TempContact__c=LstTempCon[i].Id,Event_Edition__c=LstEE[i].Id, status__c='Rejected');
            lstBoothCM.add(bcm);    
        }
        insert lstBoothCM;

        //create Stand_Design__c list
        List<Stand_Design__c> lstStndDesign = new List<Stand_Design__c>();
        for(Integer i=0;i<3;i++)
        {
            Stand_Design__c oDesign = new Stand_Design__c(Account__c=Accounts[i].Id,Opp_Booth_Mapping__c=lstExpoBoothMap[i].Id,ExpocadBooth__c=LstBoothCM[i].ExpocadBooth__c,Booth_Design_Status__c='Tentative Approval',
                Booth_Design_Submitted_On__c=system.today(),Submitted_to_Venue_On__c=system.today(),Is_Rejected__c=false);
            lstStndDesign.add(oDesign);
        }
        insert lstStndDesign;
        //create Stand_Detail__c
        List<Stand_Detail__c> lstStndDtail = new List<Stand_Detail__c>();
        for(Integer i=0;i<3;i++)
        {
            Stand_Detail__c oDetail = new Stand_Detail__c(Account__c=Accounts[i].Id,Amount__c = '25',Opp_Booth_Mapping__c=lstExpoBoothMap[i].Id,ExpocadBooth__c=LstBoothCM[i].ExpocadBooth__c,IsRigging__c=true,IsDoubleDecker__c=true,Contractor_Agreement_CA__c=true, Is_Heavy_Machinery__c=true,IsReceived__c = true,Receipt__c= '27');
            lstStndDtail.add(oDetail);
        }
        insert lstStndDtail;
        
        //create Note__c
        List<Note__c> lstNote = new List<Note__c>();
        {
            for(Integer i=0;i<3;i++)
            {
                Note__c objNote= new Note__c(Note__c='TestNote'+i,Account__c=Accounts[i].Id,ExpocadBooth__c=LstBoothCM[i].ExpocadBooth__c);
                objNote.Opp_Booth_Mapping__c = lstExpoBoothMap[i].Id;
                lstNote.add(objNote);
            }
            insert lstNote;
            String key=string.valueof(lstNote[0].Account__c)+'_'+string.valueof(lstNote[0].Opp_Booth_Mapping__c);
        }
    }
    
    @isTest static void validateBoothContractor() 
    {
        string evntId='test';
        list<BoothContractorMapping__c> bcm=[select id,Event_Edition__c from BoothContractorMapping__c];
        List<Event_Edition__c> ee1 =[Select id,Name From Event_Edition__c];
        List<Event_Settings__c> es1 = [SELECT Id,Name,Event_Edition__c,Event_Edition__r.Event_Code__c FROM Event_Settings__c WHERE Event_Edition__c =:ee1[0].id];
        string evntId1;
        Id snglId=bcm[0].Id;
        string evntEditionID=bcm[0].Event_Edition__c;
        list<string> lststatus=new list<string>{'All','Approved','Not Approved','All Approve','Rejected'};
        for(string status:lststatus)
        {
            List<BoothContractorMapping__c> lstBCM =ApproveContractorCtrl.getAllContractor(ee1[0].Id,status);
        }
        if(es1.size()>0)
        {
           evntid1 =  es1[0].Event_Edition__c;
        }
        Event_Settings__c es = ApproveContractorCtrl.getEventDetails(evntid1);
        list<Stand_Design_Attachments__c> stndDesignA = ApproveContractorCtrl.getStandDesignAttTypes();
        Test.startTest();
        List<BoothContractorMapping__c> lstBCM2 =ApproveContractorCtrl.getSingleApprovalRequest(snglId);
        System.assertEquals(1, LstBCM2.size(), true);
        List<BoothContractorMapping__c> lstBCM3 =ApproveContractorCtrl.getContractorList();
        System.assertEquals(3, lstBCM3.size(), true);
        
       
        Test.stopTest();
    }
    
   
   @isTest static void validateContractorbyfilterCtr()
    {   
        ApproveContractorCtrl.wrapperClass wrp = new ApproveContractorCtrl.wrapperClass(); 
        
        //Create Account
        Account acc = new Account(Name='TestAccount');
        insert acc;
        System.assertNotEquals(null, acc, true);
        
        //create contact
        Contact oCon = new Contact(AccountId = acc.Id, FirstName = 'TestConFirst', LastName = 'TestConLast', Email='abc@test.com');
        insert oCon;
        
        //create Event_Edition__c
        Event_Edition__c ee = new Event_Edition__c(Name='TestName',Event_Currency__c='USD',Event_Code__c='XYZ',Event_Edition_Code__c='abx');
        insert ee;
        
        
    
        //create ExpocadBooth__c
        ExpocadBooth__c eB = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.', status__c = 'Rented');
        insert eB;
        
        //create BoothContractorMapping__c 
        BoothContractorMapping__c bcm = new BoothContractorMapping__c(Approved__c=True, Contact__c=oCon.Id,Booth_Design_Status__c='No Design',Event_Edition__c=ee.Id, status__c='Rejected', Performance_Bond_Submitted__c= false, IsManagedbyAgent__c = true);
           
        insert bcm;
        string evntEditionID=bcm.Event_Edition__c;
        Test.startTest();
        ApproveContractorCtrl.ExhibitorsWrapper lstWrpr=new ApproveContractorCtrl.ExhibitorsWrapper();
        
        lstWrpr=ApproveContractorCtrl.getAllFilterContractor('Pending','Approved', '','Test',true, true,true,true, true,true, true,evntEditionID,'Id','Asc',1,10);
      //  lstWrpr=ApproveContractorCtrl.getAllFilterContractor('All','All', 'All','',false, false,false,false, false,false, false,evntEditionID,'Id','Asc',1,10);
      lstWrpr=ApproveContractorCtrl.getAllFilterContractor('All','All', 'All','',false, false,false,true, false,false, false,evntEditionID,'Id','Asc',1,10);
      //  lstWrpr=ApproveContractorCtrl.getAllFilterContractor('All','All', 'All','',false, false,true,false, false,false, false,evntEditionID,'Id','Asc',1,10);
        
        list<ApproveContractorCtrl.StandDesignStatus> listStandDesignStatus =new list<ApproveContractorCtrl.StandDesignStatus>();

        Map<String, String> mapStandDesignStatus = new Map<String , String>();  
        listStandDesignStatus = ApproveContractorCtrl.getDesignationInfo(evntEditionID); 
        mapStandDesignStatus = ApproveContractorCtrl.getAggregateResult(evntEditionID);
        list<Opportunity_ExpoCAD_Booth_Mapping__c>expBth =  ApproveContractorCtrl.getAgentBooths(evntEditionID,'',''); 
        Map<String,Stand_Design__c> mapStDsn = ApproveContractorCtrl.getAllAgentPavilionSpaceStandDesign(evntEditionID);
        Map<String,Stand_Detail__c> mapStDtl = ApproveContractorCtrl.getAllAgentPavilionSpaceStandDetail(evntEditionID);
        string rejectContarctorExtn = ApproveContractorExtensionCntr.rejectContarctorExtn(bcm.id,'',true);
        List<BoothContractorMapping__c> booth = [select id, Contact__c,TempContact__r.TempAccount__c,TempContact__r.TempAccount__r.Address__c,ExpocadBooth__c,TempContact__r.TempAccount__r.Zip__c,Event_Edition__c,TempContact__r.TempAccount__r.State__c,TempContact__r.TempAccount__r.Country__c,TempContact__r.TempAccount__r.City__c,TempContact__r.TempAccount__r.Name,TempContact__r.Phone__c, TempContact__r.MobilePhone__c, TempContact__r.Email__c,ExpocadBooth__r.Booth_Number__c, TempContact__r.Account__c,TempContact__c,TempContact__r.FirstName__c,TempContact__r.LastName__c from BoothContractorMapping__c];
        string  Extn = ApproveContractorExtensionCntr.updateTmpAccountContactExtn(booth[0].id,booth);
        Test.stopTest();
    }
    @isTest static void validateBoothContractorMapp()
    {
        list<BoothContractorMapping__c> bcm=[select id from BoothContractorMapping__c limit 1];
        list<TempAccount__c> lstTempAcc1=[SELECT Id, Name from TempAccount__c];
        TempContact__c tc = new TempContact__c(FirstName__c='TCFrst',LastName__c='TCLst',TempAccount__c=LstTempAcc1[0].Id, 
         Phone__c='1234567890',Fax__c='1234567890',Email__c='abc@test.com');
        insert tc;
        System.assertNotEquals(null, tc, true);
        
        bcm[0].TempContact__c=tc.id;
        update bcm[0];
        Id snglId1=bcm[0].Id;
        
        Test.startTest();
        
        string sABC= ApproveContractorCtrl.getapproval(snglId1,'opsAdmin');
        
        Test.stopTest();
    }
    
    @isTest static void validateBoothContractorMapping()
    {
       // List<BoothContractorMapping__c> booth = [select id, Contact__c,TempContact__r.TempAccount__c,TempContact__r.TempAccount__r.Address__c,ExpocadBooth__c,TempContact__r.TempAccount__r.Zip__c,Event_Edition__c,TempContact__r.TempAccount__r.State__c,TempContact__r.TempAccount__r.Country__c,TempContact__r.TempAccount__r.City__c,TempContact__r.TempAccount__r.Name,TempContact__r.Phone__c, TempContact__r.MobilePhone__c, TempContact__r.Email__c,ExpocadBooth__r.Booth_Number__c, TempContact__r.Account__c,TempContact__c,TempContact__r.FirstName__c,TempContact__r.LastName__c from BoothContractorMapping__c];
        list<BoothContractorMapping__c> bcm=[select id,TempContact__c,contact__c,contact__r.accountId,ExpocadBooth__c ,Event_Edition__c from BoothContractorMapping__c LIMIT 1];
        Id accId= bcm[0].contact__r.accountId;
        string bthId=bcm[0].ExpocadBooth__c;
        string bthConId=bcm[0].id;
       // String Attchid ='';
        List<Stand_Design_Message_History__c> listSDMH = new List<Stand_Design_Message_History__c>();
        Stand_Design_Message_History__c sDMH = new Stand_Design_Message_History__c(BoothContractorMapping__c = bthConId, Content__c='ABC', Is_Forwarded__c = false, Subject__c='ABC', ToEmail__c = 'abc@gc.com');
        listSDMH.add(sDMH);
        insert listSDMH;
        list<Stand_Design__c> listSDesign=ApproveContractorCtrl.getStandDesignCtr(accId,bthId,'','');
        System.assertEquals(0,listSDesign.size(), true);
        list<Stand_Detail__c> listSDetail=ApproveContractorCtrl.getStandDetailsCtr(accId,bthId,'','');
        System.assertEquals(0,listSDetail.size(), true);
        list<Stand_Design__c> listSDesign2=ApproveContractorCtrl.SubmitDesignCtr(accId);
        System.assertEquals(1,listSDesign2.size(), true);
        string standCntr = ApproveContractorCtrl.deleteStandContractor(bthConId,'tested');
        System.assertNotEquals(null,standCntr, true);
        List<Stand_Design_Message_History__c> standDesgnMsg = ApproveContractorCtrl.getStandDesignMessagesCtr(bthConId);
        String standDesgnMsg1 = ApproveContractorCtrl.forwardEmailToContractor(sDMH);
        System.assertNotEquals(null,standDesgnMsg, true);
        
        //String updateTmp  = ApproveContractorCtrl.updateTmpAccountContact(bthConId, bcm);
        
        Map<String,List<String>> objResults = ApproveContractorCtrl.getDependentStateMap('Account','billingCountryCode','billingStateCode');
    }
    
    @isTest static void validateBoothContractorMappingStandDesign()
    {   
        Stand_Detail__c objSdtail=[SELECT ID, Agent_Account__c from Stand_Detail__c limit 1];
        list<BoothContractorMapping__c> bcm=[select id, ExpocadBooth__c,Agent_Contact__r.AccountId, Contact__c,Contact__r.AccountId, Event_Edition__c, status__c 
                                             from BoothContractorMapping__c LIMIT 1];
        Id snglId=bcm[0].Id;
        string evntEditionID=bcm[0].Event_Edition__c;
        string agentId =bcm[0].Agent_Contact__r.AccountId;
        string bthId =bcm[0].ExpocadBooth__c;
        list<Stand_Design__c> objSdesign=[SELECT Id,File_Name__c,AttachmentId__c,Stand_Type__c,Booth_Design_Status__c,ExpocadBooth__c  
                                          from Stand_Design__c ];
        string accId=bcm[0].Contact__r.AccountId;
        string boothStatus=ObjSdesign[0].Booth_Design_Status__c;
        string boothStatus1='Contractor Resubmit (Incomplete)';
        string boothId=bcm[0].ExpocadBooth__c;
        string eeId=bcm[0].Event_Edition__c;
        string boothContMappingId = bcm[0].Id;
        Test.startTest();
        string sVar=ApproveContractorCtrl.rejectContarctor(snglId,'',true);
        string mailCc = 'abc@gmail.com';
        string sVar2=ApproveContractorCtrl.SaveStandDetailCtr(objSdtail,accId,EEId,boothId,boothStatus,boothContMappingId);
        System.assertEquals('Stand Detail has been updated and Email sent successfully',sVar2, true);
        string sVar3=ApproveContractorCtrl.savePerformanceBond(objSdtail,accId,EEId,boothId,boothStatus);
        System.assertEquals('Details has been updated successfully',sVar3, true);
        ApproveContractorCtrl.getBaseUrl();
        ApproveContractorCtrl.ReturnStandDesignStatusData(accId,boothStatus,boothId,EEId,'');
        string sMsg=ApproveContractorCtrl.UpdateRecordAndSendEmail(accId,boothStatus1,boothId,EEId,boothContMappingId,'Test Email Content','Test Email Subject',mailCc,'');
        System.assertEquals('Email Successfully Sent',sMsg, true);
        ApproveContractorCtrl.FindSubcontractors(snglId,accId,boothId);
        list<Note__c> lstNote=ApproveContractorCtrl.getNotes(boothId,accId);
        System.assertEquals(0,LstNote.size(), true);
        Note__c objNote=new Note__c(Note__c='test', Account__c=accId,ExpocadBooth__c=boothId);
        ApproveContractorCtrl.saveNote(ObjNote);
        string searchKeyword2='test';
        
        String obj = 'Account';
        String flnm = 'billingCountryCode';
        List<String> pick = ApproveContractorCtrl.getPicklistValues(obj,flnm);
        system.assertNotEquals(null, pick, true);
        
        /*
        List<Attachment> ap = [SELECT Id, Body, ContentType  FROM Attachment];
        Id mapID = bcm[0].id;
        String fileName1 = 'abc';
        String base64Data2= 'xys';
        String contentType12;
        String att;
        Stand_Design__c sd = [select id from Stand_Design__c limit 1];
        attachment at = new attachment();
        at.ParentId = sd.id;
        at.Name = 'test';
        at.Body = blob.toPdf('testing Only');
        insert at;
        List<String> attachid = new List<String>();
        attachid.add(at.id);
        if(ap.size()>0)
        {
            contentType12 = ap[0].ContentType;
            att = ap[1].Id;
            attachid.add(at.Id);
        }
        */
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'StandDesign',
            PathOnClient = 'Penguins.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion_1;
        
        Stand_Design__c sd = [Select Id FROM Stand_Design__c LIMIT 1];
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = sd.Id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        
        List<String> attachid = new List<String>();
        attachid.add(contentlink.contentdocumentid);
        
        String standtype123 = ObjSdesign[0].Stand_Type__c;
        Opportunity_ExpoCAD_Booth_Mapping__c lstStandDesign = [select id,Opportunity__r.Exhibitor_Paid_By__c,Opportunity__r.Name,Opportunity__r.Operations_Contact__r.Account.Name from Opportunity_ExpoCAD_Booth_Mapping__c limit 1];
        String boothid1 = lstStandDesign.Id;
        List<DesignAttachmentType__c> newDesignAttachment = [select File_Type__c , IsRejected__c,  AttachmentId__c from DesignAttachmentType__c limit 1];
        String fileType;
        string AttchId;
        if(newDesignAttachment.size()>0)
        { 
           fileType = newDesignAttachment[0].File_Type__c;
           AttchId = newDesignAttachment[0].AttachmentId__c;
        }
        ApproveContractorCtrl.designRejected(AttchId, bthId, accId, evntEditionID, agentId);
        Account acc1 = [select id from account limit 1];
        id accountid1 = acc1.Id;
        String fileId1 = '';
        if(attachid != null && !attachid.IsEmpty())
        {
            ApproveContractorCtrl.getAttachmentbody(attachid);
             
        }
        Test.stopTest();     
    }
    static testMethod void standContMethod()
    {
        //insert account data
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null, true);
        
        User_Type__c uType = new User_Type__c(Name ='Stand Contractor');
        insert uType;
        System.AssertEquals(uType.Name, 'Stand Contractor', true);
        
        Contact con = new Contact(AccountId = acc.Id, FirstName = 'TestConFirst', LastName = 'TestConLast',phone='12346456', Email='abc@test.com',MailingCountry='USA',
                                  MailingStreet='123 Lake',MailingCity='Dallas',MailingState='Texas',MailingPostalCode='75039',Type__c=uType.Id);
        insert con;
        System.AssertNotEquals(con, null, true);
        //Fetch community user profile from label
        string commUsrProfile='';
        If(Label.Community_User_Profile!= NULL)
        {
            commUsrProfile= Label.Community_User_Profile;
        }
        else
        {
            commUsrProfile='Customer Community Login User Custom';            
        }
        //Fetch community user profile
        Profile pro =[select id , Name from Profile Where Name =:commUsrProfile];
        
        User usr = new User();            
        usr.FirstName = 'Alex';
        usr.LastName = 'Sherwood';
        usr.Email = 'test@girikon.com';
        usr.Username = 'Donald@girikon.com';
        usr.Alias = 'astest';
        usr.ProfileId = pro.Id;
        usr.TimeZoneSidKey    = 'America/Denver';
        usr.LocaleSidKey      = 'en_US';
        usr.EmailEncodingKey  = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.ContactId = con.Id;
        insert usr;
        
        System.runAs(usr)
        {
            //insert EventEdition
            Event_Edition__c eventEdition1 = new Event_Edition__c(Name='TOC 2018', Event_Edition_Code__c='xyz',Event_Code__c='TOC18',Event_Currency__c='USD',End_Date__c=System.Today(),Start_Date__c=System.Today());
            insert eventEdition1;
            System.assertEquals(eventEdition1.Event_Code__c,'TOC18', 'Event Code');
            
            BoothContractorMapping__c BoothMappng = new  BoothContractorMapping__c(Contact__c=con.id, Event_Edition__c=eventEdition1.id ,   CurrencyIsoCode='USD' ,Is_Self_Managed__c=false);
            insert BoothMappng;
            System.AssertNotEquals(BoothMappng, null, true);
            
            ContactEventEditionMapping__c cEEMNew = new ContactEventEditionMapping__c(SFEventEditionID__c=eventEdition1.Id,SFContactID__c=con.Id ,IsEmailSent__c=true ,User_Type__c =uType.id);
            insert cEEMNew;
            
            Test.startTest();
            string srcText = 'test';
            ApproveContractorCtrl.getloginDetail(eventEdition1.id , acc.id ,con.id);
            ApproveContractorCtrl.sendEmails(con.id , eventEdition1.id);
            ApproveContractorCtrl.resetPasswords(con.id);
            ApproveContractorCtrl.getDuplicateContacts(con);
            Boolean isSandbox = ApproveContractorCtrl.isSandbox();
            Account acc1 = ApproveContractorCtrl.getDuplicateAccount(eventEdition1.Event_Edition_Code__c,srcText);
            Test.stopTest(); 
        }
    }
    
    //@isTest 
    public static testMethod void validateDesignAndDetail(){ 
        //Opportunity_ExpoCAD_Booth_Mapping__c oppBth =  [select id from Opportunity_ExpoCAD_Booth_Mapping__c where Display_Name__c != null And Opportunity__c != null  limit 1 ];
        Opportunity_ExpoCAD_Booth_Mapping__c oppBth =  [select id from Opportunity_ExpoCAD_Booth_Mapping__c where Opportunity__c != null  limit 1 ];
        BoothContractorMapping__c bcmCon = [select id from BoothContractorMapping__c limit 1];  
        Account acc = [select id from Account limit 1];
        Event_Edition__c edtn = [select id,Event_Code__c From Event_Edition__c limit 1];
        StandContractorUtils.getBoothsMappingFromAccId(edtn.Event_Code__c,acc.id);

        //create Stand_Design__c list
        List<Stand_Design__c> lstStndDesign = new List<Stand_Design__c>();
        for(Integer i=0;i<1;i++)
        {
            Stand_Design__c oDesign = new Stand_Design__c(Account__c = acc.Id,Event_Edition__c = edtn.id,Opp_Booth_Mapping__c = oppBth.Id,BoothContractorMapping__c = bcmCon.id,Booth_Design_Status__c='Tentative Approval',Booth_Design_Submitted_On__c=system.today(),Submitted_to_Venue_On__c=system.today(),Is_Rejected__c=false);
            lstStndDesign.add(oDesign);
        }
        insert lstStndDesign;
        System.assertEquals(lstStndDesign.size(),1,'Stand design list size equal to 1');
        //create Stand_Detail__c
        List<Stand_Detail__c> lstStndDtail = new List<Stand_Detail__c>();
        for(Integer i=0;i<1;i++)
        {
            Stand_Detail__c oDetail = new Stand_Detail__c(Account__c = acc.Id,Amount__c = '25',Event_Edition__c = edtn.id,Opp_Booth_Mapping__c = oppBth.Id,BoothContractorMapping__c = bcmCon.id,IsRigging__c=true,IsDoubleDecker__c=true,Contractor_Agreement_CA__c=true, Is_Heavy_Machinery__c=true,IsReceived__c = true,Receipt__c= '27');
            lstStndDtail.add(oDetail);
        }
        insert lstStndDtail;
        System.assertEquals(lstStndDtail.size(),1,'Stand detail list size equal to 1');
        
        list<Stand_Design__c> lstDesign     = StandContractorUtils.getSingleStandDesign(oppBth.Id, acc.Id, edtn.Id, '');
        list<Stand_Design__c> lstDesignAgn  = StandContractorUtils.getSingleStandDesign(oppBth.Id, acc.Id, edtn.Id,acc.Id);
        
        List<Stand_Detail__c> lstStndDtails  = StandContractorUtils.getSingleStandDetail(oppBth.Id, acc.Id, edtn.Id, '');
        List<Stand_Detail__c> lstStndDtailsAgn =  StandContractorUtils.getSingleStandDetail(oppBth.Id, acc.Id, edtn.Id,acc.Id);
        
        Map<String,Stand_Detail__c> mapAccStndDetail = StandContractorUtils.getAllStandDetail(edtn.Event_Code__c);
        Map<String,Stand_Design__c> mapAccStndDesign = StandContractorUtils.getAllStandDesign(edtn.Event_Code__c);
        Test.startTest();
        
        Account accnt = new Account();
        accnt.Name ='TestAccount';
        insert accnt;
        Account accountId = [Select Id FROM Account where Id =:accnt.Id];
        
        ApproveContractorCtrl.saveStandDesignFiles(bcmCon.id, 'xys',string.valueOf(oppBth.Id),'Non Complex',acc.id,string.valueOf(edtn.Id),'');
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'StandDesign',
            PathOnClient = 'Penguins.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion_1;
        
        String filetype = 'Non-Complex';
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = lstStndDesign[0].Id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        
        ApproveContractorCtrl.prepareFileTitle(contentlink.ContentDocumentId, contentVersion_1.Title, lstStndDesign[0].Id, filetype);
        //Id attId = StandContractorUtils.saveStandDesignChunk(bcmCon.id, 'xys', 'text',null,'Non Complex', string.valueOf(oppBth.Id), 'Text',acc.Id, string.valueOf(edtn.Id),'');
        //Id attId2 = StandContractorUtils.saveStandDesignChunk(bcmCon.id, 'xys', 'text',attId,'Non Complex', string.valueOf(oppBth.Id), 'Text',acc.Id, string.valueOf(edtn.Id),'');
        //System.assertNotEquals(null,attId,'Stand design chunk is not null');
        Test.stopTest();
    }
}