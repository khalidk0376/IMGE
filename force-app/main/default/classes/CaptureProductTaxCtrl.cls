/**
 * Created/Modified By: Girikon(Amish,Archit)
 * Created On:          9/13/2017, [Aishwarya BK-3759 27 Aug 2020]
 * Description/Purpose: This class is used for calculating the product tax
 * Methods:             CaptureProductTax, returnCountryIsoCode
 * Test Class:          CaptureProductTaxCtrl_Test
 **/

public class CaptureProductTaxCtrl 
{
    public Static string responseJson{get;set;}
    public Integer Price{get;set;}
    public Integer Quantity{get;set;}
    public Integer Tax{get;set;}
    public Integer TaxRates{get;set;}
    public String doDirectRequest {get;set;}
    public String ProductCode{get;set;}
    public String eventId{get;set;}
    public String mCartId{get;set;}
    public static Map<String,Integer> mapProductTaxRates=new Map<String,Integer>();
    
    public CaptureProductTaxCtrl ()
    {
        eventId=ApexPages.currentPage().getParameters().get('eventId');
        mCartId=ApexPages.currentPage().getParameters().get('mCartID');
    }
    
    public string CaptureProductTax() 
    {
        try
        {
            String sEndURL = '';
            
            List <Integration_Settings__c> cSetting= [select id,name, Password__c,Username__c,Endpoint__c from Integration_Settings__c where name ='Customer'];
            List <Integration_Settings__c> urlForTax= [select id,name, Password__c,Username__c,Endpoint__c from Integration_Settings__c where name ='TAX_CALCULATION'];
            system.debug('urlForTax=== '+urlForTax);
            if(urlForTax!=null)
                sEndURL = urlForTax[0].Endpoint__c;
            else
                sEndURL='https://uat-ux-sapintegration-informags.eu.cloudhub.io/api/v1.0/services/taxcalculation';
            
            if(cSetting!=null)
            {    
                String client_id=cSetting[0].Username__c;
                String client_secret=cSetting[0].Password__c;
                
                if(String.isNotBlank(mCartId) && String.isNotBlank(eventId))
                {         
                    List <Customer_Center_Cart__c> cCartList= [SELECT id,Customer_Center_Cart_Master__r.Contact__c,Tax_Rate__c,Event_Edition__c,Customer_Center_Cart_Master__c,Quantity__c,Rate__c,Product__c,Product__r.ProductCode FROM Customer_Center_Cart__c where Customer_Center_Cart_Master__c=: mCartId and Event_Edition__c =:eventId];
                    List<Event_Edition__c> lstEvent=[Select id,EventCurrency__r.Name from Event_Edition__c Where id=:eventId];
                    
                    List <Customer_Center_Cart_Master__c> mCartList = [SELECT ID, Contact__c,Total_Tax_Amount__c From Customer_Center_Cart_Master__c where id =:mCartId];                                  
                    system.debug('mCartList='+mCartList); 
                    Set<id> setId = new Set<id>();  
                    for ( Customer_Center_Cart_Master__c m : mCartList )
                    {
                        setId.add(m.Contact__c);
                    }
                    List <Contact> con = [Select id,MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode,Salutation,firstname,lastname,Account.name,email from Contact where id =:setId];
                    system.debug('con='+con); 
                    Integer n=2;
                    String new1='';
                    String doDirectRequest='';
                    if(cCartList!=null && mCartList!=null && con!=null)
                    {
                        String conCountry = con[0].MailingCountry;
                        system.debug('conCountry==='+conCountry);
                        system.debug('conCountry_Length==='+conCOuntry.length());
                        if(conCountry.length()>3)
                            doDirectRequest = '{"Header":{"Systems":{"CallingApplication":"SFDC-GE","MessageDate": "2017-04-04"}},"Content":{"Transaction":{"MetaData":{"Customer":{"CustomerEmail": "'+con[0].email+'"},"AddressGroup":{"BillTo":{"PersonName":{"Prefix": "'+con[0].Salutation+'","FirstNames": "'+con[0].firstname+'","LastName": "'+con[0].lastname+'"},"Address":{"Organisation": "'+con[0].Account.Name+'","Department": "","AddressLine1": "'+con[0].MailingStreet+'","City": "'+con[0].MailingCity+'","PostalCode": "'+con[0].MailingPostalCode+'","Country": "'+returnCountryIsoCode(con[0].MailingCountry)+'"}},"ShipTo":{"PersonName":{"Prefix": "'+con[0].Salutation+'","FirstNames": "'+con[0].firstname+'","LastName": "'+con[0].lastname+'"},"Address":{"Organisation": "'+con[0].Account.Name+'","Department": "","AddressLine1": "'+con[0].MailingStreet+'","City": "'+con[0].MailingCity+'","PostalCode": "'+con[0].MailingPostalCode+'","Country": "'+returnCountryIsoCode(con[0].MailingCountry)+'"}}},"Currency": "'+lstEvent[0].EventCurrency__r.Name+'"},"CartItems":[';
                        else
                            doDirectRequest = '{"Header":{"Systems":{"CallingApplication":"SFDC-GE","MessageDate": "2017-04-04"}},"Content":{"Transaction":{"MetaData":{"Customer":{"CustomerEmail": "'+con[0].email+'"},"AddressGroup":{"BillTo":{"PersonName":{"Prefix": "'+con[0].Salutation+'","FirstNames": "'+con[0].firstname+'","LastName": "'+con[0].lastname+'"},"Address":{"Organisation": "'+con[0].Account.Name+'","Department": "","AddressLine1": "'+con[0].MailingStreet+'","City": "'+con[0].MailingCity+'","PostalCode": "'+con[0].MailingPostalCode+'","Country": "'+con[0].MailingCountry+'"}},"ShipTo":{"PersonName":{"Prefix": "'+con[0].Salutation+'","FirstNames": "'+con[0].firstname+'","LastName": "'+con[0].lastname+'"},"Address":{"Organisation": "'+con[0].Account.Name+'","Department": "","AddressLine1": "'+con[0].MailingStreet+'","City": "'+con[0].MailingCity+'","PostalCode": "'+con[0].MailingPostalCode+'","Country": "'+con[0].MailingCountry+'"}}},"Currency": "'+lstEvent[0].EventCurrency__r.Name+'"},"CartItems":[';
                        for(Customer_Center_Cart__c cart:cCartList)
                        {
                            new1 +='{"CartItem":{"Quantity": '+(Integer.valueOf(cart.Quantity__c)*100)+',"Price": '+Integer.valueOf(cart.Rate__c)+',"ItemData":{"ProductCode":"'+cart.Product__r.ProductCode+'"}}},';
                        }   
                    }
                    new1 = new1.subString(0,new1.Length()-1);
                    System.debug('new:='+new1);
                    doDirectRequest+=new1;
                    doDirectRequest +=']}}}';
                    System.debug('doDirectRequest:='+doDirectRequest);
                    
                    //Making HTTP requuest
                    Http h = new Http();
                    HttpRequest req = new HttpRequest();
                    RestRequest restReq = RestContext.request;  
                    req.setMethod('POST');
                    req.setHeader('Content-Type', 'application/json');
                    req.setEndpoint(sEndURL+'?client_secret='+client_secret+'&client_id='+client_id);
                    req.setBody(doDirectRequest );
                    req.setTimeout(30000);  
                    HttpResponse res;
                    try 
                    {
                        res = h.send(req);      
                        responseJson=String.ValueOf(res.getBody());
                        responseJson=responseJson.replace('Transaction', 'Transaction_CC_CPT'); 
                        responseJson=responseJson.replace('Currency', 'Currency_CC_CPT');
                        RespopnseMainClass j = (RespopnseMainClass)JSON.deserialize(responseJson,RespopnseMainClass.class);
                        ResponseResponsecls_CartItems[] cartItems=j.Content.Transaction_CC_CPT.CartItems;
                        Decimal totalTaxAmount=0.0;
                        for(ResponseResponsecls_CartItems cart:cartItems){
                            totalTaxAmount+=cart.CartItem.Tax*((cart.CartItem.Quantity)/100);  String productCode=cart.CartItem.ItemData.ProductCode;  Integer taxRate=cart.CartItem.TaxRates[0]/100;
                            mapProductTaxRates.put(productCode,taxRate);
                        }
                        Set<String> productCodeKeys=mapProductTaxRates.keySet();
                        List<Customer_Center_Cart__c> lstCart=new List<Customer_Center_Cart__c>();
                        
                        for(String key:productCodeKeys){
                            for(Customer_Center_Cart__c cart:cCartList){
                                if(cart.Product__r.ProductCode==key)
                                { 
                                    cart.Tax_Rate__c=mapProductTaxRates.get(key); lstCart.add(cart);
                                }
                             }
                        }
                        System.debug('lstCart:='+lstCart);
                        update lstCart;
                        mCartList[0].Total_Tax_Amount__c=totalTaxAmount; update mCartList;                        
                        return responseJson;
                    } 
                    catch (Exception e) 
                    {
                        System.debug('Callout Error:' + e.getMessage()+'Line Number:='+e.getLineNumber());            
                    } 
                }    
            }
        }
        catch(Exception e)
        {
            System.debug('Exception Message:='+e.getMessage()+'**Line Number:='+e.getLineNumber());
        }
       return null; 
    }
    // Retrive Data From JSON
    public class RespopnseMainClass
    {
        public Responsecls_Header Header;
        public Responsecls_Content Content;
        public Responsecls_Messages[] Messages;
    }

