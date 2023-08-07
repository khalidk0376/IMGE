/**
* File:            PopulateExpoDetailsCtrl_Test
* Project:         GAP
* Date:            Sep 13, 2016
* Test Class For:  PopulateExpoDetailsCtrl
* Code Coverage:   87%
* Created By:      Kumar Gaurav
* *************************************************************************
* @description Test class for PopulateExpoDetailsCtrl.
* *************************************************************************
* History: Bk-9213 RaJesh Kumar on 29-09-2020
*/

@isTest(seeAlldata = false)
public class PopulateExpoDetailsCtrl_Test {
    /**
     * @description autorunTest Method Test
     */
    static testMethod void autorunTest() {
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 123456',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'SBARHE0', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Expocad_API_Url__c = 'https://api2.expocad.com/edgewebapi/informaSB' , Pavilion__c  = 'pav1,Pav2');
        insert oEvent;   
        ExpocadCredential__c expCred =  new ExpocadCredential__c(Name = 'ExpocadApiCredential',Org_Id__c = UserInfo.getOrganizationId(),Expocad_Host_URL__c = 'test.com',Url__c = 'test.com');
        insert expCred; 
        System.assertEquals('ExpocadApiCredential', expCred.Name, 'Here value is not same');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oEvent);
        Apexpages.currentpage().getparameters().put('id' , oEvent.id);
        PopulateExpoDetailsCtrl oPopulateExpoDetailsCtrl = new PopulateExpoDetailsCtrl(sc);
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new ExpocadMock());
        oPopulateExpoDetailsCtrl.autorun();
        oPopulateExpoDetailsCtrl.sErrorMsg = 'sErrorMsg';
        oPopulateExpoDetailsCtrl.returnToPT();
        Database.executeBatch(new PopulateExpoDetailsBatch(), 1);
        Test.StopTest();
    }
}