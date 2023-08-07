/**
 * Created/Modified By: Girikon(Archit )
 * Created On:          9/5/2017
 * Description/Purpose: Create Quote and Quote Line items on the newly created opportunity for Review Process and further update the fields on Customer Trasaction Detail record
 *                      Update the MCASID, Payment Status, Paid Amount field on Opportunity.
 *                      Also updated the contracted and ordered checkbox field on Opportunity is updated by trigger.
 * Methods:             save, updateTransaction
 * Test Class:          ReviewProcessController_Test
**/

public with sharing class ReviewProcessController
{
    public String transId { get; set; }
    public String eventId { get; set; }
    public User user{ get; set; }    
    public String OppName{ get; set; }
    public String Stage{ get; set; }
    public String BillingContact{ get; set; }
    public String CustomerTransactionDetail{ get; set; }
    public Date StartDate{ get; set; }
    public Date CloseDate{ get; set; }
    public String Account{ get; set; }
    public String SalesRep{ get; set; }
    public Opportunity Opp{get;set;}
    public Customer_Transaction_Detail__c TrasactionUpdate{get;set;}
    public Event_Edition__c Event{get;set;}
    List < Customer_Transaction_Detail__c > lstTrans = new List < Customer_Transaction_Detail__c > ();
    List < Customer_Center_Cart_Master__c > lstMCart = new List < Customer_Center_Cart_Master__c > ();
    List < Customer_Center_Cart__c > lstCart = new List < Customer_Center_Cart__c > ();
    private static List<SBQQ__QuoteLine__c> lines; 
    String mcartId;
    private static SBQQ__Quote__c quoteRec; 
    public boolean showPaymentErrorMsg{get;set;}
    String sTokenId;
    Decimal dAmount;
    String paymentType;
    String PricebookObjName;
    Boolean paymentSuccess=false;
    private static List<PricebookEntry> entries;
    private List<String> productIds;
    
    public ReviewProcessController()
    {
       transId= ApexPages.currentPage().getParameters().get('transId');
       eventId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
       List < Customer_Transaction_Detail__c > transList = new List < Customer_Transaction_Detail__c > ();
       Event = [Select ID, Part_of_Series__c, Event_Price_Book__r.Name, Event_Price_Book__c from Event_Edition__c where Id =:eventId limit 1];
       PricebookObjName = Event.Event_Price_Book__r.Name+'__c';
       transList = [Select id, Contact__c, Contact__r.Name,Contact__r.AccountId, Contact__r.Account.Name, CS_Payment_Token_ID__c, Opportunity__c, Primary_Transaction__c, Total_Amount__c, User__c, Customer_Center_Cart_Master__c, Customer_Center_Cart_Master__r.Payment_Type__c
                           from Customer_Transaction_Detail__c where id =:transId];
       if(transList.size()>0)
       {
           sTokenId=transList[0].CS_Payment_Token_ID__c;
           dAmount=transList[0].Total_Amount__c;
           paymentType=transList[0].Customer_Center_Cart_Master__r.Payment_Type__c;
       }
       
       Opp = new Opportunity();
       System.Debug('Opp.Name:'+Opp.Name);
       Opp.Billing_Contact__c = transList[0].Contact__c;
       Opp.Customer_Transaction_Detail__c= transList[0].Id;
       Opp.AccountId = transList[0].Contact__r.AccountId;
       Opp.EventEdition__c = eventId;
       Opp.Event_Series__c = Event.Part_of_Series__c;
        if(Test.isRunningTest()){
        Opp.StageName= 'Need Assessment';
        }
        else{
            Opp.StageName= 'Closed Won';
        }
       //Opp.Start_Date__c = date.today();
       Opp.CloseDate = date.today();
       Opp.SBQQ__QuotePricebookId__c=Event.Event_Price_Book__c;
       Opp.Opportunity_Contact__c=transList[0].Contact__c;
       //Opp.SBQQ__Ordered__c=true; 
    }
    
    public void save() 
    {
        try
        {
              System.debug('sTokenId='+sTokenId+'**dAmount='+dAmount);
              String sMCASId = '';
              Dom.XMLNode ordDtls;
              if(paymentType!='Invoice')
              {
                  if (sTokenId != null)
                  {
                      Integration_Service__c oCyberSourceCredential = Integration_Service__c.getValues('Cybersource');
                      String username = oCyberSourceCredential.User_Name__c;
                      String password = oCyberSourceCredential.Password__c;
                      String sApiUrl = oCyberSourceCredential.End_Point_Url__c;
                      String sPaymentCompleted = sApiUrl+'/mcas_services.asp?username='+username+'&password='+password+'&method=CHARGEPROFILE&subscriptionid='+sTokenId+'&amount='+dAmount+'&ordernumber=3037118362&customerno=123456&billingdocument=TEST&businessunit=INF1';
                      sPaymentCompleted = sPaymentCompleted.replace(' ', '%20');  
                      //String sPaymentCompleted = 'https://paymentservicestest.informa.com/mcas_services.asp?username=girikon&password=o5gXfifvSKndciK&method=CHARGEPROFILE&subscriptionid='+sTokenId+'&amount='+dAmount+'&ordernumber=3037118362&customerno=123456&billingdocument=TEST&businessunit=INF1';
                        //String sPaymentCompleted='https://paymentservicestest.informa.com/mcas_services.asp?username=girikon&password=o5gXfifvSKndciK&method=CHARGEPROFILE&subscriptionid=5046829023586492604106&amount=100&ordernumber=3037118362&customerno=123456&billingdocument=TEST&businessunit=INF1';
                      System.debug('sPaymentCompleted' + sPaymentCompleted);  
                      Http h = new Http();
                      HttpRequest req = new HttpRequest();
                      req.setEndpoint(sPaymentCompleted);
                      req.setMethod('GET');
                      // Send the request, and return a response
                      HttpResponse res;
                      String response='';
                     if(Test.isRunningTest())
                     {
                        response='<?xml version=\'1.0\' encoding=\'utf-8\'?><mcasResponse><status>1</status><message>APPROVED: Payment has been Approved.</message><MCASId>2013146</MCASId><AuthCode>2524</AuthCode></mcasResponse>';
                        paymentSuccess=true;
                     }
                     else
                     {                      
                        res = h.send(req);                         response=String.ValueOf(res.getBody());
                     }
                      System.debug('response:: ' + response);
                      if(String.IsNotEmpty(response))
                        {
                            Dom.Document doc = new Dom.Document();
                            doc.load(response);
                            //Retrieve the root element for this document.
                            ordDtls = doc.getRootElement();
                            
                            if (ordDtls.getChildElement('MCASId', null) != null)
                            {
                                showPaymentErrorMsg=true;
                                paymentSuccess=true;
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Opportunity has been created and payment has been accepted. Please close this window.');
                                ApexPages.addMessage(myMsg);
                            } 
                            else
                            {
                                showPaymentErrorMsg=true;                                paymentSuccess=false;                                ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.Info,' Payment has been declined. Please close this window');                                ApexPages.addMessage(myMsg1);
                                
                            }
                        }
                  }
              }
              else
              {
                  showPaymentErrorMsg=true;                  paymentSuccess=true;                  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Opportunity has been created. Please close this window.');                  ApexPages.addMessage(myMsg);
              }
              if(paymentSuccess)
              {
                if(Opp!=null)
                {   
                    system.debug('Opp======= '+Opp);
                    lstTrans = [Select id,CS_Payment_Token_ID__c,Total_Amount__c,Customer_Center_Cart_Master__c,Customer_Center_Cart_Master__r.Payment_Type__c,Applied_Amount__c  from Customer_Transaction_Detail__c where id=:transId];
                    insert Opp; 
                    
                    system.debug('Opp======= '+Opp);
                    if(lstTrans.size()>0 && lstTrans[0].Customer_Center_Cart_Master__c!=null)
                    {
                       lstMCart = [Select id,Contact__c from Customer_Center_Cart_Master__c where id=:lstTrans[0].Customer_Center_Cart_Master__c];
                       lstCart = [Select id, Contact__c, Product__c,  Quantity__c,Price__c,Rate__c,Customer_Center_Cart_Master__c from Customer_Center_Cart__c where Customer_Center_Cart_Master__c =:lstTrans[0].Customer_Center_Cart_Master__c];
                       System.Debug('lstCart: '+lstCart);
                       System.Debug('lstTrans[0].Customer_Center_Cart_Master__c: '+lstTrans[0].Customer_Center_Cart_Master__c);
                       //Add Currency to update the Currency on Quote. Dated : Oct 06,2017
                       
                       Opportunity OppCurrency = [Select Id, CurrencyIsoCode from Opportunity where Id=:Opp.Id];
                       quoteRec = new SBQQ__Quote__c(SBQQ__Opportunity2__c = Opp.Id, CurrencyIsoCode = OppCurrency.CurrencyIsoCode, SBQQ__StartDate__c = date.today(),SBQQ__Status__c='Contract Approved',SBQQ__ExpirationDate__c = Date.Today().addDays(30),SBQQ__Primary__c = true, SBQQ__SalesRep__c = Opp.OwnerId,SBQQ__Account__c = Opp.Accountid); 
                       insert quoteRec; 
                       System.debug('quoteRec:='+quoteRec);
                       if(lstCart.size()>0)
                       {
                           
                           lines = new List<SBQQ__QuoteLine__c>(); 
                           entries = new List<PricebookEntry>();
                           for(Customer_Center_Cart__c cart:lstCart)
                           {  
                               productIds=new List<String>();
                               
                              lines.add(new SBQQ__QuoteLine__c(SBQQ__ChargeType__c='One-Time', SBQQ__Quote__c = quoteRec.Id, SBQQ__Product__c = cart.Product__c, SBQQ__Quantity__c = cart.Quantity__c, SBQQ__ListPrice__c = cart.Rate__c, SBQQ__NetPrice__c = cart.Rate__c));  
                              productIds.add(cart.Product__c);
                              
                           } 
                           System.debug('lines:='+lines);
                           if(lines.size()>0)
                             insert lines; 
                             
                       }  
                      
                    }
                    
                    List<Opportunity> lstOpp = [SELECT Id, Name,SBQQ__Ordered__c,StageName, mCash_ID__c, Paid_Amount__c, Payment_Status__c,Customer_Transaction_Detail__r.Customer_Center_Cart_Master__r.Total_Amount__c from Opportunity Where id=:Opp.Id];
                    
                    updateTransaction(lstTrans[0].Customer_Center_Cart_Master__c,opp.id);
                    
                    system.debug('lstOpp==== '+lstOpp);
                    
                    if(lstOpp.size()>0)
                    {    
                    
                        if(lstTrans.size()>0 && lstTrans[0].Customer_Center_Cart_Master__c!=null)
                        {
                            lstOpp[0].Paid_Amount__c = lstTrans[0].Applied_Amount__c;
                        }
                        if(lstTrans[0].Customer_Center_Cart_Master__r.Payment_Type__c =='Credit Card')
                        {
                            if (ordDtls!=null && ordDtls.getChildElement('MCASId', null) != null)
                            {
                                sMCASId = ordDtls.getChildElement('MCASId', null).getText();
                                lstOpp[0].mCash_ID__c = sMCASId;
                       
                                if(lstTrans[0].Applied_Amount__c ==dAmount)
                                    lstOpp[0].Payment_Status__c='Paid';
                                else
                                    lstOpp[0].Payment_Status__c='Partial Paid';
                            }
                        }
                        else
                            lstOpp[0].Payment_Status__c='Invoice';
                        lstOpp[0].SBQQ__Contracted__c=true;
                        // We need to comment this out when the products are set for all the event editions
                        
                        //lstOpp[0].SBQQ__Ordered__c=true;   
                    }
                    system.debug('lstOpp=== '+lstOpp);
                    //Update lstOpp;
                    Update lstOpp;
                    system.debug('AfterlstOpp=== '+lstOpp);
                    
                }
              }
              /* When the payment Decline
              else
              {
                  if(Opp!=null)
                  { 
                    Opp.StageName= 'Closed Won';
                    Opp.Payment_Status__c='Not Paid';
                    Opp.Paid_Amount__c = dAmount;
                    insert Opp; 
                    List<Opportunity> lsOppt=[Select id,StageName from Opportunity where id=:Opp.id];
                    lsOppt[0].StageName= 'Closed Won';
                    update lsOppt;
                    updateTransaction('',opp.id);
                  }  
              }
              */
             
        }

       catch(Exception e)
       {
           System.debug('save Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
           System.debug('save Message:='+e.getStackTraceString());
       }  
    }
   
   public void updateTransaction(String cartMasterId,String oppId)
   {
       try
       {    
           system.debug('Updating Transaction=====');
           if(String.isNotBlank(cartMasterId))
            {
                List<Customer_Center_Cart_Master__c> lstMasterCart =[Select id,IsProcessed__c from Customer_Center_Cart_Master__c where id=:cartMasterId];
                lstMasterCart [0].IsProcessed__c=true;
                update lstMasterCart;
            }
            List<Customer_Transaction_Detail__c> lstcustomerTrans=[Select id,Opportunity__c from Customer_Transaction_Detail__c where Id=:transId];
            lstcustomerTrans[0].Opportunity__c=oppId;
            update lstcustomerTrans;
       }
       catch(Exception e)
       {
           System.debug('updateTransaction Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
       } 
   }
}