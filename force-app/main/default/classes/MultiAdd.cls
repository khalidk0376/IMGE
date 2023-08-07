public class MultiAdd
{
    public String WoTemplateid = ApexPages.currentPage().getParameters().get('id');
    //will hold the WorkOrder Team records to be saved
    public List<WorkOrder_Team__c>lstWoTeam  = new List<WorkOrder_Team__c>();
    
    //list of the inner class
    public List<innerClass> lstInner 
    {   get;set;    }
    
    //will indicate the row to be deleted
    public String selectedRowIndex
    {get;set;}  
    
    //no. of rows added/records in the inner class list
    public Integer count = 1;
    //{get;set;}
    
    public PageReference cancel(){
        PageReference pr = new PageReference('/'+WoTemplateid);
        return pr;
    }
    ////save the records by adding the elements in the inner class list to lstWoTeam
    public PageReference Save()
    {
        PageReference pr = new PageReference('/'+WoTemplateid);
        
        for(Integer j = 0;j<lstInner.size();j++)
        {
            lstWoTeam.add(lstInner[j].wOTeam);
            
        } 
        try{
            insert lstWoTeam;
        }
        catch(Exception e){
            String s = string.valueOf(e);
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,+s));
             return null;

        }
        pr.setRedirect(True);
        return pr;
    }
        
    //add one more row
    public void Add()
    {   
        count = count+1;
        addMore();      
    }
    
    /*Begin addMore*/
    public void addMore()
    {
        //call to the iner class constructor
        innerClass objInnerClass = new innerClass(count);
        
        //add the record to the inner class list
        lstInner.add(objInnerClass);    
        system.debug('lstInner---->'+lstInner);            
    }/* end addMore*/
    
    /* begin delete */
    public void Del()
    {
        system.debug('selected row index---->'+selectedRowIndex);
        lstInner.remove(Integer.valueOf(selectedRowIndex)-1);
        count = count - 1;
        
    }/*End del*/
    
    
    
    /*Constructor*/
    public MultiAdd(ApexPages.StandardController ctlr)
    {
    
        lstInner = new List<innerClass>();
        addMore();
        selectedRowIndex = '0';
        
    }/*End Constructor*/
        
     

    /*Inner Class*/
    public class innerClass
    {    public String WoTemplateid = ApexPages.currentPage().getParameters().get('id').escapeHtml4();   
        /*recCount acts as a index for a row. This will be helpful to identify the row to be deleted */
        public String recCount
        {get;set;}
        
        
        public WorkOrder_Team__c  wOTeam 
        {get;set;}
        
        /*Inner Class Constructor*/
        public innerClass(Integer intCount)
        {
            recCount = String.valueOf(intCount);        
            
            /*create a new Work Order Team*/
            wOTeam = new WorkOrder_Team__c ();
            wOTeam.Work_Order_Template__c = WoTemplateid;
            
        }/*End Inner class Constructor*/    
    }/*End inner Class*/
}/*End Class*/