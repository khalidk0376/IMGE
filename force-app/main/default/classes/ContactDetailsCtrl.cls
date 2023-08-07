/**
 * Created By       :   Girikon(Sunil)
 * Created On       :   Mar 13 2019
 * @description     :   This class is used in Contact details ltng component.          
 * Test Class       : 	ContactDetailsCtrl_Test
 
 * Modification log --
 * Modified by      :   Girikon(Sunil)[LTN-32 (Mar 17 2019)]
 **/
public with sharing class ContactDetailsCtrl {
    /**
     * @description [Fetch records list]
     * @param  objName     [Object api name]
     * @param  objName     [Object api name]
     * @param  fieldNames  [fields api name( comma separated)]
     * @param  compareWith [Compare field api name]
     * @param  recordId    [Record Id]
     * @param  pageNumber  [Page Number]
     * @param  pageSize    [Page Size]
     * @return             [List of sObject]
     */
    @AuraEnabled
    public static LtngUtilityCtrl.RecordDataTableWrapper getRecords(string objName ,string fieldNames ,string compareWith,string recordId , Decimal pageNumber, Decimal pageSize) {
        return LtngUtilityCtrl.getRecords(objName,fieldNames,compareWith,recordId,pageNumber,pageSize); 
    }  
    /**
    * @description [Fetch ureent user details]
    * @return [user record]
    */
	@AuraEnabled
	public static user getCurrentUserDtls() {
		return OpportunityDetailsCtrl.getCurrentUserDtls();
	}
}