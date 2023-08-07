/**
* File:        Close_Open_Opportunities.cls
* Project:     GAP
* Date:        1/11/2017 2:13 AM
* Created By:  Rajesh Kumar
* Test Class : Close_Open_Opportunities_Test.cls
* *************************************************************************
* Description: Closed all opporotunity has StageName NOT IN ('Closed Won', 'Pending Accounting Approval' , 'Awaiting Payment - Booth/Stand' , 'Closed Booked' , 'Closed Lost').
               
* *************************************************************************
* History:
* Modified By - Shiv Raghav Sharma. ticket no - Bk-2943 (Update Conditions for Close Open Opportunity Button on Event Edition)
*/

public class Close_Open_Opportunities{
    public String eventeditionid { get; set; }   
    
    public Close_Open_Opportunities(ApexPages.StandardController controller) {
        eventeditionid = ApexPages.currentPage().getParameters().get('id').escapeHtml4(); 
    }
    public PageReference getOpp(){
        if(!IsEmptyOrNull(eventeditionid)){
            //Query from opportunity
           // Modified By - Shiv Raghav Sharma. ticket no - Bk-2943 (Update Conditions for Close Open Opportunity Button on Event Edition)
            Batch_Close_Open_Opportunities btch = new Batch_Close_Open_Opportunities(eventeditionid); 
            database.executeBatch(btch, 5);
        } 
        return new PageReference('https://'+URL.getSalesforceBaseUrl().getHost()+'/'+eventeditionid).setRedirect(true);
    }
    //Utility method to check string is empty are not
    private Boolean IsEmptyOrNull(String strValue){
        return (strValue == null || strValue.trim().equals('')) ? true : false;
    }
    //Utility method to get pegerefernance parameters
    @TestVisible private String getURParameter(String pname)
    {   
        PageReference pageRef = ApexPages.currentPage();
        Map<string,string> pageParameters = pageRef.getParameters();
        string p = pageParameters.get(pname);
        return p;
    }
}