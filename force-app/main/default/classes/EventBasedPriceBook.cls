/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          7/20/2017
 * Description/Purpose: This class is called through the SKUID page: Event_Edition_Product_List
 *                      This Class is for capturing pricebook as per the eventIDs
 * Methods:             EventBasedPriceBook
 * Test Class:          EventBasedPriceBook_Test
 **/

Global class EventBasedPriceBook
{
    webservice static string eventPriceBook(String eventId)
    {
        list<Event_Edition__c> eventList= [select id,Name,Event_Price_Book__r.Name from Event_Edition__c where id =: eventId];
        list<Pricebook2> priceList = [select id,Name from Pricebook2 where Name =:eventList[0].Event_Price_Book__r.Name];      // list of pricebook as per "Event_Price_Book__r.Name"   from eventList
        List<PriceDetailWrapper> proWrapper=new List<PriceDetailWrapper>();
        // adding pricebook to the wrapper class
        if(priceList != null && priceList.size()>0)      
        {
        system.debug('amish');
            for(Pricebook2 price : priceList )
            {
                PriceDetailWrapper pDetail=new PriceDetailWrapper();
                      pDetail.Id=price.id;
                      pDetail.Name=price.Name;                                   
                      proWrapper.add(pDetail);                 
            }
        }
        system.debug(proWrapper);
        String JSONString = JSON.serialize(proWrapper);
        system.debug(JSONString );
        return JSONString; // returning in JSON format
    }
    // wrapper class to add pricebook
    global class PriceDetailWrapper
    {
        public String Id{get;set;}
        public String Name{get;set;}      
    }      
}