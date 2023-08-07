/**
 * Created By   :   Girikon(Suraj,Sunil[CCEN-584 Jan 14,2018])
 * Modified By  :   Girikon(Garima[CCEN-779]), [Aishwarya BK-2025 July 26 2019] , [Himanshu BK - 1876]
 * Modified By  :   IBM (Srikanth [BK-18216] Feb 11, 2022 - getLastLogin()
 * Created On   :    10/01/2019
 * @description  :   Allow ops admin to generate reports .
 * Test Class   :   ExportAllReportsCtrl_Test(90%)
 * Modification :   Girikon[Rajeev BK-3082 4th March 2020]
 **/

public without sharing class ExportAllReportsCtrl {

    public string header{get;set;}  // variable to store the column names
    public List<wrapperClass> lstwrapper {get; set;}  // List of the wrapper class storing the data

    public class wrapperClass{                       // wrapper class to store all the data
        //For Match Product Type
        public string matchProType {get; set;}  // Opportunity_ExpoCAD_Booth_Mapping__c 's Booth_Product_Type__c 
        public string exhibitingName {get; set;}// Opportunity_ExpoCAD_Booth_Mapping__c 's Opportunity__r.Account.name
        public string oppname {get; set;} // Opportunity_ExpoCAD_Booth_Mapping__c 's Opportunity__r.name
        public string exhibitorOpConPerson {get; set;}// Opportunity_ExpoCAD_Booth_Mapping__c 's Opportunity__r.Operations_Contact__r.name
        public string exhibitorOpEmail {get; set;} // Opportunity_ExpoCAD_Booth_Mapping__c 's Opportunity__r.Operations_Contact__r.email
        public string exhibitorOpTel {get; set;} // Opportunity_ExpoCAD_Booth_Mapping__c 's Opportunity__r.Operations_Contact__r.phone
        public string exhibitorOpMob {get; set;} //Opportunity_ExpoCAD_Booth_Mapping__c 's Opportunity__r.Operations_Contact__r.MobilePhone
        public string exhibitorCountry {get; set;} //CCEN-779 
        
        public string strBooth {get; set;} //BoothContractorMapping__c's ExpocadBooth__r.Booth_Number__c
        public string strExhibitor {get; set;} //BoothContractorMapping__c's CreatedBy.Contact.Account.Name
        public string contractorPhone {get; set;} //BoothContractorMapping__c's Contact__r.Phone
        public string contractorMobilePhone {get; set;} //BoothContractorMapping__c's Contact__r.MobilePhone
        public string contractorEmail {get; set;} //BoothContractorMapping__c's Contact__r.Email
        public string contractorCompany {get; set;} //BoothContractorMapping__c's Contact__r.Account.Name   
        public string sContactsName {get; set;} //BoothContractorMapping__c's Contact__r.Name
        public string contractorCountry {get; set;} //CCEN-779
        
        public boolean boolRigging {get; set;} //Stand_Detail__c's IsRigging__c
        public boolean boolDblDckr {get; set;} //Stand_Detail__c's IsDoubleDecker__c
        public boolean boolHevyMachin {get; set;} //Stand_Detail__c's Is_Heavy_Machinery__c
        
        public string dBoothDsnSbmttdOn {get; set;} //Stand_Design__c's Booth_Design_Submitted_On__c
        public string sBoothStatus {get; set;} //Stand_Design__c's Booth_Design_Status__c
        public string area {get; set;} // Opportunity_ExpoCAD_Booth_Mapping__c's Area__c
        public string designationStatus {get; set;} //BoothContractorMapping__c's status__c
        public string contrUsername {get; set;} // User's username
        public string amount {get; set;}//Stand_Design__c's Amount__c
        public string exhUsername {get; set;} // User's username
        public boolean perfBond {get; set;}//Stand_Detail__c's Is_Received
        public Decimal standHeight {get; set;}//Stand_Design__c's Stand_Height__c
        public Decimal riggingHeight {get; set;} // Stand_Design__c's Rigging_Height__c
        public boolean isVehicles {get; set;}//Stand_Detail__c's Is_Vehicles__c

        // For Last Login
        public string name {get; set;} // User's Name
        public string accountName {get; set;}// User's Account.Name
        public string conEmail {get; set;}// User's contact.Name
        public string username {get; set;}// User's username
        public string emailSentDate {get; set;}//ContactEventEditionMapping__c's EmailSendDate 
        public string lastLoginDate {get; set;}// User's LastLoginDate
        public string userType {get; set;}// ContactEventEditionMapping__c's usertype
        
        //For Show Category
        public string companyName {get; set;}// Opportunity_ExpoCAD_Booth_Mapping__c 's Opportunity__r.Account.name
        public string boothconName {get; set;} // BoothContactInfo__c Contact__r.Name
        public string boothconPhone {get; set;} // BoothContactInfo__c Contact__r.Phone
        public string boothconEmail {get; set;} // BoothContactInfo__c Contact__r.Email 
        public string boothconWebsite {get; set;} // BoothContactInfo__c Contact__r.Website       
        public string standNumber {get; set;} // Stand_Detail__c's Name
        public string displayName {get; set;} // Opportunity_ExpoCAD_Booth_Mapping__c 's Opportunity__r.Account.name
        public string country {get; set;} // Opportunity_ExpoCAD_Booth_Mapping__c 's Opportunity__r.Account.BillingCountry
        
        
        // Common to all reports        
        public string sBoothType {get; set;}   
    }
    //Constructor to initialize the header and wrapper class list. 
    public ExportAllReportsCtrl(){
        lstwrapper = new List<wrapperClass>();        
        if(ApexPages.currentPage().getparameters().get('compName') == 'MatchProductType'){
            header = 'Booth Number,Area,Match Product Type,Booth Type,Exhibiting Name,Exhibitor Name,Opportunity Name,Exhibitor operation contact,Exhibitor Operations Email,Exhibitor Operations Mobile No,Exhibitor Operations Tel,Contractor Company name,Contractor Contact Name,Contractor Contact Mobile,Contractor Contact Tel,Contractor Contact Email,Desgination Status,Double Decker,Rigging,Heavy Machinery,Perfomance Bond,Amount,Booth Desgin submitted on,Status,Exhibitor Username,Contractor Username';            
        }

        if(ApexPages.currentPage().getparameters().get('compName') == 'LastLogin'){
            header = 'Name,Account Name,Contact Email,Username,Email Sent Date,LastLoginDate,User Type,Booth Type';            
        }
        
         //BK - 1876
        if(ApexPages.currentPage().getparameters().get('compName') == 'ShowCategory'){
            header = 'Company Name,Contact Name, Phone,Email,Website,Company Profile,Stand Number,Display Name,Country';            
        }
    }

    public void exportToExcel(){
        if(ApexPages.currentPage().getparameters().get('compName') == 'MatchProductType'){            
            this.getMatchProductType();            
        }
        if(ApexPages.currentPage().getparameters().get('compName') == 'LastLogin'){            
            this.getLastLogin();            
        }
        //BK - 1876
        if(ApexPages.currentPage().getparameters().get('compName') == 'ShowCategory'){            
            this.getShowCategory();            
        }       
    }
    //Gets the Login information of the users.
    public void getLastLogin()
    {
        string sEventId = ApexPages.currentPage().getparameters().get('event');   //eventId

        List<Event_Edition__c> event = new List<Event_Edition__c>();
        if(Schema.sObjectType.Event_Edition__c.isAccessible()){
            event = [Select Name from Event_Edition__c where Id=:sEventId]; //event details
        }
        
        
              

        List<user> userList = new List<user>();
        if(Schema.sObjectType.user.isAccessible()){
        
           Map<Id,User> UsrMap = new Map<Id,User>([select Id,UserName from user where contactId IN ( select Operations_Contact__c from Opportunity where stageName = 'Closed Won' and EventEdition__c=:sEventId)]);                           
           Set<Id> clsdWonuserIds = UsrMap.keySet();
           
            if(clsdWonuserIds!=null && !clsdWonuserIds.isEmpty()) {        
                userList = [select User.Name ,User.account.name,contact.Email,UserName,LastLoginDate,contactId from user where Id =: clsdWonuserIds and contactId IN (select SFContactID__c from ContactEventEditionMapping__c Where SFEventEditionID__c=:sEventId)]; // user list
            } else {
        
               userList = [select User.Name ,User.account.name,contact.Email,UserName,LastLoginDate,contactId from user where contactId IN (select SFContactID__c from ContactEventEditionMapping__c Where SFEventEditionID__c=:sEventId)]; // user list           
        
            }
        }

        List<ContactEventEditionMapping__c> conEventMapList = new List<ContactEventEditionMapping__c>();
        if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible()){
            conEventMapList =[select SFContactID__r.Email,Email_Sent__c,user_type__r.name from ContactEventEditionMapping__c Where SFEventEditionID__c=:sEventId AND Email_Sent__c != null];// contact event edition list
        }
        
        

        List<Opportunity_ExpoCAD_Booth_Mapping__c> boothList = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible())
        {
            boothList = [Select Id, Opportunity__r.account.name, Expocad_Booth__r.Booth_Type__c ,Event_Edition_Name__c from Opportunity_ExpoCAD_Booth_Mapping__c Where Event_Edition_Name__c =:event[0].Name];//booth list
        }
        Map<string,Object> mapconEventMapping = (Map<string,Object>)getMappedValues(conEventMapList);// map of contact id and contact event mapping
        Map<string,Object> boothMap = (Map<string,Object>)getMappedValues(boothList); // map of account name and expocad booth
        for(User userDetail : userList){ 
            wrapperClass objWrapperClass = new  wrapperClass (); // wrapper class to store the data
            objWrapperClass.name = userDetail.name;
            objWrapperClass.accountName = userDetail.account.name;
            objWrapperClass.conEmail = userDetail.contact.Email;
            objWrapperClass.username = userDetail.UserName;
            objWrapperClass.lastLoginDate =string.valueOf(userDetail.LastLoginDate);
            // DateTime tempDate = (DateTime)userDetail.LastLoginDate; // convert time to datetime object
            // if(tempDate !=null){
            //     objWrapperClass.lastLoginDate = tempDate.format('YYYY-MM-DD hh:mm');//('yyyy-MM-dd');
            // }
            ContactEventEditionMapping__c conEventMap = (ContactEventEditionMapping__c)mapconEventMapping.get(userDetail.contactId); // get contact event edition details from map
            if(conEventMap !=null){
                objWrapperClass.userType = conEventMap.user_type__r.name;
                // DateTime tempDate1 = (DateTime)conEventMap.Email_Sent__c ;// convert time to datetime object
                // if(tempDate1 != null){
                //     objWrapperClass.emailSentDate = tempDate1.format('YYYY-MM-DD hh:mm');
                // }
                objWrapperClass.emailSentDate =string.valueOf(conEventMap.Email_Sent__c);
            } 
           
        Opportunity_ExpoCAD_Booth_Mapping__c booth = (Opportunity_ExpoCAD_Booth_Mapping__c)boothMap.get(userDetail.account.name); // get booth details from map
        if(booth!=null){
            objWrapperClass.sBoothType = booth.Expocad_Booth__r.Booth_Type__c;
        }
           
        lstwrapper.add(objWrapperClass);
        }
    }
    //Gets the Matched product type booths information
    public void getMatchProductType()
    {
        string sEventId = ApexPages.currentPage().getparameters().get('event').escapeHtml4();  // eventID
        //CCEN-779
        string expoBoothQuery = 'SELECT id , Booth_Number__c,Display_Name__c,Opportunity__r.Operations_Contact__C,Expocad_Booth__r.Area__c,Expocad_Booth__r.Matched_Product_Name__c,Expocad_Booth__r.Booth_Type__c,Opportunity__r.name,Opportunity__r.Account.Name,Opportunity__r.Account.BillingCountry,Account__r.name,Account__r.Id,Opportunity__r.Operations_Contact__r.name,Opportunity__r.Operations_Contact__r.Account.Id,Opportunity__r.Operations_Contact__r.email,Opportunity__r.Operations_Contact__r.phone,Opportunity__r.Operations_Contact__r.MobilePhone ,Expocad_Booth__r.Status__c,Status__c from Opportunity_ExpoCAD_Booth_Mapping__c where Status__c = \'Active\' AND Opportunity__r.StageName=\'Closed Won\' AND Opportunity__r.EventEdition__c=\'' + String.escapeSingleQuotes(sEventId) +'\' AND Related_Opportunity__c=null AND Expocad_Booth__r.Status__c = \'Rented\'';
        
        list<Opportunity_ExpoCAD_Booth_Mapping__c> listexpocadBooth= Database.query(expoBoothQuery); // Expocad Booth List
        list<BoothContractorMapping__c> listBooth = new list<BoothContractorMapping__c>();
        if(Schema.sObjectType.BoothContractorMapping__c.isAccessible()){
            listBooth =[SELECT Opp_Booth_Mapping__c,Opp_Booth_Mapping__r.Booth_Number__c,Contact__c, Contact__r.account.name,Parent_BoothMapping__c,Contact__r.account.BillingCountry,Contact__r.Name,Contact__r.MobilePhone,Contact__r.Email,Contact__r.Phone,Status__c FROM BoothContractorMapping__c WHERE Opp_Booth_Mapping__c In :listexpocadBooth and Parent_BoothMapping__c=null];// booth Contact map list 
        }
        list<Stand_Design__c> listStndDesign = new list<Stand_Design__c>();
        if(Schema.sObjectType.Stand_Design__c.isAccessible()){
            listStndDesign=[Select Id,Opp_Booth_Mapping__c,Opp_Booth_Mapping__r.Booth_Number__c,Booth_Design_Submitted_On__c,Booth_Design_Status__c from Stand_Design__c WHERE Opp_Booth_Mapping__c In :listexpocadBooth]; // stand design list
        }
        list<User> userList = new list<User>();
        if(Schema.sObjectType.User.isAccessible()){
            userList=[select Account.name, AccountId, ContactId, Username FROM User where AccountID != null];// user list //BK-2025 adding ContactId
        }
        list<Stand_Detail__c> listStndDetail = new List<Stand_Detail__c>();
        if(Schema.sObjectType.Stand_Detail__c.isAccessible()){
            listStndDetail=[SELECT Opp_Booth_Mapping__c,Opp_Booth_Mapping__r.Booth_Number__c,Stand_Height__c,Rigging_Height__c,Is_Vehicles__c,IsDoubleDecker__c,IsRigging__c,Is_Heavy_Machinery__c,Amount__c,IsReceived__c FROM Stand_Detail__c WHERE Opp_Booth_Mapping__c In :listexpocadBooth]; // stand detail list
        }
        Map<string, Object> boothMap = (Map<string, Object>)getMappedValues(listBooth); // map of expocad booth Id and boothConMap
        Map<string,Object> stndDesignMap = (Map<string,Object>)getMappedValues(listStndDesign); // map of expocad booth Id and standdesign 
        Map<string,Object> userMap = (Map<string,Object>)getMappedValues(userList);// map of expocad account id and users
        Map<string,Object> stndDetailMap = (Map<string,Object> )getMappedValues(listStndDetail); // map of expocad booth id and stand details
        if(listexpocadBooth!=null && listexpocadBooth.size()>0)
        { 
            for(Opportunity_ExpoCAD_Booth_Mapping__c objExpoBooth:listexpocadBooth) // loop each expocad booth
            {
                User userDetail = (User)userMap.get(objExpoBooth.Opportunity__r.Operations_Contact__C); // get the user from the usermap
                BoothContractorMapping__c objBooth = (BoothContractorMapping__c)boothMap.get(objExpoBooth.Id);// get the booth contrator mapping from boothMap
                Stand_Design__c objDesign = (Stand_Design__c)stndDesignMap.get(objExpoBooth.Id);// get stand design from standdesign map
                Stand_Detail__c objSDetail = (Stand_Detail__c)stndDetailMap.get(objExpoBooth.Id);// get stand detail from standdetail map

                wrapperClass objWrapperClass = new  wrapperClass (); // create a wrapper class to store data

                objWrapperClass.matchProType=replaceNulls(objExpoBooth.Expocad_Booth__r.Matched_Product_Name__c);
                objWrapperClass.sBoothType=replaceNulls(objExpoBooth.Expocad_Booth__r.Booth_Type__c);       
                objWrapperClass.exhibitingName= replaceNulls(objExpoBooth.Display_Name__c != null ? objExpoBooth.Display_Name__c:objExpoBooth.Opportunity__r.Account.name); 
                objWrapperClass.strExhibitor=replaceNulls(objExpoBooth.Opportunity__r.Account.name); 
                objWrapperClass.oppname=replaceNulls(objExpoBooth.Opportunity__r.name); 
                objWrapperClass.exhibitorOpConPerson=replaceNulls(objExpoBooth.Opportunity__r.Operations_Contact__r.name); 
                objWrapperClass.exhibitorOpEmail=replaceNulls(objExpoBooth.Opportunity__r.Operations_Contact__r.email);  
                objWrapperClass.exhibitorOpTel=replaceNulls(objExpoBooth.Opportunity__r.Operations_Contact__r.phone);  
                objWrapperClass.exhibitorOpMob=replaceNulls(objExpoBooth.Opportunity__r.Operations_Contact__r.MobilePhone);
                objWrapperClass.exhibitorCountry=replaceNulls(objExpoBooth.Opportunity__r.Account.BillingCountry);//CCEN-779
                objWrapperClass.area=objExpoBooth.Expocad_Booth__r.Area__c; 
                objWrapperClass.strBooth=objExpoBooth.Booth_Number__c;
                if(userDetail !=null){
                    objWrapperClass.exhUsername = userDetail.Username;
                }
                if(objBooth != null){ 
                    objWrapperClass.contractorEmail=replaceNulls(objBooth.Contact__r.Email); 
                    objWrapperClass.contractorPhone=replaceNulls(objBooth.Contact__r.Phone); 
                    objWrapperClass.contractorMobilePhone=replaceNulls(objBooth.Contact__r.MobilePhone);
                    objWrapperClass.contractorCountry=replaceNulls(objBooth.Contact__r.account.BillingCountry); //CCEN-779
                    objWrapperClass.contractorCompany=replaceNulls(objBooth.Contact__r.Account.Name);  
                    objWrapperClass.sContactsName=replaceNulls(objBooth.Contact__r.Name);   
                    objWrapperClass.designationStatus=replaceNulls(objBooth.Status__c); 
                    User userDetail2 = (User)userMap.get(objBooth.Contact__c); // get user details from map //BK-2025 modify map key from AccountId to ContactId
                    if(userDetail2 !=null){
                        objWrapperClass.contrUsername = userDetail2.Username; // putting contractor user name
                    }
                } 
                  
                if(objDesign != null){
                    DateTime tempDate = (DateTime)objDesign.Booth_Design_Submitted_On__c; // convert date to date time object
                    if(tempDate !=null){
                        objWrapperClass.dBoothDsnSbmttdOn = tempDate.format('yyyy-MM-dd');                            
                    }
                    objWrapperClass.sBoothStatus=objDesign.Booth_Design_Status__c;
                }
                if(objSDetail != null){
                    objWrapperClass.boolRigging=objSDetail.IsRigging__c;
                    objWrapperClass.boolDblDckr=objSDetail.IsDoubleDecker__c;
                    objWrapperClass.boolHevyMachin=objSDetail.Is_Heavy_Machinery__c;
                    objWrapperClass.amount=objSDetail.Amount__c;
                    objWrapperClass.perfBond=objSDetail.IsReceived__c;
                    objWrapperClass.standHeight = objSDetail.Stand_Height__c;
                    objWrapperClass.riggingHeight = objSDetail.Rigging_Height__c;
                    objWrapperClass.isVehicles = objSDetail.Is_Vehicles__c;
                }

                if(objWrapperClass.strBooth != null){
                    lstwrapper.add(objWrapperClass);
                }
            }
        }
    }
    public string replaceNulls(string str){ 
        return str==null?'':str;
    }
    // gets the map from the list passed 
    public Map<string, Object>  getMappedValues(list<Object> dataList){  
        Map<string,Object> objectMap =  new  Map<string,Object>(); // initialize the map
        if(dataList instanceOf list<BoothContractorMapping__c>){
            List<BoothContractorMapping__c> boothList = (List<BoothContractorMapping__c>)dataList; // convert the object list to specific list 
            for(BoothContractorMapping__c boothConMap : boothList){
                objectMap.put(boothConMap.Opp_Booth_Mapping__c,boothConMap);
            }
        }

        if(dataList instanceOf list<Stand_Design__c>){
            List<Stand_Design__c> stndDesignList = (List<Stand_Design__c>)dataList;  // convert the object list to specific list 
            for(Stand_Design__c stndDesign : stndDesignList){
                objectMap.put(stndDesign.Opp_Booth_Mapping__c,stndDesign);
            }
        }

        if(dataList instanceOf list<Stand_Detail__c>){
            List<Stand_Detail__c> stndDetailList = (List<Stand_Detail__c>)dataList;  // convert the object list to specific list 
            for(Stand_Detail__c stndDetail : stndDetailList){
                objectMap.put(stndDetail.Opp_Booth_Mapping__c,stndDetail);
            }
        }

        if(dataList instanceOf list<User>){
            List<User> stndDetailList = (List<User>)dataList;  // convert the object list to specific list 
            for(User userDetail : stndDetailList){
                objectMap.put(userDetail.ContactId,userDetail); //BK-2025 Modify map key from AccountId to ContactId
             }
        }

        if(dataList instanceOf list<ContactEventEditionMapping__c>){
            List<ContactEventEditionMapping__c> conEventlList = (List<ContactEventEditionMapping__c>)dataList;  // convert the object list to specific list 
            for(ContactEventEditionMapping__c conEventMap : conEventlList){
                objectMap.put(conEventMap.SFContactID__c,conEventMap);
            }
        }

        if(dataList instanceOf list<Opportunity_ExpoCAD_Booth_Mapping__c>){
            List<Opportunity_ExpoCAD_Booth_Mapping__c> boothList = (List<Opportunity_ExpoCAD_Booth_Mapping__c>)dataList;  // convert the object list to specific list 
            for(Opportunity_ExpoCAD_Booth_Mapping__c booth : boothList){
                objectMap.put(booth.Opportunity__r.account.name,booth);
            }
        }
        return objectMap;
    }

    //BK - 1876
    
   public void getShowCategory()
   {
        string sEventId = ApexPages.currentPage().getparameters().get('event').escapeHtml4();  // eventID        
        string expoBoothQuery = 'SELECT Display_Name__c,Booth_Number__c,Primary_Contact__r.Email,Primary_Contact__r.Phone,Primary_Contact__r.Website__c,Primary_Contact__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,Opportunity__r.Account.BillingCountry from Opportunity_ExpoCAD_Booth_Mapping__c where Status__c = \'Active\' AND Opportunity__r.StageName=\'Closed Won\' AND Opportunity__r.EventEdition__c=\'' + String.escapeSingleQuotes(sEventId) +'\'  AND Expocad_Booth__r.Status__c = \'Rented\'' ;
        
        list<Opportunity_ExpoCAD_Booth_Mapping__c> listexpocadBooth= Database.query(expoBoothQuery); // Expocad Booth List
        list<BoothContactInfo__c> listBooth = new list<BoothContactInfo__c>();
        if(Schema.sObjectType.BoothContactInfo__c.isAccessible()){
            listBooth =[SELECT Opportunity_Booth_Mapping__c,Contact__c,Contact__r.Website__c,Contact__r.Name,Contact__r.Email,Contact__r.Phone FROM BoothContactInfo__c WHERE Opportunity_Booth_Mapping__c In :listexpocadBooth];// booth Contact map list 
        }
              
        list<Stand_Detail__c> listStndDetail = new List<Stand_Detail__c>();
        if(Schema.sObjectType.Stand_Detail__c.isAccessible()){
            listStndDetail=[SELECT Name ,Opp_Booth_Mapping__c FROM Stand_Detail__c WHERE Opp_Booth_Mapping__c In :listexpocadBooth]; // stand detail list
        }
        
        Map<string, Object> boothMap = (Map<string, Object>)getshowcategoryMappedValues(listBooth); // map of expocad booth Id and boothConMap
        Map<string,Object> stndDetailMap = (Map<string,Object> )getshowcategoryMappedValues(listStndDetail); // map of expocad booth id and stand details
        
        Set<Id> setProfilePackageSettingEnhance = new Set<Id>();
        Map<Id,String> mapGetUserPackageEnhance = new Map<Id,String>();
        List<Profile_Package_Setting__c> listofProfilePackage = [Select Id, Name, Priority__c, Event_Edition__r.Name FROM Profile_Package_Setting__c where Event_Edition__c =: sEventId AND Priority__c = '1'];
        
        If(!listofProfilePackage.isEmpty() && listofProfilePackage.size()>0)
        {
            for(Profile_Package_Setting__c pps: listofProfilePackage)
            {
                setProfilePackageSettingEnhance.add(pps.Id);
            }
        }
        
        List<User_Package__c> listofUserPackage = [Select Id, Name, Account__c, Account__r.Name, Event_Edition__r.Name, Profile_Package_Setting__r.Name FROM User_Package__c where Event_Edition__c =: sEventId and Profile_Package_Setting__c IN :setProfilePackageSettingEnhance];
        
        if(!listofUserPackage.isEmpty() && listofUserPackage.size()>0)
        {
            for(User_Package__c pps : listofUserPackage)
            {
                mapGetUserPackageEnhance.put(pps.Account__c,pps.Account__r.Name);
            }
        }
       
        if(listexpocadBooth!=null && listexpocadBooth.size()>0)
        { 
            for(Opportunity_ExpoCAD_Booth_Mapping__c objExpoBooth:listexpocadBooth) // loop each expocad booth
                {                
                    
                wrapperClass objWrapperClass = new  wrapperClass (); // create a wrapper class to store data
                if(!mapGetUserPackageEnhance.isEmpty()  && mapGetUserPackageEnhance.containsKey(objExpoBooth.Opportunity__r.AccountId)){
                    objWrapperClass.companyName = mapGetUserPackageEnhance.get(objExpoBooth.Opportunity__r.AccountId); 
                    objWrapperClass.standNumber = replaceshowCategoryNulls(objExpoBooth.Booth_Number__c);
                    objWrapperClass.displayName=replaceshowCategoryNulls(objExpoBooth.Display_Name__c != null ? objExpoBooth.Display_Name__c:objExpoBooth.Opportunity__r.Account.name);               
                    objWrapperClass.country=replaceshowCategoryNulls(objExpoBooth.Opportunity__r.Account.BillingCountry);
                    objWrapperClass.boothconEmail=replaceshowCategoryNulls(objExpoBooth.Primary_Contact__r.Email); 
                    objWrapperClass.boothconPhone=replaceshowCategoryNulls(objExpoBooth.Primary_Contact__r.Phone);                                        
                    objWrapperClass.boothconWebsite=replaceshowCategoryNulls(objExpoBooth.Primary_Contact__r.Website__c);  
                    objWrapperClass.boothconName=replaceshowCategoryNulls(objExpoBooth.Primary_Contact__r.Name);
                    
                    lstwrapper.add(objWrapperClass);  
                }                                 
            }
        }
    }
    public string replaceshowCategoryNulls(string str){ 
        return str==null?'':str;
    }
    // gets the map from the list passed 
    public Map<string, Object>  getshowcategoryMappedValues(list<Object> dataList){        
        Map<string,Object> objectMap =  new  Map<string,Object>(); // initialize the map
        if(dataList instanceOf list<BoothContactInfo__c>){
            List<BoothContactInfo__c> boothList = (List<BoothContactInfo__c>)dataList; // convert the object list to specific list 
            for(BoothContactInfo__c boothConMap : boothList){
                objectMap.put(boothConMap.Opportunity_Booth_Mapping__c,boothConMap);
            }
        }
        

        if(dataList instanceOf list<Stand_Detail__c>){
            List<Stand_Detail__c> stndDetailList = (List<Stand_Detail__c>)dataList;  // convert the object list to specific list 
            for(Stand_Detail__c stndDetail : stndDetailList){
                objectMap.put(stndDetail.Opp_Booth_Mapping__c,stndDetail);
            }
        }        
       
        if(dataList instanceOf list<Opportunity_ExpoCAD_Booth_Mapping__c>){
            List<Opportunity_ExpoCAD_Booth_Mapping__c> boothList = (List<Opportunity_ExpoCAD_Booth_Mapping__c>)dataList;  // convert the object list to specific list 
            for(Opportunity_ExpoCAD_Booth_Mapping__c booth : boothList){
                objectMap.put(booth.Opportunity__r.account.name,booth);
            }
        }
        return objectMap;
    }

  }