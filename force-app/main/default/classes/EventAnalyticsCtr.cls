/**
 * Created By       :   Girikon(Mukesh[STL-74])
 * Created On       :   00/20/2019
 * @description     :   This controller used to get aggregate data.
 * Test Class       :   EventAnalyticsCtr_Test(97%)
 * Modified by      :   Yash Gupta [10/22/2019]
*   History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020
 **/
 
public with sharing class EventAnalyticsCtr {
    /*
    * Variables Declaration
    */  
    @AuraEnabled
    public integer offst;    
    @AuraEnabled
    public integer total;    
    @AuraEnabled
    public boolean hasprev;    
    @AuraEnabled
    public boolean hasnext;    
    
    /*
    * @description [return true if offset greater than 0 otherwise false]
    * @param off [offset]
    * @return [true/false]
    */
    public static boolean hasprevious(integer off){ if(off>0){return false;}else{return true;}}
    
    /*
    * @description [this method check whether offset less than total record]
    * @param off [offset]
    * @param li [total rows return by query]
    * @param ps [pagesize]
    * @return [true/false]
    */
    public static boolean hasnxt(integer off,integer li,integer ps){
        if((off+ps)>2000){return true;} else if((off+ps) < li) {return false;} else { return true;}
    }
    
    /*
    * @description [this method used to fetch the data based on record Id and order type and the searhc value]
    * @param recordId [Record Id]
    * @param orderType [Order Type]
    * @param ps [pagesize]
    * @param off [offset]
    * @param searchValue [searchValue]
    * @param prev [prev]
    * @param next [next]
    * @return [Map<String,Object>]
    */
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getDatas(string recordId,String orderType,Decimal pageSize,Decimal off,String searchValue,boolean next,Boolean prev){
        Integer offset = (Integer)off;
        Integer psize = (Integer)pageSize;    
        String sortQuery='';
        if(orderType!=''){
            sortQuery = 'ORDER BY Event_Series__r.Name '+orderType;
        }
        /** Added/Modified By Rajesh Kumar : BK-5121 on Date - 08-06-2020  */ 
        if (searchValue != '' && searchValue != null ){
            searchValue = String.escapeSingleQuotes(searchValue);
        }
        /** END Added/Modified By Rajesh Kumar : BK-5121 on Date - 08-06-2020  */        
        if(searchValue!=''){
            searchValue = ' AND Event_Series__r.Name LIKE \'%'+searchValue+'%\'';
        }

        List<AggregateResult> totalRows = Database.query('Select Event_Series__r.Name,Event_Series__c,Count(Id) From Opportunity WHERE AccountId=:recordId AND Event_Series__c !=\'\' '+searchValue+' group by Event_Series__c,Event_Series__r.Name');
        String query = '';
        Integer listlength = totalRows.size();
        if(next==false && prev==false){
            query = 'Select Event_Series__r.Name,Event_Series__c,Count(Id) From Opportunity WHERE AccountId=:recordId AND Event_Series__c!=\'\' '+searchValue+' group by Event_Series__c,Event_Series__r.Name '+ sortQuery +' LIMIT '+psize+' OFFSET '+offset;
        } else if(next==true && offset<=listlength){
            query = 'Select Event_Series__r.Name,Event_Series__c,Count(Id) From Opportunity WHERE AccountId=:recordId AND Event_Series__c!=\'\' '+searchValue+' group by Event_Series__c,Event_Series__r.Name '+ sortQuery +' LIMIT '+psize+' OFFSET '+offset;
        } else if(prev==true && offset>=0){
            query = 'Select Event_Series__r.Name,Event_Series__c,Count(Id) From Opportunity WHERE AccountId=:recordId AND Event_Series__c!=\'\' '+searchValue+' group by Event_Series__c,Event_Series__r.Name '+ sortQuery +' LIMIT '+psize+' OFFSET '+offset;
        }
        
        /**
        * @description [We need check the query every time that has been generated dynamically]
		*/
        List<AggregateResult> eventSeriesList = Database.query(query);
        return new Map<String,Object>{
            'eventSeriesList' => eventSeriesList,
            'oppList' => getOpportunity(recordId,eventSeriesList),
            'oppProductFamily' => getOppProductFamily(recordId),
            'offst'=>offset,
            'hasprev'=>hasprevious(offset),
            'hasnext'=>hasnxt(offset,listlength,psize),
            'total'=>listlength
        };
    }
    
    /*
    * @description [this method aggregated data from opportunity based on accountId and event series]
    * @param recordId [AccountId]
    * @param eventSeriesList [eventSeriesList (AggregateResult)]
    * @return [List<AggregateResult>]
    */
    private static List<AggregateResult> getOpportunity(String recordId, List<AggregateResult> eventSeriesList){
        Set<Id> eventIds = new Set<Id>();
        for(AggregateResult ar: eventSeriesList){
            eventIds.add(String.valueOf(ar.get('Event_Series__c')));
        }
        return [Select Event_Series__c,EventEdition__c,EventEdition__r.Name,Sum(Amount) 
                from Opportunity
                WHERE AccountId=:recordId 
                AND Event_Series__c IN:eventIds 
                Group By EventEdition__c,Event_Series__c,EventEdition__r.Name];
    }
    
    /*
    * @description [this method aggregated data from opportunity based on accountId]
    * @param recordId [AccountId]
    * @return [List<AggregateResult>]
    */
    private static List<AggregateResult> getOppProductFamily(String recordId){
        Map<Id,Opportunity> oppList = new Map<Id,Opportunity>([Select Id 
                                                               from Opportunity 
                                                               WHERE AccountId=:recordId]);
        return [Select Opportunity.EventEdition__c,Product2.Family,Opportunity.EventEdition__r.Name,SUM(TotalPrice)
                from OpportunityLineItem
                WHERE OpportunityId IN:oppList.keySet() 
                AND Opportunity.AccountId=:recordId 
                Group By Opportunity.EventEdition__r.Name,Product2.Family,Opportunity.EventEdition__c];
    }
}