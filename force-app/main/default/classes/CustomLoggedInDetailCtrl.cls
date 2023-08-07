/**
 * Created/Modified By: Girikon(Prashant)
 * Created On:          12/03/2018
 * Description/Purpose: This class provides following functionalities:
*                       Used for fetching records of logged-in user history in Customer List.
 * Test Class:          CustomLoggedInDetailCtrl_Test
 * Last Modified By :   Aishwarya[BK-6540 29 july 2020]
**/

public with sharing class CustomLoggedInDetailCtrl 
{
    
    @AuraEnabled public lightningTableWraper ltngTabWrap;     
    @AuraEnabled public integer offst;    
    @AuraEnabled public integer total;    
    @AuraEnabled public boolean hasprev;    
    @AuraEnabled public boolean hasnext;    
    
    public static boolean hasprevious(integer off)
    { 
        if(off>0)
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    public static boolean hasnxt(integer off,integer li,integer ps)
    {
        if((off+ps) < li)
        {
            return false;
        }
        else
        {
            return true;
            }
        }
    // Method used for fetching records of logged-in user 
    @AuraEnabled
    public static CustomLoggedInDetailCtrl getGenericObjectRecord(String objectName,String fieldstoget,Decimal pagesize,boolean next,boolean prev,Decimal off,String orderby,String direction,String startDate,String endDate)
    {
        Profile profileObj = [Select id from Profile Where Name='Operations'];

        // set filter query
        string whereClause =' Where CreatedBy.profileId=\''+profileObj.Id+'\' AND Action=\'suNetworkAdminLogin\' ';
        String sQueryofTotal = 'Select count() From '+ObjectName+'  Where CreatedBy.profileId=\''+profileObj.Id+'\' AND Action=\'suNetworkAdminLogin\' ';
        Boolean isAddWhere = false;        
        Date sd;
        Date ed;
        //Conditions for checking startDate and endDate entered
        if(String.isNotEmpty(startDate) && String.isNotEmpty(endDate))
        {            
            sd = Date.newInstance(Integer.valueOf(startDate.split('/').get(2)),Integer.valueOf(startDate.split('/').get(0)),Integer.valueOf(startDate.split('/').get(1)));
            String strSdate = String.valueOf(sd)+'T00:00:00Z';
            whereClause = whereClause + ' AND CREATEDDATE>='+strSdate;
            sQueryofTotal = sQueryofTotal + ' AND CREATEDDATE>='+strSdate;

            ed = Date.newInstance(Integer.valueOf(endDate.split('/').get(2)),Integer.valueOf(endDate.split('/').get(0)),Integer.valueOf(endDate.split('/').get(1)));
            String strEdate = String.valueOf(ed.adddays(1))+'T00:00:00Z';
            whereClause = whereClause + ' AND CREATEDDATE<'+strEdate;
            sQueryofTotal = sQueryofTotal + ' AND CREATEDDATE<'+strEdate;
        }
        else if(String.isNotEmpty(startDate) && String.isEmpty(endDate))
        {
            sd = Date.newInstance(Integer.valueOf(startDate.split('/').get(2)),Integer.valueOf(startDate.split('/').get(0)),Integer.valueOf(startDate.split('/').get(1)));
            String strSdate = String.valueOf(sd)+'T00:00:00Z';
            whereClause = whereClause + ' AND CREATEDDATE>='+strSdate;
            sQueryofTotal = sQueryofTotal + ' AND CREATEDDATE>='+strSdate;
        }
        else if(String.isEmpty(startDate) && String.isNotEmpty(endDate))
        {
            ed = Date.newInstance(Integer.valueOf(endDate.split('/').get(2)),Integer.valueOf(endDate.split('/').get(0)),Integer.valueOf(endDate.split('/').get(1)));
            String strEdate = String.valueOf(ed.adddays(1))+'T00:00:00Z';
            whereClause = whereClause + ' AND CREATEDDATE<'+strEdate;
            sQueryofTotal = sQueryofTotal + ' AND CREATEDDATE<'+strEdate;
            system.debug('debug 3');
        }
        else
        {
            DateTime last30Days = System.now();
            DateTime dt = last30Days.addDays(-30);
            whereClause = whereClause + ' AND CREATEDDATE>=:dt ';
            sQueryofTotal = sQueryofTotal + ' AND CREATEDDATE>=:dt ';
        }
        // End filter query
        CustomLoggedInDetailCtrl pg = new CustomLoggedInDetailCtrl();
        Integer offset = (Integer)off; 
        Integer psize = (Integer)pagesize;        
        list<account> li = new list<account>();
        integer listlength = Database.countQuery(sQueryofTotal);
        List<String> lstfieldstoget = fieldstoget.split(',');
        List<lightningTableColumnWrapper> lstTableColumn = new list<lightningTableColumnWrapper> ();        
        Transient DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe();
        Transient lightningTableColumnWrapper colWrapper;
        Transient DescribeFieldResult fieldResult;
        
        Transient String queryString = '';
        //Conditions for checking next and previous        
        if(next==false && prev==false)
        {
            queryString = 'Select '+ String.escapeSingleQuotes(String.join(lstfieldstoget,','))+
                ' from '+ String.escapeSingleQuotes(ObjectName)+ whereClause + ' ORDER BY '+orderby+' '+direction+' Limit '+psize+' OFFSET '+offset;
        }
        else if(next==true && (offset+psize)<=listlength)
        {
            offset=offset+psize;
            queryString = 'Select '+ String.escapeSingleQuotes(String.join(lstfieldstoget,','))+
                ' from '+ String.escapeSingleQuotes(ObjectName) + whereClause+  ' ORDER BY '+orderby+' '+direction+' Limit '+psize+' OFFSET '+offset;
        }
        else if(prev==true && offset>0)
        {
            offset=offset-psize;
            queryString = 'Select '+ String.escapeSingleQuotes(String.join(lstfieldstoget,','))+
                ' from '+ String.escapeSingleQuotes(ObjectName) +whereClause+ ' ORDER BY '+orderby+' '+direction+' Limit '+psize+' OFFSET '+offset;
        }
        try
        {            
            System.debug(queryString);
            lightningTableWraper ltngTableWrapper = new lightningTableWraper();
            ltngTableWrapper.tableRecord = database.query(queryString);
            ltngTableWrapper.tableColumn = lstTableColumn;
            pg.ltngTabWrap = ltngTableWrapper;
            pg.offst = offset;
            pg.hasprev = hasprevious(offset);   
            pg.hasnext = hasnxt(offset,listlength,psize);
            pg.total = listlength;
        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber()+','+e.getMessage());
        }
        return pg;
    } 
    public class lightningTableColumnWrapper 
    {
        /*@AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public String fieldName {get;set;}
        @AuraEnabled
        public string type {get;set;}
        @AuraEnabled
        public boolean sortable {get;set;}*/
    }
    //Wrapper class for table record and table column 
    public class lightningTableWraper
    {
        @AuraEnabled
        public List<sObject> tableRecord {get;Set;}
        @AuraEnabled
        public List<lightningTableColumnWrapper> tableColumn {get;set;}
    }
}