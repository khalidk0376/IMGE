/**
 * Created By       :   Girikon(Ashish) C2E-17
 * Created On       :   21 Aug 2019
 * @description     :   This class provides following functionalities:          
*                       Allow Agents to assign Stand contractor on their exhibitors behalf
 * Helper Class     :   UtilityMethods,StandContractorCtrlUtils
 * Test Class       :   AOE_StandContractorCtrl_Test(83%)
 
 * Modification log --
 * Modified by      :   
 **/
public without sharing class AOE_StandContractorCtrl {

    @AuraEnabled //Fetch event details
    public static Event_Settings__c getEventDetails(String sEventcode)
    {
        //Get event details
        return UtilityMethods.getEventDetails(sEventcode);
    }

    @AuraEnabled //Fetch AOE contractor And booth 
    public static map<string,list<BoothContractorMapping__c>> getAOEBoothsMapping(String sEventcode,string accId)
    {           
        return StandContractorUtils.getBoothsMappingFromAccId(sEventcode,accId);
    }
     
    @AuraEnabled //Fetch contractor accounts with contacts
    public static list<account> getAccountContacts(String sEventcode,String srchText)
    {
        return StandContractorCtrl.getAccountContacts(sEventcode,srchText) ;        
    }
    
    @AuraEnabled //Search contractor account
    public static account getAccount(String sEventcode,String srchText)
    {
        return StandContractorCtrl.getAccount(sEventcode,srchText) ;
    }

    //Create contractor company temporary contact, servives mapping, booth mapping
    //Check existing mapping 
    @AuraEnabled
    public static string createContactandMapping(contact con,string sEventId,string tempAccount,list<string> lstBoothIds,list<string> lstServices)
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
            list<Opportunity_ExpoCAD_Booth_Mapping__c> oppBoothsList = New list<Opportunity_ExpoCAD_Booth_Mapping__c>();
            if(String.isEmpty(con.Id) && String.isEmpty(con.AccountId) && String.isEmpty(tempAccount) && (lstBoothIds != null && lstBoothIds.size()>0))
            {
                //User usr = [SELECT Id, Contactid,Accountid,Account.Name  FROM User WHERE Id = : UserInfo.getUserId()];
                oppBoothsList = [select id,Opportunity__c,Opportunity__r.Operations_Contact__c,Opportunity__r.Operations_Contact__r.AccountId from Opportunity_ExpoCAD_Booth_Mapping__c where Opportunity__r.Operations_Contact__c != null And id in:lstBoothIds];
                if(oppBoothsList.size() >0)
                {
                    con.Id = oppBoothsList[0].Opportunity__r.Operations_Contact__c;
                    con.AccountId = oppBoothsList[0].Opportunity__r.Operations_Contact__r.AccountId;
                    selfManaged=true;
                    status='Accepted';
                }else
                {
                    msg = 'The Agent has no Operations Contact for the Booth!' ;  
                    return msg;    
                }               
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
        
            if(lstExistMap.size()>0)
            {
                msg='Error : Dupliacte Contractor Maping';
            }
            else
            {
                TempContact__c objTempCon = new TempContact__c();
                if(String.isEmpty(con.Id))
                {
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
                createContactMap(selfManaged,lstBoothIds,con,objTempCon.Id,sEventId,status,users,lstServices); 
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
    public static void createContactMap(boolean selfManaged,list<string> lstBoothIds,Contact con,string objTempConId,string sEventId,string status,list<User> users,list<string> lstServices)
    {      
        boolean disableInviteMail = false;
        boolean isMapExists = true;
        //create booth and contact mapping
        list<BoothContractorMapping__c> lstboothMapping = new list<BoothContractorMapping__c>();
        //User usr = [SELECT Id, Contactid,Accountid,Account.Name  FROM User WHERE Id = : UserInfo.getUserId()];
        for(string boothId :  lstBoothIds)
        {
            BoothContractorMapping__c newboothMapping = new BoothContractorMapping__c();
            newboothMapping.Contact__c=con.Id;
            newboothMapping.Is_Self_Managed__c=selfManaged;
            newboothMapping.TempContact__c=objTempConId;
            newboothMapping.Event_Edition__c=sEventId;
            if(String.isNotBlank(boothId))
            {
                newboothMapping.Opp_Booth_Mapping__c = boothId; 
            }
            newboothMapping.ContractorRequestStatus__c=status; 
            newboothMapping.Status__c=status; 
            if(!users.isEmpty())
            {
                newboothMapping.Approved__c = true;
                newboothMapping.Status__c = 'Accepted';
                newboothMapping.Approval_Date__c=System.now();
                isMapExists = StandContractorCtrl.checkContactEventMap(con,sEventId);
            }
            if(selfManaged)  // Customer Centre - All Assigned Contractors- designation status error 
            {
                newboothMapping.Status__c = status;  
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
        for(BoothContractorMapping__c boothMap :  lstboothMapping)
        { 
            for(string srvcId :  lstServices)
            { 
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
    @AuraEnabled //update contractor sevices
    public static string updateServices(string sMapId,string sEventId, list<string> lstServices)
    {
        return StandContractorCtrl.updateServices(sMapId,sEventId,lstServices);
    }
   
    @AuraEnabled //Fetch duplicate accounts
    public static List<sObject> getDuplicateContacts(contact con)
    {   
        List<sObject> lstDupCon = new List<sObject>();
        lstDupCon = StandContractorCtrl.getDuplicateContacts(con);
        return lstDupCon;
    }

    @AuraEnabled //Create temporary contractor company
    public static map<string,sObject>  createTempAccount(account acc)
    {
        return StandContractorCtrl.createTempAccount(acc) ;
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
        return StandContractorCtrl.removeContact(sMapId) ;       
    }

    @AuraEnabled 
    public static list<BoothContractorMapping__c> getBoothConMapById(String sMapId)
    {
        list<BoothContractorMapping__c> lstBoothMap = [SELECT Id,Contact__r.Name,Opp_Booth_Mapping__c,Contact__r.Email, Event_Edition__c,Event_Edition__r.Name,ExpocadBooth__r.Account__r.Name,ExpocadBooth__r.Booth_Number__c,Is_Self_Managed__c FROM BoothContractorMapping__c  where Id=:sMapId];
        return lstBoothMap;
    }

    @AuraEnabled 
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
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(string objApi, string contrfieldApiName,string depfieldApiName)
    {
        return StandContractorCtrl.getDependentMap(objApi,contrfieldApiName,depfieldApiName);
    }

    // get current user type from contactEventEditionMaping of login user 
    @AuraEnabled 
    public static ContactEventEditionMapping__c getCurrentUserType(String sEventcode)
    {   
        return StandContractorCtrl.getCurrentUserType(sEventcode);        
    }       
}