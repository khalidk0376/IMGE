/**
* Created by     : Girikon(Himanshu)
* Created On     : 12/3/2019
* @description   : ApproveContractorCtrl shows the 'Avoid really long classes' in Autorabbit deployment so we created the extension of ApproveContractorCtrl class
*                   and its showing the same functionality as ApproveContractorCtrl class.
* Test Class     : ApproveContractorCtrl_Test (86%)
*
* Modification Log----- 
* Modified by    :  [Girikon(Himanshu [BK-2876 15 Dec 2019]][Girikon(Rajeev [BK-3271 12 Dec 2019]]
**/

public class ApproveContractorExtensionCntr {
    public static ApproveContractorCtrl.ExhibitorsWrapper getAllFilterContractorExtn(String boothDesignStatus,string sStatus, String riggedOption,String searchTearm,Boolean bDblDckrStatus, Boolean bCA,Boolean pbs,Boolean pbns,Boolean sme,Boolean isAllAgt,Boolean isAgtPvnSpc,string sEventId,string column, string order,Decimal pageNumber, Decimal pageSize)
    {
        Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;  
        //Offset for SOQL
        Integer offset = (pNumber - 1) * pSize;
        Map<String,Note__c> mapAccBoothNotes=new Map<String,Note__c>();
        Map<String,Stand_Detail__c> mapAccStndDetail  = new  Map<String,Stand_Detail__c> ();
        Map<String,Stand_Design__c> mapAccStndDesign = new Map<String,Stand_Design__c>();
        Map<String,Stand_Detail__c> mapAgentStndDetail  = new  Map<String,Stand_Detail__c> ();
        Map<String,Stand_Design__c> mapAgentStndDesign = new Map<String,Stand_Design__c>();
        Map<Id,User> mapofUser = new Map<Id,User>();
        set<Id> setContactIds = new set<Id>();

        String query = '';
        String statusList = '';
        String riggedList = '';
        list<string> listBoothDesignStatus = new list<String>(); 
        system.debug('boothDesignStatus----'+boothDesignStatus);
        for(String s : boothDesignStatus.split(',')){
            if(statusList==''){
                statusList='\''+s+'\''; }else{statusList+=',\''+s+'\'';
            }
        }   
        //Added this for making rigging options dropdown multi select[CCEN-684]
        for(String s : riggedOption.split(',')){
            if(riggedList==''){
                riggedList='\''+s+'\'';   }else{riggedList+=',\''+s+'\'';
            }
        }
        if(boothDesignStatus!='All') {
            query += ' AND Booth_Design_Status__c IN ('+statusList+')';
        }
        if(sStatus!='All') { 
            query += ' AND Status__c=\''+String.escapeSingleQuotes(sStatus)+'\' ';
        }
        if(searchTearm!='')     // EXPOCAD Change CCEN-753
        {
            query +=' AND (contact__r.Account.Name like \'%'+String.escapeSingleQuotes(searchTearm)+'%\' or Opp_Booth_Mapping__r.Opportunity__r.account.name like \'%'+String.escapeSingleQuotes(searchTearm)+'%\' or Opp_Booth_Mapping__r.Booth_Number__c like \'%'+String.escapeSingleQuotes(searchTearm)+'%\' or Opp_Booth_Mapping__r.Display_Name__c like \'%'+String.escapeSingleQuotes(searchTearm)+'%\' or Agent_Contact__r.account.name like \'%'+String.escapeSingleQuotes(searchTearm)+'%\' or Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c like \'%'+String.escapeSingleQuotes(searchTearm)+'%\' ) ';
        }
        if(riggedOption!='All') {
            // query +=' AND Riggering_Options__c=\''+String.escapeSingleQuotes(riggedOption)+'\' '; 
            query += ' AND Riggering_Options__c IN ('+riggedList+')';
        }
        if(bCA==true){
            query +=' AND IsAgree__c='+bCA+' ';     
        }
        if(bDblDckrStatus==true) {
            query +=' AND IsDoubleDecker__c='+bDblDckrStatus+' ';
        }
        if(sme==true) {
            query +=' AND Is_Self_Managed__c='+sme+' ';     
        }   
        if(pbs==true && pbns==false) {
            query +=' AND Performance_Bond_Submitted__c='+pbs+' ';
        }
        else if(pbs==false && pbns==true) {
            pbns = !pbns;
            query +=' AND Performance_Bond_Submitted__c='+pbns+' '; 
        }
        if(isAllAgt == true ) {
            query +=' AND (Opp_Booth_Mapping__r.Opportunity__r.User_Type__r.Name = \'Agent\' or IsManagedbyAgent__c = True )';
        }
        if(isAgtPvnSpc == true ) {
            query +=' AND IsManagedbyAgent__c = True ';
        }
        list<BoothContractorMapping__c> listBooth = new list<BoothContractorMapping__c>();
        string strQuery='SELECT id,Opp_Booth_Mapping__c,Opp_Booth_Mapping__r.Display_Name__c,IsManagedbyAgent__c,Agent_Contact__r.Email,Agent_Contact__r.Phone,Agent_Contact__c,Agent_Contact__r.AccountId,Agent_Contact__r.account.Name,Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c,Opp_Booth_Mapping__r.Expocad_Booth__r.Dimensions__c,Is_Self_Managed__c,Opp_Booth_Mapping__r.Opportunity__r.User_Type__r.Name,Opp_Booth_Mapping__r.Opportunity__r.account.name, Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Email,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.MobilePhone,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Name,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Phone,ExpocadBooth__c,Riggering_Options__c, Opp_Booth_Mapping__r.Booth_Number__c,IsRigging__c,IsDoubleDecker__c,Booth_Design_Status__c, Contact__c, TempContact__r.TempAccount__r.Id, TempContact__r.TempAccount__r.Name, TempContact__r.Name__c, TempContact__r.Account__r.Name, TempContact__c, Contact__r.Name,Contact__r.Email,Contact__r.Phone,Contact__r.MobilePhone, contact__r.Account.Name,contact__r.Account.Phone,contact__r.AccountId, status__c, createdby.contact.account.name,Event_Edition__c,Event_Edition__r.Event_Code__c ,Opp_Booth_Mapping__r.Agent_Name__c ';
        string sCountAndQuery ='FROM BoothContractorMapping__c WHERE ((Opp_Booth_Mapping__r.Opportunity__c!= NULL And Opp_Booth_Mapping__r.Status__c = \'Active\' And Opp_Booth_Mapping__r.Expocad_Booth__r.status__c = \'Rented\') or (IsManagedbyAgent__c = true And Opp_Booth_Mapping__c = null)) and Event_Edition__c=\''+String.escapeSingleQuotes(sEventId)+'\' '+query+' AND (Contact__c != NULL AND Approved__c = TRUE) '; 
        //Total Records
        //Integer totalRecords = (Integer)UtilityMethods.getTotalRows(sCountAndQuery); 
        Integer totalRecords = database.countQuery('select count() '+sCountAndQuery); 
        Integer recordEnd = pSize * pNumber;
        //Instance of Contact DataTable Wrapper Class
        ApproveContractorCtrl.ExhibitorsWrapper objDT =  new ApproveContractorCtrl.ExhibitorsWrapper();  
        objDT.pageSize = pSize;
        objDT.pageNumber = pNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        strQuery=strQuery+sCountAndQuery;
        if(String.isNotBlank(column) && String.isNotBlank(order))
        {  
            strQuery=strQuery+' order by '+column+' '+order;
        }
        if(pSize>0)
        {  
            strQuery=strQuery+' LIMIT '+ pSize +' OFFSET ' + offset  ;
        }
        //listBooth = Database.query(strQuery); 
        listBooth = UtilityMethods.getDynamicSobjectList(strQuery);
    
        if(listBooth.size()>0)
        {   
            //Fetch Stand Details
           mapAccStndDetail=StandContractorUtils.getAllStandDetail(listBooth[0].Event_Edition__r.Event_Code__c);        
            //Fetch Stand Designs 
            mapAccStndDesign=StandContractorUtils.getAllStandDesign(listBooth[0].Event_Edition__r.Event_Code__c );
            //Fetch Stand Details For Agent Pavilion Space
            mapAgentStndDetail = ApproveContractorCtrl.getAllAgentPavilionSpaceStandDetail(listBooth[0].Event_Edition__c);
            //Fetch Stand Designs For Agent Pavilion Space
            mapAgentStndDesign = ApproveContractorCtrl.getAllAgentPavilionSpaceStandDesign(listBooth[0].Event_Edition__c);
        }
        list<Note__c> listNotes = new list<Note__c>();

        if(Schema.sObjectType.Note__c.fields.Note__c.isAccessible())
        {
            listNotes=[SELECT id,Account__c,ExpocadBooth__c,Opp_Booth_Mapping__c,Note__c FROM Note__c WHERE Account__c !=null AND Opp_Booth_Mapping__c!=null order by LastModifiedDate DESC];
        }
        if(listNotes!=null && listNotes.size()>0)
        {
            for(Note__c objNote:listNotes) { 
                String key=string.valueof(objNote.Account__c)+'_'+string.valueof(objNote.Opp_Booth_Mapping__c);
                if(!mapAccBoothNotes.containsKey(key)) {
                    mapAccBoothNotes.put(key,objNote);
                }    
            }
        }
        
        if(listBooth!=null && listBooth.size()>0)
        {
            for(BoothContractorMapping__c objBooth:listBooth){
                if(objBooth.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Id!=null){
                    Id contactId = objBooth.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Id;
                    setContactIds.add(contactId);
                }
                if(objBooth.Contact__c!=null){
                    Id standContId =objBooth.Contact__c;
                    setContactIds.add(standContId);
                }
                if(objBooth.Agent_Contact__c!=null){
                    Id agentContactId =objBooth.Agent_Contact__c;
                    setContactIds.add(agentContactId);}
            }
            if(!setContactIds.isEmpty()) mapofUser = AgentOwnedExhibitorUtils.getContactUserMap(setContactIds);
            
            for(BoothContractorMapping__c objBooth:listBooth) {
                string sBoothKey=string.valueof(objBooth.contact__r.AccountId)+'_'+string.valueof(objBooth.Opp_Booth_Mapping__c); // EXPOCAD Change CCEN-753
                ApproveContractorCtrl.wrapperClass objWrapperClass = new  ApproveContractorCtrl.wrapperClass ();
                objWrapperClass.sId=objBooth.Id;
                objWrapperClass.isSelfManaged=objBooth.Is_Self_Managed__c;
                //Start of BK - 2876
                objWrapperClass.exhibOpeartionCon=objBooth.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Name;
                objWrapperClass.exhibOpeartionEmail=objBooth.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Email;
                objWrapperClass.exhibOpeartionMobile=objBooth.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Phone;
                objWrapperClass.exhibOpeartionTel=objBooth.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.MobilePhone;               
                objWrapperClass.contContactMobile=objBooth.Contact__r.Phone;
                objWrapperClass.contContactName=objBooth.Contact__r.Name;               
                objWrapperClass.contContactTel=objBooth.Contact__r.MobilePhone;
                objWrapperClass.contContactEmail=objBooth.Contact__r.Email;
                objWrapperClass.boothdimensions=objBooth.Opp_Booth_Mapping__r.Expocad_Booth__r.Dimensions__c;
                objWrapperClass.contractorPhone=objBooth.Contact__r.Account.Phone; 
                if(!mapofUser.isEmpty())
                {
                   if(mapofUser.containsKey(objBooth.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c) && objBooth.IsManagedbyAgent__c==false){
                     objWrapperClass.usernameexh = mapofUser.get(objBooth.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c).UserName;  
                    }
                   if(mapofUser.containsKey(objBooth.Contact__c) && objBooth.IsManagedbyAgent__c==false){
                     objWrapperClass.contractorUsername =  mapofUser.get(objBooth.Contact__c).UserName;   
                    }
                }   
                String delimiter = 'x';
                String input = objWrapperClass.boothdimensions !=null?objWrapperClass.boothdimensions:'';              
                String firstSplit = input.substringBefore(delimiter);                
                String lastSplit = input.substringAfter(delimiter); 
               
                objWrapperClass.boothLenght=firstSplit;              
                objWrapperClass.boothWidth=lastSplit;
                //End of BK - 2876
                if(objBooth.Contact__r.Account.Name!=null) 
                {
                    objWrapperClass.contractorCompany=objBooth.Contact__r.Account.Name;                 
                }
                else if(objBooth.TempContact__r.TempAccount__r.Name!=null) { objWrapperClass.contractorCompany=objBooth.TempContact__r.TempAccount__r.Name;
                }
                else
                {
                    objWrapperClass.contractorCompany=objBooth.TempContact__r.Account__r.Name;
                }

                if(objBooth.IsManagedbyAgent__c) // Agent Managed Pavilion Space [CCEN-430] 
                {                    
                    objWrapperClass.strExhibitor=objBooth.Agent_Contact__r.account.name;
                    objWrapperClass.strBooth='Agent Booths';
                    objWrapperClass.exhibitorEmail=objBooth.Agent_Contact__r.Email;
                    objWrapperClass.exhibitorPhone=objBooth.Agent_Contact__r.Phone;
                    objWrapperClass.exhibitingName=objBooth.Agent_Contact__r.Account.Name;
                    objWrapperClass.boothProductType= 'Agent Pavilion Space';
                    objWrapperClass.userType = 'Agent';
                    objWrapperClass.isManagedbyAgent= true;
                    objWrapperClass.agentAccountID = objBooth.Agent_Contact__r.Account.Id;
                    if(!mapofUser.isEmpty())
                    {
                        if(mapofUser.containsKey(objBooth.Agent_Contact__c)){
                            objWrapperClass.usernameexh = mapofUser.get(objBooth.Agent_Contact__c).UserName;}
                        if(mapofUser.containsKey(objBooth.Contact__c)){
                            objWrapperClass.contractorUsername   =  mapofUser.get(objBooth.Contact__c).UserName;    
                        }
                    }   
                    sBoothKey = objBooth.Agent_Contact__r.Account.Id; //key for agent Managed Pavilion Space 

                    if(mapAgentStndDetail.containsKey(sBoothKey))
                    {
                        objWrapperClass.boolHevyMachin=mapAgentStndDetail.get(sBoothKey).Is_Heavy_Machinery__c;
                        objWrapperClass.isReceived=mapAgentStndDetail.get(sBoothKey).IsReceived__c;
                        objWrapperClass.performanceBondAmount=  mapAgentStndDetail.get(sBoothKey).Amount__c==null?'0':mapAgentStndDetail.get(sBoothKey).Amount__c;
                        objWrapperClass.sreqErlyAcc=mapAgentStndDetail.get(sBoothKey).Require_Early_Access__c;
                        objWrapperClass.serlyaccDte_Time=mapAgentStndDetail.get(sBoothKey).Early_Access_Date_Time__c;
                        objWrapperClass.serlyAccCost=mapAgentStndDetail.get(sBoothKey).Early_Access_Cost__c;
                    }                   
                    if(mapAgentStndDesign.containsKey(sBoothKey)){
                        objWrapperClass.dBoothDsnSbmttdOn=mapAgentStndDesign.get(sBoothKey).Booth_Design_Submitted_On__c;
                        objWrapperClass.dSubToVenueOn=mapAgentStndDesign.get(sBoothKey).Submitted_to_Venue_On__c;
                        objWrapperClass.boolCA=mapAgentStndDesign.get(sBoothKey).Contractor_Agreement_CA__c;
                        objWrapperClass.sBoothStatus=mapAgentStndDesign.get(sBoothKey).Booth_Design_Status__c;
                    }
                    else 
                    {
                        objWrapperClass.sBoothStatus='No Design';
                    }
                }
                else // non-Agent Managed Pavilion Space
                {    
                    objWrapperClass.agentName = objBooth.Opp_Booth_Mapping__r.Agent_Name__c; // Added Agent Name [CCEN-527]
                    objWrapperClass.strExhibitor=objBooth.Opp_Booth_Mapping__r.Opportunity__r.account.name;
                    objWrapperClass.strBooth=objBooth.Opp_Booth_Mapping__r.Booth_Number__c;
                    objWrapperClass.exhibitorEmail=objBooth.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Email;
                    objWrapperClass.exhibitorPhone=objBooth.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Phone;
                    if( objBooth.Opp_Booth_Mapping__r.Display_Name__c == null ) { objWrapperClass.exhibitingName=objBooth.Opp_Booth_Mapping__r.Opportunity__r.Account.name;
                    }
                    else
                    {
                        objWrapperClass.exhibitingName=objBooth.Opp_Booth_Mapping__r.Display_Name__c;
                    }  
                    objWrapperClass.boothProductType=objBooth.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c;
                    objWrapperClass.userType = objBooth.Opp_Booth_Mapping__r.Opportunity__r.User_Type__r.Name;

                    if(mapAccStndDetail.containsKey(sBoothKey))
                    {
                        objWrapperClass.boolHevyMachin       =   mapAccStndDetail.get(sBoothKey).Is_Heavy_Machinery__c;
                        objWrapperClass.isReceived           =   mapAccStndDetail.get(sBoothKey).IsReceived__c;
                        objWrapperClass.performanceBondAmount=  mapAccStndDetail.get(sBoothKey).Amount__c==null?'0':mapAccStndDetail.get(sBoothKey).Amount__c;
                        objWrapperClass.sreqErlyAcc    =   mapAccStndDetail.get(sBoothKey).Require_Early_Access__c;
                        objWrapperClass.serlyaccDte_Time  =   mapAccStndDetail.get(sBoothKey).Early_Access_Date_Time__c;
                        objWrapperClass.serlyAccCost      =   mapAccStndDetail.get(sBoothKey).Early_Access_Cost__c;
                        objWrapperClass.boolStdHgt      =   mapAccStndDetail.get(sBoothKey).Stand_Height__c;
                        objWrapperClass.boolRigHgt      =   mapAccStndDetail.get(sBoothKey).Rigging_Height__c;
                        objWrapperClass.boolVehicle      =   mapAccStndDetail.get(sBoothKey).Is_Vehicles__c;
                    }                   
                    if(mapAccStndDesign.containsKey(sBoothKey))
                    {
                        objWrapperClass.dBoothDsnSbmttdOn=mapAccStndDesign.get(sBoothKey).Booth_Design_Submitted_On__c;
                        objWrapperClass.dSubToVenueOn=mapAccStndDesign.get(sBoothKey).Submitted_to_Venue_On__c;
                        objWrapperClass.boolCA=mapAccStndDesign.get(sBoothKey).Contractor_Agreement_CA__c;
                        objWrapperClass.sBoothStatus=mapAccStndDesign.get(sBoothKey).Booth_Design_Status__c;
                    }
                    else 
                    {
                        objWrapperClass.sBoothStatus='No Design';
                    }
                }
                objWrapperClass.boolRigging=objBooth.IsRigging__c;
                objWrapperClass.boolDblDckr=objBooth.IsDoubleDecker__c;
                objWrapperClass.riggeringOptions =objBooth.Riggering_Options__c;
                objWrapperClass.sContrctorStatus=objBooth.Status__c;
                objWrapperClass.sContactsAccountName=objBooth.Contact__r.Account.Name;
                
                if(mapAccBoothNotes.containsKey(sBoothKey)){objWrapperClass.sRcntNote=mapAccBoothNotes.get(sBoothKey).Note__c;
                }
                objDT.lstWrapper.add(objWrapperClass);
            }
        }
        return objDT;
    }
    
