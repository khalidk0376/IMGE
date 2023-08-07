/**
 * Created By   :   Girikon(Mukesh)
 * Created On   :   12/03/2018
 * @description :   Test class of CommunityExhibitorBadgeCtrl controller
 * Apex Class   :   CommunityExhibitorBadgeCtrl
 
 * Modification Log----- 
 * Modified by  :   Girikon(Mukesh [Dec 3 2018]), Girikon(Prashant [CCEN-662 Feb 13 2019], [CCEN-737 April 4 2019]),Girikon(Rajeev [BK-2188 Aug 23 2019], [Aishwarya BK-2895 Nov 21 2019])
 **/
@IsTest
public class CommunityExhibitorBadgeCtrl_Test  
{ 
    //SetUp data for test class
    @isTest static void opsBadgesTest()
    {
        Test.startTest();
     //   String evntCode ='sbvite9';
       // CommunityExhibitorBadgeCtrl.getDocumentId(evntCode);
        
        Utility.isRebookInProcess = True ;
         //Create Accountss 
        Account acc = new Account(Name='TstAccFrst');
        insert acc;
        
        //Create APXTConga4__Conga_Template__c
        APXTConga4__Conga_Template__c conga = new APXTConga4__Conga_Template__c( APXTConga4__Template_Type__c = 'Document');
        insert conga;
         
        //Insert event edition image
        Document doc = new Document(); 
        doc.Name = 'TEV17-Event-Image'; 
        doc.FolderId = UserInfo.getUserId();//documents[0].FolderId;
        doc.IsPublic = true; 
        doc.Body =Blob.valueOf('Some Text'); 
        doc.ContentType = 'image/jpeg';
        doc.DeveloperName = 'Badge_CSV_File_Without_VIP_Match';
        insert doc;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'TOC Europe', CurrencyISOCode = 'USD', Package_Identifier__c = 'toc' , Event_Edition_Pool__c = 'tOC');
        oEventseries.Status__c = 'Active';
        insert oEventseries;
        
        //Create Event_Edition
        Event_Edition__c evntEditon = new Event_Edition__c(Name='TestName',CurrencyIsoCode='USD',Tab1__c='Booth Application',Tab4__c='Contact Information', Tab8__c='Transfer & Payments',Event_Currency__c ='USD',Event_Code__c='toc',Event_Edition_Status__c='Confirmed', Contract_Template__c = conga.id,End_Date__c=date.today(),Event_Website__c='http://www.testevent.com',Event_Edition_Image_URL__c= doc.Id,Invoice_From_Email_ID__c='Test', Max_Hold_Booth__c=15, Max_Hold_Days__c=365, Measurement__c='Feet',Next_Edition__c='2019', Payment_Schedule__c='50-50', Quote_Template__c=conga.id,Start_Date__c=date.today()-1,Venue__c='Las Vegas Convention Center', Year__c='2019',Informa_Logo__c=doc.Id, Cutoff_Date_1__c=date.today()+1,Cutoff_Date_2__c=date.today()-10,Cutoff_Date_3__c=date.today()-15);
        evntEditon.Part_of_Series__c = oEventseries.Id;
        insert evntEditon ;

        Product2 prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth', Number_of_Corners__c = 0);
        prd1.Event_Product_Type__c='Sponsorship';
        insert prd1;
        
        //Create Opportunity
        Opportunity opp = new Opportunity(Name='Test opp', StageName='Needs Assessment', EventEdition__c = evntEditon.id,AccountId=acc.id,EventSeries__c='Arab Health',Event_Edition__c='Arab Health 2016',CloseDate=date.today()+19);
        insert opp;
                        
        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acc.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = opp.Id;
        qtObj.CurrencyIsoCode='BRL';
        insert qtObj;
        
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj.Id;
        qlObj.SBQQ__Product__c = prd1.Id;
        qlObj.Product_Local_Name__c='';
        qlObj.Line_Description__c = 'Test';
        qlObj.Booth_Number__c = 'TESTBN3';
        qlObj.Booth__c = True;
        insert qlObj; 
        
        opp.SBQQ__PrimaryQuote__c = qtObj.Id;
        opp.StageName='Closed Won';
        update opp;
        
        //Create Booth_Size_Badge_Limit__c
        Booth_Size_Badge_Limit__c bsbl =new Booth_Size_Badge_Limit__c(Badges_Allowed__c = 20, Booth_Size_From__c = 1, Booth_Size_To__c= 250, Event_Edition__c = evntEditon.id);
        insert bsbl;
        
        //Create ExpocadBooth__c
        ExpocadBooth__c expoBooth = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.',Area__c = '11.25 m²',  Unit_Type__c='m',Dimensions__c='5M x 10M',Account__c=acc.id, status__c='Rented',quote__c=qtObj.Id);
        insert expoBooth;

