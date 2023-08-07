/**
 * Created/Modified By: Girikon(Mahesh/Divaker)
 * Created On:          26 Apr 2018
 * Description/Purpose: Using for Lookup in Form Builder 
 * Test Class:   LookupCtrl_Test 
 * Code Coverage: 100%
 *  History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020
**/
public class LookupCtrl {
    /**
     * FLS Check DONE
     * @sobjectName - Name of SObject
     * @field_API_Text - API name of field to display to user while searching
     * @field_API_ID - API name of field to be returned by Lookup COmponent
     * @limit   - Total number of record to be returned
     * @field_API_Search - API name of field to be searched
     * @searchText - text to be searched
     * Returns JSON of list of LookupWrapper to Lookup Components
     * */
    @AuraEnabled 
    public static String searchDB(String sobjectName, String field_API_Name, String field_ID,String searchTexts ){
        List<LookupWrapper> lstLookup = new List<LookupWrapper>();
        string searchText = String.escapeSingleQuotes(searchTexts);
        searchText='\'%' + searchText.trim() + '%\'';
        SObjectType schemaType = ((SObject)Type.forName(sobjectName).newInstance()).getSObjectType();
        Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
        if (fields.get(field_API_Name).getDescribe().isAccessible()){
            String query = 'SELECT ' + String.escapeSingleQuotes(field_ID)+','+String.escapeSingleQuotes(field_API_Name)+ ' FROM ' + String.escapeSingleQuotes(sobjectName) +' WHERE '+String.escapeSingleQuotes(field_API_Name)+' LIKE '+ searchText + ' LIMIT 10';
            List<sObject> sobjList = Database.query(query);
            for(SObject s : sobjList){
                LookupWrapper obj = new LookupWrapper();
                obj.text = String.valueOf(s.get(field_API_Name)) ;
                obj.val = String.valueOf(s.get(field_ID))  ;
                lstLookup.add(obj);
            } 
        }
        return JSON.serialize(lstLookup) ;
    }
    /**
     * wrapper class for lookup
     */

    public class LookupWrapper{
        public String text{get;set;}
        public String val{get;set;}
    }

}