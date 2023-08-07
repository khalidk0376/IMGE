/**
 * Created By: Girikon(Archit, Bappi)
 * Created On:  07/06/2017
 * Modified by : Girikon(Bappi)
 * Modified On: 
 * Description/Purpose: This class is used to parse the content of email for sending the email
 * Test Class:    ParsePlaceholders_Test(91%)
**/

public class ParsePlaceholders {
   
    //Creating query behelf of sObject.
    private static Map<String,String> getRecordsObject(List<String> lstFieldName,String objectName,String EventId,String objectRecordId)
    {
        Map<String,String> mapFieldValue = new Map<String,String>();
        Id CrrentUserId = UserInfo.getUserId();
        String query = 'select ' +  string.join(lstFieldName,',') +' from ' + objectName ; 
        if(objectName =='User'){
           query += ' where Id = :CrrentUserId ';
        }
        else if(objectName =='Event_Edition__c')
        {
            query += ' where Id = :EventId ';
        }
        else if(objectRecordId != null && String.isNotBlank(objectRecordId)&& objectName !='Organization')
        {
            query += ' where Id = :objectRecordId';
        }
        List<sObject> lstObj = Database.query(query);
        if(lstObj != null && lstObj.size()>0)
        {
            sObject obj = lstObj[0];
            for(String sFieldName: lstFieldName)
            {
                mapFieldValue.put('{'+objectName+'.'+sFieldName+'}',String.valueOf(obj.get(sFieldName)));
            }
        }
        return mapFieldValue;
    }
    
    //Creating query behelf of sObject.
    private static Map<String,String> getRecordsObject(List<String> lstFieldName,String objectName,String EventId)
    {
        Map<String,String> mapFieldValue = new Map<String,String>();
        Id CrrentUserId = UserInfo.getUserId();
        String query = 'select ' +  string.join(lstFieldName,',') +' from ' + objectName ; 
        if(objectName =='User'){
           query += ' where Id = :CrrentUserId ';
        }
        if(objectName =='Event_Edition__c')
        {
            query += ' where Id = :EventId ';
        }
        List<sObject> lstObj = Database.query(query);
        if(lstObj != null && lstObj.size()>0)
        {
            sObject obj = lstObj[0];
            for(String sFieldName: lstFieldName)
            {
                mapFieldValue.put('{'+objectName+'.'+sFieldName+'}',String.valueOf(obj.get(sFieldName)));
            }
        }
        return mapFieldValue;
    }
    
    //Finding Field in Context(Template).
    private static Map<String,Set<String>> findObjOfFields(String sContext)
    {
        Map<String,Set<String>> mapObjectField = new Map<String,Set<String>>();
        List<String> parts = sContext.split('\\{');
        for(String sText: parts)
        {
            Pattern ptrn = Pattern.compile('\\{[a-zA-Z0-9_.]*\\}'); 
            Matcher matcher = ptrn.matcher('{'+sText);
            if(matcher.find()){
                if(sText.indexOf('}')>-1){
                    Set<String> lstField = new Set<String>();
                    if(sText.indexOf('.')>-1){
                        List<String> lstPartOfObject= sText.split('\\.');
                        if(lstPartOfObject != null && lstPartOfObject.size()>0)
                        {
                            if(mapObjectField.containsKey(lstPartOfObject[0]))
                            {
                                lstField = mapObjectField.get(lstPartOfObject[0]);
                            }
                            String str = lstPartOfObject[1];
                            List<STring> sfieldVal = str.split('}');
                            lstField.add(sfieldVal[0]);
                            mapObjectField.put(lstPartOfObject[0],lstField);
                        }
                    }
                }      
            }
        }
        return mapObjectField;
    }
    public static string removeString(String val){
        String str = val.removeStart('{').removeEnd('}');
        list<string> strLst = str.split('\\.');
        return strLst[1]; 
    }
    
    public static string renderTemplate(String sContext,String EventId){
        Map<String,Set<String>> mapField = findObjOfFields(sContext);
        if(mapField != null && mapField.size()>0)
        {
            for(String key:mapField.Keyset())
            {
                List<String> lstFieldName = new List<String>(mapField.get(key));
                Map<String,String> mapFieldValue =getRecordsObject(lstFieldName,key,EventId);
                if(mapFieldValue != null && mapFieldValue.size()>0)
                {
                    sContext = addValue(sContext,mapFieldValue);
                }
            }
        }
        return sContext;
    }
    
    public static string renderTemplate(String sContext,String EventId,String objectRecordId){
        Map<String,Set<String>> mapField = findObjOfFields(sContext);
        if(mapField != null && mapField.size()>0)
        {
            for(String key:mapField.Keyset())
            {
                List<String> lstFieldName = new List<String>(mapField.get(key));
                Map<String,String> mapFieldValue =getRecordsObject(lstFieldName,key,EventId,objectRecordId);
                if(mapFieldValue != null && mapFieldValue.size()>0)
                {
                    sContext = addValue(sContext,mapFieldValue);
                }
            }
        }
        return sContext;
    }
    
    private static string addValue(String sContext,Map<String,String> mapFieldValue)
    {
        if(mapFieldValue != null && mapFieldValue.size()>0)
        {
            for(String keyField: mapFieldValue.Keyset())
            {
                System.debug('Test replace'+keyField+'  '+mapFieldValue.get(keyField));
                if(mapFieldValue.ContainsKey(keyField) && mapFieldValue.get(keyField)!=null)
                    sContext = sContext.replace(keyField, mapFieldValue.get(keyField));
                
            }
        }
        
        return sContext;
        
    }
    
}