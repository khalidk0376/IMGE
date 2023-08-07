/**
* Created by     : Girikon(Divaker)
* Created On     : 03/30/2018
* @description   : This class provides following functionalities:
*                  Allow ops admin to approve,reject,delete the contractor's account or contact creation request by exhibitor.
* Test Class     : ApproveContractorCtrl_Test (86%)
*
* Modification Log----- 
* Modified by    : Girikon(Sunil)[CCEN-787 (May 29 2019),CCEN-184 (Aug 29 2018),CCEN-360 (Sept 26 2018),CCEN-589 (Jan 10 2019)],Girikon(Prashant)[CCEN-315(Sept 25 2018),CCEN-326(Oct 3 2018),CCEN-411(Oct 30 2018),CCEN-593 (Jan 21 2019), CCEN-656 (Feb 4 2019), CCEN-684 (Feb 27 2019 ), CCEN-688 (Mar 15 2019), CCEN-682(Mar 22 2019)],Girikon(Ashish)[CCEN-314 (Sept 28 2018),CCEN-374 (Oct 15 2018), CCEN-327 (Oct 29 2018), CCEN-412 (Nov 9 2018),CCEN-457 (Nov 13 2018), CCEN-430 (Dec 17 2018), CCEN-585 (Jan 8 2019), CCEN-699 (march 5 2019),CCEN-470 (march 5 2019), CCEN-527 (march 4 2019),CCEN-421(march 15 2019),CCEN-742(April 1 2019),CCEN-753(April 12 2019)],[Girikon(Ashish) CCEN-591(June 03 2019),
[Girikon(Rajeev) BK-2150(Sep 05 2019),Girikon(Rajeev) BK-2172(Sep 11 2019,)Bk-2349(Sep 22 2019)BK-2346(Sep 30 2019), BK-2969(Nov 22 2019)], [Girikon(Garima) CCEN-231(Oct 12 2019),Girikon(Himanshu [BK-2876 15 Dec 2019]],
Aishwarya [BK-10223] 23 Dec 2020, **/

