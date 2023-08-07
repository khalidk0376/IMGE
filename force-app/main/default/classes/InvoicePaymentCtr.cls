/**
 * Created/Modified By: Girikon(Archit )
 * Created On:          9/28/2017
 * Description/Purpose: This class is used to allow customer to make payments on Account and Billing Section of Community
 * Methods:             populateDynamicValues, returnCountryIsoCode
 * Test Class:          PaymentDynamicValues_Ctrl_Test
**/

global class InvoicePaymentCtr{
    Public String username  {get;set;}
    Public String password  {get;set;}
    Public String Source  {get;set;}
    Public String sSignatuteEncy  {get;set;}
    Public String UTCDateTime {get;set;}  
    Public String sAccount {get;set;}
    Public String sprocessingaccount  {get;set;}
    Public String sSaprofileid  {get;set;}
    Public String sSaaccesskey  {get;set;}
    Public String sSasharedsecret  {get;set;}
    public String randomNumber{get;set;}
    public String sConfirmPage {get;set;}
    //public List<stepOneData> listStepOne{get;set;}
    public String sSignature { get; set; }
    public string InvoiceFName{get;set;}
    public string InvoiceLName{get;set;}
    public string InvoiceMailAdd{get;set;}
    public string InvoiceCity{get;set;}
    public string InvoiceCountry{get;set;}
    public string InvoiceState{get;set;}
    public string InvoiceZip{get;set;}
    public string InvoiceEmail{get;set;}
    public string InvoicePhone{get;set;}
    public string InvoiceFax{get;set;}
   /*
   public InvoicePaymentCtr() 
   {
          //BK-3753 - EmptyStatementBlock Violation Reported so I am commented this block as of now.
   }
   */
   public void populateDynamicValues()
   {
        CyberSourceCredential__c oCyberSourceCredential = CyberSourceCredential__c.getValues('CyberSourceTest');
        username  = oCyberSourceCredential.Username__c;
        password = oCyberSourceCredential.Password__c;
        Source = oCyberSourceCredential.Source__c;
        String sCardtype = oCyberSourceCredential.CardType__c;
        String sApiUrl = oCyberSourceCredential.Url__c;
        UTCDateTime = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'UTC' );
        
        //string eventCode= ApexPages.currentPage().getParameters().get('eventCode');    
        string conId= ApexPages.currentPage().getParameters().get('contactId');
        String multipleInvoicesId=ApexPages.currentPage().getParameters().get('ids').escapeHtml4();
        String paymentType=ApexPages.currentPage().getParameters().get('type');
        //system.debug(conId);
        Contact cont;
        if(String.isNotBlank(conId))
            cont= [SELECT id, FirstName, LastName, MailingStreet, MailingCity, MailingCountry, MailingState, MailingPostalCode ,Email, Phone from Contact where id=:conId];
        
        if(cont!=null)
        {
            
            if(String.isNotBlank(cont.FirstName)) 
                InvoiceFName=cont.FirstName;
            else
                InvoiceFName='';
            if(String.isNotBlank(cont.LastName)) 
                InvoiceLName=cont.LastName;
            else
                InvoiceLName='';
            if(String.isNotBlank(cont.MailingStreet))
                { InvoiceMailAdd = cont.MailingStreet;}
            else 
                { InvoiceMailAdd = 'NA';}
            
            if(String.isNotBlank(cont.MailingCity))
                { InvoiceCity = cont.MailingCity;}
            else
                { InvoiceCity = 'NA'; }
            
            if(String.isNotBlank(cont.MailingCountry))
                { 
                    //InvoiceCountry = cont.MailingCountry;
                    InvoiceCountry = returnCountryIsoCode(cont.MailingCountry);
                }
            else 
                {InvoiceCountry = 'NA';}
            
            if(String.isNotBlank(cont.MailingState))
                { InvoiceState = cont.MailingState;}
            else
                { InvoiceState = 'NA';}
            if(String.isNotBlank(cont.MailingPostalCode))
                { InvoiceZip = cont.MailingPostalCode;}
            else
                { InvoiceZip = 'NA';}
            if(String.isNotBlank(cont.Email))
                { InvoiceEmail = cont.Email;}
            else
                { InvoiceEmail = 'NA'; }
            if(String.isNotBlank(cont.Phone))
                { InvoicePhone = cont.Phone; }
            else
                { InvoicePhone = '441233456847';}
                System.debug('InvoiceCountry : '+InvoiceCountry );
                System.debug('InvoiceState : '+InvoiceState );
             /*if(InvoiceCountry != 'US' && InvoiceCountry != 'CA'){
                InvoiceState = 'NA';
            }*/
        }
        
        String EventId = ApexPages.currentPage().getParameters().get('eventId');     
        String InvoiceId = ApexPages.currentPage().getParameters().get('InvoiceId');     
        Event_Edition__c eventEdition = [SELECT ID,CurrencyIsoCode,Event_Code__c FROM Event_Edition__c WHERE Id =: EventId Limit 1];
        Http h = new Http(); 
        List<Merchant_Account_Master__c> MerchantInfo = new List<Merchant_Account_Master__c>();
        MerchantInfo = [Select Currency__c,Source_Id__c,Merchant__c FROM Merchant_Account_Master__c Where Event_Edition__c =: eventEdition.id AND Currency__c =: eventEdition.CurrencyIsoCode AND Merchant__c = 'VISA' Limit 1];
        HttpRequest req = new HttpRequest();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        if(!MerchantInfo.isEmpty())
        {
            //System.debug('SourceId: '+MerchantInfo[0].Source_Id__c);
            //System.debug('Currency: '+MerchantInfo[0].Currency__c);
            System.debug('Card Type: '+MerchantInfo[0].Merchant__c);
            req.setEndpoint(sApiUrl+'/mcas_services.asp?username='+username+'&password='+password+'&method=GETACCOUNTSA&currency='+MerchantInfo[0].Currency__c+'&source='+MerchantInfo[0].Source_Id__c+'&cardtype='+MerchantInfo[0].Merchant__c);
         }
         else{
             System.debug('CyberSource Values from Custom Setting');
            req.setEndpoint(sApiUrl+'/mcas_services.asp?username='+username+'&password='+password+'&method=GETACCOUNTSA&currency=USD&source='+Source+'&cardtype='+sCardtype);
         }
       req.setMethod('GET');
       
       // Send the request, and return a response
       httpResponse res;
       Dom.Document doc = new Dom.Document();
       if(!test.isrunningtest())
       {
            req.setTimeout(120000);     res = h.send(req);
            System.debug('res.getBody() '+res.getBody());
            doc.load(res.getBody());
        }
        else
        {
            doc.load('<?xml version=\'1.0\' encoding=\'utf-8\'?><mcasResponse><status>1</status><message>SUCCESS: Account details have been located.</message><account>7534357</account><processingaccount>inf_uk_7534357</processingaccount><saprofileid>SA00019</saprofileid><saaccesskey>51a9941953f23ba3a9af43850feae555</saaccesskey><sasharedsecret>b849ee254a64438aae15b96cd9b58084e9ce8e43deed43f4ac8c291f05f4071914eeaa738d844b62b3abac394b1d7275fca50ccb549e4f96ae452e5d12e6fa1e660fdb39f77243ec896d97dab0f5909abd093fe528104bb8bcd6f1c0532635913f0f4deb2e6041cf8add6c8b630e0451bacb4e8c35f94c77bd211dbd19977598</sasharedsecret></mcasResponse>');
        }
        
        Dom.XMLNode ordDtls = doc.getRootElement();
        sAccount = ordDtls.getChildElement('account', null).getText();
        sprocessingaccount = ordDtls.getChildElement('processingaccount', null).getText();
        sSaprofileid = ordDtls.getChildElement('saprofileid', null).getText();
        sSaaccesskey = ordDtls.getChildElement('saaccesskey', null).getText();
        sSasharedsecret = ordDtls.getChildElement('sasharedsecret', null).getText();
        
        Integer len = 10;
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        randomNumber = str.substring(0, len);
        //system.debug(Eventcode );
        if(eventEdition.Event_Code__c!=null && String.IsBlank(paymentType))
        {
            sConfirmPage = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/PaymentInvoiceConfirmation?eventCode='+eventEdition.Event_Code__c+'&InvoiceId='+InvoiceId+'&contactId='+conId;
        }
        if(eventEdition.Event_Code__c!=null && String.IsNotBlank(paymentType))
        {
            sConfirmPage = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/PaymentInvoiceConfirmation?eventCode='+eventEdition.Event_Code__c+'&InvoiceId='+multipleInvoicesId+'&contactId='+conId+'&paymentType=multiple';
        }
        System.debug('randomNumber '+randomNumber+'** sConfirmPage= '+sConfirmPage);
        
        sSignature = 'access_key='+sSaaccesskey+',profile_id='+sSaprofileid+',transaction_uuid='+randomNumber+',signed_date_time='+UTCDateTime
        +',locale=en,transaction_type=create_payment_token,reference_number=18072014133707_HOP_10.00_USD,currency=USD,override_custom_receipt_page='+sConfirmPage
        +',override_custom_cancel_page='+sConfirmPage+',bill_to_forename='+InvoiceFName+',bill_to_surname='+InvoiceLName+',bill_to_address_line1='+InvoiceMailAdd
        +',bill_to_address_city='+InvoiceCity+',bill_to_address_state='+InvoiceState+',bill_to_address_postal_code='+InvoiceZip+',bill_to_address_country='
        +InvoiceCountry+',bill_to_email='+InvoiceEmail+',bill_to_phone='+InvoicePhone
        +',unsigned_field_names=,signed_field_names=access_key,profile_id,transaction_uuid,signed_date_time,locale,transaction_type,reference_number,currency,override_custom_receipt_page,override_custom_cancel_page,bill_to_forename,bill_to_surname,bill_to_address_line1,bill_to_address_city,bill_to_address_state,bill_to_address_postal_code,bill_to_address_country,bill_to_email,bill_to_phone,unsigned_field_names,signed_field_names';
                
        Blob blobSignature = Crypto.generateMac('HmacSHA256', Blob.valueOf(sSignature), Blob.valueOf(sSasharedsecret));
        sSignatuteEncy = EncodingUtil.base64Encode(blobSignature);
        System.debug('sSignatuteEncy '+sSignatuteEncy);
        CyberSource_Transaction_Log__c CyberLog= new CyberSource_Transaction_Log__c();
        CyberLog.Access_key__c = sSaaccesskey;
        CyberLog.Payment_Status__c='Initiated';
        CyberLog.Profile_Id__c = sSaprofileid;
        CyberLog.Transaction_uuid__c = randomNumber;
        CyberLog.signed_date_time__c = UTCDateTime;
        CyberLog.Locale__c = 'en';
        CyberLog.Transaction_type__c='create_payment_token';
        CyberLog.Reference_number__c='18072014133707_HOP_10.00_USD';
        CyberLog.Currency__c = 'USD';
        CyberLog.Override_Custom_Receipt_Page__c=sConfirmPage;
        CyberLog.Override_Custom_Cancel_Page__c=sConfirmPage;
        CyberLog.Bill_to_forename__c=InvoiceFName;
        CyberLog.bill_to_surname__c=InvoiceLName;
        CyberLog.Bill_to_address_line1__c=InvoiceMailAdd;
        CyberLog.Bill_to_address_city__c=InvoiceCity;
        CyberLog.Bill_to_address_state__c=InvoiceState;
        CyberLog.Bill_to_address_postal_code__c=InvoiceZip;
        CyberLog.Bill_to_address_country__c=InvoiceCountry;
        CyberLog.Bill_to_email__c=InvoiceEmail;
        CyberLog.Bill_to_phone__c=InvoicePhone;
        CyberLog.Transaction_Date__c=UTCDateTime;
        CyberLog.System_Id__c='MCAS';
        CyberLog.Contact__c=conId;
        CyberLog.Invoice__c= InvoiceId;
        CyberLog.CyberSource_Username__c=username;
        if(CyberLog != null){
            insert CyberLog;
        }
   }
   
   public String returnCountryIsoCode(String countryName)
   {
       String isoCode;
       try
       {
            Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            System.debug('Picklist::'+ple);
            for( Schema.PicklistEntry f : ple)
            {
                if(f.getLabel()==countryName)
                {
                    isoCode=f.getValue();     return isoCode;
                }
                System.debug(f.getLabel() +'::'+ f.getValue());
            }
       }
       catch(Exception e)
       {
           System.debug('Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
       }
       return null;
   }//*/
}