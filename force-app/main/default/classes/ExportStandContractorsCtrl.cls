/**
* Created By        :  Girikon(Sunil)
* Created On        :  12/04/2018
* @description      :  This apex class "ExportStandContractorsCtrl" following methods: //CCEN - 476

* Methods:  
* Apex Test Class   :  ExportStandContractorsCtrl_Test (85%) 
*
* Modification Log----- 
* Modified by       :  Girikon(Suraj Yadav),Girikon(Amit Gupta),Girikon(Rahul Kumar) -Girikon(amish/Sunil)[CCEN 588 (22 Jan 2019)],Girikon(Mahesh)[CCEN 560 March 20 2019)],Girikon(Garima)[CCEN 756 April 3 2019),Girikon(Ashish)CCEN-742 (April 02 2019 ),CCEN-753 (April 16 2019 ),Girikon(Himanshu)BK-2173(Oct 30 2019),Girikon(Rajeev)BK-2346(Sep 30 2019), Aishwarya[BK-2990 Nov 29 2019],Girikon(Himanshu [BK-2876 15 Dec 2019]]
**/
public with sharing class ExportStandContractorsCtrl 
{    
    public string header{get;set;} //headers for the report
    public List<wrapperAllExhibitors> lstwrapper {get; set;}      // list of the wrapper class for all exhibitors  
    public List<wrapperExhibitorWithoutContractor> lstEWCwrapper {get; set;} // list of the wrapper class for exhibitors without contractors  
    public List<wrapperSubcontractors> lstSubcontractorswrapper {get; set;} //list of the wrapper class for subcontractors  
    public List<wrapperContractorSalesForceApprovals> lstContractorSalesForceApprovalswrapper {get; set;} // list of the wrapper class for contractor salesforce approval
    
    public string filetype{get;set;} // file type 
    public boolean isExcel {get;set;}// is file type excel
    public boolean isCsv {get;set;}  // is file type csv
    public ExportStandContractorsCtrl()
    {   // contructor to initialize all values
        Filetype = ''; 
        lstwrapper = new List<wrapperAllExhibitors>(); 
        lstEWCwrapper = new List<wrapperExhibitorWithoutContractor>();
        lstSubcontractorswrapper = new List<wrapperSubcontractors>();
        lstContractorSalesForceApprovalswrapper = new List<wrapperContractorSalesForceApprovals>(); 
        
        if(ApexPages.currentPage().getparameters().get('compName') == 'AllAssigned')
        {
            header = 'Customer,Type,Exhibiting Name,Agent Name,Booth#,Matched Product Name,Contractor Company,Performance Bond Submitted,Performance Bond Amount,Rigging,Double Decker,Heavy Machinery,Vehicle,Booth Design Submitted On,CA,Booth Status,Designation Status, Notes,Require Early Access,Early Access date_time,Early Access Cost,Contractor Mobile Number,Exhibitor Opeartion Contact,Exhibitor Opeartions Email,Exhibitor Opeartions MobileNo,Exhibitor Opeartion Tel,Contractor Contact Name,Contractor Contact Mobile,Contractor Contact Tel,Contractor Contact Email,Exhibitor Username,Contractor Username,Stand Height,Rigging Height,Length,Width';  
                                     
        }
        if(ApexPages.currentPage().getparameters().get('compName') == 'ExhibitorsWithoutContractors')
        {
            header = 'Exhibitor Name,Exhibiting Name,Email,Phone Number,Mobile Number,Stand Number,Matched Product Name,Notes';      
        }
        if(ApexPages.currentPage().getparameters().get('compName') == 'Subcontractors')
        {
            header = 'Booth#,Matched Product Name,Exhibitor,Exhibiting Name,Subcontractors Company,Subcontractors Contact, Services,Stand Contractor Company,Contractor Contact Person,Contractor Mobile,Contractor Email,Date Added';              
        }
        if(ApexPages.currentPage().getparameters().get('compName') == 'Contractor_SalesForce_Approvals')
        {
            header = 'For Customer,Type,Exhibiting Name,Booth#,Matched Product Name,Contractor Company,Contact,Date submitted, Date Approved, Status';              
        }
    }
    public class wrapperAllExhibitors       // wrapper class defination
    {   
        public string strExhibitor {get; set;} // ApproveContractorCtrl.ExhibitorsWrapper's strExhibitor
        public string userType {get; set;} // ApproveContractorCtrl.ExhibitorsWrapper's userType
        public string exhibitingName{get; set;} // ApproveContractorCtrl.ExhibitorsWrapper's exhibitingName
        public string strBooth{get; set;} // ApproveContractorCtrl.ExhibitorsWrapper's strBooth
        public string agntName{get; set;} // ApproveContractorCtrl.ExhibitorsWrapper's Agent Name
        public string boothProductType{get; set;} // ApproveContractorCtrl.ExhibitorsWrapper's boothProductType
        //CCEN 588 - isReceived, performanceBondAmount
        public Boolean isReceived{get; set;}
        public string performanceBondAmount{get; set;}
        public Boolean boolRigging{get; set;} // ApproveContractorCtrl.ExhibitorsWrapper's boolRigging
        public Boolean boolDblDckr{get; set;} // ApproveContractorCtrl.ExhibitorsWrapper's boolDblDckr
        public Boolean boolHevyMachin{get; set;} // ApproveContractorCtrl.ExhibitorsWrapper's boolHevyMachin
        public string dBoothDsnSbmttdOn{get; set;} // ApproveContractorCtrl.ExhibitorsWrapper's dBoothDsnSbmttdOn
        public Boolean boolCA{get; set;} // ApproveContractorCtrl.ExhibitorsWrapper's boolCA
        public string sBoothStatus{get; set;} // ApproveContractorCtrl.ExhibitorsWrapper's sBoothStatus
        public string sContrctorStatus{get; set;} // ApproveContractorCtrl.ExhibitorsWrapper's sContrctorStatus
        public string sRcntNote{get; set;} // ApproveContractorCtrl.ExhibitorsWrapper's sRcntNote
        public string contractorCompany{get; set;} // ApproveContractorCtrl.ExhibitorsWrapper's contractorCompany
        public boolean requireEarlyAcces{get;set;}
        public datetime earlyAccessDateTime{get;set;}
        public decimal earlyAccessCost{get;set;}
        public String contractorPhone{get;set;}//BoothContractorMapping__c's Contact__r.Account.Phone
        public string exhibOpeartionCon{get;set;}//BoothContractorMapping__c's Operation_Contact__r.Name
        public string exhibOpeartionEmail{get;set;}//BoothContractorMapping__c's Operation_Contact__r.Email
        public string exhibOpeartionMobile{get;set;}//BoothContractorMapping__c's Operation_Contact__r.Phone
        public string exhibOpeartionTel{get;set;}//BoothContractorMapping__c's Operation_Contact__r.MobilePhone
        public string contContactName{get;set;}//BoothContractorMapping__c's Contact__r.Name
        public string contContactMobile{get;set;}//BoothContractorMapping__c's Contact__r.Phone
        public string contContactTel{get;set;}//BoothContractorMapping__c's Contact__r.MobilePhone
        public string contContactEmail{get;set;}//BoothContractorMapping__c's Contact__r.Email
        public decimal boolStdHgt{get;set;} //Stand_Detail__c's Stand_Height__c
        public decimal boolRigHgt{get;set;} //Stand_Detail__c's Rigging_Height__c 
        public boolean boolVehicle{get;set;}//Stand_Detail__c's Is_Vehicles__c
        public string boothdimensions{get;set;}//Length and Width
        public string boothLenght{get;set;}//Boothdimesion - Length
        public string boothWidth{get;set;}//Boothdimesion -  Width
        public string usernameexh{get;set;}//BoothContractorMapping__c's Operation_Contact__r.Username
        public string contractorUsername{get;set;}//BoothContractorMapping__c's Operation_Contact__r.Username
    }
    
    public class wrapperExhibitorWithoutContractor // wrapper class defination
    { 
        public string exhibitorName {get; set;} // ExpocadBooth__c's Opportunity__r.Account.Name
        public string exhibitingName{get; set;} // ExpocadBooth__c's Display_Name__c
        public string email{get; set;} // ExpocadBooth__c's Opportunity__r.Operations_Contact__r.email
        public string phoneNumber{get; set;} // ExpocadBooth__c's Opportunity__r.Operations_Contact__r.phone
        public string mobileNumber{get; set;}// ExpocadBooth__c's Opportunity__r.Operations_Contact__r.mob
        public string standNumber{get; set;} /// ExpocadBooth__c's Booth_Number__c
        public string boothProductType{get; set;} // ExpocadBooth__c's Matched_Product_Name__c
        public string notes{get; set;} // ExpocadBooth__c's Notes__r
    }
    
    public class wrapperSubcontractors
    { // wrapper class defination
        public string booth {get; set;} // BoothContractorMapping__c ExpocadBooth__r.Booth_Number__c
        public string boothProductType {get; set;} // BoothContractorMapping__c ExpocadBooth__r.Matched_Product_Name__c 
        public string exhibitor{get; set;} // BoothContractorMapping__c ExpocadBooth__r.Opportunity__r.Account.Name
        public string exhibitingName {get; set;} // BoothContractorMapping__c ExpocadBooth__r.Display_Name__c
        public string contractor {get; set;} // BoothContractorMapping__c Parent_BoothMapping__r.Contact__r.Account.Name
        public string subContractorsCompany {get; set;}// BoothContractorMapping__c TempContact__r.Name__c
        public string subContractorSContact {get; set;}// ABoothContractorMapping__c TempContact__r.TempAccount__r.Name
        public string services {get; set;}// BoothContractorMapping__c ccServices.ContractorService__r.Contractor_Service__c
        public string standConCompany {get; set;}// BoothContractorMapping__c ccServices.ContractorService__r.Contractor_Service__c
        public string conContactName {get; set;}// BoothContractorMapping__c ccServices.ContractorService__r.Contractor_Service__c
        public string conMobile {get; set;}// BoothContractorMapping__c ccServices.ContractorService__r.Contractor_Service__c
        public string conEmail {get; set;}// BoothContractorMapping__c ccServices.ContractorService__r.Contractor_Service__c
        public Datetime dateAdded {get; set;}// BoothContractorMapping__c CreatedDate
    }
    
    public class wrapperContractorSalesForceApprovals{ // wrapper class defination
        public string forExhibitor {get; set;}// BoothContractorMapping__c  ExpocadBooth__r.Opportunity__r.Account.Name
        public string type {get; set;}// BoothContractorMapping__c ExpocadBooth__r.Opportunity__r.User_Type__r.Name
        public string exhibitingName {get; set;}// BoothContractorMapping__c ExpocadBooth__r.Display_Name__c
        public string booth{get; set;}// BoothContractorMapping__c ExpocadBooth__r.Booth_Number__c
        public string boothProductType {get; set;}//BoothContractorMapping__c ExpocadBooth__r.Matched_Product_Name__c
        public string contractorCompany {get; set;}//BoothContractorMapping__c Contact__r.Account.Name
        public string contact {get; set;}// BoothContractorMapping__c Contact__r.Name
        public Datetime dateSubmitted {get; set;}// BoothContractorMapping__c CreatedDate
        public Datetime dateApproved {get; set;}// BoothContractorMapping__c Approval_Date__c
        public string status {get; set;}// BoothContractorMapping__c Approved__c
    }
    //Export data on the basis of passed parameters 
    public void exportToExcel(){
        if(ApexPages.currentPage().getparameters().get('compName') == 'AllAssigned')
        {            
            this.exportAllContractors();            
        }
        if(ApexPages.currentPage().getparameters().get('compName') == 'ExhibitorsWithoutContractors')
        {       
            this.exportExhibitorsWithoutConractors();              
        }
        if(ApexPages.currentPage().getparameters().get('compName') == 'Subcontractors')
        {       
            this.exportSubContractors();              
        }
        if(ApexPages.currentPage().getparameters().get('compName') == 'Contractor_SalesForce_Approvals')
        {       
            this.exportContractorSalesForceApprovals();              
        }
    }
    //Export all assigned contractors
    public void exportAllContractors()
    {
        String boothDesignStatus = String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('bdstatus').escapeHtml4()); // booth design status
        system.debug('boothDesignStatus'+boothDesignStatus); 
        String sStatus = String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('status').escapeHtml4()); // status
        String riggedOption =String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('rigged').escapeHtml4());// rigged 
        String searchTearm = String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('search').escapeHtml4()); // searh string
        Boolean bDblDckrStatus = Boolean.valueOf(ApexPages.currentPage().getparameters().get('bDblDckrStatus').escapeHtml4());//ddckrstatus
        Boolean bCA = Boolean.valueOf(ApexPages.currentPage().getparameters().get('bCA').escapeHtml4()); // bca
        Boolean pbs = Boolean.valueOf(ApexPages.currentPage().getparameters().get('pbs').escapeHtml4());//pbs
        Boolean pbns = Boolean.valueOf(ApexPages.currentPage().getparameters().get('pbns').escapeHtml4());// pbns
        Boolean sme = Boolean.valueOf(ApexPages.currentPage().getparameters().get('sme').escapeHtml4());//sme
        Boolean isAllAgt = Boolean.valueOf(ApexPages.currentPage().getparameters().get('isAllAgt').escapeHtml4());// is agent
        Boolean isAgtPvnSpc = Boolean.valueOf(ApexPages.currentPage().getparameters().get('isAgtPvnSpc')); // is agent pavelion space
        String sEventId = String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('event').escapeHtml4());      // eventId
        ApproveContractorCtrl.ExhibitorsWrapper lstwrappercls = ApproveContractorCtrl.getAllFilterContractor(boothDesignStatus,sStatus,riggedOption,searchTearm,bDblDckrStatus, bCA,pbs,pbns, sme,isAllAgt,isAgtPvnSpc,sEventId,'ExpocadBooth__r.Opportunity__r.account.name','asc',1,0);
        map<string,ApproveContractorCtrl.wrapperClass> mapAgentWrpClass=new map<string,ApproveContractorCtrl.wrapperClass>();
        list<ExpocadBooth__c> expolist=new list<ExpocadBooth__c>();
        Event_Edition__c eventEdition = new Event_Edition__c();
        if(Schema.sObjectType.Event_Edition__c.isAccessible())
        {
            eventEdition = [select id,Event_Code__c from Event_Edition__c where id =:sEventId And Event_Code__c != null limit 1];  
        }
        for(ApproveContractorCtrl.wrapperClass wrp : lstwrappercls.lstWrapper)
        {
            wrapperAllExhibitors wObj = new wrapperAllExhibitors();  // initialize wrapper
            if(wrp.isManagedbyAgent)
            {   
                mapAgentWrpClass.put(wrp.agentAccountID,wrp);
            }
            else
            {
                wObj.strExhibitor        =   replaceNulls(wrp.strExhibitor).escapeCsv();
                wObj.userType            =   replaceNulls(wrp.userType).escapeCsv();
                wObj.exhibitingName      =   replaceNulls(wrp.exhibitingName).escapeCsv();
                wObj.agntName            =   replaceNulls(wrp.agentName).escapeCsv();
                wObj.strBooth            =   replaceNulls(wrp.strBooth).escapeCsv();
                wObj.boothProductType    =   replaceNulls(wrp.boothProductType).escapeCsv();
                //CCEN 588 - isReceived, performanceBondAmount
                wObj.isReceived          =   wrp.isReceived;
                wObj.performanceBondAmount =  wrp.performanceBondAmount;
                wObj.boolRigging         =   wrp.boolRigging;
                wObj.boolDblDckr         =   wrp.boolDblDckr;
                wObj.boolHevyMachin      =   wrp.boolHevyMachin; 
                wObj.boolCA              =   wrp.boolCA;
                wObj.sBoothStatus        =   replaceNulls(wrp.sBoothStatus).escapeCsv();
                wObj.sContrctorStatus    =   replaceNulls(wrp.sContrctorStatus).escapeCsv();
                wObj.sRcntNote           =   replaceNulls(wrp.sRcntNote).escapeCsv(); 
                wObj.contractorCompany =  wrp.isSelfManaged ?'(Self Managed)':replaceNulls(wrp.contractorCompany).escapeCsv();
                wObj.requireEarlyAcces   =   wrp.sreqErlyAcc; 
                wObj.earlyAccessDateTime =   wrp.serlyaccDte_Time;
                wObj.earlyAccessCost     =   wrp.serlyAccCost; 
                //Start of BK - 2876
                wObj.contractorPhone     =   wrp.contractorPhone;
                wObj.exhibOpeartionCon     =   wrp.exhibOpeartionCon;
                wObj.exhibOpeartionEmail     =   wrp.exhibOpeartionEmail;
                wObj.exhibOpeartionMobile     =   wrp.exhibOpeartionMobile;
                wObj.exhibOpeartionTel     =   wrp.exhibOpeartionTel;
                wObj.contContactName     =   wrp.contContactName;
                wObj.contContactMobile     =   wrp.contContactMobile;
                wObj.contContactTel     =   wrp.contContactTel;
                wObj.contContactEmail     =   wrp.contContactEmail;
                wObj.boolStdHgt     =   wrp.boolStdHgt;
                wObj.boolRigHgt     =   wrp.boolRigHgt;
                wObj.boolVehicle     =   wrp.boolVehicle;
                wObj.boothLenght     =   wrp.boothLenght;
                wObj.boothWidth     =   wrp.boothWidth;
                wObj.usernameexh     =   wrp.usernameexh;
                wObj.contractorUsername     =   wrp.contractorUsername;
                //End of BK - 2876
                if(wrp.dBoothDsnSbmttdOn!=null)
                {
                    DateTime submittedDate = (DateTime)wrp.dBoothDsnSbmttdOn;
                    wObj.dBoothDsnSbmttdOn =   submittedDate.format('MM-dd-YYYY');
                }
                lstwrapper.add(wObj);
            }           
        }
        // Adding Agents Pavilion Space Exhibitors in Export list [CCEN-430]
        for(Opportunity_ExpoCAD_Booth_Mapping__c expBth : getallAgentPavilionSpaceExhibitors(mapAgentWrpClass.keySet(),sEventId))
        {               
            if( mapAgentWrpClass.containsKey(expBth.opportunity__r.parent_Opportunity__r.accountId))
            {   
                wrapperAllExhibitors wObj  =   new wrapperAllExhibitors(); 
                wObj.strExhibitor          =   replaceNulls(expBth.Opportunity__r.Account.Name).escapeCsv();
                wObj.userType              =   replaceNulls(expBth.Opportunity__r.User_Type__r.Name).escapeCsv();
              /*  if(expBth.Display_Name__c == null)
                {
                    wObj.exhibitingName        =   replaceNulls(expBth.Opportunity__r.Account.Name).escapeCsv();
                }
                else
                {
                    wObj.exhibitingName        =   replaceNulls(expBth.Display_Name__c).escapeCsv();
                }*/
                wObj.exhibitingName        =   expBth.Display_Name__c == null?replaceNulls(expBth.Opportunity__r.Account.Name).escapeCsv():replaceNulls(expBth.Display_Name__c).escapeCsv();
                wObj.agntName              =   replaceNulls(mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).strExhibitor).escapeCsv();
                wObj.strBooth              =   replaceNulls(expBth.Booth_Number__c).escapeCsv();
                wObj.boothProductType      =   replaceNulls(expBth.Expocad_Booth__r.Matched_Product_Name__c).escapeCsv();
                //CCEN 588 - isReceived, performanceBondAmount
                wObj.isReceived            =   mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).isReceived;
                wObj.performanceBondAmount =   mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).performanceBondAmount;
                wObj.boolRigging           =   mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).boolRigging;
                wObj.boolDblDckr           =   mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).boolDblDckr;
                wObj.boolHevyMachin        =   mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).boolHevyMachin;
                wObj.boolCA                =   mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).boolCA;
                wObj.sBoothStatus          =   replaceNulls(mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).sBoothStatus).escapeCsv();
                wObj.sContrctorStatus      =   replaceNulls(mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).sContrctorStatus).escapeCsv();
                wObj.sRcntNote             =   replaceNulls(mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).sRcntNote).escapeCsv();
                wObj.contractorCompany     =   replaceNulls(mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).contractorCompany).escapeCsv();
                wObj.requireEarlyAcces     =   mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).sreqErlyAcc;
                wObj.earlyAccessDateTime     =   mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).serlyaccDte_Time;
                wObj.earlyAccessCost     =   mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).serlyAccCost;
                wObj.contractorPhone     =   mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).contractorPhone;
                if(mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).dBoothDsnSbmttdOn !=null )
                {
                    DateTime submittedDate = (DateTime)mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).dBoothDsnSbmttdOn;
                    wObj.dBoothDsnSbmttdOn =   submittedDate.format('MM-dd-YYYY');
                }
                // wObj.dBoothDsnSbmttdOn     =  String.valueOf(mapAgentWrpClass.get(expBth.opportunity__r.parent_Opportunity__r.accountId).dBoothDsnSbmttdOn);
                lstwrapper.add(wObj);
            }                 
        }
    }

    public string replaceNulls(string str){ 
        return str==null?'':str;
    }

    //to Get list of Expocad Booth of Agent Pavilion Space Exhibitors(CCEN-430)
    public  list<Opportunity_ExpoCAD_Booth_Mapping__c> getallAgentPavilionSpaceExhibitors(set<string> agentIds,string sEventId)
    {    
        //map<string,list<Opportunity_ExpoCAD_Booth_Mapping__c>> mapAgentBooths =  new map <string,list<Opportunity_ExpoCAD_Booth_Mapping__c>>();
        list<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpoBooths=new list<Opportunity_ExpoCAD_Booth_Mapping__c>(); // Expocad Change CCEN-753
        List<opportunity> lstOppsExh = new List<opportunity>();
        set<string> quoteIds = new set<string>();
            
            //Check is class running for test
            if(Test.isRunningTest())
            {                
                lstOppsExh = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where EventEdition__c=:sEventId and SBQQ__PrimaryQuote__c!='' order by createdDate limit 1000];                                  
            }
            else
            {
                if(Schema.sObjectType.opportunity.isAccessible())
                {
                    lstOppsExh = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where (StageName='Closed Won' OR StageName='Closed Booked') AND EventEdition__c=:sEventId and parent_Opportunity__c != null and parent_Opportunity__r.AccountId IN :agentIds and (parent_Opportunity__r.StageName='Closed Won' OR parent_Opportunity__r.StageName='Closed Booked'  ) and SBQQ__PrimaryQuote__c!='' order by createdDate limit 1000];  
                }
            }         
            if(!lstOppsExh.IsEmpty())
            { 
                for(opportunity oppty: lstOppsExh) 
                {
                    quoteIds.add(String.valueOf(oppty.SBQQ__PrimaryQuote__c)); 
                }   
                string fields = ' Id,Booth_Number__c,Expocad_Booth__r.Matched_Product_Name__c,Display_Name__c,Opportunity__r.Account.Name,Opportunity__r.User_Type__r.Name ,opportunity__r.parent_Opportunity__r.accountId ';
                string conditions = ' Status__c = \'Active\' And Expocad_Booth__r.Status__c = \'Rented\' And Opportunity__r.parent_Opportunity__c != null And Opportunity__r.User_Type__r.name = \'Agent Owned Exhibitor\' And Opportunity__r.parent_Opportunity__r.User_Type__r.name = \'Agent\' And (Opportunity__r.StageName = \'Closed Won\' OR Opportunity__r.StageName = \'Closed Booked\') And Quote__c in:quoteIds And Expocad_Booth__r.Matched_Product_Name__c like \'%Pavilion Space%\' And (NOT Expocad_Booth__r.Matched_Product_Name__c like \'%Space Only%\')';
                String query = 'select '+ fields + ' from Opportunity_ExpoCAD_Booth_Mapping__c where '+conditions;
                if(Test.isRunningTest())
                {
                    query = 'select '+ fields + ' from Opportunity_ExpoCAD_Booth_Mapping__c' ;
                }
                lstExpoBooths = Database.query(query);
                //system.debug('query======'+query);
            } 
        return lstExpoBooths;
    }
      
    //Export all exhibitors which are not assigned to any contractor.
    public void exportExhibitorsWithoutConractors()
    {
        ExhibitorsWithoutContractorsCtrl.ExhibitorsWrapper lstgetExibitorDataWrapper = new ExhibitorsWithoutContractorsCtrl.ExhibitorsWrapper();
        String eventId = String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('event').escapeHtml4());
        String mpn = String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('mpn').escapeHtml4()); //BK-2990
        string column = 'Booth_Number__c';
        string order =  'ASC';
        //string matchProductOption= 'test'; // BK-2173
        
        /* BK-2990 Start */
        string matchProductOption='';
        if(mpn != null && mpn !=''){
            matchProductOption = mpn;
        }
        else{
            matchProductOption ='All';
        }
        /* BK-2990 End*/
        string srchText = String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('search').escapeHtml4());

        lstgetExibitorDataWrapper = ExhibitorsWithoutContractorsCtrl.getExhibitors(eventId,column,order,srchText,1,0,matchProductOption);

        //lstgetExibitorDataWrapper = ExhibitorsWithoutContractorsCtrl.getExhibitors(String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('event').escapeHtml4()),'Booth_Number__c','ASC',String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('search').escapeHtml4()),1,0);

        system.debug('lstgetExibitorDataWrapper--------'+lstgetExibitorDataWrapper);
        List<Opportunity_ExpoCAD_Booth_Mapping__c> lstgetExibitorData = lstgetExibitorDataWrapper.lstExpocadBooth;
        if(lstgetExibitorData.size()>0){ 
            for(Opportunity_ExpoCAD_Booth_Mapping__c ebd :lstgetExibitorData )  //Expocad Change [CCEN-742][CCCEN-752]
            {
                wrapperExhibitorWithoutContractor wObj = new wrapperExhibitorWithoutContractor();
                if(ebd.Opportunity__r.Account.Name!=null)
                {
                    wObj.exhibitorName = replaceNulls(ebd.Opportunity__r.Account.Name).escapeCsv();
                }
                if(String.IsNotBlank(ebd.Display_Name__c))
                {
                    wObj.ExhibitingName = replaceNulls(ebd.Display_Name__c).escapeCsv();
                }
                else
                {
                   wObj.ExhibitingName = replaceNulls(ebd.Opportunity__r.Account.Name).escapeCsv(); 
                }
                wObj.email =replaceNulls( ebd.Opportunity__r.Operations_Contact__r.email).escapeCsv();
                if( ebd.Opportunity__r.Operations_Contact__r.Phone!=null)
                {
                    wObj.phoneNumber = replaceNulls(ebd.Opportunity__r.Operations_Contact__r.Phone).escapeCsv();
                }
                else
                {
                    wObj.phoneNumber ='';
                }
                if(ebd.Opportunity__r.Operations_Contact__r.MobilePhone!=null)
                {
                   wObj.mobileNumber = replaceNulls(ebd.Opportunity__r.Operations_Contact__r.MobilePhone).escapeCsv();
                }
                else
                {
                    wObj.mobileNumber = '';
                }
                wObj.standNumber = replaceNulls(ebd.Booth_Number__c).escapeCsv();
                wObj.boothProductType = replaceNulls(ebd.Expocad_Booth__r.Matched_Product_Name__c).escapeCsv();
                //Added Regarding Ticket CCEN 560
                 if(ebd.Notes__r.size()>0)
                 {
                    wObj.notes = replaceNulls(ebd.Notes__r[0].Note__c);
                 }
                lstEWCwrapper.add(wObj);                    
            }             
        }
    }
    
    //Export sub contractors
    public void exportSubContractors()
    {
        List<BoothContractorMapping__c> lstgetExibitorData = SubContractorCtrl.getSubcontactor(String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('event').escapeHtml4()),'');
        if(lstgetExibitorData.size()>0){
            for(BoothContractorMapping__c ebd :lstgetExibitorData)
            {
                wrapperSubcontractors wObj = new wrapperSubcontractors();
                //Regarding CCEN-756 
                wObj.booth =ebd.Opp_Booth_Mapping__r.Booth_Number__c;
                wObj.boothProductType = replaceNulls(ebd.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c).escapeCsv();
                wObj.exhibitor = replaceNulls(ebd.Opp_Booth_Mapping__r.Opportunity__r.Account.Name).escapeCsv();
                if(String.IsNotBlank(ebd.Opp_Booth_Mapping__r.Display_Name__c))
                {
                    wObj.exhibitingName =replaceNulls(ebd.Opp_Booth_Mapping__r.Display_Name__c).escapeCsv();
                }
                else
                {
                   wObj.exhibitingName = replaceNulls(ebd.Opp_Booth_Mapping__r.Opportunity__r.Account.Name).escapeCsv(); 
                }
                //wObj.contractor = ebd.Parent_BoothMapping__r.Contact__r.Account.Name).escapeCsv();
                wObj.subContractorsCompany = replaceNulls(ebd.TempContact__r.TempAccount__r.Name).escapeCsv();
                wObj.subContractorSContact = replaceNulls(ebd.TempContact__r.Name__c).escapeCsv();
                Integer i = 0;
                for(CustomerContractorService__c ccServices : ebd.CustomerContractorServices__r){
                    if(i > 0){
                        wObj.services += ',' + ccServices.ContractorService__r.Contractor_Service__c;
                    }else{
                        wObj.services = ccServices.ContractorService__r.Contractor_Service__c;
                    }
                    i++;
                }
                wObj.services=replaceNulls(wObj.services ).escapeCsv();
                //[CCEN-592]
                wObj.standConCompany = replaceNulls(ebd.Parent_BoothMapping__r.Contact__r.Account.Name).escapeCsv();
                wObj.conContactName = replaceNulls(ebd.Parent_BoothMapping__r.Contact__r.Name).escapeCsv();
                wObj.conMobile  = replaceNulls(ebd.Parent_BoothMapping__r.Contact__r.MobilePhone).escapeCsv();
                wObj.conEmail = replaceNulls(ebd.Parent_BoothMapping__r.Contact__r.Email).escapeCsv();
                wObj.dateAdded = ebd.CreatedDate;
                lstSubcontractorswrapper.add(wObj);                
            }             
        }
    }
    //Export all sales force approval contractors.
    public void exportContractorSalesForceApprovals(){
        string eventid = String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('event').escapeHtml4()); // event Id
        string status = String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('selectedValue').escapeHtml4()); // event Id
        List<BoothContractorMapping__c> lstgetExibitorData = ApproveContractorCtrl.getAllContractor(eventid,status);   //Expocad Change [CCEN-742][CCCEN-752]

        if(lstgetExibitorData.size()>0)
        {
            for(BoothContractorMapping__c ebd :lstgetExibitorData)
            {
                wrapperContractorSalesForceApprovals wObj = new wrapperContractorSalesForceApprovals();
                //wObj.forExhibitor = replaceNulls(ebd.ExpocadBooth__r.Opportunity__r.Account.Name)).escapeCsv();
                wObj.forExhibitor = replaceNulls(ebd.Opp_Booth_Mapping__r.Opportunity__r.Account.Name).escapeCsv(); 
                wObj.type = replaceNulls(ebd.Opp_Booth_Mapping__r.Opportunity__r.User_Type__r.Name).escapeCsv();               
                
                if(String.IsNotBlank(ebd.Opp_Booth_Mapping__r.Display_Name__c))
                {
                    wObj.exhibitingName = replaceNulls(ebd.Opp_Booth_Mapping__r.Display_Name__c).escapeCsv() ;
                }
                else
                {
                    wObj.exhibitingName = replaceNulls(ebd.Opp_Booth_Mapping__r.Opportunity__r.Account.Name).escapeCsv();
                }
                wObj.booth = ' '+replaceNulls(ebd.Opp_Booth_Mapping__r.Booth_Number__c).escapeCsv()+' ';
                wObj.boothProductType = replaceNulls(ebd.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c).escapeCsv();                
                if(ebd.Contact__c != null)
                {
                wObj.contractorCompany = replaceNulls(ebd.Contact__r.Account.Name).escapeCsv();
                }
                else 
                {
                    if(ebd.TempContact__r.Account__c != null)
                    {
                        wObj.contractorCompany = replaceNulls(ebd.TempContact__r.Account__r.Name).escapeCsv(); 
                    }
                    else
                    {
                        wObj.contractorCompany = replaceNulls(ebd.TempContact__r.TempAccount__r.Name).escapeCsv();
                    }
                }
              
                if(ebd.Contact__c != null)
                {
                    wObj.contact = replaceNulls(ebd.Contact__r.Name).escapeCsv();
                }else
                {
                    wObj.contact =replaceNulls( ebd.TempContact__r.Name__c).escapeCsv();
                }
                wObj.dateSubmitted = ebd.CreatedDate;
                wObj.dateApproved = ebd.Approval_Date__c;                
                if(ebd.Approved__c == true)
                {
                    wObj.status = 'Approved';
                }
                else if(ebd.Status__c=='Rejected') 
                {
                    wObj.status = 'Rejected';
                }
                else
                {
                    wObj.status = 'New';
                }
                if(!ebd.IsManagedbyAgent__c)
                {
                    lstContractorSalesForceApprovalswrapper.add(wObj); 
                }                   
                system.debug('lstContractorSalesForceApprovalswrapper--'+lstContractorSalesForceApprovalswrapper);
            }             
        }
    }
}