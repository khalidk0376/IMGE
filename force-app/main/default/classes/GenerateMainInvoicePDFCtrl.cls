/**
* Created/Modified By: Girikon(Archit,Bappi)
* Created On:          9/20/2017
* Description/Purpose: The VF page for this controller class is GenerateMainInvoicePDF
*                      This class is call when a payment invoice i=is being generated
* Methods:             getOnlyInoviecData, getReceiptInvoiceData, getDisplayInvoiceData
* Test Class:          GenerateMainInvoicePDFCtrl_Test
* 'VATCountry__c' This Field Is Not In Use any more.
**/

public class GenerateMainInvoicePDFCtrl
{
    public Boolean isDisplayInvoice{get;set;}
    public Boolean isReceiptInvoice{get;set;}
    public Boolean isOnlyInvoice{get;set;}
    public transient Contact conForPrimaryObj{get;set;}
    public transient User userDetail{get;set;}
    public transient InvocieWrapper InvoiceDetail{get;set;}
    public transient Event_Edition__c eeObj{get;set;}
    public GenerateMainInvoicePDFCtrl()
    {
        isDisplayInvoice = isReceiptInvoice = isOnlyInvoice = false;
        String sDisplayInvoice = ApexPages.currentPage().getParameters().get('isDisplay');
        if(String.isNotBlank(sDisplayInvoice) && sDisplayInvoice =='true')
        {
            isDisplayInvoice =true;
        }
        String sInvoice = ApexPages.currentPage().getParameters().get('isInvoice');
        if(String.isNotBlank(sInvoice) && sInvoice =='true')
        {
            isOnlyInvoice=true;
        }
        String sReceipt = ApexPages.currentPage().getParameters().get('isReceipt');
        if(String.isNotBlank(sReceipt) && sReceipt=='true')
        {
            isReceiptInvoice= true;
        }
        InvoiceDetail = new InvocieWrapper();
        String sInvoiceContactId = ApexPages.currentPage().getParameters().get('conId').escapeHtml4();
        String sUserId = ApexPages.currentPage().getParameters().get('uId').escapeHtml4();
        String sEventEditionCode = ApexPages.currentPage().getParameters().get('eventCode').escapeHtml4();
        String sEventId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
        //Get record contact information.
        if(sInvoiceContactId != null && String.isNotBlank(sInvoiceContactId))
        {
            conForPrimaryObj  = getContDetail(sInvoiceContactId);
        }
        //Get record User information.
        if(sUserId != null && string.isNotBlank(sUserId))
        {
            userDetail= getUserDetail(sUserId);
            if(String.isBlank(sInvoiceContactId))
                conForPrimaryObj  = getContDetail(userDetail.ContactId);          
        }
        else {
            userDetail = getUserDetail(userInfo.getUserId());
            if(String.isBlank(sInvoiceContactId))
                conForPrimaryObj  = getContDetail(userDetail.ContactId); 
        }
        //Get record Event Edition information.
        if(sEventEditionCode != null)
        {
            eeObj= getEventEditionDetail(sEventEditionCode);
        }
        if(sEventId != null && string.isNotblank(sEventId)){eeObj= getEventEditionDetailId(sEventId);}
    }
    
    public class ProductInfo{
        public Decimal UnitPrice{get;set;}
        public Decimal Quantity{get;set;}
        public String productName{get;set;}
        public Decimal ProductTotalAmount{get;set;}
        public String productId{get;set;}
        public String LineDescription {get;set;}
        public String UOM{get;set;}
        public Decimal InvoicePercentTotal{get;set;}
        public ProductInfo(){
            InvoicePercentTotal=ProductTotalAmount= UnitPrice= 0.0;
        }
    }
    
    public class InvocieWrapper
    {
        public Date InvoiceDate{get;set;}
        public String InvoiceNumber{get;set;}
        public Decimal totalAmount {get; set;}
        public Decimal appliedAmount {get; set;}
        public Decimal remainingAmount{get; set;}
        public Decimal totalQuantity {get; set;}
        public Decimal InvoiceTotal{get;set;}
        public Decimal InvoiceSubTotal{get;set;}
        public Decimal ContractSubTotal{get;set;}
        public ID CompanyID {get;set;}
        public String CustomerVat {get;set;}
        public List<ProductInfo> lstProductDetail{get;set;}
        public Decimal partialAmount{get;set;}
        public String referenceId{get;set;}
        public Decimal TotalTax{get;set;} 
        public Decimal TaxRate{get;set;}
        public String CreditTransfer{get;set;}
        public String VATFooter{get;set;}
        public String PaymentSchedule{get;set;}
        public String VATCountry{get;set;}
        public InvocieWrapper()
        {
            InvoiceDate = Date.Today();
            totalAmount = 0.0;
            appliedAmount = 0.0;
            remainingAmount = 0.0;
            partialAmount = 0.0;
            InvoiceSubTotal = 0.0;
            TaxRate = 0;
            TotalTax =ContractSubTotal =InvoiceTotal =totalQuantity = 0.0;            
        }
    }
    
