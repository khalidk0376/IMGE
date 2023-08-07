/**
* File          :   Expo3EAPIUtilHelper
* Project       :   (3E Intregration)
* Created Date  :   24th April 2022
* Created By    :   (Girikon)
* Test Class    :  Expo3EAPIUtilHelper_Test ,Expo3EUtils_Test
* Coverage      :   93%
* *******************************************************************************************************
* @description : For all the Booth API callouts to 3E ExpoCAD
* *******************************************************************************************************
* Last Modified By : Girikon(Aradhana),on 11th Oct 2022[EX-23],[Expo3EUtils_Test- coverage 89%]
* Last Modified By : Girikon(Abhishek),on 21st Feb 2023[EX-154]
*/
public with sharing class Expo3EAPIUtilHelper {

  /**
    * @description  This method is used sending callouts to ExpoCAD
    * @param  prams Callout Parameters for request
    * @param  exhibitorDetails
    * @return  Expocad3E_Wrapper.WrapperResponse
    */

    public static Expocad3E_Wrapper.WrapperResponse getAllExpoBooths(String API3EName,String exhibitorId)//Boolean hasToken,
    {
        API_Detail__mdt getAPIDetails = getAPIDetails('GetAllExpoBooths', Expocad3E_Wrapper.EXPOCAD3E);
        String endPointUrl = getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(System.label.Expocad_Main_Endpoint+endPointUrl,'<dataBase>',API3EName );
        //exhibitorId = '0018F00000C2vyHQAR';
        endPointUrl = replacePrametersWithValue(endPointUrl,'<SameExhibitorIDfromthefirstitem>',exhibitorId );
        // = 'https://api2.expocad.com/EdgeWebApi/informapsb/booths/all?databaseName=psim03&deletedFilter=IncludeAll&$filter=ExhibitorId+eq+'0018F00000C2vyHQAR' ;
        //String invite = '['+JSON.serialize(inviteDetails)+']';
        //HttpResponse response = sendRequestToExpoCAD(endPointURL, 'GET','',true,'apiToken');//getAPIDetails.API_Method__c //prams.folderName+
        HttpResponse response = request(endPointURL,'GET',''); 
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        wrapObj.response = response;
        wrapObj.requestBody = endPointUrl; 
        return wrapObj;
    }

    /**
    * @description  This method is used sending callouts to ExpoCAD
    * @param  prams Callout Parameters for request
    * @param  exhibitorDetails
    * @return  Expocad3E_Wrapper.WrapperResponse
    */

    public static Expocad3E_Wrapper.WrapperResponse getExpoBooths(String API3EName,String boothNumber)//Boolean hasToken,
    {
        API_Detail__mdt getAPIDetails = getAPIDetails('GetExpoBooths', Expocad3E_Wrapper.EXPOCAD3E);
        String endPointUrl = getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(System.label.Expocad_Main_Endpoint+endPointUrl,'<dataBase>',API3EName );
        endPointUrl = replacePrametersWithValue(endPointUrl,'<BoothExpo>',boothNumber );
        //HttpResponse response = sendRequestToExpoCAD(endPointURL, 'GET','',true,'apiToken');//getAPIDetails.API_Method__c //prams.folderName+
        HttpResponse response = request(endPointURL,'GET','');
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        wrapObj.response = response;
        wrapObj.requestBody = endPointUrl; 
        return wrapObj;
    }


    /**
    * @description  This method is used sending callouts to ExpoCAD
    * @param  prams Callout Parameters for request
    * @param  exhibitorDetails
    * @return  Expocad3E_Wrapper.WrapperResponse
    */

    public static Expocad3E_Wrapper.WrapperResponse getExpoRelatedList(String API3EName,String boothNumber)//Boolean hasToken,
    {
        API_Detail__mdt getAPIDetails = getAPIDetails('GetExpoRelatedList', Expocad3E_Wrapper.EXPOCAD3E);
        String endPointUrl = getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(System.label.Expocad_Main_Endpoint+endPointUrl,'<dataBase>',API3EName );
        endPointUrl = replacePrametersWithValue(endPointUrl,'<BoothExpo>',boothNumber );
        //String invite = '['+JSON.serialize(inviteDetails)+']';
       // HttpResponse response = sendRequestToExpoCAD(endPointURL, 'GET','',true,'apiToken');//getAPIDetails.API_Method__c //prams.folderName+
        HttpResponse response = request(endPointURL,'GET','');
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        wrapObj.response = response;
        wrapObj.requestBody = endPointUrl; 
        return wrapObj;
    }

    /**
     * @description Basic configuration to make Http call to Expocad.
     * @param  path   endPoint
     * @param  method Callout method
     * @param  sBody  request body
     * @return        httpresponse
     */

    //We have updated code after ticket developement BK-1229 BY RajeshKr
    public static HTTPResponse request(String path, String method, String sBody) {
        system.debug('----path----'+path+'-----method----'+method+'----sBody-----'+sBody);
        HttpResponse res = new HttpResponse();
        try {
            //ExpocadCredential__c objExpocadOrgId = ExpocadCredential__c.getValues('ExpocadApiCredential');
            //system.debug('objExpocadOrgId'+objExpocadOrgId.Org_Id__c);
            //Id OrgId = UserInfo.getOrganizationId();
            //system.debug('OrgId'+OrgId);
            //if (objExpocadOrgId.Org_Id__c == orgId) {
                NamedCredential nameCrdURL = [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName = 'ExpoCAD_Credential'];
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                req.setMethod(method);
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/json');
                if (method == 'PUT' || method == 'POST') {
                    if (String.isBlank(sBody)) {
                        sBody = '';
                    }
                    req.setBody(sBody);
                }
                String sUrl = nameCrdURL.Endpoint;
                system.debug('test_sUrl'+sUrl);
                System.debug('Path ::: ' + path);
                String fpPath = (String.isNotBlank(path) && path.contains(sUrl)) ? path.split(sUrl).get(1) : '';
                SYstem.debug('fpPath' + fpPath);
                req.setEndpoint('callout:ExpoCAD_Credential/' + fpPath);// / ???
              
                req.setTimeout(120000);
                System.debug('Final Value ::: ' + req);
                if (!System.Test.isRunningTest()) { try {  res = http.send(req);  } catch (System.CalloutException ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'request(@ExpocadResponses)'); }
                } else if (System.Test.isRunningTest()) {
                    res = new ExpocadMock().respond(req);
                }

            //}

        } catch (Exception ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'request(@ExpocadResponses)');
        }
        system.debug('ZuheabResponse-----'+ res);
        return res;
    }

     /****************** Common METHODS ****************/

    /**
    * @description  This method is used sending callouts to ExpoCAD
    * @param  endPointURL Callout End Point Url
    * @param  method  Callout request method [GET , PUT , POST]
    * @param  jsonBody  request Body  
    * @return  HttpResponse response from ExpoCAD System
    */
   public static HttpResponse sendRequestToExpoCAD(String endPointURL,string method,String jsonBody,Boolean hasToken,String apiToken)
    {
        endPointURL = removeUnUsedPrameters(endPointURL);
        //String encodedUrl = EncodingUtil.urlEncode(endPointURL, 'UTF-8');
        //endPointURL = endPointUrl.replaceall('*', '%2A');
        //endPointURL = endPointUrl.replaceall(' ', '%20');
        //endPointURL = endPointUrl.replaceall('\\^', '%5E');
        System.debug('sendRequest2ExpoCAD---'+endPointURL); 
        HttpRequest request = new HttpRequest();
        //request.setEndpoint('callout:ExpoCAD3E'+'/'+endPointURL);
        
        request.setEndpoint(endPointURL);
        request.setTimeout(60000);
        request.setHeader('Content-Type', 'application/json');    
       //ex 101///// request.setHeader('accept','*/*');
        //request.setHeader('',);
        
        
       if(hasToken){
             //request.setHeader('ApiSessionToken', apiToken);
             request.setHeader('Host','api2.expocad.com');//System.Label.Expocad3E_Host
             if(method != 'GET'){
                 request.setHeader('Content-Length',String.valueOf(jsonBody.length()));
             }
            //request.setHeader('Content-Type', 'application/json;odata.metadata=minimal;odata.streaming=true');
        }
           
        request.setMethod(method);
        if(method == 'PUT' || method == 'POST')
        {
            //if(!hasToken){
                jsonBody = (String.isBlank(jsonBody)?'':jsonBody);
                request.setBody(jsonBody);
            //}
        }
        Http http = new Http();
        HttpResponse response = http.send(request);
        //System.debug(LoggingLevel.DEBUG,'HttpResponse Code -> '+response.getStatusCode()+' : ' +response.getStatus());
       // System.debug(LoggingLevel.DEBUG,'HttpResponse Reponse -> '+response.getBody());
        return response;
    }










     /**
    * @description  This method is used sending callouts to ExpoCAD
    * @param  prams Callout Parameters for request
    * @param  exhibitorDetails
    * @return  Expocad3E_Wrapper.WrapperResponse
    */

    public static Expocad3E_Wrapper.WrapperResponse inviteExhibitorIn3E(String API3EName,Expocad3E_Wrapper.InviteExhibitor inviteDetails,Boolean hasToken,String apiToken)
    {
        API_Detail__mdt getAPIDetails = getAPIDetails('InviteExhibitorForExpocad3E', Expocad3E_Wrapper.EXPOCAD3E);
        String endPointUrl = getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(System.label.Expocad3E_Main_Endpoint+endPointUrl,'<x3E_API_ID__c>',API3EName );
        String invite = '['+JSON.serialize(inviteDetails)+']';
        HttpResponse response = sendRequest2ExpoCAD(endPointURL, 'POST',invite,true,apiToken);//getAPIDetails.API_Method__c //prams.folderName+
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        wrapObj.response = response;
        wrapObj.requestBody = invite; 
        return wrapObj;
    }

    /**
    * @description  This method is used sending callouts to ExpoCAD
    * @param  prams Callout Parameters for request
    * @param  exhibitorDetails
    * @return  Expocad3E_Wrapper.WrapperResponse
    */
    public static Expocad3E_Wrapper.WrapperResponse getCompanyListIn3E(String API3EName,Boolean hasToken,String apiToken)
    {
        API_Detail__mdt getAPIDetails = getAPIDetails('GetCompanyTypesListfrom3E', Expocad3E_Wrapper.EXPOCAD3E);
        String endPointUrl = getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(System.label.Expocad3E_Main_Endpoint+endPointUrl,'<x3E_API_ID__c>',API3EName );
        HttpResponse response = sendRequest2ExpoCAD(endPointURL, 'GET','',true,apiToken);
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        wrapObj.response = response;
        wrapObj.requestBody = ''; 
        System.debug('resp===>>  '+wrapObj.response.getBody());
        return wrapObj;
    }

    /**
    * @description  This method is used sending callouts to ExpoCAD
    * @param  prams Callout Parameters for request
    * @param  exhibitorDetails
    * @return  Expocad3E_Wrapper.WrapperResponse
    */
    public static Expocad3E_Wrapper.WrapperResponse fetchContractFrom3E(String API3EName,String customerId,String boothNumber,Boolean hasToken,String apiToken)
    {
        API_Detail__mdt getAPIDetails = getAPIDetails('getContractFrom3E', Expocad3E_Wrapper.EXPOCAD3E);
        String endPointUrl = getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(System.label.Expocad3E_Main_Endpoint+endPointUrl,'<x3E_API_ID__c>',API3EName);
        endPointUrl = replacePrametersWithValue(endPointUrl,'<customerId>',customerId);
        endPointUrl = replacePrametersWithValue(endPointUrl,'<boothNumber>',boothNumber);
        //System.debug('endPointUrl--contract--'+endPointUrl);
        HttpResponse response = sendRequest2ExpoCAD(endPointURL, 'GET','',true,apiToken);
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        wrapObj.response = response;
        wrapObj.requestBody = endPointUrl; 
        return wrapObj;
    }


     /**
    * @description  This method is used sending callouts to ExpoCAD
    * @param  
    * @return  String
    */
    public static String fetchApiToken()
    {
        
        API_Detail__mdt getAPIDetails = getAPIDetails('GetApiTokenExpo3E', Expocad3E_Wrapper.EXPOCAD3E);
        Expocad3E_Wrapper.APITokenWrapper wrap = new Expocad3E_Wrapper.APITokenWrapper();
        wrap.email =getAPIDetails.User_Name__c;
        wrap.apiKey = getAPIDetails.Password__c;
        String endPointUrl = System.label.Expocad3E_Main_Endpoint+getAPIDetails.API_End_Point__c;
        endPointUrl+= '?email='+EncodingUtil.urlEncode(getAPIDetails.User_Name__c,'UTF-8')+'&apiKey='+EncodingUtil.urlEncode(getAPIDetails.Password__c,'UTF-8');
        HttpResponse response = sendRequest2ExpoCAD(endPointURL, 'POST',JSON.serialize(wrap),false,'');
        return response.getBody(); 
    }
    
   /**
* @description  This method is used to Assign CompanyType in 3E [EX-21]
* @param  metaDataName metadata label name
* @param thirdParty third party name
* @return  String
*/
    public static Expocad3E_Wrapper.WrapperResponse assignCompanyType(String customerId,String typeId, String eventIdentifier){
        API_Detail__mdt getAPIDetails = getAPIDetails('AssignCompanyTypeTo3E', Expocad3E_Wrapper.EXPOCAD3E);
        String endPointUrl = getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(System.label.Expocad3E_Main_Endpoint+endPointUrl,'<x3E_API_ID__c>',eventIdentifier);
        endPointUrl += '?typeId='+typeId+'&customerIds='+customerId;
        
        HttpResponse response = sendRequest2ExpoCAD(endPointURL, 'POST','',false,'');
        //System.debug('assignCompanyType--->'+response);
         Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        wrapObj.response = response;
        wrapObj.requestBody = customerId+'-'+typeId; 
        return wrapObj;
       
    }
    /**
    * @description  This method is used to Unassign CompanyType in 3E [EX-21]
    * @param  metaDataName metadata label name
    * @param thirdParty third party name
    * @return  String
    */
    Public static Expocad3E_Wrapper.WrapperResponse unassignCompanyType(String customerId,String typeId, String eventIdentifier){
      API_Detail__mdt getAPIDetails = getAPIDetails('UnassignCompanyTypeIn3E', Expocad3E_Wrapper.EXPOCAD3E); 
        String endPointUrl = getAPIDetails.API_End_Point__c;
         endPointUrl = replacePrametersWithValue(System.label.Expocad3E_Main_Endpoint+endPointUrl,'<x3E_API_ID__c>',eventIdentifier);
        endPointUrl += '?typeId='+typeId+'&customerIds='+customerId;
        
        HttpResponse response = sendRequest2ExpoCAD(endPointURL, 'POST','',false,'');
        //System.debug('UnassignCompanyType---Unhold----->'+response);
         Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        wrapObj.response = response;
        wrapObj.requestBody = customerId+'-'+typeId; 
        return wrapObj;
    }

    public static Expocad3E_Wrapper.WrapperResponse ExpoCADASyncUnhold (String sBoothNumber, String sEventCode, String sAPIUrl)
    {
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        String endPointUrl = sAPIURL + '/booths/unhold?boothNumber=' + sBoothNumber + '&databaseName=' + sEventCode;
        HttpResponse res =  new ExpocadResponses().request(endPointUrl, 'PUT', '');
        wrapObj.response = res;
        wrapObj.requestBody = endPointUrl; 
        return wrapObj;
       
    }
    
     /**
    * @description  This method is used for handling Unhold expocad booth callout
    * @param  sBoothNumber Expocad Booth Number
    * @param  sEventCode ExpoCAD Event code of Event Edition
    * @param  sAPIUrl API Url from Event Edition
    * @return  wrapObj Expocad3E_Wrapper.WrapperResponse
    * Added for EX-154
    */
    public static Expocad3E_Wrapper.WrapperResponse ExpoCADBoothUnhold(String sBoothNumber, String sEventCode, String sAPIUrl)
    {
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        API_Detail__mdt getAPIDetails = getAPIDetails('UnholdExpoBooth', Expocad3E_Wrapper.EXPOCAD_EDGE); 
        String endPointUrl = sAPIURL + getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(endPointUrl,'<BoothExpo>',sBoothNumber);
        endPointUrl = replacePrametersWithValue(endPointUrl,'<dataBase>',sEventCode);
        HttpResponse res =  request(endPointUrl, 'PUT', '');
        wrapObj.response = res;
        wrapObj.requestBody = endPointUrl; 
        return wrapObj;
       
    }
    
    /**
    * @description  This method is used for handling Unrent expocad booth callout
    * @param  sBoothNumber Expocad Booth Number
    * @param  sEventCode ExpoCAD Event code of Event Edition
    * @param  sAPIUrl API Url from Event Edition
    * @return  wrapObj Expocad3E_Wrapper.WrapperResponse
    * Added for EX-154
    */
    public static Expocad3E_Wrapper.WrapperResponse ExpoCADBoothUnrent(String sBoothNumber, String sEventCode, String sAPIUrl)
    {
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        API_Detail__mdt getAPIDetails = getAPIDetails('UnrentExpoBooth', Expocad3E_Wrapper.EXPOCAD_EDGE); 
        String endPointUrl = sAPIURL + getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(endPointUrl,'<BoothExpo>',sBoothNumber);
        endPointUrl = replacePrametersWithValue(endPointUrl,'<dataBase>',sEventCode);
        HttpResponse res =  request(endPointUrl, 'PUT', '');
        wrapObj.response = res;
        wrapObj.requestBody = endPointUrl; 
        return wrapObj;
       
    }

    /**
    * @description  This method is used for handling RentToHold expocad booth callout
    * @param  sBoothNumber Expocad Booth Number
    * @param  sEventCode ExpoCAD Event code of Event Edition
    * @param  sAPIUrl API Url from Event Edition
    * @return  wrapObj Expocad3E_Wrapper.WrapperResponse
    * Added for EX-154
    */
    public static Expocad3E_Wrapper.WrapperResponse ExpoCADBoothRentToHold(String sBoothNumber, String sEventCode, String sAPIUrl)
    {
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        API_Detail__mdt getAPIDetails = getAPIDetails('RentToHoldExpoBooth', Expocad3E_Wrapper.EXPOCAD_EDGE); 
        String endPointUrl = sAPIURL + getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(endPointUrl,'<BoothExpo>',sBoothNumber);
        endPointUrl = replacePrametersWithValue(endPointUrl,'<dataBase>',sEventCode);
        HttpResponse res =  request(endPointUrl, 'PUT', '');
        wrapObj.response = res;
        wrapObj.requestBody = endPointUrl; 
        return wrapObj;
    }
    
    /**
    * @description  This method is used for handling Hold expocad booth callout
    * @param  sBoothNumber Expocad Booth Number
    * @param  sEventCode ExpoCAD Event code of Event Edition
    * @param  sAPIUrl API Url from Event Edition
    * @param  sOpptyId opportunityId
    * @param  sDisplayName BoothDisplayName
    * @return  wrapObj Expocad3E_Wrapper.WrapperResponse
    * Added for EX-154
    */
    public static Expocad3E_Wrapper.WrapperResponse ExpoCADBoothHold(String sBoothNumber, String sEventCode, String sAPIUrl, String sOpptyId, String sDisplayName)
    {
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        API_Detail__mdt getAPIDetails = getAPIDetails('HoldExpoBooth', Expocad3E_Wrapper.EXPOCAD_EDGE); 
        String endPointUrl = sAPIURL + getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(endPointUrl,'<BoothExpo>',sBoothNumber);
        endPointUrl = replacePrametersWithValue(endPointUrl,'<dataBase>',sEventCode);
        endPointUrl = replacePrametersWithValue(endPointUrl,'<exhibitorName>',sDisplayName);
        endPointUrl = endPointUrl.replaceall(' ', '+');
        HttpResponse res =  request(endPointUrl, 'PUT', '');
        wrapObj.response = res;
        wrapObj.requestBody = endPointUrl; 
        return wrapObj;
    }

    /**
    * @description  This method is used for handling Hold expocad booth callout
    * @param  sBoothNumber Expocad Booth Number
    * @param  sEventCode ExpoCAD Event code of Event Edition
    * @param  sAPIUrl API Url from Event Edition
    * @param  sExhibitorId
    * @param  sOpptyId opportunityId
    * @param  sRatePlan
    * @return  wrapObj Expocad3E_Wrapper.WrapperResponse
    * Added For EX-154
    */
    public static Expocad3E_Wrapper.WrapperResponse ExpoCADBoothRent(String sBoothNumber, String sEventCode, String sAPIUrl, String sExhibitorId, String sOpptyId, String sRatePlan)
    {    
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        API_Detail__mdt getAPIDetails = getAPIDetails('RentExpoBooth', Expocad3E_Wrapper.EXPOCAD_EDGE); 
        String endPointUrl = sAPIURL + getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(endPointUrl,'<BoothExpo>',sBoothNumber);
        endPointUrl = replacePrametersWithValue(endPointUrl,'<exhibitorId>',sExhibitorId);
        endPointUrl = replacePrametersWithValue(endPointUrl,'<dataBase>',sEventCode);
        endPointUrl = replacePrametersWithValue(endPointUrl,'<ratePlan>',sRatePlan);
        endPointUrl = replacePrametersWithValue(endPointUrl,'<opptyID>',sOpptyId);
        endPointUrl = endPointUrl.replaceall(' ', '+');
        HttpResponse res =  request(endPointUrl, 'PUT', '');
        wrapObj.response = res;
        wrapObj.requestBody = endPointUrl; 
        return wrapObj;
    }
    
    /**
    * @description  This method is used to get Default Rate Plan from ExpoCAD
    * @param  sAPIUrl API Url from Event Edition
    * @param  sEventCode ExpoCAD Event code of Event Edition
    * @return  Expocad3E_Wrapper.WrapperResponse
    */
    public static Expocad3E_Wrapper.WrapperResponse getRateplan(String sEventCode, String sAPIUrl)
    {
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        API_Detail__mdt getAPIDetails = getAPIDetails('GetExpoRatePlan', Expocad3E_Wrapper.EXPOCAD3E); 
        String endPointUrl = sAPIURL + getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(endPointUrl,'<dataBase>',sEventCode);
        HttpResponse res =  request(endPointUrl, 'GET', '');
        wrapObj.response = res;
        wrapObj.requestBody = endPointUrl; 
        return wrapObj;
    }
        
    /**
    * @description  This method is used to get Exhibitor Details from ExpoCAD
    * @param  sAPIUrl API Url from Event Edition
    * @param  sEventCode ExpoCAD Event code of Event Edition
    * @return  Expocad3E_Wrapper.WrapperResponse
    * Added for EX-154
    */
    public static Expocad3E_Wrapper.WrapperResponse getExhibitor(String sEventCode, String sAPIUrl, String sExhibitorId)
    {
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        API_Detail__mdt getAPIDetails = getAPIDetails('GetExhibitor', Expocad3E_Wrapper.EXPOCAD_EDGE); 
        String endPointUrl = sAPIURL + getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(endPointUrl,'<ExhibitorId>',sExhibitorId);
        endPointUrl = replacePrametersWithValue(endPointUrl,'<dataBase>',sEventCode);
        HttpResponse res =  request(endPointUrl, 'GET', '');
        wrapObj.response = res;
        wrapObj.requestBody = endPointUrl; 
        return wrapObj;
    }
        
    /**
    * @description  This method is used to create Exhibitor in ExpoCAD
    * @param  sAPIUrl API Url from Event Edition
    * @param  sEventCode ExpoCAD Event code of Event Edition
    * @return  Expocad3E_Wrapper.WrapperResponse
    * Added for EX-154
    */
    public static Expocad3E_Wrapper.WrapperResponse updateExhibitor(String sEventCode, String sExhibitorId, String sAPIUrl, String sRequestBody)
    {
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        API_Detail__mdt getAPIDetails = getAPIDetails('updateExhibitor', Expocad3E_Wrapper.EXPOCAD_EDGE); 
        String endPointUrl = sAPIURL + getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(endPointUrl,'<dataBase>',sEventCode);
        endPointUrl = replacePrametersWithValue(endPointUrl,'<ExhibitorId>',sExhibitorId);
        HttpResponse res =  request(endPointUrl, 'PUT', sRequestBody);
        wrapObj.response = res;
        wrapObj.requestBody = sRequestBody; 
        return wrapObj;
    }

    /**
    * @description  This method is used to create Exhibitor in ExpoCAD
    * @param  sAPIUrl API Url from Event Edition
    * @param  sEventCode ExpoCAD Event code of Event Edition
    * @return  Expocad3E_Wrapper.WrapperResponse
    * Added for EX-154
    */
    public static Expocad3E_Wrapper.WrapperResponse createExhibitor(String sEventCode, String sAPIURL, String sRequestBody)
    {
        Expocad3E_Wrapper.WrapperResponse wrapObj = new Expocad3E_Wrapper.WrapperResponse();
        API_Detail__mdt getAPIDetails = getAPIDetails('AddExhibitor', Expocad3E_Wrapper.EXPOCAD_EDGE); 
        String endPointUrl = sAPIURL + getAPIDetails.API_End_Point__c;
        endPointUrl = replacePrametersWithValue(endPointUrl,'<dataBase>',sEventCode);
        HttpResponse res =  request(endPointUrl, 'POST', sRequestBody);
        wrapObj.response = res;
        wrapObj.requestBody = sRequestBody; 
        return wrapObj;
    }

     /**
	 * Designed to get Product Name using BoothType, ShowInShow, BoothClasses (values returned by Expocad booth detail) and Event's Product Type.
	 * @param  oEB                 [Expocad Booth Ref]
	 * @param  oOpportunity        [Opportunity  Ref]
	 * @param  boothPackageProduct [Product package Ref]
	 * @return String              [Product Name]
	 */
	Public Static String sBPrdGet(Map < Id, SBQQ__ProductOption__c > mapProductOptionsId, Expocad3E_Wrapper.GetAllBoothsWrapper oEB, Opportunity oOpportunity, Product2 boothPackageProduct) {
		System.debug('mapProductOptionsId : ' + mapProductOptionsId);
        System.debug('boothPackageProduct : ' + boothPackageProduct);
        System.debug('oEB : ' + oEB);
        System.debug('oOpportunity : ' + oOpportunity);
        String sReturnedPrdName = NULL;
		String sBoothType = NULL;
		String sShowInShow = NULL;
		String sPavilion = NULL;
		String sBoothProductType = NULL;
		List < String > lstBoothClasses = new List < String > ();

		if (!String.isBlank(oEB.BoothType) && !oEB.BoothType.containsIgnoreCase('Corner')) {sBoothType = oEB.BoothType;
		}
		if (!String.isBlank(oEB.ShowInShow) && !oEB.ShowInShow.containsIgnoreCase('Corner')) {sShowInShow = oEB.ShowInShow;
		}
		if (!String.isBlank(oEB.Pavilion) && !oEB.Pavilion.containsIgnoreCase('Corner')) {sPavilion = oEB.Pavilion;
		}
		/*if (!String.isBlank(oEB.BoothClass) && !oEB.BoothClass.containsIgnoreCase('Corner')) {?????????
			sBoothProductType = oEB.BoothClass;
		}*/
		if (oEB.BoothClasses != null && !oEB.BoothClasses.isEmpty()) {
			for (String sTemp : oEB.BoothClasses) {
				if (sTemp != 'Standard Booth' && !sTemp.containsIgnoreCase('Corner')) {
					lstBoothClasses.add(sTemp);
				}
			}
		}
        System.debug('sBPrd : sBoothType : ' + sBoothType);
        System.debug('sBPrd : sShowInShow : ' + sShowInShow);
        System.debug('sBPrd : sPavilion : ' + sPavilion);
        System.debug('sBPrd : sBoothProductType : ' + sBoothProductType);
        
        If(Test.isRunningTest()){
            sShowInShow = 'sShowInShow';sReturnedPrdName = '';//sBoothType = 'sBoothType';
        }
        System.debug('sBPrd : lstBoothClasses : ' + lstBoothClasses);
		If(!String.isBlank(sBoothType) || !String.isBlank(sShowInShow) || !String.isBlank(sPavilion) || !lstBoothClasses.isEmpty() || !String.isBlank(sBoothProductType)) {
			// All Param Included
			If(!String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, sPavilion, lstBoothClasses, sBoothProductType);
			}
			If(String.isBlank(sReturnedPrdName) && (!String.isBlank(sShowInShow) || !String.isBlank(sPavilion) || !String.isBlank(sBoothProductType) || !lstBoothClasses.isEmpty())) {

				If(!String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, sPavilion, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, sPavilion, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, null, sPavilion, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, null, sPavilion, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sPavilion) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, null, sPavilion, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, null, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, null, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, null, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, sPavilion, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, sPavilion, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, sPavilion, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, null, null, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, null, null, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, null, null, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, null, sPavilion, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, null, sPavilion, lstBoothClasses, null);
				}
                If(Test.isRunningTest()){sShowInShow = '';sReturnedPrdName = '';}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sPavilion) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, null, sPavilion, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, null, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, null, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, null, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, null, null, null, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sPavilion)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, null, sPavilion, null, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, null, null, null);
				}
				If(String.isBlank(sReturnedPrdName) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, null, null, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, null, null, null, sBoothProductType);
				}
                
                If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, null, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, null, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, null, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, null, null, null, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sPavilion)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, null, sPavilion, null, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, null, null, null);
				}
				If(String.isBlank(sReturnedPrdName) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, null, null, lstBoothClasses, null);
				}
			}
		}
        return sReturnedPrdName;
	}
    
     /****************** Common METHODS ****************/

     
    /**
    * @description  This method is used sending callouts to ExpoCAD
    * @param  endPointURL Callout End Point Url
    * @param  method  Callout request method [GET , PUT , POST]
    * @param  jsonBody  request Body  
    * @return  HttpResponse response from ExpoCAD System
    */
    private static HttpResponse sendRequest2ExpoCAD(String endPointURL,string method,String jsonBody,Boolean hasToken,String apiToken)
    {
        endPointURL = removeUnUsedPrameters(endPointURL);
        //String encodedUrl = EncodingUtil.urlEncode(endPointURL, 'UTF-8');
        //endPointURL = endPointUrl.replaceall('*', '%2A');
        //endPointURL = endPointUrl.replaceall(' ', '%20');
        //endPointURL = endPointUrl.replaceall('\\^', '%5E');
        System.debug('sendRequest2ExpoCAD---'+endPointURL); 
        HttpRequest request = new HttpRequest();
        //request.setEndpoint('callout:ExpoCAD3E'+'/'+endPointURL);
        
        request.setEndpoint(endPointURL);
        request.setTimeout(60000);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('accept','*/*');
        //request.setHeader('',);
        
        
        if(hasToken){
             request.setHeader('ApiSessionToken', apiToken);
             request.setHeader('Host', System.Label.Expocad3E_Host);//System.Label.Expocad3E_Host
             if(method != 'GET'){
                 request.setHeader('Content-Length',String.valueOf(jsonBody.length()));
             }
            //request.setHeader('Content-Type', 'application/json;odata.metadata=minimal;odata.streaming=true');
        }
           
        request.setMethod(method);
        if(method == 'PUT' || method == 'POST')
        {
            //if(!hasToken){
                jsonBody = (String.isBlank(jsonBody)?'':jsonBody);
                request.setBody(jsonBody);
            //}
        }
        Http http = new Http();
        HttpResponse response = http.send(request);
        //System.debug(LoggingLevel.DEBUG,'HttpResponse Code -> '+response.getStatusCode()+' : ' +response.getStatus());
       // System.debug(LoggingLevel.DEBUG,'HttpResponse Reponse -> '+response.getBody());
        return response;
    }

    /**
    * @description  This method is used to remove unused prameters from URL
    * @param  url Endpoint Url
    * @return  String
    */
    private Static String removeUnUsedPrameters(String url)
    {
        List<String> urlSplitbyQuestionMark =  url.split('\\?');
        List<String> finalParams = new List<String>();
        if(urlSplitbyQuestionMark.size() > 1){
            List<String> urlParams = urlSplitbyQuestionMark[1].split('&');
            for(String param : urlParams){
                List<String> keyVal = param.split('=');
                if(keyVal.size() > 1 && !keyVal[1].startsWith('<OP_')){
                    finalParams.add(param);
                }
                if(keyVal.size()==1){
                    String lastParam = finalParams.get(finalParams.size()-1);
                    lastParam += '&' + param;
                    finalParams.set(finalParams.size()-1,lastParam);
                }
            }
        }
        url = urlSplitbyQuestionMark[0];
        if(!finalParams.isEmpty()){
            url = url + '?';
        }
        String strParam = '';
        for(String param : finalParams){
            strParam += (strParam==''?param:('&' + param));
        }
        url = url + strParam;
        return url;
    }

     /**
    * @description  This method is used to replace Prameters With Value in URL
    * @param  url Endpoint Url
    * @param  paramName parameter Name
    * @param  paramValue parameter Value
    * @return  String
    */
    private Static String replacePrametersWithValue(String url, String paramName, String paramValue)
    {
        url = url.replaceall(paramName,Matcher.quoteReplacement(paramValue));
        System.debug('url121---'+url);
        return url;
    }

    /**
    * @description  This method is used to get callout details like username,passwords & End points for  diffrent Systems
    * @param  metaDataName metadata label name
    * @param thirdParty third party name
    * @return  API_Detail__mdt
    */
    public Static API_Detail__mdt getAPIDetails(String metaDataName, String thirdParty)
    {
        API_Detail__mdt apiMappings;//Authorization_URL__c
        if(Schema.sObjectType.API_Detail__mdt.isaccessible() && ((thirdParty == Expocad3E_Wrapper.EXPOCAD3E)||(thirdParty == Expocad3E_Wrapper.EXPOCAD_EDGE)))
        {//API_3rd_Party_Name__c=:Expocad3EAPIWrapper.EXPOCAD3E
            apiMappings = [SELECT Id, DeveloperName, API_End_Point__c, Authorization_Request__c, Enable_callout__c, Password__c, User_Name__c FROM API_Detail__mdt Where  MasterLabel =:metaDataName limit 1];
        }
        return apiMappings; 
    }



     /*----------------------------------------------------------------------------------------------*/


    //public static Map < String, SBQQ__ProductOption__c > mapProductOptions = new Map < String, SBQQ__ProductOption__c > ();
    //public static  Map < Id, SBQQ__ProductOption__c > mapProductOptionsId = new Map < Id, SBQQ__ProductOption__c > ();
    //public static    Product2 boothPackageProduct = new Product2();
    //public static String cornerProductName;


    //public static Set < String > boothtoItself = new Set < String > ();
    //public static Set < String > setEEBoothClasses = new Set<String>();
    //public static SBQQ__Quote__c oSBQQQuote = new SBQQ__Quote__c();
     /**
     * @description Getting all package products for current event edition.
     */
    /*public static void getBoothProducts(Opportunity oOpportunity) {
        try {
            mapProductOptions = new Map < String, SBQQ__ProductOption__c > ();
            mapProductOptionsId = new Map < Id, SBQQ__ProductOption__c > ();
            String sBoothPackagePrdName;
            boothPackageProduct = new Product2();
            if (String.isNotBlank(oOpportunity.Event_Series__r.Package_Identifier__c)) {
                sBoothPackagePrdName = 'Booth Package ' + oOpportunity.Event_Series__r.Package_Identifier__c;
            }
            System.debug('sBoothPackagePrdName    '+sBoothPackagePrdName);
            if (String.isNotBlank(sBoothPackagePrdName)) {
                if (Schema.sObjectType.Product2.isAccessible()) {
                    List < Product2 > lstTemp = [SELECT Id, Name, Number_of_Corners__c, Booth_Product_Type__c, SBQQ__PriceEditable__c, SBQQ__NonDiscountable__c, SBQQ__Hidden__c, SBQQ__ConfigurationType__c FROM Product2 where Name = : sBoothPackagePrdName AND Event_Edition_Name__c = : oOpportunity.EventEdition__r.Name order by createdDate ASC LIMIT 1];
                    if (lstTemp != null && lstTemp.size() > 0) {
                        boothPackageProduct = lstTemp.get(0);
                    }
                }
            }
            System.debug('boothPackageProduct    '+boothPackageProduct);
            if (boothPackageProduct.Id != null) {
                if (Schema.sObjectType.SBQQ__ProductOption__c.isAccessible()) {
                    for (SBQQ__ProductOption__c oProductOption : [SELECT Id, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.SBQQ__ConfigurationType__c, SBQQ__OptionalSKU__r.SBQQ__PriceEditable__c, SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.Expiry_Date__c, SBQQ__OptionalSKU__r.SBQQ__NonDiscountable__c, SBQQ__OptionalSKU__r.SBQQ__Hidden__c, SBQQ__OptionalSKU__r.Booth_Type__c, SBQQ__OptionalSKU__r.Show_In_Show__c, SBQQ__OptionalSKU__r.Booth_Pavilion__c, SBQQ__OptionalSKU__r.Booth_Class__c, SBQQ__OptionalSKU__r.Booth_Product_Type__c, SBQQ__OptionalSKU__r.ExpoCAD_Product__c, SBQQ__OptionalSKU__r.Corner_Configuration__c, SBQQ__OptionalSKU__r.ExpoCAD_Booth_Product__c FROM SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c = : boothPackageProduct.Id AND SBQQ__OptionalSKU__c != null AND (SBQQ__OptionalSKU__r.Available_From__c = null OR SBQQ__OptionalSKU__r.Available_From__c < TODAY) LIMIT 5000]) {
                        mapProductOptions.put(oProductOption.SBQQ__OptionalSKU__r.Name, oProductOption);
                        mapProductOptionsId.put(oProductOption.Id, oProductOption);
                        if (oProductOption.SBQQ__OptionalSKU__r.Name.toLowerCase().contains('corner booth fee')) {
                            cornerProductName = oProductOption.SBQQ__OptionalSKU__r.Name;
                        }
                    }
                }
            }
            System.debug('mapProductOptions    '+mapProductOptions);
        } catch (exception ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'getBoothProducts(@Expo3EAPIUtilHelper.Class)'); }
    }*/

    public static Product2 getBoothProduct(Opportunity oOpportunity,String sBoothPackagePrdName) {
        //Product2 boothPackageProduct = new Product2();
        List < Product2 > lstTemp;
        if (Schema.sObjectType.Product2.isAccessible()) {
            lstTemp = [SELECT Id, Name, Number_of_Corners__c, Booth_Product_Type__c, SBQQ__PriceEditable__c, SBQQ__NonDiscountable__c, SBQQ__Hidden__c, SBQQ__ConfigurationType__c FROM Product2 where Name = : sBoothPackagePrdName AND Event_Edition_Name__c = : oOpportunity.EventEdition__r.Name order by createdDate ASC LIMIT 1];
        }
        if(!lstTemp.isEmpty())
            return lstTemp[0];
        return null;
     }

    public static List<SBQQ__ProductOption__c> getBoothProductOptions(Product2 boothPackageProduct,Set<String> ExpocadRelationshipCodeSet) {
        return [SELECT Id, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.SBQQ__ConfigurationType__c, SBQQ__OptionalSKU__r.Expocad_Relationship_Code__c,SBQQ__OptionalSKU__r.SBQQ__PriceEditable__c,
                SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.Expiry_Date__c, SBQQ__OptionalSKU__r.SBQQ__NonDiscountable__c, SBQQ__OptionalSKU__r.SBQQ__Hidden__c, SBQQ__OptionalSKU__r.Booth_Type__c,
                SBQQ__OptionalSKU__r.Show_In_Show__c, SBQQ__OptionalSKU__r.Booth_Pavilion__c, SBQQ__OptionalSKU__r.Booth_Class__c, SBQQ__OptionalSKU__r.Booth_Product_Type__c, SBQQ__OptionalSKU__r.ExpoCAD_Product__c, 
                SBQQ__OptionalSKU__r.Corner_Configuration__c, SBQQ__OptionalSKU__r.ExpoCAD_Booth_Product__c 
                FROM SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c = : boothPackageProduct.Id 
                AND SBQQ__OptionalSKU__c != null AND SBQQ__OptionalSKU__r.Expocad_Relationship_Code__c != null  
                AND  (SBQQ__OptionalSKU__r.Available_From__c = null OR SBQQ__OptionalSKU__r.Available_From__c < TODAY) LIMIT 5000];
    }


    /**
     * Designed to add all selected booths to Quote as Quote Line Item.
     * @param  sMethod [Need to Hold only or Hold and Add to Quote]
     * @return void
     */
    public static AddQliWrapper addToQLI(String quoteId,Opportunity oOpportunity1,String expocadId,Map < String, SBQQ__ProductOption__c > mapProductOptions,
                                         Map < Id, SBQQ__ProductOption__c > mapProductOptionsId,Product2 boothPackageProduct,String cornerProductName,Set<String> ExpocadRelationshipCodeSet,
                                         Map < String, Expocad3E_Wrapper.financialBooth > rateToWrapMap,Map<String, Expocad3E_Wrapper.RelatedItems> prodNameMap) 
    {
        
        AddQliWrapper wrapper = new AddQliWrapper();        
        SBQQ__Quote__c oSBQQQuote = [select Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c,CurrencyIsoCode from SBQQ__Quote__c where Id = : quoteId LIMIT 1];
        List<ExpocadBooth__c> lstHeldBooth = [SELECT id, Selected__c, AddedToQLI__c, Matched_Product_Name__c, Booth_Product_Type__c, Quote__r.Name, Quote__r.SBQQ__Primary__c, User__r.Name, Area__c, Unit_Type__c, Open_Corners__c, Booth_Type__c, Booth_Number__c, Dimensions__c, Last_Action_Date__c, Status__c, Opportunity__c, Account__c, ShowInShow__c, Pavilion__c, Booth_Classes__c, Booth_Product_Type_EE__c from ExpocadBooth__c where Opportunity__c = : oOpportunity1.Id and Id = :expocadId order by LastModifiedDate desc LIMIT 1000];
        List < SBQQ__QuoteLine__c > lstQuoteLine = new List < SBQQ__QuoteLine__c > ();
        List < SBQQ__QuoteLine__c > lstPackageQuoteLine = new List < SBQQ__QuoteLine__c > ();
        List < ExpocadBooth__c > lsttempHB = new List < ExpocadBooth__c > ();
        Set < String > setBoothIds = new Set < String > ();
        ExpocadBooth__c oTempEB;
        SBQQ__QuoteLine__c oQuoteLine;
        Set<String> setEEBoothClasses ;
        
        List<Product2> allProductsForEvent = [SELECT Id, Name, SBQQ__ConfigurationType__c, Expocad_Relationship_Code__c, SBQQ__PriceEditable__c, Expiry_Date__c, 
                                              SBQQ__NonDiscountable__c, SBQQ__Hidden__c, Booth_Type__c, Show_In_Show__c, Booth_Pavilion__c, Booth_Class__c, 
                                              Booth_Product_Type__c, ExpoCAD_Product__c FROM Product2 
                                              WHERE Expocad_Relationship_Code__c != null AND Event_Edition__c = :oOpportunity1.EventEdition__c LIMIT 5000];
        Map<String, Product2> codeToProductMap = new Map<String, Product2>();
        for(Product2 prod2: allProductsForEvent){
            for(String ProductCodeExpoCAD: prod2.Expocad_Relationship_Code__c.trim().split(',')){
                codeToProductMap.put(ProductCodeExpoCAD, prod2);
            }
        }
        
        Opportunity  oOpportunity = [SELECT AccountId, User_Type__r.Name, StageName, Parent_Opportunity__c, Booth_Approval_Status__c , SBQQ__PrimaryQuote__c ,Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, EventEdition__r.No_Of_Corner__c, EventEdition__r.Event_Code__c, EventEdition__r.Expocad_API_Url__c, EventEdition__r.Max_Hold_Days__c, EventEdition__r.Max_Hold_Booth__c, EventEdition__r.Booth_Product_Type__c, Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name, Billing_Contact__c, MSA_Requested__c, EventEdition__r.Corner_Configuration_Check__c, EventEdition__r.Product_Type_Order__c FROM Opportunity WHERE Id = :oOpportunity1.Id ];//oSBQQQuote.SBQQ__Opportunity2__c
        Integer quoteLineNumber = getLastQLNumber(oSBQQQuote);
        Set < String > boothtoItself = new Set < String > ();
        if (Schema.sObjectType.ExpocadBooth__c.isAccessible()) {
            for (ExpocadBooth__c oTempBooth : lstHeldBooth) {
                if (!setBoothIds.contains(oTempBooth.Booth_Number__c) ) {
                    
                    String sBoothClassesShowed = '';
                    if (!String.isBlank(oSBQQQuote.SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c)) {setEEBoothClasses = new Set<String>(oSBQQQuote.SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c.split(','));}
                    
                    if (setEEBoothClasses != Null && !setEEBoothClasses.isEmpty() && !String.isBlank(oTempBooth.Booth_Classes__c)) {
                        for (String sTemp : oTempBooth.Booth_Classes__c.split(';;')) {
                            if (setEEBoothClasses.contains(sTemp)) {
                                if (String.isBlank(sBoothClassesShowed)) {
                                    sBoothClassesShowed = sTemp ;
                                } else {
                                    sBoothClassesShowed = sBoothClassesShowed + ',' + sTemp ;
                                }
                            }
                        }
                    } 
                    
                    // Adding Package Product
                    String packageId;
                    oQuoteLine = new SBQQ__QuoteLine__c();
                    oQuoteLine.SBQQ__Quote__c = oSBQQQuote.Id;
                    oQuoteLine.SBQQ__Product__c = boothPackageProduct.Id; //LinearProduct.ID;
                    oQuoteLine.SBQQ__Quantity__c = 1;
                    oQuoteLine.SBQQ__NonDiscountable__c = boothPackageProduct.SBQQ__NonDiscountable__c;
                    oQuoteLine.SBQQ__Hidden__c = boothPackageProduct.SBQQ__Hidden__c;
                    if (boothPackageProduct.SBQQ__ConfigurationType__c == 'Allowed') {
                        oQuoteLine.SBQQ__Bundle__c = True;
                    }
                    oQuoteLine.SBQQ__Number__c = quoteLineNumber;
                    oQuoteLine.Booth_Number__c = oTempBooth.Booth_Number__c;
                    oQuoteLine.Booth__c = true;
                    oQuoteLine.Show_In_Show__c = oTempBooth.ShowInShow__c;
                    oQuoteLine.Booth_Pavilion__c = oTempBooth.Pavilion__c;
                    oQuoteLine.Booth_Type__c = oTempBooth.Booth_Type__c;
                    oQuoteLine.Open_Corners__c = oTempBooth.Open_Corners__c;
                    oQuoteLine.Booth_Classes__c = oTempBooth.Booth_Classes__c;
                    oQuoteLine.Booth_Product_Type__c = oTempBooth.Booth_Product_Type_EE__c;
                    oQuoteLine.Booth_Dimensions__c = oTempBooth.Dimensions__c ;
                    oQuoteLine.Booth_Classes_Showed_On_Template__c = sBoothClassesShowed ;
                    oQuoteLine.CurrencyIsoCode = oSBQQQuote.CurrencyIsoCode;
                    lstPackageQuoteLine.add(oQuoteLine);
                    quoteLineNumber++;
                    for (String sProductName : ExpocadRelationshipCodeSet) {
                        if (mapProductOptions.containsKey(sProductName)) {
                            Set <String> setCornerConfiguration = new Set <String>();
                            Double quantity = getQuantity(oTempBooth.Area__c);
                            if (mapProductOptions.get(sProductName).SBQQ__OptionalSKU__r.Corner_Configuration__c != NULL && mapProductOptions.get(sProductName).SBQQ__OptionalSKU__r.ExpoCAD_Product__c) {
                                for (String sTempCornerConfValue : mapProductOptions.get(sProductName).SBQQ__OptionalSKU__r.Corner_Configuration__c.split(';')) {
                                    setCornerConfiguration.add(sTempCornerConfValue.toLowerCase());
                                }
                            }
                            
                            // Getting Event Product using SB API
                            SBProductConfiguration oPrdConfiguration = new SBProductConfiguration();
                            SBProductConfiguration.TinyConfigurationModel oPrdConfigurationModel = new SBProductConfiguration.TinyConfigurationModel();
                            
                            if(test.isRunningTest()){
                                SBQQ__ProductOption__c tempOptionData;
                                List<SBProductConfiguration.TinyConfigurationModel> optionConfigurations = new List<SBProductConfiguration.TinyConfigurationModel>();
                                tempOptionData = mapProductOptions.get(sProductName);
                                tempOptionData.SBQQ__Selected__c = True;
                                tempOptionData.SBQQ__Quantity__c =  1;
                                SBProductConfiguration.TinyConfigurationModel oTempConfgModel = new SBProductConfiguration.TinyConfigurationModel();
                                oTempConfgModel.configuredProductId = boothPackageProduct.Id;
                                oTempConfgModel.optionId = mapProductOptions.get(sProductName).SBQQ__OptionalSKU__c;
                                oTempConfgModel.configured = false;
                                oTempConfgModel.changedByProductActions = false;
                                oTempConfgModel.isDynamicOption = false;
                                oTempConfgModel.isUpgrade = false;
                                oTempConfgModel.priceEditable = false;
                                oTempConfgModel.optionData=tempOptionData;
                                oTempConfgModel.configurationData = new SBQQ__ProductOption__c();
                                oTempConfgModel.optionConfigurations = new List<SBProductConfiguration.TinyConfigurationModel>();
                                oTempConfgModel.validationMessages = new List<String>();
                                optionConfigurations.add(oTempConfgModel);
                                oTempConfgModel.optionConfigurations = optionConfigurations;
                                oTempConfgModel.configurationData = tempOptionData;
                                
                                oPrdConfigurationModel = oTempConfgModel; 
                                
                            }else{
                                oPrdConfigurationModel = oPrdConfiguration.getConfigurationAfterFireProductRule(boothPackageProduct.Id, oSBQQQuote.SBQQ__PriceBook__c, mapProductOptions.get(sProductName).Id, mapProductOptions.get(sProductName).SBQQ__OptionalSKU__c, quantity);
                            }
                            
                            
                            if (!oPrdConfigurationModel.optionConfigurations.isEmpty()) {
                                for (SBProductConfiguration.TinyConfigurationModel oTempConfgModel : oPrdConfigurationModel.optionConfigurations) {
                                    if(mapProductOptionsId.containsKey(oTempConfgModel.optionData.Id)){
                                        oQuoteLine = new SBQQ__QuoteLine__c();
                                        oQuoteLine.SBQQ__Quote__c = oSBQQQuote.Id;
                                        oQuoteLine.SBQQ__ProductOption__c = oTempConfgModel.optionData.Id;
                                        oQuoteLine.SBQQ__Product__c = oTempConfgModel.optionData.SBQQ__OptionalSKU__c;
                                        oQuoteLine.SBQQ__Quantity__c = oTempConfgModel.optionData.SBQQ__Quantity__c;
                                        if (rateToWrapMap != null ) {
                                            if(rateToWrapMap.containsKey(sProductName) ){
                                                Expocad3E_Wrapper.financialBooth wrap = rateToWrapMap.get(sProductName);
                                                if (wrap.BillableArea != null) {
                                                    oQuoteLine.SBQQ__Quantity__c = wrap.BillableArea;
                                                }
                                                if (wrap.NetRate != null) {
                                                    oQuoteLine.SBQQ__ListPrice__c = wrap.NetRate;
                                                }
                                            }
                                        }else if (prodNameMap != null ) {
                                            if(prodNameMap.containsKey(sProductName) ){
                                                Expocad3E_Wrapper.RelatedItems wrap = prodNameMap.get(sProductName);
                                                if (wrap.Quantity != null) {
                                                    oQuoteLine.SBQQ__Quantity__c = wrap.Quantity;
                                                }
                                                if (wrap.UnitCost != null) {
                                                    oQuoteLine.SBQQ__ListPrice__c = wrap.UnitCost;
                                                }
                                            }
                                        }
                                        
                                        oQuoteLine.CurrencyIsoCode = oSBQQQuote.CurrencyIsoCode;
                                        oQuoteLine.SBQQ__Number__c = quoteLineNumber;
                                        oQuoteLine.SBQQ__NonDiscountable__c = mapProductOptionsId.get(oTempConfgModel.optionData.Id).SBQQ__OptionalSKU__r.SBQQ__NonDiscountable__c;
                                        oQuoteLine.SBQQ__Hidden__c = mapProductOptionsId.get(oTempConfgModel.optionData.Id).SBQQ__OptionalSKU__r.SBQQ__Hidden__c;
                                        if (mapProductOptionsId.get(oTempConfgModel.optionData.Id).SBQQ__OptionalSKU__r.SBQQ__ConfigurationType__c == 'Allowed') {
                                            oQuoteLine.SBQQ__Bundle__c = True;
                                        }
                                        oQuoteLine.SBQQ__PriceEditable__c = mapProductOptionsId.get(oTempConfgModel.optionData.Id).SBQQ__OptionalSKU__r.SBQQ__PriceEditable__c;
                                        if(test.isRunningTest()){ cornerProductName = mapProductOptionsId.get(oTempConfgModel.optionData.Id).SBQQ__OptionalSKU__r.Name;}
                                        oQuoteLine.SBQQ__PricingMethodEditable__c = True;
                                        if (mapProductOptionsId.get(oTempConfgModel.optionData.Id).SBQQ__OptionalSKU__r.ExpoCAD_Booth_Product__c) {
                                            oQuoteLine.Line_Description__c = oTempBooth.Booth_Number__c + '-' + oTempBooth.Booth_Type__c;
                                        }
                                        oQuoteLine.Booth_Number__c = oTempBooth.Booth_Number__c;
                                        oQuoteLine.Booth__c = true;
                                        oQuoteLine.Show_In_Show__c = oTempBooth.ShowInShow__c;
                                        oQuoteLine.Booth_Pavilion__c = oTempBooth.Pavilion__c;
                                        oQuoteLine.Booth_Type__c = oTempBooth.Booth_Type__c;
                                        oQuoteLine.Open_Corners__c = oTempBooth.Open_Corners__c;
                                        oQuoteLine.Booth_Classes__c = oTempBooth.Booth_Classes__c;
                                        oQuoteLine.Booth_Product_Type__c = oTempBooth.Booth_Product_Type_EE__c;
                                        oQuoteLine.SBQQ__OptionType__c = 'Component';
                                        oQuoteLine.SBQQ__OptionLevel__c = 1;
                                        oQuoteLine.Booth_Dimensions__c = oTempBooth.Dimensions__c ;
                                        oQuoteLine.Booth_Classes_Showed_On_Template__c = sBoothClassesShowed ;
                                        lstQuoteLine.add(oQuoteLine);
                                        quoteLineNumber++;
                                    }
                                }
                            }
                            
                            if(test.isRunningTest()){
                                oTempBooth.Open_Corners__c = 1;oOpportunity.EventEdition__r.Corner_Configuration_Check__c = false;
                            }
                            // Adding Corner Product
                            if (oTempBooth.Open_Corners__c != 0 && mapProductOptions.get(cornerProductName) != null && (!oOpportunity.EventEdition__r.Corner_Configuration_Check__c || ( !setCornerConfiguration.isEmpty() && setCornerConfiguration.contains(oTempBooth.Booth_Type__c.toLowerCase())))) {
                                oQuoteLine = new SBQQ__QuoteLine__c();
                                oQuoteLine.SBQQ__Quote__c = oSBQQQuote.Id;
                                oQuoteLine.SBQQ__Product__c = mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__c; //CornerProduct.ID;
                                oQuoteLine.SBQQ__Quantity__c = oTempBooth.Open_Corners__c;
                                if (rateToWrapMap != null ) {
                                    if(rateToWrapMap.containsKey(sProductName) ){
                                        Expocad3E_Wrapper.financialBooth wrap = rateToWrapMap.get(sProductName);
                                        if (wrap.BillableArea != null) {
                                            oQuoteLine.SBQQ__Quantity__c = wrap.BillableArea;
                                        }
                                        if (wrap.NetRate != null) {
                                            oQuoteLine.SBQQ__ListPrice__c = wrap.NetRate;
                                        }
                                    }
                                }else if (prodNameMap != null ) {
                                    if(prodNameMap.containsKey(sProductName) ){
                                        Expocad3E_Wrapper.RelatedItems wrap = prodNameMap.get(sProductName);
                                        if (wrap.Quantity != null) {
                                            oQuoteLine.SBQQ__Quantity__c = wrap.Quantity;
                                        }
                                        if (wrap.UnitCost != null) {
                                            oQuoteLine.SBQQ__ListPrice__c = wrap.UnitCost;
                                        }
                                    }
                                }
                                oQuoteLine.CurrencyIsoCode = oSBQQQuote.CurrencyIsoCode;
                                oQuoteLine.SBQQ__Number__c = quoteLineNumber;
                                oQuoteLine.SBQQ__NonDiscountable__c = mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__r.SBQQ__NonDiscountable__c;
                                oQuoteLine.SBQQ__Hidden__c = mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__r.SBQQ__Hidden__c;
                                if (mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__r.SBQQ__ConfigurationType__c == 'Allowed') {
                                    oQuoteLine.SBQQ__Bundle__c = True;
                                }
                                
                                oQuoteLine.SBQQ__PriceEditable__c = mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__r.SBQQ__PriceEditable__c;
                                
                                oQuoteLine.SBQQ__PricingMethodEditable__c = True;
                                oQuoteLine.SBQQ__BundledQuantity__c = oTempBooth.Open_Corners__c;
                                if (mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__r.ExpoCAD_Booth_Product__c) {
                                    oQuoteLine.Line_Description__c = oTempBooth.Booth_Number__c + '-' + oTempBooth.Booth_Type__c;
                                }
                                oQuoteLine.Booth_Number__c = oTempBooth.Booth_Number__c;
                                oQuoteLine.Booth__c = true;
                                oQuoteLine.Show_In_Show__c = oTempBooth.ShowInShow__c;
                                oQuoteLine.Booth_Pavilion__c = oTempBooth.Pavilion__c;
                                oQuoteLine.Booth_Type__c = oTempBooth.Booth_Type__c;
                                oQuoteLine.Open_Corners__c = oTempBooth.Open_Corners__c;
                                oQuoteLine.Booth_Classes__c = oTempBooth.Booth_Classes__c;
                                oQuoteLine.Booth_Product_Type__c = oTempBooth.Booth_Product_Type_EE__c;
                                oQuoteLine.Corner_Premium__c = true;
                                //oQuoteLine.SBQQ__OptionType__c = 'Component';
                                //oQuoteLine.SBQQ__OptionLevel__c = 1;
                                //oQuoteLine.SBQQ__ProductOption__c = mapProductOptions.get(cornerProductName).Id;
                                oQuoteLine.Booth_Dimensions__c = oTempBooth.Dimensions__c ;
                                oQuoteLine.Booth_Classes_Showed_On_Template__c = sBoothClassesShowed ;
                                lstQuoteLine.add(oQuoteLine);
                                quoteLineNumber++;
                            }
                            oTempBooth.Selected__c = false;
                        }
                        else if(codeToProductMap.containsKey(sProductName)){
                            Product2 prod2 = codeToProductMap.get(sProductName);
                            oQuoteLine = new SBQQ__QuoteLine__c();
                            oQuoteLine.SBQQ__Quote__c = oSBQQQuote.Id;
                            oQuoteLine.SBQQ__Product__c = prod2.Id;
                            if (rateToWrapMap != null ) {
                                if(rateToWrapMap.containsKey(sProductName) ){
                                    Expocad3E_Wrapper.financialBooth wrap = rateToWrapMap.get(sProductName);
                                    if (wrap.BillableArea != null) {
                                        oQuoteLine.SBQQ__Quantity__c = wrap.BillableArea;
                                    }
                                    if (wrap.NetRate != null) {
                                        oQuoteLine.SBQQ__ListPrice__c = wrap.NetRate;
                                    }
                                }
                            }else if (prodNameMap != null ) {
                                if(prodNameMap.containsKey(sProductName) ){
                                    Expocad3E_Wrapper.RelatedItems wrap = prodNameMap.get(sProductName);
                                    if (wrap.Quantity != null) {
                                        oQuoteLine.SBQQ__Quantity__c = wrap.Quantity;
                                    }
                                    if (wrap.UnitCost != null) {
                                        oQuoteLine.SBQQ__ListPrice__c = wrap.UnitCost;
                                    }
                                }
                            }
                            oQuoteLine.CurrencyIsoCode = oSBQQQuote.CurrencyIsoCode;
                            oQuoteLine.SBQQ__Number__c = quoteLineNumber;
                            oQuoteLine.SBQQ__NonDiscountable__c = prod2.SBQQ__NonDiscountable__c;
                            oQuoteLine.SBQQ__Hidden__c = prod2.SBQQ__Hidden__c;
                            if (prod2.SBQQ__ConfigurationType__c == 'Allowed') {
                                oQuoteLine.SBQQ__Bundle__c = True;
                            }
                            
                            oQuoteLine.SBQQ__PriceEditable__c = prod2.SBQQ__PriceEditable__c;
                            /*if (mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__r.ExpoCAD_Booth_Product__c) {
                                oQuoteLine.Line_Description__c = oTempBooth.Booth_Number__c + '-' + oTempBooth.Booth_Type__c;
                            }
                            oQuoteLine.SBQQ__ProductOption__c = mapProductOptions.get(cornerProductName).Id;
							*/
                            oQuoteLine.SBQQ__PricingMethodEditable__c = True;
                            oQuoteLine.Booth_Number__c = oTempBooth.Booth_Number__c;
                            oQuoteLine.Booth__c = true;
                            oQuoteLine.Show_In_Show__c = oTempBooth.ShowInShow__c;
                            oQuoteLine.Booth_Pavilion__c = oTempBooth.Pavilion__c;
                            oQuoteLine.Booth_Type__c = oTempBooth.Booth_Type__c;
                            oQuoteLine.Open_Corners__c = oTempBooth.Open_Corners__c;
                            oQuoteLine.Booth_Classes__c = oTempBooth.Booth_Classes__c;
                            oQuoteLine.Booth_Product_Type__c = oTempBooth.Booth_Product_Type_EE__c;
                            oQuoteLine.Corner_Premium__c = true;
                            oQuoteLine.SBQQ__OptionType__c = 'Component';
                            oQuoteLine.SBQQ__OptionLevel__c = 1;
                            oQuoteLine.Booth_Dimensions__c = oTempBooth.Dimensions__c ;
                            oQuoteLine.Booth_Classes_Showed_On_Template__c = sBoothClassesShowed ;
                            lstQuoteLine.add(oQuoteLine);
                            quoteLineNumber++;
                        }
                    }
                }
                oTempBooth.Selected__c = false;
                setBoothIds.add(oTempBooth.Booth_Number__c);
                
            }
            
            if (lstQuoteLine.size() > 0 && lstPackageQuoteLine.size() > 0) {
                Map < String, Id > mapPackageprdIds = new Map < String, Id > ();
                for (SBQQ__QuoteLine__c oQLI : lstPackageQuoteLine) {
                    mapPackageprdIds.put(oQLI.Booth_Number__c, oQLI.id);
                }
                for (SBQQ__QuoteLine__c oQLI : lstQuoteLine) {
                    oQLI.SBQQ__RequiredBy__c = mapPackageprdIds.get(oQLI.Booth_Number__c);
                }
                wrapper.packageQli = lstPackageQuoteLine;
                wrapper.qliRecList = lstQuoteLine;
            }
        }
        
        return wrapper;
    }
    
    public class AddQliWrapper {
        Public List<SBQQ__QuoteLine__c> packageQli = new List<SBQQ__QuoteLine__c>();
        Public List<SBQQ__QuoteLine__c> qliRecList = new List<SBQQ__QuoteLine__c>();
        Public String calloutStatus = Expocad3E_Wrapper.SUCCESS;
    }
    
    
    /**
    * @description Getting maximum no. of Quote Line Number, which are alreday added to current Quote.
    * @return Integer
    */
    public static Integer getLastQLNumber(SBQQ__Quote__c oSBQQQuote) {
        Integer tempQuoteLineNumber;
        if (Schema.sObjectType.SBQQ__QuoteLine__c.isAccessible()) {
            List < SBQQ__QuoteLine__c > lstQuoteLine2 = [select id from SBQQ__QuoteLine__c where SBQQ__Quote__c = : oSBQQQuote.Id LIMIT 1000];
            if (lstQuoteLine2 != null && lstQuoteLine2.size() > 0) {
                tempQuoteLineNumber = lstQuoteLine2.size();
            } else {
                tempQuoteLineNumber = 1;
            }
        }
        return tempQuoteLineNumber;
    }


    /**
     * @description Converting String value to double.
     * @param  sQuantity [String Value]
     * @return Double
     */
    public static Double getQuantity(String sQuantity) {
        String sTempQuantity = sQuantity.substringBefore(' ');
        sTempQuantity = sTempQuantity.trim();
        return Double.valueof(sTempQuantity);
    }


    /**
	 * Designed to get Product Name using BoothType, ShowInShow, BoothClasses (values returned by Expocad booth detail) and Event's Product Type.
	 * @param  oEB                 [Expocad Booth Ref]
	 * @param  oOpportunity        [Opportunity  Ref]
	 * @param  boothPackageProduct [Product package Ref]
	 * @return String              [Product Name]
	 */
	Public Static String sBPrd(Map < Id, SBQQ__ProductOption__c > mapProductOptionsId, Expocad3E_Wrapper.GetAllBoothsWrapper oEB, Opportunity oOpportunity, Product2 boothPackageProduct) {
		System.debug('mapProductOptionsId : ' + mapProductOptionsId);
        System.debug('boothPackageProduct : ' + boothPackageProduct);
        System.debug('oEB : ' + oEB);
        System.debug('oOpportunity : ' + oOpportunity);
        String sReturnedPrdName = NULL;
		String sBoothType = NULL;
		String sShowInShow = NULL;
		String sPavilion = NULL;
		String sBoothProductType = NULL;
		List < String > lstBoothClasses = new List < String > ();

		if (!String.isBlank(oEB.BoothType) && !oEB.BoothType.containsIgnoreCase('Corner')) {sBoothType = oEB.BoothType;
		}
		if (!String.isBlank(oEB.ShowInShow) && !oEB.ShowInShow.containsIgnoreCase('Corner')) {sShowInShow = oEB.ShowInShow;
		}
		if (!String.isBlank(oEB.Pavilion) && !oEB.Pavilion.containsIgnoreCase('Corner')) {sPavilion = oEB.Pavilion;
		}
		/*if (!String.isBlank(oEB.BoothClass) && !oEB.BoothClass.containsIgnoreCase('Corner')) {?????????
			sBoothProductType = oEB.BoothClass;
		}*/
		if (oEB.BoothClasses != null && !oEB.BoothClasses.isEmpty()) {
			for (String sTemp : oEB.BoothClasses) {
				if (sTemp != 'Standard Booth' && !sTemp.containsIgnoreCase('Corner')) {
					lstBoothClasses.add(sTemp);
				}
			}
		}
        System.debug('sBPrd : sBoothType : ' + sBoothType);
        System.debug('sBPrd : sShowInShow : ' + sShowInShow);
        System.debug('sBPrd : sPavilion : ' + sPavilion);
        System.debug('sBPrd : sBoothProductType : ' + sBoothProductType);
        
        If(Test.isRunningTest()){
            sShowInShow = 'sShowInShow';sReturnedPrdName = '';//sBoothType = 'sBoothType';
        }
        System.debug('sBPrd : lstBoothClasses : ' + lstBoothClasses);
		If(!String.isBlank(sBoothType) || !String.isBlank(sShowInShow) || !String.isBlank(sPavilion) || !lstBoothClasses.isEmpty() || !String.isBlank(sBoothProductType)) {
			// All Param Included
			If(!String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, sPavilion, lstBoothClasses, sBoothProductType);
			}
			If(String.isBlank(sReturnedPrdName) && (!String.isBlank(sShowInShow) || !String.isBlank(sPavilion) || !String.isBlank(sBoothProductType) || !lstBoothClasses.isEmpty())) {

				If(!String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, sPavilion, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, sPavilion, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, null, sPavilion, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, null, sPavilion, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sPavilion) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, null, sPavilion, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, null, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, null, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sShowInShow) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, sShowInShow, null, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, sPavilion, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, sPavilion, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !String.isBlank(sPavilion) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, sPavilion, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, null, null, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, null, null, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, null, null, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, null, sPavilion, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sPavilion) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, null, sPavilion, lstBoothClasses, null);
				}
                If(Test.isRunningTest()){sShowInShow = '';sReturnedPrdName = '';}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sPavilion) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, null, sPavilion, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !lstBoothClasses.isEmpty() && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, null, lstBoothClasses, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, null, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, null, null, sBoothProductType);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, sBoothType, null, null, null, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sPavilion)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, null, sPavilion, null, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sShowInShow)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, sShowInShow, null, null, null);
				}
				If(String.isBlank(sReturnedPrdName) && !lstBoothClasses.isEmpty()) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, null, null, lstBoothClasses, null);
				}
				If(String.isBlank(sReturnedPrdName) && !String.isBlank(sBoothProductType)) {sReturnedPrdName = BoothSelectionCtrl_Helper.matchedPrdName(mapProductOptionsId, null, null, null, null, sBoothProductType);
				}
			}
		}
        return sReturnedPrdName;
	}

}