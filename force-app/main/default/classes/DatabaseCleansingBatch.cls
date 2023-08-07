/**************************************************************************
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)2015-11-30
**####### Deletes data older than a number of days
***************************************************************************/
global class DatabaseCleansingBatch implements Database.Batchable<Sobject> 
{
    public Boolean isTesting;
  public String soqlRecordsToDelete;
    public String soqlObject;
    public String emailErrorsTo;
    public String emailReportTo;
    public Integer dataCount = 0;
    public Boolean emptyRecyleBinScope = false;
    
    global database.querylocator start(Database.BatchableContext BC)  
  {  
        String appName = 'DatabaseCleansing.' + soqlObject;
        
        
        ApplicationProcessRunning__c insertAPR = new ApplicationProcessRunning__c(ProcessCount__c=0,ProcessLastRecord__c=BC.getJobId(),name=appName,ProcessRunning__c= true ,ProcessStart__c=System.now(),ProcessEnd__c=System.now() );
        insert(insertAPR);
            
          
        return Database.getQueryLocator(soqlRecordsToDelete);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
  {
         DatabaseCleansing.dataCount =  DatabaseCleansing.dataCount + scope.size();
        List<ApplicationProcessRunning__c> apr = [Select a.Id,a.ProcessFinished__c,a.ProcessStart__c,ProcessEnd__c, a.Name, a.ProcessCalled__c, a.ProcessLastRecord__c, a.ProcessRunning__c, a.SystemModstamp, a.CreatedDate, a.Error_Message__c, a.ProcessCount__c from ApplicationProcessRunning__c a where a.ProcessLastRecord__c=:BC.getJobId()  limit 1];
        apr[0].ProcessCount__c = apr[0].ProcessCount__c + scope.size();
        apr[0].ProcessEnd__c =System.now();
        System.debug('#### Delete Job: ' + BC.getJobId() + '; Child Job: ' + BC.getChildJobId() +'; Batch of ' + scope.size()+'; Total:' + apr[0].ProcessCount__c);
        delete scope;
        
        //Hard Delete (WARNING!!!: These records will not exist in Recycle Bin or API!!!)
    if(emptyRecyleBinScope) DataBase.emptyRecycleBin(scope);
        
    update(apr);        
    }
    
    global void finish(Database.BatchableContext BC)
  {
    List<ApplicationProcessRunning__c> apr = [Select a.Id,a.ProcessFinished__c,a.ProcessStart__c,ProcessEnd__c, a.Name, a.ProcessCalled__c, a.ProcessLastRecord__c, a.ProcessRunning__c, a.SystemModstamp, a.CreatedDate, a.Error_Message__c, a.ProcessCount__c from ApplicationProcessRunning__c a where a.ProcessLastRecord__c=:BC.getJobId()  limit 1];
        
        
        
    AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id =:BC.getJobId()];
    
        String emailTo = '';
        String emailPriority= 'Normal';
        String emailSubject= 'SFDC Data Cleansing ' + soqlObject.toUpperCase() + ' status ' + a.Status + '';
        String emailMessage = 'Org: ' + UserInfo.getOrganizationName() + '(' +UserInfo.getOrganizationId() +')\nObject: ' +soqlObject +'\nDeleted(hard='+ emptyRecyleBinScope +'): '+ apr[0].ProcessCount__c +'\nSOQL: '+ soqlRecordsToDelete +'\n\nApex Job Information\nJobId: '+ BC.getJobId() + '\nJob Items: ' + a.TotalJobItems + '\nFailures: '+ a.NumberOfErrors + '\nExtended Status: ' + a.ExtendedStatus;
        
        
        if(a.NumberOfErrors > 0)
        {
            emailTo = emailErrorsTo;
            emailPriority='High';
            emailSubject= emailSubject.toUpperCase() + ' with Failure!!!';
        }
        Else
        {
            emailTo = emailReportTo;
        }
            
       
    apr[0].ProcessFinished__c =System.now();
        apr[0].ProcessRunning__c=false;
        if(emailMessage.length() > 255)
        {
            apr[0].Error_Message__c = emailMessage.left(255);
        }else
        {apr[0].Error_Message__c = emailMessage;}
        
        update(apr);
    DatabaseCleansing.SendEmail(emailTo,emailSubject,emailMessage ,emailPriority);
    
        
        
  }
  
  
    
}