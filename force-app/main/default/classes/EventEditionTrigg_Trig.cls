/*
* Created By   : Girikon[Adarsh BK-3756]
* Created On   : 01-06-2020
* @description : Whenever created Event edition and set prodcut with created event edition and pricebook or pricebook entrty in product after that set all configuration to fatch all currencies type in assiciated event edition .
* Test Class   : EventEditionTrigg_Test (81%)
* Modified By : Rajesh Kumar (BK-3756) on 04-06-2020
*/
public  Without Sharing class EventEditionTrigg_Trig implements TriggerInterface_EventEdition.Runnable {
    public Set < string > listISOcodes = new Set < string > ();
    public List < PricebookEntry > lstPriceBookEntry = new List < PricebookEntry > ();
    public set < string > sCurrency = new set < string > ();
    public Set < id > seid = new Set < id > ();
    public List < EventCurrecies__c > lstEventCurrecies = new List < EventCurrecies__c > ();
    public List < EventCurrecies__c > lstEventCurrency = new List < EventCurrecies__c > ();
    public List < Event_Edition__c > lstEvent = new List < Event_Edition__c > ();
    public Set < String > setEventIds = new Set < String > ();
    public Map < String, String > mapBoothProductType = new Map < String, String > ();

    public void run(TriggerInterface_EventEdition.Trig trig){    
        if (trig.isBefore && (trig.isInsert || trig.isUpdate)) {
            try{
                String Eventid;
                for (Event_Edition__c eed: trig.newMap.values()){
                    //add record id
                    seid.add(eed.id);
                    Eventid = eed.Id;
                    if (trig.isBefore && trig.isUpdate){
                        Event_Edition__c Oldeed = trig.oldMap.get(eed.Id);
                        if (!eed.Payment_Dates_Approved__c && (eed.Start_Date__c != null && eed.X50_Cutoff_Date__c != null  &&  Oldeed.X50_Cutoff_Date__c != eed.X50_Cutoff_Date__c && eed.X50_Cutoff_Date__c >= eed.Start_Date__c)){                            eed.Adderror('Payment Schedule 1 Cutoff Date 1 should not greater than start date.');
                        }
                        else if (!eed.Payment_Dates_Approved__c && (eed.Start_Date__c != null  && eed.CutoffDate__c != null && Oldeed.CutoffDate__c != eed.CutoffDate__c && eed.CutoffDate__c >= eed.Start_Date__c)){                            eed.Adderror('Payment Schedule 2 Cutoff Date 1 should not greater than start date.');
                        }
                        else if (!eed.Payment_Dates_Approved__c && (eed.Start_Date__c != null  && eed.Cutoff_Date_1__c != null &&  Oldeed.Cutoff_Date_1__c != eed.Cutoff_Date_1__c  &&  eed.Cutoff_Date_1__c  >= eed.Start_Date__c)){                            eed.Adderror('Payment Schedule 1 Cutoff Date 2 should not greater than start date.');
                        }
                        else if (!eed.Payment_Dates_Approved__c && (eed.Start_Date__c != null  && eed.CutoffDate_1__c != null && Oldeed.CutoffDate_1__c != eed.CutoffDate_1__c && eed.CutoffDate_1__c >= eed.Start_Date__c)){                            eed.Adderror('Payment Schedule 2 Cutoff Date 2 should not greater than start date.');
                        }
                        else if (!eed.Payment_Dates_Approved__c && (eed.Start_Date__c != null  && eed.Cutoff_Date_2__c != null && Oldeed.Cutoff_Date_2__c != eed.Cutoff_Date_2__c && eed.Cutoff_Date_2__c >= eed.Start_Date__c)){                            eed.Adderror('Payment Schedule 1 Cutoff Date 3 should not greater than start date.');
                        }
                        else if (!eed.Payment_Dates_Approved__c && (eed.Start_Date__c != null  && eed.CutoffDate_2__c != null && Oldeed.CutoffDate_2__c != eed.CutoffDate_2__c && eed.CutoffDate_2__c >= eed.Start_Date__c)){                            eed.Adderror('Payment Schedule 2 Cutoff Date 3 should not greater than start date.');
                        }
                        else if (!eed.Payment_Dates_Approved__c && (eed.Start_Date__c != null  && eed.Cutoff_Date_3__c != null && Oldeed.Cutoff_Date_3__c != eed.Cutoff_Date_3__c  && eed.Cutoff_Date_3__c >= eed.Start_Date__c)){                            eed.Adderror('Payment Schedule 1 Cutoff Date 4 should not greater than start date.');
                        }
                        else if (!eed.Payment_Dates_Approved__c && (eed.Start_Date__c != null  && eed.CutoffDate_3__c != null && Oldeed.CutoffDate_3__c != eed.CutoffDate_3__c && eed.CutoffDate_3__c >= eed.Start_Date__c)){                            eed.Adderror('Payment Schedule 2  Cutoff Date 4 should not greater than start date.');
                        }
                    }
                    if(trig.oldMap.get(eed.id).Booth_Product_Type__c != eed.Booth_Product_Type__c && eed.Booth_Product_Type__c!=Null){
                        for(String bpt : eed.Booth_Product_Type__c.split(';')){ 
                            setEventIds.add(bpt);
                        }
                        if(eed.Matched_Product_Name__c!=Null){ 
                            eed.Matched_Product_Name__c = Null;
                        }
                        
                    } else if(eed.Booth_Product_Type__c==Null){
                        eed.Matched_Product_Name__c = Null;
                    }
                }
                //Query from pricebookentry object and get all currencies type which is mapp with event edition.
                lstPriceBookEntry = [Select Product2.CurrencyIsoCode, CurrencyIsoCode, product2.name From PricebookEntry WHERE pricebook2.IsStandard = false AND Product2.Event_Edition__c IN: seid AND pricebook2Id IN(select id from Pricebook2 where isStandard = false)];
                //put the value in set
                for (PricebookEntry oprice: lstPriceBookEntry){
                    sCurrency.add(oprice.CurrencyIsoCode);
                    sCurrency.add(oprice.Product2.CurrencyIsoCode);
                }
                
                if (seid.size() > 0){
                    String sEventCurrency;
                    if (sCurrency != null && sCurrency.size() > 0 ){
                        Set < String > sECurrecies = new Set < String > ();
                        //there is already available currencies in event edition 
                        lstEventCurrecies = [SELECT Id, Name, Event_Edition__c From EventCurrecies__c Where Event_Edition__c =: seid];
                        if (lstEventCurrecies.size() > 0){
                            for (EventCurrecies__c oevnt: lstEventCurrecies)
                            {
                                sECurrecies.add(oevnt.Name);
                            }
                        }
                        
                        for (string stempCurrency: sCurrency){
                            if (sEventCurrency == null){
                                sEventCurrency = stempCurrency;}
                            else if (!sEventCurrency.contains(stempCurrency)){
                                sEventCurrency += ';' + stempCurrency;
                            }
                            if (!sECurrecies.contains(stempCurrency)){
                                EventCurrecies__c oEventCurrecies = new EventCurrecies__c();
                                oEventCurrecies.Name = stempCurrency;
                                oEventCurrecies.Event_Edition__c = Eventid;
                                lstEventCurrency.add(oEventCurrecies);
                            }
                        }
                    }
                    
                }
                
                
                //get currencies iso code
                for (Event_Edition__c ed : trig.newList ){
                    if (trig.oldMap != null){
                        //add currencies iso code 
                        if (trig.oldMap.get(ed.Id).Alternate_Currency__c != ed.Alternate_Currency__c) {
                            listISOcodes.add(ed.Alternate_Currency__c);
                        }
                    }
                    else {
                        listISOcodes.add(ed.Alternate_Currency__c);
                    }
                }
                
                if (listISOcodes.size() > 0) {
                    //get conversion rate from currencytype object
                    List < CurrencyType > currTypeList = new List < CurrencyType > ([SELECT ISoCode, ConversionRate FROM CurrencyType where IsoCode IN: listISOcodes]);
                    Map < string, decimal > currTypeMap = new Map < string, decimal > ();
                    for (CurrencyType ct: currTypeList){
                        currTypeMap.put(ct.IsoCode, ct.ConversionRate);
                    }
                    
                    for (Event_Edition__c eed1 : trig.newList ) {
                        //get conversion rate and updated 
                        decimal cRate = currTypeMap.get(eed1.Alternate_Currency__c);
                        if (cRate != null){
                            eed1.ConversionRate__c = cRate;
                        }
                    }
                }
                if (lstEventCurrency.size() > 0){
                    insert lstEventCurrency;
                }
                if( setEventIds.size()> 0 ){
                    List<Booth_Product_Type_Configuration__c> lstBoothPrdConfig = [select id, Booth_Product_Type__c,Matched_Product_Name__c from Booth_Product_Type_Configuration__c Where Booth_Product_Type__c IN:setEventIds];
                    if(lstBoothPrdConfig.size() > 0){
                        for(Booth_Product_Type_Configuration__c bptc : lstBoothPrdConfig){
                            mapBoothProductType.put(bptc.Booth_Product_Type__c, bptc.Matched_Product_Name__c);
                        }
                    }
                    for(Event_Edition__c edi: trig.newMap.values()){
                        for(string ed : edi.Booth_Product_Type__c.split(';')){
                            if(mapBoothProductType.size() > 0 && mapBoothProductType.containsKey(ed) && mapBoothProductType.get(ed)!=null){
                                edi.Matched_Product_Name__c = edi.Matched_Product_Name__c!=Null?edi.Matched_Product_Name__c+';'+mapBoothProductType.get(ed):mapBoothProductType.get(ed);
                            }
                        }
                    }
                }
            }
            catch (exception e){
                //BK-3754          
                Utility.logsError(e.getMessage(), e.getCause(), e.getLineNumber(), e.getStackTraceString(), 'EventEditionTrigg' , 'Integration');
            }
        }
        //trigger is running on after update event. so as to update the payment schedule on the already quotes when the event edition gets edited for payment schedule after the quote is created.
        if (trig.isAfter && trig.isUpdate){
            try{
                set < id > eeIdsSet = new set < id > ();  
                set < id > eeIds = new set < id > (); 
                set < id > setEventEditionIds = new set < id > ();
                List<WorkOrder> lstWorkOrderUpdate = new List<WorkOrder>();
                
                List<WorkOrderLineItem> lstWorkOrderLineItem = new List<WorkOrderLineItem>();
                List<Event_Edition__c> lstEventEditionUpdate = new List<Event_Edition__c>(); 
                
                for (Event_Edition__c ed: trig.newList){
                    Event_Edition__c oTempEventEdition = new Event_Edition__c();
                    //Quote in updated payment schedules.
                    if (ed.Payment_Schedule__c != trig.oldmap.get(ed.id).Payment_Schedule__c){
                        eeIdsSet.add(ed.id);
                    }
                    //get event edition id for update currencies iso code in event edition.
                    if (trig.oldmap.get(ed.id).EventCurrency__c != ed.EventCurrency__c ){
                        eeIds.add(ed.Id);
                    }
                    /**
                    * Modified By: Yash Gupta [As per ticket GGCW-2929] 
                    */
                    if ((trig.oldmap.get(ed.id).Event_Edition_Status__c != ed.Event_Edition_Status__c) && ed.Event_Edition_Status__c != '0' && ed.Event_Edition_Status__c == 'Completed'){
                        setEventEditionIds.add(ed.Id);
                    }
                }
                
                
                //call future class for update Qoute record.
                // FutureClass.myFutureMethod(eeIdsSet);
                
                //update currencies iso code when user select available currencies in evenedition.
                if (eeIds != null && eeIds.size() > 0 ){
                    List<Event_Edition__c> lstevents = [select id , EventCurrency__r.Name , EventCurrency__c , CurrencyIsoCode from  Event_Edition__c Where Id IN : eeIds ];
                    if (lstevents != null && lstevents.size() > 0){
                        for (Event_Edition__c oevent : lstevents){
                            oevent.CurrencyIsoCode = oevent.EventCurrency__r.Name;
                            lstEvent.add(oevent);   
                        }
                        
                    }
                }
                if (lstEvent != null && lstEvent.size() > 0){
                    update lstEvent;
                }
                
                /**
                * Modified By: Yash Gupta [As per ticket GGCW-2929] 
                * description update work orders and its line items status to "Cannot Complete" on the basis of condition.
                */
                if(setEventEditionIds.size() > 0){
                    System.debug('setEventEditionIds' + setEventEditionIds);
                    List<WorkOrder> lstWorkOrder = [SELECT Id, Status, Event_Edition__c, (SELECT Id, Status FROM WorkOrderLineItems) FROM WorkOrder Where Event_Edition__c IN : setEventEditionIds AND (Status = 'New' OR Status= 'In Progress' OR Status = 'On Hold')];
                    System.debug('lstWorkOrder' + lstWorkOrder);
                    if(lstWorkOrder.size() > 0){
                        for(WorkOrder wo : lstWorkOrder){
                            wo.Status = 'Cannot Complete';
                            lstWorkOrderUpdate.add(wo);
                            if(wo.WorkOrderLineItems.size() > 0){
                                for(WorkOrderLineItem woi : wo.WorkOrderLineItems){
                                    woi.Status = 'Cannot Complete';
                                    lstWorkOrderLineItem.add(woi);
                                }
                            }
                        }
                    }
                    if(lstWorkOrderUpdate.size() > 0){ 
                        update lstWorkOrderUpdate;
                    }
                    if(lstWorkOrderLineItem.size() > 0){
                        update lstWorkOrderLineItem;
                    }
                }
                
            }
            catch (exception e)
            {
                //BK-3754          
                Utility.logsError(e.getMessage(), e.getCause(), e.getLineNumber(), e.getStackTraceString(), 'EventEditionTrigg' , 'Integration');
            }
        }
    }
}