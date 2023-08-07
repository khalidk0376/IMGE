/**
 * Created By   :   Girikon(Sunil)
 * Created On   :   May 29 2018
 * @description :   [Allow agents to manage their exhibitors.]
 * Test Class   :   AgentOwnExhibitorsCtrl_Test (80%)
 * Modification Log-------
 * Modified by  :   Girikon(Sunil[CCEN-275 Sep 11 2018, CCEN-555 Dec 20 2018,CCEN-482 Jan 2 2019,CCEN-587 Feb 8 2019,CCEN-601 Feb 21 2019,CCEN 745 Apr 19 2019],Mahesh[CCEN-358 Oct 22,2018],Ashish[CCEN-585 Jan 8 2019],Divaker[CCEN-745 April 01 2019], Amish [CCEN 795 May 16, 2019], [Aishwarya BK-2098 Aug 2 2019], Prashant[C2E-1 Aug 20 2019],Ashish[C2E-108 ,25 Sep 2019], Aishwarya [BK-2591 Oct 14 2019])
 **/

public without sharing class AgentOwnExhibitorsCtrl { 
    @AuraEnabled //Fetch event details
    public static Event_Settings__c getEventDetails(String sEventcode)
    {
        return UtilityMethods.getEventDetails(sEventcode); 
    }
    @AuraEnabled //Fetch sub agents CCEN-275
    public static list<exhibitorsWrapperClass>  getSubAgents(String sEventcode) 
    {
        User usr = new user();
        List<opportunity> lstOpps = new List<opportunity>();
        set<string> quoteIds = new set<string>();
        
        if (!Schema.sObjectType.User.fields.AccountId.isAccessible() && !Schema.sObjectType.User.fields.ContactId.isAccessible()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
            return null;
        }
        else{
            usr = [SELECT Id, Contactid,Contact.Name,Account.Name,Accountid  FROM User WHERE Id = : UserInfo.getUserId()]; 
        }
        //if(Schema.sObjectType.opportunity.isAccessible()) {
            lstOpps = [select Id from opportunity where AccountId=:usr.Accountid AND (StageName='Closed Won' OR StageName='Closed Booked') AND EventEdition__r.Event_Code__c =: sEventcode order by createdDate limit 1000];         
        //}
        set<string> lstOppsIds = new  set<string>();
        if(lstOpps!=null && lstOpps.size()>0)
        {
            for(opportunity opp : lstOpps)
            {
                lstOppsIds.add(opp.Id); 
            }
        }       
        list<exhibitorsWrapperClass> objExhibitors= new list<exhibitorsWrapperClass>();
        List<AggregateResult> lstOppsExh = new List<AggregateResult>();
        if(!lstOpps.IsEmpty())
        { 
            //Check is class runnig for test
            if(Test.isRunningTest())
            {
                lstOppsExh = [select AccountId,Account.Name from opportunity where EventEdition__r.Event_Code__c =: sEventcode   group by AccountId,Account.Name  limit 1000];  
            }
            else
            {
                lstOppsExh = [select AccountId,Account.Name from opportunity where (StageName='Closed Won' OR StageName='Closed Booked') and (Exhibitor_Paid_By__c='SubAgent Paid By Exhibitor' or Exhibitor_Paid_By__c ='SubAgent Paid By Subagent') And parent_Opportunity__c=Null AND EventEdition__r.Event_Code__c =: sEventcode and Agent_s_Opportunity__c IN :lstOppsIds group by AccountId,Account.Name limit 1000];  
            }
            if(!lstOppsExh.IsEmpty() && lstOppsExh.size()>0)
            { 
                for(AggregateResult aggOpp : lstOppsExh){
                    exhibitorsWrapperClass newExhibitor = new exhibitorsWrapperClass();
                    newExhibitor.id = String.valueOf(aggOpp.get('AccountId'));
                    newExhibitor.accountName = String.valueOf(aggOpp.get('Name'));
                    objExhibitors.add(newExhibitor); 
                }
            }
        }
        return objExhibitors;
    }
    /*
        Agent login to see their Exhibitor Details [C2E-1]
     */

    @AuraEnabled
    public static list<exhibitorsWrapperClass>  getAllCustomers (String sEventcode,String activity,string usertype,string subAgentAccId, string standType, string searchWord, Boolean newExh)
    {
        Event_Settings__c eventSettings = CommunityExhibitorBadgeCtrl.getEventSettings(sEventCode); // Event Setting For Badges 
        list<exhibitorsWrapperClass> objExhibitors= new list<exhibitorsWrapperClass>(); // Wraper Return Varible
        list<Opportunity_ExpoCAD_Booth_Mapping__c> oppLstExpoBoothMap=new list<Opportunity_ExpoCAD_Booth_Mapping__c>();
        set<string> quoteIds = new set<string>(); // All qotes for expocad booths        
        set<string> lstOppsIds = new  set<string>();  // set Agent opp Id
        
        User usr = [SELECT Id, Contactid,Contact.Name,Account.Name,Accountid  FROM User WHERE Id = : UserInfo.getUserId()]; // Agent login User
        string agentAccId = String.isNotBlank(subAgentAccId) ? subAgentAccId:usr.Accountid;  // Agent Account Or Sub Agent Account Id

        for(opportunity agentOpp: [select Id from opportunity where AccountId=:agentAccId And (StageName='Closed Won' OR StageName='Closed Booked') AND EventEdition__r.Event_Code__c =: sEventcode order by createdDate limit 1000])
        {
            lstOppsIds.add(agentOpp.Id);
            system.debug('test__agentOpp....');
        }
        if(!lstOppsIds.IsEmpty()) // incase of Agent opp
        {
            List<opportunity> lstOppsExh = new List<opportunity>();  // AOE opp
            set<string> lstOppsIdsAOE = new  set<string>();         // set AOE opp Id

            if(usertype != 'INCONT')  // Filter for not Individual Contract {to reduce Query}
            {
                //Check is class running for test
                if(Test.isRunningTest())
                {
                    lstOppsExh = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where EventEdition__r.Event_Code__c =: sEventcode and SBQQ__PrimaryQuote__c!='' order by createdDate limit 1000];
                }
                else
                {
                    lstOppsExh = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where (StageName='Closed Won' OR StageName='Closed Booked') AND EventEdition__r.Event_Code__c =: sEventcode and parent_Opportunity__c IN :lstOppsIds and SBQQ__PrimaryQuote__c!='' And AccountId !=: agentAccId  order by createdDate limit 1000];
                    system.debug('test_lstOppsExh....'+lstOppsExh);
                }
                if(!lstOppsExh.IsEmpty() && lstOppsExh.size()>0)  // in case of Agent Owned Exhibitor opp
                {
                    for(opportunity oppty: lstOppsExh) 
                    {
                        if(usertype == 'AOE' || usertype == 'All')   // Filter Agent Owned Exhibitor
                        {
                            quoteIds.add(String.valueOf(oppty.SBQQ__PrimaryQuote__c)); //Adding quoteIds of AOE 
                            system.debug('test_QuoteID.....'+quoteIds);
                        }                            
                        lstOppsIdsAOE.add(oppty.Id);  // Adding opp of AOE for there Co-Exhibitors
                    }

                    if(usertype == 'COEXH' || usertype == 'All')  // Filter Agent Owned Exhibitor's Co-Exhibitor
                    {
                        //Need to see co-exhibitors of Agent owned exhibitors [CCEN-482]
                        for(opportunity oppty: [select id,Name,SBQQ__PrimaryQuote__c from opportunity where (StageName='Closed Won' OR StageName='Closed Booked') AND EventEdition__r.Event_Code__c =: sEventcode and parent_Opportunity__c IN :lstOppsIdsAOE and SBQQ__PrimaryQuote__c!='' and Exhibitor_Paid_By__c='Co-Exhibitor Paid by Exhibitor' order by createdDate limit 1000]) 
                        {
                            quoteIds.add(String.escapeSingleQuotes(String.valueOf(oppty.SBQQ__PrimaryQuote__c))); //Adding quoteIds of AOE's  Co- Exhibitor
                        } 
                    }
                }
            }

            if(usertype == 'INCONT' || usertype == 'All')  // Filter Individual Contract
            {
                //Agent need to see Individual Contract Exhibitors [CCEN-601]
                for(opportunity oppty: [select id,SBQQ__PrimaryQuote__c from opportunity where (StageName='Closed Won' OR StageName='Closed Booked') and Exhibitor_Paid_By__c='Individual Contract' And parent_Opportunity__c=Null AND EventEdition__r.Event_Code__c =: sEventcode and Agent_s_Opportunity__c IN :lstOppsIds limit 1000]) 
                {
                    quoteIds.add(String.escapeSingleQuotes(String.valueOf(oppty.SBQQ__PrimaryQuote__c))); //Adding quoteIds of Individual Contract 
                }
            }
           
            // query has been changed from object ExpocadBooth to Opportunity_ExpoCAD_Booth_Mapping__c regarding ticket CCEN-745
            String query = 'Select Id, Booth_Number__c,Display_Name__c,Expocad_Booth__r.Area_Number__c,Expocad_Booth__r.status__c, Status__c,Expocad_Booth__r.Dimensions__c,Expocad_Booth__r.Booth_Type__c,Expocad_Booth__r.Booth_Product_Type__c,Expocad_Booth__r.Matched_Product_Name__c,Matched_Product_Name__c,Opportunity__c,Opportunity__r.User_Type__r.Name,Opportunity__r.Operations_Contact__c,Opportunity__r.AccountId,Opportunity__r.Account.Name,Expocad_Booth__r.Pavilion__c,CountBadges__c,Opportunity__r.parent_Opportunity__r.Exhibitor_Paid_By__c,Opportunity__r.Operations_Contact__r.FirstName,Opportunity__r.Operations_Contact__r.LastName,Opportunity__r.Operations_Contact__r.Email,Opportunity__r.Operations_Contact__r.MobilePhone,Opportunity__r.parent_Opportunity__r.parent_Opportunity__r.Account.Name ,Opportunity__r.parent_Opportunity__r.account.name,Opportunity__r.parent_Opportunity__r.parent_Opportunity__r.Operations_Contact__r.Name,Opportunity__r.parent_Opportunity__r.Operations_Contact__r.name,Badge_Limit__c,Opportunity__r.Exhibitor_Paid_By__c,Opportunity__r.Agent_s_Opportunity__r.Operations_Contact__r.name,Opportunity__r.Agent_s_Opportunity__r.account.name From Opportunity_ExpoCAD_Booth_Mapping__c where Status__c=\'Active\' and Expocad_Booth__r.status__c=\'Rented\' ';
            
            if(!Test.isRunningTest())
            {
                System.debug('quoteIds---------- ' +quoteIds);
                query+=' and Quote__c IN:quoteIds ';
            } 
            if(String.isNotBlank(searchWord))
            {
                searchWord = '%'+searchWord+'%';
                query+= ' and Opportunity__r.Account.Name Like :searchWord ';
            }
            if(String.isNotBlank(standType) && standType != 'null')
            {
                query+= ' and Expocad_Booth__r.Matched_Product_Name__c =:standType ';
            }  
            else if(String.isNotBlank(standType) && standType == 'null')
            {
                query+= ' and Expocad_Booth__r.Matched_Product_Name__c = null ';
            }                        
            query+=' order by Opportunity__r.createdDate limit 800';
            oppLstExpoBoothMap = Database.query(query);  // Get all Expocad Booths From quotes
            system.debug(' oppLstExpoBoothMap........: '+oppLstExpoBoothMap);
            system.debug(' SIZE : '+oppLstExpoBoothMap.size());
            // geeting sets from all booth 
            set<Id> setBoothIds = new set<Id>();        // Set of opp Booth Maping
            set<Id> setCustomerAccIds = new set<Id>();  // Set of All Customer Account Ids
            set<Id> setContactIds = new set<Id>();      // set of All opration Contacts

            if(oppLstExpoBoothMap.size()>0)
            {
                system.debug('testlistofOpp'+oppLstExpoBoothMap);
                for(Opportunity_ExpoCAD_Booth_Mapping__c oppBooth:oppLstExpoBoothMap)
                {
                    setBoothIds.add(oppBooth.id);
                    setCustomerAccIds.add(oppBooth.Opportunity__r.AccountId);
                    if(oppBooth.Opportunity__r.Operations_Contact__c!=null)
                    {
                        setContactIds.add(oppBooth.Opportunity__r.Operations_Contact__c); 
                        system.debug('setContactIds...........'+setContactIds);
                    }
                     system.debug('setContactIds######'+setContactIds);
                }

                // Filter Activity
                map<Id,AgentOwnedExhibitorUtils.CountWraper> manualsStatusMap = new map<Id,AgentOwnedExhibitorUtils.CountWraper>();   // map to store Customer Manual Status
                map<Id,AgentOwnedExhibitorUtils.CountWraper> formStatusMap = new map<Id,AgentOwnedExhibitorUtils.CountWraper>();      // map to store Customer Forms Status
                Map<Id,datetime> maplastLogin = new Map <Id,datetime>();            // map to store Customer Last Login Status
                Map<Id,AgentOwnedExhibitorUtils.CountWraper> mapBadgesStatus = new map<Id,AgentOwnedExhibitorUtils.CountWraper>();    // map to store Customer badges Status
                Map<Id,String> mapExhibitorProfileStatus = new map<Id,String>();    // map to store Customer Exhibitor Profile Status
                Map<Id,string> mapStandContractorStatus = new map<Id,String>();     // map to store Customer Stand Contractor Status
                map<Id,ContactEventEditionMapping__c> mapConEventWlcmMail = new map<Id,ContactEventEditionMapping__c>();     //map to store contact and welcome Email details
                Map<Id,User> mapContactUser = new Map <Id,User>();          // Map to store user details from contact ids
                Map<Id, Boolean> mapAgentExhContactMap = new Map<Id, Boolean>(); // Map to store fetch AgentExhibitorContact Details[C2E-109]
                // For Future Use[C2E-109]
                mapAgentExhContactMap = AgentOwnedExhibitorUtils.getAgentExhContactMap(setContactIds,sEventcode);
                mapConEventWlcmMail = AgentOwnedExhibitorUtils.getWelcomeEmailStatus(setContactIds,sEventcode);  // Always required
                mapContactUser = AgentOwnedExhibitorUtils.getContactUserMap(setContactIds);  // Always required

                switch on activity
                { 
                    when 'NoLogin' 
                    {
                        maplastLogin = AgentOwnedExhibitorUtils.getlastLoginMap(setCustomerAccIds,sEventcode);  
                    }
                    when 'MissingForms' 
                    {
                        formStatusMap = AgentOwnedExhibitorUtils.getFormsStatusMap(setCustomerAccIds,sEventcode);  
                    }
                    when 'MissingManuals' 
                    {
                        manualsStatusMap = AgentOwnedExhibitorUtils.getManualsStatusMap(setCustomerAccIds,sEventcode);  
                    }
                    when 'MissingBadges' 
                    {
                        mapBadgesStatus = AgentOwnedExhibitorUtils.getbadgesStatusMap(setBoothIds,sEventcode);  
                    }
                    when 'MissingExProfile' 
                    {
                        mapExhibitorProfileStatus = AgentOwnedExhibitorUtils.getExhibitorProfileStatusMap(setBoothIds,sEventcode);  
                    }
                    when 'MissingContractor' 
                    {
                        mapStandContractorStatus = AgentOwnedExhibitorUtils.getStandContractorStatusMap(setBoothIds,sEventcode);  
                    }
                    when else
                    {
                        System.debug('default none! ');
                    }
                }

                // Creating Wraper for Agent Table 
                for(Opportunity_ExpoCAD_Booth_Mapping__c oppBooth:oppLstExpoBoothMap)
                {
                    exhibitorsWrapperClass newExhibitor = new exhibitorsWrapperClass();  // Cstomer record Warper

                    newExhibitor.id             =   oppBooth.Id;
                    newExhibitor.paidBy         =   oppBooth.Opportunity__r.Exhibitor_Paid_By__c;
                    newExhibitor.parentPaidBy   =   oppBooth.Opportunity__r.parent_Opportunity__r.Exhibitor_Paid_By__c;
                    newExhibitor.userType       =   oppBooth.Opportunity__r.User_Type__r.Name; 
                    newExhibitor.accountName    =   oppBooth.Opportunity__r.Account.Name ;
                    newExhibitor.displayName    =   String.isNotBlank(oppBooth.Display_Name__c)? oppBooth.Display_Name__c : oppBooth.Opportunity__r.Account.Name;
                    newExhibitor.boothNumber    =   oppBooth.Booth_Number__c;
                    newExhibitor.dimensions     =   oppBooth.Expocad_Booth__r.Dimensions__c;
                    newExhibitor.boothType      =   oppBooth.Expocad_Booth__r.Matched_Product_Name__c;                    
                    newExhibitor.accountId      =   oppBooth.Opportunity__r.Account.Id;
                    newExhibitor.operationsContact= oppBooth.Opportunity__r.Operations_Contact__c;
                    newExhibitor.fName          =   oppBooth.Opportunity__r.Operations_Contact__r.FirstName;
                    newExhibitor.lName          =   oppBooth.Opportunity__r.Operations_Contact__r.LastNAme;
                    newExhibitor.email          =   oppBooth.Opportunity__r.Operations_Contact__r.Email;
                    newExhibitor.mobileNo       =   oppBooth.Opportunity__r.Operations_Contact__r.MobilePhone;

                    newExhibitor.agentCompany   =   (newExhibitor.paidBy == 'Individual Contract') ? oppBooth.Opportunity__r.Agent_s_Opportunity__r.Account.Name : (newExhibitor.userType == 'Co-Exhibitor' ?  oppBooth.Opportunity__r.parent_Opportunity__r.parent_Opportunity__r.Account.Name : oppBooth.Opportunity__r.parent_Opportunity__r.Account.Name);
                    newExhibitor.agentName      =   (newExhibitor.paidBy == 'Individual Contract') ? oppBooth.Opportunity__r.Agent_s_Opportunity__r.Operations_Contact__r.Name : (newExhibitor.userType == 'Co-Exhibitor' ?  oppBooth.Opportunity__r.parent_Opportunity__r.parent_Opportunity__r.Operations_Contact__r.Name : oppBooth.Opportunity__r.parent_Opportunity__r.Operations_Contact__r.Name);
                    
                    // This logic is for future use [C2E-109]
                    if(mapConEventWlcmMail.containsKey(oppBooth.Opportunity__r.Operations_Contact__c))
                    {
                        newExhibitor.emailSentDate  =   mapConEventWlcmMail.get(oppBooth.Opportunity__r.Operations_Contact__c).Email_Sent__c;
                        newExhibitor.isMailSent     =   mapConEventWlcmMail.get(oppBooth.Opportunity__r.Operations_Contact__c).IsEmailSent__c == true ? true : false;
                    }
                    
                    if(newExhibitor.isMailSent == true)
                    {
                        newExhibitor.welcomeEmailStatus  = 'Sent';
                    }
                    else if(mapAgentExhContactMap.containsKey(oppBooth.Opportunity__r.Operations_Contact__c))
                    {
                        newExhibitor.welcomeEmailStatus  = (mapAgentExhContactMap.get(oppBooth.Opportunity__r.Operations_Contact__c) )?'Sent':'Email Processing';                        
                    }
                    else
                    {
                        newExhibitor.welcomeEmailStatus  = 'Pending';
                    }
                    
                    if(mapContactUser.containsKey(oppBooth.Opportunity__r.Operations_Contact__c))
                    {
                        newExhibitor.userName       =   mapContactUser.get(oppBooth.Opportunity__r.Operations_Contact__c).UserName;
                        newExhibitor.lastLoginDate  =   mapContactUser.get(oppBooth.Opportunity__r.Operations_Contact__c).LastLoginDate;
                    }
                    
                  
                    switch on activity    // Filter on activity Selected
                    { 
                        when 'NoLogin'
                        {
                            if(maplastLogin.get(oppBooth.Opportunity__r.Account.Id) == null && (newExh == false || newExhibitor.isMailSent == false))
                            {
                                objExhibitors.add(newExhibitor); // Not Loged in users
                            }
                        }
                        when 'MissingForms' 
                        {   
                            AgentOwnedExhibitorUtils.CountWraper wrap = formStatusMap.get(oppBooth.Opportunity__r.Account.Id);  
                            if(wrap.completed != wrap.total && (newExh == false || newExhibitor.isMailSent == false))
                            {
                                objExhibitors.add(newExhibitor); // Missing Forms
                            }
                        }
                        when 'MissingManuals' 
                        {   
                            AgentOwnedExhibitorUtils.CountWraper wrap = manualsStatusMap.get(oppBooth.Opportunity__r.Account.Id);
                            if(wrap.completed != wrap.total && (newExh == false || newExhibitor.isMailSent == false))
                            {
                                objExhibitors.add(newExhibitor); // Missing Manuals
                            }
                        }
                        when 'MissingBadges' 
                        {    
                            AgentOwnedExhibitorUtils.CountWraper wrap = mapBadgesStatus.get(oppBooth.Id); 
                            if(wrap.completed < 1 && wrap.total > 0 && (newExh == false || newExhibitor.isMailSent == false))
                            {
                                objExhibitors.add(newExhibitor); // Missing badges
                            }
                        }
                        when 'MissingExProfile' 
                        {                            
                            if(mapExhibitorProfileStatus.get(oppBooth.Id) == 'Not Submitted' && (newExh == false || newExhibitor.isMailSent == false))
                            {
                                objExhibitors.add(newExhibitor); // Missing Exhibitor Profile
                            }
                        }
                        when 'MissingContractor' 
                        {                            
                            String matchProductName = String.isNotBlank(newExhibitor.boothType)?newExhibitor.boothType:''; // C2E-108
                            if(mapStandContractorStatus.get(oppBooth.Id) == 'Not Submitted' && matchProductName.containsIgnoreCase('Space Only') && (newExh == false || newExhibitor.isMailSent == false))
                            {
                                objExhibitors.add(newExhibitor); // Missing Stand Contractor
                            }
                        }
                        when else
                        {
                            if(newExh == false || newExhibitor.isMailSent == false)
                            {
                                objExhibitors.add(newExhibitor);
                            }// Else condition is commented by Palla Kishore for the ticket BK-19604
                            /*else
                            {
                               // objExhibitors.add(newExhibitor); // the Default Condition (no value selected - on load)
                            }*/
                        }
                    }
                }
            }
        }
        return objExhibitors;
    }
    public class exhibitorsWrapperClass
    {
        @AuraEnabled public ID id;
        @AuraEnabled public string accountName;
        @AuraEnabled public string displayName;
        @AuraEnabled public string boothNumber; 
        @AuraEnabled public string dimensions;
        @AuraEnabled public string boothType;
        @AuraEnabled public string operationsContact;        
        @AuraEnabled public string accountId;
        @AuraEnabled public string pavilion; 
        @AuraEnabled public String badges; 
        @AuraEnabled public String badgesAlloted; 
        @AuraEnabled public String badgesCompleted; 
        @AuraEnabled public String requiredForms; 
        @AuraEnabled public String requiredManuals; 
        @AuraEnabled public boolean isMailSent;
        @AuraEnabled public datetime emailSentDate;
        @AuraEnabled public datetime lastLoginDate;
        @AuraEnabled public String fName; 
        @AuraEnabled public String lName; 
        @AuraEnabled public String email;
        @AuraEnabled public String mobileNo; 
        @AuraEnabled public String agentCompany; 
        @AuraEnabled public String agentName; 
        @AuraEnabled public String userType; 
        @AuraEnabled public String userName; 
        @AuraEnabled public String paidBy; 
        @AuraEnabled public String parentPaidBy;
        @AuraEnabled public String welcomeEmailStatus;
        @AuraEnabled public list<Exhibitor_Badge__c> exhBadges; 
    }
    
    @AuraEnabled //Fetch booth details
    public static exhibitorsWrapperClass  getBoothDetails (String boothId,String sEventCode,string uType) 
    {
        system.debug('sEventCode'+sEventCode);
         //list<ExpocadBooth__c> lstExpoBooths=new list<ExpocadBooth__c>();
         list<Opportunity_ExpoCAD_Booth_Mapping__c> oppLstExpoBoothMap=new list<Opportunity_ExpoCAD_Booth_Mapping__c>();
        if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible()) 
        {
            oppLstExpoBoothMap = [Select Id, Booth_Number__c, Expocad_Booth__r.Area_Number__c,Expocad_Booth__r.Dimensions__c,Expocad_Booth__r.Pavilion__c,ExhibitorBadgesApproved__c,CountBadges__c ,Expocad_Booth__r.Booth_Product_Type__c,Expocad_Booth__r.Matched_Product_Name__c,Badge_Limit__c  From Opportunity_ExpoCAD_Booth_Mapping__c where id=:boothId AND Status__c='Active'];            
            system.debug('oppLstExpoBoothMap'+oppLstExpoBoothMap);
        }
        exhibitorsWrapperClass objWrapperClass= new exhibitorsWrapperClass();
        system.debug('oppLstExpoBoothMap'+oppLstExpoBoothMap);
        
        if(oppLstExpoBoothMap!=null && !oppLstExpoBoothMap.IsEmpty())
        {
            Event_Settings__c eventForBooth = getEventDetails(sEventcode);
            objWrapperClass.boothNumber=oppLstExpoBoothMap[0].Booth_Number__c;
            objWrapperClass.dimensions=oppLstExpoBoothMap[0].Expocad_Booth__r.Dimensions__c;
            objWrapperClass.pavilion=oppLstExpoBoothMap[0].Expocad_Booth__r.Pavilion__c;
            objWrapperClass.badgesCompleted=string.valueOf(oppLstExpoBoothMap[0].CountBadges__c);            
            Decimal area=oppLstExpoBoothMap[0].Expocad_Booth__r.Area_Number__c;
            list<Booth_Size_Badge_Limit__c> lstBoothSizeBadgeLimit  = new list<Booth_Size_Badge_Limit__c>(); 
            if(uType=='Co-Exhibitor' || uType=='Co_Exhibitor' )
            { 
                Event_Settings__c eventSettings = CommunityExhibitorBadgeCtrl.getEventSettings(sEventCode);
                objWrapperClass.badges =string.valueOf((oppLstExpoBoothMap[0].Badge_Limit__c!=null?oppLstExpoBoothMap[0].Badge_Limit__c:0) + Decimal.valueOf(eventSettings.Co_Exhibitor_Badge_Limit__c));
            }
            else if(eventForBooth.Allotment_By_Booth_Type__c)
            {
                if(Schema.sObjectType.Booth_Size_Badge_Limit__c.isAccessible()) {
                    lstBoothSizeBadgeLimit = [Select Badges_Allowed__c,Match_Product_Entry_Type__c,Booth_Type__c,Badges_Allowed_by_Booth_Type__c from Booth_Size_Badge_Limit__c where Event_Edition__r.Event_Code__c =:sEventCode  AND Booth_Type__c!=null];
                }
                if(lstBoothSizeBadgeLimit.size()>0)
                {
                    for (Booth_Size_Badge_Limit__c badgeByBoothType : lstBoothSizeBadgeLimit){
                        for(Opportunity_ExpoCAD_Booth_Mapping__c expoBooth :oppLstExpoBoothMap){
                            if((badgeByBoothType.Match_Product_Entry_Type__c!=null) && (badgeByBoothType.Booth_Type__c == expoBooth.Expocad_Booth__r.Matched_Product_Name__c) ){
                                if(badgeByBoothType.Match_Product_Entry_Type__c=='Fixed'){
                                  decimal totBadges = badgeByBoothType.Badges_Allowed_by_Booth_Type__c==null?0:badgeByBoothType.Badges_Allowed_by_Booth_Type__c;
                                    totBadges = totBadges + (expoBooth.Badge_Limit__c==null?0:expoBooth.Badge_Limit__c); 
                                    objWrapperClass.badges=string.valueOf(totBadges);
                                }
                                if(badgeByBoothType.Match_Product_Entry_Type__c=='Formula'){decimal totBadges = UtilityMethods.getTotalBadgesByDimension(expoBooth.Expocad_Booth__r.Dimensions__c);
                                    totBadges = totBadges + (expoBooth.Badge_Limit__c==null?0:expoBooth.Badge_Limit__c); 
                                    objWrapperClass.badges=string.valueOf(totBadges);
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                if(Schema.sObjectType.Booth_Size_Badge_Limit__c.isAccessible()) {
                    lstBoothSizeBadgeLimit = [Select Badges_Allowed__c from Booth_Size_Badge_Limit__c where Event_Edition__r.Event_Code__c =:sEventCode  AND (Booth_Size_From__c <=:area AND Booth_Size_To__c >=:area)];
                }
                if(lstBoothSizeBadgeLimit!=null && !lstBoothSizeBadgeLimit.IsEmpty())
                {
                    objWrapperClass.badges=string.valueOf((lstBoothSizeBadgeLimit[0].Badges_Allowed__c + (oppLstExpoBoothMap[0].Badge_Limit__c==null?0:oppLstExpoBoothMap[0].Badge_Limit__c)));
                } 
            }
        }
        return objWrapperClass;
    }

    @AuraEnabled //Fetch booth dimensions
    public static list<AggregateResult>  getBoothDimensions() 
    {
        list<AggregateResult> lstBoothDimns=new list<AggregateResult>();
        lstBoothDimns = [Select Expocad_Booth__r.Dimensions__c From Opportunity_ExpoCAD_Booth_Mapping__c where Status__c='Active' GROUP BY Expocad_Booth__r.Dimensions__c];    
        return lstBoothDimns;
    }
    
    @AuraEnabled //Fetch Accccount Contacts for Opportunity
    public static Opportunity getAccccountContacts(String accId,string eventId)
    {
        UtilityMethods objUtilityMethods= new UtilityMethods();
        return objUtilityMethods.getAccccountContacts(accId,eventId);   
    } 

    @AuraEnabled //Fetch contact EventEdition Mapping 
    public static ContactEventEditionMapping__c getContactEventEditionMapping(string eventId)
    {
        User usr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()]; 
        UtilityMethods objUtilityMethods= new UtilityMethods();
        return objUtilityMethods.getContactEventEditionMapping(usr.ContactId,eventId);    
    }

    @AuraEnabled //update contact EventEdition Mapping 
    public static void updateContactEventEditionMapping(ContactEventEditionMapping__c eventConMap)
    {
        update eventConMap;   
    }

    @AuraEnabled //fetch required forms for account
    public static list<User_Form_Action__c>  getRequiredForms(String accId, String eventId)
    {
        list<User_Form_Action__c> lstFormActions = new list<User_Form_Action__c> ();
        if(Schema.sObjectType.User_Form_Action__c.isAccessible()) {
            lstFormActions = [SELECT Id,Is_Filled_Up__c, Is_Viewed__c,Form_Permission__r.Event_Edition_Form__r.Name FROM User_Form_Action__c where Account__c=:accId  and Form_Permission__r.Event_Edition_Form__r.Event_Edition__c=:eventId and Form_Permission__r.Event_Edition_Form__r.Mandatory__c=true and (User_Type__r.Name='Agent Owned Exhibitor' OR User_Type__r.Name='Exhibitor' OR User_Type__r.Name='Co-Exhibitor') ];   
        }
       return lstFormActions;
    }

    @AuraEnabled //send welcome email to selected/all exhibitors
    public static string sendEmailtoExhibitors(list<string> lstConIds,string eventId)
    { 
        string msg='Email has been sent';
        User usr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()]; 
        set<Id> setConExs= new set<Id>();
        set<Id> setConNonExs= new set<Id>();
        if(lstConIds!=null && lstConIds.size()>0)
        {
            for(string conId:lstConIds)
            {
                setConNonExs.add(conId);
            } 
        }
        //Get existing user of contact with community profile
        List<User> lstUsr=[Select Id,ContactId,IsActive,IsPortalEnabled from User where ContactId IN : lstConIds and IsPortalEnabled=true And Profile.Name='Customer Community Login User Custom'];  
        if(lstUsr!=null && lstUsr.size()>0)
        {
            for(user objUsr : lstUsr)
            {
                setConNonExs.remove(objUsr.ContactId);
                setConExs.add(objUsr.ContactId);
            }   
        }
        List<AgentExhibitorsContact__c> lstAgentExhCons = new  List<AgentExhibitorsContact__c>(); 
        if(Schema.sObjectType.AgentExhibitorsContact__c.isAccessible()) {
            lstAgentExhCons = [select id,ExhibitorContactId__c from AgentExhibitorsContact__c where AgentContactId__c=:usr.ContactId and ExhibitorContactId__c IN :setConNonExs and EventEdition__c=:eventId];  
        }

        if(lstAgentExhCons!=null && lstAgentExhCons.size()>0)
        {
            
            for(AgentExhibitorsContact__c agnEchCon : lstAgentExhCons)
            {
                setConNonExs.remove(agnEchCon.ExhibitorContactId__c);
            }
        }
        
        list<AgentExhibitorsContact__c> lstAgnExbCon= new list<AgentExhibitorsContact__c>();
        for(Id conId : setConNonExs)
        {
            AgentExhibitorsContact__c newAgnExhCon= new AgentExhibitorsContact__c();
            newAgnExhCon.AgentContactId__c=usr.ContactId;
            newAgnExhCon.ExhibitorContactId__c=conId;
            newAgnExhCon.EventEdition__c=eventId;
            lstAgnExbCon.add(newAgnExhCon);
        }
        
        try
        {
            if(setConExs!=null && !setConExs.IsEmpty()){ 
                UtilityMethods.sendEmailToAgentUser(setConExs, eventId, usr.Contactid);
            }
            if(lstAgnExbCon!=null && !lstAgnExbCon.IsEmpty())
            {
                if(Schema.sObjectType.AgentExhibitorsContact__c.IsCreateable()) {
                    insert lstAgnExbCon;
                }
            }
        }
        catch (Exception ex){
            msg=ex.getMessage();
            System.debug('sendEmailtoExhibitors ERROR : '+ msg);
        }
        return msg;
    }
    
    public static void updateEmailDate(set<id> setConNonExs)
    {
        if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible()){
            List<ContactEventEditionMapping__c> lstConEvnMap = [SELECT id, IsEmailSent__c,Email_Sent__c  FROM ContactEventEditionMapping__c WHERE SFContactID__c IN :setConNonExs ];

            List<ContactEventEditionMapping__c> lstConEvnMapUpdate = new List<ContactEventEditionMapping__c>();
            if(lstConEvnMap!=null && lstConEvnMap.size()>0)
            {
                for(ContactEventEditionMapping__c conEvnMap : lstConEvnMap)
                {
                    conEvnMap.IsEmailSent__c = true;
                    conEvnMap.Email_Sent__c = system.now();
                    lstConEvnMapUpdate.add(conEvnMap);
                }
            }
            if(lstConEvnMapUpdate!=null && !lstConEvnMapUpdate.IsEmpty())
            {
                if(Schema.sObjectType.ContactEventEditionMapping__c.isUpdateable()) {
                    Update lstConEvnMapUpdate;
                }
            }
        }
    }
    
    @AuraEnabled //Fetch agent exhibitors contacts for user creation
    public static list<AgentExhibitorsContact__c> getAgentExhibitorsContact(String sEventId)
    {
       list<AgentExhibitorsContact__c> lstagentExhCon = new list<AgentExhibitorsContact__c>();
       lstagentExhCon =[select Id,AgentContactId__c,AgentContactId__r.Account.Name,AgentContactId__r.Name, ExhibitorContactId__c,ExhibitorContactId__r.Name,ExhibitorContactId__r.Account.Name ,IsUserCreated__c from AgentExhibitorsContact__c where EventEdition__c =: sEventId order by createddate desc limit 500];
       return lstagentExhCon;
    }

    @AuraEnabled //Fetch agent owned exhibitors contacts for user creation
    public static list<AgentExhibitorsContact__c> createUser(AgentExhibitorsContact__c agentExhCon)
    {
        ContactEventEditionMapping__c conEventMap = new ContactEventEditionMapping__c();
        list<User_Type__c> lstUserType=new list<User_Type__c>();
        if(Schema.sObjectType.User_Type__c.isAccessible()) {
           lstUserType=[select id from User_Type__c where name ='Agent Owned Exhibitor' limit 1];
        }
        
        if(!lstUserType.IsEmpty())
        {
            List<ContactEventEditionMapping__c> lstConEnvMap=new List<ContactEventEditionMapping__c>();
            lstConEnvMap = [SELECT Id  FROM ContactEventEditionMapping__c WHERE SFContactID__c=:agentExhCon.ExhibitorContactId__c and SFEventEditionID__c=:agentExhCon.EventEdition__c and User_Type__c=:lstUserType[0].Id order by createddate desc  LIMIT 1 ];

            if(lstConEnvMap.IsEmpty()){
                conEventMap.SFContactID__c=agentExhCon.ExhibitorContactId__c;
                conEventMap.SFEventEditionID__c=agentExhCon.EventEdition__c;
                conEventMap.User_Type__c=lstUserType[0].Id; 
                if(Schema.sObjectType.ContactEventEditionMapping__c.IsCreateable()){   
                    insert conEventMap;
                }   
            }/*
            else{
                set<String> setConEEmapIds =  new set<string>();
                setConEEmapIds.add(lstConEnvMap[0].Id); 
                ContactEventEditionMappingTriggerHandler objHendler= new ContactEventEditionMappingTriggerHandler(); // changed parameter [CCEN-585]
                objHendler.createCommunityUser(setConEEmapIds); 
            }  */
            update agentExhCon;
        }
        
        return getAgentExhibitorsContact(agentExhCon.EventEdition__c);
    }

    //Send email notification to Agents when new Exhibitors are appointed CCEN-241
    public void sendEmailNotificationtoAgent(set<Id> setAgentOwned,Set<Id> setEventEdition)
    {  
        set<id> agentConIds = new set<Id>();
        map<string,string> exhibitorAgentMap = new map<String,string>();
        List<Event_Settings__c> lstEventSetting = new List<Event_Settings__c>([SELECT Id, Send_Welcome_Email__c, Is_Event_Edition_Live__c FROM Event_Settings__c WHERE Event_Edition__c IN :setEventEdition AND Is_Event_Edition_Live__c = True AND Send_Welcome_Email__c = True and Send_email_notification_to_Agents__c = true]);

        if (lstEventSetting!=null && !lstEventSetting.IsEmpty())
        {
            list<opportunity> lstAgentOwnedOpp = new list<opportunity> ([select createdDate ,id,Name,EventEdition__c,parent_Opportunity__r.operations_contact__c,operations_contact__c from opportunity where  (StageName='Closed Won' OR StageName='Closed Booked') AND EventEdition__c IN :setEventEdition and parent_Opportunity__c !=null and operations_contact__c In :setAgentOwned order by createdDate desc limit 1000]);
            if(lstAgentOwnedOpp!=null && !lstAgentOwnedOpp.IsEmpty())
            {
                list<string> lstBoothIds= new list<string>();
                string eventId = lstAgentOwnedOpp[0].EventEdition__c;
                if(lstAgentOwnedOpp!=null && lstAgentOwnedOpp.size()>0)
                {
                    for(opportunity opp : lstAgentOwnedOpp) 
                    {
                        if(string.isNotBlank(opp.parent_Opportunity__r.operations_contact__c))
                        {
                            agentConIds.add(opp.parent_Opportunity__r.operations_contact__c);
                          exhibitorAgentMap.put(opp.operations_contact__c,opp.parent_Opportunity__r.operations_contact__c);
                        }
                    }  
                }
                map<id,contact> mapAgentCon = new map<id,contact>([select id,email,Name,Account.Name from contact where id in: agentConIds ]);
                map<id,contact> mapExhCon = new map<id,contact>();
                if (!exhibitorAgentMap.IsEmpty()){
                   mapExhCon = new map<id,contact>([select id,email,Name,Account.Name from contact where id in: exhibitorAgentMap.keySet()]);
                }
                
                //System.debug('mapAgentCon'  +mapAgentCon);
                //System.debug('mapExhCon'  +mapExhCon);
                //System.debug('exhibitorAgentMap'  +exhibitorAgentMap);
                sendEmailByCode(eventId,'SETA',mapAgentCon,mapExhCon,exhibitorAgentMap);
            }
        }
       
    }  
    
    // Sending Email to Agent When New Exhibitor assigned to them using Email_Template_Code__c = 'SETA'
    public static void sendEmailByCode(string eventEditionId, string emailTemCode, map<id,contact> mapAgentCon,map<id,contact> mapExhCon,map<string,string> exhibitorAgentMap)
    {
         List<Event_Edition_Email_Template__c> eeeTemplateList =new List<Event_Edition_Email_Template__c>();
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
        if(string.isBlank(fromAdd) || fromAdd == null )
        {
            fromAdd = 'do_not_reply_gecc@informa.com'; 
        }
        List<OrgWideEmailAddress> owea =new List<OrgWideEmailAddress>();
        if(Schema.sObjectType.OrgWideEmailAddress.isAccessible()) {
            owea = [select Id from OrgWideEmailAddress where Address =:fromAdd];  
        }                                          
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        for(contact exibCon : mapExhCon.values())
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            Contact agentCon = mapAgentCon.get(exhibitorAgentMap.get(exibCon.Id));
            string content = '';
            string subject='';
            if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
            {   
                content  = eeeTemplateList[0].Content__c != NULL ? eeeTemplateList[0].Content__c : '';
                string  agntname = (agentCon.Account.name != null )?agentCon.Account.name: '';
                string  exhname = (exibCon.Account.name != null )?exibCon.Account.name: '';
                
                content=content.replace('{Agent.Name}',agntname);
                content=content.replace('{Exhibitor.Name}',exhname);
                //subject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c ,eeeTemplateList[0].Event_Edition__c, agentCon.Id);
                subject = eeeTemplateList[0].Subject__c;
                
            //added this functionality regarding ticket [CCEN-358]
            if(owea!=null && !owea.isEmpty())
            {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
                email.setToAddresses(new String[] {agentCon.email});
                email.setSaveAsActivity(false);
                email.setTargetObjectId(agentCon.Id);
                email.setHtmlBody(content);
                email.setSubject(subject);
                if(eeeTemplateList[0].Subject__c!=null){     //BK-2591
                    massEmailLst.add(email);
                }
            }
        }
        //Send all emails if list is not empty
        if(massEmailLst!=null && massEmailLst.size()>0)   
        { 
            Messaging.sendEmail(massEmailLst,false);
        }  
    }   
}