/*
* Created By    :  Girikon(Pramod)
* Created on    : 04/12/2018
* @description  : The purpose of this class is to keep common reusable functionalities at single place.
* Test Class    : UtilityMethods_Test(85%)

* Modification Log----- 
* Modified by : Girikon(Mahesh), Girikon(Sunil)[CCEN-589] on Jan 10 2019, [CCEN-312],Girikon(Ashish) [CCEN-270],Girikon(Ashish) [CCEN-327],Girikon(Mahesh)[CCEN-358],Girikon(Ashish)[CCEN-457] [CCEN-355],Girikon(Prashant)[CCEN-416][CCEN-692 March 7 2019],
Ashish [CCEN-585] on Jan 08 2019,Aishwarya[CCEN-600] on Feb 05 2019, Pramod [CCEN-695] on Feb 27 2019. Girikon(Mahesh)[CCEN-289 March 18 2019],[Girikon(Garima) CCEN-761 April 22 2019],[Girikon(Garima) CCEN-725 June 06 2019], [Girikon(Amish) CCEN-347 June 05 2019],[Girikon(Rajeev)BK-2753 Oct 22 2019],[Girikon(Aishwarya)BK-2736 Oct 24 2019],[Girikon Aishwarya BK-3893 Apr 15 2020]
* Modified On: 08/01/2018, 09/26/2018, 10/12/2018, 10/22/2018,10/22/2018,11/12/2018,11/15/2018,11/22/2018,/Himanshu Jasuja[BK - 3748]/29/04/2020, [Aishwarya BK-8006 23 Sep 2020]
               [Aishwarya BK-12701 22 Jan 2021]
*/
public without sharing class UtilityMethods
{
    /**** CCEN-347 Start ****/
    public String siteUrl{get;set;}
    public String eventcode{get;set;}
    // Return Site Url for the event
    public void returnCommunityURL()
    {
        //Added escapeHtml4 - BK - 3748
        Network myNetwork = [SELECT Id FROM Network WHERE Name ='Customer Centre' LIMIT 1];
        eventCode= ApexPages.currentPage().getParameters().get('eventCode').escapeHtml4();
        siteUrl= Network.getLoginUrl(myNetwork.id)+'?eventcode='+eventCode;   
    }
    /**** CCEN-347 end ****/
    
    //Prepare customer community user list
    Public static List<User> PrepareCommunityUser(Id profileId,List<Contact> contacts)
    {
        //Initilization of community user list
        List<User> commUserLst=new List<User>();
        for(Contact con: contacts)
        {
            //for the uniqueness of username  
            string aliasName='';
            string userNameSuffix='';
            if(string.isNotBlank(con.FirstName))
            {
                //get first 2 characters from contact frist name
                aliasName = string.valueof(con.FirstName.substring(0,1));
                userNameSuffix= string.valueof(con.FirstName.substring(0,1));
            }
            if(string.isNotBlank(con.LastName))
            {
                //get first 2 characters from contact last name
                aliasName = aliasName+string.valueof(con.LastName.substring(0,1));
                userNameSuffix = userNameSuffix+ string.valueof(con.LastName.substring(0,1));
            }
            if(string.isNotBlank(con.Account.Name)){
                //get first 2 characters from account name
                userNameSuffix = userNameSuffix+ string.valueof(con.Account.Name.substring(0,1));
                //get last 5 characters from contact id
                userNameSuffix = userNameSuffix+ string.valueof(con.Id).substring(10,15);
            }
            User commUsr = new User(contactId=con.Id,
                                    username=con.Email+'.'+userNameSuffix,
                                    firstname=con.FirstName,
                                    lastname=con.LastName,
                                    email=con.Email,
                                    communityNickname = con.LastName + '_'+userNameSuffix,
                                    alias = aliasName,
                                    profileid = profileId,
                                    emailencodingkey='UTF-8',
                                    languagelocalekey='en_US',
                                    localesidkey='en_US',
                                    timezonesidkey='America/Los_Angeles');
            commUserLst.Add(commUsr);
        }
        return commUserLst;
    }
    //Send email notification
    public static void SendEmailNotification(String[] toAddresses,string subject,String body)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses) ;
        mail.setSubject(subject);
        mail.setHtmlBody('<html lang="ja"><body>'+ body+ '</body></html>');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    //Return event setting details
    public static Event_Settings__c getEventDetails(String sEventcode)
    {
        Event_Settings__c eventSetting = new Event_Settings__c ();
        if(string.isNotBlank(sEventcode) && Schema.sObjectType.Event_Settings__c.isAccessible())    
        { 
            //[CCEN-312]: Added 2 fields "Max_Rigging_Height_Decimal__c" & "Max_Stand_Height_Decimal__c" in query            
            //[CCEN-327]: Added 1 field "Stand_Design_limit__c" in query
            //[CCEN-355]: Added 2 field "Cont_MyExh_Detail_Tab_4_Show_Amount__c" & "Cont_MyExh_Detail_Tab_4_Amount_Currency__c" in query
            //[CCEN-289]: Added 1 field "Is_Build_my_own_stand_Visible__c" in query 
            //[BK-3893] : Added 1 field "Event_Edition__r.Part_of_Series__r.Name" in query
            eventSetting = [SELECT Id,Name,About_Show__c,Agent_Own_Exhibitor_Title__c,Subcontractor_Title__c,Stand_Contractor_Title__c,My_Exhibitor_Title__c,ShowHours1__c,Cont_MyExhibitor_Detail_Tab2_Max_Rigging__c,Cont_MyExhibitor_Detail_Tab_2_Max_Stand__c,Max_Stand_Height_Decimal__c,Max_Rigging_Height_Decimal__c,ShowHours2__c,Event_Edition__r.Name,Branding_Color__c,Link_1__c,Is_Stand_Design_Visible__c,Is_Stand_Detail_Visible__c,Is_SubContractors_Visible__c,Is_Amount_Visible__c,Contractor_MyExhibitor_Detail_Tab_1__c,Contractor_MyExhibitor_Detail_Tab_2__c,Contractor_MyExhibitor_Detail_Tab_3__c ,Contractor_MyExhibitor_Detail_Tab_4__c,Cont_MyExhibitor_Detail_Tab_1_Title__c, Cont_MyExhibitor_Detail_Tab_2_Title__c,Cont_MyExhibitor_Detail_Tab_3_Title__c,Cont_MyExhibitor_Detail_Tab_4_Title__c,Cont_MyExhibitor_Detail_Tab_1_Title_Intr__c,Cont_MyExhibitor_Detail_Tab_2_Title_Intr__c,Cont_MyExhibitor_Detail_Tab_4_Title_Intr__c,Cont_MyExh_Detail_Tab_3_Design_Label_1__c,Cont_MyExh_Detail_Tab_3_Design_Label_2__c,Cont_MyExh_Detail_Tab_3_Design_Label_3__c,Cont_MyExh_Detail_Tab_3_Design_Text_1__c,Cont_MyExh_Detail_Tab_3_Design_Text_2__c,Cont_MyExh_Detail_Tab_3_Design_Text_3__c,Is_Cont_MyEx_Detail_Tab_3_Status_Visible__c,Is_Cont_MyEx_Detail_Tab_4_Agree_Visible__c,Is_Cont_MyExh_Tab_4_Signature_Visible__c,Exhibitor_Email_Content1__c,Exhibitor_Email_Content2__c,Event_Edition__r.Matched_Product_Name__c,
                            Link_2__c,Link_3__c,Link_4__c,Link_1_Label__c,Link_2_Label__c,Link_3_Label__c,Link_4_Label__c,Event_Edition__r.start_date__c,Stand_Design_limit__c, Event_Edition__r.Part_of_Series__r.Name, 
                            FaceBook__c,LinkedIn__c,Twitter__c,YouTube__c,Cont_MyExh_Detail_Tab_4_Show_Amount__c,Welcome_Text_Agent_Exhibitor_Details__c,Cont_MyExh_Detail_Tab_4_Amount_Currency__c,Custom_1_Title__c,Event_Edition__r.Payment_Schedule__c,Event_Edition__r.X50_Cutoff_Date__c,Event_Edition__r.Cutoff_Date_1__c,
                            Event_Edition__r.Cutoff_Date_2__c,Event_Edition__r.Booth_Product_Type__c,Is_Build_my_own_stand_Visible__c,Event_Edition__r.Booth_Type__c,Event_Edition__r.Cutoff_Date_3__c,Event_Edition__c,E_Commerce_Title__c,Welcome_Stand_Contractor__c,Welcome_Sub_Contractor__c,Disable_this_information__c,Welcome_Text_My_Exhibitor_Portal__c,Welcome_Text_My_Exhibitor_Booth_Details__c,Button_Text_Color__c,Button_colors__c,Welcome_Text_Agent_Own_Exhibitors__c ,Welcome_Email_Banner__c ,Allotment_By_Booth_Type__c , Allotment_By_Booth_Size__c FROM Event_Settings__c WHERE Event_Edition__r.Event_Code__c =:sEventcode Limit 1];
        }
        return eventSetting;
    }
    public static list<ExpocadBooth__c> getOppBoothDetails(String sEventcode)
    {
        list<ExpocadBooth__c> lstexpoBooths=new list<ExpocadBooth__c>();
        User usr = new User();
        if(Schema.sObjectType.User.isAccessible())
        {
            usr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()]; 
        }
        lstexpoBooths = getOppBoothforAccount(sEventcode,usr.Accountid);
        return lstexpoBooths;
    }
    public static list<ExpocadBooth__c> getOppBoothforAccount(String sEventcode,String accId) 
    {
        list<ExpocadBooth__c> lstexpoBooths=new list<ExpocadBooth__c>();
        set<string> quoteIds = new set<string>();
        
        List<opportunity> opp = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where AccountId=:accId //AND SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c=:Usr.Contactid  
                                 AND EventEdition__r.Event_Code__c =: sEventcode AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate]; 
        
        if(!opp.IsEmpty())
        {
            for(opportunity oppty: opp) {
                if(oppty.SBQQ__PrimaryQuote__c!=null)
                {
                    quoteIds.add(oppty.SBQQ__PrimaryQuote__c);
                }
            }
            //Added condition of Related_Opportunity__c and Opportunity__r.User_Type__r.Name for [CCEN-416]
            if(Schema.sObjectType.ExpocadBooth__c.isAccessible())
            {
                lstexpoBooths = [Select Id,Badge_Limit__c,Booth_Number__c,Booth_Product_Type__c, Area_Number__c, Unit_Type__c,Dimensions__c,Open_Corners__c,Booth_Product_Type_EE__c,Opportunity__c, Opportunity__r.Name, Opportunity__r.createdDate, Display_Name__c,Opportunity__r.account.name, Status__c From  
                                 ExpocadBooth__c where status__c='Rented' and quote__c IN:quoteIds and
                                 (Related_Opportunity__c  = null OR Opportunity__r.User_Type__r.Name != 'Agent') order by Opportunity__r.createdDate]; 
            }
        }
        return lstexpoBooths;
    }
    //Fetch Stand Details
    public static Map<String,Stand_Detail__c> getStandDetail(string sEventcode)
    {
        Map<String,Stand_Detail__c> mapAccStndDetail=new Map<String,Stand_Detail__c>();
        list<Stand_Detail__c> listSDetail =new list<Stand_Detail__c>();
        if(Schema.sObjectType.Stand_Detail__c.isAccessible())
        {
            listSDetail=[SELECT id,Account__c,Riggering_Options__c,Amount__c,IsReceived__c,ExpocadBooth__c,Booth_Detail_Status__c,IsRigging__c,IsDoubleDecker__c,Contractor_Agreement_CA__c, Is_Heavy_Machinery__c FROM Stand_Detail__c WHERE Account__c !=null AND ExpocadBooth__c!=null and ExpocadBooth__r.Event_Code__c=:sEventcode]; 
        }
        if(listSDetail!=null && !listSDetail.IsEmpty())
        {
            for(Stand_Detail__c objSDtail:listSDetail)
            {
                String key=string.valueOf(objSDtail.Account__c)+'_'+string.valueOf(objSDtail.ExpocadBooth__c);
                if(!mapAccStndDetail.containsKey(key))
                {
                    mapAccStndDetail.put(key,objSDtail);
                }
            }
        }
        return mapAccStndDetail;
    }
    
    //Fetch Stand Design
    public static Map<String,Stand_Design__c> getStandDesign(string sEventcode)
    {
        Map<String,Stand_Design__c> mapAccStndDesign=new Map<String,Stand_Design__c>();
        list<Stand_Design__c> listSDsign =new list<Stand_Design__c>();
        if(Schema.sObjectType.Stand_Design__c.isAccessible())
        {
            listSDsign=[SELECT id,Account__c,ExpocadBooth__c,Booth_Design_Submitted_On__c,Submitted_to_Venue_On__c,Contractor_Agreement_CA__c, Booth_Design_Status__c FROM Stand_Design__c WHERE Account__c !=null AND ExpocadBooth__c!=null and ExpocadBooth__r.Event_Code__c=:sEventcode];
        }
        if(listSDsign!=null && !listSDsign.IsEmpty())
        {
            for(Stand_Design__c objSDsign:listSDsign)
            {
                String key=string.valueof(objSDsign.Account__c)+'_'+string.valueof(objSDsign.ExpocadBooth__c);
                if(!mapAccStndDesign.containsKey(key))
                {
                    mapAccStndDesign.put(key,objSDsign);   
                }                    
            }
        }
        return mapAccStndDesign;
    }
    //Method to fetch Opportunity Booth Summary String in Map from key as AccountId // BK-2736
    public static Map<String,String> getOppExpoBoothDetailsMap(Set<Id>contactIds,Set<Id> eventIds)
    {
        Set<Id> accIds = new Set<Id>() ;
        Map<String,String> mapAccountsBooths = New Map<String,String>();
        set<Id> quoteIds = new set<Id>();
        
        for(ContactEventEditionMapping__c ccem : [select id,SFContactID__c,SFContactID__r.accountid,SFEventEditionID__c from ContactEventEditionMapping__c where SFContactID__c in :contactIds AND SFEventEditionID__c in: eventIds ])
        {
            accIds.add(ccem.SFContactID__r.accountid);            
        }
        if(!accIds.IsEmpty())
        {
            for(opportunity opp:[select id,Name,SBQQ__PrimaryQuote__c from opportunity where AccountId in:accIds AND EventEdition__c in:eventIds AND SBQQ__PrimaryQuote__c != null And (StageName='Closed Won' OR StageName='Closed Booked')])
            {
                quoteIds.add(opp.SBQQ__PrimaryQuote__c);
            }
            // Get All Expocad booths
            for(Opportunity_ExpoCAD_Booth_Mapping__c oppBooths:[select id,Opportunity__r.AccountId,Opportunity__r.EventEdition__c,Booth_Number__c,Opportunity__r.Operations_Contact__c from Opportunity_ExpoCAD_Booth_Mapping__c where Status__c='Active' And Expocad_Booth__r.Status__c='Rented' and Quote__c IN:quoteIds And Opportunity__r.Operations_Contact__c != null order by Opportunity__r.createdDate])
            {   string key = string.valueOf(oppBooths.Opportunity__r.AccountId)+'#'+String.valueOf(oppBooths.Opportunity__r.EventEdition__c); // ContactId + EventId
               if(mapAccountsBooths.ContainsKey(key))
               {                   
                   String booths = mapAccountsBooths.get(key) +','+oppBooths.Booth_Number__c; mapAccountsBooths.put(key,booths);
               }else
               {
                   mapAccountsBooths.put(key,oppBooths.Booth_Number__c);
               }
            }
        }
        return mapAccountsBooths;       
    }
    
    public static string getOppBoothDetails(string contactId,string eventId)
    {
        string boothnos='';
        List<ContactEventEditionMapping__c> objCEEM=new List<ContactEventEditionMapping__c>();
        if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible()){
            objCEEM = [select id,SFContactID__r.accountid,SFEventEditionID__c from ContactEventEditionMapping__c where SFContactID__c=:contactId AND SFEventEditionID__c =:eventId order by createddate desc  limit 1 ];   
        }
        if(!objCEEM.IsEmpty())
        {
            string accountId =objCEEM[0].SFContactID__r.accountid;
            set<string> quoteIds = new set<string>();
            objCEEM[0].IsEmailSent__c=true;
            if(string.isNotBlank(accountId) && string.isNotBlank(eventId))
            {
                List<opportunity> opp = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where AccountId=:accountId AND //SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c=:contactId AND
                                         EventEdition__c=:eventId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
                if(!opp.IsEmpty())
                {
                    for(opportunity oppty: opp)
                    {
                        if(oppty.SBQQ__PrimaryQuote__c!=null)
                        {
                            quoteIds.add(oppty.SBQQ__PrimaryQuote__c);
                        }
                    }
                    List<ExpocadBooth__c> expoBooths = [Select Id, Booth_Number__c, Area_Number__c, Unit_Type__c,Dimensions__c,Open_Corners__c,Booth_Product_Type_EE__c,Opportunity__c, Opportunity__r.Name, Opportunity__r.createdDate, Display_Name__c, Status__c From  
                                                        ExpocadBooth__c where status__c='Rented' and quote__c IN:quoteIds order by Opportunity__r.createdDate];
                    if(!expoBooths.IsEmpty())
                    {
                        for(ExpocadBooth__c ecb: expoBooths) {
                            if(string.isNotBlank(ecb.Booth_Number__c))
                            {
                                boothnos += (boothnos==''?ecb.Booth_Number__c:','+ecb.Booth_Number__c);
                            }
                        }
                    }
                }
            }
        }
        return boothnos;
    } 
    
    //Get Community URL
    public static string getCommunityURL()
    {
        Network myNetwork = [SELECT Id FROM Network WHERE Name ='Customer Centre'];
        return Network.getLoginUrl(myNetwork.id);
    }
    
    //Get community user's profile
    public static profile getProfileid()
    {
        string commUsrProfile='';
        //Fetch community user profile from label
        If(Label.Community_User_Profile!= NULL)
        {
            commUsrProfile= Label.Community_User_Profile;
        }             
        else 
        {
            commUsrProfile='Customer Community Login User Custom';
        }            
        //Fetch community user profile
        Profile comprofile =[select id , Name from Profile Where Name =:commUsrProfile];
        return comprofile;
    }
    
    //Send Email to contact
    public static void sendEmailByCode(string eventEditionId, string emailTemCode,contact cont,list<string> lstBoothIds)
    {
        User usr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()]; 
        contact con = new contact();
        if(Schema.sObjectType.contact.isAccessible())
        {
            con = [select Id,email,AccountId from  contact where id =:cont.Id];
        }        
        String exhAccId = usr.Accountid;
        string exhAccName='';
        string exhDisplayname = '';
        
        string booths='';
        string stdDetailAmt = '';
        list<ExpocadBooth__c> lstExpocadBooth= new list<ExpocadBooth__c>();
        list<Stand_Detail__c> lstStandDetail= new list<Stand_Detail__c>();
        if(Schema.sObjectType.ExpocadBooth__c.isAccessible()){
            lstExpocadBooth = [select id,Booth_Number__c,Display_Name__c,Opportunity__r.Operations_Contact__r.accountId,Opportunity__r.Operations_Contact__r.account.Name from ExpocadBooth__c where Id In :lstBoothIds];  
        }
        //Added this for fetching performance Bond Amount from Stand Detail for placeholder variable[CCEN-692]
        if(Schema.sObjectType.Stand_Detail__c.isAccessible())
        {
            lstStandDetail = [select id,Amount__c,ExpocadBooth__c  from Stand_Detail__c where ExpocadBooth__c In :lstExpocadBooth];
        }
        for(ExpocadBooth__c expBooth : lstExpocadBooth)
        {   
            booths+=(booths==''?expBooth.Booth_Number__c:','+expBooth.Booth_Number__c);
            if(String.isNotBlank(expBooth.Opportunity__r.Operations_Contact__r.accountId) || expBooth.Opportunity__r.Operations_Contact__r.accountId != null)
            {
                exhAccId    = expBooth.Opportunity__r.Operations_Contact__r.accountId; // Account Id from ExpocadBooth  for [CCEN-457]
                exhAccName  = expBooth.Opportunity__r.Operations_Contact__r.account.Name;
                exhDisplayname=expBooth.Display_Name__c;
            }
            if(string.isBlank(exhDisplayname))
            {
                exhDisplayname = expBooth.Opportunity__r.Operations_Contact__r.account.Name;
            }
            
        }
        if(lstStandDetail.size()>0)
        {
            stdDetailAmt = lstStandDetail[0].Amount__c;
        }
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c>();
        if(Schema.sObjectType.Event_Edition_Email_Template__c.isAccessible())
        {
            eeeTemplateList = [Select Id,From_Email_Address__r.Org_Wide_From_Email_Addresses__c,Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c =: emailTemCode];
        }    
        String fromAdd;
        //added this functionality regarding ticket [CCEN-358]
        if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
        {
            fromAdd = eeeTemplateList[0].From_Email_Address__r.Org_Wide_From_Email_Addresses__c;      
        } 
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromAdd];  
        
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        string content = '';
        string subject='';
        if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
        {
            content = eeeTemplateList[0].Content__c;
            subject= eeeTemplateList[0].Subject__c ;
            content= content.replaceAll('\\{Designating-Exhibitor.ExpocadBooth__c.Booth_Number__c\\}',booths);
            content= content.replaceAll('\\{Designating-Exhibitor.Account.Name\\}',exhAccName);
            content= content.replaceAll('\\{Account.Name\\}',exhAccName);
            content= content.replaceAll('\\{ExpocadBooth__c.Display_Name__c\\}',exhDisplayname);
            content= content.replaceAll('\\{ExpocadBooth__c.Booth_Number__c\\}',booths);
            if(String.isNotBlank(stdDetailAmt))
            {
                content= content.replaceAll('\\{Stand_Detail__c.Amount__c\\}',stdDetailAmt);
            }
            else{
                content= content.replaceAll('\\{Stand_Detail__c.Amount__c\\}','');
            }
            content= ParsePlaceholders.renderTemplate(content,eeeTemplateList[0].Event_Edition__c, con.Id);
            content= ParsePlaceholders.renderTemplate(content,eeeTemplateList[0].Event_Edition__c, con.AccountId);
            
            subject=subject.replace('{ExpocadBooth__c.Booth_Number__c}',booths);
            subject=subject.replace('{Designating-Exhibitor.ExpocadBooth__c.Booth_Number__c}',booths);
            if(String.isNotBlank(exhAccName)){
            subject=subject.replaceAll('\\{Designating-Exhibitor.Account.Name\\}',exhAccName);
            }
            else{
               subject=subject.replaceAll('\\{Designating-Exhibitor.Account.Name\\}',''); 
            }
            if(String.isNotBlank(stdDetailAmt))
            {
                subject= subject.replaceAll('\\{Stand_Detail__c.Amount__c\\}',stdDetailAmt);
            }
            else{
                subject= subject.replaceAll('\\{Stand_Detail__c.Amount__c\\}','');
            }
            subject = ParsePlaceholders.renderTemplate(subject ,eeeTemplateList[0].Event_Edition__c, con.Id); 
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if(!owea.isEmpty() && owea.size()>0)
        {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        } 
        email.setToAddresses(new String[] {con.email});
        email.setSaveAsActivity(false);
        email.setTargetObjectId(con.Id);
        email.setHtmlBody(content);
        email.setSubject(subject);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email },false);
    }
    
    //Get opportunity contacts
    public Opportunity getAccccountContacts(String sAccountId, string sEventId)
    {
        list<Opportunity> lstOpp=[SELECT Id,Account.Name,Agreement_Contact__c,Agreement_Contact__r.name,Agreement_Contact__r.phone,Agreement_Contact__r.Email,Billing_Contact__c,Billing_Contact__r.name,Billing_Contact__r.phone,Billing_Contact__r.Email,Marketing_Contact__c,Marketing_Contact__r.name,Marketing_Contact__r.Phone,Marketing_Contact__r.Email,Operations_Contact__c,Operations_Contact__r.name,Operations_Contact__r.phone,Operations_Contact__r.Email,Opportunity_Contact__c,Opportunity_Contact__r.name,Opportunity_Contact__r.phone,Opportunity_Contact__r.Email,Safety_Contact__c,Safety_Contact__r.name,Safety_Contact__r.Phone,Safety_Contact__r.Email FROM Opportunity WHERE AccountId=:sAccountId AND EventEdition__c=:sEventId AND(StageName='Closed Booked' OR StageName='Closed Won') ORDER BY createddate ASC limit 1];
        Opportunity objOpp = new Opportunity();
        if(!lstOpp.IsEmpty())
        {
            objOpp=lstOpp[0];
        }
        return objOpp;
    }
    //Fetch Event Edition Mapping 
    //Check the User Type Name [BK-2753]
    public ContactEventEditionMapping__c getContactEventEditionMapping(String contactId, string sEventId)
    {
        List<ContactEventEditionMapping__c> lstMap = new List<ContactEventEditionMapping__c>();
        if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible()){
            lstMap = [select id,User_Type__c,User_Type__r.name,Agent_Email_Body_Content_1__c, Agent_Email_Body_Content_2__c,LastModifieddate  from ContactEventEditionMapping__c where SFContactID__c=:contactId AND SFEventEditionID__c =:sEventId order by createddate desc  limit 1 ];  
        }
        ContactEventEditionMapping__c objMap = new ContactEventEditionMapping__c();
        if(!lstMap.IsEmpty())
        {
            objMap=lstMap[0];
        }
        return objMap;
    }
    public static void sendEmailToExistingUser(set<Id> sConId, set<Id> sEventId) // if parameter is Contact Id And Event Id
    {
        set<Id> sConEEMIds = new set<Id>();
        for(ContactEventEditionMapping__c conEEM:[SELECT Id FROM ContactEventEditionMapping__c WHERE SFContactID__c in:sConId And SFEventEditionID__c in:sEventId])
        {
            sConEEMIds.add(conEEM.Id);
        }
        if(sConEEMIds.size()>0)
        {
            sendEmailToExistingUser(sConEEMIds);
        }
    }
    public static void sendEmailToExistingUser(set<Id> sConEEMIds) // if parameter is ContactEventEditionMapping Id [CCEN-585]
    {
        UtilityMethod_Handler.sendEmailToExistingUser(sConEEMIds);
    }
    
    // Method to update SentEmail Field On ContactEventEditionMapping
    public static void updateContactsSentEmail(set<Id> sConids){
        List<ContactEventEditionMapping__c> updateCEEMApping = new List<ContactEventEditionMapping__c>();
        if(sConIds != null){
            List<ContactEventEditionMapping__c> lstCEEMApping = [SELECT id, SFContactID__c, IsEmailSent__c, Email_Sent__c, User_Type__c, User_Type__r.Name FROM ContactEventEditionMapping__c WHERE SFContactID__c IN :sConIds];
            if(lstCEEMApping != null && !lstCEEMApping.IsEmpty())
            {
                for(ContactEventEditionMapping__c oCEEMapping : lstCEEMApping)
                {
                    oCEEMapping.IsEmailSent__c = true;
                    oCEEMapping.Email_Sent__c = system.now();
                    updateCEEMApping.add(oCEEMapping);
                }
                if(updateCEEMApping != null && !updateCEEMApping.IsEmpty() && Schema.sObjectType.ContactEventEditionMapping__c.isUpdateable())
                {
                    Update updateCEEMApping;
                }
            }
        }       
    }
   public static void sendEmailToExistingUserAccCon(set<Id> sConId, set<Id> sEventId){
        string sEmailBodyOne;
        string sEmailBodyTwo;
        String firstName;
        String companyName;
        String userName;
        string sConMappingId;
        string sHeaderImage;
        string eventName;
        Map<String,String> mapAccountsBooths = New Map<String,String>(); //BK-2736
        String commUrl      =   getCommunityURL();  //BK-2736
        mapAccountsBooths   =   getOppExpoBoothDetailsMap(sConId,sEventId);//BK-2736

        // map<Id,ContactEventEditionMapping__c> mapCEEmapping = new map<Id,ContactEventEditionMapping__c>();
        Map<Id,User> mapConUser = new Map<Id,User>();
        List<ContactEventEditionMapping__c> lstContactMapping = [SELECT Id, SFContactID__r.AccountId,SFContactID__c, SFEventEditionID__c, IsEmailSent__c, User_Type__c, User_Type__r.Name,Agent_Email_Body_Content_1__c, Agent_Email_Body_Content_2__c FROM ContactEventEditionMapping__c WHERE SFContactID__c IN: sConId AND SFEventEditionID__c IN :sEventId ];
        
        list<Opportunity>lstAgentOwnedOpp = new list<Opportunity>();
        set<id> setAgent = new set<id>();
        map<string,string>mapExhAgent = new map<string,string>();
        map<string,ContactEventEditionMapping__c>mapAgentContent = new map<string,ContactEventEditionMapping__c>();
        // Query on Opportunity to get Agents Contact from Agent Owned Exhibitor's  opportunity [CCEN-270]
        lstAgentOwnedOpp =[select id,parent_Opportunity__r.operations_contact__c,Opportunity_Contact__c,Billing_Contact__c,operations_contact__c from opportunity where  (StageName='Closed Won' OR StageName='Closed Booked') AND EventEdition__c In :sEventId and parent_Opportunity__c!=null and (operations_contact__c In :sConId OR Opportunity_Contact__c in : sConId OR Billing_Contact__c in :sConId ) And User_Type__r.name = 'Agent Owned Exhibitor'  order by createdDate desc limit 1000];
        
        for(Opportunity opp :lstAgentOwnedOpp )
        {    setAgent.add(opp.parent_Opportunity__r.operations_contact__c);
            
            if(sConId.contains(opp.operations_contact__c))
            {
                mapExhAgent.put(opp.operations_contact__c, opp.parent_Opportunity__r.operations_contact__c);
            }
            if(sConId.contains(opp.Opportunity_Contact__c))
            {
                mapExhAgent.put(opp.Opportunity_Contact__c, opp.parent_Opportunity__r.operations_contact__c);
            }
            if(sConId.contains(opp.Billing_Contact__c))
            {
                mapExhAgent.put(opp.Billing_Contact__c, opp.parent_Opportunity__r.operations_contact__c);
            }
        }
        
        for(ContactEventEditionMapping__c conEntMp :[SELECT Id,SFContactID__c, SFEventEditionID__c, IsEmailSent__c, User_Type__c, User_Type__r.Name,Agent_Email_Body_Content_1__c, Agent_Email_Body_Content_2__c FROM ContactEventEditionMapping__c WHERE SFContactID__c IN: setAgent AND SFEventEditionID__c IN :sEventId ])
        {    mapAgentContent.put(conEntMp.SFContactID__c,conEntMp);
        }
        
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        //Get existing user of contact with community profile
        List<User> lstUsr=[Select Id,Email,username,firstname,Contact.Type__c,ContactId,Contact.Event_Edition__c,Contact.account.name,Contact.name,Contact.email,IsActive,IsPortalEnabled from User where ContactId IN : sConId and IsPortalEnabled=true And Profile.Name='Customer Community Login User Custom' AND IsActive=true];  
        if(lstUsr != null && !lstUsr.IsEmpty())
        {
            for(User oUser : lstUsr)
            {
                mapConUser.put(oUser.ContactId,oUser);
                System.debug('testContcatUser'+mapConUser);
            }
        }
        
        //Get Email Template Id For Existing User
        EmailTemplate templateId = [Select id,HtmlValue,Subject from EmailTemplate where DeveloperName = 'Exhibitor_Welcome_Email_Existing_User'];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'do_not_reply_gecc@informa.com' Limit 1];
        
        map<Id,Event_Settings__c> mapEventSettings = new map<Id,Event_Settings__c>();
        List<Event_Settings__c> lstEventSetting = [SELECT Id, Event_Edition__c,Event_Edition__r.Name,Event_Edition__r.Event_Code__c, Co_Exhibitor_Email_Content1__c, Co_Exhibitor_Email_Content2__c, Exhibitor_Email_Content1__c, Exhibitor_Email_Content2__c, Agent_Email_Content1__c, Agent_Email_Content2__c, Stand_Contractor_Content1__c, Stand_Contractor_Content2__c, Welcome_Email_Banner__c, Organization_Id_Ops_Admin__c, Send_Welcome_Email__c, Is_Event_Edition_Live__c FROM Event_Settings__c WHERE Event_Edition__c IN :sEventId AND Send_Welcome_Email__c=true AND Is_Event_Edition_Live__c=true];
        
        for(Event_Settings__c evntSetting : lstEventSetting)
        {
            mapEventSettings.put(evntSetting.Event_Edition__c,evntSetting); 
        }
        
        if(lstContactMapping.size()>0){
            for(ContactEventEditionMapping__c conEvntMap : lstContactMapping)
            {
                if(mapConUser.containsKey(conEvntMap.SFContactID__c))
                {
                    system.debug('mymail');
                    companyName     =   mapConUser.get(conEvntMap.SFContactID__c).Contact.account.name;
                    firstName       =   mapConUser.get(conEvntMap.SFContactID__c).firstname;
                    userName        =   mapConUser.get(conEvntMap.SFContactID__c).userName;                    
                }
                if(mapEventSettings.containsKey(conEvntMap.SFEventEditionID__c))
                {
                    eventName           =   mapEventSettings.get(conEvntMap.SFEventEditionID__c).Event_Edition__r.name; //Added regarding CCEN-725
                    String key          =   String.valueOf(conEvntMap.SFContactID__r.AccountId)+'#'+String.valueOf(conEvntMap.SFEventEditionID__c); //BK-2736
                    String boothDetails =   mapAccountsBooths.ContainsKey(key)?mapAccountsBooths.get(key):''; //BK-2736

                    if(mapEventSettings.get(conEvntMap.SFEventEditionID__c).Is_Event_Edition_Live__c == true && mapEventSettings.get(conEvntMap.SFEventEditionID__c).Send_Welcome_Email__c == true)
                    {
                        //BK-8006 Start
                        String imageURL = '';
                        if(System.Label.RTE_Image_Url !=null){
                            imageURL=System.Label.RTE_Image_Url;
                        } 
                        if(conEvntMap.User_Type__r.Name =='Exhibitor'){
                            system.debug('Exhibitormail');
                            sEmailBodyTwo = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Exhibitor_Email_Content2__c;
                            if(sEmailBodyTwo != null && sEmailBodyTwo !=''){
                                sEmailBodyTwo = sEmailBodyTwo.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                            sEmailBodyOne = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Exhibitor_Email_Content1__c;
                            if(sEmailBodyOne !=null && sEmailBodyOne != ''){
                                sEmailBodyOne = sEmailBodyOne.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                        }
                        else if(conEvntMap.User_Type__r.Name =='Stand Contractor'){
                            sEmailBodyTwo = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Stand_Contractor_Content2__c;
                            if(sEmailBodyTwo != null && sEmailBodyTwo !=''){
                                sEmailBodyTwo = sEmailBodyTwo.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                            sEmailBodyOne = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Stand_Contractor_Content1__c;
                            if(sEmailBodyOne !=null && sEmailBodyOne != ''){
                                sEmailBodyOne = sEmailBodyOne.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                        }
                        else if(conEvntMap.User_Type__r.Name =='Co-Exhibitor'){
                            sEmailBodyTwo = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Co_Exhibitor_Email_Content2__c;
                            if(sEmailBodyTwo != null && sEmailBodyTwo !=''){
                                sEmailBodyTwo = sEmailBodyTwo.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                            sEmailBodyOne = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Co_Exhibitor_Email_Content1__c;
                            if(sEmailBodyOne !=null && sEmailBodyOne != ''){
                                sEmailBodyOne = sEmailBodyOne.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                        }
                        else if(conEvntMap.User_Type__r.Name =='Agent'){
                            sEmailBodyTwo = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Agent_Email_Content2__c;
                            if(sEmailBodyTwo != null && sEmailBodyTwo !=''){
                                sEmailBodyTwo = sEmailBodyTwo.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                            sEmailBodyOne = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Agent_Email_Content1__c;
                            if(sEmailBodyOne !=null && sEmailBodyOne != ''){
                                sEmailBodyOne = sEmailBodyOne.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                        }
                        //BK-8006 end
                        else if(conEvntMap.User_Type__r.Name =='Agent Owned Exhibitor'){ // welcome email to Agent Owned Exhibitor from there Agents Content [CCEN-270]
                            if(!mapExhAgent.isEmpty() && mapExhAgent.containsKey(conEvntMap.SFContactID__c))
                            {
                                if(!mapAgentContent.isEmpty() && mapAgentContent.containsKey(mapExhAgent.get(conEvntMap.SFContactID__c)))
                                {
                                    sEmailBodyTwo = mapAgentContent.get(mapExhAgent.get(conEvntMap.SFContactID__c)).Agent_Email_Body_Content_2__c;
                                    sEmailBodyOne = mapAgentContent.get(mapExhAgent.get(conEvntMap.SFContactID__c)).Agent_Email_Body_Content_1__c; 
                                }
                            }                            
                        }
                        if(mapEventSettings.get(conEvntMap.SFEventEditionID__c).Welcome_Email_Banner__c != null && mapEventSettings.get(conEvntMap.SFEventEditionID__c).Organization_Id_Ops_Admin__c != null){
                            sHeaderImage =System.URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+mapEventSettings.get(conEvntMap.SFEventEditionID__c).Welcome_Email_Banner__c+'&oid='+mapEventSettings.get(conEvntMap.SFEventEditionID__c).Organization_Id_Ops_Admin__c;
                        }
                        //Send Email with replace values
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        // String boothDetails=getOppExpoBoothDetails(conEvntMap.SFContactID__c,conEvntMap.SFEventEditionID__c);
                        // String commUrl=getCommunityURL();
                        String htmlValue=templateId.HtmlValue;
                        if(!String.isBlank(htmlValue)) 
                        {
                            If(htmlValue.Contains('#company_name#') ){
                                if(!String.isBlank(companyName)){
                                    htmlValue=htmlValue.replace('{#company_name#}',companyName);
                                }
                                else{
                                    htmlValue=htmlValue.replace('{#company_name#}','');
                                }
                            }
                            If(htmlValue.Contains('#booth_details#') ){
                                if(!String.isBlank(boothDetails)){
                                    htmlValue=htmlValue.replace('{#booth_details#}',boothDetails);
                                }
                                else{
                                    htmlValue=htmlValue.replace('{#booth_details#}','');
                                }
                            }
                            If(htmlValue.Contains('#user_name#') ){
                                if(!String.isBlank(userName)){
                                    htmlValue=htmlValue.replace('{#user_name#}',userName);
                                }
                                else{
                                    htmlValue=htmlValue.replace('{#user_name#}','');
                                }
                            }
                            If(htmlValue.Contains('#comm_url#') ){
                                if(!String.isBlank(commUrl)){
                                    htmlValue=htmlValue.replace('{#comm_url#}',commUrl+'?eventcode='+mapEventSettings.get(conEvntMap.SFEventEditionID__c).Event_Edition__r.Event_Code__c);
                                }
                                else{
                                    htmlValue=htmlValue.replace('{#comm_url#}','');
                                }
                            }
                            If(htmlValue.Contains('#Email_Body1#') ){
                                if(!String.isBlank(sEmailBodyOne)){
                                    htmlValue=htmlValue.replace('{#Email_Body1#}',sEmailBodyOne);
                                }
                                else{
                                    htmlValue=htmlValue.replace('{#Email_Body1#}','');
                                }
                            }
                            If(htmlValue.Contains('#Email_Body2#') ){
                                if(!String.isBlank(sEmailBodyTwo)){
                                    htmlValue=htmlValue.replace('{#Email_Body2#}',sEmailBodyTwo);
                                }
                                else{
                                    htmlValue=htmlValue.replace('{#Email_Body2#}','');
                                }
                            }
                            If(htmlValue.Contains('#header_image#') ){
                                if(!String.isBlank(sHeaderImage)){
                                    htmlValue=htmlValue.replace('{#header_image#}',sHeaderImage);
                                }
                                else{
                                    htmlValue=htmlValue.replace('{#header_image#}','');
                                }
                            }
                        }
                        if (owea!=null && !owea.IsEmpty()){
                            mail.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        //BK-12701
                        String emailSubject ='';
                        if(System.Label.Welcome_Email_Subject != null){
                            emailSubject = System.Label.Welcome_Email_Subject;
                        } 
                        //templateId.Subject=companyName + ' - Welcome to Customer Center for '  + eventName;
                        templateId.Subject=companyName +' '+ emailSubject +' '+ eventName;
                        mail.setSubject(templateId.Subject);
                        mail.setHtmlBody(htmlValue);
                        mail.setSaveAsActivity(false);
                        mail.setTargetObjectId(mapConUser.get(conEvntMap.SFContactID__c).id);
                        mail.setTemplateId(templateId.id);
                        mails.add(mail);
                        
                    }
                }
            }
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
    }
    
    public static List<String> getPicklistValues(String objApi,String fieldName) 
    { 
        List<String> lstPickvals=new List<String>();   
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objApi);
        Sobject objectName = targetType.newSObject();
        Schema.sObjectType sobjectType = objectName.getSObjectType();
        Schema.DescribeSObjectResult sObjectDescribe = sobjectType.getDescribe(); 
        Map<String, Schema.SObjectField> fieldMap = sObjectDescribe.fields.getMap();       
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getPickListValues(); 
        for (Schema.PicklistEntry a : picklistValues) 
        { 
            lstPickvals.add(a.getLabel() +'__$__'+ a.getValue());
        }
        return lstPickvals; 
    }
    //Method for sending Email to Agent own Exhibitor
    public static void sendEmailToAgentUser(set<Id> sConId, string sEventId, string sAgentId)
    {
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        string sEmailBodyOne;
        string sEmailBodyTwo;
        String firstName;
        String companyName;
        String userName;
        string sConMappingId;
        string sHeaderImage;
        string eventName;
        set<Id> sEventIds = new Set<Id>();
        sEventIds.add(sEventId);
        Map<String,String> mapAccountsBooths = New Map<String,String>(); //BK-2736
        String commUrl  = getCommunityURL(); // BK-2736
        mapAccountsBooths   =  getOppExpoBoothDetailsMap(sConId,sEventIds);

        List<ContactEventEditionMapping__c> updateMapping = new List<ContactEventEditionMapping__c>();
        List<ContactEventEditionMapping__c> newMapping = new List<ContactEventEditionMapping__c>();
        ContactEventEditionMapping__c oContactMapping = [SELECT Id, SFContactID__c, Email_Sent__c, SFEventEditionID__c,SFEventEditionID__r.Name, IsEmailSent__c, User_Type__c, User_Type__r.Name,Agent_Email_Body_Content_1__c, Agent_Email_Body_Content_2__c FROM ContactEventEditionMapping__c WHERE SFContactID__c =: sAgentId and SFEventEditionID__c=:sEventId LIMIT 1];
        if(oContactMapping != null)
        {
            sEmailBodyOne   = oContactMapping.Agent_Email_Body_Content_1__c;
            sEmailBodyTwo   = oContactMapping.Agent_Email_Body_Content_2__c;
            eventName       = oContactMapping.SFEventEditionID__r.Name; //Added regarding CCEN-725
        }
        
        //Get Email Template Id For Existing User
        EmailTemplate templateId = [Select id,HtmlValue,Subject from EmailTemplate where DeveloperName = 'Exhibitor_Welcome_Email_Existing_User'];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'do_not_reply_gecc@informa.com'];
        
        Event_Settings__c oEventSetting = [SELECT Id, Event_Edition__c,Event_Edition__r.Name, Event_Edition__r.Event_Code__c,Welcome_Email_Banner__c, Organization_Id_Ops_Admin__c, Send_Welcome_Email__c, Is_Event_Edition_Live__c FROM Event_Settings__c WHERE Event_Edition__c =:sEventId LIMIT 1];
        if(oEventSetting.Is_Event_Edition_Live__c == true && oEventSetting.Send_Welcome_Email__c == true){
            if(oEventSetting.Welcome_Email_Banner__c != null && oEventSetting.Organization_Id_Ops_Admin__c != null){
                sHeaderImage =System.URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+oEventSetting.Welcome_Email_Banner__c+'&oid='+oEventSetting.Organization_Id_Ops_Admin__c;
            }
            //Get existing user of contact with community profile
            List<User> lstUsr   =   new List<User>([Select Id,Email,username,firstname,Contact.Type__c,ContactId,Contact.AccountID,Contact.Event_Edition__c,Contact.account.name,Contact.name,Contact.email,IsActive,IsPortalEnabled from User where ContactId IN : sConId and IsPortalEnabled=true And Profile.Name='Customer Community Login User Custom' AND IsActive=true]);  
            if(lstUsr != null && !lstUsr.IsEmpty())
            {
                for (User oUs:lstUsr)
                {                    
                    companyName         =   oUs.Contact.account.name;
                    firstName           =   oUs.firstname;
                    userName            =   oUs.userName;
                    String key          =   String.valueOf(oUs.Contact.AccountID)+'#'+String.valueOf(sEventId); //BK-2736
                    String boothDetails =   mapAccountsBooths.ContainsKey(key)?mapAccountsBooths.get(key):'';

                    //Send Email with replace values
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    // String boothDetails=getOppExpoBoothDetails(oUs.ContactId,sEventId);
                    // String commUrl=getCommunityURL();
                    String htmlValue=templateId.HtmlValue;
                    if(!String.isBlank(htmlValue))
                    {
                        If(htmlValue.Contains('#company_name#') ){
                            if(!String.isBlank(companyName)){
                                htmlValue=htmlValue.replace('{#company_name#}',companyName);
                            }
                            else{
                                htmlValue=htmlValue.replace('{#company_name#}','');
                            }
                        }
                        If(htmlValue.Contains('#booth_details#') ){
                            if(!String.isBlank(boothDetails)){
                                htmlValue=htmlValue.replace('{#booth_details#}',boothDetails);
                            }
                            else{
                                htmlValue=htmlValue.replace('{#booth_details#}','');
                            }
                        }
                        If(htmlValue.Contains('#user_name#') ){
                            if(!String.isBlank(userName)){
                                htmlValue=htmlValue.replace('{#user_name#}',userName); 
                            }
                            else{
                                htmlValue=htmlValue.replace('{#user_name#}','');
                            }
                        }
                        If(htmlValue.Contains('#comm_url#') ){
                            if(!String.isBlank(commUrl)){
                                htmlValue=htmlValue.replace('{#comm_url#}',commUrl+'?eventcode='+oEventSetting.Event_Edition__r.Event_Code__c);
                            }
                            else{
                                htmlValue=htmlValue.replace('{#comm_url#}','');   
                            }
                        }
                        If(htmlValue.Contains('#Email_Body1#') ){
                            if(!String.isBlank(sEmailBodyOne)){
                                htmlValue=htmlValue.replace('{#Email_Body1#}',sEmailBodyOne);
                            }
                            else{
                                htmlValue=htmlValue.replace('{#Email_Body1#}','');
                            }
                        }
                        If(htmlValue.Contains('#Email_Body2#') ){
                            if(!String.isBlank(sEmailBodyTwo)){
                                htmlValue=htmlValue.replace('{#Email_Body2#}',sEmailBodyTwo);
                            }
                            else{
                                htmlValue=htmlValue.replace('{#Email_Body2#}','');
                            }
                        }
                        If(htmlValue.Contains('#header_image#') ){
                            if(!String.isBlank(sHeaderImage)){
                                htmlValue=htmlValue.replace('{#header_image#}',sHeaderImage);
                            }
                            else{
                                htmlValue=htmlValue.replace('{#header_image#}','');
                            }
                        }
                    }
                    if (owea!=null && !owea.IsEmpty()){
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    //BK-12701
                    String emailSubject ='';
                    if(System.Label.Welcome_Email_Subject != null){
                        emailSubject = System.Label.Welcome_Email_Subject;
                    } 
                    //templateId.Subject=companyName + ' - Welcome to Customer Center for ' +eventName;
                    templateId.Subject=companyName +' '+ emailSubject +' '+ eventName;
                    mail.setSubject(templateId.Subject);
                    mail.setHtmlBody(htmlValue);
                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(oUs.id);
                    mail.setTemplateId(templateId.id);
                    mails.add(mail);
                }
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                if(sConId != null && !sConId.IsEmpty()){
                    List<ContactEventEditionMapping__c> lstContactEvent = [SELECT Id, Email_Sent__c, User_Type__c, IsEmailSent__c,SFContactID__c FROM ContactEventEditionMapping__c WHERE SFContactID__c IN :sConId];
                    if(lstContactEvent != null && !lstContactEvent.IsEmpty()){
                        for(ContactEventEditionMapping__c oEventMapping : lstContactEvent){
                            oEventMapping.Email_Sent__c=system.now();
                            oEventMapping.IsEmailSent__c=true;
                            updateMapping.add(oEventMapping);
                            sConId.remove(oEventMapping.SFContactID__c);
                        }
                    }
                    if(updateMapping != null && !updateMapping.IsEmpty())
                    {
                        update updateMapping;
                    }
                    List<User_Type__c> lstAOE = new List<User_Type__c>();
                    if(Schema.sObjectType.User_Type__c.isAccessible())
                    {
                        lstAOE = [SELECT id,Name FROM User_Type__c WHERE Name = 'Agent Owned Exhibitor' LIMIT 1]; 
                    }                     
                    if(lstAOE!=null && !lstAOE.IsEmpty())
                    {
                        for(string  oCon : sConId) {
                            ContactEventEditionMapping__c oNewMapping = new ContactEventEditionMapping__c();
                            oNewMapping.SFContactID__c = oCon;
                            oNewMapping.SFEventEditionID__c = sEventId;
                            oNewMapping.Email_Sent__c = system.now();
                            oNewMapping.IsEmailSent__c = true;
                            oNewMapping.User_Type__c = lstAOE[0].Id;
                            newMapping.add(oNewMapping);
                        }
                    }
                    if(newMapping != null && !newMapping.IsEmpty() && Schema.sObjectType.ContactEventEditionMapping__c.isCreateable())
                    {
                        insert newMapping;
                    }
                        
                }
            }
        }
    }
    //Method to get record count of query.
    public static Integer getTotalRows(String sCountQuery)
    {
        return database.countQuery('select count() '+sCountQuery);
    }
    //for calculating L+w/2 of dimension // CCEN-600
    Public static decimal getTotalBadgesByDimension(String dimension)
    {
        decimal totalBadges = 0;
        //String  dimensionRegex ='([0-9]+)([\\.]?)([0-9]*)([a-zA-z]?)([a-zA-z]) x ([0-9]+)([\\.]?)([0-9]*)([a-zA-z]?)([a-zA-z])';
        //dimension.contains(dimensionRegex)
        if(string.isNotBlank(dimension) && !dimension.containsIgnoreCase('Custom'))
        {
            String regex = '[a-wA-W]{1,}|\\-';
            String recordNumber = dimension.replaceAll(regex, '');
            list<string> str  = recordNumber.split('x');
            totalBadges =  decimal.valueOf(str[0].trim()) + decimal.valueOf(str[1].trim());
            totalBadges = (totalBadges/2).round(RoundingMode.UP);
            
        }       
        return totalBadges;
    }

    //Method to get list<Sobject> of query.
    public static list<Sobject> getDynamicSobjectList(String sQuery)
    {
        return Database.query(sQuery); 
    }
    
    //[CCEN-695]
    //Encrypt string
    public static String Encrypt_aes256(string strValue)
    {
        //32 byte string. since characters used are ascii, each char is 1 byte.
        Blob key = Blob.valueOf('12345678901234567890123456789012');
        Blob cipherText = Crypto.encryptWithManagedIV('AES256', key, Blob.valueOf(strValue));
        String encodedCipherText = EncodingUtil.base64Encode(cipherText).replace ('+','_'); 
        return encodedCipherText;
    }
    
    //[CCEN-695]
    //Decrypt string
    public static String Decrypt_aes256(string encodedCipherText)
    {
        //32 byte string. since characters used are ascii, each char is 1 byte.
        Blob key = Blob.valueOf('12345678901234567890123456789012');
        encodedCipherText=encodedCipherText.replace ('_','+');
        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(encodedCipherText);
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256', key, encodedEncryptedBlob);
        String decryptedClearText = decryptedBlob.toString();
        return decryptedClearText;
    }
}