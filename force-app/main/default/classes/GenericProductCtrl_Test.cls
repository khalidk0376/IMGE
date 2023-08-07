/**
* File			:  	GenericProductCtrl_Test
* Project		:  	Event Setup Project
* Created Date	: 	7th April 2021
* Created By	:   Deepak(Girikon) [ESP-90]
* Coverage      :   100%
* *******************************************************************************************************
* @description : Test Class for GenericProductCtrl
* *******************************************************************************************************
* Last Modified By : 
*/
@isTest
private class GenericProductCtrl_Test {
    @isTest 
    static void testGetGenericProductsCustomMetaData()
    {
        Test.startTest();
        List<Generic_Product__mdt> lstGenericProducts = GenericProductCtrl.getGenericProductsCustomMetaData();
        System.assertEquals(5, lstGenericProducts.size(), 'All data not fetched');
        Test.stopTest();
    }
    
    @isTest 
    static void testcreateProductsAndPBEs()
    {
        Test.startTest();
        Pricebook2 pb = new Pricebook2(Name='Life Sciences');
        insert pb;
        Brand__c oBrand = new Brand__c(Name='General Healthcare', SSC_Email_Distribution_ID__c = 'test@test.tst');
    	insert oBrand;
    
    	Event_Series__c oEventseries = new Event_Series__c(Name = 'Africa Health', Event_Edition_Pool__c = 'AFHLTH', Package_Identifier__c = 'AFHLTH', Brand__c=oBrand.id);
    	insert oEventseries;
    
    	Event_Edition__c oEvent = new Event_Edition__c(Name = 'Africa Health 2021', Event_Code__c = 'AEL21ZAH',Event_Currency__c= 'USD',Alternate_Currency__c='ZAR',Event_Price_Book__c=pb.Id);
    	insert oEvent;
        GenericProductCtrl.getGenericProductsCustomMetaDataAndStatus(oEvent.Id);
        String requestString = '{"eventEditionId":"'+oEvent.Id+'","eventEditionName":"'+oEvent.Name+'","eventEditionPool":"'+oEventseries.Event_Edition_Pool__c+'","currencies":"USD,ZAR","eventPriceBookId":"'+oEvent.Event_Price_Book__c+'","brand":"'+oBrand.Name+'"}';
        GenericProductCtrl.createProductsAndPBEs(requestString);
        List<Product2> prods = [Select Id From Product2 Where Prospecting_Generic_Product__c=true];
        System.assertEquals(5, prods.size(), 'All Generic Products not created');
        Test.stopTest();
    }
    
    @isTest 
    static void testcreateProductsAndPBEsError()
    {
        Test.startTest();
        Pricebook2 pb = new Pricebook2(Name='Life Sciences');
        insert pb;
        Brand__c oBrand = new Brand__c(Name='General Healthcare', SSC_Email_Distribution_ID__c = 'test@test.tst');
    	insert oBrand;
    
    	Event_Series__c oEventseries = new Event_Series__c(Name = 'Africa Health', Event_Edition_Pool__c = 'AFHLTH', Package_Identifier__c = 'AFHLTH', Brand__c=oBrand.id);
    	insert oEventseries;
    
    	Event_Edition__c oEvent = new Event_Edition__c(Name = 'Africa Health 2021', Event_Code__c = 'AEL21ZAH',Event_Currency__c= 'USD',Alternate_Currency__c='ZAR',Event_Price_Book__c=pb.Id);
    	insert oEvent;
        String requestString = '{"eventEditionId":"'+oEvent.Id+'","eventEditionName":"'+oEvent.Name+'","eventEditionPool":"'+oEventseries.Event_Edition_Pool__c+'","currencies":"USD,ZAR","eventPriceBookId":"'+oEvent.Event_Price_Book__c+'","brand":"'+oBrand.Name+'"';
        GenericProductCtrl.createProductsAndPBEs(requestString);
        List<Product2> prods = [Select Id From Product2 Where Prospecting_Generic_Product__c=true];
        System.assertEquals(0, prods.size(), 'All Generic Products created');
        Test.stopTest();
    }
    
