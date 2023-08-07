/************************************************************************** 
*
** PCI
** Last Modified by Shay Spoonmore (shay.spoonmore@informausa.com)
** Modified by Hailey Niemand - 31/10/2019 - Amendments of P1 SCA violations
*
***************************************************************************/
    
    
public class PCIOwnership { 
    
    private static PCI_Scanner__c pciSettings = PCI_Scanner__c.getall().values()[0];
    
    
    public  static void ProcessingOwnership(List<PCI_Credit_Card_Numbers__c> triggerPCI, Boolean beforeTrigger)
    {
    Set<String> ownerIds = new Set<String>();
    Set<String> recordtypeIds = new Set<String>();
    Set<String> opportunityLineItemIds = new Set<String>();
    Set<String> caseCommentIds = new Set<String>();
    
    System.debug('######DEBUG: triggerPCI.size():' + triggerPCI.size()); 
        
    for (Integer i=0;i<triggerPCI.size();i++)  {  String objectName = triggerPCI[i].Object_Name__c;

        if (triggerPCI[i].Object_Name__c == 'OpportunityLineItem' ) {            opportunityLineItemIds.add(triggerPCI[i].Record_Id__c);   }
        else if (triggerPCI[i].Object_Name__c == 'CaseComment' )  {            caseCommentIds.add(triggerPCI[i].Record_Id__c);   }
        else if (objectName != null && objectName.endsWith('History') && objectName != 'ActivityHistory' && objectName != 'OpportunityHistory' && triggerPCI[i].Record_Owner__c == null )   {            if (triggerPCI[i].Record_Created_By__c != null)ownerIds.add(triggerPCI[i].Record_Created_By__c);   }
        else if (objectName != null && objectName == 'EmailMessage' && triggerPCI[i].Record_Owner__c == null )     {            if (triggerPCI[i].Record_Last_Modified__c != null)ownerIds.add(triggerPCI[i].Record_Last_Modified__c);  }
        else {  String recordOwnerId =  triggerPCI[i].Record_Owner__c;
        if (recordOwnerId != null && recordOwnerId.startsWith('005'))ownerIds.add(triggerPCI[i].Record_Owner__c);
        
        if (triggerPCI[i].Record_RecordTypeId__c != null)recordtypeIds.add(triggerPCI[i].Record_RecordTypeId__c);
        }
    }
    
    //BEGIN: Get Parent Owners
    //Get Oportunity Product
    Map <String,String> mapOppOwners= new Map <String,String>();
    Map <String,String> mapOppRecordtypes= new Map <String,String>();
    Map<String,String>  mapObjRecordType = new Map<String,String>(); // @@Avi
    for(RecordType rt : [Select Id,SObjectType from RecordType where SObjectType in ('Case','Opportunity') ]){
        mapObjRecordType.put(rt.SObjectType,rt.SObjectType);
    }
    if (opportunityLineItemIds.Size() > 0)  {    String strOppQuery = 'Select o.Id, o.OpportunityId, o.Opportunity.OwnerId '+ String.valueOf(mapObjRecordType.containsKey('Opportunity') ? ',o.Opportunity.RecordTypeId' : ' ' )+'  from OpportunityLineItem o Where o.Id IN :opportunityLineItemIds';
        for (sObject opp : Database.query(strOppQuery)) {   sObject oppObj = opp.getSobject('Opportunity');            mapOppOwners.put(String.valueOf(opp.get('id')), String.valueOf(oppObj.get('OwnerId')));
            if(mapObjRecordType.containsKey('Opportunity') && oppObj.get('RecordTypeId') !=null){                mapOppRecordtypes.put(String.valueOf(opp.get('id')), String.valueOf(oppObj.get('RecordTypeId'))); }   
        }
    }
    
    Map <String,String> mapCaseOwners= new Map <String,String>();
    Map <String,String> mapCaseRecordtypes= new Map <String,String>();
    Map <String,String> mapCaseParentIds= new Map <String,String>();
    if (caseCommentIds.Size() > 0)   {        String strcommentQuery = 'Select c.Id, c.ParentId, c.Parent.OwnerId '+ String.valueOf(mapObjRecordType.containsKey('Case') ?',c.Parent.RecordTypeId ' : ' ') +'  from CaseComment c Where c.Id IN :caseCommentIds ';
        
        for (sObject c : Database.query(strcommentQuery))   {    sObject parent = c.getSobject('Parent');            String caseOwnerId = String.valueOf(parent.get('OwnerId'));
            if (caseOwnerId.startsWith('005')) { mapCaseOwners.put(String.valueOf(c.get('id')), String.valueOf(parent.get('OwnerId')));   }
            
            if(mapObjRecordType.containsKey('Case')  && parent.get('RecordTypeId') !=null){  mapCaseRecordtypes.put(String.valueOf(c.get('id')), String.valueOf(parent.get('RecordTypeId')));}
                
            mapCaseParentIds.put(String.valueOf(c.get('id')),String.valueOf(c.get('ParentId')));
        }
    
    }
    
    if (caseCommentIds.Size() > 0 || opportunityLineItemIds.Size() > 0) {
        for (Integer i=0;i<triggerPCI.size();i++)  {
            if (opportunityLineItemIds.Size() > 0 && triggerPCI[i].Object_Name__c == 'OpportunityLineItem' ){  String oppOwnerId = mapOppOwners.get(triggerPCI[i].Record_Id__c);   
            if (oppOwnerId != null && oppOwnerId.startsWith('005')) { triggerPCI[i].Record_Owner__c = mapOppOwners.get(triggerPCI[i].Record_Id__c);  }
                
                triggerPCI[i].Record_RecordTypeId__c = mapOppRecordtypes.get(triggerPCI[i].Record_Id__c); if (triggerPCI[i].Record_Owner__c != null) {ownerIds.add(triggerPCI[i].Record_Owner__c);} if (triggerPCI[i].Record_RecordTypeId__c != null){recordtypeIds.add(triggerPCI[i].Record_RecordTypeId__c);}
            }
            else if (caseCommentIds.Size() > 0 && triggerPCI[i].Object_Name__c == 'CaseComment' ) {
                triggerPCI[i].Record_Owner__c = mapCaseOwners.get(triggerPCI[i].Record_Id__c);     triggerPCI[i].Record_RecordTypeId__c = mapCaseRecordtypes.get(triggerPCI[i].Record_Id__c);          triggerPCI[i].Record_ParentId__c = mapCaseParentIds.get(triggerPCI[i].Record_Id__c);
                System.debug('######DEBUG: CaseComment: Owner - ' + triggerPCI[i].Record_Owner__c);
                
                if (triggerPCI[i].Record_Owner__c != null)ownerIds.add(triggerPCI[i].Record_Owner__c);
                if (triggerPCI[i].Record_RecordTypeId__c != null)recordtypeIds.add(triggerPCI[i].Record_RecordTypeId__c);
            }
        }
    }
        
    mapOppOwners.clear();
    mapOppRecordtypes.clear();
    mapCaseOwners.clear();
    mapCaseRecordtypes.clear();
    mapCaseParentIds.clear();
    //END: Get Parent Owners
    
    List<PCI_Business_Ownership__c> pciBusinessOwners =[Select p.Mapping__c, p.Business_Queue__c  from PCI_Business_Ownership__c p];
    Map <String,String> mapBusinessOwners= new Map <String,String>();
    for (PCI_Business_Ownership__c pciBusinessOwner : pciBusinessOwners)   {  mapBusinessOwners.put(pciBusinessOwner.Mapping__c, pciBusinessOwner.Business_Queue__c);
        }
    System.debug('######DEBUG: Test Owner Mapping Junction' + mapBusinessOwners.get('Junction'));
    
    //get Queues
    List<Group> pciGroups = [Select g.Id, g.Name from Group g where g.Name LIKE '%PCI CCN'];
    Map <String,String> mapQueue= new Map <String,String>();
    for (Group pciGroup : pciGroups)
        {
            String[] bu = pciGroup.Name.split('-', 2);
            System.debug('######DEBUG: pciGroup'+ pciGroup.Name +':' + bu[0]);
            mapQueue.put(pciGroup.Name, pciGroup.Id );
        }
    String SFDCAdminQueue = pciSettings.Default_User_Queue__c;//mapQueue.get('SFDC Admin - PCI CCN');

    //get Users BU and recordtypes
    
    Map<String, Schema.SObjectField> M = Schema.SObjectType.User.fields.getMap();
    String strUserQr = 'Select u.Id '+ String.valueof(M.containsKey('Informa_Business_Unit__c') ? ',u.Informa_Business_Unit__c' : ' ') + '  from User u  where u.Id in:ownerIds';
    System.debug('strUserQr : '+strUserQr );
    List<User> Users = (List<User>)Database.query(strUserQr);
    Map <Id,String> mapOwnerBU= new Map <Id,String>();
    for (sObject pciUser : Database.query(strUserQr))
        {
            System.debug('######DEBUG: pciUser(' + pciUser.Id +')');
            if (pciUser.get('Informa_Business_Unit__c') != null) {    String[] bu = String.valueof(pciUser.get('Informa_Business_Unit__c')).split('-', 2);      mapOwnerBU.put(String.valueOf(pciUser.get('Id')), bu[0].trim());
            } 
        }
    
    List<RecordType> RecordTypes = [Select Id, Name from RecordType where Id in:recordtypeIds];
    Map <String,String> mapRecortype= new Map <String,String>();
    Map <String,String> mapRecortypeName= new Map <String,String>();
    for (RecordType pciRecordType : RecordTypes)   {     String[] rt = pciRecordType.Name.split('-', 2);      mapRecortype.put(pciRecordType.Id, rt[0].Trim());         mapRecortypeName.put(pciRecordType.Id, pciRecordType.Name);
        }
    
    System.debug('######DEBUG: Users:' + Users.size());
    System.debug('######DEBUG: RecordTypes:' + RecordTypes.size());

    List<PCI_Credit_Card_Numbers__c> updateOwnerCNNs = new List<PCI_Credit_Card_Numbers__c>();
    for (Integer i=0;i<triggerPCI.size();i++)   
    {
        String businessQueueId;
        String businessName;
        String objectName = triggerPCI[i].Object_Name__c;
        
        if (objectName != null && objectName == 'EmailMessage' && triggerPCI[i].Record_Owner__c == null )   {            businessQueueId =mapQueue.get(mapBusinessOwners.get(mapOwnerBU.get(triggerPCI[i].Record_Last_Modified__c)));            businessName = mapOwnerBU.get(triggerPCI[i].Record_Last_Modified__c);
        }
        else if (objectName != null && objectName.endsWith('History') && objectName != 'ActivityHistory' && objectName != 'OpportunityHistory' && triggerPCI[i].Record_Owner__c == null )  {       businessQueueId =mapQueue.get(mapBusinessOwners.get(mapOwnerBU.get(triggerPCI[i].Record_Created_By__c)));            businessName = mapOwnerBU.get(triggerPCI[i].Record_Created_By__c);  
        }
        else If (triggerPCI[i].Record_RecordTypeId__c == null && triggerPCI[i].Record_Owner__c == null) {    businessQueueId = SFDCAdminQueue;            businessName = pciSettings.Default_Ownership_Name__c; }
        else
        {
            businessQueueId =mapQueue.get(mapBusinessOwners.get(mapOwnerBU.get(triggerPCI[i].Record_Owner__c)));
            businessName = mapOwnerBU.get(triggerPCI[i].Record_Owner__c);
            
            If (businessQueueId == null || businessQueueId.trim() == '') 
            {
                businessQueueId =mapQueue.get(mapBusinessOwners.get(mapRecortype.get(triggerPCI[i].Record_RecordTypeId__c)));
                businessName = mapRecortype.get(triggerPCI[i].Record_RecordTypeId__c); 
            }
        }
        
         If (businessQueueId == null || businessQueueId.trim() == '') 
                {
                    businessQueueId = SFDCAdminQueue;
                    businessName = pciSettings.Default_Ownership_Name__c;
                }
        
        System.debug('######DEBUG: businessQueueId :' + businessQueueId + ' -- businessName:' + businessName);
        
        if (!beforeTrigger) {   PCI_Credit_Card_Numbers__c updateOwnerCNN;      if (triggerPCI[i].Object_Name__c == 'OpportunityLineItem' )  {    updateOwnerCNN = new PCI_Credit_Card_Numbers__c(Id = triggerPCI[i].Id, OwnerId = businessQueueId, System_BU__c = businessName,Record_Owner__c = triggerPCI[i].Record_Owner__c, Record_RecordTypeId__c = triggerPCI[i].Record_RecordTypeId__c );   }
            else if (triggerPCI[i].Object_Name__c == 'CaseComment' ) {  updateOwnerCNN = new PCI_Credit_Card_Numbers__c(Id = triggerPCI[i].Id, OwnerId = businessQueueId, System_BU__c = businessName,Record_Owner__c = triggerPCI[i].Record_Owner__c, Record_RecordTypeId__c = triggerPCI[i].Record_RecordTypeId__c , Record_ParentId__c = triggerPCI[i].Record_ParentId__c ); } 
            else {  updateOwnerCNN = new PCI_Credit_Card_Numbers__c(Id = triggerPCI[i].Id, OwnerId = businessQueueId, System_BU__c = businessName);  }           updateOwnerCNNs.add(updateOwnerCNN);
        }
        
        triggerPCI[i].OwnerId = businessQueueId;
        triggerPCI[i].System_BU__c = businessName; 
        triggerPCI[i].Record_RecordTypeName__c = mapRecortypeName.get(triggerPCI[i].Record_RecordTypeId__c);
    }
    
    if (updateOwnerCNNs.Size() > 0 ){   Update(updateOwnerCNNs);   }
    //***************************************************************************/
    }












}