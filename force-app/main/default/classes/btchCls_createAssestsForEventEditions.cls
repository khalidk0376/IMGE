/*

To create Assets records related to produtcs for all the closed won Opportunities of all event edition(s) who met their end date.
Developed By : Anuj
Last Modified By: [Aishwarya BK-3759 27 Aug 2020]
Test Class: test_ManagingAssets

*/
public class btchCls_createAssestsForEventEditions implements Database.Batchable<sObject>{

Public list<Asset> assetsList = new list<Asset>();  // To insert new created Assets
    
  public btchCls_createAssestsForEventEditions(){
      system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
  }
   
   public Database.QueryLocator start(Database.BatchableContext BC){
      string oppStageName = 'Closed Booked';
      string query ='select id,name,(Select id,name,stagename from Opportunities__r where StageName=\''+oppStageName+'\'' +') from Event_Edition__c where Check_Expiry__c = true';
      return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext BC, List<Event_Edition__c> scope){
       set<String> oppIdsSet = new set<String>(); // To store ids of closed won Opportunities
       list<id> productIdsList = new list<id>();
       map<id,decimal> prodQuoteLineMap = new map<id,decimal>(); // To capture Price for the Products
       map<string,string> evntMap = new map<string,string>(); // To capture id of event on basis of their name    
       map<id,id> eventAccMap = new map<id,id>(); // To capture related account for Event Edition
       map<id,product2> productMap = new map<id,product2>();
       map<id,decimal> prodQuantityMap = new map<id,decimal>();
       
       // Traversing all the end date met Event Editions    
       for(Event_Edition__c objEE : scope){
           for(Opportunity objOpp : objEE.Opportunities__r){
               oppIdsSet.add(objOpp.id);
           }
           evntMap.put(objEE.name,objEE.id); 
       }
       List<String> lstQLIID=new List<String>();
       Map<string,string> mapQLIProdAcc=new Map<string,string>();
       // Quering Quote Line Items for the Closed Booked Opportunties.
       for(SBQQ__QuoteLine__c objQLI : [select id,SBQQ__Product__c,SBQQ__Quantity__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Accountid,SBQQ__ListPrice__c,SBQQ__Quote__r.SBQQ__Account__c From SBQQ__QuoteLine__c Where SBQQ__Quote__r.SBQQ__Opportunity2__c IN : oppIdsSet]){           

           prodQuoteLineMap.put(objQLI.SBQQ__Product__c,objQLI.SBQQ__ListPrice__c);
           prodQuantityMap.put(objQLI.SBQQ__Product__c,objQLI.SBQQ__Quantity__c);
           mapQLIProdAcc.put(objQLI.Id,objQLI.SBQQ__Product__c+'#'+objQLI.SBQQ__Quote__r.SBQQ__Account__c);
           lstQLIID.add(objQLI.Id);
           productIdsList.add(objQLI.SBQQ__Product__c);
       }
       
       for(Product2 objProd : [select id,Name,Start_Date__c,End_Date__c,Product_Brand__c from product2 where id In : productIdsList]){
          productMap.put(objProd.id,objProd);
       }
       
       //Creating Assets for the Products
       for(string qliID : lstQLIID)
       {         
           string[] arrProdAcc=mapQLIProdAcc.get(qliID).split('#');
           id prodIds= arrProdAcc[0]; 
           Asset objAsset = new Asset();
           
           objAsset.Name = productMap.get(prodIds).name;
           objAsset.Product2Id = prodIds;
           objAsset.Accountid = arrProdAcc[1]; 
           
           if(productMap!=null){
               if(productMap.get(prodIds).Start_Date__c != null){
                   objAsset.Start_Date__c = productMap.get(prodIds).Start_Date__c;
               }
               if(productMap.get(prodIds).End_Date__c != null){
                   objAsset.End_Date__c = productMap.get(prodIds).End_Date__c;
               }
           }
           
           if(evntMap.containsKey(productMap.get(prodIds).Product_Brand__c)){objAsset.Event_Edition__c = evntMap.get(productMap.get(prodIds).Product_Brand__c);}
           if(prodQuantityMap != null){objAsset.Quantity = prodQuantityMap.get(prodIds);}
           if(prodQuoteLineMap!=null){objAsset.Price_Sold_Price__c = prodQuoteLineMap.get(prodIds);}
           
           assetsList.add(objAsset);
       }
       
       if(assetsList!=null && assetsList.size()>0){
           insert assetsList;
       }
   }

   public void finish(Database.BatchableContext BC){
       // Added by Palla Kishore for the ticket Bk-19604
          system.debug('Batch job completed successfully');
   }
}