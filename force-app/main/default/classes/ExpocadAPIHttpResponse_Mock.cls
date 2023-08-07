public class ExpocadAPIHttpResponse_Mock implements HttpCalloutMock{

    public Integer responseCode;
    public String responseBody;
    
    public Boolean isResOverRide;
    public Map<String,String> mapURIBody;
    
    
    /**
* @description  This Constructor  generate Dynamic Response
* @param  code

* @param  body

*/
    Public ExpocadAPIHttpResponse_Mock(Integer code, String body)
    {
        this.responseCode = code;
        this.responseBody = body;
        this.isResOverRide = true;
    }
    /**

* @description  This Constructor Default

*/
    Public ExpocadAPIHttpResponse_Mock()
    {
        this.responseCode = 200;
        this.isResOverRide = false;
    }
    
    /**

* @description  This Constructor Default
* @param  mapstr
*/
    Public ExpocadAPIHttpResponse_Mock(Map<String,String> mapstr)
    {
        this.mapURIBody = mapstr;
    }
    
    /**

* @description  This method is used to genrate fake response for ExpoCAD
* @param  req     
* @return  HTTPResponse
*/
    public HTTPResponse respond(HTTPRequest req) 
    {
        
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');     
        if(mapURIBody != null){
            for(String key : mapURIBody.keySet()){
                if(req.getEndpoint().contains(key)){
                    String str = mapURIBody.get(key);
                    System.debug(LoggingLevel.DEBUG, 'str==='+str);
                    res.setStatusCode(Integer.valueOf(str.split('###')[0]));
                    res.setBody(str.split('###')[1]);
                    res.setStatus('OK');
                }
            }
        }
        else{   
            
            res.setStatusCode(responseCode);
            res.setStatus(responseCode==200?'Success':'Error'); 
            if(req.getEndpoint().contains('/exhibitors?'))
            {                    	
                
                res.setBody('[{"password":"","email":"test@gmail.com","customerId":"0012200000c52N1AAI"}]');
                System.debug('Exhibitor  --- ');
            }/*
            if(req.getEndpoint().contains('/exhibitors?'))
            {                    	
                String body = '{"Address1":"Indian Grass Lane","Address2":"","City":"Northlake","Comments":"","Comments2":"","Contact":"","Country":"United States","CellPhone":"","DisplayOnDrawing":"","DoingBusinessAs":"","DoingBusinessAsDisplayOnDrawing":"","Email":"","ExhibitorId":"IM-21946","ExhibitorName":"Impossible Mission Force Ltd.","ExhibitorNameLine2":"","Fax":null,"Field1":"","Field2":"","Field3":"","Field4":"","Field5":"","Field6":"","Field7":"","Field8":"","Field9":"","NickName":"","Salutation":"","Title":"","Phone":"09971714853","PostalCode":"76226","PrimaryGroup":"","PriorityPoints":"","ProductDescription":"","State":"Texas","WebSite":null}';
                res.setBody(body);
            }
            if(req.getEndpoint().contains('/exhibitors/add?')&& !this.isResOverRide)
            { 
                res.setBody('{"Address1":"Indian Grass Lane","Address2":"","City":"Northlake","Comments":"","Comments2":"","Contact":"","Country":"United States","CellPhone":"","DisplayOnDrawing":"","DoingBusinessAs":"","DoingBusinessAsDisplayOnDrawing":"","Email":"","ExhibitorId":"IM-21946","ExhibitorName":"Impossible Mission Force Ltd.","ExhibitorNameLine2":"","Fax":null,"Field1":"","Field2":"","Field3":"","Field4":"","Field5":"","Field6":"","Field7":"","Field8":"","Field9":"","NickName":"","Salutation":"","Title":"","Phone":"09971714853","PostalCode":"76226","PrimaryGroup":"","PriorityPoints":"","ProductDescription":"","State":"Texas","WebSite":null}');
                res.setStatusCode(201);
                res.setStatus('Success'); 
            }
            */
            if(this.isResOverRide)
            {
                res.setBody(responseBody);
            }
            
        }
        
        return res;
    }
    
}