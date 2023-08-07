/**
* Created By    :  Girikon(Ashish)
* Created On    :  29 Jan 2019
* @description  :  Provides Code Covrage To CustomerBadgesReportOpsCtrl (80%),MassBadgeReminderEmailBatch(97%),BatchBadgesStatusSendEmail(91%)
* Modification Log----- 
* Modified by :  Girikon(Prashant [CCEN-737 April 4 2019])
**/
@IsTest
public class CustomerBadgesReportOpsCtrl_Test 
{
    //SetUp data for test class
    @isTest static void opsBadges()
    {        
        Utility.isRebookInProcess = True ;

        //Create Accounts
        Account acc = new Account(Name='TstAccFrst');
        insert acc;
        
        //create some contacts
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0;i<3;i++)
        {
            Contact c = new Contact(AccountId = acc.Id, FirstName = 'TstConFrst'+i, LastName = 'TstConLst1'+i, Email='test@test.com');
            contacts.add(c);    
        }
        insert contacts;
    
            
        //Create user
        //Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'];
        User[] userList = new User[]{};
        User u = new User();

        u.FirstName = 'Sunil';
        u.LastName = 'Bajoliya';
        u.Email = 'test@wexeurope.com';
        u.Username = 'astest@wexeurope.com';
        u.Alias = 'astest';
        u.ProfileId = pro.Id;
        
        u.ContactId = contacts[1].id;
        u.TimeZoneSidKey    = 'America/Denver';
        u.LocaleSidKey      = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        insert u;
        //userList.add(u);
        system.debug('u contains ' + u);
        //insert userList;
        
        //Create User_Type__c
        User_Type__c oUT = new User_Type__c(Name='Co-Exhibitor');
        insert oUT;

        //Create APXTConga4__Conga_Template__c
        APXTConga4__Conga_Template__c conga = new APXTConga4__Conga_Template__c( APXTConga4__Template_Type__c = 'Document');
        insert conga;
         
        //Insert event edition image
        Document doc = new Document(); 
        doc.Name = 'TEV17-Event-Image'; 
        doc.FolderId = UserInfo.getUserId();
        doc.IsPublic = true; 
        doc.Body =Blob.valueOf('Some Text'); 
        doc.ContentType = 'image/jpeg';
        insert doc;
        
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Status__c = 'Active', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        
        //Create Event_Edition
        Event_Edition__c evntEditon = new Event_Edition__c(Name='TestName',Part_of_Series__c=oEventseries.Id,CurrencyIsoCode='USD',Tab1__c='Booth Application',Tab4__c='Contact Information', Tab8__c='Transfer & Payments',Event_Currency__c ='USD',Event_Code__c='abc',Event_Edition_Status__c='Confirmed', Contract_Template__c = conga.id,End_Date__c=date.today(),Event_Website__c='http://www.testevent.com',Event_Edition_Image_URL__c= doc.Id,Invoice_From_Email_ID__c='Test', Max_Hold_Booth__c=15, Max_Hold_Days__c=365, Measurement__c='Feet',Next_Edition__c='2019', Payment_Schedule__c='50-50', Quote_Template__c=conga.id,Start_Date__c=date.today()-1,Venue__c='Las Vegas Convention Center', Year__c='2019',Informa_Logo__c=doc.Id, Cutoff_Date_1__c=date.today()+1,Cutoff_Date_2__c=date.today()-10,Cutoff_Date_3__c=date.today()-15);
        insert evntEditon ;

        Product2 prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth', Number_of_Corners__c = 0);
        prd1.Event_Product_Type__c='Sponsorship';
        insert prd1;
        
        //Create Opportunity
        Opportunity opp = new Opportunity(Name='Test opp',Operations_Contact__c =contacts[1].id,User_Type__c=oUT.Id,StageName='Closed Booked', EventEdition__c = evntEditon.id,AccountId=acc.id,EventSeries__c='Arab Health',Event_Edition__c='Arab Health 2016',CloseDate=date.today()+19);
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
        //Booth_Size_Badge_Limit__c bsbl =new Booth_Size_Badge_Limit__c(Badges_Allowed_by_Booth_Type__c = 20,Booth_Type__c ='Space Only',Match_Product_Entry_Type__c ='Fixed',Event_Edition__c = evntEditon.id);
        insert bsbl;
        
        //Create ExpocadBooth__c
        ExpocadBooth__c expoBooth = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.',Opportunity__c =opp.Id ,Area__c = '11.25 m²',  Unit_Type__c='m',Dimensions__c='5M x 10M',Account__c=acc.id, status__c='Rented',quote__c=qtObj.Id);
        insert expoBooth;
        
