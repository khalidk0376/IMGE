/**
* Project:         GAP
* Created Date:    14/12/2018
* Test Class For:  RemovedCoExhibitorClosedLost.trg
* Code Coverage:   93%
* Created By:      Rajesh Kumar
* Modified Date:   14/12/2018
* *************************************************************************
* Description:     Test class for RemovedCoExhibitorClosedLost Trigger.
* *************************************************************************
* History:
*/

@isTest
public class RemovedCoExhibitorClosedLost_Test {
    
    static testMethod void removedCoExhibitorClosedLostTestMethod() {
        
        // Create Trigger test record 
        Trigger__c trig = new Trigger__c(Name = 'RemovedCoExhibitorClosedLost_class' , Trigger_Name_Unique__c='RemovedCoExhibitorClosedLost_class',Enabled__c=true,Object__c='Opportunity_ExpoCAD_Booth_Mapping__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=1,
                                         After_Insert__c=true , After_Update__c = true);
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt; 
        
        //Call event edition trigger interface
        //TriggerInterface_OppExpoCADBoothMapping obj = new TriggerInterface_OppExpoCADBoothMapping(); 
        
        
        //@Description: Insert Account.
        Account acc = new Account();
        acc.Name = 'Testing Account'; 
        acc.CurrencyIsoCode = 'USD';
        insert acc;
        System.assertEquals('Testing Account', acc.name,'Account NOt Created');
        
        //@Description: Insert Contact.
        Contact ocontact = new Contact();
        ocontact.FirstName = 'Testing First Name';
        ocontact.LastName = 'Testing Last Name';
        ocontact.Email = 'test.test@gmail.com';
        ocontact.AccountId = acc.Id;
        insert ocontact;
        
        //@Description: Insert Event Edition.
        Event_Edition__c eventEdition = new Event_Edition__c();
        eventEdition.Name = 'Testing Event Edition';
        eventEdition.Tab1__c = 'Tab1';
        eventEdition.Tab4__c = 'Tab4';
        eventEdition.Tab8__c = 'Tab8';
        eventEdition.Event_Code__c = 'sbah19';
        eventEdition.Expocad_API_Url__c = 'https://api2.expocad.com/edgewebapi/informaSB';
        insert eventEdition;
        
        //@Description: Insert Opportunity.
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Testing Opportunity';
        opp1.EventEdition__c = eventEdition.Id;
        opp1.Opportunity_Contact__c = ocontact.Id;
        opp1.AccountId = acc.Id;
        opp1.CloseDate = Date.Today().addDays(1);
        opp1.StageName = 'Discover';
        insert opp1;
        
        //@Description: Insert Quote 
        SBQQ__Quote__c oQuote1 = new SBQQ__Quote__c();
        oQuote1.CurrencyIsoCode = 'USD';
        oQuote1.SBQQ__Status__c = 'Quote Sent';
        oQuote1.SBQQ__Type__c = 'Quote';
        oQuote1.SBQQ__Opportunity2__c = opp1.Id;
        oQuote1.SBQQ__Account__c = acc.Id;
        oQuote1.SBQQ__Primary__c = true;
        insert oQuote1;
        
        
        Opportunity oppRel = new Opportunity();
        oppRel.Name = 'Testing Opportunity';
        oppRel.SBQQ__PrimaryQuote__c = oQuote1.Id;
        oppRel.EventEdition__c = eventEdition.Id;
        oppRel.Opportunity_Contact__c = ocontact.Id;
        oppRel.AccountId = acc.Id;
        oppRel.CloseDate = Date.Today().addDays(1);
        oppRel.StageName = 'Discover';
        insert oppRel;
        
        //@Description: Insert Booth Product Type Configuration.
        Booth_Product_Type_Configuration__c bpt = new Booth_Product_Type_Configuration__c();
        bpt.Booth_Product_Type__c = 'Space Only';
        bpt.Matched_Product_Name__c = 'Space Only';
        bpt.CurrencyIsoCode = 'USD';
        insert bpt;
        
        ExpocadBooth__c oEB = new ExpocadBooth__c();
        oEB.Quote__c = oQuote1.Id;
        oEB.Opportunity__c = opp1.Id;
        oEB.Account__c = acc.Id;
        oEB.Open_Corners__c = 4;
        oEB.Dimensions__c = '';
        oEB.Booth_Type__c = 'Linear';
        oEB.Area__c = '100 SqFt';
        oEB.Last_Action_Date__c = Date.today();
        oEB.Booth_Number__c = 'TESTBN3';
        oEB.Status__c = 'Rented';
        oEB.Selected__c = True;
        insert oEB;
        
        //@Description: Insert Opportunity ExpoCAD Booth Mapping       
        Opportunity_ExpoCAD_Booth_Mapping__c oOEBM = new Opportunity_ExpoCAD_Booth_Mapping__c();
        oOEBM.Account__c = acc.Id;
        oOEBM.Contact__c =  ocontact.Id;               
        oOEBM.Status__c = 'Active';   
        oOEBM.Related_Opportunity__c = oppRel.Id;
        oOEBM.Opportunity__c = opp1.Id;
        oOEBM.Expocad_Booth__c = oEB.Id;
        oOEBM.Quote__c = oQuote1.Id;
        oOEBM.Relation__c = 'Agent';
        oOEBM.Is_Parent_Mapping__c=false;
        insert oOEBM;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oOEBM1 = new Opportunity_ExpoCAD_Booth_Mapping__c();
        oOEBM1.Account__c = acc.Id;
        oOEBM1.Contact__c =  ocontact.Id;               
        oOEBM1.Status__c = 'Active';   
        oOEBM1.Related_Opportunity__c = oppRel.Id;
        oOEBM1.Opportunity__c = opp1.Id;
        oOEBM1.Expocad_Booth__c = oEB.Id;
        oOEBM1.Quote__c = oQuote1.Id;
        oOEBM1.Relation__c = 'Agent';
        oOEBM1.Parent_Opp_EB_Mapping__c = oOEBM.id;
        oOEBM1.Is_Parent_Mapping__c=false;
        oOEBM1.Display_Name__c = 'test';
        insert oOEBM1;
        
        //Call trigger app handler for insert event
       //// TriggerInterfaceHelper.runTrigger('RemovedCoExhibitorClosedLost_class','Opportunity_ExpoCAD_Booth_Mapping__c',1, 'ai', null,null,'All');
       // TriggerInterfaceHelper.initTriggerMapAndList('RemovedCoExhibitorClosedLost_class');   
        
        oOEBM1.Status__c = 'Inactive';
        oOEBM1.Display_Name__c = 'test2';
        update oOEBM1;
        
        oOEBM1.Display_Name__c = 'test3';
        update oOEBM1;
        
        //TriggerInterfaceHelper.runTrigger('RemovedCoExhibitorClosedLost_class','Opportunity_ExpoCAD_Booth_Mapping__c',1, 'au', null,null,'All');
       // TriggerInterfaceHelper.initTriggerMapAndList('RemovedCoExhibitorClosedLost_class'); 
        
        oOEBM1.Status__c = 'Active';
        oOEBM1.Display_Name__c = 'test4';
        update oOEBM1;
        
        //TriggerInterfaceHelper.runTrigger('RemovedCoExhibitorClosedLost_class','Opportunity_ExpoCAD_Booth_Mapping__c',1, 'au', null,null,'All');
       // TriggerInterfaceHelper.initTriggerMapAndList('RemovedCoExhibitorClosedLost_class'); 
              
        Test.startTest();      
        Boolean isFalse = false; 
        RemovedCoExhibitorClosedLost_class.updateDisplayDrawingNameToExibitor( oOEBM1.Booth_Number__c, oOEBM1.Event_Code__c, oOEBM1.Opportunity__c , 'Hi'  , isFalse , '');
        Test.stopTest();
     }   
}