    public void getOnlyInoviecData()
    {
        String checkInsert=ApexPages.currentPage().getParameters().get('checkInsert').escapeHtml4();
        String mCartId = ApexPages.currentPage().getParameters().get('mCartId').escapeHtml4();
        String paymentType = ApexPages.currentPage().getParameters().get('paymentType').escapeHtml4();
        List<Customer_Transaction_Detail__c> cTransList= new List<Customer_Transaction_Detail__c> ();
        List<ProductInfo> productLst = new List<ProductInfo>();
        Integer CounterLineDescription = 1;
        if(mCartId != null){
            
            List<Customer_Center_Cart_Master__c> CustomerCenterMasterList = [SELECT Id, Name, Contact__c, Event_Edition__c, Final_Amount__c, Final_Amount_CK__c, Is_checked_out__c, Partial_Amount__c, 
                                                                             Partial_Amount_CK__c, Total_Amount__c,Invoice_Tax__c, User__c,Total_Tax_Amount__c from Customer_Center_Cart_Master__c WHERE Id =: mCartId];// AND Is_checked_out__c = false];
            if((CustomerCenterMasterList[0].Partial_Amount_CK__c && CustomerCenterMasterList[0].Final_Amount_CK__c) || CustomerCenterMasterList[0].Final_Amount_CK__c)
            {
                InvoiceDetail.totalAmount = (CustomerCenterMasterList[0].Final_Amount__c != null?CustomerCenterMasterList[0].Final_Amount__c:0.0).setScale(2, RoundingMode.HALF_UP);
            }
            else if(CustomerCenterMasterList[0].Partial_Amount_CK__c ){
                InvoiceDetail.totalAmount = (CustomerCenterMasterList[0].Partial_Amount__c != null?CustomerCenterMasterList[0].Partial_Amount__c:0.0).setScale(2, RoundingMode.HALF_UP);
            }
            InvoiceDetail.ContractSubTotal =((CustomerCenterMasterList[0].Total_Tax_Amount__c != null ?CustomerCenterMasterList[0].Total_Tax_Amount__c:0.0) +(CustomerCenterMasterList[0].Total_Amount__c != null ?CustomerCenterMasterList[0].Total_Amount__c:0.0)).setScale(2, RoundingMode.HALF_UP);
            InvoiceDetail.TotalTax = (CustomerCenterMasterList[0].Invoice_Tax__c != null ?CustomerCenterMasterList[0].Invoice_Tax__c:0.0).setScale(2, RoundingMode.HALF_UP);
            Decimal TotAmt =(CustomerCenterMasterList[0].Total_Amount__c != null ?CustomerCenterMasterList[0].Total_Amount__c:0.0).setScale(2, RoundingMode.HALF_UP);
            
            List<Customer_Center_Cart__c> CustomerCartList = [Select ID, Name, Customer_Center_Cart_Master__c, Event_Edition__c, Price__c, Product__c,Product__r.Name, Quantity__c
                                                              from Customer_Center_Cart__c where Customer_Center_Cart_Master__c =: mCartId  ];
            for(Customer_Center_Cart__c ccc: CustomerCartList )
            {
                ProductInfo product = new ProductInfo();
                product.productId =ccc.id;
                product.UnitPrice =ccc.Price__c/ccc.Quantity__c;
                product.Quantity =ccc.Quantity__c;
                product.productName =ccc.Product__r.Name;
                product.LineDescription = ''+CounterLineDescription;
                product.UOM='P'+CounterLineDescription;
                product.InvoicePercentTotal=(InvoiceDetail.totalAmount/TotAmt)*100;
                product.ProductTotalAmount=ccc.Price__c;
                productLst.add(product);
                ++CounterLineDescription;
                InvoiceDetail.totalQuantity = InvoiceDetail.totalQuantity + ccc.Quantity__c;                
            }
            InvoiceDetail.InvoiceSubTotal = InvoiceDetail.totalAmount+InvoiceDetail.TotalTax;
            if(String.isNotBlank(paymentType))
            {
                Customer_Center_Cart_Master__c masterCart = new Customer_Center_Cart_Master__c ();
                masterCart.Id = CustomerCenterMasterList[0].Id;
                masterCart.Payment_Type__c=paymentType;
                masterCart.Is_checked_out__c=true;
                update masterCart;
            }            
        }
        InvoiceDetail.lstProductDetail = productLst;
    }
    
