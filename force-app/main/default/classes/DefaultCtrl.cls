/*
Created By      : Girikon(Sunil)
Created On      : Sep 17 2019
@description    : This class is used to redirect the user to the customer center community.
Test Class      : DefaultCtrl_Test(100%)

Modification log -- [Aishwarya BK-2520 Sep 17 2019],Himanshu Jasuja[BK - 3748]
Modified By     : 
*/
public  without sharing class DefaultCtrl {
    
    public  String  eventCode;
    public DefaultCtrl()
    {
          
        eventCode = apexpages.currentpage().getparameters().get('eventcode').escapeHtml4();
    }
    public PageReference redirectCommunity()
    {
       
        string strUrl='https://informamarkets.force.com/CustomerCenter';
        if(string.isNotBlank(eventCode)) 
        {
            strUrl=strUrl+'?eventcode='+eventCode;
        }
        return new PageReference(strUrl);  
    } 
    
    public PageReference redirectToResetPassword()
    {
        
        string strUrl='https://informamarkets.force.com/CustomerCenter?reset=1';
        if(string.isNotBlank(eventCode)) 
        {
            strUrl=strUrl+'?eventcode='+eventCode;
        }
        return new PageReference(strUrl);  
    }
}