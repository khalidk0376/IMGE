/* Create Date : 04/04/2018
* Created By : Avinash Singh
* Modified on: [16/07/2021 BK-14824]
* Test Class : LicenseInformationHandler_Test 
* History:https://informa-ge-sfdc.atlassian.net/browse/BK-3006 , [Aishwarya BK-3759 27 Aug 2020]
* Rajesh Kumar Yadav Only SCA Work.
* */
public with sharing class LicenseInformationBatchController implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
    public final String Query;
    public LicenseInformationBatchController(String sqlQr){
        Query = sqlQr;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bC, List<Salesforce_Org__c> scope){
        List<License_Usage__c> user_license = new List<License_Usage__c>();
        
        for(Salesforce_Org__c sfOrg : scope){
            // get login token from target salesforce org.
            LicenseInformationHandler lihObj = new LicenseInformationHandler();
            String strToken ='';
            if(sfOrg.Is_OAuth_Authorize__c){
                strToken = lihObj.getAccessToken(sfOrg);
            }
            else{
                strToken = lihObj.getToken(sfOrg);
            }
            //  String strTokenold = lihObj.getToken(sfOrg);
           // String strToken = lihObj.getAccessToken(sfOrg);
            if(String.isNotEmpty(strToken)){
                Http h1 = new Http();
                HttpRequest requestToken = new HttpRequest();
                string endPt = sfOrg.domain__c + '/services/data/v42.0/query?q=Select+Id,Name,Status,TotalLicenses,UsedLicenses+from+UserLicense';
                
                requestToken.setHeader('Authorization','Bearer '+strToken);
                requestToken.setMethod('GET');
                requestToken.setEndpoint(endPt);
                HttpResponse tokenResponse;
                
                if(test.isrunningtest()){
                    tokenResponse = lihObj.getTestResponse(requestToken,'stdLicense');
                }
                else{
                    tokenResponse = h1.send(requestToken);}
                
                String strResponse = tokenResponse.getBody().unescapeCsv().remove('\\');
                Map<String,Object> mp_StrObj = (Map<string,Object>)(Object)Json.deserializeUntyped(strResponse);
                date currentDate = Date.today(); // to create external Id
                List<Object> recObj = (List<Object>)mp_StrObj.get('records');
                for(Object obj : recObj){
                    Map<String,Object> mpObj = (Map<string,Object>)obj; 
                    user_license.add(new License_Usage__c(
                        ExternalId__c = String.valueOf(mpObj.get('Id'))+String.valueOf(sfOrg.Name)+String.valueOf(currentDate.month())+String.valueOf(currentDate.year()),
                        Name =String.valueOf(mpObj.get('Name')),  
                        License_Type__c =String.valueOf(mpObj.get('Name')),
                        Org_Id__c=sfOrg.Target_Oid__c,
                        Org_Name__c=sfOrg.Name, 
                        Status__c = String.valueOf(mpObj.get('Status')),
                        TotalLicenses__c = Integer.valueOf(mpObj.get('TotalLicenses')),
                        UsedLicenses__c = Integer.valueOf(mpObj.get('UsedLicenses')),
                        Month__c = lihObj.getMonthText(currentDate.month())
                    ));
                }
                // Getting CPQ license details //
                
                HttpRequest requestTokenCPQ = new HttpRequest();
                string NamespacePre ='SBQQ';
                string EndPtCPQ = sfOrg.domain__c +'/services/data/v42.0/query?q=SELECT+Id,Status,AllowedLicenses,UsedLicenses,NamespacePrefix+FROM+PackageLicense+where+NamespacePrefix ='+'\'' + String.escapeSingleQuotes(NamespacePre) + '\'';
                requestTokenCPQ.setHeader('Authorization','Bearer '+strToken);
                requestTokenCPQ.setMethod('GET');
                requestTokenCPQ.setEndpoint(EndPtCPQ);
                HttpResponse tokenResponseCPQ;
                
                if(test.isrunningtest())
                {
                    tokenResponseCPQ = lihObj.getTestResponse(requestToken,'cpqLicense');
                }
                else{
                    tokenResponseCPQ = h1.send(requestTokenCPQ);
                }
                system.debug('tokenResponseCPQ@@@@@@@2'+tokenResponseCPQ);
                if(!tokenResponseCPQ.getBody().contains('Bad Message 400')){
                    String strResponseCPQ = tokenResponseCPQ.getBody().unescapeCsv().remove('\\');
                    
                    Map<String,Object> mp_StrObjCPQ = (Map<string,Object>)(Object)Json.deserializeUntyped(strResponseCPQ);
                    
                    List<Object> recObjCPQ = (List<Object>)mp_StrObjCPQ.get('records');
                    for(Object obj : recObjCPQ){
                        Map<String,Object> mpObj = (Map<string,Object>)obj; 
                        user_license.add(new License_Usage__c(
                            ExternalId__c = String.valueOf(mpObj.get('Id'))+String.valueOf(sfOrg.Name)+String.valueOf(currentDate.month())+String.valueOf(currentDate.year()),
                            Name ='Salesforce CPQ',  
                            License_Type__c =String.valueOf(mpObj.get('Name')),
                            Org_Id__c=sfOrg.Target_Oid__c,
                            Org_Name__c=sfOrg.Name, 
                            Status__c = String.valueOf(mpObj.get('Status')),
                            TotalLicenses__c = Integer.valueOf(mpObj.get('AllowedLicenses')),
                            UsedLicenses__c = Integer.valueOf(mpObj.get('UsedLicenses')),
                            Month__c = lihObj.getMonthText(currentDate.month())
                        ));
                    }
                }
                
            }
        }
        If(user_license !=null && user_license.size()>0){
            try{
                Upsert user_license ExternalId__c;
                
            }catch(exception e){
                System.debug('error '+e.getMessage());
            }
        }
    }
    public void finish(Database.BatchableContext bC)
    {
        System.debug('Batch is Completed');
    }
}