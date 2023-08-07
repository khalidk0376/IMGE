/**
 * File:        addTermConditions.cls
 * Project:     GAP
 * Date:        9/8/2017
 * Created By:  Abdul Kadir
 * *************************************************************************
 * Description: This class purpose to add Quote term and conditions on the basis of Quote_term_identifier field availsble on Event Edition.
 * *************************************************************************
 * History: Last Modified By :   [Aishwarya BK-3759 27 Aug 2020] - Modified By Rajesh Kr - 25-01-2021 FOR BK-12717
 */
public without sharing class addTermConditions{
    
    /**
   * @description Add term & conditions ids to the Quote on the basis of Identifier.
   * @param 
   * @return string
   */
    public static void TandC(List<SBQQ__Quote__c> quoteIdList ) {
        set<String> productType = new set<String>();
        set<String> EventEditionType = new set<String>();
        Set<String> quoteTermIdentifier= new Set<String>();
        Map<String,SBQQ__Quote__c> quoteObjWithIdentifierMap = new Map<String,SBQQ__Quote__c>();
        list<SBQQ__QuoteTerm__c> quotetermIdList = new list<SBQQ__QuoteTerm__c>();
        Map<String,String> quotetermIdFullMap = new Map<String,String>();
        list<SBQQ__QuoteTerm__c> quoteSubtermIdList = new list<SBQQ__QuoteTerm__c>();
        Set<ID> listOfQtProduct=new Set<ID>();
        Set<ID> listOfQtEE=new Set<ID>();
        Set<ID> listOfFinalQt=new Set<ID>();
        Map<String,String> quoteTermIdCongaTemplateMap = new  Map<String,String>();
       // SBQQ__Quote__c quoteObj = [select id,name,Quote_Terms_Identifier__c,(select id,name,Event_Product_Type__c from  SBQQ__QuoteLine__c) from SBQQ__Quote__c where id=:quoteId];
        List<SBQQ__QuoteLine__c> QuoteLineList=[select id,name,Event_Product_Type__c,SBQQ__Quote__r.Quote_Terms_Identifier__c from  SBQQ__QuoteLine__c where SBQQ__Quote__c IN: quoteIdList];
        for(SBQQ__Quote__c objQuote:quoteIdList){  
            quoteObjWithIdentifierMap.put(objQuote.Quote_Terms_Identifier__c,objQuote);
            quoteTermIdentifier.add(objQuote.Quote_Terms_Identifier__c); 
        }
        for(SBQQ__QuoteLine__c objQuoteLine:QuoteLineList){
            productType.add(objQuoteLine.Event_Product_Type__c);
            quoteTermIdentifier.add(objQuoteLine.SBQQ__Quote__r.Quote_Terms_Identifier__c); 
        }
        if(quoteTermIdentifier!=null){
            Set<ID> listOfQuoteTermIds = new Set<ID>();
            quotetermIdList=[Select id,Event_Identifier__c from SBQQ__QuoteTerm__c where Event_Identifier__c IN : quoteTermIdentifier];
            if(quotetermIdList!=null && quotetermIdList.size()> 0){
                quoteSubtermIdList=[Select id,Event_Identifier__c from SBQQ__QuoteTerm__c where SBQQ__ParentTerm__c IN : quotetermIdList];
                list<SBQQ__QuoteTerm__c> finalListOfQuoteTerms = new list<SBQQ__QuoteTerm__c>(quotetermIdList);
                finalListOfQuoteTerms.addAll(quoteSubtermIdList);
                for(SBQQ__QuoteTerm__c tempObj : finalListOfQuoteTerms){
                    if(quoteObjWithIdentifierMap.containsKey(tempObj.Event_Identifier__c)){
                        quotetermIdFullMap.put(tempObj.Event_Identifier__c,tempObj.Id);
                    }
                    listOfQuoteTermIds.add(tempObj.Id);   
                }
                if(!listOfQuoteTermIds.isEmpty()){
                    List<SBQQ__TermCondition__c> TandCList = [select id,name,Conga_Template__c,SBQQ__TestedVariable__r.SBQQ__FilterValue__c,SBQQ__QuoteTerm__c from SBQQ__TermCondition__c where SBQQ__QuoteTerm__c IN : listOfQuoteTermIds];
                    If(TandCList.size() > 0){
                        for(SBQQ__TermCondition__c obj:TandCList){
                            if(productType.contains(obj.SBQQ__TestedVariable__r.SBQQ__FilterValue__c)){
                                listOfQtProduct.add(obj.Conga_Template__c);                    
                            }
                            if(quoteTermIdentifier.contains(obj.SBQQ__TestedVariable__r.SBQQ__FilterValue__c)){
                                listOfQtEE.add(obj.Conga_Template__c);
                                quoteTermIdCongaTemplateMap.put(obj.SBQQ__QuoteTerm__c,obj.Conga_Template__c);
                            }
                        }    
                    }
                   
                    if(listOfQtProduct!=null && listOfQtProduct.size()>0) {
                        listOfFinalQt.addAll(listOfQtProduct);
                        
                    }
                    if(listOfQtEE!=null && listOfQtEE.size()>0){
                        listOfFinalQt.addAll(listOfQtEE);
                    }
                    
                    String listOfTermCondtnIds='';
                    if(!listOfFinalQt.isEmpty()){
                        String congaTemplateIdentifire='';
                        List<APXTConga4__Conga_Template__c>  congaTemplatesList= [select id from APXTConga4__Conga_Template__c where id in:listOfFinalQt ];
                        for(String quoteIdentifier :quoteObjWithIdentifierMap.keySet()){
                            congaTemplateIdentifire=quoteTermIdCongaTemplateMap.get(quotetermIdFullMap.get(quoteIdentifier));
                            for(APXTConga4__Conga_Template__c congaTemplates : congaTemplatesList){
                                listOfTermCondtnIds+=congaTemplates.id+',';                
                            }
                            //listOfTermCondtnIds=listOfTermCondtnIds.removeend(','); //split(',')[0]
                            listOfTermCondtnIds=listOfTermCondtnIds.split(',')[0];
                            if(listOfTermCondtnIds!=null && congaTemplateIdentifire!=null){
                                if(listOfTermCondtnIds.contains(congaTemplateIdentifire)){
                                    quoteObjWithIdentifierMap.get(quoteIdentifier).term_conditionIds__c=listOfTermCondtnIds;
                                }
                            }       
                        }
                    }
                }
            }
        }
    }   
}