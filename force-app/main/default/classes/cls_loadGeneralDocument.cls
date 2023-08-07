/**
* Project:     GAP
* Date:        Jan 21, 2017
* Test Class:  Manually_Upload_Salesforce_Contract_test
* Created By: 
* *************************************************************************
* @discription : Controller to Add or Replace Booths for Closed Opportunity.
* *************************************************************************
* History: History: Modfied By Rajesh Kumar - BK-3755 on 29 - 04- 2020
*/
public without sharing class cls_loadGeneralDocument{

public String qouteId{get;set;}
public list <SBQQ__Quote__c> lstQuote{get;set;}
    
    public cls_loadGeneralDocument(){
    
        qouteId = ApexPages.currentPage().getParameters().get('quoteId');   
        lstQuote = new list <SBQQ__Quote__c>();     
        
    }
    
    public PageReference pageLoadAction(){
        
        PageReference pg;
        
        if(qouteId!=null){
            lstQuote = [SELECT Id,IsNotGeneralDocument__c FROM SBQQ__Quote__c  WHERE ID =: QouteId]; 
            
            if(lstQuote[0].IsNotGeneralDocument__c == true){
                lstQuote[0].IsNotGeneralDocument__c = false;
                try{
                    update lstQuote;
                }
                catch (Exception ex){
	                insert new Error_Log__c( Service_Source__c = 'Integration/Non Integration', Source_Name__c = 'cls_loadGeneralDocumen', Description__c = ex.getMessage() + ',' +ex.getCause()+ ',' +ex.getLineNumber() + ',' + ex.getStackTraceString());
                }
            }
            
            pg = new pageReference('/apex/SBQQ__GenerateDocument?scontrolCaching=1&id=' + qouteId);
        }
        
        
        return pg;   
    }
}