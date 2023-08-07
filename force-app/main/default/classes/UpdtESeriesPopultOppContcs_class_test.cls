/**
* File:        UpdtESeriesPopultOppContcs_class_test
* Project:     GAP
* Date:        2/18/2019 8:54 PM
* Created By:  Rajesh Kumar
* Test Class for : UpdateESeriesPopultOppContacts_class
************************************************************************
@description  Lead conversion Process builder
* Modified By: Rajesh Kumar On 13 FeB 2019 T - GGCW-3124.
* Modified By: Shiv Raghav(Bk-5887) on 20 July 2020.
* Modified By: Shiv Raghav(Bk-7068) on 29 July 2020.
* Modified By: Shiv Raghav(Bk-6861) on 16 Feb 2021.
************************************************************************
* History:
* 2/18/2019 : Modified By RajeshKumar for Jira ticket : GGCW-3124
*/

@isTest
public class UpdtESeriesPopultOppContcs_class_test {
    
    static testmethod void updtESeriesPopultOppContcs(){
        
        List<Lead> leadLst = new List<Lead>();
        Map<Id, Lead> oldOppolead = new Map<Id, Lead>(); 
        Set<Id> setContacttst=new Set<Id>();
        Boolean isInsert=true;
        
        Boolean isupdate=true;
        Boolean isAfter=true;
        
        // Create Trigger test record 
        Trigger__c trig = new Trigger__c(Name = 'UpdateESeriesPopultOppContacts_class' , Trigger_Name_Unique__c='UpdateESeriesPopultOppContacts_class',Enabled__c=true,Object__c='Lead',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=5,
                                         After_Insert__c=true , After_Update__c = true, Before_Insert__c = true, Before_Update__c =  true);
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        //Call trigger interface
        TriggerInterface_Lead obj = new TriggerInterface_Lead();
        
        //Call trigger app handler for insert event
        TriggerInterfaceHelper.runTrigger('UpdateESeriesPopultOppContacts_class','Lead',5, 'ai', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('UpdateESeriesPopultOppContacts_class');  
        // UpdateEventSeries_Trig uesObj = new UpdateEventSeries_Trig();
        Brand__c oBrand = new Brand__c(Name='World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        
        Event_Series__c oEventseries = new Event_Series__c(Status__c = 'Active' , Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c=oBrand.id , Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c();
        ct.APXTConga4__Template_Type__c = 'Document';
        insert ct;
        Event_Edition__c edi = new Event_Edition__c ();
        edi.name = 'Arab Health 2017';
        edi.Approval_Service_Now_ID__c = '123';
        edi.Alternate_Currency__c = 'AED';
        edi.CurrencyIsoCode='USD';
        edi.Tab1__c='Test';
        edi.Tab7__c = 'test1';
        edi.Event_Edition_Status__c = 'Confirmed';
        edi.Contract_Template__c = CT.Id;
        edi.Quote_Template__c = CT.Id;
        edi.End_Date__c = date.today().adddays(5);
        edi.Event_Website__c = 'https://www.google.com';
        edi.Event_Edition_Image_URL__c = 'test';
        edi.Invoice_From_Email_ID__c = 'test';
        edi.Max_Hold_Booth__c = 3;
        edi.Max_Hold_Days__c = 2;
        edi.Measurement__c = 'Meters';
        edi.Next_Edition__c = '2016';
        edi.Payment_Schedule__c = '50-50';
        edi.Start_Date__c = date.today();
        edi.Venue__c = 'Test';
        edi.Year__c = '2020';
        edi.Event_Code__c  = 'sbwoc7';
        edi.Cutoff_Date_1__c = date.today().adddays(1);
        edi.Part_of_Series__c = oEventseries.Id;
        insert edi;
        
        Lead leadList=new Lead(FirstName='Test ',LastName='Lead',Status='Contacted',Company='Test Girikon',Email ='example@example.com');
        leadList.Event_Edition__c=edi.Id;
        leadList.Lead_Type__c = 'Invoice Contact'; 
        //Modified by Avinash : BK-1240
        leadList.Country = 'USA';
        leadList.Description = 'Interests: Ambulance ServicesNOBs: Parks,Ambulance ServicesProduct sector specific questions and answers:';
        insert leadList;
        
        LeadInterestLevelMapping__c linterest= new LeadInterestLevelMapping__c();
        linterest.SFDCLeadID__c = leadList.id;
        insert linterest; 
        
        Lead_Nature_Of_Business_Mapping__c lBusiness= new Lead_Nature_Of_Business_Mapping__c();
        lBusiness.Lead__c = leadList.id;
        insert lBusiness; 
        
        
        leadList.Description = 'Interests: Ambulance1 ServicesNOBs: Parks,Ambulance1 ServicesProduct sector specific questions and answers:';
        update leadList;
        
        oldOppolead.put(leadlist.id,leadList);
        
        test.startTest();
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(leadList.id);
        
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess(), 'Lead Not Converted SuccessFully');
        lc.setOpportunityName('Test Lead');
        leadLst.add(leadList);       
        test.stopTest();
    }
}