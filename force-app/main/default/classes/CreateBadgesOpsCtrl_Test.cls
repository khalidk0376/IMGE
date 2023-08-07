/**
* Created/Modified By   : Girikon(Prashant)
* Created On    :          08/07/2018
* @description : This test class covers the apex class "CreateBadgesOpsCtrl" following methods
*                      getBoothSizeLimit, getBooths, getBoothSummary, saveExhibitorBadge, increaseBoothBadgeLimit, getPicklistValues, getEventSettings
* Methods:             OpsBadges 
* Apex Class:          CreateBadgesOpsCtrl (Coverage : 83%)
* Modification Log----- 
* Modified by :  Girikon(Prashant [CCEN-737 April 4 2019])
**/
@isTest 
public class CreateBadgesOpsCtrl_Test 
{    
    //SetUp data for test class
    @isTest static void opsBadges()
    {
        Utility.isRebookInProcess = True ;
         //Create Accounts
        Account acc = new Account(Name='TstAccFrst');
        insert acc;
        System.assertNotEquals(null, acc.Id,'Error account is not created');
        
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
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'Arab Health', CurrencyISOCode = 'USD', Package_Identifier__c = 'ARBHL', Event_Edition_Pool__c = 'ARBHL',Status__c = 'Active');
        insert oEventseries;
        
        //Create Event_Edition
        Event_Edition__c evntEditon = new Event_Edition__c(Name='TestName',CurrencyIsoCode='USD',Tab1__c='Booth Application',Tab4__c='Contact Information', Tab8__c='Transfer & Payments',
                                                            Event_Currency__c ='USD',Event_Code__c='abc',Event_Edition_Status__c='Confirmed', Contract_Template__c = conga.id,End_Date__c=date.today(),
                                                            Event_Website__c='http://www.testevent.com',Event_Edition_Image_URL__c= doc.Id,Invoice_From_Email_ID__c='Test', 
                                                            Max_Hold_Booth__c=15, Max_Hold_Days__c=365, Measurement__c='Feet',Next_Edition__c='2019', Payment_Schedule__c='50-50', 
                                                            Quote_Template__c=conga.id,Start_Date__c=date.today()-1,Venue__c='Las Vegas Convention Center', Year__c='2019',Informa_Logo__c=doc.Id, 
                                                            Cutoff_Date_1__c=date.today()+1,Cutoff_Date_2__c=date.today()-10,Cutoff_Date_3__c=date.today()-15,Part_of_Series__c = oEventseries.Id);
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
        Booth_Size_Badge_Limit__c bsbl =new Booth_Size_Badge_Limit__c(Badges_Allowed__c = 20, Booth_Size_From__c = 1, Booth_Size_To__c= 250,Booth_Type__c='Shell Scheme', Match_Product_Entry_Type__c='Fixed', Event_Edition__c = evntEditon.id);
        insert bsbl;
        
        //Create ExpocadBooth__c
        ExpocadBooth__c expoBooth = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.',Area__c = '11.25 m²',  Unit_Type__c='m',Dimensions__c='5M x 10M',Account__c=acc.id, status__c='Rented',quote__c=qtObj.Id);
        insert expoBooth;

        //Create Opportunity_ExpoCAD_Booth_Mapping__c [CCEN-737]
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = acc.Id, Badge_Limit__c = 2, status__c = 'Active', quote__c=qtObj.Id, Expocad_Booth__c = expoBooth.Id);
        insert oppExpoBoothMapping;
        
        //Create Exhibitor_Badge__c
        Exhibitor_Badge__c expBadge = new Exhibitor_Badge__c(Name='Test Badge',CurrencyIsoCode='USD',Event_Edition__c=evntEditon.id,Opp_Booth_Mapping__c = oppExpoBoothMapping.Id,  ExpocadBooth__c = expoBooth.Id  );
        insert expBadge;
        
        //Create Event_Settings__c
        Event_Settings__c evntSetting = new Event_Settings__c(Name='Test Event',CurrencyIsoCode='USD',Co_Exhibitor_Badge_Limit__c = '2',Event_Edition__c=evntEditon.id,Badge_State__c=true,Badge_Nationality__c=true,Badge_Mobile_Number__c=true,Badge_Last_Name__c=true,Badge_Job_Title__c=true,Badge_First_Name__c=true,Badge_Email__c=true
                                                          ,Badge_Country__c=true,Company_Name_on_Badge_ToUpperCase__c=false,Badge_City__c=true,Badges_Title__c='abc',Badges_Sub_Title__c='abch',Badge_LName_To_UpperCase__c=false,Badge_FName_To_UpperCase__c=false,Badge_Age_Bracket__c=true,Badge_Address__c=false,Company_Name_on_Badge__c= false ,Allotment_By_Booth_Type__c=false,Allotment_By_Booth_Size__c=true);
        insert evntSetting;
        
        system.debug('opp' +evntEditon.Id);
       // system.debug('boothid1'+boothid1);
      
        Exhibitor_Badge__c oExhB = new  Exhibitor_Badge__c();
        List<String> boothid1 = new List<String>();
        boothid1.add(expBadge.id);
        List<Opportunity_ExpoCAD_Booth_Mapping__c> expoboothidMapping = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        List<CreateBadgesOpsCtrl.boothSummaryWrpClass> booth1 = new  List<CreateBadgesOpsCtrl.boothSummaryWrpClass>();
        
       
        list<Booth_Size_Badge_Limit__c> li = CreateBadgesOpsCtrl.getBoothSizeLimit(evntEditon.Id);  
        system.assertNotEquals(null, li,'');
        
        List<CreateBadgesOpsCtrl.boothSummaryWrpClass> wrp = CreateBadgesOpsCtrl.getBooths(evntEditon.Event_Code__c, acc.Id);
        system.assertNotEquals(null, wrp,'');
        
        list<string> lstBoothIds= new list<string>();
        lstBoothIds.add(oppExpoBoothMapping.Id);
        CreateBadgesOpsCtrl.boothSummaryWrpClass wrp1 = CreateBadgesOpsCtrl.getBoothSummary(evntEditon.Event_Code__c, lstBoothIds,evntEditon.Id,'Co_Exhibitor'); 
        system.assertNotEquals(null, wrp1,'');
        
        String exb = CreateBadgesOpsCtrl.saveExhibitorBadge(oExhB, evntEditon.Id, acc.Id);
        
        CreateBadgesOpsCtrl.increaseBoothBadgeLimit(expoboothidMapping);
        
        List<String> pick = CreateBadgesOpsCtrl.getPicklistValues('Account','BillingCountryCode');
        system.assertNotEquals(null, pick,'');
        
        Event_Settings__c evt = CreateBadgesOpsCtrl.getEventSettings(evntEditon.Id);
       
        CreateBadgesOpsCtrl.updateExhibitorBadge(boothid1,'Approved');
        CreateBadgesOpsCtrl.updateBadgeAllFields(expBadge);
        CreateBadgesOpsCtrl.getSingleBadge(expBadge.Id);
        CreateBadgesOpsCtrl.AggregateResultResp wrapResult=new CreateBadgesOpsCtrl.AggregateResultResp();       
        wrapResult = CreateBadgesOpsCtrl.getBoothAggregate(evntEditon.Event_Code__c,acc.Id,lstBoothIds,evntEditon.Id,'Co_Exhibitor');
    }
}