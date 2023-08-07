public class HomeFinanceSummaryCtr
{   /*
    public HomeFinanceSummaryCtr(){
       //BK-3753 - EmptyStatementBlock Violation Reported so I am commented this block as of now.
    }*/
    
    public static  accountDetailsWrapper getOppAccountDetails()
    {
        String accountId = ApexPages.currentPage().getParameters().get('accountId');
        String eventId = ApexPages.currentPage().getParameters().get('eventId');
        //updateAccount(accountId ,eventId );
        accountDetailsWrapper acctDetail = new accountDetailsWrapper();
        Date currentDate =  date.today();
        acctDetail.amount =0.0;
        acctDetail.paidAmount =0.0;
        acctDetail.remainingAmount =0.0;
        acctDetail.check=false;
        if(string.isNotBlank(accountId) && string.isNotBlank(eventId))
        {
            List<opportunity> oppLst = [select id,Name,Amount,Paid_Amount__c,Payment_Status__c,EventEdition__r.Cutoff_Date_1__c,
                                    EventEdition__r.Cutoff_Date_2__c,EventEdition__r.Cutoff_Date_3__c,EventEdition__r.EventCurrency__r.name from opportunity where Payment_Status__c !='Paid' AND AccountId=:accountId AND 
                                      EventEdition__c=:eventId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
            List<Account> accLst  = [Select Id, name,  Has_Balance__c from Account where id=:accountId  ];   
            List<Account> newAccLst= new List<Account>();            
            system.debug(oppLst );                          
            if(oppLst!=null && oppLst.size()>0)
            {
                list<Date> dueDateLst = new list<Date>();
                for(opportunity opp:oppLst)
                {
                    if(opp.Paid_Amount__c != null)
                    {
                          acctDetail.paidAmount += opp.Paid_Amount__c;
                    }
                    if (opp.Amount!=null)
                    {
                        acctDetail.Amount += opp.Amount;
                    }
                    
                    Date dueDate;
                    if(opp.Payment_Status__c!='Paid' && opp.EventEdition__r.Cutoff_Date_1__c != null && opp.EventEdition__r.Cutoff_Date_1__c > currentDate)
                    {
                        dueDate = opp.EventEdition__r.Cutoff_Date_1__c;
                    }
                    else if(opp.Payment_Status__c!='Paid' && opp.EventEdition__r.Cutoff_Date_1__c != null && opp.EventEdition__r.Cutoff_Date_2__c > currentDate)
                    {
                        dueDate = opp.EventEdition__r.Cutoff_Date_2__c;
                    }
                    else if(opp.Payment_Status__c!='Paid' && opp.EventEdition__r.Cutoff_Date_1__c != null && opp.EventEdition__r.Cutoff_Date_3__c > currentDate)
                    {
                        dueDate = opp.EventEdition__r.Cutoff_Date_3__c;
                    }
                    
                    if(dueDate!=null)
                    {
                        dueDateLst.add(dueDate);
                    }
                    
                }
                Double rAmount= acctDetail.Amount - acctDetail.paidAmount;
               // acctDetail.remainingAmount = acctDetail.Amount - acctDetail.paidAmount;
                if (rAmount!=0)//acctDetail.remainingAmount!=0)
                {                                                                           
                    acctDetail.check=true;
                    acctDetail.remainingAmount = acctDetail.Amount - acctDetail.paidAmount;
                    acctDetail.currencyType = oppLst[0].EventEdition__r.EventCurrency__r.name;
                    system.debug(acctDetail.remainingAmount);
                    if(dueDateLst.size()>0 && dueDateLst!=null)
                    {
                        dueDateLst.sort();
                        acctDetail.dueDate = changeDateFormat(dueDateLst[0]);
                    }
                }                                         
            }
        }
        return acctDetail ;
    }
     public static String changeDateFormat(Date d)
    {
       String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('d/MM/YYYY');
       return dt;
    }
    
    public class accountDetailsWrapper
    {
      public double amount{get;set;}
      public double paidAmount{get;set;}
      public double remainingAmount{get;set;}
      public string dueDate{get;set;}
      public string currencyType{get;set;}
      public boolean check{get;set;}
    } 
   /* 
   */
   public void updateAccount()
    {  
        String acctId = ApexPages.currentPage().getParameters().get('accountId');
        String eventId = ApexPages.currentPage().getParameters().get('eventId');  
        if(string.isNotBlank(acctId) && string.isNotBlank(eventId))
        {
            List<opportunity> oppLst = [select id,Name,Amount,Paid_Amount__c,Payment_Status__c,EventEdition__r.Cutoff_Date_1__c,
                                    EventEdition__r.Cutoff_Date_2__c,EventEdition__r.Cutoff_Date_3__c from opportunity where Payment_Status__c !='Paid' AND AccountId=:acctId AND 
                                      EventEdition__c=:eventId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
            system.debug('Opp'+oppLst );
            List<Account> accLst  = [Select Id, name,  Has_Balance__c from Account where id=:acctId];   
            List<Account> newAccLst= new List<Account>();            
            system.debug(oppLst ); 
            Double amount =0.0;
            Double paidAmount =0.0;
            Double remainingAmount =0.0;                              
            if(oppLst!=null && oppLst.size()>0)
            {         
                for(opportunity opp:oppLst)
                {
                    if(opp.Paid_Amount__c != null)
                    {
                          paidAmount += opp.Paid_Amount__c;
                    }
                    if (opp.Amount!=null)
                    {
                        Amount += opp.Amount;
                    }
                                                           
                }
                Double rAmount= Amount -paidAmount; 
                system.debug( 'rAmount'+rAmount);            
                if (rAmount!=0)//acctDetail.remainingAmount!=0)
                {
                    for (Account acc : accLst )
                    {
                        Account acct = new Account();
                        acct.id= acc.id;
                        acct.Has_Balance__c =true;
                        newAccLst.add(acct);
                    }
                    update newAccLst;                                                        
                    
                }
                else
                {
                    for (Account acc : accLst )
                    {
                        Account acct = new Account();
                        acct.id= acc.id;
                        acct.Has_Balance__c =false;
                        newAccLst.add(acct);
                    }
                    update newAccLst; 
                }                               
            }
        }
       
    } // */
}