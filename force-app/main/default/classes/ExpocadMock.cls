/**
* File:        ExpocadMock.cls
* Project:     GAP
* Date:        Aug 01, 2016
* Created By:  Kumar Gaurav
* *************************************************************************
* Description: Mock class to return expocad response for test classes. 

* *************************************************************************
* * History: Bk-9213 RaJesh Kumar on 29-09-2020
*/
  
@isTest
global class ExpocadMock implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req) {
        System.debug('Request Recieved ::: ' + req);
        HTTPResponse res = new HTTPResponse();
        PageReference ref = new PageReference(req.getEndpoint());
        req.setMethod('GET');
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('User-Agent', 'salesforce-desk-client/0.1.0');
        res.setHeader('Accept', 'text/JSON;charset=UTF-8');
        if (req.getEndpoint().toLowerCase().contains('heldbooth')) {
            res.setBody('{"ExhibitorId":"0012C000004oaCvQAI","BoothNumber":"KG7","Dimensions":"10","XSize":"10","YSize":"10","Area":"100 SqFt","Status":"Unknown","BoothClass":"Test","BoothClasses": ["Pavilion Booth"],"Pavilion":"","ShowInShow":"Indoor","BoothType":"Peninsula","UnitType":"ftin","HoldExhibitorId":"","HoldExhibitorName":"","OpenCorners":2,"IsDeleted":false,"IsOnHold":true,"IsRented":false}');
            res.setStatusCode(200);
            res.setStatus('OK');
        }
        else if (req.getEndpoint().toLowerCase().contains('rentbooth')) {
            res.setBody('{"ExhibitorId":"0012C000004oaCvQAI","BoothNumber":"KG7","Dimensions":"10","XSize":"10","YSize":"10","Area":"100 SqFt","Status":"Unknown","BoothClass":"Test","BoothClasses": ["Pavilion Booth"],"Pavilion":"","ShowInShow":"Indoor","BoothType":"Peninsula","UnitType":"ftin","HoldExhibitorId":"","HoldExhibitorName":"","OpenCorners":2,"IsDeleted":false,"IsOnHold":false,"IsRented":true}');
            res.setStatusCode(200);
            res.setStatus('OK');
        }
        else if (req.getEndpoint().toLowerCase().contains('/booths?boothnumber')) {
            res.setBody('{"ExhibitorId":"0012C000004oaCvQAI","BoothNumber":"KG7","Dimensions":"10","XSize":"10","YSize":"10","Area":"100 SqFt","Status":"Unknown","BoothClass":"Test","BoothClasses": ["Pavilion Booth"],"Pavilion":"sPavilion","ShowInShow":"Indoor","BoothType":"Peninsula","UnitType":"ftin","HoldExhibitorId":"","HoldExhibitorName":"","OpenCorners":2,"IsDeleted":false,"IsOnHold":false,"IsRented":false}');
            res.setStatusCode(200);
            res.setStatus('OK');
        } else if (req.getEndpoint().toLowerCase().contains('/booths/all')) {
            res.setBody('[{"ExhibitorId":"0012C000004oaCvQAI","BoothNumber":"KG7","Dimensions":"10","XSize":"10","YSize":"10","Area":"100 SqFt","Status":"Unknown","BoothClass":"Indoor","Pavilion":"pav1","ShowInShow":"Indoor","BoothType":"Peninsula","UnitType":"ftin","HoldExhibitorId":"","HoldExhibitorName":"","OpenCorners":2,"IsDeleted":false,"IsOnHold":false,"IsRented":false},{"ExhibitorId":"0012C000004oaCvQAI","BoothNumber":"KG7","Dimensions":"10","XSize":"10","YSize":"10","Area":"10.5 SqFt","Status":"Unknown","BoothClass":"Indoor","Pavilion":"Pav2","ShowInShow":"Indoor2","BoothType":"Peninsula","UnitType":"ftin","HoldExhibitorId":"","HoldExhibitorName":"","OpenCorners":0,"IsDeleted":false,"IsOnHold":false,"IsRented":false}]');
            res.setStatusCode(200);
            res.setStatus('OK');
        }
        else if (req.getEndpoint().toLowerCase().contains('/events/stats')) {
            res.setBody('{"TotalBooths":"2426","RentedBooths":"519","AvailableBooths":"1907","NonInventoryBooths":"0","TotalExhibitors":"103","TotalBoothArea":"781473.00","RentedBoothArea":"142761.00","AvailableBoothArea":"781473.00","NonInventoryBoothArea":"0.00","RentedBoothPercentage":"18.27","AvailableBoothPercentage":"81.73","NetValueSold":"$26,775.00"}');
            res.setStatusCode(200);
            res.setStatus('OK');
            
        } else if (req.getEndpoint().toLowerCase().contains('/exhibitors?id')) {
            res.setBody('');
            res.setStatusCode(404);
            res.setStatus('OK');
        } else if (req.getEndpoint().toLowerCase().contains('exhibitors/add')) {
            res.setBody('response');
            res.setStatusCode(201);
            res.setStatus('OK');
        } else if (req.getEndpoint().toLowerCase().contains('/booths/hold?')) {
            res.setBody('response');
            res.setStatusCode(200);
            res.setStatus('OK');
        } else if (req.getEndpoint().toLowerCase().contains('rateplans')) {
            res.setBody('{"Name": "OD EB 5-16 <1000","ShortCode": "OEB1","GrossRate": 29.75,"FixedDiscountRate": 0,"PercentDiscountRate": 0,"IsFixed": false}');
            res.setStatusCode(200);
            res.setStatus('OK');
        }else if ((req.getEndpoint().toLowerCase().contains('unhold') || req.getEndpoint().toLowerCase().contains('unrent') )&& req.getEndpoint().toLowerCase().contains('400')) {
            res.setBody('{"Name": "OD EB 5-16 <1000","ShortCode": "OEB1","GrossRate": 29.75,"FixedDiscountRate": 0,"PercentDiscountRate": 0,"IsFixed": false}');
            res.setStatusCode(400);
            res.setStatus('OK');
        }
        else if (req.getEndpoint().toLowerCase().contains('unhold') || req.getEndpoint().toLowerCase().contains('booths/rent?')) {
            res.setBody('response');
            res.setStatusCode(400);
            res.setStatus('OK');
        }
        else if (req.getEndpoint().toLowerCase().contains('childexhibitorid')) {
            res.setBody('response');
            res.setStatusCode(200);
            res.setStatus('OK');
        }else if ((res.getBody() == null || res.getBody() == '') && res.getStatusCode() > 299) {
            res.setBody('{"message":"Resource Not Found"}');
            res.setStatusCode(404);
        }else if (req.getEndpoint().toLowerCase().contains('callout:expocad_credential/')){
            res.setBody('{"ExhibitorId":"0012C000004oaCvQAI","BoothNumber":"KG7","Dimensions":"10","XSize":"10","YSize":"10","Area":"100 SqFt","Status":"Unknown","BoothClass":"Test","BoothClasses": ["Pavilion Booth"],"Pavilion":"","ShowInShow":"Indoor","BoothType":"Peninsula","UnitType":"ftin","HoldExhibitorId":"","HoldExhibitorName":"","OpenCorners":2,"IsDeleted":false,"IsOnHold":true,"IsRented":false}');
            res.setStatusCode(200);
            res.setStatus('OK');
        } else {
             res.setBody('{"ExhibitorId":"0012C000004oaCvQAI","BoothNumber":"KG7","Dimensions":"10","XSize":"10","YSize":"10","Area":"100 SqFt","Status":"Unknown","BoothClass":"Test","BoothClasses": ["Pavilion Booth"],"Pavilion":"","ShowInShow":"Indoor","BoothType":"Peninsula","UnitType":"ftin","HoldExhibitorId":"","HoldExhibitorName":"","OpenCorners":2,"IsDeleted":false,"IsOnHold":true,"IsRented":false}');
            res.setStatusCode(200);
            res.setStatus('OK');
        }
       System.debug(res);
        return res;
    }
}