    public void getReceiptInvoiceData()
    {
        system.debug('currentPage getParameters:'+ApexPages.currentPage().getParameters());
        String mCartId = ApexPages.currentPage().getParameters().get('mCartId').escapeHtml4();       
        String transID=ApexPages.currentPage().getParameters().get('transId').escapeHtml4();
        String referenceId=ApexPages.currentPage().getParameters().get('refId').escapeHtml4();       
        String appAmount =ApexPages.currentPage().getParameters().get('appAmount').escapeHtml4();
        system.debug('appAmount ' +appAmount );
        List<ProductInfo> productLst = new List<ProductInfo>();
        Integer CounterLineDescription = 1;
        if(mCartId != null || transID!=null)
        {             
            if(String.isNotBlank(appAmount))
                InvoiceDetail.appliedAmount = Decimal.valueOf(string.valueOf(appAmount)).setScale(2, RoundingMode.HALF_UP);
            
            Customer_Center_Cart_Master__c mCartList = [ SELECT id,Total_Tax_Amount__c , Contact__c,Event_Edition__c,Final_Amount__c,Final_Amount_CK__c,Is_checked_out__c,Partial_Amount__c,Partial_Amount_CK__c,Product__c,Total_Amount__c,Invoice_Tax__c,User__c from Customer_Center_Cart_Master__c where id=:mCartId LIMIT 1];
            
            if(mCartList.Final_Amount__c>0)
                InvoiceDetail.totalAmount = (mCartList.Final_Amount__c).setScale(2, RoundingMode.HALF_UP);
            else
                InvoiceDetail.totalAmount=0;
            
            if( (mCartList.Partial_Amount_CK__c && mCartList.Final_Amount_CK__c) || mCartList.Final_Amount_CK__c)
            {
                InvoiceDetail.InvoiceSubTotal = ((mCartList.Final_Amount__c != null?mCartList.Final_Amount__c:0.0)-(mCartList.Total_Tax_Amount__c != null ?mCartList.Total_Tax_Amount__c:0.0)).setScale(2, RoundingMode.HALF_UP);
                InvoiceDetail.TotalTax = (mCartList.Total_Tax_Amount__c != null ?mCartList.Total_Tax_Amount__c :0.0).setScale(2, RoundingMode.HALF_UP);
                
            }
            else if(mCartList.Partial_Amount_CK__c ){
                InvoiceDetail.InvoiceSubTotal = ((mCartList.Final_Amount__c != null?mCartList.Final_Amount__c:0.0)-(mCartList.Invoice_Tax__c != null ?mCartList.Invoice_Tax__c:0.0)).setScale(2, RoundingMode.HALF_UP);
                InvoiceDetail.TotalTax = (mCartList.Invoice_Tax__c != null ?mCartList.Invoice_Tax__c:0.0).setScale(2, RoundingMode.HALF_UP);
                
            }
            InvoiceDetail.remainingAmount=  InvoiceDetail.totalAmount- InvoiceDetail.appliedAmount;    
            InvoiceDetail.referenceId = referenceId;
            
            InvoiceDetail.ContractSubTotal =((mCartList.Total_Tax_Amount__c != null ?mCartList.Total_Tax_Amount__c:0.0) +(mCartList.Total_Amount__c != null ?mCartList.Total_Amount__c:0.0)).setScale(2, RoundingMode.HALF_UP);
            
            Decimal TotAmt =(mCartList.Total_Amount__c != null ?mCartList.Total_Amount__c:0.0).setScale(2, RoundingMode.HALF_UP);
            List<Customer_Center_Cart__c> CustomerCartList = [Select ID, Name, Customer_Center_Cart_Master__c, Event_Edition__c, Price__c, Product__c,Product__r.Name, Quantity__c
                                                              from Customer_Center_Cart__c where Customer_Center_Cart_Master__c =: mCartId  ];
            
            if(CustomerCartList!=null && CustomerCartList.size()>0)
            {
                for(Customer_Center_Cart__c ccc: CustomerCartList)
                {
                    ProductInfo product = new ProductInfo();product.productId =ccc.id;product.UnitPrice =ccc.Price__c/ccc.Quantity__c; product.Quantity =ccc.Quantity__c;product.productName =ccc.Product__r.Name;product.LineDescription=''+CounterLineDescription;product.UOM='P'+CounterLineDescription;
                    System.Debug('mCartList: '+mCartList);
                    if( (mCartList.Partial_Amount_CK__c && mCartList.Final_Amount_CK__c) || mCartList.Final_Amount_CK__c)
                    {
                        product.InvoicePercentTotal=100;
                    }
                    else
                    { 
                        if(mCartList.Total_Tax_Amount__c>0)
                            product.InvoicePercentTotal=(mCartList.Invoice_Tax__c/mCartList.Total_Tax_Amount__c)*100;
                        else
                            product.InvoicePercentTotal=0;
                    }
                    product.ProductTotalAmount=ccc.Price__c;
                    productLst.add(product);
                    ++CounterLineDescription;
                    InvoiceDetail.totalQuantity = InvoiceDetail.totalQuantity + ccc.Quantity__c;
                    
                }
                
            }   
            InvoiceDetail.totalAmount=InvoiceDetail.InvoiceSubTotal+InvoiceDetail.TotalTax;
            //system.debug('totalAmount=========='+InvoiceDetail.totalAmount);
        }
        InvoiceDetail.lstProductDetail = productLst;
    }
    
