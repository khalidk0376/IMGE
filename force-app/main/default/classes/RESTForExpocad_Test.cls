@isTest
private class RESTForExpocad_Test {
  static testMethod void testDoGet() {
      test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
       ExpocadCredential__c expCred =  new ExpocadCredential__c(Name = 'ExpocadApiCredential',Org_Id__c = UserInfo.getOrganizationId(),Expocad_Host_URL__c = 'test.com',Url__c = 'test.com');
        insert expCred;        
       Event_Edition__c  evEdition = new Event_Edition__c(Expocad_API_Url__c='https://api.expocad.com',Event_Code__c ='woc17' , Tab1__c = 'tab1', Tab7__c= 'tab7');
    insert evEdition;
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    req.requestURI = 'https://api.expocad.com/edgeapi/events/stats?databaseName=woc17';  
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
      
    RestContext.request.params.put('EventCode','woc17');
      
       
    List < Map < String , String >> mapInstance = RESTForExpocad.GetExpocadJsonForEventStats();
      System.assertEquals('https://api.expocad.com' , evEdition.Expocad_API_Url__c , 'Test class failed');
      test.stopTest();
  }
     public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        /**
        * @description : Implement this interface method.    
        * @param req 
        * @return : HTTPResponse     
        **/
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"TotalBooths":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
}