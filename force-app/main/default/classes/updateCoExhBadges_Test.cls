/**
* Created By    :  Girikon(Aishwarya)[BK-16730]
* @description  :  Test class for updateCoExhBadges
* Modified By   :  [Aishwarya BK-16730 28 July 2021]
**/
@isTest
public class updateCoExhBadges_Test
{
    static testMethod void testMethod1()
    {
        Account acc = new Account(Name='TstAccFrst');
        insert acc;
        System.assertNotEquals(null, acc.Name, 'Account Name must not be null');
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'TOC Europe', CurrencyISOCode = 'USD', Package_Identifier__c = 'toc',Status__c='Active');
        insert oEventseries;
        System.assertNotEquals(null, oEventseries.Name, 'Event Series Name must not be null');
        
        //Create Event_Edition
        Event_Edition__c evntEditon = new Event_Edition__c(Name='TestName',CurrencyIsoCode='USD',Event_Code__c='toc',Event_Edition_Status__c='Confirmed',
                                                                    End_Date__c=date.today(), Start_Date__c=date.today()-1);
        evntEditon.Part_of_Series__c = oEventseries.Id;
        insert evntEditon;
        System.assertEquals('TestName', evntEditon.Name,'Event Edition name should be TestName');
        
        User_Type__c uType = new User_Type__c();
        uType.Name = 'Co-Exhibitor';
        insert uType;
        System.assertEquals('Co-Exhibitor', uType.Name,'user type shoud be Co-Exhibitor');

        //Create Opportunity
        Opportunity opp = new Opportunity(Name='Test opp', StageName='Closed Won', EventEdition__c = evntEditon.id,AccountId=acc.id,EventSeries__c='Arab Health',
                                                Event_Edition__c='Arab Health 2016',User_Type__c=uType.Id,CloseDate=date.today()+19);
        insert opp;
        System.assertEquals('Closed Won', opp.StageName,'Opportunity stage must be closed won');
        
        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acc.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = opp.Id;
        qtObj.CurrencyIsoCode='BRL';
        insert qtObj;
        System.assertEquals(acc.Id, qtObj.SBQQ__Account__c,'Account id must be equal to Quote account id');
        
        //Create Event_Settings__c
        Event_Settings__c evntSetting = new Event_Settings__c(Name='Test Event', Co_Exhibitor_Badge_Limit__c ='10', Event_Edition__c=evntEditon.id);
        insert evntSetting;
        System.assertEquals(evntEditon.id, evntSetting.Event_Edition__c,'Event edition id must be event setting event id');
        
        
        //Create ExpocadBooth__c
        ExpocadBooth__c expoBooth2 = new ExpocadBooth__c(Booth_Number__c='TestBoothNo3.',Area__c = '11.25 m²',  Unit_Type__c='m',Dimensions__c='5M x 10M',Account__c=acc.id, 
                                                            status__c='Rented', quote__c=qtObj.Id, Matched_Product_Name__c='Space Only', Opportunity__c =opp.id);
        insert expoBooth2;
        Test.startTest();
            //Create Opportunity_ExpoCAD_Booth_Mapping__c
            Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping2 = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = acc.Id, Opportunity__c =opp.Id,status__c = 'Active', quote__c=qtObj.Id, Expocad_Booth__c = expoBooth2.Id, Total_Badges__c =0);
            insert oppExpoBoothMapping2;
            System.assertEquals(acc.Id, oppExpoBoothMapping2.Account__c,'Account Id should equal to Expocad mapping account id');
        Test.stopTest();
    }
}