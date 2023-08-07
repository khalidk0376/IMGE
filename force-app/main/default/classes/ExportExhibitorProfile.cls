/**
 * Created By: Girikon(Himanshu Jasuja)
 * Created On:          27/11/2019
 * @description  : This class will be exporting the exhibitor profiles(BK - 2849)
 * Test Class:          ExportExhibitorProfile_test 
 * Modified by      :   Girikon(Rajeev[BK-2849 Dec 12 2019]) ,Girikon(Rajeev[BK-3089 Dec 17 2019]), [Aishwarya BK-15072 9 Apr 2021]
**/
public class ExportExhibitorProfile {
 
    public string  extrnalSiteURl{get;set;}
    public string eveId = '';
    public string baseUrl = '';        
    public string reportName = ''; // report name
    public List<wrapperClass> lstwrapper {get; set;}  // List of the wrapper class storing the data
    map<string,string> mapBoothLogoURL = new map<string,string>();
   
    public ExportExhibitorProfile()
    {
        extrnalSiteURl = System.URL.getSalesforceBaseUrl().toExternalForm();
        if(!Test.isRunningTest())
        {
            Network myNetwork = [SELECT Id 
                                 FROM Network 
                                 WHERE Name ='Customer Centre' ];
            extrnalSiteURl = Network.getLoginUrl(myNetwork.id);            
            extrnalSiteURl = extrnalSiteURl.replace('/UserLogin','').trim();
            
        }              
      eveId = apexpages.currentpage().getparameters().get('eventId');
        reportName = apexpages.currentpage().getparameters().get('reportName'); // get the report name from the url 
        lstwrapper = new List<wrapperClass>();        
    } 
    
    public void exportToExcel(){
        if( reportName == 'ExhibitorProfile'){             
             getexhibitorProfiles();
        }           
    }
    