    @isTest 
    static void testaddValueToPicklistWithGVS()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String requestData = '{"gvsName":"Event_Edition","gvsValue":"Africa Health 2022","isCreateDependency":true,"isAddGVS":true,"objectApiName":"Product2","fieldDeveloperName":"Product_Brand"}';
        GenericProductCtrl.GVSUpdateResponse resp = GenericProductCtrl.addValueToPicklistWithGVS(requestData);
        System.assertEquals(true, resp.isSuccess, 'Picklist not updated');
        Test.stopTest();
    }
    
    @isTest 
    static void testaddValueToPicklistWithGVSError()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorError());
        String requestData = '{"gvsName":"Event_Edition","gvsValue":"Africa Health 2022","isCreateDependency":true,"isAddGVS":true,"objectApiName":"Product2","fieldDeveloperName":"Product_Brand"}';
        GenericProductCtrl.GVSUpdateResponse resp = GenericProductCtrl.addValueToPicklistWithGVS(requestData);
        System.assertEquals(false, resp.isSuccess, 'Picklist update not failed.');
        Test.stopTest();
    }
    
    @isTest 
    static void testcreateDependency()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String requestData = '{"Metadata":{"description":null,"externalId":false,"inlineHelpText":null,"label":"Event Edition","required":false,"restrictedAdminField":null,"scale":null,"securityClassification":null,"startingNumber":null,"stripMarkup":null,"summarizedField":null,"summaryFilterItems":null,"summaryForeignKey":null,"summaryOperation":null,"trackFeedHistory":false,"trackHistory":false,"trackTrending":null,"translateData":null,"type":"Picklist","unique":null,"urls":null,"valueSet":{"controllingField":"Event_Edition_Pool__c","restricted":true,"valueSetDefinition":null,"valueSetName":"Event_Edition","valueSettings":[{"controllingFieldValue":["GHS"],"valueName":"Global Health Exhibition 2019"},{"controllingFieldValue":["GHS"],"valueName":"OMNIA Saudi Arabia"}]},"visibleLines":null,"writeRequiresMasterRead":null}}';
        Boolean resp = GenericProductCtrl.createDependency('/services/data/v50.0/tooling/sobjects/CustomField/00000000000000',requestData);
        System.assertEquals(true, resp, 'dependency not updated');
        Test.stopTest();
    }
    
    /**
    * @description : Success Mocks Class.    
    **/
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        /**
        * @description : Implement this interface method.    
        * @param req 
        * @return : HTTPResponse     
        **/
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(String.valueOf(req.getEndpoint()).contains('/query') && String.valueOf(req.getEndpoint()).contains('from+globalvalueset')){
            	res.setBody('{"size":1,"totalSize":1,"done":true,"entityTypeName":"GlobalValueSet","records":[{"attributes":{"type":"GlobalValueSet","url":"/services/data/v50.0/tooling/sobjects/GlobalValueSet/0Nt50000000GmoLCAS"},"Id":"0Nt50000000GmoLCAS"}]}');
            }
            if(String.valueOf(req.getEndpoint()).contains('/sobjects/GlobalValueSet') && req.getMethod() == 'POST'){
            	res.setBody('{"example":"test"}');
            }
            if(String.valueOf(req.getEndpoint()).contains('/sobjects/GlobalValueSet') && req.getMethod() == 'GET'){
            	res.setBody('{"attributes":{"type":"GlobalValueSet","url":"/services/data/v50.0/tooling/sobjects/GlobalValueSet/0Nt50000000GmoLCAS"},"Metadata":{"customValue":[{"color":null,"default":false,"description":null,"isActive":null,"label":"Encontro Anual do Mercado Livre 2020","urls":null,"valueName":"Encontro Anual do Mercado Livre 2020"},{"color":null,"default":false,"description":null,"isActive":false,"label":"NT Expo Experience 2020","urls":null,"valueName":"NT Expo Experience 2020"},{"color":null,"default":false,"description":null,"isActive":false,"label":"Medlab Asia Pacific 2019","urls":null,"valueName":"Medlab Asia Pacific 2019"},{"color":null,"default":false,"description":null,"isActive":false,"label":"OMNIA 2018","urls":null,"valueName":"OMNIA 2018"},{"color":null,"default":false,"description":null,"isActive":false,"label":"ABF Expo 2020","urls":null,"valueName":"ABF Expo 2020"}],"description":null,"masterLabel":"Event Edition","sorted":false,"urls":null},"FullName":"Event_Edition","Id":"0Nt50000000GmoLCAS","DeveloperName":"Event_Edition","MasterLabel":"Event Edition","Description":null,"NamespacePrefix":null,"ManageableState":"unmanaged","CreatedDate":"2016-08-05T09:56:59.000+0000","CreatedById":"005500000065jAWAAY","LastModifiedDate":"2016-08-05T09:56:59.000+0000","LastModifiedById":"005500000065jAWAAY"}');
            }
            
            res.setStatusCode(200);
            return res;
        }
    }
    
    /**
    * @description : Error Mocks Class.    
    **/
    public class MockHttpResponseGeneratorError implements HttpCalloutMock {
        /**
        * @description : Implement this interface method.    
        * @param req 
        * @return : HTTPResponse     
        **/
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"');
            res.setStatusCode(200);
            return res;
        }
    }
}