public without sharing class ApproveContractorCtrl 
{
    public class StandDesignStatus
    {
        @AuraEnabled public String key;      
        @AuraEnabled public Integer value; 
    }
    @AuraEnabled
    public static List<StandDesignStatus>  getDesignationInfo(String sEventId)
    {
        List<StandDesignStatus> sdsObjList = new List<StandDesignStatus>();    
        // Added Matched_Product_Name__c to show the count in Designation info of only those which have the substring 'Space Only' in it. [CCEN-593]
        StandDesignStatus obj = new StandDesignStatus();
        obj.key='Total Number of Exhibitors';  // EXPOCAD Change CCEN-753
        String totalExhibitors = 'select count() from Opportunity_ExpoCAD_Booth_Mapping__c where Status__c =  \'Active\' And Expocad_Booth__r.Status__c = \'Rented\' And Opportunity__r.EventEdition__c = \''+String.escapeSingleQuotes(sEventId)+'\' And Opportunity__c != null And Opportunity__r.Operations_Contact__c != null  And (Opportunity__r.StageName = \'Closed Won\' or Opportunity__r.StageName = \'Closed Booked\') And (Opportunity__r.User_Type__r.name = \'Exhibitor\' or Opportunity__r.User_Type__r.name = \'Agent Owned Exhibitor\' )  And Expocad_Booth__r.Matched_Product_Name__c LIKE \'%'+ 'Space Only'+'%\'';        
        obj.value=Database.countQuery(totalExhibitors);
        sdsObjList.add(obj); 
        
        StandDesignStatus obj2 = new StandDesignStatus();
        obj2.key='Exhibitors without Contractors';  // EXPOCAD Change CCEN-753
        String exhWithoutContractors = 'select count() from Opportunity_ExpoCAD_Booth_Mapping__c where  Status__c =  \'Active\' And Expocad_Booth__r.Status__c = \'Rented\' And Opportunity__r.EventEdition__c = \''+String.escapeSingleQuotes(sEventId)+'\' And Opportunity__c != null And Opportunity__r.Operations_Contact__c != null  And (Opportunity__r.StageName = \'Closed Won\' or Opportunity__r.StageName = \'Closed Booked\') And (Opportunity__r.User_Type__r.name = \'Exhibitor\' or Opportunity__r.User_Type__r.name = \'Agent Owned Exhibitor\' ) And id not In (select Opp_Booth_Mapping__c from BoothContractorMapping__c  where Event_Edition__c =\''+String.escapeSingleQuotes(sEventId)+'\' and (Opp_Booth_Mapping__r.Opportunity__c!= NULL and Opp_Booth_Mapping__r.Expocad_Booth__r.status__c = \'Rented\' And Opp_Booth_Mapping__r.Status__c =  \'Active\' )AND (Contact__c != NULL AND Approved__c = TRUE)) And Expocad_Booth__r.Matched_Product_Name__c LIKE \'%'+ 'Space Only'+'%\'';
        obj2.value=Database.countQuery(exhWithoutContractors);         
        sdsObjList.add(obj2);
        
        StandDesignStatus obj3 = new StandDesignStatus();
        obj3.key='All Assigned Contractors';    // EXPOCAD Change CCEN-753
        String allAssignContractor = 'Select count() from BoothContractorMapping__c where ((Opp_Booth_Mapping__r.Opportunity__c!= NULL and Opp_Booth_Mapping__r.Status__c =  \'Active\' And Opp_Booth_Mapping__r.Expocad_Booth__r.status__c = \'Rented\') OR (IsManagedbyAgent__c = true And Opp_Booth_Mapping__c = null)) and  Event_Edition__c=\''+String.escapeSingleQuotes(sEventId)+'\' and (Contact__c != NULL AND Approved__c = TRUE) And Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c LIKE \'%'+ 'Space Only'+'%\'';         
        obj3.value=Database.countQuery(allAssignContractor);         
        sdsObjList.add(obj3); 
        
        return sdsObjList; 
    } 
    @AuraEnabled
    public static Map<String, String> getAggregateResult(String sEventId) 
    {
        Map<String, String> sdsObjMap = new Map<String, String>();
        AggregateResult []arObjList = new list<AggregateResult>();
        if(Schema.sObjectType.BoothContractorMapping__c.isAccessible()) // EXPOCAD Change CCEN-753
        {
            arObjList = [SELECT count(id), Booth_Design_Status__c FROM BoothContractorMapping__c WHERE Event_Edition__c=:sEventId and ((Opp_Booth_Mapping__r.Opportunity__c!= NULL and Opp_Booth_Mapping__r.status__c = 'Active' And Opp_Booth_Mapping__r.Expocad_Booth__r.status__c = 'Rented' ) or (IsManagedbyAgent__c = true And ExpocadBooth__c = null)) AND (Contact__c != NULL AND Approved__c = TRUE) group by Booth_Design_Status__c];
        }        
        String status='';
        //List<String> customStr = new List<string>();
        for(AggregateResult arObj : arObjList)
        {
            status = String.valueOf(arObj.get('Booth_Design_Status__c'));
            if(status!=null && status!='')
            {
                sdsObjMap.put(status, String.valueOf(arObj.get('expr0')));
            }
        }
        return sdsObjMap;
    }  
    @AuraEnabled 
    // Stand Contractor..Pagination required to show the records [CCEN-589 Jan 10 2019]
    public static ExhibitorsWrapper getAllFilterContractor(String boothDesignStatus,string sStatus, String riggedOption,String searchTearm,Boolean bDblDckrStatus, Boolean bCA,Boolean pbs,Boolean pbns,Boolean sme,Boolean isAllAgt,Boolean isAgtPvnSpc,string sEventId,string column, string order,Decimal pageNumber, Decimal pageSize)
    {
        ExhibitorsWrapper exhibitObj = ApproveContractorExtensionCntr.getAllFilterContractorExtn(boothDesignStatus, sStatus, riggedOption, searchTearm, bDblDckrStatus, bCA, pbs, pbns, sme, isAllAgt, isAgtPvnSpc, sEventId, column, order, pageNumber, pageSize);
        return exhibitObj;
    }
    //Wrapper Class For Exhibitors DataTable  
    public class ExhibitorsWrapper
    {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public list<wrapperClass> lstWrapper {get;set;}
        public ExhibitorsWrapper()
        {            
            lstWrapper=new list<wrapperClass>();
        }
    } 
    @AuraEnabled //This Method Returns Map of all Stand Details of Agent's  Pavilion Space Stand Detail [CCEN-430]
    public static  Map<String,Stand_Detail__c> getAllAgentPavilionSpaceStandDetail(String sEventID)
    {
        Map<String,Stand_Detail__c> mapAgentStndDetail  = new  Map<String,Stand_Detail__c> ();
        for(Stand_Detail__c stndDtl :[select id,Amount__c,Is_Heavy_Machinery__c,Stand_Height__c,Rigging_Height__c,IsReceived__c ,Early_Access_Date_Time__c,Early_Access_Cost__c,Require_Early_Access__c,Agent_Account__c from Stand_Detail__c where Agent_Account__c != null And ExpocadBooth__c = null And Event_Edition__c =:sEventID])
        {
            mapAgentStndDetail.put(stndDtl.Agent_Account__c,stndDtl);
        }   
        return  mapAgentStndDetail;                                
    } 
    @AuraEnabled //This Method Returns Map of all Stand Details of Agent's  Pavilion Space Stand Design [CCEN-430]
    public static  Map<String,Stand_Design__c> getAllAgentPavilionSpaceStandDesign(String sEventID)
    {
        Map<String,Stand_Design__c> mapAgentStndDesign = new Map<String,Stand_Design__c>();
        for(Stand_Design__c stndDsn :[select id,Booth_Design_Submitted_On__c,Submitted_to_Venue_On__c, Contractor_Agreement_CA__c,Agent_Account__c ,Booth_Design_Status__c from Stand_Design__c where Agent_Account__c != null And ExpocadBooth__c = null And Event_Edition__c =:sEventID])
        {
            mapAgentStndDesign.put(stndDsn.Agent_Account__c,stndDsn);
        }      
        return  mapAgentStndDesign;                                
    } 
    @AuraEnabled // This Method getting the Approval Request [CCEN-430] 
    public static List<BoothContractorMapping__c> getAllContractor(String sEventId, string sStatus)
    {         
        List<BoothContractorMapping__c> lstBoothMap = new List<BoothContractorMapping__c>();
        if(String.isNotBlank(sEventId)&&string.isNotBlank(sStatus))
        {
            String query = '';
            String condition = 'and Parent_BoothMapping__c =\'\' And Event_Edition__c =:sEventId' ;
            if(sStatus == 'Rejected')
            {
                condition = condition+' And Status__c = \'Rejected\' and Approved__c=false ' ;
            }
            if(sStatus == 'Approved')
            {
                condition = condition+' And Approved__c = true And Status__c !=  \'Rejected\'' ;
            }
            if(sStatus == 'New') // on firstload New Request 
            {
                condition = condition+' And Approved__c = false And Status__c !=  \'Rejected\'' ; 
            }
            
            String fields  = 'Id,Opp_Booth_Mapping__r.Booth_Number__c,Opp_Booth_Mapping__r.Opportunity__r.Account.Name,Opp_Booth_Mapping__r.Display_Name__c,Opp_Booth_Mapping__r.Opportunity__r.User_Type__r.Name,Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c,Contact__r.Name,Name,Contact__r.Account.Name,Contact__r.Account.Phone, IsRigging__c,IsDoubleDecker__c, Booth_Design_Status__c, Event_Edition__r.Name,TempContact__r.Account__c,Status__c, TempContact__c,CreatedBy.Contact.Account.Name,CreatedDate, Approval_Date__c,Approved__c,TempContact__r.Account__r.Name,TempContact__r.TempAccount__r.Name,TempContact__r.Name__c,IsManagedbyAgent__c,Is_Self_Managed__c,Agent_Contact__r.AccountId,Agent_Contact__r.account.Name,Stand_Height__c,Rigging_Height__c ';
            query = 'select '+fields+' from BoothContractorMapping__c WHERE ((Opp_Booth_Mapping__r.Opportunity__c!= NULL And Opp_Booth_Mapping__r.Expocad_Booth__c != NULL And Opp_Booth_Mapping__r.Status__c = \'Active\' And Opp_Booth_Mapping__r.Expocad_Booth__r.status__c = \'Rented\') OR (IsManagedbyAgent__c = true And Opp_Booth_Mapping__c = null)) '+condition+'  ORDER BY CreatedDate DESC limit 500';
            lstBoothMap  =  Database.query(query);  
        }  
        return lstBoothMap;  
    }
    @AuraEnabled //Query single BoothContractorMapping__c record on the basis of BoothContractorMapping__c Id 
    public static List<BoothContractorMapping__c> getSingleApprovalRequest(Id singleId)
    {
        List<BoothContractorMapping__c> singleBooth = new List<BoothContractorMapping__c>();
        singleBooth = StandContractorUtils.getSingleContractorDetail(singleId);
        return singleBooth;
    }  
    @AuraEnabled //Query all the BoothContractorMapping__c records
    public static List<BoothContractorMapping__c> getContractorList() 
    {
        return [SELECT id, ExpocadBooth__c, ExpocadBooth__r.Booth_Number__c,IsRigging__c,IsDoubleDecker__c,Booth_Design_Status__c, Contact__c, TempContact__r.TempAccount__r.Id,  TempContact__r.TempAccount__r.Name, TempContact__r.Name__c, TempContact__r.Account__r.Name, TempContact__c, Contact__r.Name, contact__r.Account.Name,contact__r.Account.phone,contact__r.AccountId, status__c, createdby.contact.account.name FROM BoothContractorMapping__c WHERE (Contact__c != NULL AND Approved__c = TRUE) OR Status__c = 'Rejected'];
    } 
    // wrapper class to return data from BoothContractorMapping__c, Stand_Detail__c, Stand_Design__c and Note__c
    public class WrapperClass
    {        
        @AuraEnabled public ID sId; //BoothContractorMapping__c's ID
        @AuraEnabled public string strExhibitor; //BoothContractorMapping__c's CreatedBy.Contact.Account.Name
        @AuraEnabled public string strBooth; //BoothContractorMapping__c's ExpocadBooth__r.Booth_Number__c
        @AuraEnabled public string contractorCompany;//BoothContractorMapping__c's Contact__r.Account.Name or TempContact__r.TempAccount__r.Name or TempContact__r.Account__r.Name
        @AuraEnabled public boolean boolRigging; //Stand_Detail__c's IsRigging__c
        @AuraEnabled public boolean boolDblDckr; //Stand_Detail__c's IsDoubleDecker__c
        @AuraEnabled public boolean boolHevyMachin; //Stand_Detail__c's Is_Heavy_Machinery__c
        @AuraEnabled public Date dBoothDsnSbmttdOn; //Stand_Design__c's Booth_Design_Submitted_On__c
        @AuraEnabled public Date dSubToVenueOn; //Stand_Design__c's Submitted_to_Venue_On__c
        @AuraEnabled public boolean boolCA; //Stand_Design__c's Contractor_Agreement_CA__c
        @AuraEnabled public string sBoothStatus; //Stand_Design__c's Booth_Design_Status__c
        @AuraEnabled public string sContrctorStatus; //BoothContractorMapping__c's Status__c
        @AuraEnabled public string performanceBondAmount; //Stand Design Performace bond amount 
        @AuraEnabled public string sContactsAccountName; //BoothContractorMapping__c's Contact__r.Account.Name
        @AuraEnabled public string sRcntNote; //Note__c's Note__c
        @AuraEnabled public boolean isSelfManaged; //Note__c's Note__c
        @AuraEnabled public String riggeringOptions; //Riggering_Options__c field of Stand Detail object
        @AuraEnabled public Boolean isReceived; //IsReceived__c field of Stand Detail object
        @AuraEnabled public String contractorEmail;        
        @AuraEnabled public String exhibitorEmail; 
        @AuraEnabled public String exhibitorPhone; 
        @AuraEnabled public String exhibitingName; //Riggering_Options__c field of Stand Detail object
        @AuraEnabled public String boothProductType;
        @AuraEnabled public String userType;
        @AuraEnabled public boolean isManagedbyAgent;
        @AuraEnabled public String agentAccountID;
        @AuraEnabled public String agentName;  // Agent Name based on Differnt User type of Booth's opp. [CCEN-527]
        @AuraEnabled public boolean sreqErlyAcc; 
        @AuraEnabled public datetime  serlyaccDte_Time; 
        @AuraEnabled public decimal serlyAccCost;        
        @AuraEnabled public String contractorPhone;  //BoothContractorMapping__c's Contact__r.Account.Phone
        @AuraEnabled public string exhibOpeartionCon;//BoothContractorMapping__c's Operation_Contact__r.Name
        @AuraEnabled public string exhibOpeartionEmail;//BoothContractorMapping__c's Operation_Contact__r.Email
        @AuraEnabled public string exhibOpeartionMobile;//BoothContractorMapping__c's Operation_Contact__r.Phone
        @AuraEnabled public string exhibOpeartionTel;//BoothContractorMapping__c's Operation_Contact__r.MobilePhone
        @AuraEnabled public string contContactName;//BoothContractorMapping__c's Contact__r.Name
        @AuraEnabled public string contContactMobile;//BoothContractorMapping__c's Contact__r.Phone
        @AuraEnabled public string contContactTel;//BoothContractorMapping__c's Contact__r.MobilePhone
        @AuraEnabled public string contContactEmail;  //BoothContractorMapping__c's Contact__r.Email     
        @AuraEnabled public decimal boolStdHgt; //Stand_Detail__c's Stand_Height__c
        @AuraEnabled public decimal boolRigHgt; //Stand_Detail__c's Rigging_Height__c
        @AuraEnabled public boolean boolVehicle;//Stand_Detail__c's Is_Vehicles__c
        @AuraEnabled public string boothdimensions;//Length and Width
        @AuraEnabled public string boothLenght;//Boothdimesion - Length 
        @AuraEnabled public string boothWidth;//Boothdimesion -  Width
        @AuraEnabled public string usernameexh;//BoothContractorMapping__c's Operation_Contact__r.Username
        @AuraEnabled public string contractorUsername;//BoothContractorMapping__c's Operation_Contact__r.Username
         
        
        public wrapperClass(){
            
            strExhibitor='';
            strBooth='';
            contractorCompany='';            
            boolRigging=false;
            boolDblDckr=false;
            boolHevyMachin=false;
            boolCA=false;
            sBoothStatus='';
            performanceBondAmount = '0';
            sContrctorStatus='';
            sContactsAccountName='';
            sRcntNote='';
            isSelfManaged=false;
            riggeringOptions='';
            isReceived=false;
            sreqErlyAcc=false;
            isManagedbyAgent=false;
            agentAccountID =''; 
            agentName ='';            
            exhibOpeartionCon='';
            exhibOpeartionEmail='';
            exhibOpeartionMobile='';
            exhibOpeartionTel='';
            contContactName='';
            contractorPhone='';  
            contContactMobile='';
            contContactTel='';
            contContactEmail=''; 
            boolVehicle=false; 
            boothdimensions = '';
            boothLenght= ''; 
            boothWidth='';
            usernameexh='';
            contractorUsername='';
           

        }
    }
    //Added this method for updating temp account and contact before approval by Ops Admin[CCEN-682]
    @AuraEnabled
    public static string updateTmpAccountContact(Id sIds, List<BoothContractorMapping__c> singleBth)
    {   
        String message = ApproveContractorExtensionCntr.updateTmpAccountContactExtn(sIds,singleBth);
        return message;
    }  
    @AuraEnabled
    public static string getapproval(Id sIds,string requestedBy)
    {   
        string msg = StandContractorUtils.approveStandContractor(sIds,requestedBy);
        return msg;
    }
    @AuraEnabled
    public static string rejectContarctor(Id sIds,string notes, Boolean sendMail)
    {    
        string msg = ApproveContractorExtensionCntr.rejectContarctorExtn(sIds,notes,sendMail);
        return msg;
    }    
    //return Stand_Detail__c records on the basis of AccountID and sBoothId [Used in StandDetails.cmp]
    @AuraEnabled
    public static List<Stand_Detail__c> getStandDetailsCtr( Id sAccId,string sBthID,string sEventId,string agentId)
    {                               
        return StandContractorUtils.getSingleStandDetail(sBthID,sAccId,sEventId,agentId);
    }
    
    //return Stand_Design__c records on the basis of AccountID and sBoothId [Used in StandDesignStatus.cmp]
    @AuraEnabled
    public static List<Stand_Design__c> getStandDesignCtr( Id sAccId, string sBthID,string sEventId,string agentId)
    {       
        return StandContractorUtils.getSingleStandDesign(sBthID,sAccId,sEventId,agentId);
    }  
    //On the click of submit button from StandDesign.cmp, it will update current date on the Stand_Design__c's Booth_Design_Submitted_On__c
    @AuraEnabled
    public static List<Stand_Design__c> submitDesignCtr( Id sAccId)
    {  
        List<Stand_Design__c> lstStndDsign=[SELECT Id,File_Name__c,AttachmentId__c,Stand_Type__c,Booth_Design_Status__c from Stand_Design__c WHERE Account__r.Id=:sAccId];
        List<Stand_Design__c> lstFinalSDsignforUpdate = new List<Stand_Design__c>();
        for(Stand_Design__c objStDesign: lstStndDsign)
        {            
            lstFinalSDsignforUpdate.add(objStDesign);
        }
        if(Schema.sObjectType.Stand_Design__c.IsCreateable() && Schema.sObjectType.Stand_Design__c.isUpdateable())
        {
            upsert lstFinalSDsignforUpdate;
        }        
        return lstFinalSDsignforUpdate;
    }
    //record from StandDetail.cmp will be updated
    @AuraEnabled   // Upadated code to save standDetail without PerformanceBond records [CCEN-374]
    public static string saveStandDetailCtr(Stand_Detail__c oStndDtail,string sAccId,string eEId,string sBoothId,string sBoothStatus, string boothContMappingId)
    {
        string sMessage;
        if(oStndDtail!=null )
        { 
            if(oStndDtail.id == null){
                oStndDtail.Opp_Booth_Mapping__c=sBoothId;
                oStndDtail.BoothContractorMapping__c=boothContMappingId;
                oStndDtail.Event_Edition__c = eEId;
                oStndDtail.Account__c=sAccId;
                insert oStndDtail;
            }
            else{    
                Stand_Detail__c standDetail = new Stand_Detail__c();
                if(Schema.sObjectType.Stand_Design__c.isAccessible())
                {
                    standDetail = [select id,Riggering_Options__c,Amount__c,IsReceived__c,Receipt__c,Require_Early_Access__c,Early_Access_Date_Time__c,Early_Access_Cost__c from Stand_Detail__c where id =:oStndDtail.id  ];
                }                
                oStndDtail.Amount__c = standDetail.Amount__c;
                oStndDtail.IsReceived__c = standDetail.IsReceived__c;
                oStndDtail.Receipt__c = standDetail.Receipt__c;               //[CCEN-699]
                oStndDtail.Require_Early_Access__c=standDetail.Require_Early_Access__c;
                oStndDtail.Early_Access_Date_Time__c=standDetail.Early_Access_Date_Time__c;
                oStndDtail.Early_Access_Cost__c=standDetail.Early_Access_Cost__c;
                update oStndDtail;
            }
            sMessage= 'Stand Detail has been updated and Email sent successfully';
            EmailConfirmToContractorForBoothStatus.sendEmailToContractoForBoothStatus(eEId,sAccId,sBoothStatus,sBoothId,boothContMappingId, null,oStndDtail.Agent_Account__c);
        }
        else
        {
            sMessage='Please try to save a valid Stand Detail'; 
        }
        return sMessage;
    }    
    @AuraEnabled // Upadated code to save standDetail withPerformanceBond records only [CCEN-374]
    public static string savePerformanceBond(Stand_Detail__c oStndDtail, string sAccId, string eEId,string sBoothId,string sBoothStatus)
    {
        string sMessage;
        if(oStndDtail!=null)
        {
            if(oStndDtail.id == null)
            {
                oStndDtail.Opp_Booth_Mapping__c=sBoothId;
                oStndDtail.Event_Edition__c = eEId;
                oStndDtail.Account__c=sAccId;
                insert oStndDtail;
            }
            else
            {
                Stand_Detail__c standDetail = new Stand_Detail__c();
                standDetail = [select id,IsDoubleDecker__c,IsRigging__c,Contractor_Agreement_CA__c from Stand_Detail__c where id =:oStndDtail.id  ];
                oStndDtail.IsDoubleDecker__c = standDetail.IsDoubleDecker__c;
                oStndDtail.Contractor_Agreement_CA__c = standDetail.Contractor_Agreement_CA__c;
                update oStndDtail;
            }
            sMessage= 'Details has been updated successfully';
        }
        else
        {
            sMessage='Please try to save a valid Stand Detail';
        }
        return sMessage;
    }
    //return base URL of sfdc
    @AuraEnabled
    public static String getBaseUrl () {
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        return baseUrl;
    }
    //return Email Template and Contact list to send email
    @AuraEnabled
    public static EmailConfirmToContractorForBoothStatus.wrapperClass returnStandDesignStatusData(string sAccIdDes,string sBoothStatusDes,string boothId1,string eEId1,string agentId)
    {
        EmailConfirmToContractorForBoothStatus.wrapperClass oWrpprObj=new EmailConfirmToContractorForBoothStatus.wrapperClass();// instantiate wrapperClass from EmailConfirmToContractorForBoothStatus class
        oWrpprObj=EmailConfirmToContractorForBoothStatus.captureEmailTemplate(sBoothStatusDes,eEId1,sAccIdDes,boothId1,agentId); //call captureEmailTemplate from EmailConfirmToContractorForBoothStatus.
        return oWrpprObj;
    }
    //Update Stand Design Status and Send Email
    @AuraEnabled //Added mailInCC parameter for CC email addresses[CCEN-326] & agentId [CCEN-430]    
    public static string updateRecordAndSendEmail(string sAccIdDes,string sBoothStatusDes,string boothId1,string eEId1, string sMapId ,string emailContent,string emailSubject,string mailInCC,string agentId) 
    {
        string sResultMessage = 'Email Not Sent';
        String eTemCode= EmailConfirmToContractorForBoothStatus.returnEmailTempCode (sBoothStatusDes); // calling returnEmailTempCode from EmailConfirmToContractorForBoothStatus to get the Email Template code.
        List<Stand_Design__c> lstFinalSDsignforUpdate=new List<Stand_Design__c>();
        List<DesignAttachmentType__c> listDsignAttchment= new List<DesignAttachmentType__c>();
        List<Stand_Design__c> lstStndDsign = getStandDesignCtr(sAccIdDes,boothId1,eEId1,agentId);
        List<Event_Edition_Email_Template__c> lstEvntEdition = new List<Event_Edition_Email_Template__c>();
        if(Schema.sObjectType.Event_Edition_Email_Template__c.isAccessible())
        {
            lstEvntEdition= [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eEId1 AND Email_Template_Code__c =: eTemCode];
        }        
        // update Email Content From ops Admin before sending email 
        if(lstEvntEdition!=null && lstEvntEdition.size()>0)
        {
            if((lstEvntEdition[0].Content__c != emailContent || lstEvntEdition[0].Subject__c != emailSubject )&& Schema.sObjectType.Event_Edition_Email_Template__c.isUpdateable())
            {
                lstEvntEdition[0].Content__c = emailContent; 
                lstEvntEdition[0].Subject__c = emailSubject;  // Added Subject to Update [CCEN-591]
                
                update lstEvntEdition;
            }
        }        
        if(lstStndDsign!=null && lstStndDsign.size()>0)
        {
            for(Stand_Design__c objStDesign: lstStndDsign)
            {
                objStDesign.Booth_Design_Status__c=sBoothStatusDes;
                objStDesign.BoothContractorMapping__c=sMapId;
                if(sBoothStatusDes=='Contractor Resubmit (Incomplete)')
                {
                    for(DesignAttachmentType__c objDesignAttachmentType: objStDesign.DesignAttachmentTypes__r)
                    {
                        objDesignAttachmentType.IsRejected__c=true;                        
                        listDsignAttchment.add(objDesignAttachmentType);
                    }
                } 
                else
                {
                    for(DesignAttachmentType__c objDesignAttachmentType: objStDesign.DesignAttachmentTypes__r)
                    {
                        if(objDesignAttachmentType.IsRejected__c == false)
                        {
                            objDesignAttachmentType.IsRejected__c=false;                            
                            listDsignAttchment.add(objDesignAttachmentType);
                        }                        
                    }
                }
                lstFinalSDsignforUpdate.add(objStDesign);
            }
        }
        update lstFinalSDsignforUpdate;
        if(listDsignAttchment!=null && listDsignAttchment.size()>0 && Schema.sObjectType.DesignAttachmentType__c.isUpdateable())
        {
            update listDsignAttchment;
        }       
        if(sBoothStatusDes!='No Design')
        {
            // call sendEmailToContractoForBoothStatus from EmailConfirmToContractorForBoothStatus to send Email
            EmailConfirmToContractorForBoothStatus.sendEmailToContractoForBoothStatus(eEId1,sAccIdDes,sBoothStatusDes,boothId1,sMapId, mailInCC,agentId); 
            sResultMessage='Email Successfully Sent';
        }
        return sResultMessage;
    }
    // wrapper class2    
    public class WrapperClass2
    {
        @AuraEnabled public list<BoothContractorMapping__c> lstBoothMapList; // to return the list of BoothContractorMapping__c
        @AuraEnabled public list<Stand_Detail__c> lstStandDetailList; // to return the list of Stand_Detail__c
    }
    // will return details of BoothContractorMapping__c and Stand_Detail__c on the basis of BoothContractorMapping__c.Id, Account ID and sBoothId
    @AuraEnabled
    public static wrapperClass2 findSubcontractors(string mapId, string accId, string boothId)
    {   
        wrapperClass2 oObjWrap=new wrapperClass2();
        oObjWrap = ApproveContractorExtensionCntr.findSubcontractors(mapId,accId,boothId);
        return oObjWrap;
    }  
    //Fetch Notes   
    @AuraEnabled
    public static List<Note__c> getNotes(string sBoothId,string sAccId )
    {
        User oUsr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()]; 
        List<Note__c> lstNote;
        if(sAccId!=NULL){ 
            lstNote =  [select Id,Note__c,Account__c,Opp_Booth_Mapping__c, createddate from Note__c where Account__c = :sAccId AND Opp_Booth_Mapping__c=:sBoothId order by createddate desc ];
        }
        else{
            lstNote =  [select Id,Note__c,Account__c,Opp_Booth_Mapping__c, createddate from Note__c where Opp_Booth_Mapping__c=:sBoothId order by createddate desc ];
        }
        return lstNote;
    }     
    //Save Note   
    @AuraEnabled
    public static List<Note__c> saveNote(Note__c sNote)
    {
        insert sNote;
        return getNotes(sNote.Opp_Booth_Mapping__c,sNote.Account__c);
    }
    @AuraEnabled //fetch picklist values.
    public static List<String> getPicklistValues(String objApi,String fieldName)
    { 
        List<String> lstPickvals=new List<String>();    
        lstPickvals = UtilityMethods.getPicklistValues(objApi,fieldName);
        return lstPickvals;  
    } 
    @AuraEnabled //Fetch event details  
    public static Event_Settings__c getEventDetails(String sEventId)
    {
        Event_Settings__c eventSetting = new Event_Settings__c();
        if(string.isNotBlank(sEventId) && Schema.sObjectType.Event_Settings__c.isAccessible()){
            eventSetting = [SELECT Id,Name,Max_Stand_Height_Decimal__c,Stand_Design_limit__c,Max_Rigging_Height_Decimal__c,Cont_MyExhibitor_Detail_Tab2_Max_Rigging__c,Cont_MyExhibitor_Detail_Tab_2_Max_Stand__c,Event_Edition__r.Event_Code__c FROM Event_Settings__c WHERE Event_Edition__c =:sEventId limit 1];
        }
        
        return eventSetting;
    }
    
    @AuraEnabled //Fetch Stand Design 
    public static list<Stand_Design_Attachments__c> getStandDesignAttTypes() {
        list<Stand_Design_Attachments__c> lstDesign=  [select Id, Name,Design_Category__c from Stand_Design_Attachments__c limit 100];
        return lstDesign;
    }
    
    @AuraEnabled //Save stand design file in chunks //BK-10223 Start
    public static String saveStandDesignFiles(Id sMapId, String standType,String boothId,String uploadFileType ,id accountid,string eventId,string agentId) 
    {
        Id standDesingid;
        if(uploadFileType == null)
            uploadFileType = '';
        Opportunity_ExpoCAD_Booth_Mapping__c expocadBoothlstStandDesign = new Opportunity_ExpoCAD_Booth_Mapping__c();

        // Added Opportunity__r.Operations_Contact__r.Account.Name to find Exhibitor Company Name from ExpocadBooth [CCEN-656]
        if( string.isNotBlank(boothId) && Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible())
        {
            expocadBoothlstStandDesign = [select Booth_Number__c,Opportunity__r.Account.Name from Opportunity_ExpoCAD_Booth_Mapping__c where id =: boothId limit 1];
        }        
        string exhCompName = '';
        string newExhCompName = '';
        if(string.isNotBlank(agentId) && Schema.sObjectType.Account.isAccessible())        
        {
            Account agentAccount = [select id,Name from Account where id =: agentId limit 1];
            exhCompName = agentAccount.Name;
            newExhCompName = exhCompName.replaceAll('\\s+','_'); 
            newExhCompName = newExhCompName.replaceAll('[,.]','');  
        }
        else
        {
            exhCompName = expocadBoothlstStandDesign.Opportunity__r.Account.Name;
            newExhCompName = exhCompName.replaceAll('\\s+','_'); 
            newExhCompName = newExhCompName.replaceAll('[,.]',''); 
        }
        list<Stand_Design__c> lstStandDesign = new list<Stand_Design__c>();
        if(!String.isEmpty(agentId)){
            lstStandDesign = [select Id from Stand_Design__c where Is_Rejected__c=false and Account__c=:accountid and Event_Edition__c=:eventId and Agent_Account__c=:agentId];
        }
        else{
            lstStandDesign = [select Id from Stand_Design__c where  Is_Rejected__c=false and Account__c=:accountid and Opp_Booth_Mapping__c=:boothId];
        }        
        Stand_Design__c standDesign= new Stand_Design__c();
        String finalFileName = expocadBoothlstStandDesign.Booth_Number__c +'_'+newExhCompName+'_'+uploadFileType;
        if(!String.isEmpty(agentId)){
            finalFileName ='Agent Pavilion Space'+'_'+newExhCompName+'_'+uploadFileType;
        } 
        if(lstStandDesign.size()>0){
            standDesingid=lstStandDesign[0].Id;
            lstStandDesign[0].Booth_Design_Status__c='No Design';
            if(Schema.sObjectType.Stand_Design__c.IsUpdateable())
            {          
                update lstStandDesign;
            }
        }
        else{
            standDesign.Event_Edition__c = eventId;
            standDesign.Agent_Account__c = agentId;
            standDesign.BoothContractorMapping__c=sMapId; 
            standDesign.Stand_Type__c =standType; 
            standDesign.File_Name__c=finalFileName+'.pdf'; 
            standDesign.Account__c= accountid;
            standDesign.Opp_Booth_Mapping__c=boothId;
            standDesign.Booth_Design_Status__c= 'No Design';
            standDesign.Booth_Design_Submitted_On__c=Date.Today();
            if(Schema.sObjectType.Stand_Design__c.IsCreateable()){
                insert standDesign;
                standDesingid=standDesign.Id;
            }
        } /*  // Showing a version number when uploading two PDF's with the same Attachment label [CCEN-412]*/
        string fileSearchkey = finalFileName+'%';
        list<DesignAttachmentType__c> files = new list<DesignAttachmentType__c>();
        files = [select id,File_Name__c from DesignAttachmentType__c where Stand_Design__c =:standDesingid And IsRejected__c = false And File_Name__c like :fileSearchkey ORDER BY File_Name__c];
        Integer fileSize = files.size();
        if(fileSize !=0){
            string val =  files[fileSize-1].File_Name__c;
            val = val.removeStart(finalFileName+'.0');
            val = val.removeEnd('.pdf');
            val = val.removeStart(finalFileName+'.');
            //fileSize = Integer.valueOf(val);
        }
        if(fileSize<9){ 
            finalFileName = finalFileName+'.0'+String.valueOf(fileSize+1)+'.pdf';  
        }else{
            finalFileName = finalFileName+'.'+String.valueOf(fileSize+1)+'.pdf'; 
        } 
        return standDesingid + '#' + finalFileName;
    }
     
     @AuraEnabled
     public static void prepareFileTitle(string recordId, string fileTitle, String sdRecordId, String filetype){
        ContentVersion version = [SELECT Id, ContentDocumentId, Title FROM ContentVersion Where ContentDocumentId =: recordId];
        version.Title = fileTitle;
        Update version; 
        List<DesignAttachmentType__c> listDesignAtt = new List<DesignAttachmentType__c>();
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        cdl = [Select Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where ContentDocumentId =:recordId];
        
        for(ContentDocumentLink cd : cdl){
            if(String.ValueOf(cd.LinkedEntityId).startswith('a5Q')){
                DesignAttachmentType__c newDesignAttachmentType = new DesignAttachmentType__c ();
                newDesignAttachmentType.AttachmentId__c = cd.ContentDocumentId;
                newDesignAttachmentType.File_Name__c = fileTitle;
                newDesignAttachmentType.File_Type__c = filetype; 
                newDesignAttachmentType.Stand_Design__c = cd.LinkedEntityId;
                if(Schema.sObjectType.DesignAttachmentType__c.IsCreateable())
                {
                   listDesignAtt.add(newDesignAttachmentType);
                }
            } 
        }
        if(!listDesignAtt.isEmpty())
            insert listDesignAtt;
     } //BK-10223 End
    
    @AuraEnabled //get Attachment body 
    public static List<AttachmentWrapper> getAttachmentbody (list<String> attachmentid)
    {
        List <AttachmentWrapper> lstAttachmentWrapper = new List <AttachmentWrapper>();
        List<ContentVersion> version = [SELECT Id, VersionData, ContentDocumentId, Title FROM ContentVersion Where ContentDocumentId IN: attachmentid];
        for(ContentVersion att :version){
            AttachmentWrapper wrapper =  new AttachmentWrapper();
            wrapper.attName = att.Title; 
            wrapper.attEncodedBody = EncodingUtil.base64Encode(att.VersionData);
            lstAttachmentWrapper.add(wrapper);
        }
        return lstAttachmentWrapper;
    } 
    /*Wrapper Class which holds the Name and Body of Attachments*/
    public class AttachmentWrapper 
    {
        @AuraEnabled public String attEncodedBody ; //base64encode of Attchment body 
        @AuraEnabled public String attName;         // Attchment name
    }
    @AuraEnabled //delete Stand Contractor    [CCEN-314]
    public static string deleteStandContractor(string bthConMapID , string rejectReason) 
    { 
        
        String msg = 'Stand Contractor deleted !';
        list<BoothContractorMapping__c> boothMap = [SELECT Id,Rejection_Reason__c,Agent_Contact__c,IsManagedbyAgent__c,Opp_Booth_Mapping__c,Contact__r.Name,Contact__r.Email,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c,Event_Edition__c,Event_Edition__r.Name,Opp_Booth_Mapping__r.Account__r.Name,Opp_Booth_Mapping__r.Booth_Number__c,Is_Self_Managed__c FROM BoothContractorMapping__c  where Id=:bthConMapID limit 1];        
        
        //Regarding Ticket Bk-2349
        if(boothMap != null &&  boothMap.size()>0)  {
            boothMap[0].Rejection_Reason__c=rejectReason; //save the reason for deleteing the StandContractor
            update boothMap;
        }
        if(boothMap != null &&  boothMap.size()>0) 
        {             
            list<string> lstBoothIds = new list<string>(); // List of ExpocadBooth
            lstBoothIds.add(boothMap[0].Opp_Booth_Mapping__c);
            set<id> conID = new set<id>();
            id exhConid;
            conID.add(boothMap[0].Contact__c); // Contact of Stand Contractor 
            if(boothMap[0].IsManagedbyAgent__c) //If Agent managed
            {
                conID.add(boothMap[0].Agent_Contact__c); // Contact of exhibitor for  Stand Contractor
                exhConid = boothMap[0].Agent_Contact__c;
            }
            else {            //Expocad Change [CCEN-742]
                conID.add(boothMap[0].Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c); // Contact of exhibitor for  Stand Contractor []
                
                exhConid = boothMap[0].Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c;
            }        
            map<id,Contact> mapCon = new map<id,Contact> ([select Id,Name,FirstName,LastName,Account.Name,Email from contact where Id in :conID]);                        
            if(boothMap[0].Contact__c != null) {  //Send Email to Contractor
                StandContractorUtils.sendEmailToContractorByCode(boothMap[0].Event_Edition__c,'OPSCSC',mapCon.get(boothMap[0].Contact__c),lstBoothIds);   
            }
            if(exhConid != null) {  // Send Email to exhibitor 
                StandContractorUtils.sendEmailToContractorByCode(boothMap[0].Event_Edition__c,'ECSC',mapCon.get(exhConid),lstBoothIds);
            }
        } 
        try 
        {   
            msg = msg +' : '+deleteStandDesignAndStandDetail(bthConMapID);
            if(BoothContractorMapping__c.sObjectType.getDescribe().isDeletable()) {
                delete boothMap;
            }        
        } 
        catch(DmlException e) { 
            msg = e.getMessage();
        } 
        return msg;
    }        
    @AuraEnabled  
    public static string deleteStandDesignAndStandDetail(string bthConMapID) 
    {  
        string msg = 'StandDesign And StandDetail deleted!';
        list<Stand_Detail__c> stnddtl = new list<Stand_Detail__c>();
        list<Stand_Design__c> stnddsn = new list<Stand_Design__c>();
        stnddtl = [select id from Stand_Detail__c where BoothContractorMapping__c =:bthConMapID ];
        stnddsn = [select id from Stand_Design__c where BoothContractorMapping__c =:bthConMapID ];
        BoothContractorMapping__c newBoothContractorMapping =  new BoothContractorMapping__c();
        newBoothContractorMapping.id = bthConMapID;
        newBoothContractorMapping.Booth_Detail_Status__c = 'Not Submitted';
        newBoothContractorMapping.Booth_Design_Status__c = 'No Design';
        newBoothContractorMapping.Riggering_Options__c = '';
        newBoothContractorMapping.IsAgree__c = False ;
        newBoothContractorMapping.IsRigging__c = False ;
        newBoothContractorMapping.IsDoubleDecker__c = False ;
        newBoothContractorMapping.Performance_Bond_Submitted__c = False ;
        try 
        {   
            update newBoothContractorMapping;
            if(Stand_Detail__c.sObjectType.getDescribe().isDeletable()){
                delete stnddtl;
            }
            if(Stand_Design__c.sObjectType.getDescribe().isDeletable()) {
                delete stnddsn;
            }   
        } 
        catch(DmlException e) {
            msg = e.getMessage();
        }
        return msg;
    } 
    //return Stand_Design_Message_History__c records on the basis of boothMapId[CCEN-411]
    @AuraEnabled
    public static List<Stand_Design_Message_History__c> getStandDesignMessagesCtr(Id boothMapId)
    {
        List<Stand_Design_Message_History__c> lstStndDsignMsg = new List<Stand_Design_Message_History__c>();
        if(boothMapId != null && Schema.sObjectType.Stand_Design_Message_History__c.isAccessible()){
            lstStndDsignMsg=[SELECT id,name,BoothContractorMapping__c,Is_Forwarded__c,BoothContractorMapping__r.Event_Edition__c,ToEmail__c,CCEmail__c,From__c,Subject__c,Content__c,CreatedDate,Email_Template_Code__c from Stand_Design_Message_History__c where BoothContractorMapping__c = :boothMapId order by CreatedDate DESC];
        }   
        return lstStndDsignMsg;
    }
    // Added this method to forward email from Messages tab in Stand Contractor(Ops Admin) section [CCEN-688]
    @AuraEnabled
    public static string forwardEmailToContractor(Stand_Design_Message_History__c stdHistory){
        string msg = EmailConfirmToContractorForBoothStatus.forwardEmailToCon(stdHistory);  
        return msg;
    }
    //Added this method to fetch state picklist based on country before approval by Ops Admin[CCEN-682]
    @AuraEnabled
    public static Map<String, List<String>> getDependentStateMap(string objApi, string contrfieldApiName,string depfieldApiName)
    {
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        objResults = ExhibitorsWithoutContractorsCtrl.getDependentMap(objApi,contrfieldApiName,depfieldApiName);
        return objResults;
    }
    //Added this method to fetch duplicate contacts before approval by Ops Admin[CCEN-682]
    @AuraEnabled //Fetch duplicate contacts
    public static List<sObject> getDuplicateContacts(contact con)  {
        List<sObject> lstDupCon = StandContractorCtrl.getDuplicateContacts(con);
        return lstDupCon;
    }
    //Added this method to fetch duplicate accounts before approval by Ops Admin[CCEN-682]
    @AuraEnabled //Fetch duplicate accounts
    public static account getDuplicateAccount(String sEventcode,String srchText) {
        account lstDupAcc = StandContractorCtrl.getAccount(sEventcode, srchText);
        return lstDupAcc;
    }  
    @AuraEnabled//Get Agents booths [CCEN-430]
    public static list<Opportunity_ExpoCAD_Booth_Mapping__c>  getAgentBooths(String sEventId,string accid,string srchText) // Changed data type [CCEN-742]
    {        
        return StandContractorUtils.getPavilionSpaceExhibitorsBooths(sEventId,accid,srchText);
    }
    @AuraEnabled//Regarding Ticket No.[BK-2150]
    public static loginCtrWrapper  getloginDetail(String eventId ,String accountId , String boothContactMappngId)
    {
        loginCtrWrapper loginwrapper = new loginCtrWrapper();
        string communityName = 'Customer Centre';
        Network n = [Select id from Network WHERE Name=:communityName];
        list<Event_Settings__c>evntStng = new list<Event_Settings__c>();
        evntStng = [select id ,Event_Edition__c from Event_Settings__c where
                    Is_Event_Edition_Live__c = true
                    And Event_Edition__r.Event_Edition_Status__c = 'Confirmed'
                    And Event_Edition__c =:eventId];
        user objUsr=[SELECT Id, Name,username ,ContactId from User where ContactId=:BoothContactMappngId and IsActive=:true];
        
        loginwrapper.userInfo=objUsr;
        loginwrapper.sNetworkid = n.Id;
        loginwrapper.sNetworkid=loginwrapper.sNetworkid.substring(0,15);
        loginwrapper.sOrgId=UserInfo.getOrganizationId().subString(0,15);
        loginwrapper.baseUrl= System.URL.getSalesforceBaseUrl().toExternalForm();
        return loginwrapper;
    }
    @AuraEnabled//Regarding Ticket No.[BK-2150]
    public static void sendEmails(String sContactId,string sEventId)
    {
        set<Id> setCon= new set<Id>();
        set<Id> setConEEmapIds= new set<Id>();
        set<Id> setEEdition = new set<Id>();
        list<user> lstUsr= [SELECT Id, Name from user WHERE ContactId=:sContactId];
        //checking if mapping is created for contact, if not it will create mapping for contact.
        setEEdition.add(sEventId);
        setCon.add(sContactId);
        UtilityMethods.sendEmailToExistingUserAccCon(setCon,setEEdition);// Calling Utility method to send Email   
    }    
    @AuraEnabled//Regarding Ticket No.[BK-2172]
    public static List<Stand_Design__c> designRejected(String attchmntId , String sBthID , String sAccId , String sEventId , String agentId)
    {
        List<DesignAttachmentType__c> rejectedDesign = new List<DesignAttachmentType__c>();
        rejectedDesign = [select id , name ,IsRejected__c ,AttachmentId__c from DesignAttachmentType__c where AttachmentId__c =:attchmntId limit 1];
        if(rejectedDesign.size()>0)
        {
            rejectedDesign[0].IsRejected__c=true;
        }
        update rejectedDesign;
        return StandContractorUtils.getSingleStandDesign(sBthID,sAccId,sEventId,agentId);
    }   
    @AuraEnabled//Regarding Ticket No.[BK-2150]
    public static void resetPasswords(String sContactId)
    {
        List<user > lstUser=new List<user >();
        lstUser = [Select Id,contactId, username from user where contactId =:sContactId and IsActive=:true];
        System.resetPassword(lstUser[0].Id,true);
    }  
    public class LoginCtrWrapper
    {
        @AuraEnabled public string sOrgId;
        @AuraEnabled public string sNetworkid;
        @AuraEnabled public string baseUrl;
        @AuraEnabled public User userInfo;       
    }
    // Check is org sandbox or prod (CCEN-231)
    @AuraEnabled
    public static Boolean isSandbox(){
        Boolean isSandBox = true;
        List<Organization> orgList = [Select ID, IsSandBox from Organization limit 1];
        if(!orgList.isEmpty()){
            isSandBox = orgList[0].IsSandBox;
        }
        return isSandBox;
    }
}