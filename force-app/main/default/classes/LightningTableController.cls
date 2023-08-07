/**
 * Created By       :   Girikon(Mukesh)
 * Created On       :   03/06/2018
 * @description     :   This class provides following functionalities:          
 *                      Allow to fetch record based on dynamic object and field. This class used by LightningDataTable component
 *                      
 * Helper Class     :   N/A
 * Test Class       :   LightningTableController_Test(83%)
 
 * Modification log --
 * Modified by      :   Girikon(Mukesh)[]
 **/
public with sharing class LightningTableController{
    @AuraEnabled
    public LightningTableWraper ltngTabWrap;    
    @AuraEnabled
    public integer offst;    
    @AuraEnabled
    public integer total;    
    @AuraEnabled
    public boolean hasprev;    
    @AuraEnabled
    public boolean hasnext;    
     @AuraEnabled
    public boolean checkBrasilContactUpdate= false;
    public static boolean hasprevious(integer off){ if(off>0){return false;}else{return true;}}
    public static boolean hasnxt(integer off,integer li,integer ps){if((off+ps) < li){return false;}else{return true;}}
    @AuraEnabled
    public static lightningTableController getGenericObjectRecord(String ObjectName,String fieldstoget,Decimal pagesize,boolean next,boolean prev,Decimal off,String whField,String whValue,Boolean inlineEditable,String operator){
        lightningTableController pg = new lightningTableController();
        Integer offset = (Integer)off;
        Integer psize = (Integer)pagesize;        
        list<account> li = new list<account>();
        integer listlength = (Integer)getTotalRows(ObjectName,whField,whValue,operator);
        List<String> lstfieldstoget = fieldstoget.split(',');
        List<lightningTableColumnWrapper> lstTableColumn = new list<lightningTableColumnWrapper> ();        
        Transient DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe();
        Transient lightningTableColumnWrapper colWrapper;
        Transient DescribeFieldResult fieldResult;        
        for(String field : lstfieldstoget){
            if(objResult.fields.getMap().containsKey(field)){
                colWrapper = new lightningTableColumnWrapper();
                fieldResult = objResult.fields.getMap().get(field).getDescribe();
                colWrapper.label = fieldResult.getLabel();
                colWrapper.fieldName = fieldResult.getName();
                colWrapper.type = String.valueof(fieldResult.getType()).toLowerCase();
                colWrapper.sortable = true;
                colWrapper.editable = inlineEditable;
                lstTableColumn.add(colWrapper);
            }
        }
       
        if(!schema.sobjecttype.Contact.isaccessible()){return new lightningTableController();}
        else{
            
            Transient String queryString = '';
            String wh = '';
            List<String> whFieldsAr = whField.split(',');
            List<String> whValueAr = whValue.split(',');

            if(String.isNotBlank(whField)){
                wh = ' WHERE ';//+String.escapeSingleQuotes(whField)+'=:whValue';
                Integer i=0;
                for(String field:whFieldsAr){
                    if(i==0){
                        wh = wh + String.escapeSingleQuotes(field)+'=\''+whValueAr[i]+'\'';
                    }
                    else{
                        if(whValueAr[i]=='false'||whValueAr[i]=='true'){
                            wh = wh + ' '+operator+' '+String.escapeSingleQuotes(field)+'='+whValueAr[i];    
                        }
                        else{
                            wh = wh + ' '+operator+' '+String.escapeSingleQuotes(field)+'=\''+whValueAr[i]+'\'';    
                        }                        
                    }
                    i++;
                }
            }

            if(next==false && prev==false){
                queryString = 'Select '+ String.escapeSingleQuotes(String.join(lstfieldstoget,','))+
                    ' from '+ String.escapeSingleQuotes(ObjectName) + wh+' Limit '+psize+' OFFSET '+offset;
            }else if(next==true && (offset+psize)<=listlength){
                offset=offset+psize;
                queryString = 'Select '+ String.escapeSingleQuotes(String.join(lstfieldstoget,','))+
                    ' from '+ String.escapeSingleQuotes(ObjectName) + wh+' Limit '+psize+' OFFSET '+offset;
            }else if(prev==true && offset>0){
                offset=offset-psize;
                queryString = 'Select '+ String.escapeSingleQuotes(String.join(lstfieldstoget,','))+
                    ' from '+ String.escapeSingleQuotes(ObjectName) + wh+' Limit '+psize+' OFFSET '+offset;
            }
            try{
                LightningTableWraper ltngTableWrapper = new LightningTableWraper();
                ltngTableWrapper.tableRecord = database.query(queryString);
                ltngTableWrapper.tableColumn = lstTableColumn;
                pg.ltngTabWrap = ltngTableWrapper;
                pg.offst = offset;
                pg.hasprev = hasprevious(offset);  
                pg.hasnext = hasnxt(offset,listlength,psize);
                pg.total = listlength;
                pg.checkBrasilContactUpdate = checkBrasilConUpdateUser();
                system.debug(offset+','+listlength+','+psize);
            }
            catch(Exception e){
                System.debug(queryString);
                system.debug(e.getLineNumber()+','+e.getMessage());
            }
        }
        return pg;
    }    
    @AuraEnabled
    public static List<sobject> getRecordDetail(String objectName,String fields,String recordId){
        return Database.query('Select '+String.escapeSingleQuotes(fields)+' from '+String.escapeSingleQuotes(objectName)+' WHERE Id=:recordId');
    }
    @AuraEnabled
    public static List<sobject> getFileDetail(String objectName,String fields,String parentId){
        return Database.query('Select '+String.escapeSingleQuotes(fields)+' from '+String.escapeSingleQuotes(objectName)+' WHERE ParentId=:parentId ORDER BY CreatedDate Desc LIMIT 1');
    }
    /**
     * We have used to view file BK-10226 Modified By - Rajesh Kumar - 02-11-2020
     */

    @AuraEnabled
    public static List<sobject> getFilePreview(String objectName,String fields,String parentId){
        return Database.query('Select '+String.escapeSingleQuotes(fields)+' from '+String.escapeSingleQuotes(objectName)+' WHERE LinkedEntityId =  : parentId ORDER BY ContentDocument.CreatedDate Desc LIMIT 1');
    }
    @AuraEnabled
    public static void deleteRecord(Contact cont_obj){
        try{
            delete cont_obj;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Integer getTotalRows(String objectName,String whField,String whValue,String operator){
        String wh='';
        if(String.isNotBlank(whField)){
            wh = ' WHERE ';
            Integer i=0;
            List<String> whFieldsAr = whField.split(',');
            List<String> whValueAr = whValue.split(',');
            for(String field:whFieldsAr){
                if(i==0){
                    wh = wh + String.escapeSingleQuotes(field)+'=\''+whValueAr[i]+'\'';
                }
                else{
                    if(whValueAr[i]=='false'||whValueAr[i]=='true'){
                        wh = wh + ' '+operator+' '+String.escapeSingleQuotes(field)+'='+whValueAr[i];    
                    }
                    else{
                        wh = wh + ' '+operator+' '+String.escapeSingleQuotes(field)+'=\''+whValueAr[i]+'\'';    
                    }                        
                }
                i++;
            }
        }
        System.debug(wh);
        return database.countQuery('select count() from '+objectName+wh);
    }    
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
   
    public class lightningTableWraper{
        @AuraEnabled
        public List<sObject> tableRecord {get;Set;}
        @AuraEnabled
        public List<lightningTableColumnWrapper> tableColumn {get;set;}
    }  
         // Added by Palla Kishore for the tickets BK-24718
    public static boolean checkBrasilConUpdateUser() {
        boolean isBrasilUser = false;
        try {
            list<PermissionSetAssignment> lstPSA = new list<PermissionSetAssignment>();
            lstPSA = [SELECT Id,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId=:Userinfo.getUserId() AND PermissionSet.Name= 'Brazil_Contact_Update_Permission_Set'];
            if(!lstPSA.isEmpty()){
                isBrasilUser = true;
            }
        } catch(Exception ex) {
            return isBrasilUser;
        }
        
        return isBrasilUser;
    } 
}