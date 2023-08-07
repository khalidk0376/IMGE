/**
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-60)]
 * Created On   :   June 28 2019
 * @description :   [For the static resource fetching and passing into forgot password email template .]
 * Test Class   :   SsoEmailHeaderChangePassCtrlTest
 * Modification Log----- 
 * Modified by  :  Rajesh Kumar on BK-6910 - 29-07-2020 
 **/
public class SsoEmailHeaderChangePassCtrl 
{   
    public string ssoLang{get;set;}
    public string getinformaImg()
    {  
        String body = 'esso_ChangePass_Email_header_Image';
        string baseUrl = '';
        if(!test.isRunningTest())
        {
            ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity([SELECT Id FROM Network WHERE Name ='Informa Markets' ].id);
            baseUrl = myCommunity.siteUrl;
        }        
        if(string.isNotBlank(ssoLang))
        {
            List<StaticResource> staticRes = new List<StaticResource>();
            string langReso = 'esso_ChangePass_Email_header_Image';
            staticRes = [select id, name, body from StaticResource where name =: langReso limit 1];
            if(staticRes.size()>0)
            {
                body = staticRes[0].name;    
            } 
        }
        string url =  baseUrl+'/resource/'+body; 
        return url;
    }
}