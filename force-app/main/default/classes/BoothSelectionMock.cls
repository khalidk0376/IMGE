/**
* File:        BoothSelectionMock.cls
* Project:     GAP
* Date:        Sep 09, 2022
* Created By:  Khan Faisal
* *************************************************************************
* Description: Mock class to return expocad response for test classes. 
*/
  
@isTest
global class BoothSelectionMock implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req) {
        System.debug('Request Recieved ::: ' + req);
        HTTPResponse res = new HTTPResponse();
        PageReference ref = new PageReference(req.getEndpoint());
        req.setMethod('GET');
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('User-Agent', 'salesforce-desk-client/0.1.0');
        res.setHeader('Accept', 'text/JSON;charset=UTF-8');

       if (req.getEndpoint().toLowerCase().contains('/booths?boothnumber')) {
            res.setBody('{"ExhibitorId":"0012C000004oaCvQAI","BoothNumber":"KG7","Dimensions":"10","XSize":"10","YSize":"10","Area":"100 SqFt","Status":"Unknown","BoothClass":"Test","BoothClasses": ["Pavilion Booth"],"Pavilion":"sPavilion","ShowInShow":"Indoor","BoothType":"Peninsula","UnitType":"ftin","HoldExhibitorId":"","HoldExhibitorName":"","OpenCorners":2,"IsDeleted":false,"IsOnHold":false,"IsRented":True}');
            res.setStatusCode(200);
            res.setStatus('OK');
        } else if (req.getEndpoint().toLowerCase().contains('/booths/all')) {
            res.setBody('[{"ExhibitorId":"0012C000004oaCvQAI","BoothNumber":"KG7","Dimensions":"10","XSize":"10","YSize":"10","Area":"100 SqFt","Status":"Unknown","BoothClass":"Indoor","Pavilion":"pav1","ShowInShow":"Indoor","BoothType":"Peninsula","UnitType":"ftin","HoldExhibitorId":"","HoldExhibitorName":"","OpenCorners":2,"IsDeleted":false,"IsOnHold":False,"IsRented":True},{"ExhibitorId":"0012C000004oaCvQAI","BoothNumber":"KG7","Dimensions":"10","XSize":"10","YSize":"10","Area":"10.5 SqFt","Status":"Unknown","BoothClass":"Indoor","Pavilion":"Pav2","ShowInShow":"Indoor2","BoothType":"Peninsula","UnitType":"ftin","HoldExhibitorId":"","HoldExhibitorName":"","OpenCorners":0,"IsDeleted":false,"IsOnHold":False,"IsRented":True}]');
            res.setStatusCode(200);
            res.setStatus('OK');
        }
        else {
             res.setBody('{"ExhibitorId":"0012C000004oaCvQAI","BoothNumber":"KG7","Dimensions":"10","XSize":"10","YSize":"10","Area":"100 SqFt","Status":"Unknown","BoothClass":"Test","BoothClasses": ["Pavilion Booth"],"Pavilion":"","ShowInShow":"Indoor","BoothType":"Peninsula","UnitType":"ftin","HoldExhibitorId":"","HoldExhibitorName":"","OpenCorners":2,"IsDeleted":false,"IsOnHold":true,"IsRented":True}');
            res.setStatusCode(200);
            res.setStatus('OK');
        }
       System.debug(res);
        return res;
    }

}