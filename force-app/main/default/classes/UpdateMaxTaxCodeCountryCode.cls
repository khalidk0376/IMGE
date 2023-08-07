/**
* Class Name: UpdateMaxTaxCodeCountryCode
* Created By : Rajesh Kumar 
* Created Date : 03-09-2020
* Test Class: .InvoiceHandlerFromQuote_Test
* Ticket : BK-6918
* **************************************************************************************************************************
* @description MOdified By Rajesh Kumar on 01-12-2020 Bk-11310

  Modified by - Shiv raghav bk-6941 04/12/2020
Modified by - Shiv raghav sharma for Bk-16003 20/5/2020

* **************************************************************************************************************************
**/
public without sharing class UpdateMaxTaxCodeCountryCode {

    //Added BY Rajesh Kumar - BK-6918 - Date - 03-09-2020

    public static void maxrollupsummery (List<blng__InvoiceLine__c> lstInvoiceLine , Map<Id, blng__InvoiceLine__c> mapOldValuesInvoiceLine , Boolean isInsert , Boolean isupdate , Boolean isAfter, Boolean isBefore){


        set<id> ids=new set<id>();
        set<id> setinvoiceIdsBooth=new set<id>();
        List<blng__Invoice__c> invupdate=new List<blng__Invoice__c>();
        List<blng__Invoice__c> invupdated=new List<blng__Invoice__c>();
        Map<String, Integer> myMap = new Map<String,Integer>();
        Map<String, Integer> myMapcode = new Map<String,Integer>();
        Map<String, Integer> myMapPrimaryTAX = new Map<String,Integer>();
        Map<String, Integer> myMapSecondaryTAX = new Map<String,Integer>();
        List<String> lstTaxCode = new List<String>();
        List<String> lstTaxCountryCode = new List<String>();
        List<String> lstPrimaryTaxRate = new List<String>();
        List<String> lstSecondaryTaxRate = new List<String>();
        String sInvoiceIds = '';
        String sInvoiceIdsBooth = '';
        for(blng__InvoiceLine__c invline: lstInvoiceLine){
            // We have reset value after send tax call "After select tax status is equal to Queued"
            if (IsBefore){
                if (Isupdate && invline.blng__TaxStatus__c == 'Queued'){
                    invline.SAP_Tax_Code__c = '';
                    invline.SAP_Tax_Country__c = '';
                    invline.SAP_Primary_Tax_Rate__c = '';
                    invline.SAP_Secondary_Tax_Rate__c = '';
                    invline.Tax_Exempt_SAP__c = false;
                    sInvoiceIds = invline.blng__Invoice__c;
                }
            }
            if (IsAfter){
                if(IsInsert) {

                    if ((String.isNotBlank(invline.SAP_Tax_Code__c) || String.isNotBlank(invline.SAP_Tax_Country__c))){
                        ids.add(invline.blng__Invoice__c);
                    }
                    //Bk-16003 
                    if(String.isNotBlank(invline.UOM__c) && (invline.UOM__c == 'M2' || invline.UOM__c == 'F2'))
                    {
                        sInvoiceIdsBooth = invline.blng__Invoice__c; 

                    }                    
                }    
                if(Isupdate)
                {
                    if(((String.isNotBlank(invline.SAP_Tax_Code__c) && invline.SAP_Tax_Code__c != mapOldValuesInvoiceLine.get(invline.Id).SAP_Tax_Code__c ) || (String.isNotBlank(invline.SAP_Tax_Country__c) && invline.SAP_Tax_Country__c != mapOldValuesInvoiceLine.get(invline.Id).SAP_Tax_Country__c ))) {
                        ids.add(invline.blng__Invoice__c);
                    }
                }
            }
        }
        //bk-16003
        String soql = 'Select id, SAP_Tax_Country__c , SAP_Tax_Code__c, SAP_Primary_Tax_Rate__c,SAP_Secondary_Tax_Rate__c , InformaTRN__c , Contains_Booth_Product__c  from blng__Invoice__c';
        
        if(!string.isBlank(sInvoiceIdsBooth)) {
            soql = soql +  ' WHERE Id =  \''+string.escapeSingleQuotes(sInvoiceIdsBooth) +'\''; 
        }
        if(!string.isBlank(sInvoiceIds)) {
            soql = soql +  ' WHERE Id =  \''+string.escapeSingleQuotes(sInvoiceIds) +'\''; 
        }
        //Query Invoice for Getting required value from mentioned fields.  
        System.debug('Rajesh ++++' + soql); 
        if (!string.isBlank(sInvoiceIds) || !string.isBlank(sInvoiceIdsBooth)){
            List<blng__Invoice__c> lstInvoice =  Database.query(soql);
            for (blng__Invoice__c oInvoice :lstInvoice ){
                if(oInvoice.Contains_Booth_Product__c == false) {
                    oInvoice.Contains_Booth_Product__c = true;
                }
                if (IsBefore && Isupdate){
                    oInvoice.SAP_Tax_Country__c = '';
                    oInvoice.SAP_Tax_Code__c  = '';
                    oInvoice.SAP_Primary_Tax_Rate__c = '';
                    oInvoice.SAP_Secondary_Tax_Rate__c = '';
                    oInvoice.InformaTRN__c = '';
                }
                invupdated.add(oInvoice);
            }
            update invupdated;
        }
        if (isAfter){
            for (blng__InvoiceLine__c oinvline : [SELECT  Id , SAP_Tax_Code__c, SAP_Tax_Country__c, SAP_Primary_Tax_Rate__c,SAP_Secondary_Tax_Rate__c  FROM blng__InvoiceLine__c where blng__Invoice__c in:ids ]){
                if(String.isNotBlank(oinvline.SAP_Tax_Code__c)){
                    lstTaxCode.add(oinvline.SAP_Tax_Code__c);
                }
                if(String.isNotBlank(oinvline.SAP_Tax_Country__c)){
                    lstTaxCountryCode.add(oinvline.SAP_Tax_Country__c);
                }
                if(String.isNotBlank(oinvline.SAP_Primary_Tax_Rate__c)){
                    lstPrimaryTaxRate.add(oinvline.SAP_Primary_Tax_Rate__c);
                }
                if(String.isNotBlank(oinvline.SAP_Secondary_Tax_Rate__c)){
                    lstSecondaryTaxRate.add(oinvline.SAP_Secondary_Tax_Rate__c);
                }
            }

            Set<String> strSetTaxCode = new Set<String>();
            Set<String> strSetCountryCode = new Set<String>();
            Set<string> setPrimaryTaxRate = new Set<String>();
            Set<string> setSecondaryTaxRate = new Set<String>();

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
            if (i_values.size() > 0 ){
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
            string staxcode ;
            //get the max value of the count
            if (i_valuestax.size() >0 ){
                Integer i_max_valuecode = i_valuestax[(i_valuestax.size()-1)];
                for(String stax : myMap.keySet()){
                    Integer saptaxcode = myMap.get(stax);
                    if(saptaxcode == i_max_valuecode){
                        System.debug(' The Maximum value is' + stax + 'and repeated ' + saptaxcode + 'times' );
                        staxcode= stax;
                        
                    }    
                }
            }
            if (ids.size() > 0){
                 // bk-6941
                Map<String , Tax_Mapping_Configuration__c> tableofTaxMappingRecords = New Map<String , Tax_Mapping_Configuration__c>();
                String sPrimaryTaxRate = sSAPPrimaryTaxes.remove('%');
                Decimal dPrimaryTaxRate = Decimal.valueOf(sPrimaryTaxRate);
                
                for(Tax_Mapping_Configuration__c taxData : [Select id,Tax_Code__c,Tax_Country__c,Primary_Tax_Rate__c,Local_Currency_ISO_Code__c,Secondary_Tax_Rate__c,Tax_Text__c , Tax_Registration_No__c from Tax_Mapping_Configuration__c where  Tax_Code__c = : staxcode AND Tax_Country__c = : staxcountrycode  AND Primary_Tax_Rate__c = : dPrimaryTaxRate]){ 

                    String str = taxData.Tax_Code__c+taxData.Tax_Country__c+taxData.Primary_Tax_Rate__c;
                    System.debug('TaxMappingStr' +str);
                    tableofTaxMappingRecords.put(str , taxData);
                }
                for (blng__Invoice__c oInvoice :[Select id, Active__c , CurrencyIsoCode,ShowReverseCharge__c,VAT_Country_Conga__c, SAP_Tax_Country__c , SAP_Tax_Code__c, SAP_Primary_Tax_Rate__c,SAP_Secondary_Tax_Rate__c,Event_Series_Alternate_Currency__c, InformaTRN__c from blng__Invoice__c where Id IN : ids]){
                    if(!String.isBlank(staxcountrycode) || !String.isBlank(staxcode) || !String.isBlank(sSAPPrimaryTaxes) || !String.isBlank(sSapSecondaryTaxes) ){
                        oInvoice.SAP_Tax_Country__c = staxcountrycode;
                        oInvoice.SAP_Tax_Code__c  = staxcode;
                        oInvoice.SAP_Primary_Tax_Rate__c = sSAPPrimaryTaxes;
                        oInvoice.SAP_Secondary_Tax_Rate__c = sSapSecondaryTaxes;
                    }
                    
                    String strtax  = '';
                    if (oInvoice.SAP_Primary_Tax_Rate__c != '' && oInvoice.SAP_Primary_Tax_Rate__c != null){
                        strtax = oInvoice.SAP_Primary_Tax_Rate__c.remove('%');
                    }
                    String mergeString = oInvoice.SAP_Tax_Code__c+oInvoice.SAP_Tax_Country__c+strtax;                
                    System.debug('mergeString' +mergeString);            
                    if(tableofTaxMappingRecords.containsKey(mergeString)){

                        if (tableofTaxMappingRecords.get(mergeString).Tax_Registration_No__c != ''){
                            oInvoice.InformaTRN__c = tableofTaxMappingRecords.get(mergeString).Tax_Registration_No__c;
                        }

                        if(oInvoice.Active__c && oInvoice.CurrencyIsoCode != tableofTaxMappingRecords.get(mergeString).Local_Currency_ISO_Code__c) {
                            oInvoice.Event_Series_Alternate_Currency__c = tableofTaxMappingRecords.get(mergeString).Local_Currency_ISO_Code__c ;                   
                        }
                        
                        if (oinvoice.ShowReverseCharge__c == true) {
                            oinvoice.VAT_Country_Conga__c = System.label.UK_VAT;
                        }
                        else{          
                            oInvoice.VAT_Country_Conga__c = tableofTaxMappingRecords.get(mergeString).Tax_Text__c;
                        }
                    }            
                    invupdate.add(oInvoice);  
                }   
                if(invupdate.size() >0 ) {
                    update invupdate;
                }
            } 
        }
    }
}