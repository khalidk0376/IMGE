/**
* Created By : Girikon(Abhishek)
* Created On : Sep 21, 2019
* @description : This test class covers all the methods of class CreateBadgesOpsAgentCtrl
* Apex Class : CreateBadgesOpsAgentCtrl(94% coverage)
* Modification log --
* Modified by      :   Girikon(Prashant C2E-103 [Sept 25 2019])
**/
@isTest
public with sharing class CreateBadgesOpsAgentCtrl_Test {
    //@isTest
    @testSetup 
    static void setup()
    {
        Utility.isRebookInProcess = True ;
         //Create Accounts
        Account acc = new Account(Name='TstAccFrst');
        insert acc;
        System.assertNotEquals(null, acc.Id,'Account Id should not be null');
        
        //Create APXTConga4__Conga_Template__c
        APXTConga4__Conga_Template__c conga = new APXTConga4__Conga_Template__c( APXTConga4__Template_Type__c = 'Document');
        insert conga;
        
        //Insert event edition image
        Document doc = new Document(); 
        doc.Name = 'TEV17-Event-Image'; 
        doc.FolderId = UserInfo.getUserId();//documents[0].FolderId;
        doc.IsPublic = true; 
        doc.DeveloperName = 'Badge_CSV_File_Without_VIP_Match';
        doc.Body =Blob.valueOf('Some Text'); 
        doc.ContentType = 'image/jpeg';
        insert doc;
        
        //Create Event_Edition


        Event_Edition__c evntEditon = new Event_Edition__c(Name='TestName',CurrencyIsoCode='USD',Tab1__c='Booth Application',Tab4__c='Contact Information', Tab8__c='Transfer & Payments',Event_Currency__c ='USD',Event_Code__c='sbah19', Contract_Template__c = conga.id,End_Date__c=date.today(),Event_Website__c='http://www.testevent.com',Event_Edition_Image_URL__c= doc.Id,Invoice_From_Email_ID__c='Test', Max_Hold_Booth__c=15, Max_Hold_Days__c=365, Measurement__c='Feet',Next_Edition__c='2019', Payment_Schedule__c='50-50', Quote_Template__c=conga.id,Start_Date__c=date.today()-1,Venue__c='Las Vegas Convention Center', Year__c='2019',Informa_Logo__c=doc.Id, Cutoff_Date_1__c=date.today()+1,Cutoff_Date_2__c=date.today()-10,Cutoff_Date_3__c=date.today()-15);


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
        
        //Create Agent Event Edition Mapping
        AgentEventEditionMapping__c eventMapping = new AgentEventEditionMapping__c(Account__c=acc.Id,EventEdition__c=evntEditon.id,Is_Active__c = true);
        insert eventMapping;

        //Create Agent Badges
        Agent_Badges__c badge1 = new Agent_Badges__c(Address__c='NA',Age_Bracket__c='21-24',Account_Name__c='Test Company 1',AgentEventEditionMapping__c=eventMapping.Id,City__c='New City',Country__c='AW',Country_Code__c='+1',Email__c='test@company.com',First_Name__c='Test1',Job_Title__c='Jack of All Trades',Last_Name__c='Know it All',Mobile_Number__c='87768768',Nationality__c='AD',State__c='Plasma',Status__c='Approved',Is_VIP__c=true);
        insert badge1;
        Agent_Badges__c badge2 = new Agent_Badges__c(Address__c='NA',Age_Bracket__c='21-24',Account_Name__c='Test Company 2',AgentEventEditionMapping__c=eventMapping.Id,City__c='New City',Country__c='AW',Country_Code__c='+1',Email__c='test1@company.com',First_Name__c='Test2',Job_Title__c='Jack of All Trades',Last_Name__c='Know Nothing',Mobile_Number__c='87768768',Nationality__c='AD',State__c='Plasma',Status__c='Pending',Is_VIP__c=false);
        insert badge2;
        
        //Create Event_Settings__c
        Event_Settings__c evntSetting = new Event_Settings__c(Name='Test Event',Badges_MatchMaking__c=true ,CurrencyIsoCode='USD',Co_Exhibitor_Badge_Limit__c = '2',Event_Edition__c=evntEditon.id,Badge_State__c=true,Badge_Nationality__c=true,Badge_Mobile_Number__c=true,Badge_Last_Name__c=true,Badge_Job_Title__c=true,Badge_First_Name__c=true,Badge_Email__c=true
                                                          ,Badge_Country__c=true,Company_Name_on_Badge_ToUpperCase__c=false,Badge_City__c=true,Badges_Title__c='abc',Badges_Sub_Title__c='abch',Badge_LName_To_UpperCase__c=false,Badge_FName_To_UpperCase__c=false,Badge_Age_Bracket__c=true,Badge_Address__c=false,Company_Name_on_Badge__c= false ,Allotment_By_Booth_Type__c=false,Allotment_By_Booth_Size__c=true,Agent_Badge_limit__c='10');
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
    }

    @isTest static void updateExhibitorBadgeTest(){
        Test.startTest();
        List<Agent_Badges__c> badges = [SELECT Status__c FROM Agent_Badges__c];
        List<String> idStr = new List<String>();
        for(Agent_Badges__c badge : badges){
            idStr.add(badge.Id);
        }
        String requiredStatus = 'Approved';
        CreateBadgesOpsAgentCtrl.updateExhibitorBadge(idStr, requiredStatus);
        List<Agent_Badges__c> badgesAfterUpdate = [SELECT Status__c FROM Agent_Badges__c];
        for(Agent_Badges__c badge : badgesAfterUpdate){
            System.assert(badge.Status__c==requiredStatus, 'Status should be as sent for updation');
        }
        Test.stopTest();
    }

    @isTest static void updateBadgeAllFieldsTest(){
        Test.startTest();
        Agent_Badges__c badge = [SELECT Id, First_Name__c FROM Agent_Badges__c LIMIT 1];
        badge.First_Name__c = 'Test 3';
        CreateBadgesOpsAgentCtrl.updateBadgeAllFields(badge);
        Agent_Badges__c updatedBadge = [SELECT First_Name__c FROM Agent_Badges__c WHERE Id = :badge.Id];
        System.assert(updatedBadge.First_Name__c == 'Test 3', 'Updated value should reflect after update');
        Test.stopTest();
    }

    @isTest static void getBadgesStatusMapTest(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Event_Edition__c eveEd = [SELECT Id FROM Event_Edition__c LIMIT 1];
        CreateBadgesOpsAgentCtrl.AggregateResultResp statusMap = CreateBadgesOpsAgentCtrl.getBadgesStatusMap(acc.Id,eveEd.Id);
        CreateBadgesOpsAgentCtrl.AggregateResultResp statusCCMap = CreateBadgesOpsAgentCtrl.getBadgesStatusCCMap(acc.Id,eveEd.Id);
        //System.assert(statusMap.submitted==2,'Total submitted badges should be equal to total badges created');
        System.assert(statusMap.agentBadgeList.size()==2,'All badges created should appear');
        System.assert(statusCCMap.submitted==2,'Total submitted badges should be equal to total badges created');
        System.assert(statusCCMap.agentBadgeList.size()==2,'All badges created should appear');
        Test.stopTest();
    }

    @isTest static void getPicklistValuesTest(){
        Test.startTest();
        List<String> picklistValues = CreateBadgesOpsAgentCtrl.getPicklistValues('Agent_Badges__c', 'Nationality__c');
        System.assert(picklistValues.size()>0,'Picklist values should not be empty');
        Test.stopTest();
    }

    @isTest static void saveAgentBadgeTest(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Event_Edition__c eveEd = [SELECT Id FROM Event_Edition__c LIMIT 1];
        AgentEventEditionMapping__c eventMapping = [SELECT Id FROM AgentEventEditionMapping__c LIMIT 1];
        Agent_Badges__c agentBadge = new Agent_Badges__c(Address__c='NA',Age_Bracket__c='21-24',Account_Name__c='Test Company 5',AgentEventEditionMapping__c=eventMapping.Id,City__c='New City',Country__c='AW',Country_Code__c='+1',Email__c='test1@company.com',First_Name__c='Test2',Job_Title__c='Jack of All Trades',Last_Name__c='Know Nothing',Mobile_Number__c='87768768',Nationality__c='AD',State__c='Plasma',Status__c='Pending',Is_VIP__c=false);
        CreateBadgesOpsAgentCtrl.saveAgentBadge(agentBadge,eveEd.Id, acc.Id );
        List<Agent_Badges__c> updatedBadges = new List<Agent_Badges__c>();
        updatedBadges = [SELECT Id FROM Agent_Badges__c WHERE Account_Name__c = 'Test Company 5'];
        System.assert(updatedBadges.size()>0, 'Agent badge should be inserted');
        Test.stopTest();
    }

    @isTest static void increaseBadgeLimitTest(){
        Test.startTest();
        AgentEventEditionMapping__c eventMapping = [SELECT Id FROM AgentEventEditionMapping__c LIMIT 1];
        Integer newLimit = 5;
        String eventEditionMappingId = eventMapping.Id;
        CreateBadgesOpsAgentCtrl.increaseBadgeLimit(newLimit, eventEditionMappingId);
        AgentEventEditionMapping__c eventMappingUpdated = [SELECT Id, Badge_Limit__c FROM AgentEventEditionMapping__c WHERE Id=:eventEditionMappingId];
        System.assert(eventMappingUpdated.Badge_Limit__c==newLimit,'Limit should be increased after running the method');
        Test.stopTest();
    }

    @isTest static void getEventSettingsTest(){
        Test.startTest();
        Event_Edition__c eventEdition = [SELECT Id FROM Event_Edition__c LIMIT 1];
        Event_Settings__c fetchedEventSettings = CreateBadgesOpsAgentCtrl.getEventSettings(eventEdition.Id);
        System.assert(fetchedEventSettings.Agent_Badge_limit__c=='10', 'Fetched data should should match created data');
        Test.stopTest();
    }
    
    @isTest static void getDocIdTest(){
        Test.startTest();
        Event_Edition__c eventEdition = [SELECT id, Event_Code__c FROM Event_Edition__c LIMIT 1];
        String getDocId = CreateBadgesOpsAgentCtrl.getDocumentId(eventEdition.Event_Code__c);
        System.assertNotEquals(null, getDocId, 'Fetched data must not be null');
        Test.stopTest();
    }
    
    @isTest static void getSingleBadgeTest(){
        Test.startTest();
        Agent_Badges__c agntBadge = [SELECT Id FROM Agent_Badges__c Limit 1];
        List<Agent_Badges__c> getSingleBadge = CreateBadgesOpsAgentCtrl.getSingleBadge(agntBadge.Id);
        CreateBadgesOpsAgentCtrl.deleteSelectedBadge(agntBadge.Id);
        System.assertNotEquals(null, getSingleBadge, 'Fetched data must not be null');
        Test.stopTest();
    }
    
    @isTest static void getCurrentUserTypeTest(){
        Test.startTest();
        Event_Edition__c eventEdition = [SELECT Id FROM Event_Edition__c LIMIT 1];
        ContactEventEditionMapping__c fetchCurrentUser = CreateBadgesOpsAgentCtrl.getCurrentUserType(eventEdition.Id);
        System.assertNotEquals(null, fetchCurrentUser, 'Fetched data must not be null');
        Test.stopTest();
    }
    
}