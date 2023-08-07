/**
* File:        QuoteCurrency class
* Project:     GAP
* Date:        16/1/2018 1:54 PM
* Created By:  Rajesh Kumar
* Test Class:  QuoteCurrenciestrgg_test(85%)
* *************************************************************************
* Description: Trigger converted currency conversion in Quote
* *************************************************************************
* History: 
*/
public without sharing class QuoteCurrency {
    
    List<SBQQ__Quote__c> newQuoteLst        { get; set; }
    Map<Id, SBQQ__Quote__c> oldQuoteMap     { get; set; }
    Boolean isInsert                        { get; set; }
    Boolean isupdate                        { get; set; }
    Boolean isBefore                        { get; set; }
    Boolean isAfter                         { get; set; }
    List<SBQQ__Quote__c> listQuote          { get; set; } 
    Set<Id> oppIds                          { get; set; }
    Set<String> qAlternateCurrency          { get; set; }
    Set<String> qCurrencyIsoCode            { get; set; }
    String opptyId;
    String congaQuoteId;
    String congaContractId;
    String congatermconditionId;
    String congaAlternatetermconditionId;
    String mixedtermsConditon ;
    
    
    public QuoteCurrency ( List<SBQQ__Quote__c> newQuoteLst, Map<id, SBQQ__Quote__c> oldQuoteMap, Boolean isInsert, Boolean isupdate, Boolean isBefore, Boolean isAfter ) {
        
        this.newQuoteLst  = newQuoteLst; 
        this.oldQuoteMap  = oldQuoteMap;
        this.isInsert     = isInsert;
        this.isupdate     = isupdate;
        this.isBefore     = isBefore;
        this.isAfter      = isAfter;
        
        listQuote         = new List<SBQQ__Quote__c>( );
        oppIds            = new Set<Id>( );
        qAlternateCurrency             = new Set<String>( );
        qCurrencyIsoCode            = new Set<String>( );
        opptyId  = congaQuoteId = congaContractId = congatermconditionId = congaAlternatetermconditionId= '';
    }
    
    public void currencyConversion() {
        
        if(isUpdate ) {
            System.debug('Test in ');
            for( SBQQ__Quote__c qt : newQuoteLst ){ 
                if( qt.SBQQ__Opportunity2__c != null ) {
                    opptyId = qt.SBQQ__Opportunity2__c;
                }
                if (oldQuoteMap.size() > 0){
                    if( oldQuoteMap.get( Qt.Id ).Alternate_Currency2__c != Qt.Alternate_Currency2__c )  {
                        qAlternateCurrency.add(Qt.Alternate_Currency2__c); 
                        qCurrencyIsoCode.add(Qt.CurrencyIsoCode);  
                    }
                }   
            }
        }
        
        
        if( isInsert ) {
            for( SBQQ__Quote__c qt : newQuoteLst ) {
                if( qt.SBQQ__Opportunity2__c != null ) {
                    opptyId = qt.SBQQ__Opportunity2__c; 
                }
                if( qt.SBQQ__Opportunity2__r.PartnerAccount != null ) {
                    qt.SBQQ__Partner__c = qt.SBQQ__Opportunity2__r.PartnerAccount.Id;  
                }
                //Get Alternate Currencies and CurrencyIsoCode
                qAlternateCurrency.add(Qt.Alternate_Currency2__c);
                qCurrencyIsoCode.add(Qt.CurrencyIsoCode);
            }
            
        }    
        
        if( qAlternateCurrency.size() > 0 && qCurrencyIsoCode.size() > 0 ) {
            List<Currency_Master__c> currExchRateList = new List<Currency_Master__c> ();
            // Check if the user has read access on the Currency_Master__c.ExchangeRate__c field
            if (!Schema.sObjectType.Currency_Master__c.fields.ExchangeRate__c.isAccessible() && !Schema.sObjectType.Currency_Master__c.fields.ForeignCurrency__c.isAccessible() && !Schema.sObjectType.Currency_Master__c.fields.LocalCurrency__c.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
            }
            else {
                currExchRateList = [ Select ExchangeRate__c,ForeignCurrency__c,LocalCurrency__c From Currency_Master__c Where LocalCurrency__c in : qAlternateCurrency AND  ForeignCurrency__c  in : qCurrencyIsoCode Order By LastModifiedDate DESC Limit 1 ];
            }
            
            Map<String,decimal> currTypeMap = new Map<string,decimal>( );
            
            for( Currency_Master__c curr : currExchRateList ) {
                currTypeMap.put( curr.LocalCurrency__c,curr.ExchangeRate__c );
            }
            
            for( SBQQ__Quote__c oquote: newQuoteLst ) {
                Decimal cRate = currTypeMap.get( oquote.Alternate_Currency__c );
                if( cRate != null ) {
                    oquote.QuoteConversionRate__c = cRate;
                } 
            }
        }
        
        for( Opportunity opp: [ Select id, Quote_Template_Id__c,EventEdition__r.Mix_Supply_Terms_and_Condition__c, Mixed_Products__c,Exhibitor_Paid_By__c, EventEdition__r.Terms_Condition_Template__c, EventEdition__r.DS_Terms_Condition_Template__c,EventEdition__r.Alternative_Terms_Condition_Template__c, Contract_template_id__c,( Select id,conga_quote_template_id__c,conga_contract_template_id__c from SBQQ__Quotes2__r) from Opportunity where Id =: opptyId ] ) {
            
            if( opp.Quote_Template_Id__c != null ) { 
                congaQuoteId = opp.Quote_Template_Id__c;
            }
            if( opp.Contract_template_id__c!=null ) {
                congaContractId = opp.Contract_template_id__c;
            }
            
           if(opp.Exhibitor_Paid_By__c != 'Delegate Sales')
            {
                if(opp.EventEdition__r.Terms_Condition_Template__c != null)
                {
                    congatermconditionId = opp.EventEdition__r.Terms_Condition_Template__c;                    
                }
                if(opp.EventEdition__r.Alternative_Terms_Condition_Template__c != null)
                {
                    congaAlternatetermconditionId = opp.EventEdition__r.Alternative_Terms_Condition_Template__c;
                }
            }
           
            else if(opp.Exhibitor_Paid_By__c == 'Delegate Sales')
            {
               if(opp.EventEdition__r.DS_Terms_Condition_Template__c != null)
                {
                    congatermconditionId = opp.EventEdition__r.DS_Terms_Condition_Template__c;                    
                } 
            }
            
            if(opp.EventEdition__r.Mix_Supply_Terms_and_Condition__c!=null){
                   mixedtermsConditon=opp.EventEdition__r.Mix_Supply_Terms_and_Condition__c;
            }
            
            for( SBQQ__Quote__c objQt : opp.SBQQ__Quotes2__r ) {
                listQuote.add( objQt );
            }
        }
        if ( listQuote.isEmpty( ) ) {
            for (SBQQ__Quote__c qt: newQuoteLst) {
                qt.SBQQ__Primary__c = true;
            } 
        }
        else {
            for( SBQQ__Quote__c qt: newQuoteLst ) { 
                if( !String.IsBlank( congaQuoteId ) )                
                {   
                    qt.conga_quote_template_id__c = congaQuoteId ; 
                    
                } 
                if( !String.IsBlank( congaContractId ) ) 
                {  
                    qt.conga_contract_template_id__c = congaContractId ;
                }
                if(qt.Online_Opportunity_Quote_Check__c && !String.IsBlank( congaAlternatetermconditionId ))
                {
                    qt.term_conditionIds__c = congaAlternatetermconditionId;
                }
                else if(!String.IsBlank( congatermconditionId ))
                {
                    qt.term_conditionIds__c = congatermconditionId;
                }
                 if(qt.Mixed_Product_Term_Check__c ){
                   qt.term_conditionIds__c=mixedtermsConditon;
                }
                
                if( isInsert && isBefore ) {   qt.Version__c=1; }
            }
        }
    } 
}