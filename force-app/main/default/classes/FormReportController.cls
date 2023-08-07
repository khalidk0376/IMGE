/**
 * Created By       :   Girikon(Sunil )
 * Created On       :   12 sep 2019
 * @description     :   to get customize data for form report tab under customer center .
 * Test Class       :   FormReportCtrl_Test(100%)
 * Modification log --
 * Modified by      :   
 **/

public class FormReportController {
     @AuraEnabled(Cacheable=true)
    public static FormDataTableWrapper searchForm(Decimal pageNumber,Decimal pageSize, String searchTxt) {
        String searchKey = '%'+searchTxt + '%';
        system.debug('----------pageSize'+pageSize+'    '+pageNumber);
        Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
        Integer totalRecords = [SELECT COUNT() FROM Account];
        //Offset for SOQL
        Integer offset = (pNumber - 1) * 10;
        FormDataTableWrapper objDT =  new FormDataTableWrapper(); 
        objDT.totalRecords=totalRecords;
        objDT.formList =[SELECT Id,Event_Edition_Form__r.Name,Event_Edition_Form__r.Mandatory__c,Event_Edition_Form__r.FormType__c,Total_User_Viewed__c,Total_User_Count__c,Total_User_Filled_Up__c FROM Forms_Permission__c where (Event_Edition_Form__r.Name LIKE: searchKey)  LIMIT :pSize OFFSET :offset];
        //acc.total_Rec=totalRecords
        return objDT;    
    }
 public class FormDataTableWrapper {
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public List<Forms_Permission__c> formList {get;set;}
    }
}