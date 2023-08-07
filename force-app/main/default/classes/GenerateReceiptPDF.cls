public without sharing class GenerateReceiptPDF 
{
    private String prdouctIds;
    private String mCartId;
    private String userId;
    private String invoiceContactId;
    private String eventEditionCode; 
    private String transID;
    public string referenceId{get;set;}
    public string creditCardNum{get;set;}
    public string creditCardExp{get;set;}
    public string appAmount{get; set;}    
    public List<Customer_Center_Cart_Master__c> CustomerCenterMasterList{get; set;}
    //public List<Customer_Transaction_Detail__c> cTransRecordList {get; set;}
    public List<Customer_Center_Cart__c> CustomerCartList{get; set;}
    public Contact conForPrimaryObj {get; set;}
    //public Contact icObj {get; set;}
    public Event_Edition__c eeObj {get; set;}
    public User userDetail{get; set;}   
    public Decimal totalAmount {get; set;}
    public Decimal appliedAmount {get; set;}
    public Decimal remainingAmount{get; set;}
    public Decimal totalQuantity {get; set;}
    public String url {get; set;}
    public string randomNumber{get;set;}         
    //public string ExhibitorNames {get;set;}
       
    public GenerateReceiptPDF()
    {
        url = 'Event_Arab_Health_2017';
        totalAmount = 0.0;
        appliedAmount = 0.0;
        totalQuantity = 0;
        remainingAmount=0;        
        
        Integer len = 5;
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        randomNumber = 'INV-'+str.substring(0, len);
        system.debug('Random Number-' + randomNumber);
    }
    
    public void getData()
    {
        system.debug('currentPage getParameters:'+ApexPages.currentPage().getParameters());
        mCartId = ApexPages.currentPage().getParameters().get('mCartId').escapeHtml4();       
        transID=ApexPages.currentPage().getParameters().get('transId').escapeHtml4();
        referenceId=ApexPages.currentPage().getParameters().get('refId').escapeHtml4();       
        creditCardNum=ApexPages.currentPage().getParameters().get('ccNum').escapeHtml4();
        //system.debug('creditCardNum' +creditCardNum);
        creditCardExp=ApexPages.currentPage().getParameters().get('ccExp').escapeHtml4();
        appAmount =ApexPages.currentPage().getParameters().get('appAmount').escapeHtml4();
        //system.debug('appAmount ' +appAmount );
        appliedAmount = Decimal.valueOf(string.valueOf(appAmount ));
        if(mCartId != null&&transID!=null)
        {             
            Customer_Center_Cart_Master__c mCartList = [ SELECT id, Contact__c,Event_Edition__c,Final_Amount__c,Final_Amount_CK__c,Is_checked_out__c,Partial_Amount__c,Partial_Amount_CK__c,Product__c,Total_Amount__c,User__c from Customer_Center_Cart_Master__c where id=:mCartId LIMIT 1];
            system.debug(mCartList.Final_Amount__c);
            totalAmount = mCartList.Final_Amount__c;
            remainingAmount=  totalAmount - appliedAmount ;    
            //cTransRecordList = [Select id,User__c,Contact__c,CS_Card_Expiration_Date__c,CS_Card_Number__c,CS_Card_Type__c,CS_Payment_Token_ID__c,CS_Refrence_ID__c,Applied_Amount__c,Customer_Center_Cart_Master__r.Final_Amount__c from Customer_Transaction_Detail__c where id =: transID AND  Customer_Center_Cart_Master__c =:mCartId LIMIT 1];
           /*Integer start = System.Now().millisecond();
           while(System.Now().millisecond()< start+150) {
               cTransRecordList = [Select id,User__c,Contact__c,CS_Card_Expiration_Date__c,CS_Card_Number__c,CS_Card_Type__c,CS_Payment_Token_ID__c,CS_Refrence_ID__c,Applied_Amount__c,Customer_Center_Cart_Master__r.Final_Amount__c from Customer_Transaction_Detail__c where id =: transID];
           }*/
            //cTransRecordList = [Select id,User__c,Contact__c,CS_Card_Expiration_Date__c,CS_Card_Number__c,CS_Card_Type__c,CS_Payment_Token_ID__c,CS_Refrence_ID__c,Applied_Amount__c,Customer_Center_Cart_Master__r.Final_Amount__c from Customer_Transaction_Detail__c where id =: transID];
            //system.debug('cTransRecordList:'+cTransRecordList );
            /*if(cTransRecordList !=null && cTransRecordList.size()>0)
            {
                totalAmount = cTransRecordList[0].Customer_Center_Cart_Master__r.Final_Amount__c;
                appliedAmount  =0;// cTransRecordList[0].Applied_Amount__c;
                remainingAmount=totalAmount-appliedAmount ;
                transactionId=cTransRecordList[0].CS_Refrence_ID__c;
                creditCardNum=cTransRecordList[0].CS_Card_Number__c;
                creditCardExp=cTransRecordList[0].CS_Card_Expiration_Date__c;
            }*/
                            
            CustomerCartList = [Select ID, Name, Customer_Center_Cart_Master__c, Event_Edition__c, Price__c, Product__c,Product__r.Name, Quantity__c
                                    from Customer_Center_Cart__c where Customer_Center_Cart_Master__c =: mCartId  ];
            system.debug('CustomerCartList:'+CustomerCartList);
            if(CustomerCartList!=null && CustomerCartList.size()>0)
            {
                for(Customer_Center_Cart__c ccc: CustomerCartList)
                {
                    totalQuantity = totalQuantity + ccc.Quantity__c;
                }
            }            
        }
        invoiceContactId = ApexPages.currentPage().getParameters().get('conId');
        if(invoiceContactId != null)
        {
            conForPrimaryObj = [SELECT Id, Name,Salutation, FirstName, LastName, Title, Email, MailingCity, MailingState, MailingCountry,MailingPostalCode,MailingStreet, MobilePhone, Phone, Account.Name
                                    FROM Contact WHERE Id =: invoiceContactId];  
        }
        userId = ApexPages.currentPage().getParameters().get('uId');
        if(userId != null)
        {
          userDetail= [SELECT Id, Name, Email  FROM User WHERE Id =: userId ];          
        }
        eventEditionCode = ApexPages.currentPage().getParameters().get('eventCode');
        if(eventEditionCode != null)
        {
            eeObj = [SELECT Id,  Name, Venue__c,Start_Date__c,End_Date__c,Event_Code__c,Part_of_Series__c,Event_Edition_Image_URL__c,Part_of_Series__r.Name FROM Event_Edition__c WHERE Event_Code__c =: eventEditionCode];
            //System.debug('Event Edition==='+eeObj);
           
        }
   }
}