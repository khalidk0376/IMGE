/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          8/17/2017 
 * Description/Purpose: This class is the controlle of SendPDFEmail. It is used to send the email with the Invoice attached to the email when user select the option Pay by invoice.
 * Methods:             call, sendPDFEmail, insertAttachment
 * Test Class:          SendPDFAsInvoice_Test
**/

public class SendPDFAsInvoice
{
    public string sMessage{get;set;}
    
      /*** Function that call SendPDFEmail ***/
      public PageReference call() 
      {       
        string paymentType_FromURl = ApexPages.currentPage().getParameters().get('paymentType').escapeHtml4();
        String ContactId =ApexPages.currentPage().getParameters().get('ContactId').escapeHtml4();
        string eventCodeFromURl = ApexPages.currentPage().getParameters().get('eventCode').escapeHtml4();
        String mCartId= ApexPages.currentPage().getParameters().get('mCartId').escapeHtml4();
        String UserId= ApexPages.currentPage().getParameters().get('UserId').escapeHtml4();
        system.debug('ContactId === '+ContactId );
        system.debug('paymentType_FromURl === '+paymentType_FromURl );
        system.debug('mCartId=== '+mCartId);
        system.debug('UserId=== '+UserId);
        system.debug('eventCodeFromURl === '+eventCodeFromURl );
        
        sendPDFEmail(eventCodeFromURl, ContactId, UserID, mCartId, paymentType_FromURl);
        sMessage='Invoice has been created successfully';
        return null;
      }
      
      //Send EMail to the contact of the user with the Invoice attached. and also create a Customer Transaction record.
      public boolean sendPDFEmail(String EventCode, String ContactId, String UserID, String mCartId, String paymentType_FromURl)
      {
          try
          {
            String emailString = '';
            PageReference invoicePDF = Page.GenerateMainInvoicePDF;
            invoicePDF.getParameters().put('isInvoice','true');
            system.debug('EventCode==='+EventCode);
            system.debug('ContactId==='+ContactId);
            system.debug('UserID==='+UserID);
            system.debug('mCartId==='+mCartId);
            invoicePDF.getParameters().put('eventCode',EventCode);
            invoicePDF.getParameters().put('conId',ContactId);
            invoicePDF.getParameters().put('uId',UserID);
            invoicePDF.getParameters().put('mCartId',mCartId);
            invoicePDF.getParameters().put('paymentType',paymentType_FromURl);
            
            invoicePDF.setRedirect(true);
            
            Blob invoicePageContent = Blob.valueOf('Test method');
            if(!test.isrunningtest()){
                invoicePageContent = invoicePDF.getContentAsPDF();
            }
            
            System.debug('invoicePageContent =='+invoicePageContent );
            List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
            String tempContent = '';
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c 
                                        from Event_Edition_Email_Template__c where Event_Edition__r.Event_Code__c =:EventCode AND Email_Template_Code__c = 'ORDINV'];
                                        
            Contact con = [select Email, id, Name,Type__c,FirstName,accountId from Contact where id =: ContactId limit 1];
            Account acc = [Select Id from Account where id=: con.accountId];
            User us = [select Email, id, Name from User where Id =: UserID];
            if(eeeTemplateList!=null && eeeTemplateList.size()>0)
            {
                tempContent = eeeTemplateList[0].Content__c;
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, con.id); //added by amish
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, acc.id); //added by amish
                system.debug('tempContent==='+tempContent);
            }
                
                 
            /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          
            String[] toAddresses = new String[] {con.Email};
            mail.setToAddresses(toAddresses);
            mail.setSaveAsActivity(false);
            mail.setHtmlBody(tempContent);
            mail.setSubject(ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c));     
            Messaging.EmailFileAttachment invoiceEFA = new Messaging.EmailFileAttachment();
            invoiceEFA.setFileName('Invoice.pdf');
            invoiceEFA.setBody(invoicePageContent);
            System.debug('invoiceEFA=='+invoiceEFA);      
            
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {invoiceEFA});   
            system.debug('mail'+mail);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
            System.debug('mCartId :='+mCartId );*/
            
            List<Customer_Center_Cart_Master__c > CustomerCenterMasterList = [SELECT Id, Name, Contact__c, Event_Edition__c, Final_Amount__c, Final_Amount_CK__c, Is_checked_out__c, Partial_Amount__c, 
                                            Partial_Amount_CK__c, Total_Amount__c, User__c from Customer_Center_Cart_Master__c WHERE Id =: mCartId];
            
            List<Customer_Transaction_Detail__c> cTransList= new List<Customer_Transaction_Detail__c> ();

            Customer_Transaction_Detail__c cTrans= new Customer_Transaction_Detail__c();
            cTrans.Customer_Center_Cart_Master__c=CustomerCenterMasterList[0].id;
            cTrans.Total_Amount__c=CustomerCenterMasterList[0].Total_Amount__c; 
            if(CustomerCenterMasterList[0].Partial_Amount_CK__c==true)
            {
                cTrans.Applied_Amount__c=CustomerCenterMasterList[0].Partial_Amount__c;
            }
            if(CustomerCenterMasterList[0].Final_Amount_CK__c==true)
            {
                cTrans.Applied_Amount__c=CustomerCenterMasterList[0].Final_Amount__c;
            }
            cTrans.User__c=CustomerCenterMasterList[0].User__c;
            cTrans.Contact__c=CustomerCenterMasterList[0].Contact__c;
            system.debug(cTrans);
            cTransList.add(cTrans);
            system.debug(cTransList);
            if(cTransList!=null&&cTransList.size()>0)
            {
                insert cTransList;
            }
            insertAttachment(invoicePDF.getContentAsPDF(),cTransList[0].id, CustomerCenterMasterList[0].Name);
          }
          catch(Exception e)
          {
            System.debug('Exception Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
          } 
          return true;
       }
       public void insertAttachment(Blob invoicePageContent,String custTransDetailId,String custTransDetailName)
       {
           System.debug('invoicePageContent:='+invoicePageContent+'** Id='+custTransDetailId);
           if(String.isNotBlank(custTransDetailId) && invoicePageContent!=null)
           {
                Attachment att = new Attachment ();
                String ext='.pdf';
                att.parentId=custTransDetailId;
                att.Body= invoicePageContent;
                att.name='Invoice-'+custTransDetailName+ext;
                System.debug('att:='+att);
                insert att;
           }
           
       }
   }