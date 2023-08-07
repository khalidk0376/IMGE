/**
 * Created : Girikon(Sunil)
 * Modified : Girikon(Divaker Singh)/Ticket CCEN:48 , Girikon(Garima Gupta)[CCEN-748],[Aishwarya 23 Sep 2020 BK-8006]
 * Created On:          20 Feb 2018
 * @description      : This class provides following functionalities:
 *                      Fetch opportunity booth details.
 * Methods:             getOppBoothDetails
 * Test Class:          ExhibitorWelcomeEmailCtrl_Test(91%)
**/
public without sharing class ExhibitorWelcomeEmailCtrl
{    
     public user usr;
     public string sContactId{get;set;}
     public string sIdContact{get;set;}
     public Event_Settings__c eventSet{get;set;}
     public boolean isImageExistImg{get;set;}
     public boolean isEmailBodyOne{get;set;}
     public boolean isEmailBodytwo{get;set;}
     public boolean isBoothExistbooth{get;set;}
     public string conevntId;
    
     //Method to fetch Opportunity Booth Summary
     public string getOppBoothDetails()
     {
        string boothnos='';
        set<string> setBoothsNos = new set<string>(); 
        List<Contact> con = new List<Contact>();
        con = [Select id,User_Created_for_Event_Edition__c from Contact where id =:sIdContact limit 1];
        if(!con.IsEmpty())
        {
            conevntId = con[0].User_Created_for_Event_Edition__c;
        }
        List<ContactEventEditionMapping__c> objCEEM=new List<ContactEventEditionMapping__c>();
        objCEEM = [select id,SFContactID__c,SFContactID__r.accountid,SFEventEditionID__c from ContactEventEditionMapping__c where SFContactID__c=:sIdContact and SFEventEditionID__c =: conevntId order by createddate desc  limit 1 ];
        system.debug('objCEEM ================='+objCEEM );
         if(!objCEEM.IsEmpty())
        {
            string accountId =objCEEM[0].SFContactID__r.accountid;
            String eventId = objCEEM[0].SFEventEditionID__c;
            set<string> quoteIds = new set<string>();
            objCEEM[0].IsEmailSent__c=true;
            if(string.isNotBlank(accountId) && string.isNotBlank(eventId))
            {
                List<opportunity> opp = new List<opportunity>();
                opp =  [select id,Name,SBQQ__PrimaryQuote__c,EventEdition__c from opportunity where AccountId=:accountId AND  EventEdition__c=:eventId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
                
                if(opp.size()>0)
                {
                    for(opportunity oppty: opp)
                    {
                        if(string.isNotBlank(oppty.SBQQ__PrimaryQuote__c))
                        {
                            quoteIds.add(oppty.SBQQ__PrimaryQuote__c);    
                        }                        
                    }
                    List<Opportunity_ExpoCAD_Booth_Mapping__c> expoBooths = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
                    if(quoteIds.size()>0)
                    {
                        expoBooths = [Select Id,Badge_Limit__c,Booth_Number__c,Expocad_Booth__r.Matched_Product_Name__c, Area__c, Expocad_Booth__r.Unit_Type__c,Expocad_Booth__r.Dimensions__c,Expocad_Booth__r.Open_Corners__c,Opportunity__c, Opportunity__r.Name, Opportunity__r.createdDate, Display_Name__c,Opportunity__r.account.name, Expocad_Booth__r.Status__c From  Opportunity_ExpoCAD_Booth_Mapping__c where (Expocad_Booth__r.Status__c='Rented' or Expocad_Booth__r.Status__c='Added To Quote/On Hold') and Quote__c IN:quoteIds order by Opportunity__r.createdDate];
                    }                     
                    if(expoBooths.size()>0)
                    {
                        for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: expoBooths)
                        {
                            if(string.isNotBlank(ecb.Booth_Number__c) && !setBoothsNos.contains(ecb.Booth_Number__c))
                            {
                                setBoothsNos.add(ecb.Booth_Number__c); // to remove Duplicate Booth Nos .
                                boothnos += (boothnos==''?ecb.Booth_Number__c:','+ecb.Booth_Number__c);
                                isBoothExistbooth=true; 
                            }
                        }                           
                    }
                }
            }
        }
        system.debug('boothnos ================='+boothnos );
        return boothnos;
    }
     
    //Method for fetch Community URL 
    public string getCommunityURL()
    {
        Network myNetwork = [SELECT Id FROM Network WHERE Name ='Customer Centre'];
        //System.debug('MyDebug: ' + Network.getLoginUrl(myNetwork.id));
        return Network.getLoginUrl(myNetwork.id);
    }

    //Method for fetch dynamic Email body one for Actor Type/CCEN 48
    public string getemailBodyOne()
    {
        string sEmailBody='';
        isEmailBodyOne=true; 
        List<Contact> con = new List<Contact>();
        con = [Select id,User_Created_for_Event_Edition__c from Contact where id =:sContactId limit 1];
        if(!con.IsEmpty())
        {
            conevntId = con[0].User_Created_for_Event_Edition__c;
        }
        List<ContactEventEditionMapping__c> listEventMapping=new List<ContactEventEditionMapping__c>();
        if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible()) // EXPOCAD Change CCEN-753
        {
            listEventMapping = [SELECT id, SFContactID__r.accountid, SFEventEditionID__c, User_Type__r.Name  FROM ContactEventEditionMapping__c WHERE SFContactID__c=:sContactId and SFEventEditionID__c =: conevntId order by createddate desc  LIMIT 1 ];
        }        
        system.debug('listEventMapping================='+listEventMapping);
        if(!listEventMapping.IsEmpty())
        {
            //Check user type for Agent Owned Exhibitor and fetch email template from contact event edition map / CCEN-73
            system.debug('listEventMapping[0].User_Type__r.Name================='+listEventMapping[0].User_Type__r.Name);
             if(listEventMapping[0].User_Type__r.Name =='Agent Owned Exhibitor')
             {
                list<AgentExhibitorsContact__c> lstagentExhCon = new list<AgentExhibitorsContact__c>();
                if(Schema.sObjectType.AgentExhibitorsContact__c.isAccessible()) // EXPOCAD Change CCEN-753
                {
                    lstagentExhCon =[select id,AgentContactId__c from AgentExhibitorsContact__c where ExhibitorContactId__c =: sContactId limit 1];
                }
                if(!lstagentExhCon.IsEmpty())
                {
                    system.debug('listEventMapping[0].User_Type__r.Name================='+listEventMapping[0].User_Type__r.Name);
                    List<ContactEventEditionMapping__c> lstConEnvMap=new List<ContactEventEditionMapping__c>();
                    lstConEnvMap = [SELECT id, Agent_Email_Body_Content_1__c,Agent_Email_Body_Content_2__c  FROM ContactEventEditionMapping__c WHERE SFContactID__c=:lstagentExhCon[0].AgentContactId__c AND SFEventEditionID__c= :listEventMapping[0].SFEventEditionID__c order by createddate desc  LIMIT 1 ];
                    system.debug('lstConEnvMap================='+lstConEnvMap);
                    if(!lstConEnvMap.IsEmpty())
                    {
                        sEmailBody=lstConEnvMap[0].Agent_Email_Body_Content_1__c;
                        return sEmailBody; 
                    }
                }
            }

            List<Event_Settings__c> lstEventSetting = [SELECT Id, Co_Exhibitor_Email_Content1__c, Co_Exhibitor_Email_Content2__c, Exhibitor_Email_Content1__c, Exhibitor_Email_Content2__c, Agent_Email_Content1__c, Agent_Email_Content2__c, Stand_Contractor_Content1__c, Stand_Contractor_Content2__c, Welcome_Email_Banner__c FROM Event_Settings__c WHERE Event_Edition__c = :listEventMapping[0].SFEventEditionID__c];
            system.debug('lstEventSetting================='+lstEventSetting);
            if(!lstEventSetting.IsEmpty()){
                //BK-8006 Start
                String imageURL = '';
                if(System.Label.RTE_Image_Url_New_Community_User !=null){
                    imageURL=System.Label.RTE_Image_Url_New_Community_User;
                } 
                for(Event_Settings__c oEventSetting:lstEventSetting){
                    if(listEventMapping[0].User_Type__r.Name =='Exhibitor'){
                        sEmailBody = oEventSetting.Exhibitor_Email_Content1__c;
                        if(sEmailBody != null && sEmailBody !=''){
                            sEmailBody = sEmailBody.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                        }
                    }
                    else if(listEventMapping[0].User_Type__r.Name =='Stand Contractor'){
                        sEmailBody = oEventSetting.Stand_Contractor_Content1__c;
                        if(sEmailBody != null && sEmailBody !=''){
                            sEmailBody = sEmailBody.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                        }
                    }
                    else if(listEventMapping[0].User_Type__r.Name=='Co-Exhibitor'){
                        sEmailBody = oEventSetting.Co_Exhibitor_Email_Content1__c;
                        if(sEmailBody != null && sEmailBody !=''){
                            sEmailBody = sEmailBody.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                        }
                    }   
                    else if(listEventMapping[0].User_Type__r.Name =='Agent'){
                        sEmailBody = oEventSetting.Agent_Email_Content1__c;
                        if(sEmailBody != null && sEmailBody !=''){
                            sEmailBody = sEmailBody.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                        }
                    }   //BK-8006 End
                }
            }
        }
        return sEmailBody;
    } 

    //Method for fetch dynamic Email body two for Actor Type/CCEN 48
    public string getemailBodyTwo(){
        string sEmailBody='';
        isEmailBodytwo = true; 
        List<Contact> con = new List<Contact>();
        con = [Select id,User_Created_for_Event_Edition__c from Contact where id =:sContactId limit 1];
        if(!con.IsEmpty())
        {
            conevntId = con[0].User_Created_for_Event_Edition__c;
        }
        List<ContactEventEditionMapping__c> listEventMapping=new List<ContactEventEditionMapping__c>();
        listEventMapping = [SELECT id, SFContactID__r.accountid, SFEventEditionID__c, User_Type__r.Name  FROM ContactEventEditionMapping__c WHERE SFContactID__c=:sContactId and SFEventEditionID__c =: conevntId order by createddate desc  LIMIT 1 ];
        system.debug('listEventMapping================='+listEventMapping);
        if(!listEventMapping.IsEmpty())
        {
            //Check user type for Agent Owned Exhibitor and fetch email template from contact event edition map / CCEN-73
             if(listEventMapping[0].User_Type__r.Name =='Agent Owned Exhibitor'){
                list<AgentExhibitorsContact__c> lstagentExhCon = new list<AgentExhibitorsContact__c>();
                lstagentExhCon =[select id,AgentContactId__c from AgentExhibitorsContact__c where ExhibitorContactId__c =: sContactId limit 1];
                if(!lstagentExhCon.IsEmpty())
                {
                    List<ContactEventEditionMapping__c> lstConEnvMap=new List<ContactEventEditionMapping__c>();
                    lstConEnvMap = [SELECT id, Agent_Email_Body_Content_1__c,Agent_Email_Body_Content_2__c  FROM ContactEventEditionMapping__c WHERE SFContactID__c=:lstagentExhCon[0].AgentContactId__c AND SFEventEditionID__c= :listEventMapping[0].SFEventEditionID__c order by createddate desc  LIMIT 1 ];
                    if(!lstConEnvMap.IsEmpty())
                    {
                        sEmailBody=lstConEnvMap[0].Agent_Email_Body_Content_2__c;
                        return sEmailBody; 
                    }
                }
            }

            List<Event_Settings__c> lstEventSetting = [SELECT Id, Co_Exhibitor_Email_Content1__c, Co_Exhibitor_Email_Content2__c, Exhibitor_Email_Content1__c, Exhibitor_Email_Content2__c, Agent_Email_Content1__c, Agent_Email_Content2__c, Stand_Contractor_Content1__c, Stand_Contractor_Content2__c, Welcome_Email_Banner__c FROM Event_Settings__c WHERE Event_Edition__c = :listEventMapping[0].SFEventEditionID__c];
            if(!lstEventSetting.IsEmpty()){
                system.debug('lstEventSetting================='+lstEventSetting);
                for(Event_Settings__c oEventSetting:lstEventSetting){
                    //BK-8006 Start
                    String imageURL = '';
                    if(System.Label.RTE_Image_Url_New_Community_User !=null){
                        imageURL=System.Label.RTE_Image_Url_New_Community_User;
                    } 
                    if(listEventMapping[0].User_Type__r.Name =='Exhibitor'){
                        sEmailBody = oEventSetting.Exhibitor_Email_Content2__c;
                        if(sEmailBody != null && sEmailBody !=''){
                            sEmailBody = sEmailBody.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                        }
                    }
                    else if(listEventMapping[0].User_Type__r.Name =='Stand Contractor'){
                        sEmailBody = oEventSetting.Stand_Contractor_Content2__c;
                        if(sEmailBody != null && sEmailBody !=''){
                            sEmailBody = sEmailBody.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                        }
                    }
                    else if(listEventMapping[0].User_Type__r.Name=='Co-Exhibitor'){
                        sEmailBody = oEventSetting.Co_Exhibitor_Email_Content2__c;
                        if(sEmailBody != null && sEmailBody !=''){
                            sEmailBody = sEmailBody.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                        }
                    }   
                    else if(listEventMapping[0].User_Type__r.Name =='Agent'){
                        sEmailBody = oEventSetting.Agent_Email_Content2__c;
                        if(sEmailBody != null && sEmailBody !=''){
                            sEmailBody = sEmailBody.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                        }
                    }   //BK-8006 End
                }
            }
        }
        return sEmailBody;
    } 

    //Fetch Event Image Url for Email Template from Event setting record/CCEN 48
    public string geteventUrl(){
        isImageExistImg = true;
        string sEventUrl='';
        List<Contact> con = new List<Contact>();
        con = [Select id,User_Created_for_Event_Edition__c from Contact where id =:sContactId limit 1];
        if(!con.IsEmpty())
        {
            conevntId = con[0].User_Created_for_Event_Edition__c;
        }
        List<ContactEventEditionMapping__c> listEventMapping=new List<ContactEventEditionMapping__c>();
        listEventMapping = [select id, SFContactID__r.accountid, SFEventEditionID__c, User_Type__r.Name  from ContactEventEditionMapping__c where SFContactID__c=:sContactId and SFEventEditionID__c =: conevntId order by createddate desc  limit 1 ];
        system.debug('listEventMapping================='+listEventMapping);
        if(!listEventMapping.IsEmpty())
        {
            List<Event_Settings__c> lstEventSetting = [SELECT Id, Welcome_Email_Banner__c, Organization_Id_Ops_Admin__c FROM Event_Settings__c WHERE Event_Edition__c = :listEventMapping[0].SFEventEditionID__c];
            system.debug('lstEventSetting================='+lstEventSetting);
            if(!lstEventSetting.IsEmpty()){
                for(Event_Settings__c oEventSetting:lstEventSetting){
                    if(oEventSetting.Welcome_Email_Banner__c !=null)
                    {
                        sEventUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+oEventSetting.Welcome_Email_Banner__c+'&oid='+oEventSetting.Organization_Id_Ops_Admin__c;
                    }
                }
            }
        }
        return sEventUrl;
    }          
}