    public void getexhibitorProfiles(){

       
        string expoBoothQuery = 'SELECT Opportunity__r.Name ,Display_Name__c,Booth_Logo_Id__c,Event_Edition_Name__c,Account__r.Name,Facebook__c,LinkedIn__c,Twitter__c,Instagram__c,YouTube__c,Web_Description__c,Print_Description__c,Opportunity__r.Id,Opportunity__r.Account.Name,Expocad_Booth__r.Matched_Product_Name__c,Expocad_Booth__r.Booth_Number__c,Expocad_Booth__r.Area__c,Expocad_Booth__r.Booth_Logo_Id__c,Booth_Number__c,Opportunity__r.Operations_Contact__r.FirstName,Opportunity__r.Operations_Contact__r.LastName,Opportunity__r.Parent_Opportunity__r.Account.Name, Opportunity__r.Operations_Contact__r.email,Opportunity__r.Operations_Contact__r.phone, Opportunity__r.User_Type__r.Name,Opportunity__r.Owner.Username,Relation__c from Opportunity_ExpoCAD_Booth_Mapping__c where Status__c = \'Active\' AND Opportunity__r.StageName=\'Closed Won\' AND Opportunity__r.EventEdition__c=\'' + String.escapeSingleQuotes(eveId) +'\' AND Expocad_Booth__r.Status__c = \'Rented\' AND Opportunity__r.User_Type__r.Name != \'Agent\'';        
        list<Opportunity_ExpoCAD_Booth_Mapping__c> listexpocadBooth= Database.query(expoBoothQuery); // Expocad Booth List  
        
       Map<Id,List<Customer_Product_Sub_Category__c>> mapGetCPCategory = new Map<Id,List<Customer_Product_Sub_Category__c>>();
        list<Customer_Product_Sub_Category__c> CPCategoryList = [Select id, Name,Account__c, Contact__c,Event_Edition__r.Name,Event_Edition_Sub_Category_Mapping__r.Levels_Master__r.LevelValue__c,ExpocadBooth__c,Opp_Booth_Mapping__c  From Customer_Product_Sub_Category__c  WHERE Event_Edition__c =:eveId];       
            if(!CPCategoryList.isEmpty())
            {
                for(Customer_Product_Sub_Category__c cpc : CPCategoryList)
                {               
                    if(mapGetCPCategory.containsKey(cpc.Opp_Booth_Mapping__c)){
                        mapGetCPCategory.get(cpc.Opp_Booth_Mapping__c).add(cpc);
                        
                    }
                    else{
                        List<Customer_Product_Sub_Category__c> lstCPC = new List<Customer_Product_Sub_Category__c>();
                        lstCPC.add(cpc);
                        mapGetCPCategory.put(cpc.Opp_Booth_Mapping__c,lstCPC);
                    }
                }
            } 
        
        Map<Id,GoMed2Med__c> mapGetGoMed2 = new Map<Id,GoMed2Med__c>();
        list<GoMed2Med__c> GoMed2List = [Select Id,Account__c, Name, Are_you_a_manufacturer_supplying_to_Dist__c, Are_you_a_manufacturer_supplying_to_End__c, Event_Edition__c,Event_Edition__r.Name, Are_you_a_distributor__c,LastModifiedByCC__c  FROM GoMed2Med__c  WHERE Event_Edition__c =:eveId];
            if(!GoMed2List.isEmpty() && GoMed2List.size()>0)
            {
                for(GoMed2Med__c gmm : GoMed2List)
                {               
                    mapGetGoMed2.put(gmm.Account__c,gmm);                  
                }
            } 
        
        list<BoothContactInfo__c> listBooth = new list<BoothContactInfo__c>();
        if(Schema.sObjectType.BoothContactInfo__c.isAccessible()){
            listBooth =[SELECT First_Name__c,Opportunity_Booth_Mapping__r.Booth_Logo_Id__c,Last_Name__c,Address__c,City__c, toLabel(Country__c),Email__c,Fax__c,P_O_Box__c,State__c,Telephone__c,Website__c,Zip_Code__c,Opportunity_Booth_Mapping__c,Contact__c,Contact__r.Website__c,Contact__r.Name,Contact__r.Email,Contact__r.Phone FROM BoothContactInfo__c WHERE Opportunity_Booth_Mapping__c In :listexpocadBooth];// booth Contact map list             
        }
        
        Set<Id> setProfilePackageSetting = new Set<Id>();
        Map<Id,User_Package__c> mapGetUserPackage = new Map<Id,User_Package__c>();
        List<Profile_Package_Setting__c> listofProfilePackage = [Select Id, Name, Priority__c, Event_Edition__r.Name FROM Profile_Package_Setting__c where Event_Edition__c =: eveId];
        
        list<User> userList = new list<User>();
        if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.ContactEventEditionMapping__c.isAccessible() ){            
            userList = [select  Account.name, AccountId, ContactId, Username,LastLoginDate from user where contactId IN (select SFContactID__c from ContactEventEditionMapping__c Where SFEventEditionID__c =: eveId)]; // user list
             
        }
        Map<string,Object> userMap = (Map<string,Object>)getMappedValues(userList);// map of expocad account id and users
        Map<string, Object> boothMap = (Map<string, Object>)getMappedValues(listBooth); // map of expocad booth Id and boothConMap
        List<User_Package__c> listofUserPackage = [Select Id, Name, Account__c, Account__r.Name, Event_Edition__r.Name, Profile_Package_Setting__r.Name FROM User_Package__c where Event_Edition__c =: eveId];
        
            if(!listofUserPackage.isEmpty() && listofUserPackage.size()>0)
            {
                for(User_Package__c pps : listofUserPackage)
                {               
                    mapGetUserPackage.put(pps.Account__c,pps);
                }
            } 
            
        if(listexpocadBooth!=null && listexpocadBooth.size()>0) 
            