    public void getDisplayInvoiceData()
    {
        String sInvoiceId = ApexPages.currentPage().getParameters().get('InvId').escapeHtml4();
        List<ProductInfo> productLst = new List<ProductInfo>();
        if(String.isNotBlank(sInvoiceId))
        {
            List<blng__Invoice__c> lstInvoice  =new List<blng__Invoice__c>([SELECT blng__InvoiceDate__c, VAT_Country_Conga__c, CreditTransferInfoLong__c, PaymentSchedule2EU__c, VAT_or_Tax_footer__c, blng__Account__c,Customer_VAT_No__c, blng__Subtotal__c,TaxRate__c,Schedule_Number__c, Name, Id, blng__Order__c, blng__TotalAmount__c, blng__TaxStatus__c, blng__InvoiceStatus__c,blng__TaxAmount__c,blng__Order__r.OpportunityId ,(Select id,Name,blng__UnitPrice__c,blng__TotalAmount__c,blng__Subtotal__c,blng__Quantity__c,blng__Product__c,blng__Product__r.Name, blng__Product__r.Booth_Product_Type__c,LineDescription__c,UOM__c, InvoicePercentofTotal__c from blng__InvoiceInvoiceLines__r)  FROM blng__Invoice__c where Id=:sInvoiceId]);
            if(lstInvoice != null && lstInvoice.size()>0){
                InvoiceDetail.InvoiceNumber = lstInvoice[0].Name;InvoiceDetail.InvoiceDate = lstInvoice[0].blng__InvoiceDate__c;Decimal amount = 0.0;
                for(blng__InvoiceLine__c oInvLineItem:lstInvoice[0].blng__InvoiceInvoiceLines__r)
                {
                    ProductInfo product = new ProductInfo();
                    product.productId =oInvLineItem.id;
                    product.UnitPrice =(oInvLineItem.blng__UnitPrice__c != null ?oInvLineItem.blng__UnitPrice__c :0.0);
                    product.Quantity = (oInvLineItem.blng__Quantity__c != null ?oInvLineItem.blng__Quantity__c:0.0);
                    product.productName =oInvLineItem.Name;
                    product.LineDescription = oInvLineItem.LineDescription__c;
                    product.UOM = oInvLineItem.UOM__c;
                    product.ProductTotalAmount =(oInvLineItem.blng__Subtotal__c !=null ?oInvLineItem.blng__Subtotal__c: 0.0);
                    product.InvoicePercentTotal= (oInvLineItem.blng__Subtotal__c/(oInvLineItem.blng__UnitPrice__c*oInvLineItem.blng__Quantity__c))*100;
                    productLst.add(product);
                    amount+=(product.UnitPrice * product.Quantity);
                }
                InvoiceDetail.InvoiceTotal = (lstInvoice[0].blng__TotalAmount__c != null ? lstInvoice[0].blng__TotalAmount__c:0.0).setScale(2, RoundingMode.HALF_UP);
                InvoiceDetail.ContractSubTotal = amount.setScale(2, RoundingMode.HALF_UP);
                InvoiceDetail.TotalTax=(lstInvoice[0].blng__TaxAmount__c!= null ? lstInvoice[0].blng__TaxAmount__c:0.0).setScale(2, RoundingMode.HALF_UP);
                InvoiceDetail.InvoiceSubTotal = (lstInvoice[0].blng__Subtotal__c!= null ? lstInvoice[0].blng__Subtotal__c:0.0).setScale(2, RoundingMode.HALF_UP);
                InvoiceDetail.TaxRate = (lstInvoice[0].TaxRate__c!= null ? lstInvoice[0].TaxRate__c:0.0).setScale(2, RoundingMode.HALF_UP);
                InvoiceDetail.CustomerVat = lstInvoice[0].Customer_VAT_No__c;
                InvoiceDetail.CompanyId=lstInvoice[0].blng__Account__c;
                InvoiceDetail.CreditTransfer=lstInvoice[0].CreditTransferInfoLong__c;
                InvoiceDetail.VATFooter=lstInvoice[0].VAT_or_Tax_footer__c;
                InvoiceDetail.PaymentSchedule=lstInvoice[0].PaymentSchedule2EU__c;
                InvoiceDetail.VATCountry=lstInvoice[0].VAT_Country_Conga__c;
            }
        }
        InvoiceDetail.lstProductDetail = productLst;
    }
    
