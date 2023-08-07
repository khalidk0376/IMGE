/**
 * Created/Modified By: Girikon(Amish, Archit)
 * Created On:          8/18/2017
 * Description/Purpose: This class is the controller class of PaymentConfirmation.
 *                      This class is used to display the payment confirmation message and after successfull payment update the Customer Transaction details Record.
 *                      Also send the payment confirmation email to the contact of the user with the invoice. 
 * Methods:             autoRun, call,Chckvalues, sendPDFEmail,updateCyberSourceLog, returnStateIsoCode
 * Test Class:          PaymentConfirmation_Ctrl_Test
**/

public class PaymentConfirmation_Ctrl 
{
    public MAP<string, string> params {get;set;}
    public string htmlThankyou{get;set;}
    public string eventCodeFromURl{get;set;}
    public string mCartIDFromURl{get;set;}
    public Boolean isShowButton{get;set;}
    public String mCartId;
    public String customerTransactionDetailid;
    private Attachment  att = new Attachment ();
    private String customerTransactionDetailName;
    public String attachmentId{get;set;}
    public Decimal paidAmount{get;set;}
    
    // Variables for display Payment information
    public string FirstName{get;set;}
    public string LastName{get;set;}
    public string RefrenceID{get;set;}
    public string CardNo{get;set;}
    public string CardType{get;set;}
    public decimal TotalPaidAmount{get;set;}
    
    
    Public PaymentConfirmation_Ctrl ()
    {
         params = ApexPages.currentPage().getParameters();
         system.debug('================PARAMS'+params);
         eventCodeFromURl = ApexPages.currentPage().getParameters().get('Eventcode').escapehtml4();
         mCartIDFromURl= ApexPages.currentPage().getParameters().get('id');
         
         FirstName = params.get('req_bill_to_forename');
         LastName = params.get('req_bill_to_surname');
         CardNo = params.get('req_card_number');
         CardType = params.get('score_card_scheme');
         RefrenceID = params.get('req_transaction_uuid');
         system.debug('===='+FirstName);
         system.debug('===='+LastName );
         system.debug('===='+CardNo );
         system.debug('===='+CardType );
         system.debug('===='+RefrenceID);
    }
    
