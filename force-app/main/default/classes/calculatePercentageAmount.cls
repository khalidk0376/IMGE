/**
 * This class calculate the percentage of amount
 * @Author      : Abdul Kadir
 * @Date        : 27/Apr/2018
 * Test Class   : FileUploadCtrl_Test
 * Code cover   : 82% 
 */
public class calculatePercentageAmount{

    public decimal getTax(Decimal Amount,string sPaymentSch,string per ){

    List<RounUp> lstTaxAmt = new List<RounUp>();
    List<RounUp> roundlstTaxAmt = new List<RounUp>();
    
    //Decimal Amount = 27.57;
    //String sPaymentSch ='10-90';
    List<String> lstPaymentSch = sPaymentSch.split('-');
    decimal calculateTotal = 0;
    for(Integer i=0; i<lstPaymentSch.Size(); i++){
        Integer iTocal = Integer.valueOf(lstPaymentSch.get(i));
        Double calAmt= ((Amount*iTocal)/100).setScale(2);
        calculateTotal += calAmt;
        lstTaxAmt.add(new RounUp(''+(i+1),calAmt));
    }

    System.debug(lstTaxAmt);
    System.debug(Amount-calculateTotal);
    Decimal lftAmountRounded= Amount-calculateTotal;
        
    if(lftAmountRounded != 0){
         Decimal amountPerObject = ( lftAmountRounded / lstTaxAmt.size()  ).setScale(2);
         Decimal leftOverAmountRounded = (lftAmountRounded - amountPerObject * lstTaxAmt.size()).setScale(2, System.RoundingMode.HALF_UP); 
        for (RounUp obj : lstTaxAmt ) {
           
            Decimal extraAmount;
            System.debug('InvoiceUtilities.distributeCurrencyAmount leftOverAmountRounded: ' + leftOverAmountRounded);
            if (leftOverAmountRounded != 0) {
                Decimal additionalAmount = leftOverAmountRounded > 0
                    ? 0.01
                    : -0.01;
                extraAmount = amountPerObject + additionalAmount;

                leftOverAmountRounded -= additionalAmount;
            } else {
                extraAmount = amountPerObject;
            }

            System.debug('InvoiceUtilities.distributeCurrencyAmount extraAmount: ' + extraAmount);
            Decimal currentAmount = obj.dAmount;  //(Decimal)obj.get(currencyField);
            System.debug('InvoiceUtilities.distributeCurrencyAmount currentAmount: ' + currentAmount);
            roundlstTaxAmt.add(new RounUp(obj.sPerscent, currentAmount+ extraAmount));
        }   
     }

Decimal calVal= 0;

     
if( lftAmountRounded!=0){
    for(Integer i=0; i<roundlstTaxAmt.Size(); i++){
       if(roundlstTaxAmt.get(i).sPerscent==per){
        calVal= roundlstTaxAmt.get(i).dAmount;
       }
    }
    
} 
else{
    
    for(Integer i=0; i<lstTaxAmt.Size(); i++){
       if(lstTaxAmt.get(i).sPerscent==per){
        calVal= lstTaxAmt.get(i).dAmount;
       }
    }
    
}
 return calVal; 
     
}


public class RounUp{
    public String sPerscent ;
    public Decimal dAmount ;
    public RounUp(String sPerscent , Decimal dAmount  ){
        this.sPerscent = sPerscent ;
        this.dAmount = dAmount ;
    }
}

public String cutoffDates(String QId){
            Map<Date, Double> mapAmount;
            Map<Date, Double> mapPercent;
            Map<Date,Decimal> mapAmountEMI ;
            String quoteId = QId;
           // Boolean customPayment=cpayment;
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
            if(quoteId !=null ){
                oQuote1 = [select id,Name,ISO_Code_Logo__c,CurrencyIsoCode,Product_Attachments__c,SBQQ__PrimaryContact__c,Primary_Contact_Info__c,documentType__c,Next_Version__c,conga_quote_template_id__c,term_conditionIds__c,conga_contract_template_id__c,Quote_Event_Edition__c,Is_a_Local_Company__c , Payment_Schedule_amount__c, Payment_Schedule_percent1__c, Payment_Schedule_percent__c ,Cutoff_Date__c , Cutoff_Date_1__c , Cutoff_Date_2__c , Cutoff_Date_3__c , SBQQ__NetAmount__c ,ISO_Code__c ,Payment_Schedule_amount1__c , SBQQ__Opportunity2__c , EE_Payment_Schedule__c ,SBQQ__Opportunity2__r.EventEdition__c, Payment_Schedule_Revised__c,InvoicetoStartDate__c,Invoice_to_Start_Date_Cut_Off_Date1__c,Invoice_to_Start_Date_Cut_Off_Date2__c,Invoice_to_Start_Date_Cut_Off_Date3__c, Invoice_to_be_issued_before_in_Days__c,SBQQ__Opportunity2__r.stageName,SBQQ__Status__c, SBQQ__Opportunity2__r.Is_Barter_Opportunity__c,SBQQ__Opportunity2__r.Custom_Payment__c,invoice_payment1__c,invoice_payment2__c,invoice_payment3__c,invoice_payment4__c,invoice_payment5__c,invoice_payment6__c,invoice_payment7__c,invoice_payment8__c,invoice_payment9__c,invoice_payment10__c,invoice_payment11__c,invoice_payment12__c, ES_Company_Country__c from SBQQ__Quote__c where id =:quoteId limit 1];
                
              //  if(!oQuote1.SBQQ__Opportunity2__r.stageName.containsIgnoreCase('Closed')){
                    dAmountToPay = oQuote1.SBQQ__NetAmount__c;
                   
                    if(!oQuote1.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c && oQuote1.SBQQ__Opportunity2__r.Custom_Payment__c==false && oQuote1.EE_Payment_Schedule__c!=null){
                        Cutoff_Date1 = oQuote1.InvoicetoStartDate__c;
                        Cutoff_Date2 = oQuote1.Invoice_to_Start_Date_Cut_Off_Date1__c;
                        Cutoff_Date3 = oQuote1.Invoice_to_Start_Date_Cut_Off_Date2__c;
                        Cutoff_Date4 = oQuote1.Invoice_to_Start_Date_Cut_Off_Date3__c ;
                        if(oQuote1.Invoice_to_be_issued_before_in_Days__c != Null){
                            InvoiceIssuedBefore = Integer.ValueOf(oQuote1.Invoice_to_be_issued_before_in_Days__c) ;
                        }
                        if(!String.isBlank(oQuote1.EE_Payment_Schedule__c)){
                            lstPaymentPercent = oQuote1.EE_Payment_Schedule__c.split('-');
                        }
                       
                        if(dAmountToPay != null && !lstPaymentPercent.isEmpty() && (Cutoff_Date1 != null || Cutoff_Date2 != null || Cutoff_Date3 != null || Cutoff_Date4 != null)){
                            
                            List<Date> lstQualifiedDate = new List<Date>();
                            Date currentdate = Date.today();
                            if(Cutoff_Date1 == Null || Cutoff_Date1 <= currentdate){
                                lstQualifiedDate.add(currentdate);
                            }
                            else if(lstPaymentPercent.size() >= 1){
                                lstQualifiedDate.add(Cutoff_Date1);
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
                                    dScaleAmount = (dTempAmount - dTempAmount.round(System.RoundingMode.DOWN));
                                    if(i != (iPaymentPercentSize-1)){ mapAmountEMI.put(lstQualifiedDate.get(i),this.CurrencyFormat(dTempAmount.round(System.RoundingMode.DOWN))); }
                                    else if(i == (iPaymentPercentSize-1)){ mapAmountEMI.put(lstQualifiedDate.get(i),this.CurrencyFormat(dTempAmount)); }
                                }
                                else{
                                    if(i+1 <= (iPaymentPercentSize - iDateSize)){
                                        dAmount += (dAmountToPay * (Decimal.ValueOf(lstPaymentPercent.get(i))/100)); 
                                    }
                                    else if(dAmount != 0){
                                        dTempAmount = ((dAmountToPay * (Decimal.ValueOf(lstPaymentPercent.get(i))/100))+dScaleAmount+dAmount); dScaleAmount = (dTempAmount - dTempAmount.round(System.RoundingMode.DOWN));
                                        if(i != (iPaymentPercentSize-1)){ mapAmountEMI.put(lstQualifiedDate.get(i-(iPaymentPercentSize - iDateSize)),this.CurrencyFormat(dTempAmount.round(System.RoundingMode.DOWN))); }
                                        else if(i == (iPaymentPercentSize-1)){ mapAmountEMI.put(lstQualifiedDate.get(i-(iPaymentPercentSize - iDateSize)),this.CurrencyFormat(dTempAmount)); }
                                        dAmount = 0;
                                    } else {
                                        dTempAmount = ((dAmountToPay * (Decimal.ValueOf(lstPaymentPercent.get(i))/100))+dScaleAmount); dScaleAmount = (dTempAmount - dTempAmount.round(System.RoundingMode.DOWN));
                                        if(i != (iPaymentPercentSize-1)){ mapAmountEMI.put(lstQualifiedDate.get(i-(iPaymentPercentSize - iDateSize)),this.CurrencyFormat(dTempAmount.round(System.RoundingMode.DOWN))); }
                                        else if(i == (iPaymentPercentSize-1)){ mapAmountEMI.put(lstQualifiedDate.get(i-(iPaymentPercentSize - iDateSize)),this.CurrencyFormat(dTempAmount)); }
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
                                sFinaldatePercent = String.ValueOf(dTempPerccent)+'-';//String.ValueOf(dTempPerccent)+'% Immediate Payment.';
                            }
                            else if(lstPaymentPercent.size() >= 1){
                                sFinaldate = String.ValueOf(dTempPerccent)+'%';
                                sFinaldatePercent = String.ValueOf(dTempPerccent)+'-'; //String.ValueOf(dTempPerccent)+'% Payable by '+DateTime.newInstance(lstDate.get(0)+InvoiceIssuedBefore, Time.newInstance(0,0,0,0)).format(sDateFormat);
                            }
                            for(Integer i=0; i< lstTemp.size(); i++){
                                sFinaldate += '\n'+ String.ValueOf(lstTemp.get(i))+'%' ;
                                sFinaldatePercent += String.ValueOf(lstTemp.get(i))+'-';//'\n'+ String.ValueOf(lstTemp.get(i))+'% Payable by '+DateTime.newInstance(lstDate.get(i+1)+InvoiceIssuedBefore, Time.newInstance(0,0,0,0)).format(sDateFormat); 
                            }
                            system.debug('sFinaldatePercent==='+sFinaldatePercent);
                            return sFinaldatePercent;
                        }
                    }
                    else{
                        return '100';
                    }
               // }
                
                
            }
           return '';
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


}