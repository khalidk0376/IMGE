/**
* Class Name: PopulateLegalEntity_class
* Created By : Rajesh Kumar 
* Created Date : 13/02/2019
* Test Class: InvoiceHandlerFromQuote_Test.
* Ticket :GGCW-3124
* Update By:  Shiv Raghav Sharma (Bk-3460) Modified By - Rajesh Kumar - on 30-07-2020 to BK-6532
* **************************************************************************************************************************
* @description This class is used to do the functionality of Process builder "SFB Populate Legal Entity on Order Product v2" 
* **************************************************************************************************************************
**/

public without sharing class PopulateLegalEntity_class {
    /**
     * [updateLegalEntity description called method from trigger]
     */
    public static void updateLegalEntity(List<OrderItem> lstorderItems){ 
        try{
            List<OrderItem> orderProLists = new List<OrderItem>();
            Map<Id, OrderItem > mapOrderProducts = new Map<Id, OrderItem>([Select Id ,blng__InvoiceGroupId__c , Order.OrderNumber , blng__LegalEntity__c,SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__Product__r.LegalEntityLookup__c from  OrderItem where Id IN : lstorderItems]); 
            if(mapOrderProducts.size() > 0){
                for(OrderItem ordProLst : mapOrderProducts.values()){
                    if (ordProLst.SBQQ__QuoteLine__c != null && OrdProLst.SBQQ__QuoteLine__r.SBQQ__Product__r.LegalEntityLookup__c != null){
                        OrdProLst.blng__LegalEntity__c = OrdProLst.SBQQ__QuoteLine__r.SBQQ__Product__r.LegalEntityLookup__c;
                    }
                    ordProLst.blng__InvoiceGroupId__c = ordProLst.Order.OrderNumber;  
                    orderProLists.add(ordProLst);
                }
            }
            
            if (!orderProLists.IsEmpty()){
                 update orderProLists;
            }
        }
        catch (Exception ex){           Utility.logsError(Ex.getMessage(), Ex.getCause(), Ex.getLineNumber(), Ex.getStackTraceString(), 'PopulateLegalEntity_class' , 'Integration');       }
    }
    //Added BY Rajesh Kumar - BK-6918 - Date - 03-09-2020
    public static void maxrollupsummery (List<OrderItem> lstorderItems , Map<Id, OrderItem> mapOldValuesOrderitem , Boolean IsInsert , Boolean Isupdate){
        set<id> ids=new set<id>();
        List<Order> orderupdate=new List<Order>();
        Map<String, Integer> myMap = new Map<String,Integer>();
        Map<String, Integer> myMapcode = new Map<String,Integer>();
        Map<String, Integer> myMapPrimaryTAX = new Map<String,Integer>();
        Map<String, Integer> myMapSecondaryTAX = new Map<String,Integer>();
        List<String> lstTaxCode = new List<String>();
        List<String> lstTaxCountryCode = new List<String>();
        List<String> lstPrimaryTaxRate = new List<String>();
        List<String> lstSecondaryTaxRate = new List<String>();
        Set<string> setPrimaryTaxRate = new Set<String>();
        Set<string> setSecondaryTaxRate = new Set<String>();
		boolean DifferentialTaxonOrderLines = false;
        for(OrderItem otm: lstorderItems){

            if (IsInsert && (String.isNotBlank(otm.SAP_Tax_Code__c) || String.isNotBlank(otm.SAP_Tax_Country__c) )){ ids.add(otm.OrderId); }
            if(Isupdate && ((String.isNotBlank(otm.SAP_Tax_Code__c) && otm.SAP_Tax_Code__c != mapOldValuesOrderitem.get(otm.Id).SAP_Tax_Code__c) || (String.isNotBlank(otm.SAP_Tax_Country__c) && otm.SAP_Tax_Country__c != mapOldValuesOrderitem.get(otm.Id).SAP_Tax_Country__c) ))  {


                ids.add(otm.OrderId);
            }
        }
        



        for (OrderItem orderitems : [SELECT orderId ,SAP_Tax_Code__c, SAP_Tax_Country__c, SAP_Primary_Tax_Rate__c,SAP_Secondary_Tax_Rate__c  FROM OrderItem where OrderId in:ids]){


            if(String.isNotBlank(orderitems.SAP_Tax_Code__c)){
                lstTaxCode.add(orderitems.SAP_Tax_Code__c);
            }
            if(String.isNotBlank(orderitems.SAP_Tax_Country__c)){
                lstTaxCountryCode.add(orderitems.SAP_Tax_Country__c);
            }
            if(String.isNotBlank(orderitems.SAP_Primary_Tax_Rate__c)){
                lstPrimaryTaxRate.add(orderitems.SAP_Primary_Tax_Rate__c);
            }
            if(String.isNotBlank(orderitems.SAP_Secondary_Tax_Rate__c)){
                lstSecondaryTaxRate.add(orderitems.SAP_Secondary_Tax_Rate__c);
            }
        }

        Set<String> strSetTaxCode = new Set<String>();
        Set<String> strSetCountryCode = new Set<String>();

        for (string settemp : lstTaxCode){
            strSetTaxCode.add(settemp);
        }

        for (string settempcode : lstTaxCountryCode){
            strSetCountryCode.add(settempcode);
        }
        
        for (String sPrimaryTax :lstPrimaryTaxRate ){
            setPrimaryTaxRate.add(sPrimaryTax);
        }
        for (String sSecondaryTax :lstSecondaryTaxRate ){
            setSecondaryTaxRate.add(sSecondaryTax);
        }

        for(String str: strSetTaxCode){
            Integer countofChar = 0;
            for(String strl: lstTaxCode ){
               if(str == strl){
                 countofChar++;
               }
            }
            myMap.put(str, countofChar);
        }

        for(String strcode: strSetCountryCode){
            Integer countofCharccode = 0;
            for(String strl: lstTaxCountryCode ){
               if(strcode == strl){
                countofCharccode++;
               }
            }
            myMapcode.put(strcode, countofCharccode);
        }
        for(String strPrimary: setPrimaryTaxRate){
            Integer countofChar = 0;
            for(String strlPr: lstPrimaryTaxRate ){
               if(strPrimary == strlPr){
                 countofChar++;
                }
				else{
				  DifferentialTaxonOrderLines = true;
				}
            }
            myMapPrimaryTAX.put(strPrimary, countofChar);
        }
        for(String strSecondaryTax: setSecondaryTaxRate){
            Integer countofChar = 0;
            for(String strl: lstSecondaryTaxRate ){
               if(strSecondaryTax == strl){
                 countofChar++;

                }
            }
            myMapSecondaryTAX.put(strSecondaryTax, countofChar);
        }
        
        List<Integer> i_valuesPrimaryTax = myMapPrimaryTAX.values();
        i_valuesPrimaryTax.sort();
        //get the max value of the count
        string sSAPPrimaryTaxes ;
        if (i_valuesPrimaryTax.size() > 0 ){
            Integer i_max_value = i_valuesPrimaryTax[(i_valuesPrimaryTax.size()-1)];
            for(String sSAPPrimaryTax : myMapPrimaryTAX.keySet()){
                Integer isapSecondaryTax = myMapPrimaryTAX.get(sSAPPrimaryTax);
                if(isapSecondaryTax == i_max_value){
                    System.debug(' The Maximum value is' + sSAPPrimaryTax + 'and repeated for Primary Tax ' + isapSecondaryTax + 'times' );
                    sSAPPrimaryTaxes=sSAPPrimaryTax;
                }
            }
        }
        
        List<Integer> i_valuesSecondary = myMapSecondaryTAX.values();
        i_valuesSecondary.sort();
        //get the max value of the count
        string sSapSecondaryTaxes ;
        if (i_valuesSecondary.size() > 0 ){
            Integer i_max_value = i_valuesSecondary[(i_valuesSecondary.size()-1)];
            for(String sSapSecondary : myMapSecondaryTAX.keySet()){
                Integer isapSecondaryTax = myMapSecondaryTAX.get(sSapSecondary);
                if(isapSecondaryTax == i_max_value){
                    System.debug(' The Maximum value is' + sSapSecondary + 'and repeated for Secondary Tax ' + isapSecondaryTax + 'times' );
                    sSapSecondaryTaxes=sSapSecondary;
                }
            }
        }

        List<Integer> i_values = myMapcode.values();
        i_values.sort();
        //get the max value of the count
        string staxcountrycode ;
        if(i_values.size() > 0){
            Integer i_max_value = i_values[(i_values.size()-1)];
            for(String scountrycode : myMapcode.keySet()){
                Integer sapTaxCountryCode = myMapcode.get(scountrycode);
                if(sapTaxCountryCode == i_max_value){
                    System.debug(' The Maximum value is' + scountrycode + 'and repeated ' + sapTaxCountryCode + 'times' );
                    staxcountrycode=scountrycode;
                }
            }
        }
        

        List<Integer> i_valuestax = myMap.values();
        i_valuestax.sort();
        //get the max value of the count
        string staxcode ;
        if(i_valuestax.size() > 0){
            Integer i_max_valuecode = i_valuestax[(i_valuestax.size()-1)];
            for(String stax : myMap.keySet()){
                Integer saptaxcode = myMap.get(stax);
                if(saptaxcode == i_max_valuecode){
                    System.debug(' The Maximum value is' + stax + 'and repeated ' + saptaxcode + 'times' );
                    staxcode= stax;
                }
            }
        }
        

        for (Order ord :[Select id, SAP_Tax_Country__c , Differential_Tax_on_Order_Lines__c, SAP_Tax_Code__c, SAP_Primary_Tax_Rate__c, SAP_Secondary_Tax_Rate__c from Order where Id IN : ids]){
            if(!String.isBlank(staxcountrycode) || !String.isBlank(staxcode) ){
                ord.SAP_Tax_Country__c = staxcountrycode;
                ord.SAP_Tax_Code__c  = staxcode;
            }
            ord.SAP_Primary_Tax_Rate__c = sSAPPrimaryTaxes;
            ord.SAP_Secondary_Tax_Rate__c = sSapSecondaryTaxes;
			ord.Differential_Tax_on_Order_Lines__c = DifferentialTaxonOrderLines;
            orderupdate.add(ord);
        }    
        update orderupdate;
    }  
    //Making a blank after selection of Queued in TAX Status.
    public static void resetSAPTAXCallFields (List<OrderItem> lstorderItems){

        set<id> setOrderIds=new set<id>();
        List<Order> orderupdateblank=new List<Order>();

        for(OrderItem oritm : lstorderItems){
            if (oritm.blng__TaxStatus__c == 'Queued'){
                oritm.SAP_Tax_Code__c = '';
                oritm.SAP_Tax_Country__c = '';
                oritm.SAP_Primary_Tax_Rate__c = '';
                oritm.SAP_Secondary_Tax_Rate__c = '';

                oritm.Tax_Exempt_SAP__c = false;
                setOrderIds.add(oritm.OrderId);
            }
        }
        for (Order ord :[Select id, SAP_Tax_Country__c , Differential_Tax_on_Order_Lines__c,SAP_Tax_Code__c, SAP_Primary_Tax_Rate__c, SAP_Secondary_Tax_Rate__c from Order where Id IN : setOrderIds]){
            ord.SAP_Tax_Country__c = '';
            ord.SAP_Tax_Code__c  = '';
            ord.SAP_Primary_Tax_Rate__c = '';
            ord.SAP_Secondary_Tax_Rate__c = '';
            ord.Differential_Tax_on_Order_Lines__c = false;
            orderupdateblank.add(ord);
        }
        update orderupdateblank;

    }
}