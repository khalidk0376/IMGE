//Ticket No.-BK-14522 Updating API Version
global class PCIScanHistoryRelationship implements Database.Batchable<Sobject>{
    
    public Boolean isTesting;// used for test methods
    public String query;
    public Map<String,Id> mapIds ;
    public List<string> systemScanIds ;
    
    global database.querylocator start(Database.BatchableContext BC){
    System.debug('DEBUG: Start Batch PCICreditCardRelationship');
    //System.debug('DEBUG: Start Batch PCICreditCardRelationship:'); 
        
    if (isTesting)  query = query + ' LIMIT 10';  
        
    return Database.getQueryLocator(query);} 
    
    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        

    List<PCI_Credit_Card_Numbers__c> updateMissingRelationship = new List<PCI_Credit_Card_Numbers__c>();
//for (PCI_Credit_Card_Numbers__c ccn : [Select Id,System_Scan_Id__c  from PCI_Credit_Card_Numbers__c Where PCI_Scan_History__c = null and System_Scan_Id__c IN :systemScanIds])
 //{
    for(sObject s : scope)
 {  PCI_Credit_Card_Numbers__c ccn = (PCI_Credit_Card_Numbers__c)s;
                System.debug('*****ccn.Id' + ccn.Id);
                System.debug('*****mapIds.get(ccn.System_Scan_Id__c)=' + mapIds.get(ccn.System_Scan_Id__c));
                PCI_Credit_Card_Numbers__c updateCNN = new PCI_Credit_Card_Numbers__c(
                    Id = ccn.Id,
                    PCI_Scan_History__c = mapIds.get(ccn.System_Scan_Id__c)
                    );   
            
                updateMissingRelationship.add(updateCNN);
        
 }
 
 if(updateMissingRelationship.size() > 0) update updateMissingRelationship;
        System.debug('DEBUG: Data Count -' + scope.Size());
    }
    
    global void finish(Database.BatchableContext BC)
    {
        System.debug('DEBUG: Finish Batch PCI');
        //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //mail.setToAddresses(new String[] {'Shay.Spoonmore@informaUSA.com'});
        //mail.setReplyTo('batch@acme.com');
        //mail.setSenderDisplayName('Batch Processing');
        //mail.setSubject('PCI Batch Process Completed');
        //mail.setPlainTextBody('Batch Process has completed'); 
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    
    

}