/**
 * Created By       :   Girikon(Mukesh[STL-4])
 * Created On       :   07/23/2019
 * @description     :   Used by LWC Generic table Components. This class provides following functionalities: Allow to fetch record based on dynamic object and field. This class used by common-table component(LWC)
 * Test Class       :   CommonTableController_Test(88%)
 * Modified by      :   Girikon(Mukesh)[Yash Gupta 12th Aug 2019, Remove violations], Mukesh Gupta[Fixed Sorting Issues]
 **/

public class CommonTableController {
    
    /*
    * Variables Declaration
    */
    @AuraEnabled
    public LightningTableWraper ltngTabWrap;     
    @AuraEnabled
    public integer offst;    
    @AuraEnabled
    public integer total;
    @AuraEnabled
    public decimal aggregateAmount;
    @AuraEnabled
    public boolean hasprev;    
    @AuraEnabled
    public boolean hasnext;    
    
    /*
    * @description [method return true if offset greater than 0 otherwise false]
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
        if((off+ps)>2000){
            return true;
        } else if((off+ps) < li) {
            return false;
        } else { 
            return true;
        }
    }
    /*
    * @description [this method get record for any object it is depends on parameter you have passed]
    * @param searchValue [send searchbox value on common-table component]
    * @param objectName [Pass object api name]
    * @param condition [pass condition if any recquired otherwise set default to id!='']
    * @return [object of CommonTableController]
    */
    @AuraEnabled(cacheable=false)
    public static CommonTableController getGenericObjectRecord(String searchValue, String objectName,String fieldstoget,Decimal pagesize,boolean next,boolean prev,Decimal off,String sortBy,String sortType, String condition,Boolean isAggregate){
        String sv = searchValue; // used original search value in includes query
        CommonTableController pg = new CommonTableController();
        Integer offset = (Integer)off;
        if(offset==-1){
            offset = 0;
        }
        Integer psize = (Integer)pagesize;    
        String innerQuery = '';
        List<String> fieldsAndInnerQuery  = fieldstoget.split(',\\(');
        List<String> lstfieldstoget = fieldsAndInnerQuery[0].split(',');
        if(fieldsAndInnerQuery.size()==2){
            innerQuery = fieldsAndInnerQuery[1];
            innerQuery = ',('+innerQuery;
        }

        Integer listlength = 0;
        List<lightningTableColumnWrapper> lstTableColumn = new list<lightningTableColumnWrapper> ();        
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe();
        lightningTableColumnWrapper colWrapper;
        DescribeFieldResult fieldResult;
        Map<String,Map<String,String>> typeAndLabelMap = new Map<String,Map<String,String>>();
        String fieldToQuery='';        
        for(String field : lstfieldstoget){
            if(objResult.fields.getMap().containsKey(field)){
                colWrapper = new lightningTableColumnWrapper();
                fieldResult = objResult.fields.getMap().get(field).getDescribe();
                colWrapper.label = fieldResult.getLabel();
                colWrapper.fieldName = fieldResult.getName();
                colWrapper.type = String.valueof(fieldResult.getType()).toLowerCase();
                if((colWrapper.type=='picklist' || colWrapper.type=='multipicklist') && colWrapper.fieldName.toLowerCase()!='currencyisocode'){
                    fieldToQuery += fieldToQuery ==''?'toLabel('+field+')':',toLabel('+field+')';
                } else if(colWrapper.type=='currency'){
                    fieldToQuery += fieldToQuery ==''?'FORMAT('+field+')':',FORMAT('+field+')';
                } else{
                    fieldToQuery += fieldToQuery ==''?field:','+field;
                }
                colWrapper.sortable = true;
                lstTableColumn.add(colWrapper);
            } else {
                typeAndLabelMap.put(field,getFieldType(objectName,field));
                colWrapper = new lightningTableColumnWrapper();                
                colWrapper.label = typeAndLabelMap.get(field).get('field_label');
                colWrapper.fieldName = field;
                colWrapper.type = typeAndLabelMap.get(field).get('field_type');
                colWrapper.sortable = true;
                if((colWrapper.type=='picklist' || colWrapper.type=='multipicklist') && colWrapper.fieldName.toLowerCase()!='currencyisocode'){
                    fieldToQuery += fieldToQuery ==''?'toLabel('+field+')':',toLabel('+field+')';
                } else if(colWrapper.type=='currency'){
                    fieldToQuery += fieldToQuery ==''?'FORMAT('+field+')':',FORMAT('+field+')';
                } else{
                    fieldToQuery += fieldToQuery ==''?field:','+field;
                }
                lstTableColumn.add(colWrapper);
            }
        }
        String sortQuery = '';
        if(sortBy!='' && sortType!=''){
            sortQuery = ' Order By '+String.escapeSingleQuotes(sortBy)+' '+String.escapeSingleQuotes(sortType)+' NULLS LAST ';
        }
        if(!schema.sobjecttype.Contact.isaccessible()){return new CommonTableController();}

        else{
            String queryString = '';
            String wh = '';
            //Modified By Rajesh Kumar -BK-5121 on 11-06-2020
            if(String.isNotBlank(condition)){
                condition = condition.replaceAll('&lt;','<');
                condition = condition.replaceAll('&gt;','>');
                wh = ' WHERE '+condition;
            }
            String fieldType='string';
            if(searchValue.trim()!='' && wh == ''){
                wh = ' WHERE ';
                Boolean isAddedInQuery = false;
                searchValue = string.escapeSingleQuotes(searchValue);
                searchValue ='%'+searchValue+'%';
                
                for(String field : lstfieldstoget){
                    fieldType='string';
                    if(objResult.fields.getMap().containsKey(field)){
                        fieldResult = objResult.fields.getMap().get(field).getDescribe();
                        fieldType = String.valueof(fieldResult.getType()).toLowerCase();
                    } else{                        
                        fieldType = typeAndLabelMap.get(field).get('field_type');
                    }
                    if(isAddedInQuery == false){
                        if(fieldType=='boolean' && (sv.toLowerCase()=='true'||sv.toLowerCase()=='false')){
                            wh = wh + String.escapeSingleQuotes(field)+' = '+sv;
                            isAddedInQuery = true;
                        } else if(fieldType.toLowerCase()=='string' || fieldType.toLowerCase()=='picklist' || fieldType.toLowerCase()=='url'){
                            wh = wh + String.escapeSingleQuotes(field)+' LIKE \''+searchValue+'\' ';    
                            isAddedInQuery = true;
                        } else if(fieldType=='multipicklist'){
                            wh = wh +String.escapeSingleQuotes(field)+' Includes (\''+sv+'\') ';
                            isAddedInQuery = true;
                        }
                    } else {
                        if(fieldType=='boolean' && (sv.toLowerCase()=='true'||sv.toLowerCase()=='false')){
                            wh = wh + ' OR '+String.escapeSingleQuotes(field)+' = '+sv;
                        } else if(fieldType=='string' || fieldType.toLowerCase()=='picklist' || fieldType.toLowerCase()=='url'){
                            wh = wh + ' OR '+String.escapeSingleQuotes(field)+' LIKE \''+searchValue+'\' ';    
                        } else if(fieldType=='multipicklist'){
                            wh = wh + ' OR '+String.escapeSingleQuotes(field)+' Includes (\''+sv+'\') ';
                        }
                    }
                }
            } else if(searchValue.trim()!='' && wh != ''){
                Boolean isAddedInQuery = false;
                searchValue = string.escapeSingleQuotes(searchValue);
                searchValue ='%'+searchValue+'%';
                wh = wh+ ' AND (';
                for(String field : lstfieldstoget){
                    fieldType='string';
                    if(objResult.fields.getMap().containsKey(field)){
                        fieldResult = objResult.fields.getMap().get(field).getDescribe();
                        fieldType = String.valueof(fieldResult.getType()).toLowerCase();
                    } else {
                        fieldType = typeAndLabelMap.get(field).get('field_type');
                    }
                    if(isAddedInQuery==false){
                        if(fieldType=='boolean' && (sv.toLowerCase()=='true'||sv.toLowerCase()=='false')){
                            wh = wh + String.escapeSingleQuotes(field)+' = '+sv;
                            isAddedInQuery = true;
                        } else if(fieldType=='string' || fieldType.toLowerCase()=='picklist' || fieldType.toLowerCase()=='url'){
                            wh = wh + String.escapeSingleQuotes(field)+' LIKE \''+searchValue+'\' ';
                            isAddedInQuery = true;
                        } else if(fieldType=='multipicklist'){
                            wh = wh +String.escapeSingleQuotes(field)+' Includes (\''+sv+'\') ';
                            isAddedInQuery = true;
                        }
                    } else{
                        if(fieldType=='boolean' && (sv.toLowerCase()=='true'||sv.toLowerCase()=='false')){
                            wh = wh + ' OR '+String.escapeSingleQuotes(field)+' = '+sv;
                        } else if(fieldType=='string' || fieldType.toLowerCase()=='picklist' || fieldType.toLowerCase()=='url'){
                            wh = wh + ' OR '+String.escapeSingleQuotes(field)+' LIKE \''+searchValue+'\' ';
                        } else if(fieldType=='multipicklist'){
                            wh = wh + ' OR '+String.escapeSingleQuotes(field)+' Includes (\''+sv+'\') ';
                        }         
                    }
                }
                wh = wh +' ) ';
            }
            listlength = Database.countQuery('select count() from '+objectName+wh);
            
            if(next==false && prev==false){
                queryString = 'Select '+ String.escapeSingleQuotes(fieldToQuery)+' '+
                    innerQuery+ ' from '+ String.escapeSingleQuotes(ObjectName) + wh +' '+sortQuery+' Limit '+psize+' OFFSET '+offset;
            } else if(next==true && offset<=listlength){
                queryString = 'Select '+ String.escapeSingleQuotes(fieldToQuery)+' '+
                    innerQuery+ ' from '+ String.escapeSingleQuotes(ObjectName) + wh+' '+sortQuery+' Limit '+psize+' OFFSET '+offset;
            } else if(prev==true && offset>=0){
                queryString = 'Select '+ String.escapeSingleQuotes(fieldToQuery)+' '+
                    innerQuery+ ' from '+ String.escapeSingleQuotes(ObjectName) + wh+' '+sortQuery+' Limit '+psize+' OFFSET '+offset;
            }

            try{
                LightningTableWraper ltngTableWrapper = new LightningTableWraper();
                ltngTableWrapper.tableRecord = Database.query(queryString);
                ltngTableWrapper.tableColumn = lstTableColumn;
                pg.ltngTabWrap = ltngTableWrapper;
                pg.offst = offset;
                pg.hasprev = hasprevious(offset);   
                pg.hasnext = hasnxt(offset,listlength,psize); 
                pg.total = listlength;                
                if(isAggregate!=null && isAggregate==true && objectName=='SBQQ__QuoteLine__c'){
                    wh = wh + ' AND SBQQ__NetTotal__c!=0 AND SBQQ__NetTotal__c!=null';
                    List<sObject> aggRes = Database.Query('select convertCurrency(SBQQ__NetTotal__c) amount FROM SBQQ__QuoteLine__c '+wh);
                    Decimal sum = 0;
                    for (sObject record : aggRes){
                        sum += (Decimal)record.get('amount');
                    }
                    pg.aggregateAmount = sum;// Decimal.valueOf(String.valueOf(aggRes[0].get('expr0')));
                }
            } catch(Exception e){
                System.debug(e.getLineNumber()+','+e.getMessage());
            }
        }
        return pg;
    }    
    
