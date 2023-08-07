/**
* File:        ProdcutDateUpdateClass.cls
* Project:     GAP
* Date :      3/2/2017 3:35 AM
* Created By:  Rajesh Girikon
* Test Class:  ProdcutDateUpdateClass_Test
* *************************************************************************
* @Description We are updating start date and End Date from Event Edition .
*
* *************************************************************************
* History:
*/
//@Description Class to update product start date and end date.
public class ProdcutDateUpdateClass{

    //@Description Variable declaration.
    public String sEventId{get;set;}
    
    //@Description Constructor Defined.
    public ProdcutDateUpdateClass(ApexPages.StandardController controller) {
        if (ApexPages.currentPage().getParameters().get('id') != null) {
            sEventId= ApexPages.currentPage().getParameters().get('id');
        }
    }
    
    //@Description Constructor Defined.
    public ProdcutDateUpdateClass() {system.debug('This defines constructor.');}
    
    //@Description Page reference type method.
    public pagereference autoRedirect(){
        if(String.IsNotBlank(sEventId)){
            Event_Edition__c lstEventEdition = [Select id , Name , Start_Date__c , End_Date__c from Event_Edition__c where Id = :  sEventId Limit 1];
            if(lstEventEdition.Start_date__c!=null && lstEventEdition.END_Date__c!=null){
                UpdateProductStartDateEndDate_Batch productDateUpdatebatch = new UpdateProductStartDateEndDate_Batch( lstEventEdition.Id , lstEventEdition.Start_date__c , lstEventEdition.END_Date__c );
                Database.executeBatch( productDateUpdatebatch, 1 );                
            }
        }
        return new pageReference('/' + sEventId);
    }
}