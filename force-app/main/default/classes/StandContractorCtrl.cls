/**
 * Created By       :   Girikon(Sunil)
 * Created On       :   03/06/2018
 * @description     :   This class provides following functionalities:          
*                       Allow Exhibitor to send request to existing contractor or create  new contractor account and contact and send request.          
 * Helper Class     :   UtilityMethods
 * Test Class       :   StandContractorCtrl_Test(83%)
 
 * Modification log --
 * Modified by      :   Girikon(Sunil[CCEN-611 June 03 2019,CCEN-360 Sept 25 2019,CCEN-431 Dec 7 2018]),Girikon(Ashish)[CCEN-457 (Nov 12 2018)],Girikon(Prashant)[CCEN-654 (Mar 4 2019), Girikon(Aishwarya)[CCEN-389],Girikon(Ashish)[CCEN-742] ,Girikon(Rajeev)[BK-2345],Girikon(Rajeev)[BK-2347]]
 **/
public without sharing class StandContractorCtrl {

    @AuraEnabled //Fetch event details
    public static Event_Settings__c getEventDetails(String sEventcode)
    {
        //Get event details
        return UtilityMethods.getEventDetails(sEventcode);
    }
    
    @AuraEnabled //Fetch contractor accounts with contacts
    public static list<account> getAccountContacts(String sEventcode,String srchText)
    {
        String strQuery = 'select Id,Name,BillingCountry,(select Id,Name,Contact_Type__c  from contacts) from account where type=\'Stand Contractor\' ';       
        if(String.isNotEmpty(srchText)) 
        {
            string whereClause = '%' + String.escapeSingleQuotes(srchText) + '%';
            strQuery+=' and Name like :whereClause ';
        }
        strQuery+=' limit 100';
        list<account> lstacc = new list<account>();
        lstacc = Database.query(strQuery);  
        return lstacc;
    }
    
    @AuraEnabled //Search contractor account
    public static account getAccount(String sEventcode,String srchText)
    {
        String strQuery = 'select Id,Name from account where type=\'Stand Contractor\' ';
        //CCEN-611
        string srchTxt = String.escapeSingleQuotes(srchText);
        if(String.isNotEmpty(srchText))
        {
            strQuery+=' and Name =:srchTxt';
        }
        strQuery+=' order by createddate asc limit 1';
        list<account> lstacc = Database.query(strQuery);
        if(lstacc != null && lstacc.size()>0)
        {
            return lstacc[0];
        } 
        else 
        {
            return null;
        }
    }
    @AuraEnabled //Fetch booths
    public static list<ExpocadBooth__c> getBooths(String sEventcode)
    {
        list<ExpocadBooth__c> listexpo = new list<ExpocadBooth__c>();
        //UtilityMethods.getOppBoothDetails(sEventcode);   // Expocad Change 
        return listexpo ;
    }

    @AuraEnabled //Fetch contractor booth
    public static map<string,list<BoothContractorMapping__c>> getBoothsMapping(String sEventcode)
    {   
        User usr = new User();
        usr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()]; 
        return StandContractorUtils.getBoothsMappingFromAccId(sEventcode,usr.Accountid);
    }
    /*
    @AuraEnabled //Fetch contractor booth
    public static map<string,list<BoothContractorMapping__c>> getBoothsMapping(String sEventcode)
    {   
        set<id> boothids= new set<id>();
        User usr = new User();
        if(Schema.sObjectType.User.isAccessible())
        {
            usr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()]; 
        }
        map<string,list<BoothContractorMapping__c>> mapBooths = new map<string,list<BoothContractorMapping__c>>();
        for(Opportunity_ExpoCAD_Booth_Mapping__c sBooth :  StandContractorUtils.getCustomerBooths(usr.Accountid,sEventcode)) // Expocad Change [CCEN-742]
        {
            list<BoothContractorMapping__c> obj= new list<BoothContractorMapping__c>();
            //mapBooths.put(sBooth.Booth_Number__c+'_$_'+sBooth.Id,obj);
            mapBooths.put(sBooth.Booth_Number__c+'_$_'+sBooth.Id+'_$_'+sBooth.Expocad_Booth__r.Matched_Product_Name__c,obj); 
            boothids.add(sBooth.Id);
        }
        
        
        //Fetch Stand Details
        Map<String,Stand_Detail__c> mapAccStndDetail = StandContractorUtils.getAllStandDetail(sEventcode);

        //Fetch Stand Designs
        Map<String,Stand_Design__c> mapAccStndDesign = StandContractorUtils.getAllStandDesign(sEventcode);

        for(BoothContractorMapping__c sBoothMap :  [select Id,Agent_Contact__c,IsManagedbyAgent__c,ExpocadBooth__c,Opp_Booth_Mapping__c,Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c,Opp_Booth_Mapping__r.Booth_Number__c,TempContact__r.TempAccount__r.Name,TempContact__c,TempContact__r.Account__r.Name,TempContact__r.Name__c,Contact__c,Contact__r.Name,contact__r.AccountId,Contact__r.Account.Name,ContractorRequestStatus__c,Booth_Design_Status1__c,Booth_Detail_Status1__c,Is_Self_Managed__c,(select Id,ContractorService__r.Contractor_Service__c from CustomerContractorServices__r)  from BoothContractorMapping__c where Opp_Booth_Mapping__c in :boothids and Event_Edition__r.Event_Code__c =:sEventcode and Parent_BoothMapping__c='' limit 1000])
        {   
            string sKey=sBoothMap.Opp_Booth_Mapping__r.Booth_Number__c+'_$_'+sBoothMap.Opp_Booth_Mapping__c+'_$_'+sBoothMap.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c;
            if(mapBooths.containsKey(sKey))
            {
                list<BoothContractorMapping__c> lstmap = mapBooths.get(sKey);
                string boothKey=string.valueof(sBoothMap.contact__r.AccountId)+'_'+string.valueof(sBoothMap.Opp_Booth_Mapping__c);

                //Check Stand Details Status
                if(mapAccStndDetail.containsKey(boothKey))
                {
                    sBoothMap.Booth_Detail_Status1__c= mapAccStndDetail.get(boothKey).Booth_Detail_Status__c;
                }
                else
                {
                    sBoothMap.Booth_Detail_Status1__c='Not Submitted';//Set default status 
                }

                //Check Stand Design Status
                if(mapAccStndDesign.containsKey(boothKey))
                {
                    sBoothMap.Booth_Design_Status1__c = mapAccStndDesign.get(boothKey).Booth_Design_Status__c;
                }
                else{
                    sBoothMap.Booth_Design_Status1__c='No Design'; //Set default status 
                }
                lstmap.add(sBoothMap); 
                mapBooths.put(sKey,lstmap);  
            } 
        } 
        return mapBooths;
    }
        */
    // filtered  ExpocadBooth__c records for account on the basis of multi select from ops admin. 
    public static list<ExpocadBooth__c> getOppBoothformAccount(String sEventcode,String accId) 
    {   
        list<Event_Settings__c>evntStng =  new list<Event_Settings__c>();
        list<ExpocadBooth__c> lstexpoBooths=new list<ExpocadBooth__c>();
        set<string> quoteIds = new set<string>();
        list<string>allowedExpocadProductTypes = new list<string>();
        if(Schema.sObjectType.Event_Settings__c.isAccessible())
        {
            evntStng = [select id , Allowed_Expocad_Product_Types__c from Event_Settings__c where Event_Edition__r.Event_Code__c =: sEventcode limit 1];
        }
        if(evntStng.size()>0)
        {
            if(String.IsNotBlank(evntStng[0].Allowed_Expocad_Product_Types__c))
            {
                allowedExpocadProductTypes = evntStng[0].Allowed_Expocad_Product_Types__c.split(';');
            }   
        }
        List<opportunity> opp = new List<opportunity>();
            opp = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where AccountId=:accId //AND SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c=:usr.Contactid  
                AND EventEdition__r.Event_Code__c =: sEventcode AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
        
        if(!opp.IsEmpty())
        {
            for(opportunity oppty: opp)
            {
                if(oppty.SBQQ__PrimaryQuote__c!=null)
                {
                    quoteIds.add(oppty.SBQQ__PrimaryQuote__c);
                }
            }
            //Added condition of Related_Opportunity__c and Related_Opportunity__r.User_Type__r.Name for [CCEN-416]
            String strExpoBooths='Select Id,Badge_Limit__c,Booth_Number__c,Matched_Product_Name__c, Area_Number__c, Unit_Type__c, Dimensions__c, Open_Corners__c,Booth_Product_Type_EE__c, Opportunity__c, Opportunity__r.Name, Opportunity__r.createdDate, Display_Name__c, Opportunity__r.account.name, Status__c From ExpocadBooth__c where status__c=\'Rented\' and quote__c IN:quoteIds and (Related_Opportunity__c  = null OR Related_Opportunity__r.User_Type__r.Name = \'Co-Exhibitor\')';            
            strExpoBooths += ' And Matched_Product_Name__c in : allowedExpocadProductTypes';           
            strExpoBooths += ' order by Opportunity__r.createdDate';
            lstexpoBooths = Database.Query(strExpoBooths);
        }
        //System.debug('lstexpoBooths ========================================================='+lstexpoBooths);
        return lstexpoBooths;
    }

    //Create contractor company temporary contact, servives mapping, booth mapping
    //Check existing mapping 
    @AuraEnabled
    public static string createContactandMapping(contact con,string sEventId,string tempAccount,list<string> lstBoothIds,list<string> lstServices,boolean isAgent)
    {
        string msg='success';
        Boolean selfManaged=false;
        String status='Pending';
        try
        {
            //system.debug('con'+con);
            list<BoothContractorMapping__c> lstExistMap = new list<BoothContractorMapping__c>();
            string name=con.FirstName+' '+con.LastName;
            List<User> users=new List<User>();
            if(String.isEmpty(con.Id) && String.isEmpty(con.AccountId) && String.isEmpty(tempAccount))
            {
                User usr = [SELECT Id, Contactid,Accountid,Account.Name  FROM User WHERE Id = : UserInfo.getUserId()]; 
                con.Id=usr.Contactid;
                con.AccountId=usr.Accountid;
                selfManaged=true;
                status='Accepted';
            }
            //fetch exisiting map for exisitng account and contact
            if(!String.isEmpty(con.Id) && Schema.sObjectType.BoothContractorMapping__c.isAccessible())
            {
                lstExistMap = [select id from BoothContractorMapping__c where Contact__c=:con.Id and Contact__r.AccountId=:con.AccountId and Event_Edition__c=:sEventId and Opp_Booth_Mapping__c in :lstBoothIds  order by createddate desc ];
            }
            else if(!String.isEmpty(tempAccount)) 
            {
                //fetch temp account by name
                list<TempAccount__c> lstTempAcc = new list<TempAccount__c>();
                if(Schema.sObjectType.TempAccount__c.isAccessible())
                {
                    lstTempAcc = [select id,name from TempAccount__c where id=:tempAccount];
                }                
                if(lstTempAcc.size()>0 && Schema.sObjectType.BoothContractorMapping__c.isAccessible())
                {
                    //fetch exisiting map for temp account and temp contact
                    lstExistMap = [select id from BoothContractorMapping__c where TempContact__r.Name__c=:name and TempContact__r.TempAccount__r.Name=:lstTempAcc[0].Name and Event_Edition__c=:sEventId and Opp_Booth_Mapping__c in :lstBoothIds order by createddate desc];
                }
            }
            else
            {
                //fetch exisiting map for exisitng account and temp contact
                lstExistMap = [select id from BoothContractorMapping__c where TempContact__r.Name__c=:name and TempContact__r.Account__c=:con.AccountId and Event_Edition__c=:sEventId and Opp_Booth_Mapping__c in :lstBoothIds order by createddate desc];
            }
        
            if(!isAgent && lstExistMap.size()>0 )
            {
                msg='error';
            }
            else{
                TempContact__c objTempCon =new TempContact__c();
                if(String.isEmpty(con.Id)){
                    //insert temp con;
                    objTempCon.Email__c=con.Email;
                    objTempCon.MobilePhone__c=con.MobilePhone;
                    objTempCon.FirstName__c=con.FirstName;
                    objTempCon.LastName__c=con.LastName;
                    objTempCon.Phone__c=con.Phone;
                    objTempCon.Account__c=con.AccountId;
                    if(String.isNotEmpty(tempAccount))
                    {
                        objTempCon.TempAccount__c=tempAccount;
                    }
                    //Insert temp contact
                    if(Schema.sObjectType.TempContact__c.IsCreateable())
                    {
                        insert objTempCon;                        
                    }                    
                }
                else
                {
                    users=[Select Id,Contact.Type__c,ContactId,Contact.name,Contact.email,IsActive,IsPortalEnabled from User where ContactId =:con.Id and IsPortalEnabled=true And Profile.Name=:UtilityMethods.getProfileid().Name and IsActive=true];
                }
                createContactMap(selfManaged,lstBoothIds,con,objTempCon.Id,sEventId,status,users,lstServices,isAgent); 
            }
        }
        catch(Exception ex)
        {
            msg=ex.getMessage();
            msg=msg+'==='+ex.getLineNumber();
            system.debug('msg'+msg);
        }
        return msg;
    } 
    //Create contractor company contact and servives mapping    
    public static void createContactMap(boolean selfManaged,list<string> lstBoothIds,Contact con,string objTempConId,string sEventId,string status,list<User> users,list<string> lstServices,boolean isAgent)
    {      
        boolean disableInviteMail = false;
        boolean isMapExists = true;
        //create booth and contact mapping
        list<BoothContractorMapping__c> lstboothMapping = new list<BoothContractorMapping__c>();
        User usr = [SELECT Id, Contactid,Accountid,Account.Name  FROM User WHERE Id = : UserInfo.getUserId()];
        for(string boothId :  lstBoothIds)
        {
            BoothContractorMapping__c newboothMapping = new BoothContractorMapping__c();
            newboothMapping.Contact__c=con.Id;
            newboothMapping.Is_Self_Managed__c=selfManaged;
            newboothMapping.TempContact__c=objTempConId;
            newboothMapping.Event_Edition__c=sEventId;
            if(String.isNotBlank(boothId))
            {
                //newboothMapping.ExpocadBooth__c=boothId;
                newboothMapping.Opp_Booth_Mapping__c = boothId;   // Expocad Change [CCEN-742]
            } 
            newboothMapping.ContractorRequestStatus__c=status; 
            newboothMapping.Status__c=status; 
            if(!users.isEmpty()){
                newboothMapping.Approved__c = true;
                newboothMapping.Status__c = 'Accepted';
                newboothMapping.Approval_Date__c=System.now();
                isMapExists = checkContactEventMap(con,sEventId);
            }
            if(selfManaged)  // Customer Centre - All Assigned Contractors- designation status error 
            {
                newboothMapping.Status__c = status;  
            }
            if(isAgent && String.isBlank(boothId)){
                 
                newboothMapping.IsManagedbyAgent__c = true;
                newboothMapping.Agent_Contact__c = usr.Contactid;
            }
            lstboothMapping.add(newboothMapping);
        }
        //Insert exhibitor and contartor map for expocad booth
        if(Schema.sObjectType.BoothContractorMapping__c.IsCreateable())
        {
            insert lstboothMapping;
        } 

        // Added this functionality to edit contact record of the respective Stand Contractor[CCEN-654];
        if(!String.isEmpty(con.Id) && !selfManaged)
        {
            List<Contact> updateCon = new List<Contact>();
            List<Contact> lstCon = new List<Contact>();
            if(Schema.sObjectType.Contact.isAccessible())
            {
                lstCon = [SELECT Id, Contact_Type__c, Type__c,FirstName, LastName, MobilePhone ,Phone,Email FROM Contact WHERE Id = :con.Id];
            }
            if(lstCon != null && lstCon.size()>0) 
            {
                
                for(Contact oUpdateCon : lstCon)
                {   
                    oUpdateCon.FirstName = con.FirstName;
                    oUpdateCon.LastName = con.LastName;
                    oUpdateCon.Email = con.Email;
                    oUpdateCon.MobilePhone = con.MobilePhone;
                    oUpdateCon.Phone = con.Phone;
                    updateCon.add(oUpdateCon); 
                }   
            }
            if(updateCon != null && updateCon.size()>0 && Schema.sObjectType.Contact.isUpdateable())
            {
                update updateCon; 
            }
        }        
        //create service and contact mapping
        list<CustomerContractorService__c> newServiceMaplst = new list<CustomerContractorService__c>();
        for(BoothContractorMapping__c boothMap :  lstboothMapping){ 
            for(string srvcId :  lstServices){ 
                CustomerContractorService__c newServiceMap = new CustomerContractorService__c();
                newServiceMap.Event_Edition__c=sEventId;
                newServiceMap.ContractorService__c=srvcId;
                newServiceMap.BoothContractorMapping__c=boothMap.Id;
                newServiceMaplst.add(newServiceMap);
            }           
            if(con.Contact_Type__c=='Stand Contractor')
            {                            
                string msg = StandContractorUtils.approveStandContractor(boothMap.Id,'opsAdmin');
                System.debug('Exhibitors Without Contractor Approval for BOOTH CON MAP id : '+boothMap.Id +' is  '+ msg);
                disableInviteMail = true;                
            }
        }
        //Insert Contractor service map 
        if(Schema.sObjectType.CustomerContractorService__c.IsCreateable())
        {
            insert newServiceMaplst; 
        }
        if(string.isNotBlank(objTempConId) && !disableInviteMail && users.isEmpty())
        {
            // CCEN-389 Calling the sendEmailToOpsAdmin method of class EmailConfirmToContractorForBoothStatus
            EmailConfirmToContractorForBoothStatus.sendEmailToOpsAdmin('SCWA', sEventId,lstBoothIds); 
        }

        // if user not exits Invitation Email should be send to stand contractor only after the approval is done from ops admin. [CCEN-457]
        if(!String.isEmpty(con.Id) && lstboothMapping.size()>0 && !selfManaged &&!users.isEmpty() && !disableInviteMail)
        {
            if(isMapExists)
            {
                StandContractorUtils.sendEmailToContractorByCode(sEventId,'ISC',con,lstBoothIds); 
            }     
        }    
    }
    // create Contact EventEddition Maping for auto aproval Contractors 
    public static boolean checkContactEventMap(Contact con,string sEventId)
    {  
        boolean isMapExists = true;
        list<ContactEventEditionMapping__c> objContactEventEditionMapping = new list<ContactEventEditionMapping__c>();
        if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible())
        {
            objContactEventEditionMapping = [select id,SFContactID__c,SFEventEditionID__c from ContactEventEditionMapping__c where SFContactID__c =:con.Id and SFEventEditionID__c =: sEventId and Status__c= true];
        }
        if(objContactEventEditionMapping.isEmpty() && Schema.sObjectType.User_Type__c.isAccessible())
        {
            isMapExists=false;
            list<User_Type__c> lstUserType = [select id,name from User_Type__c Where name='Stand Contractor'];
            if(!lstUserType.isEmpty() && Schema.sObjectType.ContactEventEditionMapping__c.IsCreateable())
            {
                ContactEventEditionMapping__c newConEveEdtMap = new ContactEventEditionMapping__c();
                newConEveEdtMap.SFContactID__c=con.Id;
                newConEveEdtMap.SFEventEditionID__c=sEventId;
                newConEveEdtMap.User_Type__c=lstUserType[0].Id;
                newConEveEdtMap.Status__c = true;
                insert newConEveEdtMap;
            } 
        }
        return isMapExists;
    }
    @AuraEnabled //update contractor sevices
    public static string updateServices(string sMapId,string sEventId, list<string> lstServices)
    {
        string msg='Services Updated';
        //Delete exisitng services map and create new one
        delete [select id from CustomerContractorService__c where BoothContractorMapping__c=:sMapId];
        
        //create service and contact mapping
        list<CustomerContractorService__c> newServiceMaplst = new list<CustomerContractorService__c>();
        for(string srvcId :  lstServices)
        { 
            CustomerContractorService__c newServiceMap = new CustomerContractorService__c();
            newServiceMap.Event_Edition__c=sEventId;
            newServiceMap.ContractorService__c=srvcId;
            newServiceMap.BoothContractorMapping__c=sMapId;
            newServiceMaplst.add(newServiceMap);
        }
        insert newServiceMaplst;
        return msg;
    }
    @AuraEnabled //Fetch duplicate accounts
    public static List<sObject> getDuplicateRecords(sObject obj) 
    {
        List<sObject> dupobj = new List<sObject>();
        try
        {            
            List<sObject> objList = new List<sObject>();
            objList.add(obj);
            
            Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(objList);
            for (Datacloud.FindDuplicatesResult findDupeResult : results) 
            {
                for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) 
                {
                    for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) 
                    {
                        for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) 
                        {                            
                            //Adding duplicate records in list
                            dupobj.add(matchRecord.getRecord());
                        } 
                    }
                }
            }   
        }
        catch(Exception ex)
        {
            System.debug('The following exception has occurred: ' + ex.getMessage());
        }
        return dupobj;
    }
    @AuraEnabled //Fetch duplicate accounts
    public static List<sObject> getDuplicateContacts(contact con)
    {
        List<sObject> lstDupCon = getDuplicateRecords(con);
        return lstDupCon;
    }

    @AuraEnabled //Create temporary contractor company
    public static map<string,sObject>  createTempAccount(account acc)
    {
        map<string,sObject> maptemp=new map<string,sObject>();
        TempAccount__c newTempAcc=new TempAccount__c();
        //Check duplicate reord
        list<sObject> lstResults = getDuplicateRecords(acc);
        if(lstResults.size()>0)
        {
                maptemp.put('error',lstResults[0]);
        }
        else if(Schema.sObjectType.TempAccount__c.IsCreateable())
        {
            //Create new record
            newTempAcc.Name=acc.Name;
            newTempAcc.Address__c=acc.BillingStreet;
            newTempAcc.City__c=acc.BillingCity;
            newTempAcc.State__c=acc.BillingState;
            newTempAcc.Zip__c=acc.BillingPostalCode;    
            newTempAcc.Country__c=acc.BillingCountry;
            insert newTempAcc;
            maptemp.put('success',newTempAcc);
        }
        return maptemp;
    }
    @AuraEnabled //Fetch contractor contacts
    public static contact getContactByID(String sId)
    { 
        list<contact> lstcon = new list<contact>();
        if(Schema.sObjectType.contact.isAccessible())
        {
            lstcon = [select Id,Name,FirstName,LastName,Account.Name,Phone,MobilePhone,Email,Fax from contact where Id=:sId];
        }
        
        return lstcon[0];
    }
    @AuraEnabled //Fetch contractor services
    public static list<ContractorService__c> getServices(String sEventcode)
    {
        list<ContractorService__c> lstSonServices = new list<ContractorService__c>();
        if(Schema.sObjectType.ContractorService__c.isAccessible())
        {
            lstSonServices = [SELECT Id, Name, Event_Edition__c,Contractor_Service__c, Visible__c FROM ContractorService__c where Visible__c=true and Event_Edition__r.Event_Code__c =:sEventcode order by createddate desc limit 100];
        }
        return lstSonServices;
    }
    @AuraEnabled //Remove booth, contact mapping
    public static string removeContact(String sMapId)
    {
        string msg='Contact has been removed';
        list<BoothContractorMapping__c> lstBoothMap = getBoothConMapById(sMapId);
        if(lstBoothMap.Size()>0 && BoothContractorMapping__c.sObjectType.getDescribe().isDeletable())
        {
            if(!lstBoothMap[0].Is_Self_Managed__c && String.isNotEmpty(lstBoothMap[0].Contact__c))
            {
                Contact con = getContactByID(lstBoothMap[0].Contact__c);
                list<string> lstBoothIds = new list<string>();
                lstBoothIds.add(lstBoothMap[0].Opp_Booth_Mapping__c);
                try
                {
                    StandContractorUtils.sendEmailToContractorByCode(lstBoothMap[0].Event_Edition__c,'CSC',con,lstBoothIds);  // Expocad Change [CCEN-742]
                }
                catch(Exception ex)
                {
                    msg=ex.getMessage();
                    system.debug('msg'+msg);
                }
                
            }
            delete lstBoothMap;
            deleteSubContarctors(sMapId);
        } 
        return msg;
    }
    public static list<BoothContractorMapping__c> getBoothConMapById(String sMapId)
    {
        list<BoothContractorMapping__c> lstBoothMap = [SELECT Id,Contact__r.Name,Opp_Booth_Mapping__c,Contact__r.Email, Event_Edition__c,Event_Edition__r.Name,ExpocadBooth__r.Account__r.Name,ExpocadBooth__r.Booth_Number__c,Is_Self_Managed__c FROM BoothContractorMapping__c  where Id=:sMapId];
        return lstBoothMap;
    }
    public static void deleteSubContarctors(String sMapId)
    {
        delete [SELECT Id FROM BoothContractorMapping__c where Parent_BoothMapping__c=:sMapId];
    }
    @AuraEnabled //Delete temp account
    public static string deleteTempAccount(String tempAccId)
    {
        list<TempAccount__c> lstTempAcc = new list<TempAccount__c>();
        if(Schema.sObjectType.TempAccount__c.isAccessible() && TempAccount__c.sObjectType.getDescribe().isDeletable())
        {
            lstTempAcc = [SELECT Id FROM TempAccount__c where Id=:tempAccId];
            delete lstTempAcc;
        } 
        return 'Temp account has been deleted';
    }
     @AuraEnabled //fetch picklist values.
    public static List<String> getPicklistValues(String objApi,String fieldName)
    { 
        List<String> lstPickvals=new List<String>();    
        lstPickvals = UtilityMethods.getPicklistValues(objApi,fieldName);
        return lstPickvals;  
    }
    // fetch dependent picklist for country and state code CCEN -266
    @AuraEnabled// Fetch custom picklist values from custom Setting mdt related code towards country[(BK-2347)]
    public static String getDepndentCustom(String cCountryCode)
    { 
        return ExhibitorsWithoutContractorsCtrl.getDepndentCustomVal(cCountryCode);
       
    }
    @AuraEnabled // Fetch custom picklist values from custom Setting mdt related code towards country[(BK-2347)]
    public static String getCountryNameRelatdCode(String cCountryName)
    { 
        return ExhibitorsWithoutContractorsCtrl.getCountryRelatdCode(cCountryName); 
    }
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(string objApi, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objApi);
        Sobject objectName = targetType.newSObject();
        Schema.sObjectType objType = objectName.getSObjectType();
        if (objType==null)
        {
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String val = ple.getValue();
            objResults.put(val, new List<String>());
            controllingValues.add(val);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String val = plew.label+'__$__'+plew.value ;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(val);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) {
            return '';
        }
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = BASE64CHARS.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String BASE64CHARS = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> pLEs) 
    {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(pLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper
    {
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}      
    }

    // get current user type from contactEventEditionMaping of login user 
    @AuraEnabled 
    public static ContactEventEditionMapping__c getCurrentUserType(String sEventcode)
    {   
        list<ContactEventEditionMapping__c> lstconEvnMp = new list<ContactEventEditionMapping__c>();
        ContactEventEditionMapping__c objConEvnMap= new ContactEventEditionMapping__c();
        lstconEvnMp = [select Id,User_Type__r.Name,SFContactID__r.Account.Name from ContactEventEditionMapping__c where SFEventEditionID__r.Event_Code__c =:sEventCode and Status__c= true and SFContactID__c in (SELECT Contactid FROM User WHERE Id = : UserInfo.getUserId()) ];
        system.debug('lstconEvnMp'+lstconEvnMp);
        if(lstconEvnMp.size()>0 )
        {  
           objConEvnMap= lstconEvnMp[0];
        }               
        return objConEvnMap;
    }
    
    @AuraEnabled //Fetch agents booth CCEN-431
    public static  map<string,list<BoothContractorMapping__c>> getBoothsMappingPavillion(String sEventcode)
    {   
        set<id> boothids= new set<id>();
        User usr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()]; 
        
        map<string,list<BoothContractorMapping__c>> mapBooths = new map<string,list<BoothContractorMapping__c>>();
        list<BoothContractorMapping__c> obj= new list<BoothContractorMapping__c>();
        mapBooths.put('View All',obj);

        //Fetch Stand Details
        Map<String,Stand_Detail__c> mapAccStndDetail =UtilityMethods.getStandDetail(sEventcode);

        //Fetch Stand Designs
        Map<String,Stand_Design__c> mapAccStndDesign=UtilityMethods.getStandDesign(sEventcode);

        for(BoothContractorMapping__c sBoothMap :  [select Id,Agent_Contact__c,IsManagedbyAgent__c,ExpocadBooth__c,ExpocadBooth__r.Matched_Product_Name__c,ExpocadBooth__r.Booth_Number__c,TempContact__r.TempAccount__r.Name,TempContact__c,TempContact__r.Account__r.Name,TempContact__r.Name__c,Contact__c,Contact__r.Name,contact__r.AccountId,Contact__r.Account.Name,ContractorRequestStatus__c,Booth_Design_Status1__c,Booth_Detail_Status1__c,Booth_Design_Status__c,Booth_Detail_Status__c,Is_Self_Managed__c,(select Id,ContractorService__r.Contractor_Service__c from CustomerContractorServices__r)  from BoothContractorMapping__c where  ExpocadBooth__c= null and Event_Edition__r.Event_Code__c =:sEventcode and Parent_BoothMapping__c='' and Agent_Contact__c=:usr.Contactid limit 1000])
        {
            string sKey='View All';
            if(mapBooths.containsKey(sKey))
            {
                list<BoothContractorMapping__c> lstmap = mapBooths.get(sKey);
                string boothKey=string.valueof(sBoothMap.contact__r.AccountId)+'_'+string.valueof(sBoothMap.ExpocadBooth__c);

                //Check Stand Details Status
                if(mapAccStndDetail.containsKey(boothKey))
                {
                    sBoothMap.Booth_Detail_Status1__c= mapAccStndDetail.get(boothKey).Booth_Detail_Status__c;
                }
                else
                {
                    sBoothMap.Booth_Detail_Status1__c='Not Submitted';//Set default status 
                }
                //Check Stand Design Status
                if(mapAccStndDesign.containsKey(boothKey)){
                    sBoothMap.Booth_Design_Status1__c = mapAccStndDesign.get(boothKey).Booth_Design_Status__c;
                }
                else
                {
                    sBoothMap.Booth_Design_Status1__c='No Design'; //Set default status 
                }
                lstmap.add(sBoothMap); 
                mapBooths.put(sKey,lstmap);  
            } 
        } 
        return mapBooths;
    }
    @AuraEnabled //Fetch pavailion space booths for agent CCEN-431
    public static list<Opportunity_ExpoCAD_Booth_Mapping__c>  getPavilionSpaceExhibitors(String sEventcode,string accId,string srchText) 
    {         
        User usr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()]; 
        string accountId=usr.Accountid;    
        list<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpoBooths=new list<Opportunity_ExpoCAD_Booth_Mapping__c>();
        lstExpoBooths = StandContractorUtils.getPavilionSpaceExhibitorsBooths(sEventcode,accountId,srchText);
        return lstExpoBooths;        
    }
    
    /* Regarding Ticket BK-2345 Start */
    @AuraEnabled
    public static List<account> PrefContractors(string EventCode , string srchText)
    {
        system.debug('testEvnt'+EventCode);
        List<String> tempList = new List<String>();
        Event_Edition__c evntEdtn = new Event_Edition__c();
        evntEdtn=[select id , name , Preferred_Contractors__c  from Event_Edition__c where Event_Code__c=:EventCode limit 1];
        if(evntEdtn.Preferred_Contractors__c!=null)
        {
            tempList.addall(evntEdtn.Preferred_Contractors__c.split(';'));
        }
        //system.debug('evntEdtn'+evntEdtn);
        //system.debug('tempList'+tempList); 
        String strQuery = 'select Id,Name,BillingCountry,(select Id,Name,Contact_Type__c  from contacts) from account where id IN:tempList';       
        if(String.isNotEmpty(srchText)) 
        {
            string whereClause = '%' + String.escapeSingleQuotes(srchText) + '%';
            strQuery+=' and Name like :whereClause ';
        }
        strQuery+=' order by name asc limit 100';
        list<account> preferrdAccs = new list<account>();
        preferrdAccs = Database.query(strQuery);  
        system.debug('preferrdAccs'+preferrdAccs);
       return preferrdAccs;
    }
    /* Regarding Ticket BK-2354 End */
}