    public  class Responsecls_Header {
        public Responsecls_Systems Systems;
    }
    public  class Responsecls_Systems {
        public String CallingApplication;   //SFDC-GE
        public String MessageDate;  //2017-04-04
        public String MessageStatus;
        public String MessageStatusText;
    }
    public class Responsecls_Content {
        public Responsecls_Transaction Transaction_CC_CPT;
    }
    public  class Responsecls_Transaction {
        public Responsecls_MetaData MetaData;
        public ResponseResponsecls_CartItems[] CartItems;
    }
    public  class Responsecls_MetaData {
        public Responsecls_Customer Customer;
        public ResponseResponsecls_AddressGroup AddressGroup;
        public String Currency_CC_CPT; //GBP
        public String TaxLabel;
    }
    public  class Responsecls_Customer {
        public String CustomerEmail;    //mulesoft@informa.com
    }
    public  class ResponseResponsecls_AddressGroup {
        public Responsecls_BillTo BillTo;
        public Responsecls_ShipTo ShipTo;
    }
    public  class Responsecls_BillTo {
        public Responsecls_PersonName PersonName;
        public Responsecls_Address Address;
    }
    public  class Responsecls_PersonName {
        public String Prefix;   //Mr
        public String FirstNames;   //Guan
        public String LastName; //Carlos
    }
    public  class Responsecls_Address {
        public String Organisation; //Informa
        public String Department;   //public Support
        public String AddressLine1; 
        public String AddressLine2;//Schimmelt 32
        public String City; //Eindhoven
        public String State;
        public String PostalCode;   //5611 ZX
        public String Country;  //NL
        public String PhoneNumber;
        public String PhoneExtension    ;
        public String FaxNumber;
    }
    public  class Responsecls_ShipTo {
        public Responsecls_PersonName PersonName;
        public Responsecls_Address Address;
    }
    public  class ResponseResponsecls_CartItems {
        public Responsecls_CartItem CartItem;
    }
    public  class Responsecls_CartItem {
        public Integer Quantity;    //1
        public Integer Price;   //1000
        public Integer Tax;
        public Integer[] TaxRates;
        public Responsecls_ItemData ItemData;
    }
    public  class Responsecls_ItemData {
        public String ProductCode;  //UKCOMI-TOCEU2018
    }
    public class Responsecls_Messages{
        public String MessageReference;
        public String MessageSeverity;
        public String MessageType;
        public String MessageID;
        public String MessageText;
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
                    isoCode=f.getValue();
                    return isoCode;
                }
                System.debug(f.getLabel() +'::'+ f.getValue());
            }
       }
       catch(Exception e)
       {
           System.debug('Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
       }
       return null;
   }
}