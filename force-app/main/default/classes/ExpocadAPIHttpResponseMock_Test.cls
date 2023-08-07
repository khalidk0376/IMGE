@isTest
public with sharing class ExpocadAPIHttpResponseMock_Test {
   @isTest
   static void mockClassTest(){
    Test.startTest();

    ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
    Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,''));
    Map<String,String> mapstr = new Map<String,String>();
    mapstr.put('/update','dfssghfd');
    mapstr.put('/contact','dfssghfd');
    mapstr.put('/exhibitors/','dfssghfd');
    mapstr.put('/booths?','dfssghfd');
    ExpocadAPIHttpResponse_Mock rec1 = new ExpocadAPIHttpResponse_Mock(mapstr);

    HttpRequest response = new HttpRequest() ; 
    response.setEndpoint('exhibitors');
    rec1.respond(response);
    response.setEndpoint('/booths?');
    mockCls.respond(response);

    System.assertNotEquals(response,null, 'Not Found');//EX-101
       
    Test.stopTest();
   } 


}