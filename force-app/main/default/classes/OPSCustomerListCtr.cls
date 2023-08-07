/**
 * Created By       :   Girikon(Mukesh[STL-216])
 * Created On       :   27 sept 2019
 * @description     :   This controller used to get aggregate data also using limit & offset to paginate data.
 * Test Class       :   OPSCustomerListCtr_Test(86%)
 * Modified by      :   Yash Gupta [4/10/2019] ,Himanshu jasuja[BK - 3678 - 03/18/2020]
  History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020
 **/

public with sharing class OPSCustomerListCtr
{

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
    @AuraEnabled
    public String testQuery;
    
    /*
    * @description [return true if offset greater than 0 otherwise false]
    * @param off [offset]
    * @return [true/false]
    */
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
    
    /*
    * @description [this method check whether offset less than total record]
    * @param off [offset]
    * @param li [total rows return by query]
    * @param ps [pagesize]
    * @return [true/false]
    */
    public static boolean hasnxt(integer off,integer li,integer ps)
    {
        if((off+ps)>2000)
        {
            return true;
        } 
        else if((off+ps) < li) 
        {
            return false;
        } 
        else 
        { 
            return true;
        }
    }
    
    /*
    * @description [this method get record for any object it is depends on parameter you have passed]
    * @param searchValue [send searchbox value on common-table component]
    * @param objectName [Pass object api name]
    * @param condition [pass condition if any recquired otherwise set default to id!='']
    * @return [object of OPSCustomerListCtr]
    */
    @AuraEnabled(cacheable=false)
    public static OPSCustomerListCtr getGenericObjectRecord(String agentName,String searchValue,String eventId,Decimal pagesize,boolean next,boolean prev,Decimal off,String sortBy,String sortType)
    {
        //bind all returning data in single unit using this variable
        OPSCustomerListCtr returnDataObj = new OPSCustomerListCtr();

        //queryString used to build and store dynamic soql string
        String queryString='';

        //this is passing param from LWC which defined next offset of query
        Integer offset = (Integer)off;

        //check if offset is -1 then set to 0 by default
        if(offset==-1)
        {
            offset = 0;
        }
        String orderBy='';
        if(sortBy!=''){
            if(sortBy.toLowerCase()=='name'){
                orderBy = ' Order By SFContactID__r.Account.Name '+sortType+'  NULLS LAST  ';
            }
            else{
                orderBy = ' Order By User_Type__r.Name '+sortType+'  NULLS LAST  ';
            }
        }
        //pagesize parameter also passing by method
        Integer psize = (Integer)pagesize;
        
        //wh string that hold condition which used in query
        //BK - 3678 - Added the EventEdition__c field in below queries.
        String wh = '';
        if(agentName!=''){
            wh = ' User_Type__r.Name =\''+agentName+'\' AND SFEventEditionID__r.Id=\''+eventId+'\' AND User_Type__c!=null AND SFContactID__c!=null AND User_Type__r.Name NOT IN(\'Stand Contractor\',\'Contractor\') AND SFContactID__c in(SELECT Operations_Contact__c from Opportunity WHERE StageName In(\'Closed Won\',\'Closed Booked\' ) AND EventEdition__c =\''+eventId+'\' ) AND User_Type__c!=\'\' AND Status__c=true  ';
        }
        else{
            wh = ' SFEventEditionID__r.Id=\''+eventId+'\' AND User_Type__c!=null AND SFContactID__c!=null AND User_Type__r.Name NOT IN(\'Stand Contractor\',\'Contractor\') AND SFContactID__c in(SELECT Operations_Contact__c from Opportunity WHERE StageName In(\'Closed Won\',\'Closed Booked\') AND EventEdition__c =\''+eventId+'\') AND User_Type__c!=\'\' AND Status__c=true ';
        }
        String agentQueryCondition = ' SFEventEditionID__r.Id=\''+eventId+'\' AND User_Type__c!=null AND SFContactID__c!=null AND User_Type__r.Name NOT IN(\'Stand Contractor\',\'Contractor\') AND SFContactID__c in(SELECT Operations_Contact__c from Opportunity WHERE StageName In(\'Closed Won\',\'Closed Booked\') AND EventEdition__c =\''+eventId+'\' ) AND User_Type__c!=\'\' AND Status__c=true ';
        if(searchValue!=''){
            //secure search value by adding single quote if any special char search            
            //searchValue = string.escapeSingleQuotes(searchValue);

            //suffix and prefix % sign to search LIKE Query
            searchValue ='%'+searchValue+'%';

            //there are only two fields visible on table, so here search in account name and user type fields
            wh = wh + ' AND (SFContactID__r.Account.Name LIKE \''+searchValue+'\' OR User_Type__r.Name LIKE \''+searchValue+'\') ';
        }

        //listlength variable used to check whether offset in query is less than record count
        Integer listlength = 0;
        
       
        //here always grouping SFContactID__r.AccountId,SFEventEditionID__r.Name, User_Type__c and User_Type__r.Name
        wh = wh + ' GROUP BY SFContactID__r.AccountId,SFContactID__r.Account.Name,SFEventEditionID__c,SFEventEditionID__r.Name,User_Type__c,User_Type__r.Name,SFContactID__r.Account.Id,SFEventEditionID__r.Id,User_Type__r.Id';
        
         //add order 
        wh = wh +  orderBy;
        
        //record count query
        List<AggregateResult> aaRes = Database.Query('SELECT count(Id) FROM ContactEventEditionMapping__c WHERE '+wh);
        
        // Assign size
        listlength = aaRes.size();
        
        String queryString2='';
        if((next==false && prev==false) || (next==true && offset<=listlength) || (prev==true && offset>=0))
        {
            //queryString used to get aggregate account name and user type because both name field can't access in grouping query
            queryString = 'SELECT SFContactID__r.AccountId,SFContactID__r.Account.Name,User_Type__c FROM ContactEventEditionMapping__c WHERE ' + wh + ' Limit '+psize+' OFFSET '+offset;
            
            //queryString2 used to get aggregate only  user type id, and user type name
            queryString2 = 'SELECT User_Type__c,User_Type__r.Name FROM ContactEventEditionMapping__c WHERE ' + wh + ' Limit '+psize+' OFFSET '+offset;
        }

        try
        {
            LightningTableWraper ltngTableWrapper = new LightningTableWraper();
            
            //this record contains only account name and user type id where user type id used to merge tableRecord2 user type name
            SYstem.debug('queryString' + queryString);
            ltngTableWrapper.tableRecord = Database.query(queryString);
            
            //this record used to merge with tableRecord variable in client side
            ltngTableWrapper.tableRecord2 = Database.query(queryString2);
            
            ltngTableWrapper.userAgents = Database.query('Select count(Id),User_Type__r.Name from ContactEventEditionMapping__c WHERE '+ agentQueryCondition +' Group BY User_Type__r.Name');

            returnDataObj.ltngTabWrap = ltngTableWrapper;
            //set current page offset
            returnDataObj.offst = offset;
            //set is previous data exist or not
            returnDataObj.hasprev = hasprevious(offset);   
            //set is next offset exist or not
            returnDataObj.hasnext = hasnxt(offset,listlength,psize); 
            //set total record count
            returnDataObj.total = listlength;
            //returnDataObj.testQuery = queryString;
        } 
        catch(Exception e)
        {
            //throw and hanlde by lwc component to display proper message
            throw new AuraHandledException(e.getMessage()+','+queryString);
        }

        return returnDataObj;
    }    
    
    /*
    * @description [wrapper class used to wrap data and return by getGenericObjectRecord() method]
    */
    public class lightningTableWraper{
        @AuraEnabled public List<sObject> tableRecord;
        @AuraEnabled public List<sObject> tableRecord2;
        @AuraEnabled public List<AggregateResult> userAgents;
         
    }
}