        //Create Opportunity_ExpoCAD_Booth_Mapping__c [CCEN-737]
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = acc.Id, Badge_Limit__c = 2, status__c = 'Active', quote__c=qtObj.Id, Expocad_Booth__c = expoBooth.Id);
        insert oppExpoBoothMapping;
        
        //Create Exhibitor_Badge__c
        Exhibitor_Badge__c expBadge = new Exhibitor_Badge__c(Name='Test Badge',CurrencyIsoCode='USD', Opp_Booth_Mapping__c = oppExpoBoothMapping.Id, ExpocadBooth__c = expoBooth.Id ,Event_Edition__c=evntEditon.id, Is_VIP__c = true);
        insert expBadge;
        
        //Create Event_Settings__c
        Event_Settings__c evntSetting = new Event_Settings__c(Name='Test Event',CurrencyIsoCode='USD',Event_Edition__c=evntEditon.id,Badge_State__c=true,Badge_Nationality__c=true,Badge_Mobile_Number__c=true,Badge_Last_Name__c=true,Badge_Job_Title__c=true,Badge_First_Name__c=true,Badge_Email__c=true,Allotment_By_Booth_Size__c=true
                                                          ,Badge_Country__c=true,Company_Name_on_Badge_ToUpperCase__c=false,Badge_City__c=true,Badges_Title__c='abc',Badges_Sub_Title__c='abch',Badge_LName_To_UpperCase__c=false,Badge_FName_To_UpperCase__c=false,Badge_Age_Bracket__c=true,Badge_Address__c=false,Company_Name_on_Badge__c= false);
        insert evntSetting;
        Blob b3 = Blob.valueOf('Test Data record');
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'Complete.pdf';//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion.Title ='Completed';//Name of the file
        cVersion.VersionData = b3;//File content
        insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId =  evntSetting.id;//Add Files parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        //string output = CommunityExhibitorBadgeCtrl.getDocumentId(evntEditon.Event_Edition_Code__c);
        //System.debug('output' + output);
        
        List<Exhibitor_Badge__c> fetchLastModifiedofUser = CommunityExhibitorBadgeCtrl.fetchLastModifiedofUser(acc.Id, evntEditon.Id, oppExpoBoothMapping.Id);
      
        Exhibitor_Badge__c oExhB = new  Exhibitor_Badge__c();
        List<String> boothid1 = new List<String>();
        List<CommunityExhibitorBadgeCtrl.boothSummaryWrpClass> booth1 = new  List<CommunityExhibitorBadgeCtrl.boothSummaryWrpClass>();
        
        Email_Templates__c eTemplate = new Email_Templates__c(Name='emailtest',Content__c='Test',Subject__c='test',Template_Code__c=evntEditon.Event_Code__c);
        insert eTemplate;
        system.assertEquals('emailtest', eTemplate.Name,'eTemplateName must have Test');
        
        Event_Edition_Email_Template__c eeTemplate = new Event_Edition_Email_Template__c(Name = 'Test', Content__c='Test',Subject__c='test', Event_Edition__c=evntEditon.Id, Email_Template_Code__c = evntEditon.Event_Code__c, Email_Template__c = eTemplate.Id );
        insert eeTemplate;
        system.assertEquals('Test', eeTemplate.Name,'eeTemplateName must have Test');
      
       
        list<Booth_Size_Badge_Limit__c> li = CommunityExhibitorBadgeCtrl.getBoothSizeLimit(evntEditon.Id);  
        system.assertNotEquals(null, li, 'Booth Size must not be null');
        
        List<CommunityExhibitorBadgeCtrl.boothSummaryWrpClass> wrp = CommunityExhibitorBadgeCtrl.getBooths(evntEditon.Event_Code__c, acc.Id);
        system.assertNotEquals(null, wrp, 'Booths must not be null');
        
        list<string> lstBoothIds= new list<string> ();
        lstBoothIds.add(oppExpoBoothMapping.Id);
        CommunityExhibitorBadgeCtrl.boothSummaryWrpClass wrp1 = CommunityExhibitorBadgeCtrl.getBoothSummary(evntEditon.Event_Code__c, lstBoothIds,evntEditon.Id);
        system.assertNotEquals(null, wrp1,'Booths must not be null' );
        System.debug('expBadge' +expBadge);
        String exb = CommunityExhibitorBadgeCtrl.saveExhibitorBadge(expBadge,evntEditon.Id,acc.Id);        
        
        List<String> pick = CommunityExhibitorBadgeCtrl.getPicklistValues('Account','BillingCountryCode');
        system.assertNotEquals(null, pick, 'Picklist values must not be null');
        
        Event_Settings__c evt = CommunityExhibitorBadgeCtrl.getEventSettings(evntEditon.Id);
        
        CommunityExhibitorBadgeCtrl.updateExhibitorBadge(boothid1,'Approved');
        CommunityExhibitorBadgeCtrl.updateBadgeAllFields(expBadge);
        CommunityExhibitorBadgeCtrl.getSingleBadge(expBadge.Id);
        CommunityExhibitorBadgeCtrl.checkFileId(evntEditon.Event_Code__c);
        
        CommunityExhibitorBadgeCtrl.getEventIdAccountId(evntEditon.Event_Code__c);
        CommunityExhibitorBadgeCtrl.getCurrentUserType(evntEditon.Id);
        
        CommunityExhibitorBadgeCtrl.AggregateResultResp wrapResult=new CommunityExhibitorBadgeCtrl.AggregateResultResp();       
        wrapResult = CommunityExhibitorBadgeCtrl.getBoothAggregate(evntEditon.Event_Code__c,acc.Id,lstBoothIds);
        CommunityExhibitorBadgeCtrl.deleteSelectedBadge(oExhB.Id);
        CommunityExhibitorBadgeCtrl.getDocumentId(evntEditon.Event_Code__c);
        /********* Commented as per ticket BK-2895
        CommunityExhibitorBadgeCtrl.med2MedMatching('no', acc.Id ,evntEditon.Id ,system.today());
        CommunityExhibitorBadgeCtrl.medDetail(evntEditon.Id, acc.Id);
        **********/
        //CommunityExhibitorBadgeCtrl.getDocumentId('toc');
        Test.stopTest();
    }
}