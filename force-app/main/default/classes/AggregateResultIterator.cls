/**
* File:        AggregateResultIterator.cls
* Project:     Informa Market (BAU GE)
* Date:		23-12-2020
* Created By : Rajesh Kumar 
* *************************************************************************
* Description:  using Apex classes that implement Iterator<AggregateResult> and Iterable<AggregateResult> seems the only way for now. 
* *************************************************************************
* History: BK-9619 Used in Batch Apex : ExpocadBoothAggregateBatch
*/
public class AggregateResultIterator implements Iterator<AggregateResult> {
  AggregateResult [] results {get;set;}
  // tracks which result item is returned
  Integer index {get; set;} 
  public String batchRunFor;     
  public AggregateResultIterator(String query,String runcondtn) {
    index = 0;
    batchRunFor = runcondtn;    
    results = Database.query(query);            
  } 

  public boolean hasNext(){ 
    return results != null && !results.isEmpty() && index < results.size(); 
  }    

  public AggregateResult next(){        
    return results[index++];            
  }       
}