    /*
    * @description [update sobject list record]
    * @param objList [list of sobject]
    * @return [all updated record size]
    */
    @AuraEnabled
    public static Integer massUpdateRecords(List<sObject> objList){        
        Integer recourdCount = objList.size();
        try{            
            update objList;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return recourdCount;
    }
    
    /*
    * @description [update sobject list record]
    * @param objList [list of sobject]
    * @return [all updated record size]
    */
    @AuraEnabled
    public static Integer massInsertRecords(List<sObject> objList){        
        Integer recourdCount = objList.size();
        try{
            insert objList;
        } catch(Exception e){
            if(!test.isRunningTest()){
                throw new AuraHandledException(e.getMessage());    
            }
        }
        return recourdCount;
    }

    /*
    * @description [wrapper class used in lightningTableWraper class]
    */
    public class lightningTableColumnWrapper {
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public String fieldName {get;set;}
        @AuraEnabled
        public string type {get;set;}
        @AuraEnabled
        public boolean sortable {get;set;}
        @AuraEnabled 
        public Boolean editable;
    }    
    
    /*
    * @description [wrapper class used to wrap data and return by getGenericObjectRecord() method]
    */
    public class lightningTableWraper{
        @AuraEnabled
        public List<sObject> tableRecord {get;Set;}
        @AuraEnabled
        public List<lightningTableColumnWrapper> tableColumn {get;set;}
    }
    
    /*
    * @description [get attachment from object by passing parentId]
    * @param objectName [object Name must be Attachment]
    * @param fields [must be Id]
    * @param parentId [All related object to attachment]    
    * @return [sObject list]
    */
    @AuraEnabled(cacheable=true)
    public static List<sobject> getFileDetail(String objectName,String fields,String parentId){
        return Database.query('Select '+String.escapeSingleQuotes(fields)+' from '+String.escapeSingleQuotes(objectName)+' WHERE ParentId=:parentId ORDER BY CreatedDate Desc LIMIT 1');
    }
    
    /**
     * We have used to view file from invoice BK-9736 Modified By - Rajesh Kumar - 30-10-2020
     */

    @AuraEnabled(cacheable=true)
    public static List<sobject> getFilePreview(String objectName,String fields,String parentId){
        return Database.query('Select '+String.escapeSingleQuotes(fields)+' from '+String.escapeSingleQuotes(objectName)+' WHERE LinkedEntityId =  : parentId ORDER BY ContentDocument.CreatedDate Desc LIMIT 1');
    }
    /**
     * We have used to view file from invoice BK-9736 Modified By - Rajesh Kumar - 30-10-2020
     */

    @AuraEnabled(cacheable=true)
    public static List<sobject> getFilePreviewLink(String objectName,String fields,String parentId){
        List<ContentVersion> lstcontentversion = new List<ContentVersion> ();
        String soql = 'Select '+String.escapeSingleQuotes(fields)+' from '+String.escapeSingleQuotes(objectName)+' WHERE LinkedEntityId =  : parentId ORDER BY ContentDocument.CreatedDate Desc LIMIT 1';
        List<ContentDocumentLink> lstContentDocumentLink = Database.query(soql);
        if (!lstContentDocumentLink.isEmpty()){       
            lstcontentversion = [SELECT Id, Title, PathOnClient, VersionData, OwnerId, ContentDocumentId FROM ContentVersion where ContentDocumentId =: lstContentDocumentLink[0].ContentDocumentId Order By LastModifiedDate Desc LIMIT 1 ];
        }         
        return lstcontentversion;
    }
    
    /*
    * @description [this method get aggregate result by passing field api name]
    * @param condition [condition that used in query]    
    * @param objectName [object api name]    
    * @param fieldName [single fields api name]
    * @return [List<AggregateResult>]
    */
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getAggregateData(String condition,String objectName,String fieldName){
        if(String.isNotBlank(condition)){
            condition = condition.replaceAll('&lt;','<');
            condition = condition.replaceAll('&gt;','>');
        }
        String toLabel = fieldName;
        fieldName = fieldName.replace('toLabel(','').replace(')', '');
        return Database.query('Select count(Id), '+String.escapeSingleQuotes(toLabel)+' from '+String.escapeSingleQuotes(objectName)+' WHERE '+condition+' Group BY '+String.escapeSingleQuotes(fieldName));
    }

    /*
    * @description [this method get aggregate result by passing field api name and it is not cacheable]
    * @param condition [condition that used in query]    
    * @param objectName [object api name]    
    * @param fieldName [single fields api name]
    * @return [List<AggregateResult>]
    */
    @AuraEnabled(cacheable=false)
    public static List<AggregateResult> getAggregateData2(String condition,String objectName,String fieldName){
        if(String.isNotBlank(condition)){
            condition = condition.replaceAll('&lt;','<');
            condition = condition.replaceAll('&gt;','>');
        }
        String toLabel = fieldName;
        fieldName = fieldName.replace('toLabel(','').replace(')', '');
        return Database.query('Select count(Id), '+String.escapeSingleQuotes(toLabel)+' from '+String.escapeSingleQuotes(objectName)+' WHERE '+condition+' Group BY '+String.escapeSingleQuotes(fieldName));
    }

    /*
    * @description [This method used to return total amount]
    * @param condition [condition that used in query]    
    * @param objectName [object api name]    
    * @param fieldName [single fields api name]
    * @return [List<AggregateResult>]
    */
    @AuraEnabled(cacheable=false)
    public static List<AggregateResult> getTotalAmount(String condition,String objectName,String fieldName){
        if(String.isNotBlank(condition)){
            condition = condition.replaceAll('&lt;','<');
            condition = condition.replaceAll('&gt;','>');
        }
        String toLabel = fieldName;
        fieldName = fieldName.replace('toLabel(','').replace(')', '');
        return Database.query('Select SUM(Amount), '+String.escapeSingleQuotes(toLabel)+' from '+String.escapeSingleQuotes(objectName)+' WHERE '+condition+' Group BY '+String.escapeSingleQuotes(fieldName));
    }

    /*
    * @description [Get record detail by passing object api name,comma seperated all fields api name and recordId]
    * @param objectName [set object api name]
    * @param allFields [comma seperated fields api name]
    * @param recordId [recordId]
    * @return [list of sObject]
    */
    @AuraEnabled(cacheable=true)
    public static List<sobject> getRecordDetail(String objectName,String allFields,String recordId){
        return Database.query('Select '+String.escapeSingleQuotes(allFields)+' from '+String.escapeSingleQuotes(objectName)+' WHERE Id=:recordId');
    }
    // Added by Palla Kishore for Ticket no EMEA-84
    @AuraEnabled(cacheable=true)
    public static List<SBQQ__QuoteLine__c> getQLRecords(string oppId, String searchKey){
        system.debug('SearchKey===='+searchKey);
        List<SBQQ__QuoteLine__c> getAllRecord = new List<SBQQ__QuoteLine__c>();
        if(String.isBlank(searchKey)){
            getAllRecord = [Select Id, SBQQ__Product__r.Name,SBQQ__Quantity__c,Booth_Number__c,Start_Date__c,End_Date__c,Event_Product_Type__c,Line_Description__c,SBQQ__NetTotal__c,SBQQ__Product__c,CurrencyIsoCode,FORMAT(SBQQ__NetTotal__c) formatedCurrency from SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.SBQQ__Opportunity2__c=:oppId AND SBQQ__Quote__r.SBQQ__Primary__c=true];
        }else
        {
            String key = '%' + searchKey + '%';
            getAllRecord = [Select Id, SBQQ__Product__r.Name,SBQQ__Quantity__c,Booth_Number__c,Start_Date__c,End_Date__c,Event_Product_Type__c,Line_Description__c,SBQQ__NetTotal__c,SBQQ__Product__c,CurrencyIsoCode,FORMAT(SBQQ__NetTotal__c) formatedCurrency from SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.SBQQ__Opportunity2__c=:oppId AND SBQQ__Quote__r.SBQQ__Primary__c=true AND SBQQ__Product__r.Name Like :key];
        }
       // getAllRecord = [Select Id, SBQQ__Product__r.Name,SBQQ__Quantity__c,Booth_Number__c,Start_Date__c,End_Date__c,Event_Product_Type__c,Line_Description__c,SBQQ__NetTotal__c,SBQQ__Product__c from SBQQ__QuoteLine__c LIMIT 50];
              
      return getAllRecord;
    }
     @AuraEnabled(cacheable=true)
    public static List<SBQQ__QuoteLine__c> getQLRecordsForBrazilTab(String oppId, String searchKey, string sapMatJs){
        List<SBQQ__QuoteLine__c> getAllRecordForBrazil = new List<SBQQ__QuoteLine__c>();
        if(String.isBlank(searchKey)){
         getAllRecordForBrazil = [Select Id, SBQQ__Product__r.Name,SBQQ__Quantity__c,SBQQ__NetPrice__c,SBQQ__Product__r.SAP_Material_Code__c,SBQQ__Product__r.SAP_Material_Code_Type__c,Booth_Number__c,Start_Date__c,End_Date__c,Event_Product_Type__c,Line_Description__c,SBQQ__NetTotal__c,SBQQ__Product__c,CurrencyIsoCode,FORMAT(SBQQ__NetTotal__c) formatedCurrency from SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.SBQQ__Opportunity2__c=:oppId AND SBQQ__Quote__r.SBQQ__Primary__c=true AND SBQQ__Product__r.SAP_Material_Code_Type__c =:sapMatJs];
        }
        else{
             String keys = '%' + searchKey + '%';
             getAllRecordForBrazil = [Select Id, SBQQ__Product__r.Name,SBQQ__Quantity__c,SBQQ__NetPrice__c,SBQQ__Product__r.SAP_Material_Code__c,SBQQ__Product__r.SAP_Material_Code_Type__c,Booth_Number__c,Start_Date__c,End_Date__c,Event_Product_Type__c,Line_Description__c,SBQQ__NetTotal__c,SBQQ__Product__c,CurrencyIsoCode,FORMAT(SBQQ__NetTotal__c) formatedCurrency from SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.SBQQ__Opportunity2__c=:oppId AND SBQQ__Quote__r.SBQQ__Primary__c=true AND  SBQQ__Product__r.SAP_Material_Code_Type__c =:sapMatJs AND SBQQ__Product__r.Name Like :keys];
        }
      return getAllRecordForBrazil;
    }

    /*
    * @description [Get record detail by passing object api name,comma seperated all fields api name and recordId]
    * @param objectName [set object api name]
    * @param allFields [comma seperated fields api name]
    * @param recordId [recordId]
    * @return [list of sObject]
    */
    @AuraEnabled(cacheable=false)
    public static List<sobject> getRecordDetail2(String objectName,String allFields,String recordId){
        return Database.query('Select '+String.escapeSingleQuotes(allFields)+' from '+String.escapeSingleQuotes(objectName)+' WHERE Id=:recordId');
    }

    /*
    * @description [Get record detail by passing object api name,comma seperated all fields api name and condition]
    * @param objectName [set object api name]
    * @param allFields [comma seperated fields api name]
    * @param condition [condition]
    * @return [list of sObject]
    */
    @AuraEnabled(cacheable=false)
    public static List<sobject> getRecordDetail3(String objectName,String allFields,String condition){
        return Database.query('Select '+String.escapeSingleQuotes(allFields)+' from '+String.escapeSingleQuotes(objectName)+' WHERE '+condition);
    }

    /*
    * @description [Delete all passed sobject list record]
    * @param objList [list of sobject]    
    * @return [all deleted record size]
    */
    @AuraEnabled
    public static Integer deleteRecord(List<sObject> objList){
        Integer recourdCount = objList.size();
        try{
            delete objList;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return recourdCount;
    }

    /*
    * @description [Get related field type]
    * @param objectName [object Api Name]
    * @return [relatedField like 'Manual_Permission__r.Manuals__r.Allow_Submit_After_Deadline__c']
    */
    public static Map<String,String> getFieldType(String objectName,String relatedField){
        String []fieldArr = relatedField.split('\\.');
        String object1;
        String relation1;
        String object2;
        String relation2;
        String object3;
        String relation3;
        String fieldName;
        String fieldType;
        String fieldLabel;
        Integer fieldCount = fieldArr.size();
        if(fieldCount>=2){            
            if(fieldCount==4){
                relation1 = fieldArr[fieldCount-4];
                relation2 = fieldArr[fieldCount-3];
                relation3 = fieldArr[fieldCount-2];
            }
            if(fieldCount==3){                
                relation1 = fieldArr[fieldCount-3];
                relation2 = fieldArr[fieldCount-2];
            }
            if(fieldCount==2){
                relation1 = fieldArr[fieldCount-2];
            }
            fieldName = fieldArr[fieldCount-1];
            try{
                for(Schema.SobjectField strFld: Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().Values()){
                    if(strFld.getDescribe().getType() == Schema.DisplayType.REFERENCE && strFld.getDescribe().getRelationshipName()!=null && strFld.getDescribe().getRelationshipName().toLowerCase()==relation1.toLowerCase()){
                        object1 = String.valueOf(strFld.getDescribe().getReferenceTo().get(0));                        
                        break;
                    }
                }
                if(object1!=null && relation2!=null){
                    for(Schema.SobjectField strFld: Schema.getGlobalDescribe().get(object1).getDescribe().fields.getMap().Values()){
                        if(strFld.getDescribe().getType() == Schema.DisplayType.REFERENCE && strFld.getDescribe().getRelationshipName()!=null && strFld.getDescribe().getRelationshipName().toLowerCase()==relation2.toLowerCase()){
                            object2 = String.valueOf(strFld.getDescribe().getReferenceTo().get(0));
                            break;
                        }
                    }   
                }
                if(object2!=null && relation3!=null){
                    for(Schema.SobjectField strFld: Schema.getGlobalDescribe().get(object2).getDescribe().fields.getMap().Values()){
                        if(strFld.getDescribe().getType() == Schema.DisplayType.REFERENCE && strFld.getDescribe().getRelationshipName()!=null && strFld.getDescribe().getRelationshipName().toLowerCase()==relation3.toLowerCase()){
                            object3 = String.valueOf(strFld.getDescribe().getReferenceTo().get(0));
                            break;
                        }
                    }   
                }
                SObjectType sObjectTypeObj = Schema.getGlobalDescribe().get(object3);
                if(sObjectTypeObj!=null){                    
                    fieldType = String.valueOf(sObjectTypeObj.getDescribe().fields.getMap().get(fieldName).getDescribe().getType());
                }
                if(fieldType==null){
                    sObjectTypeObj = Schema.getGlobalDescribe().get(object2);
                    if(sObjectTypeObj!=null){                        
                        fieldType = String.valueOf(sObjectTypeObj.getDescribe().fields.getMap().get(fieldName).getDescribe().getType());
                    }
                }
                if(fieldType==null){
                    sObjectTypeObj = Schema.getGlobalDescribe().get(object1);
                    if(sObjectTypeObj!=null){                        
                        fieldType = String.valueOf(sObjectTypeObj.getDescribe().fields.getMap().get(fieldName).getDescribe().getType());
                    }
                }

                fieldLabel = sObjectTypeObj.getDescribe().getLabel();
            }
            catch(Exception e){
                System.debug(e.getLineNumber()+',@@@:'+e.getMessage());
            }
        }
        if(fieldType!=null){
            fieldType = fieldType.toLOwerCase();
        }
        return new Map<String,String>{
            'field_type' => fieldType.toLOwerCase(),
            'field_label' => fieldLabel
        };
    }

    /*
    * @description [this method get record for any object it is depends on parameter you have passed]
    * @param searchValue [send searchbox value on common-table component]
    * @param objectName [Pass object api name]
    * @param condition [pass condition if any recquired otherwise set default to id!='']
    * @return [object of CommonTableController]
    */
    @AuraEnabled(cacheable=false)
    public static CommonTableController getAgreegatedObjectRecord(String searchValue,String eventId,Decimal pagesize,boolean next,boolean prev,Decimal off){
        CommonTableController pg = new CommonTableController();
        String queryString='';
        Integer offset = (Integer)off;
        if(offset==-1){
            offset = 0;
        }
        Integer psize = (Integer)pagesize;
        Integer listlength = 0;
        String wh = 'SBQQ__Quote__r.SBQQ__Opportunity2__r.EventEdition__c = \''+eventId+'\' AND Event_Product_Type__c!=null AND SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName IN (\'Closed Won\',\'Closed Booked\') AND Event_Product_Type__c NOT IN (\'Booth Cancellation\',\'Digital\',\'Premium\',\'Publishing\',\'Sponsorship\',\'Other\') AND (NOT SBQQ__Product__r.Name LIKE \'%Booth Package%\') AND (NOT SBQQ__Product__r.Name LIKE \'%Corner%\')';
        if(searchValue!=''){
            searchValue = string.escapeSingleQuotes(searchValue);
            searchValue ='%'+searchValue+'%';
            wh = wh + ' AND (SBQQ__Product__r.Name LIKE \''+searchValue+'\' OR SBQQ__Product__r.Event_Product_Type__c LIKE \''+searchValue+'\') ';
        }
        wh = wh + ' GROUP BY SBQQ__Product__r.Name,SBQQ__Product__r.Event_Product_Type__c,currencyIsoCode,SBQQ__Quote__r.SBQQ__Opportunity2__r.EventEdition__r.Measurement__c';
        List<AggregateResult> aaRes = Database.Query('SELECT count(Id) FROM SBQQ__QuoteLine__c WHERE '+wh);        
        if(aaRes.size()>0){
            listlength = aaRes.size();
        }
        
        if(next==false && prev==false){
            queryString = 'Select SBQQ__Product__r.Name,SBQQ__Product__r.Event_Product_Type__c,SUM(SBQQ__NetTotal__c), SUM(SBQQ__Quantity__c),currencyIsoCode from SBQQ__QuoteLine__c WHERE ' + wh + ' Limit '+psize+' OFFSET '+offset;
        } else if(next==true && offset<=listlength){
            queryString = 'Select SBQQ__Product__r.Name,SBQQ__Product__r.Event_Product_Type__c,SUM(SBQQ__NetTotal__c), SUM(SBQQ__Quantity__c),currencyIsoCode from SBQQ__QuoteLine__c WHERE ' + wh + ' Limit '+psize+' OFFSET '+offset;
        } else if(prev==true && offset>=0){
            queryString = 'Select SBQQ__Product__r.Name,SBQQ__Product__r.Event_Product_Type__c,SUM(SBQQ__NetTotal__c), SUM(SBQQ__Quantity__c),currencyIsoCode from SBQQ__QuoteLine__c WHERE ' + wh + ' Limit '+psize+' OFFSET '+offset;
        }
        
        try{
            LightningTableWraper ltngTableWrapper = new LightningTableWraper();
            ltngTableWrapper.tableRecord = Database.query(queryString);            
            pg.ltngTabWrap = ltngTableWrapper;
            pg.offst = offset;
            pg.hasprev = hasprevious(offset);   
            pg.hasnext = hasnxt(offset,listlength,psize); 
            pg.total = listlength;                
        } catch(Exception e){
            System.debug(e.getLineNumber()+','+e.getMessage());
        }
        return pg;
    }   

    @AuraEnabled
    public static Map<String,Boolean> getFieldVisibility(String accountId,String eventId)
    {
        Map<String,Boolean> ret = new Map<String,Boolean>{
            'boothContact'=> false,
            'social' => false,
            'logo' => false,
            'printScreen' => false,
            'webDesc' => false
        };

        List<Profile_Package_Setting__c>  ppsList = new List<Profile_Package_Setting__c>();
        List<Profile_Option_Visibility__c>  posList = new List<Profile_Option_Visibility__c>();
        List<User_Package__c> upList = new List<User_Package__c>();

        upList = [SELECT Profile_Package_Setting__c 
                  FROM User_Package__c 
                  WHERE Account__c=:accountId 
                  AND Event_Edition__c=:eventId 
                  LIMIT 1];
        if(!upList.isEmpty()){
            ppsList = [SELECT Social_Media_Links__c,Booth_Contact_Info__c,Print_Description__c,Web_Description__c,Logo__c 
                       FROM Profile_Package_Setting__c
                       WHERE ID=:upList[0].Profile_Package_Setting__c 
                       ORDER BY Priority__c DESC 
                       LIMIT 1];
        } else{
            ppsList = [SELECT Social_Media_Links__c,Booth_Contact_Info__c,Print_Description__c,Web_Description__c,Logo__c 
                       FROM Profile_Package_Setting__c 
                       WHERE Is_Default__c=true 
                       AND Event_Edition__c=:eventId 
                       LIMIT 1];
        }
        posList = [SELECT Social_Media_Links__c,Booth_Contact_Info__c,Print_Description__c,Web_Description__c,Logo__c,Product_Categories__c 
                   FROM Profile_Option_Visibility__c 
                   WHERE Event_Edition__c=:eventId
                   LIMIT 1];
        if(!posList.isEmpty() && !ppsList.isEmpty()){
            ret = new Map<String,Boolean>{
                'boothContact'=> posList[0].Booth_Contact_Info__c&&ppsList[0].Booth_Contact_Info__c,
                'social' => posList[0].Social_Media_Links__c&&ppsList[0].Social_Media_Links__c,
                'logo' => posList[0].Logo__c&&ppsList[0].Logo__c,
                'printScreen' => posList[0].Print_Description__c&&ppsList[0].Print_Description__c,
                'webDesc' => posList[0].Web_Description__c&&ppsList[0].Web_Description__c
            };
        }
        return ret;
    }
     
    @AuraEnabled
    public static void submitForApprovalBrazil(Id OppId) {
        System.debug('this is test Oppid'+Oppid);
        try{
                  Approval.ProcessSubmitRequest req1 =new Approval.ProcessSubmitRequest();
                  req1.setComments('Submitting request for approval.');
                  req1.setObjectId(OppId);
                  String appovalName=System.Label.ApprovalProcessName;
                // Submit the record to specific process and skip the criteria evaluation
                  req1.setProcessDefinitionNameOrId(appovalName);
                  req1.setSkipEntryCriteria(true);
                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(req1);
             }
            catch(Exception e){
                  System.debug('tetstst'+e.getLineNumber()+','+e.getMessage());
            }
          }    
}