        //create Email_Templates__c
        List<Email_Templates__c> lstETemp = new List<Email_Templates__c>();
        for(Integer i=0;i<1;i++)
        {
            Email_Templates__c eTemp = new Email_Templates__c(Name='TestName'+i,Template_Code__c='BDGAPR');
            lstETemp.add(eTemp);    
        }
        insert lstETemp;
        //create Event_Edition_Email_Template__c
        List<Event_Edition_Email_Template__c> lstEEETemp = new List<Event_Edition_Email_Template__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Edition_Email_Template__c eeet = new Event_Edition_Email_Template__c(Name='TestName'+i,Content__c='TestContent'+i,Email_Template_Code__c='BDGAPR', 
                                                                                       Subject__c='test'+i,Email_Template__c=LstETemp[0].Id,Event_Edition__c=evntEditon.Id);
            lstEEETemp.add(eeet);   
        }
        insert lstEEETemp;

        //Create Opportunity_ExpoCAD_Booth_Mapping__c [CCEN-737]
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = acc.Id, Badge_Limit__c = 2, status__c = 'Active', quote__c=qtObj.Id, Expocad_Booth__c = expoBooth.Id,Opportunity__c = opp.Id);
        insert oppExpoBoothMapping;
        
        //Create Exhibitor_Badge__c
        Exhibitor_Badge__c expBadge = new Exhibitor_Badge__c(Account__c =acc.Id,Name='Test Badge',Status__c='Approved',CurrencyIsoCode='USD',Event_Edition__c=evntEditon.id, Opp_Booth_Mapping__c = oppExpoBoothMapping.Id,  ExpocadBooth__c = expoBooth.Id, User_Name__c = u.Id );
        insert expBadge;
        
        //Create Event_Settings__c
        Event_Settings__c evntSetting = new Event_Settings__c(Name='Test Event',CurrencyIsoCode='USD',Event_Edition__c=evntEditon.id,Badge_State__c=true,Badge_Nationality__c=true,Badge_Mobile_Number__c=true,Badge_Last_Name__c=true,Badge_Job_Title__c=true,Badge_First_Name__c=true,Badge_Email__c=true,Allotment_By_Booth_Type__c = true
                                                          ,Badge_Country__c=true,Company_Name_on_Badge_ToUpperCase__c=false,Badge_City__c=true,Badges_Title__c='abc',Badges_Sub_Title__c='abch',Badge_LName_To_UpperCase__c=false,Badge_FName_To_UpperCase__c=false,Badge_Age_Bracket__c=true,Badge_Address__c=false,Company_Name_on_Badge__c= false);
        insert evntSetting;

        Set<String> expBadgeSet= new  Set<String>();
        expBadgeSet.Add(String.valueOf(expBadge.id));
        
        Test.startTest();
        CustomerBadgesReportOpsCtrl.AggregateResultWrapper  wrap = CustomerBadgesReportOpsCtrl.getExhibitorBadgeAggregate(evntEditon.Id,1,5,'All');
        
        List<String> pickVal = CustomerBadgesReportOpsCtrl.getPicklistValues('Case','Status');
        
        Event_Settings__c evntStng = CustomerBadgesReportOpsCtrl.getEventSettings(evntEditon.Id);
        
        List<String> idStr = new List<String>();
        idStr.add(expBadge.id);
        CustomerBadgesReportOpsCtrl.updateExhibitorBadge(idStr, 'Approved', true, 'TESTING ONLY');
        
        list<Exhibitor_Badge__c> ebBDge = CustomerBadgesReportOpsCtrl.getAccountBadges(acc.Id, evntEditon.Id);
        
        string result = CustomerBadgesReportOpsCtrl.updateBadgeAllFields(expBadge, true, 'Test');
        system.assertNotEquals(null, result, 'Record Saved!');
        
        Boolean msg = CustomerBadgesReportOpsCtrl.massBadgesEmailReminder(evntEditon.Id);
        
        BatchBadgesStatusSendEmail batch1 = new BatchBadgesStatusSendEmail(expBadgeSet,expBadge.Status__c, 'Test');
        Database.executeBatch(batch1, 10); 
        Test.stopTest();
    }  
    /**
     * @description : For data setup and test methods.
    */
     public static testMethod void massBadgeReminderEmailDataInsert()
    {
        Event_Edition__c eve;
        eve= new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert eve; 
        
        Account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null, 'Acc name must not be null');
        
        Contact cont = new Contact();
        cont.LastName='Sam';
        cont.Email='test@test.com';
        cont.AccountId = acc.Id;
        insert cont;  
        
        User_Type__c uType = new User_Type__c(Name ='Exhibitor');
        insert uType;
        
        ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c();
        cEEM.SFEventEditionID__c = eve.Id;
        cEEM.SFContactID__c = cont.Id; 
        cEEM.User_Type__c = uType.Id;
        cEEM.IsEmailSent__c = True;
        
        
        insert cEEM;
        
            EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=eve.id);
                insert eventCurrency;
                System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
                eve.EventCurrency__c = eventCurrency.id;
                eve.CurrencyIsoCode = eventCurrency.Name;
                update eve;
                System.assert(eve.EventCurrency__c != null, 'Event Currency');
            
             Email_Templates__c testET = new Email_Templates__c();
                testET.name = 'test email template';
                testET.Template_Code__c = 'BADGEMRM';
                testET.Content__c = 'testContent';
                testET.Subject__c = 'Test Template';
                testET.CurrencyIsoCode = eventCurrency.Name;
                insert testET;
            
            Event_Edition_Email_Template__c testEEET = new Event_Edition_Email_Template__c();
                testEEET.Event_Edition__c = eve.id;
                testEEET.Subject__c = 'Test Template';
                testEEET.Email_Template__c = testET.id;
                testEEET.Email_Template_Code__c = 'BADGEMRM';
                testEEET.Content__c = 'test email template';
                insert testEEET;
                
            List<String> accList= new  List<String>();
            accList.Add(String.valueOf(acc.id));
            string accntIDs=System.JSON.serialize(accList);
        Test.StartTest();
            //MassBadgeReminderEmail.MassBadgeReminderEmail(String.valueOf(eve.id), accntIDs);
            MassBadgeReminderEmailBatch batch = new MassBadgeReminderEmailBatch(String.valueOf(eve.id),accntIDs);
            Database.executeBatch(batch, 10);      
        Test.StopTest();                       
    }


}