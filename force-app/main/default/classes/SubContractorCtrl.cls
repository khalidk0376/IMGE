/**
    @Created By     :   Girikon(Divaker)
    @Created On     :   03/06/2018
    @Modified by    :   Girikon(Sunil)[CCEN-90 (Aug 7 2018),CCEN-530 (Dec 20 2018),CCEN-592 (Jan 22 2019)],Girikon(Garima)[CCEN-756 April 3 2019]
    @description    :   View subcontractors for the booth.          
    @Test Class     :   SubContractorCtrl_Test(89%)
**/
    public without sharing  class SubContractorCtrl 
    {
    @AuraEnabled //Fetch event details
    public static Event_Settings__c getEventDetails(String sEventcode)
    {
        return UtilityMethods.getEventDetails(sEventcode); 
    }
    @AuraEnabled //Fetch Exhibitors
    public static list<BoothContractorMapping__c> getExhibitors(String sEventcode)
    {
        User usr = new user();
        if(Schema.sObjectType.User.isAccessible()) {
            usr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()];
        }
        list<BoothContractorMapping__c> lstboothmap = new list<BoothContractorMapping__c>();
        if(Schema.sObjectType.BoothContractorMapping__c.isAccessible()) {
            lstboothmap =  [select Id,Opp_Booth_Mapping__c,Parent_BoothMapping__r.Opp_Booth_Mapping__r.Opportunity__r.Account.Name,Opp_Booth_Mapping__r.Opportunity__r.Account.Name,Opp_Booth_Mapping__r.Booth_Number__c,Opp_Booth_Mapping__r.Display_Name__c,  TempContact__r.Is_SubContractors_Available__c,TempContact__r.TempAccount__r.Name,ContractorRequestStatus__c,TempContact__r.Name__c,Parent_BoothMapping__c,Amount__c ,Createdby.Contact.Account.Name,(select Id,ContractorService__r.Contractor_Service__c from CustomerContractorServices__r)  from BoothContractorMapping__c where contact__c=:usr.Contactid];       
        }  
        return lstboothmap;
    }
    @AuraEnabled //Fetch mapping by id
    public static BoothContractorMapping__c getExhibitorMapbyId(String mapId)
    {
        list<BoothContractorMapping__c> lstboothmap = new list<BoothContractorMapping__c>();
        if(Schema.sObjectType.BoothContractorMapping__c.isAccessible()) {
            lstboothmap =  [select Id,Parent_BoothMapping__r.ExpocadBooth__r.Opportunity__r.Account.Name,ExpocadBooth__r.Opportunity__r.Account.Name,ExpocadBooth__c,ExpocadBooth__r.Booth_Number__c,ExpocadBooth__r.Open_Corners__c,ExpocadBooth__r.Dimensions__c,ContractorRequestStatus__c,Stand_Height__c,Is_One_side_open_stand__c,Is_Two_side_open_stand__c,Is_Three_side_open_stand__c,Island_Booth_4_sides__c,IsRigging__c,Rigging_Height__c,IsDoubleDecker__c ,
            Createdby.Contact.Account.Name  from BoothContractorMapping__c where id=:mapId ];
        }
        return lstboothmap[0];
    }

    @AuraEnabled //fetch contractor status values
    public static list<string> getContartorStatus()
    { 
        list<string> listState= new list<string>();
        Schema.DescribeFieldResult fieldResult = BoothContractorMapping__c.ContractorRequestStatus__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //System.debug('Picklist::'+ple);
        for( Schema.PicklistEntry f : ple){
            //System.debug(f.getLabel() +'::'+ f.getValue());
            listState.add(f.getValue() +'__$__'+ f.getLabel() );
        }
        return listState;
    }

    @AuraEnabled //Fetch contractor services
    public static list<ContractorService__c> getServices(String sEventcode)
    {
        list<ContractorService__c> lstSonServices = new list<ContractorService__c>(); 
        if(Schema.sObjectType.ContractorService__c.isAccessible()) {
            lstSonServices = [SELECT Id, Name, Event_Edition__c,Contractor_Service__c, Visible__c FROM ContractorService__c where Visible__c=true and Event_Edition__r.Event_Code__c =:sEventcode];
        }
        return lstSonServices;
    }

    @AuraEnabled // Add subcontractor for a Contractor
    public static string createSubConMapping(contact con,string eventId,string tempAcc,list<string> lstServices,Id boothId,string accName,string country)
    {
        User usr = new user();
        if(Schema.sObjectType.User.isAccessible()) {
            usr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()];
        }
        BoothContractorMapping__c lstBoothsingle;
        if(Usr.Contactid !=null && !Test.isRunningTest()){
            lstBoothsingle = [SELECT Id FROM BoothContractorMapping__c WHERE Opp_Booth_Mapping__c=:boothId AND Event_Edition__c=:eventId AND contact__c=:Usr.Contactid LIMIT 1];
        }
        else{
                lstBoothsingle = [SELECT Id FROM BoothContractorMapping__c WHERE Opp_Booth_Mapping__c=:boothId AND Event_Edition__c=:eventId  LIMIT 1];
        }
        string msg='success';
        try
        {
            list<BoothContractorMapping__c> lstExistMap = new list<BoothContractorMapping__c>();
            string name=con.FirstName+' '+con.LastName;
            TempAccount__c otemAcc = new TempAccount__c();
            if(accName != null){
            otemAcc.Name = accName;
            otemAcc.Country__c = country;
            }
            if(Schema.sObjectType.TempAccount__c.IsCreateable()) {
                insert otemAcc;
            }
            TempContact__c objTempCon =new TempContact__c();
            if(String.isEmpty(con.Id)){
                objTempCon.Email__c=con.Email;
                objTempCon.FirstName__c=con.FirstName;
                objTempCon.LastName__c=con.LastName;
                objTempCon.MobilePhone__c=con.MobilePhone;
                objTempCon.Account__c=con.AccountId;
                objTempCon.Is_SubContractors_Available__c=true;
                if(otemAcc != null){
                    objTempCon.TempAccount__c=otemAcc.id;
                }
                if(Schema.sObjectType.TempContact__c.IsCreateable()){
                    insert objTempCon;
                }
            }
            //create booth and contact mapping
            if(lstBoothsingle !=null)
            {
                BoothContractorMapping__c newboothMapping = new BoothContractorMapping__c();
                newboothMapping.TempContact__c=objTempCon.Id;
                newboothMapping.Event_Edition__c=eventId;
                newboothMapping.ContractorRequestStatus__c='Pending'; 
                newboothMapping.Status__c='Pending'; 
                newboothMapping.Opp_Booth_Mapping__c=boothId; 
                newboothMapping.Parent_BoothMapping__c=lstBoothsingle.Id; 
                if(Schema.sObjectType.BoothContractorMapping__c.IsCreateable()) {
                    insert newboothMapping;
                }
                //create service and contact mapping
                list<CustomerContractorService__c> newServiceMaplst = new list<CustomerContractorService__c>();
                for(string srvcId :  lstServices)
                { 
                    CustomerContractorService__c newServiceMap = new CustomerContractorService__c();
                    newServiceMap.Event_Edition__c=eventId;
                    newServiceMap.ContractorService__c=srvcId;
                    newServiceMap.BoothContractorMapping__c=newboothMapping.Id;
                    newServiceMaplst.add(newServiceMap);
                }
                if(Schema.sObjectType.CustomerContractorService__c.IsCreateable()) {
                    insert newServiceMaplst;
                }   
            }
        }
        catch(Exception ex)
        {
            msg=ex.getMessage();
        }
        return msg;
    }

    @AuraEnabled //Fetch contractor booth
    public static map<string,list<BoothContractorMapping__c>> getBoothsMapping(String sEventcode)
    {
        map<string,list<BoothContractorMapping__c>> mapBooths = new map<string,list<BoothContractorMapping__c>>();
        list<BoothContractorMapping__c> lstmapUpdate = new list<BoothContractorMapping__c>();
        User usr = new user();
        if(Schema.sObjectType.User.isAccessible()) {
            usr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()];
        }
        system.debug('Usr'+Usr);
        list<BoothContractorMapping__c> lstboothmap = new list<BoothContractorMapping__c>();
        if(Schema.sObjectType.BoothContractorMapping__c.isAccessible() && Schema.sObjectType.CustomerContractorService__c.isAccessible())
        {
            lstboothmap =  [select Id,Opp_Booth_Mapping__c,Parent_BoothMapping__r.Opp_Booth_Mapping__r.Opportunity__r.Account.Name,Opp_Booth_Mapping__r.Opportunity__r.Account.Name,TempContact__c,Opp_Booth_Mapping__r.Booth_Number__c,Opp_Booth_Mapping__r.Display_Name__c,TempContact__r.Is_SubContractors_Available__c,TempContact__r.TempAccount__r.Name,ContractorRequestStatus__c,TempContact__r.Name__c,Parent_BoothMapping__c,Amount__c ,Createdby.Contact.Account.Name,(select Id,ContractorService__r.Contractor_Service__c from CustomerContractorServices__r)  from BoothContractorMapping__c where Opp_Booth_Mapping__c != null And contact__c=:Usr.Contactid And Event_Edition__r.Event_Code__c =:sEventcode and ContractorRequestStatus__c='Accepted']; 
        }
        
        for(BoothContractorMapping__c sBooth : lstboothmap)
        {           
            string sKey=sBooth.Opp_Booth_Mapping__r.Booth_Number__c+'_$_'+sBooth.Opp_Booth_Mapping__r.Id;
            list<BoothContractorMapping__c> lstmap = new list<BoothContractorMapping__c>();
            lstmap.add(sBooth); 
            mapBooths.put(sKey,lstmap);        
        }  
        
        for(BoothContractorMapping__c sBoothMap :   [select Id,TempContact__c,Opp_Booth_Mapping__c,Opp_Booth_Mapping__r.Booth_Number__c,Opp_Booth_Mapping__r.Display_Name__c,TempContact__r.Is_SubContractors_Available__c,TempContact__r.TempAccount__r.Name,ContractorRequestStatus__c,TempContact__r.Name__c,Parent_BoothMapping__c,Amount__c ,Parent_BoothMapping__r.Createdby.Contact.Account.Name,Opp_Booth_Mapping__r.Opportunity__r.Account.Name, (select Id,ContractorService__r.Contractor_Service__c from CustomerContractorServices__r)  from BoothContractorMapping__c where TempContact__r.Is_SubContractors_Available__c=true AND Event_Edition__r.Event_Code__c =:sEventcode])
        {            
            string sKey=sBoothMap.Opp_Booth_Mapping__r.Booth_Number__c+'_$_'+sBoothMap.Opp_Booth_Mapping__r.Id;
            if(mapBooths.containsKey(sKey))
            {               
                lstmapUpdate  = mapBooths.get(sKey); 
                lstmapUpdate.add(sBoothMap);
                mapBooths.put(sKey,lstmapUpdate);  
            } 
        }
        for(String key: mapBooths.Keyset())
        {
            lstmapUpdate  = mapBooths.get(key);
            if(lstmapUpdate.size()>1)
            {
                lstmapUpdate.remove(0);
            }
            mapBooths.put(key,lstmapUpdate);   
                
        }   
        system.debug('mapBooths================>>'+JSON.serialize(mapBooths));     
        return mapBooths;
    }   

    @AuraEnabled // Grt sub contractor by map id.
    Public static List<BoothContractorMapping__c> getSubContractor (String sMapId){

        List<BoothContractorMapping__c> lstBooth = new List<BoothContractorMapping__c>();
        if(Schema.sObjectType.BoothContractorMapping__c.isAccessible() && Schema.sObjectType.CustomerContractorService__c.isAccessible()) {
            lstBooth = [select Id,Opp_Booth_Mapping__c,Opp_Booth_Mapping__r.Booth_Number__c, TempContact__r.TempAccount__r.Country__c,TempContact__c,TempContact__r.TempAccount__c,TempContact__r.FirstName__c,TempContact__r.LastName__c, TempContact__r.MobilePhone__c,TempContact__r.Email__c,TempContact__r.Is_SubContractors_Available__c,TempContact__r.TempAccount__r.Name,ContractorRequestStatus__c,TempContact__r.Name__c,Parent_BoothMapping__c,Amount__c ,Createdby.Contact.Account.Name,(select Id,ContractorService__r.Contractor_Service__c ,Name from CustomerContractorServices__r)  from BoothContractorMapping__c where Id=:sMapId];
        }
        return lstBooth;
    }

    @AuraEnabled //Update account contacts of sub contractors
    public static string updateContact(list<string> lstServices,string accName,string fName,string lName,string email,string mobile,string country,string conId,string accId,string mapId){
        List<TempAccount__c> updateAcc = new List<TempAccount__c>();
        List<TempContact__c> updateCon = new List<TempContact__c>();
            List<TempContact__c> lstContact = new  List<TempContact__c>();
        if(Schema.sObjectType.TempContact__c.isAccessible())
        {
            lstContact = [SELECT Id, Name__c, Phone__c, FirstName__c, LastName__c, Email__c FROM TempContact__c WHERE Id = :conId];
        }
        if(lstContact.size()>0){
            for(TempContact__c oCon : lstContact){
                oCon.FirstName__c = fName; 
                oCon.LastName__c = lName;
                oCon.MobilePhone__c = mobile;
                oCon.Email__c = email;
                UpdateCon.add(oCon);
            }
            if(UpdateCon.size()>0 && Schema.sObjectType.TempContact__c.isUpdateable()){
                update updateCon;
            } 
        }
        List<TempAccount__c> lstAcc = new List<TempAccount__c> ();
        if(Schema.sObjectType.TempAccount__c.isAccessible())
        {
            lstAcc = [SELECT Id, Name, Country__c FROM  TempAccount__c WHERE Id = :AccId];
        }
        if(lstAcc.size()>0){
            for(TempAccount__c oAcc:lstAcc){
                oAcc.Name = accName;
                oAcc.Country__c = country;
                UpdateAcc.add(oAcc);
            }
            if(UpdateAcc.size()>0){
                update UpdateAcc;
            }
        }
        BoothContractorMapping__c lstBooth = new  BoothContractorMapping__c();
        if(Schema.sObjectType.BoothContractorMapping__c.isAccessible())
        {
            lstBooth = [SELECT Id,Event_Edition__c FROM BoothContractorMapping__c WHERE TempContact__c=:conId];
        }
        list<CustomerContractorService__c> newServiceMaplst = new list<CustomerContractorService__c>();
        for(string srvcId :  lstServices)
        {           
            CustomerContractorService__c newServiceMap = new CustomerContractorService__c();
            newServiceMap.Event_Edition__c=lstBooth.Event_Edition__c;
            newServiceMap.ContractorService__c=srvcId;
            newServiceMap.BoothContractorMapping__c=lstBooth.Id;
            newServiceMaplst.add(newServiceMap);
        }
        if(newServiceMaplst.size()>0){
            if(CustomerContractorService__c.sObjectType.getDescribe().isDeletable())
            {
                delete [select id from CustomerContractorService__c where BoothContractorMapping__c=:lstBooth.Id];
            }
            if(Schema.sObjectType.CustomerContractorService__c.IsCreateable())
            {
                insert newServiceMaplst;
            }
        }
        return null;
    }

    @AuraEnabled //Delete Booth contractor map
    Public static string sDeleteRecord(string sBoothId){
        Delete ([SELECT Id FROM BoothContractorMapping__c WHERE ID=:sBoothId]);
        return null;
    }

    @AuraEnabled //fetch countries list
    public static list<string> getCountries()
    {
        list<string> listCountry= new list<string>();
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //System.debug('Picklist::'+ple);
        for( Schema.PicklistEntry f : ple){
            //System.debug(f.getLabel() +'::'+ f.getValue());
            listCountry.add(f.getValue() +'__$__'+ f.getLabel() );
        }
        return listCountry;
    }

    @AuraEnabled//Get Subcontractor List [CCEN-530],[CCEN-592]
    Public static List<BoothContractorMapping__c> getSubcontactor(string sEventId,string boothMapId){

        string query = 'select Id,Name, Opp_Booth_Mapping__r.Booth_Number__c, Opp_Booth_Mapping__r.Opportunity__r.Account.Name,Opp_Booth_Mapping__r.Display_Name__c,Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c, Parent_BoothMapping__r.Contact__r.Account.Name,Parent_BoothMapping__r.Contact__r.Name,Parent_BoothMapping__r.Contact__r.Email,Parent_BoothMapping__r.Contact__r.MobilePhone,TempContact__r.Name__c,TempContact__r.FirstName__c,TempContact__r.LastName__c,TempContact__r.MobilePhone__c,TempContact__r.Email__c,TempContact__r.TempAccount__r.Name,createddate,(select Id,ContractorService__r.Contractor_Service__c from CustomerContractorServices__r)  from BoothContractorMapping__c where TempContact__r.Is_SubContractors_Available__c=true AND Parent_BoothMapping__c != null And Parent_BoothMapping__r.Contact__r.Account.Name != null And Event_Edition__c=:sEventId';

        if(String.isNotBlank(boothMapId)) 
        {
            query+=' and Parent_BoothMapping__c =:boothMapId ';
        }
        List<BoothContractorMapping__c> lstboothmap = new List<BoothContractorMapping__c> ();
        if(Schema.sObjectType.BoothContractorMapping__c.isAccessible() && Schema.sObjectType.CustomerContractorService__c.isAccessible()) {
            lstboothmap = Database.query(query);
        }
        
        system.debug('lstboothmap'+lstboothmap);
        
        return lstboothmap;
    }
    }