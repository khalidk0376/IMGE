/**
 * Created By:          Girikon(Amish)
 * Created On:          6/15/2017
 * Modified By:    Girikon(Amish) - CCEN 274, CCEN 420 , Girikon(Prashant) - CCEN-416
 * Modified On :  11/20/2018,11/26/2018
 * Description/Purpose: This class is used for the home page on Customer Community to show the summary
 * Methods:             oppAccountDetails, oppAccountDetailsOPS
 * Test Class:          oppAccountDetails_Test
**/

global class oppAccountDetails
{
  webservice static string oppAccountDetails(String accountId,String eventId)
  {
      accountDetailsWrapper acctDetail = new accountDetailsWrapper();
      acctDetail.amount =0.0;
      acctDetail.remainingAmount =0.0;
      set<string> quoteIds = new set<string>();
      
      if(string.isNotBlank(accountId) && string.isNotBlank(eventId))
      {
          List<opportunity> opp = [select id,Name,Amount,Paid_Amount__c,SBQQ__PrimaryQuote__c from opportunity where AccountId=:accountId AND 
                                      EventEdition__c=:eventId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
          List<boothOpptyWrapper> listBoothOpptyWrapper = new List<boothOpptyWrapper>();
          if(opp!=null && opp.size()>0){
              for(opportunity oppty: opp)
              {
                  if(oppty.SBQQ__PrimaryQuote__c!=null)
                  {
                      quoteIds.add(oppty.SBQQ__PrimaryQuote__c);
                  }
                  boothOpptyWrapper bow = new boothOpptyWrapper();
                  bow.opptyId = oppty.Id;
                  listBoothOpptyWrapper.add(bow);
              }
              
              list<double> listOppAmount = new list<double>();
              for(integer i=0; i<opp.size();i++){
                  if(opp[i].Paid_Amount__c == null){
                      opp[i].Paid_Amount__c = 0.0;
                  }
                  if(opp[i].Amount !=null){
                      acctDetail.amount =opp[i].Amount;
                      acctDetail.remainingAmount = opp[i].Amount - opp[i].Paid_Amount__c;
                      //acctDetail.lstAmount.add(opp[i].Amount);
                       listOppAmount.add(acctDetail.remainingAmount);
                       acctDetail.lstAmount =listOppAmount;
                       
                  }
              }
          
          }
          if(opp!=null && opp.size()>0)
          {
              //List<ExpocadBooth__c> expoBooths = [Select Id,Booth_Number__c,Area__c,Unit_Type__c From ExpocadBooth__c where quote__c=:opp[0].SBQQ__PrimaryQuote__c];
              //Added condition of Related_Opportunity__c and Related_Opportunity__r.User_Type__r.Name for [CCEN-416]
              List<ExpocadBooth__c> expoBooths = [Select Id, Booth_Number__c, Area__c, Unit_Type__c, Opportunity__c,Opportunity__r.account.name, Opportunity__r.Name, Opportunity__r.createdDate, Display_Name__c, Status__c From  
                                                         ExpocadBooth__c where Status__c = 'Rented' AND quote__c IN:quoteIds  AND (Related_Opportunity__c  = null OR Related_Opportunity__r.User_Type__r.Name = 'Exhibitor')  order by Opportunity__r.createdDate];
              
              List<boothDetailsWrapper> expoBoothWrpr =new List<boothDetailsWrapper>();
              //List<boothOpptyWrapper> listBoothOpptyWrapper = new List<boothOpptyWrapper>();
             
              if(expoBooths !=null && expoBooths.size()>0)              
              {
                  for(ExpocadBooth__c ecb: expoBooths)
                  {
                      boothDetailsWrapper bdw=new boothDetailsWrapper();
                      bdw.boothName=ecb.Booth_Number__c;
                      bdw.boothArea=ecb.Area__c;
                      bdw.unitType=ecb.Unit_Type__c;
                      bdw.boothId=ecb.Id;
                      bdw.oppty = ecb.Opportunity__r.Name;
                      // updated as pre CCEN 420
                      if (!String.isBlank(ecb.Display_Name__c))
                      {                    
                          bdw.displayName = ecb.Display_Name__c;
                      }
                      else
                      {
                          bdw.displayName =ecb.Opportunity__r.account.name;
                      }
                      
                      bdw.boothStatus = ecb.Status__c;
                      expoBoothWrpr.add(bdw);
                   }
              }
              /*
              if(opp[0].Paid_Amount__c ==null)
                  opp[0].Paid_Amount__c=0.0;
              if(opp[0].Amount !=null)
              {
                  acctDetail.amount =opp[0].Amount;
                  acctDetail.remainingAmount = opp[0].Amount - opp[0].Paid_Amount__c;
              }
              */
              acctDetail.boothDetails=expoBoothWrpr;
              acctDetail.boothOppty = listBoothOpptyWrapper;
              system.debug('acctDetail='+acctDetail);
              
          }
          system.debug('acctDetail= no opp');
      }
      String JSONString = JSON.serialize(acctDetail);
      return JSONString ;
  }
  
  webservice static string oppAccountDetailsOPS(String eventId)
  {
      accountDetailsWrapper acctDetail = new accountDetailsWrapper();
      set<string> quoteIds = new set<string>();
      
      if(string.isNotBlank(eventId))
      {
          List<opportunity> opp = [select id,Name,Amount,Paid_Amount__c,SBQQ__PrimaryQuote__c from opportunity where  
                                      EventEdition__c=:eventId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
          List<boothOpptyWrapper> listBoothOpptyWrapper = new List<boothOpptyWrapper>();
          if(opp!=null && opp.size()>0){
              for(opportunity oppty: opp){
                  quoteIds.add(oppty.SBQQ__PrimaryQuote__c);
                  boothOpptyWrapper bow = new boothOpptyWrapper();
                  bow.opptyId = oppty.Id;
                  listBoothOpptyWrapper.add(bow);
              }
              
              list<double> listOppAmount = new list<double>();
           }
          if(opp!=null && opp.size()>0)
          {
              //List<ExpocadBooth__c> expoBooths = [Select Id,Booth_Number__c,Area__c,Unit_Type__c From ExpocadBooth__c where quote__c=:opp[0].SBQQ__PrimaryQuote__c];
              List<ExpocadBooth__c> expoBooths = [Select Id, Booth_Number__c, Area__c, Unit_Type__c, Opportunity__c, Opportunity__r.Name, Opportunity__r.createdDate, 
                                                         Display_Name__c, Status__c From  
                                                         ExpocadBooth__c where Status__c = 'Rented' AND quote__c IN:quoteIds order by Opportunity__r.createdDate ];
              
              List<boothDetailsWrapper> expoBoothWrpr =new List<boothDetailsWrapper>();
              //List<boothOpptyWrapper> listBoothOpptyWrapper = new List<boothOpptyWrapper>();
             
              if(expoBooths !=null && expoBooths.size()>0)              
              {
                  for(ExpocadBooth__c ecb: expoBooths)
                  {
                      boothDetailsWrapper bdw=new boothDetailsWrapper();
                      bdw.boothName=ecb.Booth_Number__c;
                      bdw.boothArea=ecb.Area__c;
                      bdw.unitType=ecb.Unit_Type__c;
                      bdw.boothId=ecb.Id;
                      bdw.oppty = ecb.Opportunity__r.Name;
                      expoBoothWrpr.add(bdw);
                   }
              }
             
              acctDetail.boothDetails=expoBoothWrpr;
              acctDetail.boothOppty = listBoothOpptyWrapper;
              system.debug('acctDetail='+acctDetail);
              
          }
          system.debug('acctDetail= no opp');
      }
      String JSONString = JSON.serialize(acctDetail);
      return JSONString ;
  }
  
  global class accountDetailsWrapper
  {
      public double amount{get;set;}
      public double remainingAmount{get;set;}
      public list<double> lstAmount{get; set;}
      public List<boothDetailsWrapper> boothDetails{get; set;}
      public List<boothOpptyWrapper> boothOppty{get; set;}
      public List<boothOpptyAmountWrapper> boothOpptyAmount{get; set;}
  }
  
  public class boothDetailsWrapper
  {
      public string boothId{get;set;}
      public string boothName{get;set;}
      public string boothArea{get;set;}
      public string unitType{get;set;}
      public string oppty{get;set;}
      public string displayName{get;set;}
      public string boothStatus{get;set;}
  }
  
  public class boothOpptyWrapper
  {
      public string opptyId{get;set;}
      
  }
  
  public class boothOpptyAmountWrapper
  {
      public double Amount{get;set;}
      public double remainingAmount{get; set;}
      
  }
  
}