/*Created By: {Girikon(Pramod)}
Created On: Feb 27 2019
@ description/Purpose: [CCEN-695] This class is to make attachments available through CC community url with encrypted salesforce ID,  [Aishwarya BK-15194 20 Apr 2021]
Test Class: ViewAttCtrl_Test(85%)
*/

//Display attachment file controller
Public Class ViewAttCtrl
{
    Public ViewAttCtrl(){
        system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
    }
    /*
    Public AttProps attProp{get;set;}
    Public ViewAttCtrl()
    {
        string baseUrl = ''; 
        string ur ='';
        //Get community
        if(!test.isRunningTest())
        {
            Network ccNetwork = [SELECT Id FROM Network WHERE Name ='Customer Centre' ];
            ConnectApi.Community ccCommunity = ConnectApi.Communities.getCommunity(ccNetwork.id); baseUrl  = ccCommunity.siteUrl;
        }        
        //Get attachment salesforce record
        List<Attachment> atts=[select Id,ContentType from Attachment where Id=:ApexPages.currentPage().getParameters().get('file')];
        attProp=new AttProps();
        if(!atts.isEmpty())
        {
            //Get type of record
            attProp.type=atts[0].ContentType;
            //Prepare attachment url by prefix community base url and suffixing record salesforce ID
            attProp.url= baseUrl+'/servlet/servlet.FileDownload?file='+atts[0].Id;
        }
    }    
    //Wrapper class
    Public Class AttProps
    {
        public string type{get;set;}
        public string url{get;set;}
    }
    */
}