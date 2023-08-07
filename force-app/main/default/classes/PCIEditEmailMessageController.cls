public class PCIEditEmailMessageController 
{
    public  EmailMessage em {get; set;}
    public  Boolean showHTML  {get;set;}
    public  Boolean showControllers  {get;set;}
    public  String id ='';
    public  String pciId ='';
    public  String fieldName ='';
    
    public PCIEditEmailMessageController() 
    {     
        showHTML=false;
        showControllers=false;
        id = ApexPages.currentPage().getParameters().get('Id');
        pciId = ApexPages.currentPage().getParameters().get('PCIID');
        fieldName = ApexPages.currentPage().getParameters().get('FieldName');
        
        
        if(id != null)
        {
            //@@Avi removed e.Division from the list
            List<EmailMessage> records = [Select e.ToAddress, e.TextBody, e.SystemModstamp, e.Subject, e.Status, e.ReplyToEmailMessageId, e.ParentId, e.MessageDate, e.LastModifiedDate, e.LastModifiedById, e.IsDeleted, e.Incoming, e.Id, e.HtmlBody, e.Headers, e.HasAttachment, e.FromName, e.FromAddress,  e.CreatedDate, e.CreatedById, e.CcAddress, e.BccAddress, e.ActivityId From EmailMessage e Where e.Id = :id];

            if (records.size() > 0)
            {
                em = records.get(0);
                showHTML=true;
                showControllers=true;
                
                if(fieldName.trim() == 'TextBody') 
                {showHTML=false;}
            }
            
            
        }
        
        
    }
    
    public PageReference isValidId()
    {
        if (em == null) 
        {
            
            showControllers=false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Email message record no longer exists!'));
            
        }
        else if (pciId ==null || pciId.left(3)!= 'a2x') 
        {
            showControllers=false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'PCI Record isn\'t valid! '+ pciId));
        }
       
        return null;
    }
    
     public PageReference save() 
     {
        try {
            //EmailMessage deleteEM = new EmailMessage();
            //deleteEM.Id=id;
            //EmailMessage updateEM = new EmailMessage();
            //updateEM.Id=id;
            //updateEM.Status = 'Draft';
            //if (showHTML)
            //{updateEM.HtmlBody = em.HtmlBody;}
            //else
            //{updateEM.TextBody = em.TextBody;}
            
            em.id=null;
            insert(em);
            delete(new EmailMessage(Id=id));
            
            //Update all pending records with correct new Id
            List<PCI_Credit_Card_Numbers__c> updateCCN = new List<PCI_Credit_Card_Numbers__c>();
            for(PCI_Credit_Card_Numbers__c ccn : [Select p.Record_Id__c, p.Record_Action__c, p.Id From PCI_Credit_Card_Numbers__c p Where p.Record_Action__c IN ('Pending','Positive') AND p.Record_Id__c =:id])//get oppProduct ids to get data
            {
                updateCCN.add(new PCI_Credit_Card_Numbers__c(id=ccn.Id, Record_Id__c=em.Id));
            }
            
            
            
            update(updateCCN);
            
            
        } catch(System.DMLException e) 
        {
            ApexPages.addMessages(e);
            return null;
        }
        return (new ApexPages.StandardController(em)).view();
     
     }
     
      public PageReference cancel() 
     {
        
        return (new ApexPages.StandardController(em)).view();
     
     }
        

}