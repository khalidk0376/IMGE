/**
* File:        UpdateProductStartDateEndDate_Batch
* Project:     GAP
* Date :       10/1/2019
* Created By:  Rajesh Kumar
* Test Class:  ProdcutDateUpdateClass_Test
* *************************************************************************
* @Description We are updating start date and End Date from Event Edition .
*
* *************************************************************************
* History:
*/

//@Description Batchable Class
public class UpdateProductStartDateEndDate_Batch implements  Database.Batchable <sobject> , Database.Stateful {
    
    list<Product2> lstProdcuts;
    private String sQUERY = null;
    Date dStartDates = null;
    Date dEndDates = null;
    String sEventIds = '';
    
    //@Description Constructor Defined
    public UpdateProductStartDateEndDate_Batch (String sEventid , Date startDate , Date EndDate){
        this.sEventIds = sEventid;
        this.dStartDates = startDate;
        this.dEndDates = EndDate;
        lstProdcuts = new  list<Product2>();
        sQUERY = 'SELECT Id , Name , Start_Date__c , End_Date__c , Event_Edition__c from Product2 where  Event_Edition__c =  \'' + sEventIds + '\'';
    }
    
    //@Description Get query using Database.QueryLocator
    public Database.QueryLocator start(Database.BatchableContext batchcontext){
        return Database.getQueryLocator(sQUERY);
    }
    
    //@Description Implement Core functionality
    public void execute (Database.BatchableContext batchcontext , List<Product2> scope){
        for (Product2 oprod2 : (List<Product2>)scope) {
            oprod2.Start_Date__c = dStartDates ;
            oprod2.End_Date__c = dEndDates;
            lstProdcuts.add(oprod2);
        }
    }
    
    //@Description update product in finish method
    public void finish (Database.BatchableContext batchcontext){
        if (lstProdcuts.size() > 0){
            update lstProdcuts;
        }
    }
    
}