    public PageReference autoRun()
    {
        Boolean isProfileSaved = False;
        String sSaveProfileMsg = '';
        system.debug('==== yes'+params.get('decision'));
        try
        {
            if(params.get('decision') != 'ACCEPT')
            {
                htmlThankyou ='There is some problem while payment. Please try later.';
                return null;
            }
            mCartId= params.get('id');
            system.debug('mCartID==  '+mCartId);
            if(params.get('id') != null && params.get('payment_token') != null && string.isNotBlank(eventCodeFromURl))
            {    
                system.debug('PAyment_Token ==== '+params.get('payment_token'));
                Event_Edition__c eventEdition = [SELECT ID,CurrencyIsoCode,EventCurrency__c FROM Event_Edition__c WHERE Event_Code__c =: eventCodeFromURl Limit 1];
                Integration_Service__c oIntegrationService = Integration_Service__c.getValues('Cybersource');
                String username = oIntegrationService.User_Name__c;
                String password = oIntegrationService.Password__c;
                String sApiUrl = oIntegrationService.End_Point_Url__c;
                       
                String sSaveProfile = sApiUrl+'/mcas_services.asp?username='+username+'&password='+password+'&method=SAVEPROFILE&subscriptionid='+params.get('payment_token')+'&ordernumber='+mCartId+'&processingaccount=inf_uk_7534357&firstname='+params.get('req_bill_to_forename')+'&surname='+params.get('req_bill_to_surname')+'&address1='+params.get('req_bill_to_address_line1')+'&city='+params.get('req_bill_to_address_city')+'&county='+params.get('req_bill_to_address_state')+'&postcode='+params.get('req_bill_to_address_postal_code')+'&country='+params.get('req_bill_to_address_country')+'&cardnumber='+params.get('req_card_number')+'&expmonth='+params.get('req_card_expiry_date').substringBefore('-')+'&expyear='+params.get('req_card_expiry_date').substringAfter('-')+'&currency='+params.get('req_currency')+'&customerno=123456&cardtype=VISA&source=GEGB157';
                                 
                
                sSaveProfile = sSaveProfile.replace(' ', '%20');
                System.debug('sSaveProfile String '+sSaveProfile);
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                req.setEndpoint(sSaveProfile);
                req.setMethod('GET');
                
                // Send the request, and return a response
                if(!test.isrunningtest())
                {
                    res = h.send(req);
                    System.debug('Response Body ::: '+res.getBody());
                }
                else{
                        res.setBody('<?xml version=\'1.0\' encoding=\'utf-8\'?><mcasResponse><status>1</status><message>SUCCESS: Test class Profile details have been saved.</message></mcasResponse>');
                }
                
                if(res.getBody() != null){
                    Dom.Document doc = new Dom.Document();
                    doc.load(res.getBody());
                    //Retrieve the root element for this document.
                    Dom.XMLNode saveProfileResult = doc.getRootElement();
                    String resultCode = saveProfileResult.getChildElement('status', null).getText();
                    sSaveProfileMsg = saveProfileResult.getChildElement('message', null).getText();
                    // print out specific elements
                    if(!String.isBlank(resultCode) && resultCode == '1'){
                        isProfileSaved = True;
                    }
                    System.debug('Save Profile ResultCode ::: ' + resultCode);
                    System.debug('SaveProfileMsg ::: ' + sSaveProfileMsg);
                }
                
                String eCode= params.get('Eventcode');
                List<Customer_Transaction_Detail__c> cTransList= new List<Customer_Transaction_Detail__c>();
                if(!String.isBlank(mCartId))
                {                   
                    Customer_Center_Cart_Master__c mCart = [ SELECT id, Contact__c,Event_Edition__c,Final_Amount__c,Final_Amount_CK__c,Is_checked_out__c,Partial_Amount__c,Partial_Amount_CK__c,Product__c,Total_Amount__c,User__c from Customer_Center_Cart_Master__c where id=:mCartId LIMIT 1];
                    mCart.Is_checked_out__c=true;
                    mCart.Payment_Type__c=' Credit Card';
                    update mCart;
                    Customer_Transaction_Detail__c cTrans= new Customer_Transaction_Detail__c();
                    cTrans.CS_Card_Expiration_Date__c=params.get('req_card_expiry_date');
                    cTrans.CS_Card_Number__c=params.get('req_card_number');
                    cTrans.CS_Card_Type__c=params.get('score_card_scheme');
                    cTrans.CS_Payment_Token_ID__c=params.get('payment_token');
                    cTrans.CS_Refrence_ID__c=params.get('req_transaction_uuid');
                    cTrans.Customer_Center_Cart_Master__c=mCart.id;
                    cTrans.Total_Amount__c=mCart.Total_Amount__c;
                    TotalPaidAmount = mCart.Final_Amount__c;
                    /*if(mCart.Partial_Amount_CK__c==true)
                    {
                        cTrans.Applied_Amount__c=mCart.Partial_Amount__c;
                    }
                    if(mCart.Final_Amount_CK__c==true)
                    {
                        cTrans.Applied_Amount__c=mCart.Final_Amount__c;
                    }*/
                    cTrans.Applied_Amount__c=mCart.Final_Amount__c;
                    paidAmount=cTrans.Applied_Amount__c;
                    cTrans.User__c=mCart.User__c;
                    cTrans.Contact__c=mCart.Contact__c;
                    cTransList.add(cTrans);
                    if(cTransList!=null&&cTransList.size()>0)
                    {
                        insert cTransList;
                    }
                    Customer_Transaction_Detail__c  cTransRecord = [Select id,name,User__c,Total_Amount__c, Contact__c,CS_Card_Expiration_Date__c,CS_Card_Number__c,CS_Card_Type__c,CS_Payment_Token_ID__c,CS_Refrence_ID__c,Applied_Amount__c,Customer_Center_Cart_Master__c from Customer_Transaction_Detail__c where id =: cTransList[0].id AND Customer_Center_Cart_Master__c  =: mCartId LIMIT 1];
                    //system.debug('cTransRecord: '+cTransRecord.id);
                    customerTransactionDetailid=cTransRecord.id;
                    customerTransactionDetailName=cTransRecord.name;
                    sendPDFEmail(eventCodeFromURl ,ctransRecord );  
                     /*---------------Update CyberLog after getting response from the CyberSource API ---------*/
                    this.updateCyberSourceLog(mCartId, 'Success');
               
                }
            }
            else
            {
                if(!String.isBlank(mCartId))
                {    
                    this.updateCyberSourceLog(mCartId, 'Failure');
                }
            }
            htmlThankyou ='Thank You. Your payment is successful.';
        }
        catch(Exception e)
        {
            System.debug('Error In Class '+e.getMessage()+','+e.getLineNumber());
        }
        return null;
    }
     
    
     
