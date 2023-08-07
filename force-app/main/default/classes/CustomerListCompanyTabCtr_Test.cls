/*Created By: Girikon(Mukesh Gupta[STL-216])
Created On: 9 Oct, 2019
@description : This is the test class for apex class- CustomerListCompanyTabCtr
Methods: customerProfileContact
Apex Class: CustomerListCompanyTabCtr
Modification log --
Modified By:
Modified On:
*/
@IsTest
public class CustomerListCompanyTabCtr_Test {
	@isTest 
    static void customerProfileContact()
    {
        //Create Account
        List<Account> accounts = new List<Account>();
        for(Integer i=0;i<3;i++)
        {
            Account a = new Account(Name='TestAcc' + i);
            accounts.add(a);    
        }
        insert accounts;
        //create Event_Edition__c
        List<Event_Edition__c> lstEE = new List<Event_Edition__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Edition__c ee = new Event_Edition__c(Name='TestName'+i,Event_Currency__c='USD',Event_Code__c='XYZ');
            lstEE.add(ee);  
        }
        insert lstEE;
        //create Contact
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0;i<3;i++)
        {
            Contact c = new Contact(AccountId = accounts[i].Id, FirstName = 'TestConFirst'+i, LastName = 'TestConLast'+i, Email='abc@test.com');
            contacts.add(c);    
        }
        insert contacts;
        //create Opportunity
        List<Opportunity> opps = new List<Opportunity>();
        for(Integer i=0;i<3;i++)
        {
            Opportunity op = new Opportunity(Name='Testopp'+i,EventEdition__c = lstEE[0].id,AccountId=accounts[0].id,CloseDate=date.today()+19,Opportunity_Contact__c=contacts[0].id,StageName = 'Closed Won');
            opps.add(op);
        }
        insert opps;
        

        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = accounts[0].Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = opps[0].Id;
        qtObj.CurrencyIsoCode='BRL';
        insert qtObj;

        
        //create ExpocadBooth__c
        List<ExpocadBooth__c> lstExpoBooth = new List<ExpocadBooth__c>();
        for(Integer i=0;i<3;i++)
        {
            ExpocadBooth__c eB = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.'+i,BoothContact__c=contacts[0].id,Primary_Contact__c=contacts[0].id);
            lstExpoBooth.add(eB);   
        }
        insert lstExpoBooth;

        //Create Opportunity_ExpoCAD_Booth_Mapping__c [CCEN-743]
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = accounts[0].Id, Badge_Limit__c = 2, status__c = 'Active', quote__c=qtObj.Id, Expocad_Booth__c = lstExpoBooth[0].Id, Primary_Contact__c = contacts[0].id);
        insert oppExpoBoothMapping;

        //create BoothContactInfo__c
        List<BoothContactInfo__c> boothConInfo = new List<BoothContactInfo__c>();
        for(Integer i=0;i<1;i++)
        {
            BoothContactInfo__c bCon = new BoothContactInfo__c(Name='TestBooth' + i,Event_Edition__c=lstEE[0].id,Contact__c=oppExpoBoothMapping.Primary_Contact__c,ExpocadBooth__c=lstExpoBooth[0].id, Opportunity_Booth_Mapping__c = oppExpoBoothMapping.Id);
            boothConInfo.add(bCon);            
        } 
        insert boothConInfo;
        
        //Create Event_Settings__c
        List<Event_Settings__c> evntSetting = new List<Event_Settings__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Settings__c eS = new Event_Settings__c(Name='Test Event',Event_Edition__c=lstEE[0].id);
            evntSetting.add(eS);
        }
        insert evntSetting;
        //create Profile_Option_Visibility__c
        List<Profile_Option_Visibility__c> proOpVis = new List<Profile_Option_Visibility__c>();
        for(Integer i=0;i<3;i++)
        {
            Profile_Option_Visibility__c pOV = new Profile_Option_Visibility__c(Name='Test Profile'+i,Event_Edition__c=lstEE[0].id,CurrencyIsoCode='USD');
            proOpVis.add(pOV);
        }
        insert proOpVis;
        //create Profile_Package_Setting__c
        List<Profile_Package_Setting__c> profilePkgSetting = new List<Profile_Package_Setting__c>();
        for(Integer i=0;i<3;i++)
        {
            Profile_Package_Setting__c pPS = new Profile_Package_Setting__c(Name='Test Profile1'+i,CurrencyIsoCode='USD',Event_Edition__c=lstEE[0].id,Is_Default__c=true);
            profilePkgSetting.add(pPS);
        }
        insert profilePkgSetting;
        
        string boothId1 = oppExpoBoothMapping.id;
        //string eventId1 = boothConInfo[0].Event_Edition__c;
        string eventId1 = lstEE[0].Id;
        string eventCode = oppExpoBoothMapping.Event_Code__c;
        
        BoothContactInfo__c boothCon = new BoothContactInfo__c();  
        Opportunity_ExpoCAD_Booth_Mapping__c expo = new Opportunity_ExpoCAD_Booth_Mapping__c();
        CustomerListCompanyTabCtr.ContactInfoDetailsWrap wrp1 = CustomerListCompanyTabCtr.getContactDetails(boothId1, eventId1, accounts[0].Id, true);
        system.assertNotEquals(null, wrp1,'It is not the correct value');         
        List<String> pick = CustomerListCompanyTabCtr.getPicklistValues('Contact','MailingCountryCode');
        system.assertNotEquals(null, pick,'It is not the correct value');
        Event_Settings__c eS = CustomerListCompanyTabCtr.getEventDetails(eventCode);
        system.assertNotEquals(null, eS,'It is not the correct value');
        Opportunity_ExpoCAD_Booth_Mapping__c exB = CustomerListCompanyTabCtr.getExpocadBoothDetails(boothId1, accounts[0].Id);
        system.assertNotEquals(null, exB, 'It is not the correct value');
        string createRec = CustomerListCompanyTabCtr.createRecord(boothCon);
        system.assertNotEquals(null, createRec, 'It is not the correct value');
        string updateRecord = CustomerListCompanyTabCtr.updateExpocadBooth(expo);
        system.assertNotEquals(null, updateRecord, 'It is not the correct value');
        Profile_Option_Visibility__c pO = CustomerListCompanyTabCtr.getProfileOptionVisibility(eventId1);
        system.assertNotEquals(null, pO, 'It is not the correct value');
        Profile_Package_Setting__c packageS = CustomerListCompanyTabCtr.getProfilePackageSetting(eventId1,boothId1, accounts[0].Id);
        system.assertNotEquals(null, packageS, 'It is not the correct value');
        
        //List to remove existing boothcontact to test the "Else" condition        
        List<BoothContactInfo__c> boothConInfoDel = new List<BoothContactInfo__c>();
        set<id> bconIds = new set<id>();
        for(Integer i=0;i<1;i++)
        {
            bconIds.add(boothConInfo[i].id);                           
        } 
        delete [Select Id from BoothContactInfo__c where Id =: bconIds]; 
        CustomerListCompanyTabCtr.ContactInfoDetailsWrap wrp11 = CustomerListCompanyTabCtr.getContactDetails(boothId1, eventId1, accounts[0].Id, true);
        system.assertNotEquals(null, wrp11,'It is not the correct value'); 
     }
}