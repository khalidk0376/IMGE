/**
 * Created/Modified By: Girikon(Amish,Pramod)
 * Created On:          11/9/2017
 * Description/Purpose: This class is used for managing the compulsury product related to a main product at the customer center
 * Methods:             getItems
 * Test Class:          CarouselCompulsoryProduct_Test
 **/

public class CarouselCompulsoryProduct{
    public String EventCode{get;set;}
    public String IsVisible{get;set;}
    //public String ProductId;
    //public String eventId;           
    public CarouselCompulsoryProduct(){
       getItems();
    }
    public List<SBQQ__ProductOption__c> optionList {get; set;}
    public List<Event_Edition__c> eventList{get; set;}
    
    public void getItems() 
    {   
        String ProductId= ApexPages.currentPage().getParameters().get('ProductId');            
        String  eventId= ApexPages.currentPage().getParameters().get('eventId'); 
        eventList= [SELECT Id,Event_Code__c,name from Event_Edition__c where Id=:eventId];  
        if(eventList!=null && eventList.size()>0)
            EventCode=eventList[0].Event_Code__c;                                      
        List<product2> productLst = [SELECT Id,Name,SBQQ__DefaultQuantity__c from product2 where Id=:ProductId];            
        List<SBQQ__ProductFeature__c> featureList = [SELECT Id from SBQQ__ProductFeature__c where SBQQ__ConfiguredSKU__c IN: productLst ];           
        //optionList = new List<SBQQ__ProductOption__c>([SELECT Id,SBQQ__Required__c, SBQQ__OptionalSKU__r.Product_Image_Link__c,SBQQ__Feature__r.Name, SBQQ__ProductFamily__c, SBQQ__Quantity__c, SBQQ__Type__c,SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Name, SBQQ__ProductName__c from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c IN: productLst and SBQQ__Required__c=true ]);                      
        optionList = new List<SBQQ__ProductOption__c>([SELECT Id,SBQQ__Required__c, SBQQ__OptionalSKU__r.Product_Image_Link__c,SBQQ__Feature__r.Name, SBQQ__ProductFamily__c, SBQQ__Quantity__c, SBQQ__Type__c,SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Name, SBQQ__ProductName__c from SBQQ__ProductOption__c where SBQQ__Feature__c IN: featureList AND SBQQ__ConfiguredSKU__c IN: productLst and SBQQ__Required__c=true ]);                      
        if(optionList!=null && optionList.size()>0)
            IsVisible='inherit';
        else
            IsVisible='none';
    }
}