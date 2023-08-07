/**
* File:        BoothApprovalProcess_test
* Project:     GAP
* Date:        2/18/2019 8:54 PM
* Created By:  Rajesh Kumar
* Test Class:  -----
************************************************************************
@description created test class for BoothApprovalProcess_Trig apex class
* Modified By: Rajesh Kumar On 13 FeB 2019 T - GGCW-3124
************************************************************************
* History:
*/

@isTest
public class BoothApprovalProcess_test {
    static testmethod void boothApprovalProcessTrig(){
        Trigger__c trig = new Trigger__c(Name = 'BoothApprovalProcess_Trig' , Trigger_Name_Unique__c='BoothApprovalProcess_Trig',Enabled__c=true,Object__c='Booth_Approval_Dashboard__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=40,
                                         After_Update__c = true);
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        
        TriggerInterface_BoothApprovalDashboard boothAprvlIntfc = new TriggerInterface_BoothApprovalDashboard();
        
        TriggerInterfaceHelper.runTrigger('BoothApprovalProcess_Trig','Booth_Approval_Dashboard__c',1, 'au', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('BoothApprovalProcess_Trig');
        
        Account acc= new Account();
        acc.Name='Test Adarsh';
        insert acc;
        System.assertEquals('Test Adarsh' , acc.Name,'Account is not created');
        
        Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = acc.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='',MailingCountry='India', MobilePhone = '2121212145');
        insert oCon;
        
        Brand__c oBrand = new Brand__c(Name='World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c=oBrand.id , Event_Edition_Pool__c = 'WOC');
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
        edi.Event_Edition_Status__c='Completed';
        insert edi;
        
        Contract contracts=new Contract();
        contracts.StartDate=Date.today();
        contracts.AccountId=acc.Id;
        contracts.Status='Draft';
        contracts.StartDate = Date.today();
        Insert contracts;
        
        Opportunity opp=new opportunity(Name='TestOpp');
        opp.AccountId=acc.Id;
        opp.CloseDate = Date.newInstance(2019, 10, 03);
        opp.StageName = 'Proposal sent';
        opp.EventEdition__c= edi.Id;
        opp.Main_Contract__c=contracts.Id;
        opp.Billing_Contact__c=oCon.Id;
        opp.Total_No_of_payment__c = 2;
        Insert opp;
        
        Booth_Approval_Dashboard__c  boothLst =new Booth_Approval_Dashboard__c();
        boothLst.Opportunity__c=opp.Id;
        insert boothLst;
        boothlst.Status__c='Approved';
        Update boothLst;
        boothlst.Status__c='Declined';
        Update boothLst;
        
        Test.startTest();
        BoothApprovalProcess_Trig obj = new BoothApprovalProcess_Trig(); 
        TriggerInterfaceHelper.runTrigger('BoothApprovalProcess_Trig','Booth_Approval_Dashboard__c',40, 'au', null,null,'All'); 
        Test.stopTest();
    }
}