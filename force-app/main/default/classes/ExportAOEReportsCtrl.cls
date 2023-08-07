/**
 * Created By      :   Girikon(Suraj)
 * Created On      :   Jan 15 2019
 * @description    :   Allow exhibitors to generate reports.
 * Test Class      :   ExportAOEReportsCtrl_Test(94%)
 * Modification Log----- 
 * Modified by     :   Girikon(Sunil[CCEN-587 Feb 1 2019], Girikon(Aishwarya)[CCEN-672 15 March 2019] ,Girikon(Rajeev mishra)[BK-2865 11 Nov 2019])
 **/

public with sharing class ExportAOEReportsCtrl 
{
    public string header{get;set;}  // variable to store the column names
    public List<wrapperClass> lstwrapper {get; set;}  // List of the wrapper class storing the data
     // List of the wrapper class storing the data
    public Boolean vipAllowedForEvent  {get;set;}
    // wrapper class to store all the data
    public string strEventName  {get;set;}
        /** Status Maps **/
    private map<Id,AgentOwnedExhibitorUtils.CountWraper> manualsStatusMap   = new map<Id,AgentOwnedExhibitorUtils.CountWraper>();   // map to store Customer Manual Status
    private map<Id,AgentOwnedExhibitorUtils.CountWraper> formStatusMap      = new map<Id,AgentOwnedExhibitorUtils.CountWraper>();      // map to store Customer Forms Status
    private Map<Id,AgentOwnedExhibitorUtils.CountWraper> mapBadgesStatus    = new map<Id,AgentOwnedExhibitorUtils.CountWraper>();    // map to store Customer badges Status
    private Map<Id,String> mapExhibitorProfileStatus = new map<Id,String>();    // map to store Customer Exhibitor Profile Status
    private Map<Id,string> mapStandContractorStatus = new map<Id,String>();     // map to store Customer Stand Contractor Status


    public class wrapperClass
    {                       
        public ID id;                                       // ID 
        public string boothNumber {get; set;}               // Booth Number
        public string boothType {get; set;}                 // Booth Type
        public string boothDimensions{get; set;}            // Booth Dimensions
        public string operationsContact {get; set;}         // Operations contact
        public string accountName {get; set;}               // account name
        public string displayName {get; set;}               // display name
        public String badges {get; set;}                    // badges
        public String badgesAlloted {get; set;}             // alloted badges
        public String badgesCompleted {get; set;}           // completed badges
        public String requiredForms {get; set;}             // required forms
        public String requiredManuals {get; set;}           // required Manuals
        public String contactName {get; set;}               // Contact Full Name
        public String fName {get; set;}                     // first name
        public String lName {get; set;}                     // last name
        public String email{get; set;}                      // email
        public String agentCompany{get; set;}               // agent company
        public String agentName{get; set;}                  // agent name
        public String userType{get; set;}                   // user type
        public String welcomeEmailSent{get; set;}           // Welcome Email Sent Date
        public String lastloginDate{get; set;}              // Last Login  Date
        public String exhibitorName{get; set;}              // exporter name
        public String jobTitle{get; set;}                   // job title
        public String mobile{get; set;}                     // mobile
        public String ageBracket{get; set;}                 // age bracket
        public String address{get; set;}                    // address
        public String city{get; set;}                       // city
        public String state{get; set;}                      // city
        public string country{get; set;}                    // country
        public String nationality{get; set;}                // nationality
        public string status{get; set;}                     // status
        public string userName{get; set;}                   // username  
        public string isVip{get;set;}                       // Vip Badge 
        public string contractorCompany{get;set;}           // Stand Contractor Account Name
        public string contractorContact{get;set;}           // Stand Contractor Contact Name
        public string subcontractors{get;set;}              // Stand Contractor's Sub-Contractor Account Name
        public string detailSubmitted{get;set;}             // Stand Details Submitted Date
        public string designSubmitted{get;set;}             // Stand Designs Submitted Date
        public string contractorAgreement{get;set;}         // Stand Contractor Agreement
        public string missingRequiredForms{get;set;}        // Missing Required Forms
        public string missingRequiredManuals{get;set;}      // Missing Required Manuals
        public string missingRequiredBadges{get;set;}       // Missing Required Badges
        public string missingExhibitorProfile{get;set;}     // Missing Exhibitor Profile
        public string missingStandContractor{get;set;}      // Missing Stand Contractor
        public string webDescription {get;set;}             // exhibitor Web Description
        public string printDescription {get;set;}           // exhibitor print Description
        public string exhibitorWebsite {get;set;}           // exhibitor Website
        public string exhibitorFaceBook {get;set;}          // exhibitor FaceBook
        public string exhibitorLinkedIn {get;set;}          // exhibitor LinkedIn
        public string exhibitorTwitter {get;set;}           // exhibitor Twitter
        public string exhibitorInstagram {get;set;}         // exhibitor Instagram
        public string exhibitorYouTube {get;set;}           // exhibitor YouTube
        public string exhibitorProducts{get;set;}           // exhibitor Products
    }

    // contructor to initilize values 
    public ExportAOEReportsCtrl()
    {  
        Event_Settings__c eventStng = new Event_Settings__c();
        vipAllowedForEvent = true;
        string eventId      = String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('eventId').escapeHtml4());  // Event Code as pram
        string reportName   = ApexPages.currentPage().getparameters().get('reportName');

        eventStng =  [select id , Allow_VIP_Badges__c,Event_Edition__r.Name from  Event_Settings__c where Event_Edition__r.Event_Code__c=:eventId limit 1];
        vipAllowedForEvent = eventStng.Allow_VIP_Badges__c;
        strEventName    =   eventStng.Event_Edition__r.Name;
        lstwrapper = new List<wrapperClass>();         
        switch on reportName 
        {
            when  'AllExhibitors'
            {
                header = 'Company Name,Stand,First Name,Last Name,Email,Exhibitor Username,Agent Company,Agent Name,Required Forms,Required Manuals,Badges,Badges Alloted,Badges Completed';
            }
            when  'ExhibitorActivitySummary'
            {
                header = 'Event Name,Exhibitor Name,Operations contact Firstname,Operations contact Lastname,Operations contact Email,Operations contact Mobile,Exhibitor Login username,Agent Company,Agent Name,Stand,Stand  Dimension,User Type,Matched Product Type,Welcome Email sent,Last Login,Missing required online forms,Missing required manuals,Missing required badges,Missing exhibitor profile,Missing stand contractor';
            }
            when  'ExhibitorLastlogin'
            {
                header = 'Company Name,Booth Number,Booth Type,Contact Name,Contact Email,User Type,Username,Welcome Email Date,Last Login Date'; 
                // header = 'Company Name,Stand,First Name,Last Name,Email,Exhibitor Username,Agent Company,Agent Name';
            }                
            when  'ExhibitorsMissingBadges'
            {
                header = 'Company Name,Stand,First Name,Last Name,Email,Exhibitor Username,Agent Company,Agent Name';
            }
            when  'ExhibitorsMissingManuals'
            {
                header = 'Company Name,Stand,First Name,Last Name,Email,Exhibitor Username,Agent Company,Agent Name,Required Manuals';
            }
            when  'ExhibitorsMissingForms'
            {
                header = 'Company Name,Stand,First Name,Last Name,Email,Exhibitor Username,Agent Company,Agent Name,Required Forms';
            }
            when  'ExhibitorsMissingExhibitorProfile'
            {
                header = 'Company Name,Stand,First Name,Last Name,Email,Exhibitor Username,Agent Company,Agent Name';
            }
            when  'ExhibitorsMissingContractor'
            {
                header = 'Exhibitor Name,Exhibitor Stand,Company Name,First Name,Last Name,Email Address,Username,Agent Company Name,Agent Name,Size of stand';
            }
            when  'ExhibitorsBadgeInformation'
            {
                //CCEN-672 Exporting Badges Report contains VIP column on basis of the Allow Vip badges checkbox on event setting Start
                if(eventStng.Allow_VIP_Badges__c == true)
                {
                    header = 'Company Name,Exhibitor Username,Company Name on Badge,Job Title,First Name,Last Name,Mobile Number,Email,Age Bracket,Address,City,State,Country,Nationality,Status,Booth Number,VIP';               
                }else
                {
                    header = 'Company Name,Exhibitor Username,Company Name on Badge,Job Title,First Name,Last Name,Mobile Number,Email,Age Bracket,Address,City,State,Country,Nationality,Status,Booth Number';            
                }                      
            }
            when  'ExhibitorsStandContractorInformation'
            {
                header = 'Exhibitor Name,Exhibitor Stand,Stand Contractor Company Name,Stand Contractor Contact,Submitted Stand Details,Submitted Stand Designs,Contractor Agreement Signed,Subcontractors';
            }
            when  'ExhibitorsProfilesInformation'
            {
                header = 'Exhibitor Name,Display Name,Profile Contact,Company Name,Stand,First Name,Last Name,Email Address,Exhibitor Username,Website,FaceBook,LinkedIn,Twitter,YouTube,Instagram,Web description,Print Description,Product Categories';
            }
            when else
            {
                header = 'Company Name,Stand,First Name,Last Name,Email,Exhibitor Username,Agent Company,Agent Name';
            }
        }
    }

     // function to export the data
     public void exportToExcel()
     { 
        string eventId      = String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('eventId').escapeHtml4());   //event Code
        string reportName   = ApexPages.currentPage().getparameters().get('reportName'); // reportName
        string accountId    = String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('accountId').escapeHtml4());   // SubAgent account Id

        List<AgentOwnExhibitorsCtrl.exhibitorsWrapperClass> exhibitorsList = new List<AgentOwnExhibitorsCtrl.exhibitorsWrapperClass>();// list of wrapper class

        switch on reportName 
        {
            when  'AllExhibitors'   
            {
                set<Id> setCustomerAccIds = new Set<Id>();
                set<Id> setBoothsIds = new Set<Id>();
                exhibitorsList = AgentOwnExhibitorsCtrl.getAllCustomers(eventId,'','All',accountId,null,null,false);                                
                for(AgentOwnExhibitorsCtrl.exhibitorsWrapperClass exhibitors : exhibitorsList)
                {
                    setCustomerAccIds.add(exhibitors.accountId);
                    setBoothsIds.add(exhibitors.id);
                }
                formStatusMap               =   AgentOwnedExhibitorUtils.getFormsStatusMap(setCustomerAccIds,eventId);
                manualsStatusMap            =   AgentOwnedExhibitorUtils.getManualsStatusMap(setCustomerAccIds,eventId);
                mapBadgesStatus             =   AgentOwnedExhibitorUtils.getbadgesStatusMap(setBoothsIds,eventId);

                setMiisingWrapperList(exhibitorsList);                
            }
            when  'ExhibitorActivitySummary'   
            {
                set<Id> setCustomerAccIds = new Set<Id>();
                set<Id> setBoothsIds = new Set<Id>();
                exhibitorsList = AgentOwnExhibitorsCtrl.getAllCustomers(eventId,'','All',accountId,null,null,false);                                
                for(AgentOwnExhibitorsCtrl.exhibitorsWrapperClass exhibitors : exhibitorsList)
                {
                    setCustomerAccIds.add(exhibitors.accountId);
                    system.debug('boothId'+exhibitors.id);
                    setBoothsIds.add(exhibitors.id);
                }
                formStatusMap               =   AgentOwnedExhibitorUtils.getFormsStatusMap(setCustomerAccIds,eventId);
                manualsStatusMap            =   AgentOwnedExhibitorUtils.getManualsStatusMap(setCustomerAccIds,eventId);
                mapBadgesStatus             =   AgentOwnedExhibitorUtils.getbadgesStatusMap(setBoothsIds,eventId);
                mapExhibitorProfileStatus   =   AgentOwnedExhibitorUtils.getExhibitorProfileStatusMap(setBoothsIds,eventId);
                mapStandContractorStatus    =   AgentOwnedExhibitorUtils.getStandContractorStatusMap(setBoothsIds,eventId);

                setMiisingWrapperList(exhibitorsList);  
            }
            when  'ExhibitorLastlogin'
            {
                exhibitorsList = AgentOwnExhibitorsCtrl.getAllCustomers(eventId,'','All',accountId,null,null,false);
                setMiisingWrapperList(exhibitorsList);
            }
            when  'ExhibitorsMissingBadges'
            {
                exhibitorsList = AgentOwnExhibitorsCtrl.getAllCustomers(eventId,'MissingBadges','All',accountId,null,null,false);
                setMiisingWrapperList(exhibitorsList);
            }
            when  'ExhibitorsMissingForms'
            {
                set<Id> setCustomerAccIds = new Set<Id>();
                exhibitorsList = AgentOwnExhibitorsCtrl.getAllCustomers(eventId,'MissingForms','All',accountId,null,null,false);
                for(AgentOwnExhibitorsCtrl.exhibitorsWrapperClass exhibitors : exhibitorsList)
                {
                    setCustomerAccIds.add(exhibitors.accountId);
                }
                formStatusMap = AgentOwnedExhibitorUtils.getFormsStatusMap(setCustomerAccIds,eventId);
                setMiisingWrapperList(exhibitorsList);
            }
            when  'ExhibitorsMissingManuals'
            {
                set<Id> setCustomerAccIds = new Set<Id>();
                exhibitorsList = AgentOwnExhibitorsCtrl.getAllCustomers(eventId,'MissingManuals','All',accountId,null,null,false);
                for(AgentOwnExhibitorsCtrl.exhibitorsWrapperClass exhibitors : exhibitorsList)
                {
                    setCustomerAccIds.add(exhibitors.accountId);
                }
                manualsStatusMap = AgentOwnedExhibitorUtils.getManualsStatusMap(setCustomerAccIds,eventId);
                setMiisingWrapperList(exhibitorsList);
                
            }
            when  'ExhibitorsMissingExhibitorProfile'  //New
            {
                exhibitorsList = AgentOwnExhibitorsCtrl.getAllCustomers(eventId,'MissingExProfile','All',accountId,null,null,false);
                setMiisingWrapperList(exhibitorsList);
            }
            when  'ExhibitorsMissingContractor'     //New
            {
                exhibitorsList = AgentOwnExhibitorsCtrl.getAllCustomers(eventId,'MissingContractor','All',accountId,'Space Only',null,false);
                setMiisingWrapperList(exhibitorsList);
            }
            when  'ExhibitorsBadgeInformation'      //New
            {
                exhibitorsList = AgentOwnExhibitorsCtrl.getAllCustomers(eventId,'','All',accountId,null,null,false);
                setWrapperListForBadges(exhibitorsList);
            }
            when  'ExhibitorsStandContractorInformation'    //New
            {
                exhibitorsList = AgentOwnExhibitorsCtrl.getAllCustomers(eventId,'','All',accountId,null,null,false);
                setWrapperListForContractor(exhibitorsList,eventId);
            }
            when 'ExhibitorsProfilesInformation' 
            {
                exhibitorsList = AgentOwnExhibitorsCtrl.getAllCustomers(eventId,'','All',accountId,null,null,false);
                setWrapperListForExhibitorProfile(exhibitorsList,eventId);
            }
            when else
            {
                System.debug('no request');
            }
        }
    }
     // function to set the data in the wrapper list   
    public void setMiisingWrapperList(List<AgentOwnExhibitorsCtrl.exhibitorsWrapperClass> exhibitorsList)
    {           
        for (AgentOwnExhibitorsCtrl.exhibitorsWrapperClass exhibitors : exhibitorsList)
        {                   
            // wrapper class to hold the data
            wrapperClass  wrpCls = new wrapperClass();                                                          
            wrpCls.ID               =   exhibitors.ID;
            wrpCls.boothNumber      =   exhibitors.boothNumber.escapeCsv();
            wrpCls.boothDimensions  =   String.isNotBlank(exhibitors.dimensions)? exhibitors.dimensions.escapeCsv() :'';
            wrpCls.userName         =   String.isNotBlank(exhibitors.userName)? exhibitors.userName.escapeCsv() :'';
            wrpCls.boothType        =   String.isNotBlank(exhibitors.boothType)? exhibitors.boothType.escapeCsv() :'';
            wrpCls.operationsContact=   String.isNotBlank(exhibitors.operationsContact)? exhibitors.operationsContact.escapeCsv() :''; 
            wrpCls.accountName      =   String.isNotBlank(exhibitors.accountName)? exhibitors.accountName.escapeCsv() :'';
            wrpCls.fName            =   String.isNotBlank(exhibitors.fName)? exhibitors.fName.escapeCsv() :''; 
            wrpCls.lName            =   String.isNotBlank(exhibitors.lName)? exhibitors.lName.escapeCsv() :'';            
            wrpCls.contactName      =   (wrpCls.fName.unescapeCsv()+' '+wrpCls.lName.unescapeCsv()).escapeCsv();
            wrpCls.email            =   String.isNotBlank(exhibitors.email)? exhibitors.email.escapeCsv() :'';
            wrpCls.mobile           =   String.isNotBlank(exhibitors.mobileNo)? exhibitors.mobileNo.escapeCsv() :'';
            wrpCls.agentCompany     =   String.isNotBlank(exhibitors.agentCompany)? exhibitors.agentCompany.escapeCsv() :'';
            wrpCls.agentName        =   String.isNotBlank(exhibitors.agentName)? exhibitors.agentName.escapeCsv() :'';
            wrpCls.userType         =   String.isNotBlank(exhibitors.userType)? (exhibitors.userType == 'Agent Owned Exhibitor' ? 'Exhibitor':(exhibitors.userType == 'Exhibitor'?'Individual Contract':exhibitors.userType )) :'';
            wrpCls.welcomeEmailSent =   exhibitors.emailSentDate != null? (exhibitors.emailSentDate).format() :'';
            wrpCls.lastloginDate    =   exhibitors.lastloginDate != null? (exhibitors.lastloginDate).format() :'';

            wrpCls.requiredForms    =   formStatusMap.containskey(exhibitors.accountId) ? string.valueOf(formStatusMap.get(exhibitors.accountId).total) : '0';
            wrpCls.requiredManuals  =   manualsStatusMap.containskey(exhibitors.accountId) ? string.valueOf(manualsStatusMap.get(exhibitors.accountId).total) : '0';

            wrpCls.badges           =   mapBadgesStatus.containskey(exhibitors.id) ? string.valueOf(mapBadgesStatus.get(exhibitors.id).completed)+' Out of '+string.valueOf(mapBadgesStatus.get(exhibitors.id).total) : '0 Out Of 0';
            wrpCls.badgesAlloted    =   mapBadgesStatus.containskey(exhibitors.id) ? string.valueOf(mapBadgesStatus.get(exhibitors.id).total) : '0';
            wrpCls.badgesCompleted  =   mapBadgesStatus.containskey(exhibitors.id) ? string.valueOf(mapBadgesStatus.get(exhibitors.id).completed):'0';

            wrpCls.missingRequiredForms     =   formStatusMap.containskey(exhibitors.accountId) ? (formStatusMap.get(exhibitors.accountId).completed != formStatusMap.get(exhibitors.accountId).total ? 'Yes':'No'): '';
            wrpCls.missingRequiredManuals   =   manualsStatusMap.containskey(exhibitors.accountId) ? (manualsStatusMap.get(exhibitors.accountId).completed != manualsStatusMap.get(exhibitors.accountId).total ? 'Yes':'No'): '';
            //system.debug('test_Complted_Badges..'+exhibitors.id);
            //system.debug('test_Complted_Badges..'+mapBadgesStatus.get(exhibitors.id).completed);
            wrpCls.missingRequiredBadges    =   mapBadgesStatus.containskey(exhibitors.id) ? (mapBadgesStatus.get(exhibitors.id).completed !=0 ? 'No':'Yes'): '';
            wrpCls.missingExhibitorProfile  =   mapExhibitorProfileStatus.containskey(exhibitors.id) ? (mapExhibitorProfileStatus.get(exhibitors.Id) == 'Not Submitted' ? 'Yes' : 'No') : '';
            //system.debug('StandContractorStatus.....'+mapStandContractorStatus.get(exhibitors.Id));
            wrpCls.missingStandContractor   =   mapStandContractorStatus.containskey(exhibitors.id) ? (mapStandContractorStatus.get(exhibitors.Id) == 'Not Submitted' && (exhibitors.boothType=='Space Only' || exhibitors.boothType=='Agent Pavilion Space Only')? 'Yes' : 'No') : '';
            lstwrapper.add(wrpCls);
        }
    }
    public void setWrapperListForBadges(List<AgentOwnExhibitorsCtrl.exhibitorsWrapperClass> exhibitorsList)
    {
        set<Id> setBoothids = new set<Id>();
        map<Id,AgentOwnExhibitorsCtrl.exhibitorsWrapperClass> mapExhibitorDetails = new map<Id,AgentOwnExhibitorsCtrl.exhibitorsWrapperClass>();
        for (AgentOwnExhibitorsCtrl.exhibitorsWrapperClass exhibitor : exhibitorsList) 
        {
            setBoothids.add(exhibitor.id);
            mapExhibitorDetails.put(exhibitor.accountId,exhibitor);
        }

        list <Exhibitor_Badge__c> listBadges = new list<Exhibitor_Badge__c> ([select id,Account__c,ExpoBoothNumber__c,Account__r.Name,User_Name__r.AccountId,User_Name__r.Account.Name,Job_Title__c,First_Name__c,Last_Name__c,Mobile_Number__c,Address__c,Age_Bracket__c,Booth_Size__c,City__c, toLabel(Country__c),Email__c,Exhibitor_Name__c,Nationality__c,State__c,Status__c,Is_VIP__c from Exhibitor_Badge__c where Opp_Booth_Mapping__c IN : setBoothids ]);
        for(Exhibitor_Badge__c badge:listBadges)
        {
            // initialize wrapper class
            wrapperClass  wrpCls    =   new wrapperClass(); 
            if(mapExhibitorDetails.containskey(badge.Account__c))
            {
                wrpCls.accountName  =   String.isNotBlank(mapExhibitorDetails.get(badge.Account__c).accountName)? mapExhibitorDetails.get(badge.Account__c).accountName.escapeCsv() :''; 
                wrpCls.userName     =   String.isNotBlank(mapExhibitorDetails.get(badge.Account__c).userName)? mapExhibitorDetails.get(badge.Account__c).userName.escapeCsv() :''; 
            }
            wrpCls.exhibitorName=   String.isNotBlank(badge.Exhibitor_Name__c)? badge.Exhibitor_Name__c.escapeCsv() :'';
            wrpCls.jobTitle     =   String.isNotBlank(badge.Job_Title__c)? badge.Job_Title__c.escapeCsv() :'';
            wrpCls.mobile       =   String.isNotBlank(badge.Mobile_Number__c)? badge.Mobile_Number__c.escapeCsv() :'';
            wrpCls.ageBracket   =   String.isNotBlank(badge.Age_Bracket__c)? badge.Age_Bracket__c.escapeCsv() :'';
            wrpCls.address      =   String.isNotBlank(badge.Address__c)? badge.Address__c.escapeCsv() :'';
            wrpCls.city         =   String.isNotBlank(badge.City__c)? badge.City__c.escapeCsv() :'';
            wrpCls.state        =   String.isNotBlank(badge.State__c)? badge.State__c.escapeCsv() :'';
            wrpCls.country      =   String.isNotBlank(badge.Country__c)? badge.Country__c.escapeCsv() :'';
            wrpCls.nationality  =   String.isNotBlank(badge.Nationality__c)? badge.Nationality__c.escapeCsv() :'';
            wrpCls.status       =   String.isNotBlank(badge.Status__c)? badge.Status__c.escapeCsv() :'';
            wrpCls.fName        =   String.isNotBlank(badge.First_Name__c)? badge.First_Name__c.escapeCsv() :'';
            wrpCls.lName        =   String.isNotBlank(badge.Last_Name__c)? badge.Last_Name__c.escapeCsv() :'';
            wrpCls.email        =   String.isNotBlank(badge.Email__c)? badge.Email__c.escapeCsv() :'';
            wrpCls.boothNumber  =   String.isNotBlank(badge.ExpoBoothNumber__c)? badge.ExpoBoothNumber__c.escapeCsv() :'';
            wrpCls.isVip        =   badge.Is_VIP__c ?'Yes': 'No';
            lstwrapper.add(wrpCls);
        }
    }
    public void setWrapperListForExhibitorProfile(List<AgentOwnExhibitorsCtrl.exhibitorsWrapperClass> exhibitorsList,string strEventCode)
    {
        set<Id> setBoothids = new set<Id>();
        map<Id,BoothContactInfo__c> mapBoothInnfo = new map<Id,BoothContactInfo__c>();
        map<Id,string> mapBoothProducts = new map<Id,string>();

        for (AgentOwnExhibitorsCtrl.exhibitorsWrapperClass exhibitor : exhibitorsList) 
        {
            setBoothids.add(exhibitor.id);            
        }
        map<Id,Opportunity_ExpoCAD_Booth_Mapping__c> mapBooths = new map<Id,Opportunity_ExpoCAD_Booth_Mapping__c>([select id,FaceBook__c,LinkedIn__c,Twitter__c,Instagram__c,Print_Description__c,YouTube__c,Web_Description__c from Opportunity_ExpoCAD_Booth_Mapping__c where id in:setBoothids]);

        // geeting BoothContactInfo__c for all booths
        for(BoothContactInfo__c boothInfo : [select id,First_Name__c,Website__c,Last_Name__c,Opportunity_Booth_Mapping__c from BoothContactInfo__c where Opportunity_Booth_Mapping__c in :setBoothids])
        {
            mapBoothInnfo.put(boothInfo.Opportunity_Booth_Mapping__c,boothInfo);
        }
        
        // geeting Products for all booths
        for(Customer_Product_Sub_Category__c productL3 : [select id , Opp_Booth_Mapping__c,Event_Edition_Sub_Category_Mapping__c,Event_Edition_Sub_Category_Mapping__r.Levels_Master__r.LevelValue__c from Customer_Product_Sub_Category__c where Opp_Booth_Mapping__c in : setBoothids])
        {
            string prodl3 = String.isNotBlank(productL3.Event_Edition_Sub_Category_Mapping__r.Levels_Master__r.LevelValue__c)? productL3.Event_Edition_Sub_Category_Mapping__r.Levels_Master__r.LevelValue__c :'';
            if(mapBoothProducts.containskey(productL3.Opp_Booth_Mapping__c))
            {   
                string prod =  mapBoothProducts.get(productL3.Opp_Booth_Mapping__c)+','+prodl3;
                mapBoothProducts.put(productL3.Opp_Booth_Mapping__c,prod);
            }
            else
            {
                mapBoothProducts.put(productL3.Opp_Booth_Mapping__c,prodl3);
            }
        }

        for (AgentOwnExhibitorsCtrl.exhibitorsWrapperClass exhibitors : exhibitorsList)
        {
            String exhibitorProfileName;
            if(mapBoothInnfo.containskey(exhibitors.id))
            {
                string exhibitorProfileFName    =   String.isNotBlank(mapBoothInnfo.get(exhibitors.id).First_Name__c) ? mapBoothInnfo.get(exhibitors.id).First_Name__c:'';
                string exhibitorProfileLName    =   String.isNotBlank(mapBoothInnfo.get(exhibitors.id).Last_Name__c) ? mapBoothInnfo.get(exhibitors.id).Last_Name__c:'';
                exhibitorProfileName     =    exhibitorProfileFName+' '+exhibitorProfileLName;
            }
            
        
        // initialize wrapper class
            wrapperClass  wrpCls    =   new wrapperClass();

            wrpCls.accountName      =   String.isNotBlank(exhibitors.accountName)? exhibitors.accountName.escapeCsv() :'';
            wrpCls.boothNumber      =   exhibitors.boothNumber.escapeCsv();
            wrpCls.displayName      =   String.isNotBlank(exhibitors.displayName)? exhibitors.displayName.escapeCsv() :'';
            wrpCls.fName            =   String.isNotBlank(exhibitors.fName)? exhibitors.fName.escapeCsv() :''; 
            wrpCls.lName            =   String.isNotBlank(exhibitors.lName)? exhibitors.lName.escapeCsv() :'';
            wrpCls.contactName      =   (wrpCls.fName.unescapeCsv()+' '+wrpCls.lName.unescapeCsv()).escapeCsv();
            wrpCls.email            =   String.isNotBlank(exhibitors.email)? exhibitors.email.escapeCsv() :'';
            wrpCls.userName         =   String.isNotBlank(exhibitors.userName)? exhibitors.userName.escapeCsv() :'';
            wrpCls.exhibitorName    =   String.isNotBlank(exhibitorProfileName) ? exhibitorProfileName.escapeCsv() : wrpCls.contactName;
            wrpCls.exhibitorWebsite =   mapBoothInnfo.containskey(exhibitors.id) ? (String.isNotBlank(mapBoothInnfo.get(exhibitors.id).Website__c) ? mapBoothInnfo.get(exhibitors.id).Website__c.escapeCsv() :''):'';
            // wrpCls.webDescription   =   String.isNotBlank(mapBooths.get(exhibitors.id).Web_Description__c) ? mapBooths.get(exhibitors.id).Web_Description__c.stripHtmlTags() :'';
            // wrpCls.printDescription =   String.isNotBlank(mapBooths.get(exhibitors.id).Print_Description__c) ? mapBooths.get(exhibitors.id).Print_Description__c.stripHtmlTags() :'';
            wrpCls.webDescription   =   String.isNotBlank(mapBooths.get(exhibitors.id).Web_Description__c) ? mapBooths.get(exhibitors.id).Web_Description__c.replaceAll('<[^>]+>',' ').replaceAll('[^a-zA-Z0-9\\s+]', '').escapeCsv() :'';
            wrpCls.printDescription =   String.isNotBlank(mapBooths.get(exhibitors.id).Print_Description__c) ? mapBooths.get(exhibitors.id).Print_Description__c.replaceAll('<[^>]+>',' ').replaceAll('[^a-zA-Z0-9\\s+]', '').escapeCsv() :'';
            wrpCls.exhibitorFaceBook=   String.isNotBlank(mapBooths.get(exhibitors.id).FaceBook__c) ? mapBooths.get(exhibitors.id).FaceBook__c.escapeCsv() :'';
            wrpCls.exhibitorLinkedIn=   String.isNotBlank(mapBooths.get(exhibitors.id).LinkedIn__c) ? mapBooths.get(exhibitors.id).LinkedIn__c.escapeCsv() :'';
            wrpCls.exhibitorTwitter =   String.isNotBlank(mapBooths.get(exhibitors.id).Twitter__c) ? mapBooths.get(exhibitors.id).Twitter__c.escapeCsv() :'';
            wrpCls.exhibitorYouTube =   String.isNotBlank(mapBooths.get(exhibitors.id).YouTube__c) ? mapBooths.get(exhibitors.id).YouTube__c.escapeCsv() :'';
            wrpCls.exhibitorInstagram=  String.isNotBlank(mapBooths.get(exhibitors.id).Instagram__c) ? mapBooths.get(exhibitors.id).Instagram__c.escapeCsv() :'';
            wrpCls.exhibitorProducts =  mapBoothProducts.containskey(exhibitors.id) ? (String.isNotBlank(mapBoothProducts.get(exhibitors.id)) ? mapBoothProducts.get(exhibitors.id).escapeCsv() :'') :'';
            
            lstwrapper.add(wrpCls);
        }
    }
    public void setWrapperListForContractor(List<AgentOwnExhibitorsCtrl.exhibitorsWrapperClass> exhibitorsList,string strEventCode)
    {
        set<Id> setBoothids = new set<Id>();
        Map<String,Stand_Detail__c> mapAccStndDetail  = new  Map<String,Stand_Detail__c> ();        //map Stand Detail
        Map<String,Stand_Design__c> mapAccStndDesign = new Map<String,Stand_Design__c>();           //map Stand Design
        map<Id,AgentOwnExhibitorsCtrl.exhibitorsWrapperClass> mapExhibitorDetails = new map<Id,AgentOwnExhibitorsCtrl.exhibitorsWrapperClass>();
        for (AgentOwnExhibitorsCtrl.exhibitorsWrapperClass exhibitor : exhibitorsList) 
        {
            setBoothids.add(exhibitor.id);
            mapExhibitorDetails.put(exhibitor.id,exhibitor);
        }
        // fatch Contractors
        list <BoothContractorMapping__c> listBoothMaping = new list<BoothContractorMapping__c>([select Id , Opp_Booth_Mapping__c,contact__r.AccountId,Contact__c,Contact__r.Name,Contact__r.Account.Name,IsAgree__c,(select id,TempContact__r.TempAccount__r.Name from BoothContractorMappings__r where TempContact__r.Is_SubContractors_Available__c = true) from BoothContractorMapping__c where Opp_Booth_Mapping__c in: setBoothids AND Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c like 'Space Only%' And (Contact__c != NULL AND Approved__c = TRUE)]);

        if(!listBoothMaping.isEmpty())
        {
            //Fetch Stand Details
            mapAccStndDetail    =  StandContractorUtils.getAllStandDetail(strEventCode);
            
            //Fetch Stand Designs
            mapAccStndDesign    =   StandContractorUtils.getAllStandDesign(strEventCode);
        }
        for(BoothContractorMapping__c BoothConMapping:listBoothMaping)
        {
            string SubContractorsName ;
            string mapKey = string.valueof(BoothConMapping.contact__r.AccountId)+'_'+string.valueof(BoothConMapping.Opp_Booth_Mapping__c);
            for(BoothContractorMapping__c SubContractors :BoothConMapping.BoothContractorMappings__r ) // SubContractors
            {
                SubContractorsName = string.isNotBlank(SubContractors.TempContact__r.TempAccount__r.Name) ? SubContractors.TempContact__r.TempAccount__r.Name+','+SubContractors.TempContact__r.TempAccount__r.Name : SubContractors.TempContact__r.TempAccount__r.Name;
            }
            wrapperClass  wrpCls    =   new wrapperClass();            
            wrpCls.accountName      =   String.isNotBlank(mapExhibitorDetails.get(BoothConMapping.Opp_Booth_Mapping__c).accountName)? mapExhibitorDetails.get(BoothConMapping.Opp_Booth_Mapping__c).accountName.escapeCsv() :'';
            wrpCls.boothNumber      =   String.isNotBlank(mapExhibitorDetails.get(BoothConMapping.Opp_Booth_Mapping__c).boothNumber)? mapExhibitorDetails.get(BoothConMapping.Opp_Booth_Mapping__c).boothNumber.escapeCsv() :'';
            wrpCls.contractorCompany=   String.isNotBlank(BoothConMapping.Contact__r.Account.Name)? BoothConMapping.Contact__r.Account.Name.escapeCsv() :'';
            wrpCls.contractorContact=   String.isNotBlank(BoothConMapping.Contact__r.Name)? BoothConMapping.Contact__r.Name.escapeCsv() :'';
            wrpCls.subcontractors   =   string.isNotBlank(SubContractorsName) ? SubContractorsName.escapeCsv() : '';                        
            wrpCls.detailSubmitted  =   mapAccStndDetail.containskey(mapKey) ? (mapAccStndDetail.get(mapKey).LastModifiedDate != null? mapAccStndDetail.get(mapKey).LastModifiedDate.date().format():'') :'';
            wrpCls.designSubmitted  =   mapAccStndDesign.containskey(mapKey) ? (mapAccStndDesign.get(mapKey).Booth_Design_Submitted_On__c != null? mapAccStndDesign.get(mapKey).Booth_Design_Submitted_On__c.format():'') :'';
            wrpCls.contractorAgreement  = BoothConMapping.IsAgree__c ? 'Yes': 'No';

            lstwrapper.add(wrpCls);
        }  
    }
}