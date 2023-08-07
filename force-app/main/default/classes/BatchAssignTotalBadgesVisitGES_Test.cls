/*
 * Created By:  Aishwarya Kumar (Girikon)
 * Created/Last Modified On :  28 June 2021
 * Apex Class:  BatchAssignTotalBadgesVisitGES
*/
@isTest
public class BatchAssignTotalBadgesVisitGES_Test
{
    static testmethod void BatchAssignTotalBadgesTest1() 
    {
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
        System.assertEquals('TestName', evntEditon.Name,'Event Edition name is TestName');
        
         User_Type__c userType = new User_Type__c();
         userType.Name = 'Co-Exhibitor';
         insert userType;
         System.assertEquals('Co-Exhibitor', userType.Name,'User Tye is Co-Exhibitor');

        //Create Opportunity
        Opportunity opp = new Opportunity(Name='Test opp', StageName='Needs Assessment', EventEdition__c = evntEditon.id,AccountId=acc.id,EventSeries__c='Arab Health',
                                                    Event_Edition__c='Arab Health 2016',CloseDate=date.today()+19,User_Type__c =userType.Id);
        insert opp;
        System.assertEquals('Needs Assessment', opp.StageName,'Stage is Needs Assesment');
                        
        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acc.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = opp.Id;
        qtObj.CurrencyIsoCode='BRL';
        insert qtObj;
        System.assertEquals(acc.Id, qtObj.SBQQ__Account__c,'Quote account equals to account id');
        
        opp.SBQQ__PrimaryQuote__c = qtObj.Id;
        opp.StageName='Closed Won';
        update opp;
        
        //Create Event_Settings__c
        Event_Settings__c evntSetting = new Event_Settings__c(Name='Test Event', Allotment_By_Booth_Size__c=true, Event_Edition__c=evntEditon.id, Allotment_By_Booth_Type__c=false,Is_Event_Edition_Live__c = True);
        insert evntSetting;
        System.assertEquals(evntEditon.id, evntSetting.Event_Edition__c,'Event Edition name should equals to Event Setting Edition name');
        
        //Create Booth_Size_Badge_Limit__c
        Booth_Size_Badge_Limit__c bsbl =new Booth_Size_Badge_Limit__c(Badges_Allowed__c = 20, Booth_Size_From__c = 1, Booth_Size_To__c= 250, Event_Edition__c = evntEditon.id);
        insert bsbl;
        System.assertEquals(20, bsbl.Badges_Allowed__c,'Allowed badges are 10');
        
        //Create ExpocadBooth__c
        ExpocadBooth__c expoBooth = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.',Area__c = '11.25 m²',  Unit_Type__c='m',Dimensions__c='5M x 10M',Account__c=acc.id, 
                                                        status__c='Rented',quote__c=qtObj.Id,Opportunity__c =opp.id);
        insert expoBooth;
        System.assertEquals('TestBoothNo.', expoBooth.Booth_Number__c,'Expocad Booth number should equals to TestBoothNo.');
         
        //Create Opportunity_ExpoCAD_Booth_Mapping__c
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = acc.Id, Badge_Limit__c = 2, status__c = 'Active', 
                                                                    quote__c=qtObj.Id, Expocad_Booth__c = expoBooth.Id,Opportunity__c =opp.Id);
        insert oppExpoBoothMapping;
        System.assertEquals(acc.Id, oppExpoBoothMapping.Account__c,'Accoun Id equals to Expocad Booth Mapping Account Id');
        
        expoBooth.Booth_Number__c ='TestBoothNo2';
        update expoBooth;
        
        Opportunity opp2 = new Opportunity(Name='Test opp', StageName='Closed Won', EventEdition__c = evntEditon.id,AccountId=acc.id,EventSeries__c='Arab Health',
                                                    Event_Edition__c='Arab Health 2016',CloseDate=date.today()+20);
        insert opp2;
        System.assertEquals('Closed Won', opp2.StageName,'Stage Name should equals to Closed Won');

        Event_Settings__c evntSetting2 = new Event_Settings__c(Name='Test Event', Allotment_By_Booth_Size__c=false, Event_Edition__c=evntEditon.id, Allotment_By_Booth_Type__c=true);
        insert evntSetting2;
        System.assertEquals(evntEditon.id, evntSetting2.Event_Edition__c, 'both values should be equals');
        
        //Create Booth_Size_Badge_Limit__c
        Booth_Size_Badge_Limit__c bsbl2 =new Booth_Size_Badge_Limit__c(Badges_Allowed__c = 10, Booth_Type__c ='Space Only', Match_Product_Entry_Type__c ='Fixed', Event_Edition__c = evntEditon.id);
        insert bsbl2;
        system.assertEquals(10, bsbl2.Badges_Allowed__c,'Allowed badges are 10' );
        
        //Create ExpocadBooth__c
        ExpocadBooth__c expoBooth2 = new ExpocadBooth__c(Booth_Number__c='TestBoothNo3.',Area__c = '11.25 m²',  Unit_Type__c='m',Dimensions__c='5M x 10M',Account__c=acc.id, status__c='Rented',
                                                                    quote__c=qtObj.Id,Matched_Product_Name__c='Space Only',Opportunity__c =opp2.id);
        insert expoBooth2;
        System.assertEquals('TestBoothNo3.', expoBooth2.Booth_Number__c,'Booth Number should equals to TestBoothNo3');
        
        //Create Opportunity_ExpoCAD_Booth_Mapping__c
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping2 = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = acc.Id, Badge_Limit__c = 2, status__c = 'Active', 
                                                                                            quote__c=qtObj.Id, Expocad_Booth__c = expoBooth2.Id, Opportunity__c =opp2.Id, Total_Badges__c =0);
        insert oppExpoBoothMapping2;
        System.assertEquals(acc.Id, oppExpoBoothMapping2.Account__c,'Account id equals Opp Expo Booth mapping account');
        Test.startTest();
            BatchAssignTotalBadgesVisitGES batch = new BatchAssignTotalBadgesVisitGES();
            Database.executeBatch(batch,1);
        Test.stopTest();
    }
}