     /*** Function that call SendPDFEmail ***/
      public PageReference call() 
      {      
        Customer_Transaction_Detail__c  transRecord = [Select id,User__c,Contact__c,CS_Card_Expiration_Date__c,Applied_Amount__c,CS_Card_Number__c,CS_Card_Type__c,CS_Payment_Token_ID__c,CS_Refrence_ID__c,Total_Amount__c,Customer_Center_Cart_Master__c from Customer_Transaction_Detail__c where Customer_Center_Cart_Master__c  =: mCartIDFromURl LIMIT 1];
        system.debug('transRecord === '+transRecord );
        
        sendPDFEmail(eventCodeFromURl ,transRecord ); 
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Email Send successfully. Please close this window.'));
        return null;
      }
      
    public string Chckvalues(String tempV)
    {
        if(!params.isEmpty())
        {
            if(params.ContainsKey(tempV)!=null)
                return params.get(tempV);
                //System.debug('aaaaaaaaaaaaaaaaa'+params.get(tempV));
        }
        else
        {
            return null;
        }
        return null;
    }
    
    //Send email to the Contact with Invoice attached after successful payment.
    public void sendPDFEmail(String EventCode, Customer_Transaction_Detail__c transDetail) 
    {
        try
        {
            String emailString = '';
              ///Added By amish
            String appAmount = String.valueOf(transDetail.Applied_Amount__c);
            system.debug('appAmount ==== '+appAmount );
            //PageReference invoicePDF = Page.GenerateReceiptPDF;
            PageReference invoicePDF = Page.GenerateMainInvoicePDF;
            invoicePDF.getParameters().put('isReceipt','true');
            invoicePDF.getParameters().put('eventCode',EventCode);
            invoicePDF.getParameters().put('conId',transDetail.Contact__c );
            invoicePDF.getParameters().put('uId',transDetail.User__c );
            invoicePDF.getParameters().put('mCartId',transDetail.Customer_Center_Cart_Master__c);
            invoicePDF.getParameters().put('transId',transDetail.Id);
            ///Added by amish
            invoicePDF.getParameters().put('refId',transDetail.CS_Refrence_ID__c);       
            invoicePDF.getParameters().put('ccNum',transDetail.CS_Card_Number__c);
            invoicePDF.getParameters().put('ccExp',transDetail.CS_Card_Expiration_Date__c);
            invoicePDF.getParameters().put('ccType',transDetail.CS_Card_Type__c);
            invoicePDF.getParameters().put('appAmount',appAmount );
            
            //calling the invoice page for attaching the invoice in the Email to be send to the contact of the user. 
            invoicePDF.setRedirect(true);
            Blob invoicePageContent = Blob.valueOf('Test method');
            if(!test.isrunningtest())
            {
                invoicePageContent = invoicePDF.getContentAsPDF();
            }
            
            System.debug('invoicePageContent =='+invoicePageContent );
            List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
            String tempContent = '';
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c 
                                        from Event_Edition_Email_Template__c where Event_Edition__r.Event_Code__c =:EventCode AND Email_Template_Code__c = 'ORDINV'];
            system.debug('eeeTemplateList='+eeeTemplateList);                                  
            Contact con = [select Email, id, Name,Type__c,FirstName from Contact where id =: transDetail.Contact__c  limit 1];
            User us = [select Email, id, Name from User where Id =: transDetail.User__c];
            if(eeeTemplateList!=null && eeeTemplateList.size()>0)
            {
                tempContent = eeeTemplateList[0].Content__c;
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,con.Id);
               // system.debug('tempContent==='+tempContent);
            }
                
                 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          
            String[] toAddresses = new String[] {con.Email};
            mail.setToAddresses(toAddresses);
            mail.setSaveAsActivity(false);
            //mail.setTargetObjectId(con.Id); 
            mail.setHtmlBody(tempContent);
            mail.setSubject(ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c));     
            Messaging.EmailFileAttachment invoiceEFA = new Messaging.EmailFileAttachment();
            invoiceEFA.setFileName('Invoice.pdf');
            invoiceEFA.setBody(invoicePageContent);
            System.debug('invoiceEFA=='+invoiceEFA);      
            
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {invoiceEFA});   
            system.debug('mail'+mail);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
            
            List<CyberSource_Transaction_Log__c> lsttransactionLog=[Select id from CyberSource_Transaction_Log__c where Customer_Center_Cart_Master__c=:mCartId AND Customer_Center_Cart_Master__r.Is_checked_out__c=true];
            system.debug('lsttransactionLog: ==== '+lsttransactionLog);
            if(lsttransactionLog!= null && lsttransactionLog.size()>0)
            {
                lsttransactionLog[0].Customer_Transaction_Detail__c=customerTransactionDetailid;
                update lsttransactionLog;
            }
            att.parentId=customerTransactionDetailid;
            att.Body= invoicePDF.getContentAsPDF();
            att.name='Invoice-'+customerTransactionDetailName;
            insert att;
            attachmentId=att.Id;
            List<Customer_Transaction_Detail__c> lstCusTranDetail=[Select Id,CyberSource_Transaction_Log__c From Customer_Transaction_Detail__c Where Customer_Center_Cart_Master__c=:mCartId];
            if(lstCusTranDetail!=null && lstCusTranDetail.size()>0)
            {
                lstCusTranDetail[0].CyberSource_Transaction_Log__c=lsttransactionLog[0].id;
                update lstCusTranDetail;
            }
        }
        catch(Exception e)
        {
            System.debug('Exception Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
        }    
    }
    
     public void updateCyberSourceLog(String mCartId, String sStatus){
        try
        {
            List<CyberSource_Transaction_Log__c> lstCyberLog = [SELECT Id, Decision__c, Decision_rmsg__c, Message__c, Name, OwnerId, Payer_authentication_eci__c, Payment_Status__c, Payment_token__c,Profile_Id__c, Reason_code__c, Reference_number__c, Request_Currency__c, Req_access_key__c, Req_Amount__c, req_bill_to_address_city__c, Req_bill_to_address_country__c, Req_bill_to_address_line1__c, Req_bill_to_address_line2__c, req_bill_to_address_postal_code__c, req_bill_to_address_state__c, Req_bill_to_company_name__c, Req_bill_to_email__c, Req_bill_to_forename__c, Req_bill_to_phone__c, req_bill_to_surname__c, Req_card_expiry_date__c, Req_card_number__c, Req_card_type__c, Req_consumer_id__c, Req_customer_ip_address__c, Signature__c, signed_date_time__c, Transaction_Date__c, Transaction_id__c, utf8__c,Req_locale__c, Req_Override_Custom_Cancel_Page__c, Req_Override_Custom_Receipt_Page__c, Req_payment_method__c, Req_profile_id__c, Req_reference_number__c, Req_Transaction_uuid__c  FROM CyberSource_Transaction_Log__c WHERE Customer_Center_Cart_Master__c =:mCartId ORDER BY LastModifiedDate DESC LIMIT 1];
            
            if(!lstCyberLog.isEmpty()){
                CyberSource_Transaction_Log__c CyberLogInfo = lstCyberLog[0];
                System.debug('Existing CyberSource Log details ::: '+CyberLogInfo );
                CyberLogInfo.Payment_Status__c = sStatus ;
                CyberLogInfo.Req_access_key__c = Chckvalues('req_access_key');
                CyberLogInfo.Decision__c = Chckvalues('decision');
                CyberLogInfo.Decision_rmsg__c = Chckvalues('decision_rmsg');
                CyberLogInfo.Message__c = Chckvalues('message');
                if(Chckvalues('payment_token') != null){
                    CyberLogInfo.Payment_token__c = Utility.encode(Chckvalues('payment_token'));
                }
                CyberLogInfo.Reason_code__c = Chckvalues('reason_code');
                CyberLogInfo.req_bill_to_address_city__c = Chckvalues('req_bill_to_address_city');
                CyberLogInfo.req_bill_to_address_state__c = returnStateIsoCode(Chckvalues('req_bill_to_address_state'));
                CyberLogInfo.Req_bill_to_address_line1__c = Chckvalues('req_bill_to_address_line1');
                CyberLogInfo.Req_bill_to_address_line2__c = Chckvalues('req_bill_to_address_line2');
                CyberLogInfo.req_bill_to_address_postal_code__c = Chckvalues('req_bill_to_address_postal_code');
                CyberLogInfo.Req_bill_to_address_country__c = Chckvalues('req_bill_to_address_country');
                CyberLogInfo.Req_bill_to_email__c = Chckvalues('req_bill_to_email');
                CyberLogInfo.Req_bill_to_forename__c = Chckvalues('req_bill_to_forename');
                CyberLogInfo.req_bill_to_surname__c = Chckvalues('req_bill_to_surname');
                CyberLogInfo.Req_bill_to_phone__c = Chckvalues('req_bill_to_phone');
                CyberLogInfo.Req_card_expiry_date__c = Chckvalues('req_card_expiry_date');
                CyberLogInfo.Req_card_number__c = Chckvalues('req_card_number');
                CyberLogInfo.Req_card_type__c = Chckvalues('req_card_type');
                CyberLogInfo.Request_Currency__c = Chckvalues('req_currency');
                CyberLogInfo.Req_locale__c = Chckvalues('req_locale');
                CyberLogInfo.Req_Override_Custom_Cancel_Page__c = Chckvalues('req_override_custom_cancel_page');
                CyberLogInfo.Req_Override_Custom_Receipt_Page__c = Chckvalues('req_override_custom_receipt_page');
                CyberLogInfo.Req_payment_method__c = Chckvalues('req_payment_method');
                CyberLogInfo.Req_profile_id__c = Chckvalues('req_profile_id');
                CyberLogInfo.Req_reference_number__c = Chckvalues('req_reference_number');
                CyberLogInfo.Req_Transaction_uuid__c = Chckvalues('req_transaction_uuid');
                CyberLogInfo.Signature__c = Chckvalues('signature');
                CyberLogInfo.Transaction_id__c = Chckvalues('transaction_id');
                CyberLogInfo.Req_Amount__c = Chckvalues('auth_amount');
                update CyberLogInfo;
                System.debug('After Update CyberSource Log details ::: '+CyberLogInfo );
            }
        }
        catch(Exception e)
        {
            System.debug('Exception Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
        }
    }
     public String returnStateIsoCode(String stateName)
     {
       String isoCode;
       Integer flag =0;
       try
       {
            Schema.DescribeFieldResult fieldResult = User.StateCode.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            System.debug('Picklist::'+ple);
            for( Schema.PicklistEntry f : ple)
            {
                if(f.getLabel()==stateName)
                {
                    isoCode=f.getValue();
                    flag=1;
                    return isoCode;
                    
                }
               
            }
            if(flag==0)
                return stateName;
       }
       catch(Exception e)
       {
           System.debug('Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
       }
       return null;
     }
}