/**
* Project:     GAP
* Date:        29/9/2017
* Created By:  Abdul Kadir
* Test class   CongaUtilities_Test.cls
* *************************************************************************
* Description: This class provide utility methods for conga classes.
* *************************************************************************
* History:Modified By : Rajesh Kumar 21/02/2019 on GGCW-GGCW-2997
          Modified By : Avinash Shukla 19/8/2019 on GGCW-1950
*/
public class CongaUtilities {
    
    /**
    * @description check for null for billing contact address.
    * @param  contactId
    * @return Boolean
    */
    public static Boolean isBillingAddressNull(String contactId){
        
        Contact billingContact;
        boolean billingContactFlag=true;
        if(String.isNotBlank(contactId)){
            
            billingContact = [select id,MailingStreet,MailingCity,MailingPostalCode,MailingCountry from Contact where id=:contactId limit 1];
            
        }
        // Removed [&& String.isNotBlank(billingContact.MailingPostalCode)]
        if(billingContact != null && (String.isNotBlank(billingContact.MailingStreet) && String.isNotBlank(billingContact.MailingCity) && String.isNotBlank(billingContact.MailingCountry))){
            billingContactFlag=false;
        }
        
        return billingContactFlag;
    }
    
    
    /**
    * @description This method will calculate the cut off date and amount.
    * @param 
    * @return pageReference
    */
    public void cutoffDates(String QId,boolean cpayment){
        Map<Date, Double> mapAmount;
        Map<Date, Double> mapPercent;
        Map<Date,Decimal> mapAmountEMI ;
        String quoteId = QId;
        Boolean customPayment=cpayment;
        SBQQ__Quote__c oQuote1;
        Decimal dAmountToPay ;
        Decimal dPartialAmountToPay ;
        Boolean isPartialAmount ;
        
        dAmountToPay = dPartialAmountToPay = 0;
        isPartialAmount = true;
        mapAmountEMI = new Map<Date,Decimal>();
        date Cutoff_Date1 ;
        date Cutoff_Date2 ;
        date Cutoff_Date3 ;
        date Cutoff_Date4 ;
        Integer InvoiceIssuedBefore = 0;
        List<String> lstPaymentPercent = new List<String>();
        if(quoteId !=null && !customPayment){
            oQuote1 = [select id,Name,ISO_Code_Logo__c,CurrencyIsoCode,Product_Attachments__c,SBQQ__PrimaryContact__c,Primary_Contact_Info__c,documentType__c,Next_Version__c,conga_quote_template_id__c,conga_contract_template_id__c,Quote_Event_Edition__c,Is_a_Local_Company__c , Payment_Schedule_amount__c, Payment_Schedule_percent1__c, Payment_Schedule_percent__c ,Cutoff_Date__c , Cutoff_Date_1__c , Cutoff_Date_2__c , Cutoff_Date_3__c , SBQQ__NetAmount__c ,ISO_Code__c ,Payment_Schedule_amount1__c , SBQQ__Opportunity2__c , EE_Payment_Schedule__c ,SBQQ__Opportunity2__r.EventEdition__c, Payment_Schedule_Revised__c,InvoicetoStartDate__c,Invoice_to_Start_Date_Cut_Off_Date1__c,Invoice_to_Start_Date_Cut_Off_Date2__c,Invoice_to_Start_Date_Cut_Off_Date3__c, Invoice_to_be_issued_before_in_Days__c,SBQQ__Opportunity2__r.stageName,SBQQ__Status__c, SBQQ__Opportunity2__r.Is_Barter_Opportunity__c,SBQQ__Opportunity2__r.Custom_Payment__c,invoice_payment1__c,invoice_payment2__c,invoice_payment3__c,invoice_payment4__c,invoice_payment5__c,invoice_payment6__c,invoice_payment7__c,invoice_payment8__c,invoice_payment9__c,invoice_payment10__c,invoice_payment11__c,invoice_payment12__c, ES_Company_Country__c from SBQQ__Quote__c where id =:quoteId limit 1];
            
            dAmountToPay = oQuote1.SBQQ__NetAmount__c;
            oQuote1.invoice_payment1__c = null;
            oQuote1.invoice_payment2__c = null;
            oQuote1.invoice_payment3__c = null;
            oQuote1.invoice_payment4__c = null;
            oQuote1.invoice_payment5__c = null;
            oQuote1.invoice_payment6__c = null;
            oQuote1.invoice_payment7__c = null;
            oQuote1.invoice_payment8__c = null;
            oQuote1.invoice_payment9__c = null;
            oQuote1.invoice_payment10__c = null;
            oQuote1.invoice_payment11__c = null;
            oQuote1.invoice_payment12__c = null;
            if(!oQuote1.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c && oQuote1.SBQQ__Opportunity2__r.Custom_Payment__c==false && oQuote1.EE_Payment_Schedule__c!=null){
                if ( oQuote1.EE_Payment_Schedule__c != '100'){
                    Cutoff_Date1 = oQuote1.InvoicetoStartDate__c;
                }
                else {
                    Cutoff_Date1 = Date.today();
                }
                
                Cutoff_Date2 = oQuote1.Invoice_to_Start_Date_Cut_Off_Date1__c;
                Cutoff_Date3 = oQuote1.Invoice_to_Start_Date_Cut_Off_Date2__c;
                Cutoff_Date4 = oQuote1.Invoice_to_Start_Date_Cut_Off_Date3__c ;
                if(oQuote1.Invoice_to_be_issued_before_in_Days__c != Null){
                    InvoiceIssuedBefore = Integer.ValueOf(oQuote1.Invoice_to_be_issued_before_in_Days__c) ;
                }
                
                if(!String.isBlank(oQuote1.EE_Payment_Schedule__c) && oQuote1.EE_Payment_Schedule__c != '100'){
                    lstPaymentPercent = oQuote1.EE_Payment_Schedule__c.split('-');
                }
                else{
                    lstPaymentPercent.add(oQuote1.EE_Payment_Schedule__c);
                    System.debug('test Rajesh payment EE_Payment_Schedule__c : ' + lstPaymentPercent);
                    System.debug('test Rajesh payment EE_Payment_Schedule__c conga: ' + lstPaymentPercent.size());
                }
                       
                
                if(dAmountToPay != null && !lstPaymentPercent.isEmpty() && (Cutoff_Date1 != null || Cutoff_Date2 != null || Cutoff_Date3 != null || Cutoff_Date4 != null)){
                    
                    List<Date> lstQualifiedDate = new List<Date>();
                    Date currentdate = Date.today();
                    if(Cutoff_Date1 == Null || Cutoff_Date1 <= currentdate){
                        lstQualifiedDate.add(currentdate);
                        System.debug('test Rajesh :2  ' +  lstPaymentPercent.size());
                    }
                    else if(lstPaymentPercent.size() >= 1){
                        lstQualifiedDate.add(Cutoff_Date1);
                        System.debug('test Rajesh :  ' +  lstPaymentPercent.size());
                    }
                    
                    if(currentdate <= Cutoff_Date2 && lstPaymentPercent.size() >= 2){ lstQualifiedDate.add(Cutoff_Date2); }
                    if(currentdate <= Cutoff_Date3 && lstPaymentPercent.size() >= 3){ lstQualifiedDate.add(Cutoff_Date3); }
                    if(currentdate <= Cutoff_Date4 && lstPaymentPercent.size() >= 4){ lstQualifiedDate.add(Cutoff_Date4); }
                    
                    
                    Decimal dTempAmount = 0;
                    Decimal dAmount = 0;
                    Decimal dScaleAmount = 0;
                    Integer iDateSize = lstQualifiedDate.size();
                    Integer iPaymentPercentSize= lstPaymentPercent.size();
                    for(Integer i=0 ; i<iPaymentPercentSize; i++){
                        if(iDateSize >= iPaymentPercentSize){
                            dTempAmount = ((dAmountToPay * (Decimal.ValueOf(lstPaymentPercent.get(i))/100))+dScaleAmount);
                            //dScaleAmount = (dTempAmount - dTempAmount.round(System.RoundingMode.DOWN));
                            Decimal dActual = dTempAmount;
                            dTempAmount = dTempAmount.setscale(2);
                            dScaleAmount = dActual - dTempAmount ;
                            if(i != (iPaymentPercentSize-1))
                            { 
                                //mapAmountEMI.put(lstQualifiedDate.get(i),this.CurrencyFormat(dTempAmount.round(System.RoundingMode.DOWN))); 
                                mapAmountEMI.put(lstQualifiedDate.get(i),dTempAmount); 
                            }
                            else if(i == (iPaymentPercentSize-1)){
                                mapAmountEMI.put(lstQualifiedDate.get(i),this.CurrencyFormat(dTempAmount)); 
                            }
                        }
                        else{
                            if(i+1 <= (iPaymentPercentSize - iDateSize)){
                                dAmount += (dAmountToPay * (Decimal.ValueOf(lstPaymentPercent.get(i))/100)); 
                            }
                            else if(dAmount != 0){
                                dTempAmount = ((dAmountToPay * (Decimal.ValueOf(lstPaymentPercent.get(i))/100))+dScaleAmount+dAmount); 
                                //dScaleAmount = (dTempAmount - dTempAmount.round(System.RoundingMode.DOWN));
                                Decimal dActual = dTempAmount;
                                dTempAmount = dTempAmount.setscale(2);
                                dScaleAmount = dActual - dTempAmount ;
                                if(i != (iPaymentPercentSize-1)){ 
                                    //mapAmountEMI.put(lstQualifiedDate.get(i-(iPaymentPercentSize - iDateSize)), this.CurrencyFormat(dTempAmount.round(System.RoundingMode.DOWN)));
                                    mapAmountEMI.put(lstQualifiedDate.get(i-(iPaymentPercentSize - iDateSize)), dTempAmount);
                                }
                                else if(i == (iPaymentPercentSize-1)){
                                    mapAmountEMI.put(lstQualifiedDate.get(i-(iPaymentPercentSize - iDateSize)),this.CurrencyFormat(dTempAmount)); 
                                }
                                dAmount = 0;
                            } else {
                                dTempAmount = ((dAmountToPay * (Decimal.ValueOf(lstPaymentPercent.get(i))/100))+dScaleAmount); 
                                //dScaleAmount = (dTempAmount - dTempAmount.round(System.RoundingMode.DOWN));
                                Decimal dActual = dTempAmount;
                                dTempAmount = dTempAmount.setscale(2);
                                dScaleAmount = dActual - dTempAmount ;
                                if(i != (iPaymentPercentSize-1)){
                                    //mapAmountEMI.put(lstQualifiedDate.get(i-(iPaymentPercentSize - iDateSize)),this.CurrencyFormat(dTempAmount.round(System.RoundingMode.DOWN))); 
                                    mapAmountEMI.put(lstQualifiedDate.get(i-(iPaymentPercentSize - iDateSize)),dTempAmount);
                                }
                                else if(i == (iPaymentPercentSize-1)){
                                    mapAmountEMI.put(lstQualifiedDate.get(i-(iPaymentPercentSize - iDateSize)),this.CurrencyFormat(dTempAmount)); 
                                }
                            }
                        }
                    }
                    String sFinaldate = '';
                    String sFinaldatePercent = '';
                    Integer dTempPerccent = 0;
                    List<Integer> lstTemp = new List<Integer>();
                    List<Date> lstDate = new List<Date>();
                    lstDate.addAll(mapAmountEMI.Keyset());
                    
                    for(Integer i = 0; i < lstPaymentPercent.size(); i++){
                        if(lstPaymentPercent.size() - i >= mapAmountEMI.size()){
                            dTempPerccent += Integer.Valueof(lstPaymentPercent.get(i));
                        }
                        else{ 
                            lstTemp.add(Integer.Valueof(lstPaymentPercent.get(i))); 
                        }
                    }
                    String sDateFormat = 'dd/MM/yyyy';
                    if(oQuote1.ES_Company_Country__c != NULL){
                        Country_Date_Format__c oDateFormat = Country_Date_Format__c.getValues(oQuote1.ES_Company_Country__c);
                        if(oDateFormat != Null && !String.isBlank(oDateFormat.Date_Format__c))
                            sDateFormat = oDateFormat.Date_Format__c ;
                    }
                    if(Cutoff_Date1 == Null || Cutoff_Date1 <= currentdate){
                        sFinaldate = String.ValueOf(dTempPerccent)+'%';
                        sFinaldatePercent = String.ValueOf(dTempPerccent)+'% Immediate Payment.';
                    }
                    else if(lstPaymentPercent.size() >= 1){
                        sFinaldate = String.ValueOf(dTempPerccent)+'%';
                        sFinaldatePercent = String.ValueOf(dTempPerccent)+'% Payable by '+DateTime.newInstance(lstDate.get(0)+InvoiceIssuedBefore, Time.newInstance(0,0,0,0)).format(sDateFormat);
                    }
                    for(Integer i=0; i< lstTemp.size(); i++){
                        sFinaldate += '\n'+ String.ValueOf(lstTemp.get(i))+'%' ;
                        sFinaldatePercent += '\n'+ String.ValueOf(lstTemp.get(i))+'% Payable by '+DateTime.newInstance(lstDate.get(i+1)+InvoiceIssuedBefore, Time.newInstance(0,0,0,0)).format(sDateFormat); 
                    }
                    oQuote1.Payment_Schedule_percent1__c = sFinaldate;
                    oQuote1.Payment_Schedule_Revised__c = sFinaldatePercent ;
                    
                    String sFinal = '';
                    List<Decimal> paymentList = new List<Decimal>();
                    if(mapAmountEMI.size() == 0){ 
                        mapAmountEMI.put(currentdate, dAmountToPay.round(System.RoundingMode.DOWN)); 
                    }
                    for(Decimal dTempAmt : mapAmountEMI.Values()){
                        sFinal += oQuote1.ISO_Code_Logo__c +' '+dTempAmt.setScale(2)+'\n' ;
                        paymentList.add(dTempAmt);
                    }
                    
                    oQuote1.invoice_payment1__c = paymentList.size()>=1?paymentList.get(0):null;
                    oQuote1.invoice_payment2__c = paymentList.size()>=2?paymentList.get(1):null;
                    oQuote1.invoice_payment3__c = paymentList.size()>=3?paymentList.get(2):null;
                    oQuote1.invoice_payment4__c = paymentList.size()>=4?paymentList.get(3):null;
                    
                    oQuote1.invoice_Percentage1__c = dTempPerccent!=null?dTempPerccent:null;
                    oQuote1.invoice_Percentage2__c = lstTemp.size()>=1?lstTemp.get(0):null;
                    oQuote1.invoice_Percentage3__c = lstTemp.size()>=2?lstTemp.get(1):null;
                    oQuote1.invoice_Percentage4__c = lstTemp.size()>=3?lstTemp.get(2):null;
                    
                    oQuote1.Payment_Schedule_amount1__c = sFinal;
                    
                    Update oQuote1;
                }
            }
            else{
                oQuote1.Payment_Schedule_percent1__c = '100%';
                oQuote1.Payment_Schedule_Revised__c =  '100% Immediate Payment.';
                oQuote1.Payment_Schedule_amount1__c = oQuote1.ISO_Code_Logo__c+' '+dAmountToPay;
                oQuote1.invoice_payment1__c=oQuote1.SBQQ__NetAmount__c.round(System.RoundingMode.DOWN);
                oQuote1.invoice_Percentage1__c = 100;
                
                Update oQuote1;
            }
        }else{
            customPayments(quoteId);
        }
        
    }
    
