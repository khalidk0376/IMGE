/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created/LastModifiedDate:    10 Feb 2021, [Aishwarya BK-14559 17 March 2021]
 * Test Class:    ccLiveChatCtr_Test
 * @description : This class call from the VF page - ccLiveChat
**/

public class ccLiveChatCtr{
    public String contactFirstName {get;set;}
    public String contactLastName  {get;set;}
    public String contactEmail     {get;set;}
    public String ccURL            {get;set;}
    public String IMEditionId      {get;set;}
    public Boolean isAgentOnline   {get;set;}
    public String SupportTeam      {get;set;}
    public String ChatDeployment   {get;set;}
    public String ButtonID         {get;set;}
    public String AgentDevName     {get;set;}
    public String DeploymentId     {get;set;}
    public List<Event_Settings__c> listEveSetting;
    
    public ccLiveChatCtr(){
        listEveSetting = new List<Event_Settings__c>();
        contactFirstName = '';
        contactLastName = '';
        contactEmail = '';
        IMEditionId = '';  
        SupportTeam = '';
        ChatDeployment = '';
        ButtonID = '';
        AgentDevName = '';
        DeploymentId = '';
        isAgentOnline = false;
        string s1 ='';
        string eveCodeFromURL ='';
        ccURL = ApexPages.currentPage().getHeaders().get('Referer');
        if(ccURL !=null && ccURL !='' && ccURL.contains('eventcode')){
            eveCodeFromURL = ccURL.substringAfter('eventcode');
            //system.debug('@@@@@@@@@@@@@@@@@@@@3344'+eveCodeFromURL );
            if(eveCodeFromURL.contains('&')){
                eveCodeFromURL = eveCodeFromURL.substringBefore('&');
            }
            if(eveCodeFromURL.contains('=')){
                eveCodeFromURL = eveCodeFromURL.replace('=', '');
            }
        }
        
        if(!Test.isRunningTest()){
            listEveSetting = [Select Id, IM_EventEditionId__c, Live_Agent_Online__c, CS_Team__c, CS_Team__r.AgentDevName__c, CS_Team__r.Button_ID__c, CS_Team__r.Chat_Deployment__c,
                              CS_Team__r.SupportTeam__c, CS_Team__r.Deployment_Id__c FROM Event_Settings__c where Event_Edition__r.Event_Code__c =:eveCodeFromURL LIMIT 1];
            SYSTEM.DEBUG('@@@@@@@@@@@@@'+listEveSetting);
        }
        else{
            listEveSetting = [Select Id, IM_EventEditionId__c, Live_Agent_Online__c, CS_Team__c, CS_Team__r.AgentDevName__c, CS_Team__r.Button_ID__c, CS_Team__r.Chat_Deployment__c,
                              CS_Team__r.SupportTeam__c, CS_Team__r.Deployment_Id__c FROM Event_Settings__c LIMIT 1];
        }
        
        if(listEveSetting.size()>0){
            IMEditionId   = listEveSetting[0].IM_EventEditionId__c;
            isAgentOnline = listEveSetting[0].Live_Agent_Online__c;
        }

        if(listEveSetting.size()>0 && listEveSetting[0].CS_Team__c !=null){
            SupportTeam    = listEveSetting[0].CS_Team__r.SupportTeam__c;            
            AgentDevName   = listEveSetting[0].CS_Team__r.AgentDevName__c;
            ButtonID       = listEveSetting[0].CS_Team__r.Button_ID__c;
            ChatDeployment = listEveSetting[0].CS_Team__r.Chat_Deployment__c;
            DeploymentId   = listEveSetting[0].CS_Team__r.Deployment_Id__c;
        }
        getCurrentUserContact();
    }
    
    public void getCurrentUserContact()
    {
        User u = [SELECT Id, ContactId, Contact.FirstName, Contact.LastName, Contact.Email FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
        contactFirstName = u.Contact.FirstName;
        contactLastName = u.Contact.LastName;
        contactEmail = u.Contact.Email;
    }
}