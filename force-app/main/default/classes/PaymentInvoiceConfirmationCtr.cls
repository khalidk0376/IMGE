/**
 * Created/Modified By: Girikon(Archit )
 * Created On:          9/23/2017 
 * Description/Purpose: This class is used to show the confirmation of the payment on Account and Billing Section of Community
 * Methods:             autoRun, Chckvalues, sendPDFEmail, updateCyberSourceLog, returnStateIsoCode
 * Test Class:          PaymentConfirmation_Ctrl_Test
**/

public class PaymentInvoiceConfirmationCtr{
    public MAP<string, string> params {get;set;}
    public string htmlThankyou{get;set;}
    public string eventCodeFromURl{get;set;}
    public string InvoiceId{get;set;}
    public string contactId{get;set;}
    public Boolean isShowButton{get;set;}
    private Attachment  att = new Attachment ();
    private String customerTransactionDetailName;
    public String attachmentId{get;set;}
    public Decimal paidAmount{get;set;}
    private String paymentToken{get;set;}
    public String redirectURL{get;set;}
    public boolean showPaymentErrorMsg{get;set;}
    public boolean paymentSuccess {get;set;}
    public String expMonth;
    public String expYear;
    public String paymentType;
    List<String> invoiceIds=new List<String>();
    
    Public PaymentInvoiceConfirmationCtr()
    {
        MAP<string, string> hdrs = ApexPages.currentPage().getheaders();
        params = ApexPages.currentPage().getParameters();
        eventCodeFromURl = ApexPages.currentPage().getParameters().get('eventCode').escapeHtml4();
        InvoiceId= ApexPages.currentPage().getParameters().get('InvoiceId').escapeHtml4();
        contactId=ApexPages.currentPage().getParameters().get('contactId').escapeHtml4();
        paymentType=ApexPages.currentPage().getParameters().get('paymentType').escapeHtml4();
        redirectURL= '/AccountAndBilling?eventcode='+eventCodeFromURl;
        if(String.isNotBlank(InvoiceId))
            invoiceIds=InvoiceId.split(',');
    }
    
