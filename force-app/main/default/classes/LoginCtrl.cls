/**
* Created/Modified By: Girikon(Pramod )
* Created On:          5-1-2017
* @description : This class provides following functionalities:
*                      If community url is having event code then display event data on login page i.e. event name & log
*                      Allow login to valid user (with or without event code) else show proper error message
*                      Allow valid user to put the request for new password.
* Methods:             GetUserData, getEventCode, resetPassword
* Test Class:          LoginCtrl_Test
* Modification log --
* Modified By: {Girikon(Prashant)} [Jira CCEN-243], 09/13/2018},{Girikon(Pramod) [Jira# CCEN-502],11/23/2018},{Girikon(Pramod) [Jira# CCEN-465],11/23/2018},{Girikon(Ashish) [Jira# CCEN-785],6 April 2019, [Aishwarya CCEN-814 7 Apr 2019],[Aishwarya BK-1869 4 July 2019],[Aishwarya BK-2520 Sep 17 2019]}
**/

public without sharing class LoginCtrl
{
    public string username {get;set;}
    public string password {get;set;}
    public string errMsg{get;set;}
    public boolean showForgotPwd{get;set;}
    public Event_Edition__c event{get;set;}
    public Event_Settings__c eventSet{get;set;}
    public String eventEditionCode{get;set;}
    public String brandingColor{get;set;}  
    public String aboutShow{get;set;} 
    public String showHours1{get;set;}
    public String showHours2{get;set;}
    public String showHours3{get;set;}
    public String link1Label{get;set;}
    public String link2Label{get;set;}
    public String link3Label{get;set;}
    public String link4Label{get;set;}
    public String link1{get;set;}
    public String link2{get;set;}
    public String link3{get;set;}
    public String link4{get;set;}  
    public String facebook{get;set;}
    public String twitter{get;set;}
    public String youtube{get;set;}
    public String linkedin{get;set;}
    public String footerbackgroundColor{get;set;}
    public String footertextColor{get;set;}
    public String imageURL{get;set;}    
    
    //CCEN-465
    public String chatButtonId{get;set;}
    public String deploymentId{get;set;}
    public String deploymentURL1{get;set;}
    public String deploymentURL2{get;set;}
    public Boolean liveAgentOnline{get;set;}
    public String IMEditionId {get;set;}
    public String SupportTeam {get;set;}
    public String ChatDeployment {get;set;}
    public String ButtonID {get;set;}
    public String AgentDevName {get;set;}
    public String ChatDeploymentId {get;set;}
    //public String siteUrls{get;set;}/* test */
    public Boolean ifIsReset{get;set;} //BK-2520
    public String getSiteURL() 
    {
        return System.URL.getSalesforceBaseURL().toExternalForm();
    }
    // TO get Current Org ID
    public String getOrgId() 
    {
        return UserInfo.getOrganizationId();
    }
    /*Class constructor*/
    public LoginCtrl()
    {  
        // BK-2520
        string isReset= apexpages.currentpage().getparameters().get('reset'); 
        if(isReset=='1')
        {
             showForgotPwd=true;
             ifIsReset = true;
        }     
        try
        {     
            string errorCode= apexpages.currentpage().getparameters().get('er');
            System.Debug('ErrorCode: '+ErrorCode);
            for (string param: ApexPages.currentPage().getParameters().keySet())
            {
                System.Debug('!DEBUG! Param: '+ param + '=' + ApexPages.currentPage().getParameters().get(param));
            }
            //Display proper error message as per errorcode
            if(string.isNotBlank(ErrorCode))
            {
                if(ErrorCode.equalsIgnoreCase('iunp'))
                {
                    errMsg='Incorrect user name and password.';
                }
                else if(ErrorCode.equalsIgnoreCase('iufte'))
                {
                    errMsg='Invalid user for this event.';
                }
                else if(ErrorCode.equalsIgnoreCase('iu'))
                {
                    errMsg='Incorrect user.';            
                }
            }
            
            //Get event code from to get event details to display on login page
            string eventCode= apexpages.currentpage().getparameters().get('eventcode');
            if(eventCode !=null)
            {
                if(string.isBlank(EventCode))
                {
                    eventCode = getEventCode();
                }
                
                if(string.isNotBlank(EventCode))
                {
                    List<Event_Edition__c> eves = [SELECT id,Name,Event_Edition_Image_URL__c,End_Date__c FROM Event_Edition__c WHERE Event_Code__c =:EventCode AND Event_Edition_Status__c='Confirmed'];
                    System.Debug('eves: '+eves);
                    IMEditionId ='';
                    if(eves!=null && eves.size()>0)
                    {
                        event=eves[0];
                        //Event_Settings__c 
                        eventSet = [Select Id, Name,Button_colors__c,Button_Text_Color__c,Footer_background_color__c, Footer_text_color__c,Branding_Color__c,About_Show__c,ShowHours1__c, ShowHours2__c, ShowHours3__c, Event_Edition__c, Event_Edition__r.Event_Code__c,
                                    Link_1_Label__c, Link_2_Label__c, Link_3_Label__c,Link_4_Label__c, Link_1__c, Link_2__c, Link_3__c,Link_4__c,FaceBook__c,Twitter__c,LinkedIn__c,
                                    YouTube__c,Live_Agent_Online__c, IM_EventEditionId__c, CS_Team__c, CS_Team__r.AgentDevName__c, CS_Team__r.Button_ID__c, CS_Team__r.Chat_Deployment__c,
                                    CS_Team__r.SupportTeam__c, CS_Team__r.Deployment_Id__c FROM Event_Settings__c where Event_Edition__c =: eves[0].Id limit 1];
                        
                        //Start :: CCEN-465
                        liveAgentOnline=eventSet.Live_Agent_Online__c;
                        System.Debug('liveAgentOnline: '+liveAgentOnline);
                        IMEditionId = eventSet.IM_EventEditionId__c;
                        if(eventSet.CS_Team__c !=null){
                            SupportTeam      = eventSet.CS_Team__r.SupportTeam__c;            
                            AgentDevName     = eventSet.CS_Team__r.AgentDevName__c;
                            ButtonID         = eventSet.CS_Team__r.Button_ID__c;
                            ChatDeployment   = eventSet.CS_Team__r.Chat_Deployment__c;
                            ChatDeploymentId = eventSet.CS_Team__r.Deployment_Id__c;
                        }
                        //Get live agent info
                        liveAgentValue();
                        //End :: CCEN-465
                        
                        brandingColor = eventSet.Branding_Color__c;
                        footerbackgroundColor= eventSet.Footer_background_color__c;
                        footertextColor=eventSet.Footer_text_color__c;
                        aboutShow = eventSet.About_Show__c;
                        showHours1 = eventSet.ShowHours1__c;
                        showHours2 = eventSet.ShowHours2__c;
                        // BK-1869 add showHours3
                        showHours3 = eventSet.ShowHours3__c;
                        
                        link1Label = eventSet.Link_1_Label__c;
                        link2Label = eventSet.Link_2_Label__c;
                        link3Label = eventSet.Link_3_Label__c;
                        link4Label = eventSet.Link_4_Label__c;
                        facebook = eventSet.FaceBook__c;
                        twitter = eventSet.Twitter__c;
                        linkedin = eventSet.LinkedIn__c;
                        youtube = eventSet.YouTube__c;
                        
                        String l1 = eventSet.Link_1__c;
                        String l2 = eventSet.Link_2__c;
                        String l3 = eventSet.Link_3__c;
                        String l4 = eventSet.Link_4__c; 
                        
                        if(String.IsNotBlank(l1) && l1.containsIgnoreCase('http')){link1 = l1;}
                        else{ link1='http:\\'+l1; }
                        if(String.IsNotBlank(l2) && l2.containsIgnoreCase('http')){ link2 = l2;}
                        else{ link2='http:\\'+l2; }
                        if(String.IsNotBlank(l3) && l3.containsIgnoreCase('http')){ link3 = l3;}
                        else{ link3='http:\\'+l3; }
                        if(String.IsNotBlank(l4) && l4.containsIgnoreCase('http')){ link4 = l4; }
                        else{ link4='http:\\'+l4; }                        
                    }
                    else
                    {
                        errMsg='Either invalid event code or event has been ended.';
                    }
                }
                System.Debug('event: '+event);
            }
            
            imageURL='/servlet/servlet.FileDownload?file=';  
            //List<document> documentList=[select id, name from document where name='Informa Exhibitions Logo' Limit 1]; 
            List<document> documentList=[select id, name from document where name='Informa Markets Logo' Limit 1]; 
            
            if(documentList.size()>0)
            {
                imageURL=imageURL+documentList[0].id;
            }
         }
        catch(Exception ex)
        {
            System.Debug('Error : '+ex.getMessage());   
        }
        
        //return pageRef;
    } 
    
    /*Method to get the ids of liveAgent*/ //CCEN-465
    public void liveAgentValue()
    {           
        //Get custom label which contains SF IDs of live agent chat button & deployment (comma seperated)
        String liveAgentIDs= Label.Live_Agent_IDs;
        if(string.isNotBlank(liveAgentIDs))
        {
            //Get chat button id
            chatButtonId=liveAgentIDs.Split(',')[0];
            //Get deployment id
            deploymentId=liveAgentIDs.Split(',')[1];
        } 
        
        //Get custom label which contains Live agent deployment urls(comma seperated)
        String liveAgentURLs= Label.Live_Agent_URLs;
        if(string.isNotBlank(liveAgentURLs))
        {
            //Get chat button id
            deploymentURL1=liveAgentURLs.Split(',')[0];
            //Get deployment id
            deploymentURL2=liveAgentURLs.Split(',')[1];
        } 
        System.debug('chatButtonId: '+chatButtonId+',deploymentId: '+deploymentId);
    }
    
    /* Method to get user data & redirect user to respective page*/
    public PageReference getUserData(string eventCode)
    {
        PageReference pageRef;
        String eventcodeParam='';
        
        
        if(string.isNotBlank(EventCode))
        {
            eventcodeParam='&eventcode='+EventCode;
        }
        System.Debug('EventCode : '+EventCode);
        System.Debug('eventcodeParam : '+eventcodeParam);
        System.Debug('username : '+username);
        username =username.trim();
        List<User> usr=[Select Id,Contact.Type__r.Name,Contact.id From User Where username=:username AND IsActive=True];
        if(usr!=null && usr.size()>0 && usr[0].Contact!=null)
        {
            string strQuery='select id,SFEventEditionID__r.Event_Code__c, SFEventEditionID__r.Event_Edition_Code__c from ContactEventEditionMapping__c where SFContactID__c =\''+ String.escapeSingleQuotes(usr[0].Contact.id)+'\'';
            strQuery +=' AND SFEventEditionID__r.Event_Code__c != null';
            //CCEN-814
            strQuery +=' AND IsEmailSent__c = True AND Status__c = True';
            if(string.isNotBlank(EventCode))
            {
                strQuery +=' AND SFEventEditionID__r.Event_Code__c =\''+String.escapeSingleQuotes(EventCode)+'\'';
            }                
            System.Debug('strQuery :'+strQuery);
            List<ContactEventEditionMapping__c> cntctMapLst=Database.query(strQuery);
            System.Debug('cntctMapLst :'+cntctMapLst);
            if(cntctMapLst!=null && cntctMapLst.size()>0)
            {
                EventCode = cntctMapLst[0].SFEventEditionID__r.Event_Code__c;
                eventEditionCode = cntctMapLst[0].SFEventEditionID__r.Event_Edition_Code__c;
                string communityURL ='/s/?eventcode='+EventCode+'&eventedition='+eventEditionCode;
                System.Debug('CommunityURL  :'+CommunityURL);
                if(usr!=null && usr.size()>0 && !String.isBlank(usr[0].Contact.Type__r.Name))
                {
                    CommunityURL= '/s/?eventcode='+EventCode+'&eventedition='+eventEditionCode;
                    // if(usr[0].Contact.Type__r.Name.equalsIgnoreCase('Agent'))
                    //     CommunityURL= '/AgentHome?eventcode='+EventCode+'&eventedition='+eventEditionCode;
                    // if(usr[0].Contact.Type__r.Name.equalsIgnoreCase('Exhibitor'))
                    //     CommunityURL= '/Home?eventcode='+EventCode+'&eventedition='+eventEditionCode;
                    // if(usr[0].Contact.Type__r.Name.equalsIgnoreCase('Contractor'))
                    //     CommunityURL= '/ContractorHome?eventcode='+EventCode+'&eventedition='+eventEditionCode;
                }
                pageRef = Site.login(username, password, CustomIdentityRedirect.CustomerUrl(CommunityURL ));
                System.Debug('pageRef: '+pageRef);
                if(pageRef == null)
                {
                    pageRef=new PageReference('/apex/UserLogin?er=iunp&eventcode='+EventCode+'&eventedition='+eventEditionCode);
                    pageRef.setRedirect(true);
                }
            }
            else if(string.isNotBlank(EventCode))
            {
                pageRef=new PageReference('/apex/UserLogin?er=iufte&eventcode='+EventCode+'&eventedition='+eventEditionCode);
                pageRef.setRedirect(true);
            }
            else
            {
                pageRef = Site.login(username, password, CustomIdentityRedirect.CustomerUrl('/apex/Welcome'));
                System.Debug('pageRef: '+pageRef);
                if(pageRef == null)
                {
                    pageRef=new PageReference('/apex/UserLogin?&er=iunp&eventcode='+EventCode+'&eventedition='+eventEditionCode);
                    pageRef.setRedirect(true);
                }
            }
        }
        else
        {
            pageRef=new PageReference('/apex/UserLogin?&er=iu'+eventcodeParam);
            pageRef.setRedirect(true);
        }
        return pageRef;
    }
    
    //Get event code from encoded url
    public string getEventCode()
    {
        string eventCode = '';
        string url='';
        string headerdata= ApexPages.currentPage().getHeaders().get('Host');
        string urlvalue=Apexpages.currentPage().getUrl(); 
        string currentURL ='https://' + headerdata+ urlvalue;
        String encoded = EncodingUtil.urlDecode(currentURL, 'UTF-8');
        string[] strArr=encoded.split('\\?');
        System.Debug('strArr: '+strArr);
        System.Debug('strArr.size(): '+strArr.size());
        if(strArr!=null && strArr.size()>0)
        {
            URL=strArr[1];
            if(strArr.size()>2)
            {
                EventCode=strArr[2];
            }                    
            string[] strURLArr=URL.split('=');
            if(strURLArr!=null && strURLArr.size()>1)
            {
                URL=strURLArr[1];
                URL=URL.remove('\'');
            }
            string[] strparamArr;
            if(String.IsNotBlank(EventCode))
            {
                strparamArr=EventCode.split('=');
            }                
            if(strparamArr!=null && strparamArr.size()>0)
            {
                EventCode=strparamArr[1];
            }
        }
        return EventCode;
    }
    
    /*Login functionality with or without event code*/
    public PageReference login() 
    {
        PageReference pageRef;
        string eventCode= apexpages.currentpage().getparameters().get('eventcode');
        if(EventCode!=null && string.isBlank(EventCode))
        {
            EventCode = getEventCode();
        }
        pageRef=GetUserData(EventCode);
        
        
        return pageRef;
    }
    /* End*/
    
    /*Show forgot password panel*/
    public PageReference forgotPassword() 
    {
        errMsg='';
        showForgotPwd=true;
        return null;
    }
    /* End*/
    
    /*Processing for reset password*/
    public PageReference resetPassword() 
    {        
        if(username != null && username != '')
        {
            username =username.trim();
            List<user> listbs = [SELECT Username,Email FROM user WHERE Username=: username LIMIT 1];
            if(listbs.size() > 0) 
            {
                string str = listbs[0].Email;
                string[] strLst = str.Split('@');
                string str1 = strLst[0].replaceAll('(?!^).(?!$)', '*');
                string userEmail =  str1+'@'+strLst[1];
                boolean success =Site.forgotPassword(username);
                if(success)
                {
                    errMsg='Password reset link has been sent to , '+ userEmail;
                }                    
            } 
            else 
            {
                System.debug('No record');
                errMsg= 'Invalid user name';
            }
        }
        else
        {
            System.debug('Outside username');
            errMsg = 'Please enter user name!' ;
        }
        return null;
    }
    /* End*/
    
    //Redirect user to CC home page when Ops Admin does "Login As Customer" [CCEN-502]
    public PageReference redirectToHome() 
    {
        PageReference pageRef;
        // For Site Maintenance  [CCEN-785]
        
        CC_community_Setting__c ccStng = CC_community_Setting__c.getValues('Customer Center');
        if(ccStng !=  null && ccStng.Under_Maintenance__c == true)
        {  
            string url = System.URL.getSalesforceBaseUrl().toExternalForm()+'/CustomerCenter/CC_Maintenance';             
            pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;
        } 

        string userID = UserInfo.getUserId();
        if(String.isNotBlank(userID))
        {
            List<User> usr=[Select Id,Contact.Type__r.Name,Contact.id From User Where ID =: userID AND IsActive=True ];
            
            list<ContactEventEditionMapping__c> conEvntMp = new list<ContactEventEditionMapping__c>();
            list<Event_Settings__c> evntStng = new list<Event_Settings__c>();
            if(!usr.isEmpty() && usr[0].Contact.id != null)
            {   
                set<Id>evntIDs =  new set<id>();
                evntStng = [select id,Event_Edition__c from Event_Settings__c where Is_Event_Edition_Live__c = true And Event_Edition__c in (select SFEventEditionID__c from ContactEventEditionMapping__c where SFContactID__c =: usr[0].Contact.id And SFEventEditionID__r.Event_Edition_Status__c = 'Confirmed' And SFEventEditionID__r.Event_Code__c != null) ORDER BY createddate ];                
                for(Event_Settings__c evStng : evntStng)
                {
                    evntIDs.add(evStng.Event_Edition__c);
                } 
                conEvntMp = [select id,SFEventEditionID__c,SFEventEditionID__r.Event_Code__c,SFEventEditionID__r.Event_Edition_Code__c from ContactEventEditionMapping__c where SFContactID__c =: usr[0].Contact.id And SFEventEditionID__c in :evntIDs ORDER BY createddate];            
            }
            if(conEvntMp.size()>0)
            {
                string eventcode        = conEvntMp[0].SFEventEditionID__r.Event_Code__c;
                string eventEditionCode = conEvntMp[0].SFEventEditionID__r.Event_Edition_Code__c;  
                
                string url;
                string baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
                baseUrl = baseUrl+'/CustomerCenter';
                url = baseUrl+'/s/?eventcode=' + eventcode +'&eventedition='+ eventEditionCode; 
                
                pageRef = new PageReference(url);
                pageRef.setRedirect(true);
                return pageRef;
            }
        }        
        return null; 
    }
     
}