/**
* File:        AggregateResultIterable.cls
* Project:     Informa Market (BAU GE)
* Date:		23-12-2020
* Created By : Rajesh Kumar 
* *************************************************************************
* Description:  using Apex classes that implement Iterator<AggregateResult> and Iterable<AggregateResult> seems the only way for now. 
* *************************************************************************
* History: BK-9619 Used in Batch Apex : ExpocadBoothAggregateBatch
*/
public class AggregateResultIterable implements Iterable<AggregateResult> {
  private String query;
  public String batchRunFor;
  public AggregateResultIterable(String soql, String runcondtn){
    query = soql;
    batchRunFor = runcondtn;   
  }

  public Iterator<AggregateResult> Iterator(){
    return new AggregateResultIterator(query,batchRunFor);
  }
}