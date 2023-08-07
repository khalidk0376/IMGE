/**
* Created By    :  Girikon(Prashant)[CCEN-737]
* Created On    :  March 29 2019
* @description  :  This is the test class for BadgesUtils Class.
* Apex Class    :  BadgesUtils
* Modification log --
* Modified By   : Girikon(Prashant C2E-103 (Oct 1 2019))
**/
@isTest
public class BadgesUtils_Test 
{
    @isTest static void badgesData() 
    {
        //Create Account
        Account acc = new Account(Name='TstAccFrst');
    	insert acc;
        System.assertNotEquals(null, acc.Name, 'Account Name must not be null.');

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
        insert doc;
        
        blng__LegalEntity__c legalentity = new blng__LegalEntity__c(Name = 'Test LegalEntity' , blng__Active__c = true , Legal_Entity_Code__c = 'AE006');
        insert legalentity;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC', Active_VAT_Tax_Alt_Currency__c = True, VAT_Tax_Alt_Currency__c = 'ZAR' , Legal_Entity__c = legalentity.id, Status__c= 'Active');
        insert oEventseries;
        //Create Event_Edition
        Event_Edition__c evntEditon = new Event_Edition__c(Name='TestName',CurrencyIsoCode='USD',Tab1__c='Booth Application', Part_of_Series__c = oEventseries.id,Tab4__c='Contact Information', Tab8__c='Transfer & Payments',Event_Currency__c ='USD',Event_Code__c='abc',Event_Edition_Status__c='Confirmed', Contract_Template__c = conga.id, End_Date__c=date.today(),Event_Website__c='http://www.testevent.com',Invoice_From_Email_ID__c='Test', Event_Edition_Image_URL__c= doc.Id, Max_Hold_Booth__c=15, Max_Hold_Days__c=365, Measurement__c='Feet',Next_Edition__c='2019', Payment_Schedule__c='50-50',Start_Date__c=date.today()-1,Venue__c='Las Vegas Convention Center',Quote_Template__c=conga.id,Informa_Logo__c=doc.Id, Year__c='2019', Cutoff_Date_1__c=date.today()+1,Cutoff_Date_2__c=date.today()-10,Cutoff_Date_3__c=date.today()-15);
        insert evntEditon;
        
        //Create Opportunity
        Opportunity opp = new Opportunity(Name='Test opp', StageName='Needs Assessment', EventEdition__c = evntEditon.id,AccountId=acc.id,EventSeries__c='Arab Health',Event_Edition__c='Arab Health 2016',CloseDate=date.today()+19);
        insert opp;

        //Create Quote            
        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acc.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = opp.Id;
        qtObj.CurrencyIsoCode='BRL';
        insert qtObj;

        opp.SBQQ__PrimaryQuote__c = qtObj.Id;
        opp.StageName='Closed Won';
        update opp;
        
        //Create ExpocadBooth__c
        ExpocadBooth__c expoBooth = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.',Area__c = '12',  Unit_Type__c='m',Dimensions__c='5M x 10M',Account__c=acc.id, status__c='Rented',quote__c=qtObj.Id);
        insert expoBooth;
        
        //Create Opportunity_ExpoCAD_Booth_Mapping__c
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = acc.Id, Badge_Limit__c = 2, status__c = 'Active', quote__c=qtObj.Id, Expocad_Booth__c = expoBooth.Id);
        insert oppExpoBoothMapping;
	
    	//Create Exhibitor_Badge__c
    	Exhibitor_Badge__c expBadge = new Exhibitor_Badge__c(Name='Test Badge',CurrencyIsoCode='USD',Event_Edition__c=evntEditon.id,Opp_Booth_Mapping__c = oppExpoBoothMapping.Id, Is_VIP__c = true, Booth_Size__c = expoBooth.id,  ExpocadBooth__c = expoBooth.Id );
    	insert expBadge;
        
        //Create Agent Event Edition Mapping
        AgentEventEditionMapping__c eventMapping = new AgentEventEditionMapping__c(Account__c=acc.Id,EventEdition__c=evntEditon.id,Is_Active__c = true);
        insert eventMapping;

        //Create Agent Badges
        Agent_Badges__c agnBadge = new Agent_Badges__c(Address__c='NA',Age_Bracket__c='21-24',Account_Name__c='Test Company 1',AgentEventEditionMapping__c=eventMapping.Id,City__c='New City',Country__c='AW',Country_Code__c='+1',Email__c='test@company.com',First_Name__c='Test1',Job_Title__c='Jack of All Trades',Last_Name__c='Know it All',Mobile_Number__c='87768768',Nationality__c='AD',State__c='Plasma',Status__c='Approved',Is_VIP__c=true);
        insert agnBadge;

        //Create Event_Settings__c
        Event_Settings__c evntSetting = new Event_Settings__c(Name='Test Event',CurrencyIsoCode='USD',Event_Edition__c=evntEditon.id,Badge_State__c=true,Badge_Nationality__c=true,Badge_Mobile_Number__c=true,Badge_Last_Name__c=true,Badge_Job_Title__c=true,Badge_First_Name__c=true,Badge_Email__c=true ,Badge_Country__c=true,Company_Name_on_Badge_ToUpperCase__c=false,Badge_City__c=true,Badges_Title__c='abc',Badges_Sub_Title__c='abch',Badge_LName_To_UpperCase__c=false,Badge_FName_To_UpperCase__c=false,Badge_Age_Bracket__c=true,Badge_Address__c=false,Company_Name_on_Badge__c= false, VIP_badge_notification_recipient__c = 'test@test.com');
        insert evntSetting;

        List<String> boothid1 = new List<String>();
        
        BadgesUtils.updateBadgeStatus(boothid1,'Approved');
        BadgesUtils.getOppBoothforAccountBadge(evntEditon.Event_Code__c, acc.Id);
        BadgesUtils.getTotalBadgesByDimension(expoBooth.Dimensions__c);
        BadgesUtils.saveExhibitorBadges(expBadge, evntEditon.Id, acc.Id, '');
        BadgesUtils.saveAgentBadges(agnBadge, evntEditon.Id, acc.Id);
        BadgesUtils.sendEmailByCode('VBWR', evntEditon.Id, acc.Id);
        BadgesUtils.getCurrentUserType(evntEditon.Id, evntEditon.Event_Code__c);
        String getMultipleBadgesTemplate = BadgesUtils.getMultipleBadgesTemplateId();
        BadgesUtils getBoothsForBadge = new BadgesUtils();
        getBoothsForBadge.getBooths(evntEditon.Event_Code__c, acc.Id);
    }
    
	
}