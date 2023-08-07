public class ext_CreateNewQuote {

public list<SBQQ__Quote__c> lstQuoteInsert {get;set;}
public Opportunity objOpp {get;set;}
public id oppId {get;set;}
public boolean bolCheck {get;set;} 
    public ApexPages.StandardController stdCntrlr {get; set;}
    public ext_CreateNewQuote(){
        System.debug('To remove SCA violation');
    }
     public ext_CreateNewQuote(ApexPages.StandardController controller) {
        //stdCntrlr = controller;
        bolCheck =false;
        if(ApexPages.currentPage().getParameters().get('OpportunityId')!=null){
            oppId = ApexPages.currentPage().getParameters().get('OpportunityId');
        }
        else{
            oppId = controller.getRecord().Id;
        }
        system.debug('1 : Opportunity------>'+oppId);
        /*system.debug('2 : Opportunity ID------>'+oppId);*/
        
        //objQuote = new SBQQ__Quote__c();
        objOpp = new Opportunity();
        lstQuoteInsert = new list<SBQQ__Quote__c>();
        
        objOpp =[Select id,name,Accountid,Account.ShippingStreet,Account.ShippingCity,Opportunity_Contact__c,Account.ShippingCountry,Account.ShippingPostalCode,Account.ShippingState,Ownerid,Account.name,
                    Billing_Contact__c,Billing_Contact__r.MailingStreet,Billing_Contact__r.MailingCity,Billing_Contact__r.MailingState,Billing_Contact__r.MailingPostalCode,Billing_Contact__r.MailingCountry
                    FROM Opportunity 
                    WHERE id =:oppId];
        list<SBQQ__Quote__c> primaryQuoteList = [select id,SBQQ__Primary__c,SBQQ__Opportunity2__c from SBQQ__Quote__c Where SBQQ__Opportunity2__c =:oppId AND SBQQ__Primary__c = true];
        
        if(primaryQuoteList.size()>0){
            bolCheck=true;
        }
        else{
            bolCheck = false;
        }            
    }


/*  
    public ext_CreateNewQuote() {
        
    }*/
/*
    public PageReference newQuote() {
        PageReference pageRef = null;
        //try{    
            
            system.debug('2 : Opportunity------>'+oppId);        
            list<SBQQ__Quote__c> primaryQuoteList = [select id,SBQQ__Primary__c,SBQQ__Opportunity2__c from SBQQ__Quote__c Where SBQQ__Opportunity2__c =:oppId AND SBQQ__Primary__c = true];
            
            objQuote.SBQQ__Opportunity2__c = objOpp.id;
            objQuote.SBQQ__Account__c = objOpp.Accountid;
            objQuote.SBQQ__BillingName__c = objOpp.Account.name;
            objQuote.SBQQ__ShippingName__c = objOpp.Account.name; 
            objQuote.SBQQ__StartDate__c = date.today(); //SBQQ__EndDate__c
            //objQuote.SBQQ__EndDate__c = date.today().adddays(30);
            //objQuote.SBQQ__Primary__c = false;
            objQuote.SBQQ__ExpirationDate__c = date.today().adddays(30);
            objQuote.SBQQ__SalesRep__c = objOpp.Ownerid;
            objQuote.SBQQ__PrimaryContact__c = objOpp.Opportunity_Contact__c;
            objQuote.SBQQ__BillingStreet__c =objOpp.Billing_Contact__r.MailingStreet;
            objQuote.SBQQ__ShippingStreet__c = objOpp.Account.ShippingStreet;
            objQuote.SBQQ__BillingCity__c = objOpp.Billing_Contact__r.MailingCity;
            objQuote.SBQQ__ShippingCity__c =objOpp.Account.ShippingCity;
            objQuote.SBQQ__BillingState__c = objOpp.Billing_Contact__r.MailingState;
            objQuote.SBQQ__ShippingState__c =objOpp.Account.ShippingState;
            objQuote.SBQQ__BillingPostalCode__c =objOpp.Billing_Contact__r.MailingPostalCode;
            objQuote.SBQQ__ShippingPostalCode__c =objOpp.Account.ShippingPostalCode;
            objQuote.SBQQ__BillingCountry__c =objOpp.Billing_Contact__r.MailingCountry;
            objQuote.SBQQ__ShippingCountry__c =objOpp.Account.ShippingCountry;
            objQuote.CurrencyIsoCode = objOpp.CurrencyIsoCode; 
            
            lstQuoteInsert.add(objQuote);
            
            if(primaryQuoteList.size()>0 && objQuote.SBQQ__Primary__c == false){
                PageReference acctPage = new PageReference('/apex/Create_Quote');
                //PageReference acctPage = new PageReference('/apex/vf_makeQuotePrimary?OpportunityId='+oppId);
                acctPage.setRedirect(true);
                return acctPage;
                bolCheck =true;
            }
            else{
                lstQuoteInsert[0].SBQQ__Primary__c = true;
                system.debug('0 : lstQuoteInsert ------>'+lstQuoteInsert);
                if(lstQuoteInsert!=null && lstQuoteInsert.size()>0){
                    insert lstQuoteInsert;
                }
            }
            
            */
            
            /* Code By PVT */
            /*if(objOpp.Account.ShippingStreet!=null && objOpp.Account.ShippingCity != null && objOpp.Account.ShippingCountry!=null)
            {
            
            }
            
            else if(objOpp.Account.ShippingStreet==null && objOpp.Account.ShippingCity == null && objOpp.Account.ShippingCountry==null)
            {
              ErrorMsg ='please check opportunity account address field and fill them';
            }*/
            /*string quoteURL = System.Label.QuoteLine_Items_URL;
            pageRef = new PageReference(quoteURL+objQuote.id);
            pageRef.setRedirect(true);*/

        /*}
        
        catch(exception ex){
            system.debug('exception--->'+ex);
        }
        */
 /*       if(primaryQuoteList.size()>0){
            bolCheck=true;
        }
        else{
            bolCheck = false;
        }
        PageReference acctPage = new PageReference('/apex/Create_Quote?OpportunityId='+oppId);
        //PageReference acctPage = new PageReference('/apex/vf_makeQuotePrimary?OpportunityId='+oppId);
        acctPage.setRedirect(true);
        return acctPage;
        
        //return pageRef; 
    }
    
    public PageReference saveQuote(){
            
        objOpp = new Opportunity();
        
        objOpp =[Select id,name,Accountid,Account.ShippingStreet,Account.ShippingCity,Opportunity_Contact__c,Account.ShippingCountry,Account.ShippingPostalCode,Account.ShippingState,Ownerid,Account.name,
                    Billing_Contact__c,Billing_Contact__r.MailingStreet,Billing_Contact__r.MailingCity,Billing_Contact__r.MailingState,Billing_Contact__r.MailingPostalCode,Billing_Contact__r.MailingCountry
                    FROM Opportunity 
                    WHERE id =:oppId];    
            
            objQuote.SBQQ__Opportunity2__c = objOpp.id;
            objQuote.SBQQ__Account__c = objOpp.Accountid;
            objQuote.SBQQ__BillingName__c = objOpp.Account.name;
            objQuote.SBQQ__ShippingName__c = objOpp.Account.name; 
            objQuote.SBQQ__StartDate__c = date.today(); //SBQQ__EndDate__c
            //objQuote.SBQQ__EndDate__c = date.today().adddays(30);
            objQuote.SBQQ__Primary__c = false;
            objQuote.SBQQ__ExpirationDate__c = date.today().adddays(30);
            objQuote.SBQQ__SalesRep__c = objOpp.Ownerid;
            objQuote.SBQQ__PrimaryContact__c = objOpp.Opportunity_Contact__c;
            objQuote.SBQQ__BillingStreet__c =objOpp.Billing_Contact__r.MailingStreet;
            objQuote.SBQQ__ShippingStreet__c = objOpp.Account.ShippingStreet;
            objQuote.SBQQ__BillingCity__c = objOpp.Billing_Contact__r.MailingCity;
            objQuote.SBQQ__ShippingCity__c =objOpp.Account.ShippingCity;
            objQuote.SBQQ__BillingState__c = objOpp.Billing_Contact__r.MailingState;
            objQuote.SBQQ__ShippingState__c =objOpp.Account.ShippingState;
            objQuote.SBQQ__BillingPostalCode__c =objOpp.Billing_Contact__r.MailingPostalCode;
            objQuote.SBQQ__ShippingPostalCode__c =objOpp.Account.ShippingPostalCode;
            objQuote.SBQQ__BillingCountry__c =objOpp.Billing_Contact__r.MailingCountry;
            objQuote.SBQQ__ShippingCountry__c =objOpp.Account.ShippingCountry;
            objQuote.CurrencyIsoCode = objOpp.CurrencyIsoCode; 
            
            lstQuoteInsert.add(objQuote);
        
        system.debug('1 : lstQuoteInsert ------>'+lstQuoteInsert);
        if(lstQuoteInsert!=null && lstQuoteInsert.size()>0){
            //insert lstQuoteInsert;
        }
        PageReference acctPage = new PageReference('/'+objQuote.id);
        acctPage.setRedirect(true);
        return acctPage;
    }
    
    public PageReference cancelQuote(){
        PageReference acctPage = new PageReference('/'+oppId);
        acctPage.setRedirect(true);
        return acctPage;
    }*/
}