    /**
    * @description This method will calculate the custom payment date and amount.
    * @param 
    * @return pageReference
    */
    public void customPayments(String QId){
        
        List<CustomPaymentWrapper> cpw = new List<CustomPaymentWrapper>();
        List<CustomPaymentWrapper> cpwImmediateList= new List<CustomPaymentWrapper>();
        List<CustomPaymentWrapper> cpwNonImmediateList= new List<CustomPaymentWrapper>();
        String quoteId=QId;
        SBQQ__Quote__c oQuote1;
        Decimal immediatePayment=0;
        Decimal immediatePercentage=0;
        String remainingPaymentStr='';
        String remainingPercentage='';
        String remainingAmt='';
        Integer InvoiceIssuedBefore = 0;
        
        if(quoteId !=null){
            oQuote1 = [select id, Payment_Schedule_amount__c,ISO_Code_Logo__c, Payment_Schedule_percent1__c, Payment_Schedule_percent__c ,Cutoff_Date__c , Cutoff_Date_1__c , Cutoff_Date_2__c , Cutoff_Date_3__c , SBQQ__NetAmount__c ,ISO_Code__c ,Payment_Schedule_amount1__c , SBQQ__Opportunity2__c , EE_Payment_Schedule__c ,SBQQ__Opportunity2__r.EventEdition__c, Payment_Schedule_Revised__c,InvoicetoStartDate__c,Invoice_to_Start_Date_Cut_Off_Date1__c,Invoice_to_Start_Date_Cut_Off_Date2__c,Invoice_to_Start_Date_Cut_Off_Date3__c,Invoice_to_Start_Date_Cut_Off_Date4__c,Invoice_to_Start_Date_Cut_Off_Date5__c,Invoice_to_Start_Date_Cut_Off_Date6__c,Invoice_to_Start_Date_Cut_Off_Date7__c,Invoice_to_Start_Date_Cut_Off_Date8__c,Invoice_to_Start_Date_Cut_Off_Date9__c,Invoice_to_Start_Date_Cut_Off_Date10__c,Invoice_to_Start_Date_Cut_Off_Date11__c, Invoice_to_be_issued_before_in_Days__c,SBQQ__Opportunity2__r.stageName,SBQQ__Status__c, SBQQ__Opportunity2__r.Is_Barter_Opportunity__c,SBQQ__Opportunity2__r.Custom_Payment__c,SBQQ__Opportunity2__r.Total_No_of_payment__c,SBQQ__Opportunity2__r.Milestone_1_Amount__c,SBQQ__Opportunity2__r.Milestone_2_Amount__c,SBQQ__Opportunity2__r.Milestone_3_Amount__c,SBQQ__Opportunity2__r.Milestone_4_Amount__c,SBQQ__Opportunity2__r.Milestone_5_Amount__c,SBQQ__Opportunity2__r.Milestone_6_Amount__c,SBQQ__Opportunity2__r.Milestone_7_Amount__c,SBQQ__Opportunity2__r.Milestone_8_Amount__c,SBQQ__Opportunity2__r.Milestone_9_Amount__c,SBQQ__Opportunity2__r.Milestone_10_Amount__c,SBQQ__Opportunity2__r.Milestone_11_Amount__c,SBQQ__Opportunity2__r.Milestone_12_Amount__c,invoice_payment1__c,invoice_payment2__c,invoice_payment3__c,invoice_payment4__c,invoice_payment5__c,invoice_payment6__c,invoice_payment7__c,invoice_payment8__c,invoice_payment9__c,invoice_payment10__c,invoice_payment11__c,invoice_payment12__c 
                       ,SBQQ__Opportunity2__r.Milestone_1_Percent__c,SBQQ__Opportunity2__r.Milestone_2_Percent__c,SBQQ__Opportunity2__r.Milestone_3_Percent__c
                       ,SBQQ__Opportunity2__r.Milestone_4_Percent__c,SBQQ__Opportunity2__r.Milestone_5_Percent__c,SBQQ__Opportunity2__r.Milestone_6_Percent__c
                       ,SBQQ__Opportunity2__r.Milestone_7_Percent__c,SBQQ__Opportunity2__r.Milestone_8_Percent__c,SBQQ__Opportunity2__r.Milestone_9_Percent__c
                       ,SBQQ__Opportunity2__r.Milestone_10_Percent__c,SBQQ__Opportunity2__r.Milestone_11_Percent__c,SBQQ__Opportunity2__r.Milestone_12_Percent__c ,ES_Company_Country__c from SBQQ__Quote__c where id =:quoteId limit 1];
            
            Date currentdate = Date.today();
            if(!oQuote1.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c){
                
                if(oQuote1.Invoice_to_be_issued_before_in_Days__c != Null){
                    InvoiceIssuedBefore = Integer.ValueOf(oQuote1.Invoice_to_be_issued_before_in_Days__c) ;
                }
                
                if(oQuote1.InvoicetoStartDate__c!=null && oQuote1.SBQQ__Opportunity2__r.Milestone_1_Amount__c!=null){
                    if(oQuote1.InvoicetoStartDate__c <= currentdate){
                        immediatePayment = oQuote1.SBQQ__Opportunity2__r.Milestone_1_Amount__c;
                        immediatePercentage = oQuote1.SBQQ__Opportunity2__r.Milestone_1_Percent__c;
                    }else{
                        cpw.add(new CustomPaymentWrapper(oQuote1.InvoicetoStartDate__c,oQuote1.SBQQ__Opportunity2__r.Milestone_1_Amount__c,oQuote1.SBQQ__Opportunity2__r.Milestone_1_Percent__c));
                        
                    }
                }
                if(oQuote1.Invoice_to_Start_Date_Cut_Off_Date1__c!=null && oQuote1.SBQQ__Opportunity2__r.Milestone_2_Amount__c!=null){
                    cpw.add(new CustomPaymentWrapper(oQuote1.Invoice_to_Start_Date_Cut_Off_Date1__c,oQuote1.SBQQ__Opportunity2__r.Milestone_2_Amount__c,oQuote1.SBQQ__Opportunity2__r.Milestone_2_Percent__c));
                    
                }
                if(oQuote1.Invoice_to_Start_Date_Cut_Off_Date2__c!=null && oQuote1.SBQQ__Opportunity2__r.Milestone_3_Amount__c!=null){
                    cpw.add(new CustomPaymentWrapper(oQuote1.Invoice_to_Start_Date_Cut_Off_Date2__c,oQuote1.SBQQ__Opportunity2__r.Milestone_3_Amount__c,oQuote1.SBQQ__Opportunity2__r.Milestone_3_Percent__c));
                    
                }
                if(oQuote1.Invoice_to_Start_Date_Cut_Off_Date3__c!=null && oQuote1.SBQQ__Opportunity2__r.Milestone_4_Amount__c!=null){
                    cpw.add(new CustomPaymentWrapper(oQuote1.Invoice_to_Start_Date_Cut_Off_Date3__c,oQuote1.SBQQ__Opportunity2__r.Milestone_4_Amount__c,oQuote1.SBQQ__Opportunity2__r.Milestone_4_Percent__c));
                    
                }
                if(oQuote1.Invoice_to_Start_Date_Cut_Off_Date4__c!=null && oQuote1.SBQQ__Opportunity2__r.Milestone_5_Amount__c!=null){
                    cpw.add(new CustomPaymentWrapper(oQuote1.Invoice_to_Start_Date_Cut_Off_Date4__c,oQuote1.SBQQ__Opportunity2__r.Milestone_5_Amount__c,oQuote1.SBQQ__Opportunity2__r.Milestone_5_Percent__c));
                    
                }
                if(oQuote1.Invoice_to_Start_Date_Cut_Off_Date5__c!=null && oQuote1.SBQQ__Opportunity2__r.Milestone_6_Amount__c!=null){
                    cpw.add(new CustomPaymentWrapper(oQuote1.Invoice_to_Start_Date_Cut_Off_Date5__c,oQuote1.SBQQ__Opportunity2__r.Milestone_6_Amount__c,oQuote1.SBQQ__Opportunity2__r.Milestone_6_Percent__c));
                    
                }
                if(oQuote1.Invoice_to_Start_Date_Cut_Off_Date6__c!=null && oQuote1.SBQQ__Opportunity2__r.Milestone_7_Amount__c!=null){
                    cpw.add(new CustomPaymentWrapper(oQuote1.Invoice_to_Start_Date_Cut_Off_Date6__c,oQuote1.SBQQ__Opportunity2__r.Milestone_7_Amount__c,oQuote1.SBQQ__Opportunity2__r.Milestone_7_Percent__c));
                    
                }
                if(oQuote1.Invoice_to_Start_Date_Cut_Off_Date7__c!=null && oQuote1.SBQQ__Opportunity2__r.Milestone_8_Amount__c!=null){
                    cpw.add(new CustomPaymentWrapper(oQuote1.Invoice_to_Start_Date_Cut_Off_Date7__c,oQuote1.SBQQ__Opportunity2__r.Milestone_8_Amount__c,oQuote1.SBQQ__Opportunity2__r.Milestone_8_Percent__c));
                    
                }
                if(oQuote1.Invoice_to_Start_Date_Cut_Off_Date8__c!=null && oQuote1.SBQQ__Opportunity2__r.Milestone_9_Amount__c!=null){
                    cpw.add(new CustomPaymentWrapper(oQuote1.Invoice_to_Start_Date_Cut_Off_Date8__c,oQuote1.SBQQ__Opportunity2__r.Milestone_9_Amount__c,oQuote1.SBQQ__Opportunity2__r.Milestone_9_Percent__c));
                    
                }
                if(oQuote1.Invoice_to_Start_Date_Cut_Off_Date9__c!=null && oQuote1.SBQQ__Opportunity2__r.Milestone_10_Amount__c!=null){
                    cpw.add(new CustomPaymentWrapper(oQuote1.Invoice_to_Start_Date_Cut_Off_Date9__c,oQuote1.SBQQ__Opportunity2__r.Milestone_10_Amount__c,oQuote1.SBQQ__Opportunity2__r.Milestone_10_Percent__c));
                    
                }
                if(oQuote1.Invoice_to_Start_Date_Cut_Off_Date10__c!=null && oQuote1.SBQQ__Opportunity2__r.Milestone_11_Amount__c!=null){
                    cpw.add(new CustomPaymentWrapper(oQuote1.Invoice_to_Start_Date_Cut_Off_Date10__c,oQuote1.SBQQ__Opportunity2__r.Milestone_11_Amount__c,oQuote1.SBQQ__Opportunity2__r.Milestone_11_Percent__c));
                    
                }
                if(oQuote1.Invoice_to_Start_Date_Cut_Off_Date11__c!=null && oQuote1.SBQQ__Opportunity2__r.Milestone_12_Amount__c!=null){
                    cpw.add(new CustomPaymentWrapper(oQuote1.Invoice_to_Start_Date_Cut_Off_Date11__c,oQuote1.SBQQ__Opportunity2__r.Milestone_12_Amount__c,oQuote1.SBQQ__Opportunity2__r.Milestone_12_Percent__c));
                    
                }
                
                String sDateFormat = 'dd/MM/yyyy';
                if(oQuote1.ES_Company_Country__c != NULL){
                    Country_Date_Format__c oDateFormat = Country_Date_Format__c.getValues(oQuote1.ES_Company_Country__c);
                    if(oDateFormat != Null && !String.isBlank(oDateFormat.Date_Format__c))
                        sDateFormat = oDateFormat.Date_Format__c ;
                }
                
                List<Decimal> invoicePaymentList = new List<Decimal>();
                List<Decimal> invoicePercentageList = new List<Decimal>();
                for(CustomPaymentWrapper temp : cpw){
                    if(currentdate <= temp.milestoneDate){
                        temp.immediatePayment=false;
                        remainingPaymentStr+=String.valueOf(temp.milestonePercent.setScale(2))+'% Payable by '+DateTime.newInstance( temp.milestoneDate+InvoiceIssuedBefore, Time.newInstance(0,0,0,0)).format(sDateFormat)+'\n';
                        remainingPercentage+=String.valueOf(temp.milestonePercent.setScale(2))+'%'+'\n';
                        remainingAmt+=oQuote1.ISO_Code_Logo__c+String.valueOf(temp.milestoneAmount)+'\n';
                        invoicePaymentList.add(temp.milestoneAmount);
                        invoicePercentageList.add((temp.milestonePercent));
                        
                        
                    }else{
                        temp.immediatePayment=true;
                        immediatePayment += temp.milestoneAmount;
                        immediatePercentage += temp.milestonePercent!=null?temp.milestonePercent:0.0;
                        
                    }
                }
                
                if(immediatePayment > 0.00 ){
                    oQuote1.invoice_payment1__c = immediatePayment;
                    oQuote1.invoice_payment2__c = invoicePaymentList.size()>=1?invoicePaymentList.get(0):null;
                    oQuote1.invoice_payment3__c = invoicePaymentList.size()>=2?invoicePaymentList.get(1):null;
                    oQuote1.invoice_payment4__c = invoicePaymentList.size()>=3?invoicePaymentList.get(2):null;
                    oQuote1.invoice_payment5__c = invoicePaymentList.size()>=4?invoicePaymentList.get(3):null;
                    oQuote1.invoice_payment6__c = invoicePaymentList.size()>=5?invoicePaymentList.get(4):null;
                    oQuote1.invoice_payment7__c = invoicePaymentList.size()>=6?invoicePaymentList.get(5):null;
                    oQuote1.invoice_payment8__c = invoicePaymentList.size()>=7?invoicePaymentList.get(6):null;
                    oQuote1.invoice_payment9__c = invoicePaymentList.size()>=8?invoicePaymentList.get(7):null;
                    oQuote1.invoice_payment10__c = invoicePaymentList.size()>=9?invoicePaymentList.get(8):null;
                    oQuote1.invoice_payment11__c = invoicePaymentList.size()>=10?invoicePaymentList.get(9):null;
                    oQuote1.invoice_payment12__c = invoicePaymentList.size()>=11?invoicePaymentList.get(10):null;
                    
                    oQuote1.invoice_Percentage1__c = immediatePercentage;
                    oQuote1.invoice_Percentage2__c = invoicePercentageList.size()>=1?invoicePercentageList.get(0):null;
                    oQuote1.invoice_Percentage3__c = invoicePercentageList.size()>=2?invoicePercentageList.get(1):null;
                    oQuote1.invoice_Percentage4__c = invoicePercentageList.size()>=3?invoicePercentageList.get(2):null;
                    oQuote1.invoice_Percentage5__c = invoicePercentageList.size()>=4?invoicePercentageList.get(3):null;
                    oQuote1.invoice_Percentage6__c = invoicePercentageList.size()>=5?invoicePercentageList.get(4):null;
                    oQuote1.invoice_Percentage7__c = invoicePercentageList.size()>=6?invoicePercentageList.get(5):null;
                    oQuote1.invoice_Percentage8__c = invoicePercentageList.size()>=7?invoicePercentageList.get(6):null;
                    oQuote1.invoice_Percentage9__c = invoicePercentageList.size()>=8?invoicePercentageList.get(7):null;
                    oQuote1.invoice_Percentage10__c = invoicePercentageList.size()>=9?invoicePercentageList.get(8):null;
                    oQuote1.invoice_Percentage11__c = invoicePercentageList.size()>=10?invoicePercentageList.get(9):null;
                    oQuote1.invoice_Percentage12__c = invoicePercentageList.size()>=11?invoicePercentageList.get(10):null;
                }else{
                    oQuote1.invoice_payment1__c = invoicePaymentList.size()>=1?invoicePaymentList.get(0):null;
                    oQuote1.invoice_payment2__c = invoicePaymentList.size()>=2?invoicePaymentList.get(1):null;
                    oQuote1.invoice_payment3__c = invoicePaymentList.size()>=3?invoicePaymentList.get(2):null;
                    oQuote1.invoice_payment4__c = invoicePaymentList.size()>=4?invoicePaymentList.get(3):null;
                    oQuote1.invoice_payment5__c = invoicePaymentList.size()>=5?invoicePaymentList.get(4):null;
                    oQuote1.invoice_payment6__c = invoicePaymentList.size()>=6?invoicePaymentList.get(5):null;
                    oQuote1.invoice_payment7__c = invoicePaymentList.size()>=7?invoicePaymentList.get(6):null;
                    oQuote1.invoice_payment8__c = invoicePaymentList.size()>=8?invoicePaymentList.get(7):null;
                    oQuote1.invoice_payment9__c = invoicePaymentList.size()>=9?invoicePaymentList.get(8):null;
                    oQuote1.invoice_payment10__c = invoicePaymentList.size()>=10?invoicePaymentList.get(9):null;
                    oQuote1.invoice_payment11__c = invoicePaymentList.size()>=11?invoicePaymentList.get(10):null;
                    oQuote1.invoice_payment12__c = invoicePaymentList.size()>=11?invoicePaymentList.get(11):null;
                    
                    oQuote1.invoice_Percentage1__c = invoicePercentageList.size()>=1?invoicePercentageList.get(0):null;
                    oQuote1.invoice_Percentage2__c = invoicePercentageList.size()>=2?invoicePercentageList.get(1):null;
                    oQuote1.invoice_Percentage3__c = invoicePercentageList.size()>=3?invoicePercentageList.get(2):null;
                    oQuote1.invoice_Percentage4__c = invoicePercentageList.size()>=4?invoicePercentageList.get(3):null;
                    oQuote1.invoice_Percentage5__c = invoicePercentageList.size()>=5?invoicePercentageList.get(4):null;
                    oQuote1.invoice_Percentage6__c = invoicePercentageList.size()>=6?invoicePercentageList.get(5):null;
                    oQuote1.invoice_Percentage7__c = invoicePercentageList.size()>=7?invoicePercentageList.get(6):null;
                    oQuote1.invoice_Percentage8__c = invoicePercentageList.size()>=8?invoicePercentageList.get(7):null;
                    oQuote1.invoice_Percentage9__c = invoicePercentageList.size()>=9?invoicePercentageList.get(8):null;
                    oQuote1.invoice_Percentage10__c = invoicePercentageList.size()>=10?invoicePercentageList.get(9):null;
                    oQuote1.invoice_Percentage11__c = invoicePercentageList.size()>=11?invoicePercentageList.get(10):null;
                    oQuote1.invoice_Percentage12__c = invoicePercentageList.size()>=11?invoicePercentageList.get(11):null;
                }
                
                
                
                oQuote1.Payment_Schedule_percent1__c = immediatePercentage > 0.0 ? immediatePercentage.setScale(2)+'%'+'\n'+remainingPercentage : remainingPercentage;
                oQuote1.Payment_Schedule_Revised__c =  immediatePercentage > 0.0 ? String.valueOf(immediatePercentage.setScale(2))+'% Immediate Payment.'+'\n'+remainingPaymentStr : remainingPaymentStr;
                oQuote1.Payment_Schedule_amount1__c = immediatePayment > 0.0 ? oQuote1.ISO_Code_Logo__c+immediatePayment+'\n'+remainingAmt : remainingAmt;
                Update oQuote1;
                
                
            }
            else{
                oQuote1.Payment_Schedule_percent1__c = '100%';
                oQuote1.Payment_Schedule_Revised__c =  '100% Immediate Payment.';
                oQuote1.Payment_Schedule_amount1__c = oQuote1.ISO_Code_Logo__c+' '+oQuote1.SBQQ__NetAmount__c.round(System.RoundingMode.DOWN);
                oQuote1.invoice_payment1__c=oQuote1.SBQQ__NetAmount__c.round(System.RoundingMode.DOWN);
                oQuote1.invoice_Percentage1__c = 100;
                
                Update oQuote1;
            }
        }
        
    }
    
    
    
