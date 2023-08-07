/*
Created By		: Girikon(Himanshu[STL-160])
Created On		: Sep 25 2019
@description 	: This class is test class for ops_emailTemplatesCtrl.
Test Class		: 

Modification log --
Modified By		: 
*/
    

@isTest
public class ops_emailTemplatesCtrl_Test {

    public static testmethod void exhibitorWithoutContractor() {
       
       Brand__c oBrand = new Brand__c(Name='World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
      
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c=oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;
        
        FromEmailAddressESMapping__c emailMapping = new FromEmailAddressESMapping__c();
        emailMapping.Event_Series_Name__c=oEvent.Part_of_Series__c;
        emailMapping.Org_Wide_From_Email_Addresses__c ='techarabhealth@informa.com';
        insert emailMapping;
        
        Test.startTest();
        ops_emailTemplatesCtrl.getEmails(oEvent.id);
        system.assertEquals('World Of Concrete', oEventseries.Name, 'Event Series cannot be null') ;
        Test.stopTest();
        
    }
}