    public PageReference autoRun()
    {
        try {            
            paymentToken='5053803328296785004107';
            CyberSourceCredential__c oCyberSourceCredential = CyberSourceCredential__c.getValues('CyberSourceTest');
            String sURL = oCyberSourceCredential.CC_Community_Url__c;
            String sCommunityUrl = sURL+'/AccountAndBilling?eventcode=' + eventCodeFromURl;
            pageReference pageRef=new PageReference(sCommunityUrl);
            pageRef.setRedirect(true);
            if(params.get('decision') != 'ACCEPT')
            {
                htmlThankyou ='There is some problem while payment. Please try later.';
                return null;
            }
            if(params.get('payment_token') != null && string.isNotBlank(eventCodeFromURl))
            {    
                system.debug('PAyment_Token ==== '+params.get('payment_token'));
                Event_Edition__c eventEdition = [SELECT ID,CurrencyIsoCode,EventCurrency__c FROM Event_Edition__c WHERE Event_Code__c =: eventCodeFromURl Limit 1];
                //CyberSourceCredential__c oCyberSourceCredential = CyberSourceCredential__c.getValues('CyberSourceTest');
                String username = oCyberSourceCredential.Username__c;
                String password = oCyberSourceCredential.Password__c;
                String Source = oCyberSourceCredential.Source__c;
                String sCardtype = oCyberSourceCredential.CardType__c;
                String sApiUrl = oCyberSourceCredential.Url__c;
                String ExpiryDate= params.get('req_card_expiry_date');
                List<String> expList= new List<String>();
                for(String s : ExpiryDate.split('-'))
                {
                   expList.add(s);
                }
                if(expList.size()>0)
                {
                    expMonth = expList[0];  expYear = expList[1];
                }
                String sSaveProfile = sApiUrl+'/mcas_services.asp?username='+username+'&password='+password+'&method=SAVEPROFILE&subscriptionid='+paymentToken+'&ordernumber=3037118362&processingaccount=inf_uk_7534357&firstname='+params.get('req_bill_to_forename')+'&surname='+params.get('req_bill_to_surname')+'&address1='+params.get('req_bill_to_address_line1')+'&city='+params.get('req_bill_to_address_city')+'&county=AL&postcode='+params.get('req_bill_to_address_postal_code')+'&country=US&cardnumber='+params.get('req_card_number')+'&expmonth='+expMonth+'&expyear='+expYear+'&currency='+eventEdition.EventCurrency__c+'&customerno=123456&cardtype='+sCardtype;
                sSaveProfile = sSaveProfile.replace(' ', '%20');
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(sSaveProfile);  req.setMethod('GET');
                // Send the request, and return a response
                if(!test.isrunningtest())
                {
                    HttpResponse res = h.send(req);
                    System.debug('res :='+res);
                }
                String sMCASId = '';
                Dom.XMLNode ordDtls;
                if (paymentToken!= null)
                {   
                    Decimal dAmount = 0;
                    if(invoiceIds!=null && invoiceIds.size()>0)
                    {
                        List<blng__Invoice__c> invs=[Select id,name,blng__Account__c, blng__TotalAmount__c,blng__DueDate__c from blng__Invoice__c where id IN:invoiceIds];
                        for(blng__Invoice__c inv:invs){
                            dAmount+=inv.blng__TotalAmount__c;
                        }
                    }
                    String sPaymentCompleted = 'https://paymentservicestest.informa.com/mcas_services.asp?username='+username+'&password='+password+'&method=CHARGEPROFILE&subscriptionid='+paymentToken+'&amount='+dAmount+'&ordernumber=3037118362&customerno=123456&billingdocument=TEST&businessunit=INF1';
                    Http ht = new Http();
                    HttpRequest req1 = new HttpRequest();
                    req1.setEndpoint(sPaymentCompleted); req1.setMethod('GET');
                    // Send the request, and return a response
                    HttpResponse res1 = ht.send(req1);
                    if(res1.getBody()!= null)
                    {
                        Dom.Document doc = new Dom.Document();
                        doc.load(res1.getBody());
                        //Retrieve the root element for this document.
                        ordDtls = doc.getRootElement();
                        if (ordDtls.getChildElement('MCASId', null) != null)
                        {
                            showPaymentErrorMsg=true;  paymentSuccess=true;
                            List<blng__Invoice__c> lstInvoice = new List<blng__Invoice__c>();
                            if(invoiceIds!=null)
                            {
                                List<blng__Invoice__c> lstBlngInv=new List<blng__Invoice__c>();lstInvoice=[Select id,name,blng__Account__c, blng__TotalAmount__c,blng__DueDate__c from blng__Invoice__c where id IN:invoiceIds];
                                if(lstInvoice.size()>0){for(blng__Invoice__c inv:lstInvoice){ inv.blng__DueDate__c=Date.today();lstBlngInv.add(inv);
                                    }
                                    if(lstBlngInv.size()>0)
                                    {
                                        update lstBlngInv;
                                    }   
                                }
                            }
                            sendPDFEmail(eventCodeFromURl ,contactId);this.updateCyberSourceLog(InvoiceId, 'Success');                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Payment has been accepted. Please close this window.'); ApexPages.addMessage(myMsg);
                        } 
                        else
                        {
                            showPaymentErrorMsg=true; paymentSuccess=false;this.updateCyberSourceLog(InvoiceId, 'Failure');ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.Info,' Payment has been declined. Please close this window');
ApexPages.addMessage(myMsg1);
                        }
                    }
                }  
            }
        }
        catch(Exception e)
        {
            System.debug('Error In Class '+e.getMessage()+','+e.getLineNumber());
        }
        return null;
    }
    
    public string Chckvalues(String tempV)
    {
        if(!params.isEmpty())
        {
            if(params.ContainsKey(tempV)!=null)
                return params.get(tempV);
        }
        else
        {
            return null;
        }
        return null;
    }
    
    public void sendPDFEmail(String EventCode, String contactId) {
        try{
            String emailString = '';
            Event_Edition__c eve = [Select Id from Event_Edition__c where Event_Code__c=:EventCode limit 1];
            PageReference invoicePDF = Page.GenerateMainInvoicePDF;
            invoicePDF.getParameters().put('isDisplay','true');
            invoicePDF.getParameters().put('InvId',InvoiceId);
            invoicePDF.getParameters().put('eventId',eve.Id);
            invoicePDF.setRedirect(true);
            Blob invoicePageContent = Blob.valueOf('Test method');
            if(!test.isrunningtest())
            {
                invoicePageContent = invoicePDF.getContentAsPDF();
            }
            List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
            String tempContent = '';
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__r.Event_Code__c =:EventCode AND Email_Template_Code__c = 'ORDINV'];                                 
            Contact con = [select Email, id, Name,Type__c,FirstName from Contact where id =: contactId limit 1];
            if(eeeTemplateList!=null && eeeTemplateList.size()>0)
            {
                tempContent = eeeTemplateList[0].Content__c;
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,con.Id);
            }   
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {con.Email};
            mail.setToAddresses(toAddresses);
            mail.setSaveAsActivity(false); 
            mail.setHtmlBody(tempContent);
            mail.setSubject(ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c));     
            Messaging.EmailFileAttachment invoiceEFA = new Messaging.EmailFileAttachment();
            invoiceEFA.setFileName('Invoice.pdf');
            invoiceEFA.setBody(invoicePageContent);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {invoiceEFA});   
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
        }
        catch(Exception e)
        {
            System.debug('Exception Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
        }    
    }
    public void updateCyberSourceLog(String InvoiceId, String sStatus){
        try {
            List<CyberSource_Transaction_Log__c> lstCyberLog = [SELECT Id, Decision__c, Decision_rmsg__c, Message__c, Name, OwnerId, Payer_authentication_eci__c, Payment_Status__c, Payment_token__c,Profile_Id__c, Reason_code__c, Reference_number__c, Request_Currency__c, Req_access_key__c, Req_Amount__c, req_bill_to_address_city__c, Req_bill_to_address_country__c, Req_bill_to_address_line1__c, Req_bill_to_address_line2__c, req_bill_to_address_postal_code__c, req_bill_to_address_state__c, Req_bill_to_company_name__c, Req_bill_to_email__c, Req_bill_to_forename__c, Req_bill_to_phone__c, req_bill_to_surname__c, Req_card_expiry_date__c, Req_card_number__c, Req_card_type__c, Req_consumer_id__c, Req_customer_ip_address__c, Signature__c, signed_date_time__c, Transaction_Date__c, Transaction_id__c, utf8__c,Req_locale__c, Req_Override_Custom_Cancel_Page__c, Req_Override_Custom_Receipt_Page__c, Req_payment_method__c, Req_profile_id__c, Req_reference_number__c, Req_Transaction_uuid__c  FROM CyberSource_Transaction_Log__c WHERE Invoice__c=:InvoiceId ORDER BY LastModifiedDate DESC LIMIT 1];
            
            if(!lstCyberLog.isEmpty()){
                CyberSource_Transaction_Log__c CyberLogInfo = lstCyberLog[0];
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
            }
        }
        catch(Exception e)
        {
            System.debug('Exception Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
        }
    }
    public String returnStateIsoCode(String stateName){
       String isoCode;
       Integer flag =0;
       try
       {
            Schema.DescribeFieldResult fieldResult = User.StateCode.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple)
            {
                if(f.getLabel()==stateName)
                {
                    isoCode=f.getValue(); flag=1; return isoCode; 
                }
            }
            if(flag==0)
                return stateName;
        }
        catch(Exception e){
           System.debug('Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
        }
        return null;
    }
}