    /**
    * @description This method will formate decimal value to 2 scale.
    * @param dParamAmount
    * @return Decimal
    */
    public Decimal CurrencyFormat(Decimal dParamAmount){
        Decimal dFormatedAmount = dParamAmount;
        dFormatedAmount = dFormatedAmount.setscale(4);
        return dFormatedAmount;
    }
    
    /**
    * @description This method will return Locale on basis of Country Name.
    * @param dParamAmount
    * @return Decimal
    */
    public String CountryLocale(String country){
        String countryLocale='';
        try{
            //Modified By : Avinash Shukla 19/8/2019 on GGCW-1950
            if(Country_locales__c.getValues(country.trim()).locale__c != NULL) { countryLocale = Country_locales__c.getValues(country.trim()).locale__c; }
            
        }catch(Exception ex){
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'CongaUtilities(@CountryLocale)');
            return System.LABEL.ES_Country_not_valid;
        }
        return countryLocale.trim();
    }
    /**
    * @description This method will update Local Name on the Quote Line Item.
    * @param prodIdQuoteLineMap
    * @return 
    */
    public void getProductLocalName(Map<Id,SBQQ__QuoteLine__c> prodIdQuoteLineMap){
        List<SBQQ__QuoteLine__c> qLineUpdates=new List<SBQQ__QuoteLine__c>();
        Set<Id> qLineUpdatesSet=new Set<Id>();
        for(SBQQ__Localization__c localeObj : [select id,SBQQ__Product__c,SBQQ__Text__c,SBQQ__LongTextArea__c,SBQQ__Description__c from SBQQ__Localization__c where SBQQ__Product__c IN : prodIdQuoteLineMap.keySet() and SBQQ__APIName__c ='Name' and SBQQ__Text__c!=null]){
            if(localeObj.SBQQ__Text__c!=null && !qLineUpdatesSet.contains(localeObj.SBQQ__Product__c)){
                SBQQ__QuoteLine__c temp = prodIdQuoteLineMap.get(localeObj.SBQQ__Product__c);
                temp.Product_Local_Name__c=localeObj.SBQQ__Text__c;
                qLineUpdatesSet.add(localeObj.SBQQ__Product__c);
                qLineUpdates.add(temp);
            }
            
        }
        if(!qLineUpdates.isEmpty()){
            update qLineUpdates;
        }
        
    }
    
    /**
    * @description This wrapper class use to hold the payment schedule date and amount .
    * @param 
    * @return 
    */
    public class CustomPaymentWrapper {
        public Date milestoneDate {get; set;}
        public Decimal milestoneAmount {get; set;}
        public Decimal milestonePercent {get; set;}
        public Boolean immediatePayment{get;set;}
        
        public CustomPaymentWrapper(Date aDate, Decimal amount, Decimal percent) {
            milestoneDate = aDate;
            milestoneAmount = amount;
            milestonePercent = percent;
        }
    }
    
    
    /**
    * @description This method Will give indirect account.
    * @param directAccountId
    * @return list of Account
    */
    public List<Account> AddressSelection(String billingContactId,String accountId){
        Set<String> IndirectContactIDSet = new Set<String>();
        List<String> IndirectAccountIDList = new List<String>();
        List<Account> allAccountList = new List<Account>();
        
        if(billingContactId!=null && billingContactId!='' && accountId!=null){
            IndirectAccountIDList.add(accountId);
            for(Contact con : [select accountId from Contact where id=:billingContactId]){
                if(!accountId.equals(con.accountId))
                    IndirectAccountIDList.add(con.accountId);
            }
        }
        
        if(!IndirectAccountIDList.isEmpty())
            allAccountList = [select Id,Name,BillingStreet,Billing_Address_Line_2__c,BillingCity,BillingState,Billingpostalcode,BillingCountry,type from Account where id IN : IndirectAccountIDList];
        if(!allAccountList.isEmpty()){
            
            return allAccountList;
        }
        return null;
    }
    
    
    
}