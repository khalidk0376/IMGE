public with sharing class LookupPageController {
 
    public Boolean render1 { get; set; }
    public String accountId{get;set;}
    public List<contact> records=new List<contact>();
    public String searchvalue { get; set; }
   
 
    public LookupPageController(){
        try
        {
            //searchvalue=ApexPages.currentPage().getParameters().get('parentname');
            String id=ApexPages.currentPage().getParameters().get('accountId');
            accountId=[select id from Account where id=:id].Id;
            system.debug('----accountId----'+accountId);
         
        if(String.IsNotBlank(searchvalue)){
            render1=true;
            records=[Select Id,Name,email from contact where accountId=:accountId order by Name asc limit 500];
        }
            else{
                render1=true;
                records=[Select Id,Name,email from contact where accountId=:accountId order by Name asc limit 500];
            }
        }catch(Exception e)
        {
            system.debug('error'+ e);
           //BK-3754          
              Utility.logsError(e.getMessage(), e.getCause(), e.getLineNumber(), e.getStackTraceString(), 'LookupPageController' , 'Integration');
        }
        searchvalue=null;
    }
 
    public List<contact> getRecords() {
        if(records.size()!=0)
        {
            return records;
        }else
        {
            return null;
        }
    }
 
    public PageReference onkeyupAction() {
        searchAction();
        return null;
    }
 
    public PageReference searchAction() {
        render1=true;
        //records=[Select Id,Name,email from contact where Name like :+searchvalue+'%' order by Name asc limit 500];
        records=[Select Id,Name,email from contact where Name like :+searchvalue+'%' and accountId=:accountId order by Name asc limit 500];
    if(records.isEmpty())
    {
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,'No Records Found'));
    }
        return null;
    }
 
}