    public static string updateTmpAccountContactExtn(Id sIds, List<BoothContractorMapping__c> singleBth){
       List<TempAccount__c> lstTmpAcc= new List<TempAccount__c>();
        List<TempContact__c> lstTmpCon= new List<TempContact__c>();
        string tempAccountId = '';
        string tempContactId = '';
        List<BoothContractorMapping__c> lstBoothConMap = [select id, Contact__c,TempContact__r.TempAccount__c,TempContact__r.TempAccount__r.Address__c,ExpocadBooth__c,TempContact__r.TempAccount__r.Zip__c,Event_Edition__c,TempContact__r.TempAccount__r.State__c,TempContact__r.TempAccount__r.Country__c,TempContact__r.TempAccount__r.City__c,TempContact__r.TempAccount__r.Name,TempContact__r.Phone__c, TempContact__r.MobilePhone__c, TempContact__r.Email__c,ExpocadBooth__r.Booth_Number__c, TempContact__r.Account__c,TempContact__c,TempContact__r.FirstName__c,TempContact__r.LastName__c from BoothContractorMapping__c where Id = :sIds ];
       if(lstBoothConMap.size()>0 && lstBoothConMap[0].TempContact__r.TempAccount__c != null && Schema.sObjectType.TempAccount__c.isAccessible() && singleBth != null)
        {
            tempAccountId = lstBoothConMap[0].TempContact__r.TempAccount__c;
            lstTmpAcc = [Select id,Name,City__c,Country__c,Address__c,State__c,Zip__c from TempAccount__c where id=:tempAccountId];

            if(lstTmpAcc.size()>0)
            {
                lstTmpAcc[0].Name = singleBth[0].TempContact__r.TempAccount__r.Name;
                lstTmpAcc[0].City__c = singleBth[0].TempContact__r.TempAccount__r.City__c;
                lstTmpAcc[0].Country__c = singleBth[0].TempContact__r.TempAccount__r.Country__c;
                lstTmpAcc[0].State__c = singleBth[0].TempContact__r.TempAccount__r.State__c;
                lstTmpAcc[0].Zip__c = singleBth[0].TempContact__r.TempAccount__r.Zip__c;
            }
            if(Schema.sObjectType.TempAccount__c.isUpdateable())
            {
                update lstTmpAcc;
            }
        }

        if(lstBoothConMap.size()>0 && lstBoothConMap[0].TempContact__c != null && Schema.sObjectType.TempContact__c.isAccessible() && singleBth != null)
        {
            tempContactId = lstBoothConMap[0].TempContact__c;
            lstTmpCon = [Select id,FirstName__c,LastName__c,TempAccount__c,MobilePhone__c,Phone__c,Email__c from TempContact__c where id=:tempContactId];

            if(lstTmpCon.size()>0)
            {
               lstTmpCon[0].FirstName__c = singleBth[0].TempContact__r.FirstName__c;
                lstTmpCon[0].LastName__c = singleBth[0].TempContact__r.LastName__c;
                lstTmpCon[0].MobilePhone__c = singleBth[0].TempContact__r.MobilePhone__c;
                lstTmpCon[0].Phone__c = singleBth[0].TempContact__r.Phone__c;
                lstTmpCon[0].Email__c = singleBth[0].TempContact__r.Email__c; 
            }
            if(Schema.sObjectType.TempContact__c.isUpdateable())
            {
                update lstTmpCon;
            }
        }
        ApproveContractorCtrl.getapproval(sIds, 'Exhibitor');
        return ('Successfully  Updated!');
    }
    
