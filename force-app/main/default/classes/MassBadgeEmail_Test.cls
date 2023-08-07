/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          8/31/2017
 * Description/Purpose: This test class covers the apex class : MassBadgeEmail
 * Methods:             MassBadgeEmail_DataInsert
 * Apex Class:          MassBadgeEmail
**/
//Ticket No. BK-14521 Updating API Version
@isTest
public class MassBadgeEmail_Test {
    public static testMethod void MassBadgeEmail_DataInsert()
    {
        
         // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserKumar1@testorg.com');
        insert u;
         System.runAs(u) 
        {
            Contact con = new Contact();
            con.LastName = 'testLastName';
            con.FirstName = 'testFirstName';
            con.MailingCountry = 'USA';
            con.MailingState = 'Texas';
            con.MailingStreet = 'testMailingStreet';
            con.MailingCity = 'testMailingCity';
            con.MailingPostalCode = '201000';
            con.Email = 'test@gmail.com';
            con.Phone = '2012012012';
            insert con;
            
            Event_Edition__c OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
            //insert OEve;
            System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
            EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=OEve.id);
            insert eventCurrency;
            System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
            OEve.EventCurrency__c = eventCurrency.id;
            oEve.CurrencyIsoCode = eventCurrency.Name;
            //update OEve;
            System.assert(OEve.EventCurrency__c != null, 'Event Currency');
            
            Email_Templates__c testET = new Email_Templates__c();
            testET.name = 'test email template';
            testET.Template_Code__c = 'ORDINV';
            testET.Content__c = 'testContent';
            testET.Subject__c = 'Test Template';
            testET.CurrencyIsoCode = eventCurrency.Name;
            insert testET;
            
            
            
            ExpocadBooth__c testExpo = new ExpocadBooth__c();
            testExpo.User__c = u.id;
            insert testExpo;
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
          
          //Create Event_Edition
          Event_Edition__c evntEditon = new Event_Edition__c(Name='TestName2021', Event_Edition_Status__c='Completed');
          insert evntEditon;
          Event_Edition_Email_Template__c testEEET = new Event_Edition_Email_Template__c();
            testEEET.Event_Edition__c = evntEditon.id;
            testEEET.Subject__c = 'Test Template';
            testEEET.Email_Template__c = testET.id;
            testEEET.Email_Template_Code__c = 'BDGAPR';
            testEEET.Content__c = 'test email template';
            insert testEEET;
            
            Event_Edition_Email_Template__c testEEET2 = new Event_Edition_Email_Template__c();
            testEEET2.Event_Edition__c = evntEditon.id;
            testEEET2.Subject__c = 'Test Template';
            testEEET2.Email_Template__c = testET.id;
            testEEET2.Email_Template_Code__c = 'BDGREJ';
            testEEET2.Content__c = 'test email template';
            insert testEEET2;
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
            string exhibitorId=expBadge.id;
            List<String> exbadgeIdList= new  List<String>();
                 exbadgeIdList.Add(exhibitorId);
                 string exbadgeIds=System.JSON.serialize(exbadgeIdList);
            Test.startTest();
                /*SingleBadgeEmail.SingleBadgeEmail(OEve.id,con.id,testExpo.id,'Reject','test');
                SingleBadgeEmail.SingleBadgeEmail(OEve.id,con.id,testExpo.id,'Approve','test');*/
                 
               boolean strJson = MassBadgeEmail.massBadgeEmailNotification(evntEditon.id,con.id,exbadgeIds,'Reject','test');
                boolean strJson1 = MassBadgeEmail.massBadgeEmailNotification(evntEditon.id,con.id,exbadgeIds,'Approve','test');
            Test.stopTest();
        }
    }
}