        { 
            for(Opportunity_ExpoCAD_Booth_Mapping__c objExpoBooth:listexpocadBooth) // loop each expocad booth
            {
                User userDetail = (User)userMap.get(objExpoBooth.Opportunity__r.Operations_Contact__C); // get the user from the usermap
                BoothContactInfo__c objBooth = (BoothContactInfo__c)boothMap.get(objExpoBooth.Id);// get the booth cont mapping from boothMap              
                //Attachment attch = (Attachment)boothMap.get(objExpoBooth.Booth_Logo_Id__c);
                ContentDocument attch = (ContentDocument)boothMap.get(objExpoBooth.Booth_Logo_Id__c);
                
                
                system.debug('@@@@@@@@@@@@@@@@@'+attch);
                wrapperClass objWrapperClass = new  wrapperClass (); 
                  objWrapperClass.Contnttype= new Map<String,String>();
                    objWrapperClass.oppaccountname=objExpoBooth.Opportunity__r.Account.Name;             
                    objWrapperClass.agentcompany=objExpoBooth.Opportunity__r.Parent_Opportunity__r.Account.Name; 
                    objWrapperClass.usertype=objExpoBooth.Opportunity__r.User_Type__r.Name;
                    objWrapperClass.oppnumber=objExpoBooth.Opportunity__r.Id;
                    objWrapperClass.oppname=objExpoBooth.Opportunity__r.name;
                    objWrapperClass.Facebook=objExpoBooth.Facebook__c;
                    objWrapperClass.LinkedIn=objExpoBooth.LinkedIn__c; 
                    objWrapperClass.Twitter=objExpoBooth.Twitter__c;
                    objWrapperClass.Instagram=objExpoBooth.Instagram__c ; 
                    objWrapperClass.YouTube=objExpoBooth.YouTube__c;
                    objWrapperClass.webdescription=objExpoBooth.Web_Description__c;
                    objWrapperClass.printdescription=objExpoBooth.Print_Description__c; 
                    objWrapperClass.eventName= objExpoBooth.Event_Edition_Name__c;
                    objWrapperClass.standnumber=objExpoBooth.Expocad_Booth__r.Booth_Number__c;
                    objWrapperClass.standsize=objExpoBooth.Expocad_Booth__r.Area__c;
                    objWrapperClass.matchproductype=objExpoBooth.Expocad_Booth__r.Matched_Product_Name__c;
                    objWrapperClass.logo=objExpoBooth.Expocad_Booth__r.Booth_Logo_Id__c; 
                    objWrapperClass.displayname=objExpoBooth.Display_Name__c;
                    objWrapperClass.operationconfirstname=objExpoBooth.Opportunity__r.Operations_Contact__r.FirstName;
                    objWrapperClass.operationconlastname=objExpoBooth.Opportunity__r.Operations_Contact__r.LastName;
                    
                   if(mapGetUserPackage.containsKey(objExpoBooth.Account__c)){
                        User_Package__c up = mapGetUserPackage.get(objExpoBooth.Account__c);                       
                        objWrapperClass.opppackage= up.Profile_Package_Setting__r.Name;
                    }
                    else
                       objWrapperClass.opppackage= 'Default Package';
                                      
                    if(userDetail !=null){
                         objWrapperClass.operationconccusername = userDetail.Username;   
                         objWrapperClass.lastlogin = userDetail.LastLoginDate;
                   }                                                                                                     
                    if(objBooth != null){                                                                
                    objWrapperClass.firstname=objBooth.First_Name__c; 
                    objWrapperClass.lastname=objBooth.Last_Name__c;
                    objWrapperClass.country=objBooth.Country__c; 
                    objWrapperClass.address=objBooth.Address__c;
                    objWrapperClass.city=objBooth.City__c; 
                    objWrapperClass.state=objBooth.State__c;
                    objWrapperClass.pobox=objBooth.P_O_Box__c; 
                    objWrapperClass.telephone=objBooth.Telephone__c;
                    objWrapperClass.fax=objBooth.Fax__c; 
                    objWrapperClass.email=objBooth.Email__c;
                    objWrapperClass.Website=objBooth.Website__c; 
                    
                    if (attch!= null){
                        //objWrapperClass.attchid=attch.id;
                        if(!mapBoothLogoURL.isEmpty() && mapBoothLogoURL.containsKey(attch.id)){
                            objWrapperClass.attchid = mapBoothLogoURL.get(attch.id);
                            objWrapperClass.logoName=attch.Title;
                        }
                    }                                                            
                } 
                
                    if(mapGetGoMed2.containsKey(objExpoBooth.Account__c)){                          
                        GoMed2Med__c gmm = mapGetGoMed2.get(objExpoBooth.Account__c);                          
                        objWrapperClass.goMedSuptoDis= gmm.Are_you_a_manufacturer_supplying_to_Dist__c;
                        objWrapperClass.goMedSuptoEnd= gmm.Are_you_a_manufacturer_supplying_to_End__c;
                        objWrapperClass.goMedDistributer= gmm.Are_you_a_distributor__c;
                        objWrapperClass.ccUserInfo= gmm.LastModifiedByCC__c;                        
                   } 
                
                     if(mapGetCPCategory.containsKey(objExpoBooth.id)){ 
                    
                            List<Customer_Product_Sub_Category__c> cpc = mapGetCPCategory.get(objExpoBooth.id); 
                            String[] tmp1 = New String[]{};
                     
                            if(cpc.size()>0){   
                                for(Customer_Product_Sub_Category__c CustomerPrductCat: cpc)
                                {
                                    tmp1.add(CustomerPrductCat.Event_Edition_Sub_Category_Mapping__r.Levels_Master__r.LevelValue__c);
                                }  
                            }
                            objWrapperClass.productcategories = string.join(tmp1,',');                         
                }   
                lstwrapper.add(objWrapperClass); 
          }      
       }
    }
    
    public class wrapperClass{ 
          
        public string oppaccountname {get; set;} 
        public string agentcompany {get; set;} 
        public string usertype {get; set;} 
        public string oppnumber {get; set;} 
        public string oppname {get; set;} 
        public string opppackage {get; set;} 
        public string operationconfirstname {get; set;}
        public string operationconlastname {get; set;} 
        public string operationconccusername {get; set;}
        public DateTime lastlogin {get; set;} 
        public string standnumber {get; set;} 
        public string standsize {get; set;} 
        public string matchproductype {get; set;}
        public string displayname {get; set;}
        public string firstname {get; set;}
        public string lastname{get; set;}
        public string country {get; set;}
        public string address {get; set;}
        public string city {get; set;}
        public string state {get; set;}
        public string pobox {get; set;}
        public string telephone {get; set;}
        public string fax {get; set;}
        public string email {get; set;}
        public string Website {get; set;}
        public string Facebook {get; set;}
        public string LinkedIn {get; set;}
        public string Twitter {get; set;}
        public string Instagram {get; set;}
        public string YouTube {get; set;}
        public string logo {get; set;}
        public string attchid {get; set;}
        public string logoName {get; set;}
        public string webdescription {get; set;}
        public string printdescription {get; set;}
        public string productcategories {get; set;}
        public string eventName {get;set;}
        public string goMedSuptoDis {get;set;}
        public string goMedSuptoEnd {get;set;}
        public string goMedDistributer {get;set;}
        public DateTime ccUserInfo {get;set;}
        public Map<String,String> Contnttype{get;set;}
        
    }
    
     // gets the map from the list passed 
    public Map<string, Object>  getMappedValues(list<Object> dataList){        
        Map<string,Object> objectMap =  new  Map<string,Object>(); // initialize the map
        
        if(dataList instanceOf list<User>){
            List<User> stndDetailList = (List<User>)dataList;  // convert the object list to specific list 
            for(User userDetail : stndDetailList){
                objectMap.put(userDetail.ContactId,userDetail); // Modify map key from AccountId to ContactId
             }
        }
        
        if(dataList instanceOf list<BoothContactInfo__c>){
            List<BoothContactInfo__c> boothList = (List<BoothContactInfo__c>)dataList; // convert the object list to specific list 
            set<id> attchmntIds= new set<id>();
            for(BoothContactInfo__c boothConMap : boothList){
                attchmntIds.add(boothConMap.Opportunity_Booth_Mapping__r.Booth_Logo_Id__c);
                objectMap.put(boothConMap.Opportunity_Booth_Mapping__c,boothConMap);
            }
            /*
            List<Attachment> listAttchmnt = new List<Attachment>();
            listAttchmnt = [select id , name, ContentType from attachment where id IN:attchmntIds];          
            for(Attachment attchmnt :listAttchmnt){
                objectMap.put(attchmnt.id ,attchmnt);
            }*/           
            List<ContentDocument> listAttchmnt = new List<ContentDocument>();
            listAttchmnt = [select Id, Title from ContentDocument where Id IN:attchmntIds];          
            for(ContentDocument attchmnt :listAttchmnt){
                objectMap.put(attchmnt.id ,attchmnt);
            }
            
            List<ContentDistribution> listContentDist = new List<ContentDistribution>();
            listContentDist = [Select Id, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl from ContentDistribution where ContentDocumentId IN:attchmntIds];
            if(listContentDist.size()>1){
                for(ContentDistribution cond :listContentDist){
                    mapBoothLogoURL.put(cond.ContentDocumentId,cond.DistributionPublicUrl);
                }
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