/**
* Project:         GAP
* Date:            10/04/2019
* Test Class For:  ExpocadRentedBooth_LWC
* Code Coverage:   88%
* Created By:      Yash Gupta
* Modified Date:   10/23/2019
* Modified By:     Yash Gupta
* *************************************************************************
* @Description:    This test class covers "ExpocadRentedBooth_LWC" class.
* *************************************************************************
* History: 
*/

@isTest
public class ExpocadRentedBooth_LWC_Test {
    @isTest static void expocadRentedBoothMethodOne() {
        Test.startTest();
        Event_Edition__c  evEdition = new Event_Edition__c(Expocad_API_Url__c='https://api.expocad.com/',Event_Code__c ='woc17' , Tab1__c = 'tab1', Tab7__c= 'tab7');
        insert evEdition;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://api2.expocad.com/EdgeWebApi/informapsb/booths/all/rented?databaseName=PSBTST0';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('EventCode','woc17');
        Test.setMock(HttpCalloutMock.class, new ExpocadMock());
        Map <String , Object> mapInstance = ExpocadRentedBooth_LWC.getExpocadForEventStats('woc17');
        ExpocadRentedBooth_LWC.GetExpocadJsonForEventStats('woc17');
        ExpocadRentedBooth_LWC.getRESTForExpocadAllBooth('woc17');
        System.assertNotEquals(mapInstance, null,'true');
        Test.stopTest();
    }
}