    public static string rejectContarctorExtn(Id sIds,string notes, Boolean sendMail){
        string msg = 'Contractor Rejected successfully!';    
        List<BoothContractorMapping__c> updateBoothmap = new List<BoothContractorMapping__c>();
        if(sIds != null )
        {
            List<BoothContractorMapping__c> lstTempCon = [select id, Status__c from BoothContractorMapping__c where Id = :sIds limit 1];           
            if(lstTempCon != null && lstTempCon.size()>0)
            {
                for(BoothContractorMapping__c oBooth: lstTempCon)
                {
                    oBooth.Status__c = 'Rejected';
                    oBooth.ContractorRequestStatus__c = 'Declined';
                    updateBoothmap.add(oBooth);
                }
                if(updateBoothmap.size()>0 && Schema.sObjectType.BoothContractorMapping__c.isUpdateable())
                {
                    Update updateBoothmap;
                }
                if(sendMail) // Added to send Reject mail[CCEN-421]
                {
                    msg = EmailConfirmToContractorForBoothStatus.sendRejectMailToExh(sIds,notes); 
                }
            }   
        }
        return msg;
    }
    
    public static ApproveContractorCtrl.wrapperClass2 findSubcontractors(string mapId, string accId, string boothId)
    {
        ApproveContractorCtrl.wrapperClass2 oObjWrap=new ApproveContractorCtrl.wrapperClass2();
        List<BoothContractorMapping__c> lstboothmap = new List<BoothContractorMapping__c>();
        if(Schema.sObjectType.BoothContractorMapping__c.isAccessible())
        {
            lstboothmap =  [select Id,Name, Parent_BoothMapping__r.Contact__r.Account.Name, Parent_BoothMapping__r.Contact__r.Account.Phone,TempContact__r.Name__c,TempContact__r.TempAccount__r.Name,Parent_BoothMapping__c,(select Id,ContractorService__r.Contractor_Service__c from CustomerContractorServices__r)  from BoothContractorMapping__c where TempContact__r.Is_SubContractors_Available__c=true AND Parent_BoothMapping__r.Contact__r.Account.Name != null AND Parent_BoothMapping__c=:mapId];
        }            
        oObjWrap.lstBoothMapList=lstboothmap;
        //oObjWrap.lstStandDetailList = getStandDetailsCtr(accId,boothId,'','');// calling getStandDetailsCtr to get the list of Stand_Detail__c       
        return oObjWrap;
    }
}