/* * File:        CreateCustomerController.cls
 * Project:     GAP
 * Created Date: 29-Nov-2017
 * Created By:  Margaret Persico ,  28/7/2017 8:30 PM
 * Modified By:  Rajesh Kumar
 * Test Class: CreateCustomerControllerTest
 * Coverage: 80%
 * *************************************************************************
 * @Description Controller to handle the calls out to the create customer api
 * *************************************************************************
 * History: 
  *  GGCW-1933 Modified By Rajesh Kumar on 21/02/2019
 */
public with sharing class CreateCustomerController {
    private String CALL_VERB = 'POST';
    private String INTEGRATION_SERVICE_NAME = 'CUSTOMER';
    private String integrationUrl = '';
    private String integrationUsername = '';
    private String integrationPassword = '';    
    private CreateCustomerControllerDatabaseInterface databaseInterface;    
    public CreateCustomerController() {    
        databaseInterface = new CreateCustomerControllerDatabaseDefaultImpl();  
    }    
    public CreateCustomerController(ApexPages.StandardController standardController) {       
        databaseInterface = new CreateCustomerControllerDatabaseDefaultImpl();    
    }    
    public CreateCustomerController(CreateCustomerControllerDatabaseInterface altDatabaseInterface){    
        databaseInterface = altDatabaseInterface;   
    }

    public CreateCustomerController(ApexPages.StandardController standardController, CreateCustomerControllerDatabaseInterface altDatabaseInterface) { 
        databaseInterface = altDatabaseInterface; 
    }

    /**
     * Method for use from the apex page.
     */
    public PageReference createCustomer() {
        String orderId = System.currentPageReference().getParameters().get('ordId');
        try {            
            return createCustomerCallout(orderId); 
        }
        catch(Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Exception Occurred: ' + e.getMessage());
            ApexPages.addMessage(msg);
            return null;
        }
    }

    /**
     * Perform the create customer action.
     */
    public PageReference createCustomerCallout(String orderId) {
        integrationUrl = IntegrationSettingsHelper.getEndpointFromSettings(INTEGRATION_SERVICE_NAME);
        integrationUsername = IntegrationSettingsHelper.getUsernameFromSettings(INTEGRATION_SERVICE_NAME);
        integrationPassword = IntegrationSettingsHelper.getPasswordFromSettings(INTEGRATION_SERVICE_NAME);

        String accountId  = '';
        String contactId = '';
        Account account;
        Contact contact;
        Order order;
        List<OrderItem> orderItems;
        List<Account_Legal_Entity__c> accountLegalEntities;
        List<Id> legalEntityIdsNotCreated = new List<Id>();
        Map<Id, String> entityCodeByLegalEntityId = new Map<Id, String>();
        List<Error_Log__c> lstErrorLog = new List<Error_Log__c>();
        try {
            if(String.isNotBlank(orderId)) {
                Map<Id, Contact> contactMapByOrderIds = databaseInterface.retrieveBillingContact(new List<Id>{orderId});
                contact = contactMapByOrderIds.get(orderId);
                if(contact == null) {
                    throw new InformaExceptions.InformaInvalidInputException(1156, 'No Billing Contact', 'There needs to exist a billing contact on the order');
                }
                
                order = databaseInterface.queryOrderByOrderId(orderId);
                orderItems = databaseInterface.queryOrderItemsByOrderId(orderId);
                accountId = contact.AccountId; //order.AccountId;
                contactId = contact.Id;
                Set<Id> legalEntitySet = new Set<Id>();

                for(OrderItem orderItem: orderItems) {
                    legalEntitySet.add(orderItem.blng__LegalEntity__c);
                    entityCodeByLegalEntityId.put(orderItem.blng__LegalEntity__c, orderItem.blng__LegalEntity__r.Informa_Branch__c);
                }

                Set<Id> accountLegalEntitySet = new Set<Id>();
                accountLegalEntities = databaseInterface.queryAccountLegalEntitiesByAccountIdAndLegalEntityId(accountId, legalEntitySet);
                // GGCW-1933 : Rajesh Kumar - 21/02/2019
                for(Account_Legal_Entity__c acctLE: accountLegalEntities) { 
                    if (acctLE.Active__c){ 
                        accountLegalEntitySet.add(acctLE.Legal_Entity__c);  
                    }  
                }                    
                for(Id leId: legalEntitySet) {       
                    if(!accountLegalEntitySet.contains(leId)) { 
                        legalEntityIdsNotCreated.add(leId);                       
                    }                    
                }
            }
            if(String.isNotBlank(accountId)) {                
                account = databaseInterface.queryAccountByAccountId(accountId);
            }
        } 
        catch (Exception eek) {
            System.debug(LoggingLevel.ERROR, 'CreateCustomerController() selecting error: ' + eek.getMessage() + ' ' + eek.getStackTraceString());
            throw new InformaExceptions.InformaInvalidInputException(1157, 'No Account', 'There needs to exist account on the order');
        }

        Boolean failureOccurred = false;        
        List<Account_Legal_Entity__c> insertAccountLegalEntities = new List<Account_Legal_Entity__c>();
        if (legalEntityIdsNotCreated.size() > 0 ){            
            for(Id legalEntityId : legalEntityIdsNotCreated) {   
                if (account != null) {    
                    CreateCustomerRequest ccRequest = new CreateCustomerRequest(account, entityCodeByLegalEntityId.get(legalEntityId), contact);
                    String createCustomerPayload = CreateCustomerRequest.serializeToString(ccRequest);
                    String response = '';        
                    response = OutboundCallHelper.makeClientIdTypeHttpRequest(integrationUrl, CALL_VERB, createCustomerPayload, integrationUsername, integrationPassword);
                    CreateCustomerResponse customerResponse = CreateCustomerResponse.parse(response);
                if(customerResponse.Header != null && (String.isBlank(customerResponse.Header.Systems.MessageStatus) || customerResponse.Header.Systems.MessageStatus == 'OK' || customerResponse.Header.Systems.MessageStatus == 'UPDATED'))  {
                    String businessPartnerNumber = customerResponse.Results.BusinessPartnerNumber; 
                    String cpNumber =  customerResponse.Results.ContactPerson;
                    if(String.isNotEmpty(businessPartnerNumber)) {   
                        insertAccountLegalEntities.add(new Account_Legal_Entity__c(Account__c = account.Id, Legal_Entity__c = legalEntityId, Business_Partner_Number__c = businessPartnerNumber));
                    } else {
                        failureOccurred = true;                            
                        throw new InformaExceptions.InformaHttpException(1000, 'Error from integration server occurred: [ Did not return a valid business Partner number ' + businessPartnerNumber + ' ' + customerResponse.Header.Systems.MessageStatusText + ']');                        
                    }                    
                } else {
                        // The response was not completed successfully.
                        String errorString = '';                        
                        for(CreateCustomerResponse.Message message: customerResponse.Messages) {                            
                            errorString += ' [' + message.MessageType + ' ' + message.MessageText + '] ';                         
                        }                         
                        failureOccurred = true;                         
                        Error_Log__c el = new Error_Log__c(); el.Service_Source__c = 'Integration'; el.Source_Name__c = INTEGRATION_SERVICE_NAME; el.Description__c = errorString; el.Affected_Object__c = 'Account_Legal_Entity__c'; el.Related_OrderNumber__c = order.OrderNumber; lstErrorLog.add(el);
                        //insert new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = INTEGRATION_SERVICE_NAME, Description__c = errorString, Affected_Object__c = 'Account_Legal_Entity__c', Related_OrderNumber__c = order.OrderNumber);                        
                        throw new InformaExceptions.InformaHttpException(1001, 'Error from integration server occurred: [' + errorString + ']');
                        }
                    }
            }
            if(lstErrorLog.size() > 0){ insert lstErrorLog; }
        }
        
        try {
            if(insertAccountLegalEntities.size() > 0) {  
              databaseInterface.insertAccountLegalEntities(insertAccountLegalEntities);            
            }
        } catch (Exception e1) {            
            failureOccurred = true;
            System.debug(LoggingLevel.ERROR, 'ValidateCustomerController() inserting the account legal entities update had an error: ' + e1.getMessage() + ' ' + e1.getStackTraceString());
            throw new InformaExceptions.InformaHttpException(1001, 'Error from integration server occurred: [' + e1.getMessage() + ']');
        }

        order.Create_Customer_Result__c = failureOccurred ? 'Failure' : 'Success';
        databaseInterface.updateOrder(order);        return new PageReference('/' + orderId);
    }

    /**
     * Database interface for the create customer controller
     */
    public interface CreateCustomerControllerDatabaseInterface {
        Order queryOrderByOrderId(String orderId);

        List<OrderItem> queryOrderItemsByOrderId(String orderId);

        List<Account_Legal_Entity__c> queryAccountLegalEntitiesByAccountIdAndLegalEntityId(Id accountId, Set<Id> legalEntitySet);

        Account queryAccountByAccountId(String accountId);
        Map<Id, Contact> retrieveBillingContact(List<Id> orderIds);
        void insertAccountLegalEntities(List<Account_Legal_Entity__c> accountLegalEntities);
        void updateOrder(Order anOrder);
    }

    /**
     * Default implementation of the create customer database interface.
     */
    public class CreateCustomerControllerDatabaseDefaultImpl implements CreateCustomerControllerDatabaseInterface  {
        public Order queryOrderByOrderId(String orderId) {            
            return [SELECT Id, OrderNumber, AccountId, BillToContactId, SBQQ__Quote__r.SBQQ__Opportunity2__r.Billing_Contact__c  FROM Order   WHERE Id = :orderId   LIMIT 1];        
        }

        public List<OrderItem> queryOrderItemsByOrderId(String orderId) {            
            return [SELECT Id, OrderId, blng__LegalEntity__c, blng__LegalEntity__r.Legal_Entity_Code__c,blng__LegalEntity__r.Informa_Branch__c FROM OrderItem WHERE OrderId = :orderId]; 
        }

        public List<Account_Legal_Entity__c> queryAccountLegalEntitiesByAccountIdAndLegalEntityId(Id accountId, Set<Id> legalEntitySet) { 
            return [SELECT Id, Account__c, Legal_Entity__c, Business_Partner_Number__c , Active__c FROM Account_Legal_Entity__c WHERE Account__c = :accountId AND Legal_Entity__c IN :legalEntitySet]; 
        }

        public Account queryAccountByAccountId(String accountId) { 
            return [SELECT Id, Name, AccountNumber, BillingStreet, BillingCity, BillingState, BillingStateCode, BillingPostalCode, BillingCountry, BillingCountryCode, Phone, Fax, blng__BillToContact__c, Tax_Id__c, Billing_Address_Line_2__c FROM Account WHERE Id = :accountId LIMIT 1];
        }

        public Map<Id, Contact> retrieveBillingContact(List<Id> orderIds) {             
            return InvoiceUtilities.retrieveBillingContact(orderIds);         
        }

        public void insertAccountLegalEntities(List<Account_Legal_Entity__c> accountLegalEntities) { 
            insert accountLegalEntities;         
        }

        public void updateOrder(Order anOrder) {             
            update anOrder;         
        }
    }
}