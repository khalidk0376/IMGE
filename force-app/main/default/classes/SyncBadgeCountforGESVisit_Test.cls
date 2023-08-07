/**
* Created By    :  Girikon(Aishwarya)[BK-9194/9188]
* Created On    :  15/10/2020
* @description  :  Test class for SyncBadgeCountforGESVisit
* Test Class    :  SyncBadgeCountforGESVisit_test
* Modified By   :  25/11/2020
**/

@isTest
public class SyncBadgeCountforGESVisit_Test{
    static testMethod void SyncBadgeCountforGESVisitTest()
    {
        Trigger__c trig = new Trigger__c(Name = 'SyncBadgeCountforGESVisit_Trig' , Trigger_Name_Unique__c='SyncBadgeCountforGESVisit_Trig',Enabled__c=true,Object__c='ExpocadBooth__c',
                                            Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                            After_Insert__c=true , After_Delete__c = true , Before_Insert__c = true , After_Update__c = true , After_UnDelete__c = true);
        insert trig;
        System.assertEquals('ExpocadBooth__c', trig.Object__c, 'Here value is not same');
        
        Trigger_Recordtype__c rrrt = new Trigger_Recordtype__c(Recordtype_Id__c=trig.Id , Trigger__c=trig.Id,Enabled__c=true, Parameters__c='param=1;param=2');
        Insert rrrt; 
        System.assertEquals(true, rrrt.Enabled__c, 'Here value is not same');
         
        TriggerInterface_ExpocadBooth obj = new TriggerInterface_ExpocadBooth();
       
        TriggerInterfaceHelper.runTrigger('SyncBadgeCountforGESVisit_Trig ','ExpocadBooth__c', 2, 'au', rrrt.id ,rrrt.Parameters__c,'All');
        
        Account acc = new Account(Name='TstAccFrst');
        insert acc;
        System.assertNotEquals(null, acc.Name, 'Account Name must not be null');
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'TOC Europe', CurrencyISOCode = 'USD', Package_Identifier__c = 'toc' , Event_Edition_Pool__c = 'tOC');
        oEventseries.Status__c = 'Active';
        insert oEventseries;
        System.assertNotEquals(null, oEventseries.Name, 'Event Series Name must not be null');
        
        //Create Event_Edition
        Event_Edition__c evntEditon = new Event_Edition__c(Name='TestName',CurrencyIsoCode='USD',Event_Code__c='toc',Event_Edition_Status__c='Confirmed',
                                                                    End_Date__c=date.today(), Start_Date__c=date.today()-1);
        evntEditon.Part_of_Series__c = oEventseries.Id;
        insert evntEditon ;
        System.assertEquals('TestName', evntEditon.Name, 'Here value is not same');
        
         User_Type__c userType = new User_Type__c();
         userType.Name = 'Co-Exhibitor';
         insert userType;
         System.assertEquals('Co-Exhibitor', userType.Name, 'Here value is not same');

        //Create Opportunity
        Opportunity opp = new Opportunity(Name='Test opp', StageName='Needs Assessment', EventEdition__c = evntEditon.id,AccountId=acc.id,EventSeries__c='Arab Health',
                                                    Event_Edition__c='Arab Health 2016',CloseDate=date.today()+19,User_Type__c =userType.Id);
        insert opp;
        System.assertEquals('Needs Assessment', opp.StageName, 'Here value is not same');
                        
        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acc.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = opp.Id;
        qtObj.CurrencyIsoCode='BRL';
        insert qtObj;
        System.assertEquals(acc.Id, qtObj.SBQQ__Account__c, 'Here value is not same');
        
        opp.SBQQ__PrimaryQuote__c = qtObj.Id;
        opp.StageName='Closed Won';
        Test.StartTest();
        update opp;
        
        //Create Event_Settings__c
        Event_Settings__c evntSetting = new Event_Settings__c(Name='Test Event', Allotment_By_Booth_Size__c=true, Event_Edition__c=evntEditon.id, Allotment_By_Booth_Type__c=false);
        insert evntSetting;
        System.assertEquals(evntEditon.id, evntSetting.Event_Edition__c, 'Here value is not same');
        