    public void getMainData()
    {
        //Get record Only Invoice
        if(isOnlyInvoice)
        {
            getOnlyInoviecData();
        }
        //Get record Receipt Invoice
        if(isReceiptInvoice)
        {
            getReceiptInvoiceData();
        }
        //Get record Display Invoice
        if(isDisplayInvoice)
        {
            getDisplayInvoiceData();
        }
    }
    
    public static contact getContDetail(String sInvoiceContactId){
        return [SELECT Id, Name,Salutation, FirstName, LastName, Title, Email, MailingCity, MailingState, MailingCountry,MailingPostalCode,MailingStreet, MobilePhone, Phone,Fax, Account.Name FROM Contact WHERE Id =: sInvoiceContactId];
    }
    public static user getUserDetail(String sUserId){
        return [SELECT Id, Name, Email,ContactId, Fax, Phone  FROM User WHERE Id =: sUserId ]; 
    }
    
    public static Event_Edition__c getEventEditionDetail(String sEventEditionCode){
        return [SELECT Id,  Name, Venue__c,Start_Date__c,End_Date__c,Event_Code__c,Event_Website__c,Part_of_Series__c,EventCurrency__r.Name,Event_Edition_Image_URL__c,Part_of_Series__r.Name,
                Part_of_Series__r.Company_Street__c, Part_of_Series__r.Company_City__c,Part_of_Series__r.Company_State__c, Part_of_Series__r.Company_Country__c,Part_of_Series__r.SSC_Center_Department_Name__c,
                Part_of_Series__r.Company_Postal_Code__c,Part_of_Series__r.Company_Phone__c, Part_of_Series__r.Company_Website__c,Part_of_Series__r.Company_Name__c FROM Event_Edition__c WHERE Event_Code__c =: sEventEditionCode];
    }
    public static Event_Edition__c getEventEditionDetailId(String sEventId){
        return [SELECT Id,  Name, Venue__c,Start_Date__c,End_Date__c,Event_Code__c,Event_Website__c,Part_of_Series__c,EventCurrency__r.Name, Event_Edition_Image_URL__c,Part_of_Series__r.Name,
                Part_of_Series__r.Company_Street__c, Part_of_Series__r.Company_City__c,Part_of_Series__r.Company_State__c, Part_of_Series__r.Company_Country__c,Part_of_Series__r.SSC_Center_Department_Name__c,
                Part_of_Series__r.Company_Postal_Code__c,Part_of_Series__r.Company_Phone__c, Part_of_Series__r.Company_Website__c,Part_of_Series__r.Company_Name__c FROM Event_Edition__c WHERE Id =: sEventId];
    }
}