        //Create Booth_Size_Badge_Limit__c
        Booth_Size_Badge_Limit__c bsbl =new Booth_Size_Badge_Limit__c(Badges_Allowed__c = 20, Booth_Size_From__c = 1, Booth_Size_To__c= 250, Event_Edition__c = evntEditon.id);
        insert bsbl;
        System.assertEquals(20, bsbl.Badges_Allowed__c, 'Here value is not same');
        
        //Create ExpocadBooth__c
        ExpocadBooth__c expoBooth = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.',Area__c = '11.25 m²',  Unit_Type__c='m',Dimensions__c='5M x 10M',Account__c=acc.id, 
                                                        status__c='Rented',quote__c=qtObj.Id,Opportunity__c =opp.id);
        insert expoBooth;
        System.assertEquals('TestBoothNo.', expoBooth.Booth_Number__c, 'Here value is not same');
         
        //Create Opportunity_ExpoCAD_Booth_Mapping__c
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = acc.Id, Badge_Limit__c = 2, status__c = 'Active', 
                                                                    quote__c=qtObj.Id, Expocad_Booth__c = expoBooth.Id, Total_Badges__c =0,Opportunity__c =opp.Id);
        insert oppExpoBoothMapping;
        System.assertEquals(acc.Id, oppExpoBoothMapping.Account__c, 'Here value is not same');
        
        expoBooth.Booth_Number__c ='TestBoothNo2';
        update expoBooth;
        
        Opportunity opp2 = new Opportunity(Name='Test opp', StageName='Closed Won', EventEdition__c = evntEditon.id,AccountId=acc.id,EventSeries__c='Arab Health',
                                                    Event_Edition__c='Arab Health 2016',CloseDate=date.today()+20);
        insert opp2;
        System.assertEquals('Closed Won', opp2.StageName, 'Here value is not same');

        Event_Settings__c evntSetting2 = new Event_Settings__c(Name='Test Event', Allotment_By_Booth_Size__c=false, Event_Edition__c=evntEditon.id, Allotment_By_Booth_Type__c=true);
        insert evntSetting2;
        System.assertEquals(evntEditon.id, evntSetting2.Event_Edition__c, 'Here value is not same');
        
        //Create Booth_Size_Badge_Limit__c
        Booth_Size_Badge_Limit__c bsbl2 =new Booth_Size_Badge_Limit__c(Badges_Allowed__c = 10, Booth_Type__c ='Space Only', Match_Product_Entry_Type__c ='Fixed', Event_Edition__c = evntEditon.id);
        insert bsbl2;
        system.assertEquals(10, bsbl2.Badges_Allowed__c,'Here value is not same');
        
        //Create ExpocadBooth__c
        ExpocadBooth__c expoBooth2 = new ExpocadBooth__c(Booth_Number__c='TestBoothNo3.',Area__c = '11.25 m²',  Unit_Type__c='m',Dimensions__c='5M x 10M',Account__c=acc.id, status__c='Rented',
                                                                    quote__c=qtObj.Id,Matched_Product_Name__c='Space Only',Opportunity__c =opp2.id);
        insert expoBooth2;
        System.assertEquals('TestBoothNo3.', expoBooth2.Booth_Number__c, 'Here value is not same');
        
        //Create Opportunity_ExpoCAD_Booth_Mapping__c
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping2 = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = acc.Id, Badge_Limit__c = 2, status__c = 'Active', 
                                                                                            quote__c=qtObj.Id, Expocad_Booth__c = expoBooth2.Id, Opportunity__c =opp2.Id, Total_Badges__c =0);
        insert oppExpoBoothMapping2;
        System.assertEquals(acc.Id, oppExpoBoothMapping2.Account__c, 'Here value is not same');
        expoBooth.Booth_Number__c ='TestBoothNo33';
        update expoBooth2;
        Test.StopTest();
     }
     
    static testMethod void SyncBadgeCountforGESVisitTest2()
    {
        Trigger__c trig = new Trigger__c(Name = 'SyncBadgeCountforGESVisit_Trig' , Trigger_Name_Unique__c='SyncBadgeCountforGESVisit_Trig',Enabled__c=true,Object__c='ExpocadBooth__c',
                                            Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                            After_Insert__c=true , After_Delete__c = true , Before_Insert__c = true , After_Update__c = true , After_UnDelete__c = true);
        insert trig;
        System.assertEquals('ExpocadBooth__c', trig.Object__c, 'Here value is not same');
        
        Trigger_Recordtype__c rrrt = new Trigger_Recordtype__c(Recordtype_Id__c=trig.Id , Trigger__c=trig.Id,Enabled__c=true, Parameters__c='param=1;param=2');
        Insert rrrt;
        System.assertEquals(true, rrrt.Enabled__c, 'Here value is not same');
         
        TriggerInterface_ExpocadBooth obj = new TriggerInterface_ExpocadBooth();
       
        TriggerInterfaceHelper.runTrigger('SyncBadgeCountforGESVisit_Trig ','ExpocadBooth__c', 2, 'au', rrrt.id ,rrrt.Parameters__c,'All');
        
        Account acc = new Account(Name='TstAccFrst');
        insert acc;
        System.assertNotEquals(null, acc.Name, 'Account Name must not be null');
         
        Event_Series__c oEventseries = new Event_Series__c(Name = 'TOC Europe', CurrencyISOCode = 'USD', Package_Identifier__c = 'toc' , Event_Edition_Pool__c = 'tOC');
        oEventseries.Status__c = 'Active';
        insert oEventseries;
        System.assertNotEquals(null, oEventseries.Name, 'Event Series Name must not be null');
        
        //Create Event_Edition
        Event_Edition__c evntEditon = new Event_Edition__c(Name='TestName',CurrencyIsoCode='USD',Event_Code__c='toc',Event_Edition_Status__c='Confirmed',
                                                                    End_Date__c=date.today(), Start_Date__c=date.today()-1);
        evntEditon.Part_of_Series__c = oEventseries.Id;
        insert evntEditon ;
        System.assertNotEquals(null, oEventseries.Name, 'Event Series Name must not be null');

        //Create Opportunity
        Opportunity opp = new Opportunity(Name='Test opp', StageName='Needs Assessment', EventEdition__c = evntEditon.id,AccountId=acc.id,EventSeries__c='Arab Health',Event_Edition__c='Arab Health 2016',CloseDate=date.today()+19);
        insert opp;
        System.assertEquals('Needs Assessment', opp.StageName, 'Here value is not same');
                        
        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acc.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = opp.Id;
        qtObj.CurrencyIsoCode='BRL';
        insert qtObj;
        System.assertEquals(acc.Id, qtObj.SBQQ__Account__c, 'Here value is not same');
        
        opp.SBQQ__PrimaryQuote__c = qtObj.Id;
        opp.StageName='Closed Won';
        Test.StartTest();
        update opp;
        
        Event_Settings__c evntSetting2 = new Event_Settings__c(Name='Test Event', Event_Edition__c=evntEditon.id, Allotment_By_Booth_Type__c=true);
        insert evntSetting2;
        System.assertEquals(evntEditon.id, evntSetting2.Event_Edition__c, 'Here value is not same');
        
        //Create Booth_Size_Badge_Limit__c
        Booth_Size_Badge_Limit__c bsbl2 =new Booth_Size_Badge_Limit__c(Badges_Allowed__c = 20, Booth_Type__c ='Space Only', Match_Product_Entry_Type__c ='Fixed', Event_Edition__c = evntEditon.id);
        insert bsbl2;
        System.assertEquals(20, bsbl2.Badges_Allowed__c, 'Here value is not same');
        
        //Create ExpocadBooth__c
        ExpocadBooth__c expoBooth2 = new ExpocadBooth__c(Booth_Number__c='TestBoothNo3.',Area__c = '11.25 m²',  Unit_Type__c='m',Dimensions__c='5M x 10M',Account__c=acc.id, status__c='Rented',
                                                                    quote__c=qtObj.Id, Matched_Product_Name__c='Space Only', Opportunity__c =opp.id);
        insert expoBooth2;
        expoBooth2.Booth_Number__c ='TestBoothNo33';
        update expoBooth2;
        System.assertEquals('TestBoothNo33', expoBooth2.Booth_Number__c, 'Here value is not same');

        //Create Opportunity_ExpoCAD_Booth_Mapping__c
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping2 = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = acc.Id, Badge_Limit__c = 2, status__c = 'Active', 
                                                                    quote__c=qtObj.Id, Expocad_Booth__c = expoBooth2.Id, Total_Badges__c =0);
        insert oppExpoBoothMapping2;
        System.assertEquals(acc.Id, oppExpoBoothMapping2.Account__c,'Here value is not same');
        expoBooth2.status__c = 'Released';
        update expoBooth2;
        Test.StopTest();
     }
}