/**
* Created By : Girikon(Abhishek)
* Created On : Sep 16, 2019
* @description : This class used to upload badges from the Operations Admin and Customer Centre for Agent.
* Test Class : BulkUploadBadgesCtrl_Test(83%)
* Modification Log ---------
* Modified By : Aishwarya [BK-2895 Nov 26 2019], [Aishwarya BK-9812 1 Dec 2020]
**/

public without sharing class BulkUploadBadgesCtrl
{
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    String[] filelines = new String[]{};
    List<Agent_Badges__c> badgesToUpload;
    public string eventCodeFromURl{get;set;}
    public AgentEventEditionMapping__c eventMapping;
    public Id eventEditionId;
    public boolean fileUploadcomplete {get; set;}
    public string importBadgesCSVFileId {get; set;}
    public String brandingColor{get;set;}
    public String brandingTextColor{get;set;}
    public Integer flag{get;set;}
    public boolean loadflag{get;set;}
    public string accountId{get;set;}
    boolean uploadallowed = true ;
    set<String> ageBracketSet=new Set<String>();  
    set<String> countryCodeSet=new Set<String>(); 
    private boolean hasError = false;
    public boolean checkFile{get;set;} 
    
    public BulkUploadBadgesCtrl()
    {
        fileUploadcomplete = false;
        checkFile = false;
        eventCodeFromURl = ApexPages.currentPage().getParameters().get('eventCode').escapeHtml4();
        accountId = ApexPages.currentPage().getParameters().get('accountId').escapeHtml4();
        eventEditionId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
        List<Event_Settings__c> eventSetting = new List<Event_Settings__c>([Select Id,Badges_MatchMaking__c, Branding_Color__c,Utility_Navigation_text_Color__c,Badge_Address_Character_Limit__c,Badge_City_Character_Limit__c, Badge_Deadline__c, Badge_Email_Character_Limit__c, Badge_FName_Character_Limit__c, Badge_FName_To_UpperCase__c, Badge_JobTitle_Character_Limit__c, Badge_LName_Character_Limit__c, Badge_LName_To_UpperCase__c, Badge_Mobile_Character_Limit__c, Company_Name_on_Badge_Character_Limit__c, Allow_VIP_Badges__c, Agent_Badge_limit__c FROM Event_Settings__c where Event_Edition__r.Event_Code__c =:eventCodeFromURl LIMIT 1]);
        brandingColor = eventSetting[0].Branding_Color__c;
        brandingTextColor = eventSetting[0].Utility_Navigation_text_Color__c;
        List<document> listDocumentBadgesCSV = new List<document>();
        List<document> listDocumentBadgesWithoutVipCSV = new List<document>();
        List<document> listDocumentBadgesWithoutMatchMakigCSV = new List<document>();
        List<document> listDocumentBadgesWithoutVIPandMatchCSV = new List<document>();
        /*** BK-1820 Start ***/
        //List<Attachment> listInformaTemplateByEvent = new List<Attachment>();
        List<ContentDocumentLink> listInformaTemplateByEvent = new List<ContentDocumentLink>(); //BK-9812
        if(eventSetting.size()>0){
            //listInformaTemplateByEvent = [Select Id FROM Attachment where ParentId =:eventSetting[0].Id order by createdDate desc LIMIT 1];
            listInformaTemplateByEvent = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId =:eventSetting[0].Id order by ContentDocument.CreatedDate desc LIMIT 1];
        }
        system.debug('=============AttId '+listInformaTemplateByEvent);
        // CCEN-672 Querying on Badge Template Start
        if(!eventSetting.isEmpty() && eventSetting[0].Allow_VIP_Badges__c == True && listInformaTemplateByEvent.size()==0 && eventSetting[0].Badges_MatchMaking__c ==True){
            listDocumentBadgesCSV =[Select Id FROM document where DeveloperName = 'Badge_CSV_File' LIMIT 1];
        }
        else if(!eventSetting.isEmpty() && eventSetting[0].Allow_VIP_Badges__c == False && listInformaTemplateByEvent.size()==0 && eventSetting[0].Badges_MatchMaking__c==True){
            listDocumentBadgesWithoutVipCSV = [Select Id, Name FROM document where DeveloperName = 'Badge_CSV_File_Without_VIP' LIMIT 1];
        }
        else if(!eventSetting.isEmpty() && eventSetting[0].Allow_VIP_Badges__c == True && listInformaTemplateByEvent.size()==0 && eventSetting[0].Badges_MatchMaking__c==False){
            listDocumentBadgesWithoutMatchMakigCSV = [Select Id, Name FROM document where DeveloperName = 'Badges_CSV_File_Without_MatchMaking' LIMIT 1];
        }
        else if(!eventSetting.isEmpty() && eventSetting[0].Allow_VIP_Badges__c == False && listInformaTemplateByEvent.size()==0 && eventSetting[0].Badges_MatchMaking__c==False){
            listDocumentBadgesWithoutVIPandMatchCSV =[Select Id, Name from document where DeveloperName = 'Badge_CSV_File_Without_VIP_Match' LIMIT 1];
        }
        if(!listDocumentBadgesCSV.IsEmpty()){
            importBadgesCSVFileId = listDocumentBadgesCSV[0].Id;
        }
        if(!listDocumentBadgesWithoutVipCSV.IsEmpty()){
            importBadgesCSVFileId = listDocumentBadgesWithoutVipCSV[0].Id;
        }
        if(!listDocumentBadgesWithoutMatchMakigCSV.IsEmpty()){
            importBadgesCSVFileId = listDocumentBadgesWithoutMatchMakigCSV[0].Id;
        }
        if(!listDocumentBadgesWithoutVIPandMatchCSV.IsEmpty()){
            importBadgesCSVFileId = listDocumentBadgesWithoutVIPandMatchCSV[0].Id;
        }
        if(listDocumentBadgesCSV.size()==0 && listDocumentBadgesWithoutVipCSV.size()==0 && listDocumentBadgesWithoutMatchMakigCSV.size()==0 && listDocumentBadgesWithoutVIPandMatchCSV.size()==0 && listInformaTemplateByEvent.size()>0){
            //importBadgesCSVFileId = listInformaTemplateByEvent[0].Id;
            importBadgesCSVFileId = listInformaTemplateByEvent[0].ContentDocumentId;
            checkFile = true;
        }
        /*** BK-1820 End ***/
        
        // CCEN-672 Querying on Badge Template End
        
        /***** getting the Age_Bracket__c picklist value from  Agent_Badges__c Object *****/
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Agent_Badges__c');
        Sobject objectName = targetType.newSObject();
        Schema.sObjectType sobjectType = objectName.getSObjectType();
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe(); 
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
        List<Schema.PicklistEntry> pickListValuesAgeBrakt = fieldMap.get('Age_Bracket__c').getDescribe().getPickListValues(); 
        List<Schema.PicklistEntry> pickListValuesCountryCode = fieldMap.get('Country_Code__c').getDescribe().getPickListValues(); 
        for (Schema.PicklistEntry a : pickListValuesAgeBrakt){ 
            ageBracketSet.add(a.getValue());    
        }
        for (Schema.PicklistEntry picCountryCode : pickListValuesCountryCode){ 
            countryCodeSet.add(picCountryCode.getValue());    
        } 
    } 
    
    /*** @description : Function that reads the uplaoded CSV file and inserts records(as per records available in csv file) into the Agent_Badges__c custom object. 
    @return : Pagereference ***/
    public Pagereference readFile()
    {
        try
        {
            List<Event_Settings__c> eventSet = new List<Event_Settings__c>([Select Branding_Color__c,Badge_Address_Character_Limit__c,Badge_City_Character_Limit__c, Badge_Deadline__c , Approval_Not_Required__c,Allow_VIP_Badges__c, 
                                                                            Badge_Email_Character_Limit__c, Badge_FName_Character_Limit__c, Badge_FName_To_UpperCase__c, Badge_JobTitle_Character_Limit__c, Badge_LName_Character_Limit__c,Badge_LName_To_UpperCase__c, 
                                                                            Badge_Mobile_Character_Limit__c, Company_Name_on_Badge_Character_Limit__c, Allotment_By_Booth_Size__c, Allotment_By_Booth_Type__c, Company_Name_on_Badge_ToUpperCase__c, Company_Name_on_Badge__c, Badge_Mobile_Number__c, Badge_Age_Bracket__c, Badge_Address__c, Badge_City__c, Badge_State__c, Badge_Country__c, Badge_Nationality__c, Badge_First_Name__c, Badge_Last_Name__c, Badge_Job_Title__c, Badge_Email__c, Agent_Badge_limit__c, 
                                                                            Badges_MatchMaking__c FROM Event_Settings__c where Event_Edition__r.Event_Code__c =:eventCodeFromURl LIMIT 1]);
            fileUploadcomplete = false;
            loadflag=false;
            Integer numRecord=0;
            if(!String.isEmpty(nameFile) && contentFile!= null){
                if(nameFile.endsWith('csv') || nameFile.endsWith('CSV')){                        
                    //Convert the uploaded csv file from BLOB format into a string
                    string fileContent = blobToString( contentFile,'ISO-8859-1'); 
                    
                    // parsing the Converted String into 2-D List of String
                    List<List<String>> content = New List<List<String>>();
                    
                    content = parseCSV(fileContent);                        
                    badgesToUpload = new List<Agent_Badges__c>();
                    if(hasError == true){return null;
                    }
                    
                    eventCodeFromURl = ApexPages.currentPage().getParameters().get('eventCode').escapeHtml4();
                    
                    // for getting values from global picklist used on exhibitor badge Country field
                    Map<string,string> mapGlobalCountryValues = new Map<string,string>();
                    set<string>listGlobalCountryValues = new set<string>();
                    listGlobalCountryValues = mapGlobalCountryValues.keySet();
                    Schema.DescribeFieldResult country = Agent_Badges__c.Country__c.getDescribe();
                    List<Schema.PicklistEntry> countryValues = country.getPicklistValues();
                    if(countryValues != null && countryValues.size()>0){
                        for(Schema.PicklistEntry p :countryValues){
                            mapGlobalCountryValues.put(p.Label,p.Value);
                        }
                    }
                    List<User> currentUserAccountList = new List<User>();
                    if(Schema.sObjectType.User.isAccessible()){
                        currentUserAccountList = [select AccountId, Account.Name, profile.Name from User where Id =:userInfo.getUserId() LIMIT 1];
                    }
                    List<AgentEventEditionMapping__c> eventMappings = new List<AgentEventEditionMapping__c>();
                    if(Schema.sObjectType.AgentEventEditionMapping__c.isAccessible()){
                        eventMappings = [SELECT Id, Badge_Limit__c,Total_Badges__c FROM AgentEventEditionMapping__c WHERE EventEdition__c = :eventEditionId AND Account__c = :accountId AND Is_Active__c = true];
                    }
                    for(Integer i=0;i<content.size();i++){   
                        list<String> inputvalues = new List<String>();
                        inputvalues = content[i];
                        if(inputvalues.size() < 12){addError('All columns not present in uploaded file, if you didn\'t change template columns, contact admin!');
                        }else{
                            flag =0;                                                            
                            numRecord=numRecord+1;                                
                            Agent_Badges__c badge = new Agent_Badges__c();
                            if(eventMappings.size()>0){
                                eventMapping = eventMappings[0];
                            } 
                            if(eventMapping != null){
                                badge.AgentEventEditionMapping__c = eventMapping.Id;
                            } else {
                                flag=1;
                                loadflag=true;
                                addError('Wrong event Id, Please contact admin!');
                            }
                            if (!String.isEmpty(inputvalues[0]))
                            {
                                system.debug('val'+inputvalues[0]);
                                if (inputvalues[0].length()>eventSet[0].Company_Name_on_Badge_Character_Limit__c ){
                                    flag =1; 
                                    loadflag= true;                                        
                                    addError('You have reached the character limit of '+eventSet[0].Company_Name_on_Badge_Character_Limit__c+' for company name on badge for record# : '+ numRecord);
                                }
                                else if (inputvalues[0].length()<=eventSet[0].Company_Name_on_Badge_Character_Limit__c && inputvalues[0].replaceAll('(\\s+)', ' ') != null && eventSet[0].Company_Name_on_Badge_ToUpperCase__c ==true){badge.Account_Name__c = inputvalues[0].touppercase();
                                }else {
                                    badge.Account_Name__c = inputvalues[0];
                                }
                            }                                
                            if (!String.isEmpty(inputvalues[1]))
                            {
                                if (inputvalues[1].length()>eventSet[0].Badge_FName_Character_Limit__c ){
                                    flag =1;
                                    loadflag= true;                                        
                                    addError('You have reached the characters limit of '+eventSet[0].Badge_FName_Character_Limit__c+' for First Name for record# : '+ numRecord);
                                }
                                else if (inputvalues[1].length()<=eventSet[0].Badge_FName_Character_Limit__c && eventSet[0].Badge_FName_To_UpperCase__c==true){badge.First_Name__c =inputvalues[1].touppercase();
                                }else{
                                    badge.First_Name__c = inputvalues[1];
                                }
                            }                                                  
                            if (!String.isEmpty(inputvalues[2]))
                            {
                                if (inputvalues[2].length()>eventSet[0].Badge_LName_Character_Limit__c){
                                    flag =1;
                                    loadflag= true;                                        
                                    addError('You have reached the characters limit of '+eventSet[0].Badge_LName_Character_Limit__c+' for Last Name for record# : '+ numRecord);
                                }
                                else if (inputvalues[2].length()<=eventSet[0].Badge_LName_Character_Limit__c && eventSet[0].Badge_LName_To_UpperCase__c==true)
                                {badge.Last_Name__c =inputvalues[2].touppercase();
                                }else{
                                    badge.Last_Name__c  = inputvalues[2];
                                }
                            }                                 
                            if (!String.isEmpty(inputvalues[3]))
                            {
                                if (inputvalues[3].length()<=eventSet[0].Badge_Email_Character_Limit__c){
                                    badge.Email__c  = inputvalues[3];
                                }   
                                else{
                                    flag =1;
                                    loadflag= true;                                        
                                    addError('You have reached the characters limit of '+eventSet[0].Badge_Email_Character_Limit__c+' for Email Address for record# : '+ numRecord); 
                                }
                            }                               
                            if (!String.isEmpty(inputvalues[4])){
                                if(!countryCodeSet.contains(inputvalues[4])){
                                    flag =1;
                                    loadflag= true;                                        
                                    addError('You have given bad pick-list value for Country Code "'+inputvalues[4] +'" for record# :  '+ numRecord +' ,please verify CSV file');
                                }else{
                                    badge.Country_Code__c = inputvalues[4];
                                }                                    
                            }
                            if (!String.isEmpty(inputvalues[5]))
                            {
                                if (inputvalues[5].length()<=eventSet[0].Badge_Mobile_Character_Limit__c){
                                    badge.Mobile_Number__c = inputvalues[5];
                                }else{
                                    flag =1;
                                    loadflag= true;                                        
                                    addError('You have reached the characters limit of '+eventSet[0].Badge_Mobile_Character_Limit__c+' for Mobile for record# : '+ numRecord);
                                }
                            } 
                            if (!String.isEmpty(inputvalues[6]))
                            {
                                if(mapGlobalCountryValues.size()>0 && mapGlobalCountryValues.containsKey(inputvalues[6].trim())){
                                    badge.Country__c= mapGlobalCountryValues.get(inputvalues[6].trim()); 
                                }else{
                                    flag =1;   
                                    loadflag= true;                                        
                                    addError('You have given bad pick-list value for Country "'+inputvalues[6] +'" for record# :  '+ numRecord +' ,please verify CSV file');
                                }                                
                            }
                            if (!String.isEmpty(inputvalues[8]))
                            {
                                if (inputvalues[8].length()<=eventSet[0].Badge_City_Character_Limit__c)
                                {
                                    badge.City__c   = inputvalues[8];
                                }else{
                                    flag =1;
                                    loadflag= true;                                        
                                    addError('You have reached the characters limit of '+eventSet[0].Badge_City_Character_Limit__c+' for city for record# : '+ numRecord);
                                }
                            }                                 
                            if (!String.isEmpty(inputvalues[9]))
                            {
                                if (inputvalues[9].length()<=eventSet[0].Badge_Address_Character_Limit__c)
                                {
                                    badge.Address__c= inputvalues[9];
                                }else{
                                    flag =1;
                                    loadflag= true;                                        
                                    addError('You have reached the character limit of '+eventSet[0].Badge_Address_Character_Limit__c+' for address for record# : '+ numRecord);
                                }
                            }
                            if (!String.isEmpty(inputvalues[10])) // CCEN-512
                            {
                                if(mapGlobalCountryValues.size()>0 && mapGlobalCountryValues.containsKey(inputvalues[10].trim())){
                                    badge.Nationality__c= mapGlobalCountryValues.get(inputvalues[10].trim()); 
                                }
                                else{
                                    flag =1;
                                    loadflag= true;                                        
                                    addError('You have given bad pick-list value for Nationality "'+inputvalues[10] +'" for record# :  '+ numRecord +' ,please verify CSV file');
                                }                                
                            }
                            if (!String.isEmpty(inputvalues[11]))
                            {
                                if(!ageBracketSet.contains(inputvalues[11])){
                                    flag =1;
                                    loadflag= true;                                        
                                    addError('You have given bad pick-list value for Age Bracket "'+inputvalues[11] +'" for record# :  '+ numRecord +' ,please verify CSV file');
                                }else{
                                    badge.Age_Bracket__c  = inputvalues[11];
                                }
                            }
                            if (!String.isEmpty(inputvalues[12]))
                            {
                                if (inputvalues[12].length()<=eventSet[0].Badge_JobTitle_Character_Limit__c)
                                {
                                    badge.Job_Title__c    = inputvalues[12];
                                }else{
                                    flag =1;
                                    loadflag= true;                                        
                                    addError('You have reached the character limit of '+eventSet[0].Badge_JobTitle_Character_Limit__c+' for job title for record# : '+ numRecord);
                                }
                            }
                            //BK-2895  
                            if(eventSet[0].Badges_MatchMaking__c == True && !String.isEmpty(inputvalues[13])){badge.MatchMaking__c = inputvalues[13];
                            }
                            if(inputvalues.size()>14){badge.Is_VIP__c= false;if(eventSet[0].Allow_VIP_Badges__c && !String.isEmpty(inputvalues[14])){string vip = 'Yes';
                                    if(vip.equalsIgnoreCase(inputvalues[14])){
                                        badge.Is_VIP__c        = true;
                                    }
                                }
                            }
                            badge.State__c             = inputvalues[7];
                            badge.Address__c           = inputvalues[9];
                            if((!String.isEmpty(accountId) && currentUserAccountList[0].profile.Name != 'Customer Community Login User Custom') || (eventSet[0].Approval_Not_Required__c == True && !badge.Is_VIP__c))
                            {
                                badge.Status__c = 'Approved';
                            }
                            else{badge.Status__c = 'Pending';
                            }
                            /****  BK-1820 Start ****/
                            if((String.isEmpty(inputvalues[0].trim()) && eventSet[0].Company_Name_on_Badge__c == True) || (String.isEmpty(inputvalues[1].trim()) && eventSet[0].Badge_First_Name__c == True) || (String.isEmpty(inputvalues[2].trim()) && eventSet[0].Badge_Last_Name__c == True) || (String.isEmpty(inputvalues[3].trim()) && eventSet[0].Badge_Email__c == True)  || (String.isEmpty(inputvalues[5].trim()) && eventSet[0].Badge_Mobile_Number__c == True) 
                                || (String.isEmpty(inputvalues[6].trim()) && eventSet[0].Badge_Country__c == True) || (String.isEmpty(inputvalues[7].trim()) && eventSet[0].Badge_State__c == True) || (String.isEmpty(inputvalues[8].trim()) && eventSet[0].Badge_City__c == True) || (String.isEmpty(inputvalues[9].trim()) && eventSet[0].Badge_Address__c == True) || (String.isEmpty(inputvalues[10].trim()) && eventSet[0].Badge_Nationality__c == True) 
                                || (String.isEmpty(inputvalues[11].trim()) && eventSet[0].Badge_Age_Bracket__c == True) || (String.isEmpty(inputvalues[12].trim()) && eventSet[0].Badge_Job_Title__c == True) || (String.isEmpty(inputvalues[13].trim()) && eventSet[0].Badges_MatchMaking__c == True) )
                            {
                                //badgesToUpload.add(badge);
                                addError('All fields are required in the csv file for record# : '+ numRecord);
                                flag =1;
                                loadflag= true;
                            }
                            else{
                               if (badgesToUpload.size()>=900){flag =1;loadflag= true;addError('Sorry! Number of badges exceeds 900. Please make multiple files with badges less than 900 per file and upload multiple times.');
                                } else {
                                    badgesToUpload.add(badge);
                                    System.debug('badgesToUpload' +badgesToUpload);
                                }
                            }                            
                            if(flag ==1){uploadallowed = false;
                            }
                            /****  BK-1820 End ****/
                        }                                                      
                    }
                    if(!uploadallowed){System.debug('badgesToUpload12' +badgesToUpload);badgesToUpload.clear(); 
                    }
                    //Finally, insert the collected records from Badges import csv file
                    try
                    {   
                        System.debug('badgesToUpload23' +badgesToUpload);
                        Boolean checkVIPBadge = false;
                        // check the badges against the allowed badges limits   
                        if(!badgesToUpload.isEmpty() && uploadallowed){     
                            //Get fresh badge limit as it might be outdated (in case badge limit is changed before uploading)
                            List<Event_Settings__c> currentEventSetting = new List<Event_Settings__c>();
                            if(Schema.sObjectType.Event_Settings__c.isAccessible()){
                                currentEventSetting = [Select Agent_Badge_limit__c FROM Event_Settings__c where Event_Edition__r.Event_Code__c =:eventCodeFromURl LIMIT 1];
                            }
                            Integer allowedBadges = Integer.valueOf(currentEventSetting[0].Agent_Badge_limit__c) > 0? Integer.valueOf(currentEventSetting[0].Agent_Badge_limit__c):0;
                            if(Integer.valueOf(eventMapping.Badge_Limit__c) > 0){allowedBadges+= Integer.valueOf(eventMapping.Badge_Limit__c);
                            }
                            //Integer allowedBadges = Integer.valueOf(currentEventSetting[0].Agent_Badge_limit__c) + Integer.valueOf(eventMapping.Badge_Limit__c);
                            //increase badge limit
                            Integer availableBadges =Integer.valueOf(eventMapping.Total_Badges__c) >0? allowedBadges - Integer.valueOf(eventMapping.Total_Badges__c):allowedBadges-0;
                            
                            if(availableBadges < badgesToUpload.size()){ addError('Sorry!! Badges limit reached. '+availableBadges+' out of '+allowedBadges+' badges are available');
                            } else {
                                try{ 
                                    if(Schema.sObjectType.Agent_Badges__c.isCreateable()){
                                        insert badgesToUpload;
                                    }
                                    for(Agent_Badges__c badge: badgesToUpload)
                                    {
                                        if(badge.Is_VIP__c && !String.isEmpty(accountId) && currentUserAccountList[0].profile.Name == 'Customer Community Login User Custom')
                                        {checkVIPBadge = true;
                                        }
                                    }
                                    if(checkVIPBadge)
                                    {BadgesUtils.sendEmailByCode('VBWR',eventEditionId,accountId);
                                    }
                                        fileUploadcomplete = true;
                                    ApexPages.Message successMsg = new ApexPages.Message(ApexPages.severity.Confirm,'File has been uploaded successfully!');  ApexPages.addMessage(successMsg);                                            
                                } 
                                catch (DMLException e)
                                {
                                    addError('An error has occured inserting the records'+e.getdmlMessage(0)); 
                                }                                                  
                            }                                                                             
                        }
                    }                        
                    catch (Exception e)
                    {
                        addError('An error has occured inserting the records'+e.getMessage());
                    }
                } 
                else
                {                       
                    addError('Please convert xlsx file to csv file to upload.');
                }
            }
            else
            {                    
                addError('Please select file to upload.');
            }
            
        }
        catch(Exception e)
        {                 
            addError('An error has occured reading the CSV file'+e.getMessage() +' at line '+ e.getLineNumber());
        }                     
        return null;
    }    
    /**** @description : This function sends back to the visualforce page the list of Agent_Badges__c records that were inserted 
@return : List<Agent_Badges__c> ****/ 
    public List<Agent_Badges__c> getuploadedExhibitorBadges()
    {
        if (badgesToUpload!= NULL){
            if (badgesToUpload.size() > 0){
                return badgesToUpload;
            }
            else{
                return null;
            }
        }                 
        else{return null;
        }
    }  
    
    /** @description : Function for converting the input CSV file in BLOB format into a string  
@return : String **/
    public static String blobToString(Blob input, String inCharset)
    {
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i){
            bytes[i] =  hex.mid(i << 1, 2);
        }  
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    } 
    
    public PageReference detailBadges() {
        return null;
    }
    
    /*Function to parseCSV */ //CCEN-598
    public List<List<String>> parseCSV(String contents) 
    {        
        contents = contents.trim();

        // Determine if it is split by newLine(\n) or return carriage(\r) or a \r\nn
        Boolean hasNewLine = false;
        Boolean hasCarrReturn = false;
        
        //First check for a \r\n char
        if(contents.contains('\r\n')){hasNewLine = true;hasCarrReturn = false;
        }
        else
        {
            //If not then check for either a /r or /n
            if(contents.contains('\n'))
            {                
                hasNewLine = true;
            }
            if(contents.contains('\r')){hasCarrReturn = true;
            }
        } 
        //        
        List<List<String>> allFields = new List<List<String>>();
        if(hasNewLine && hasCarrReturn){addError('The file contains both newline and carriage returns ,Please Make Another File To Upload');
        }
        else 
        {            
            String splitBy = '\n';
            if(hasCarrReturn) {splitBy = '\r';
            }            
            // replace instances where a double quote begins a field containing a comma
            // in this case you get a double quote followed by a doubled double quote
            // do this for beginning and end of a field
            contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
            // now replace all remaining double quotes - we do this so that we can reconstruct
            // fields with commas inside assuming they begin and end with a double quote
            contents = contents.replaceAll('""','DBLQT');
            // we are not attempting to handle fields with a newline inside of them
            // so, split on newline to get the spreadsheet rows
            List<String> lines = new List<String>();
            try 
            {
                lines = contents.split(splitBy);
            } 
            catch (System.ListException e) 
            {
                System.debug('## Limits exceeded?' + e.getMessage());
            }
            //System.debug('## About to check ' + lines.size() + ' lines...');
            Integer num = 0;
            Integer size = lines.size();
            
            for(Integer i=1; i < size; i++) 
            {   
                string rows =  lines[i];
                rows = rows.trim();
                if(rows.contains('",",')  || (rows.startsWith('",'))){addError('Please correct the csv file as Column value should not start with comma(e.g ,Abc)'+' at line '+ i);hasError = true;
                }
                rows = rows.replaceAll(',",','#COMMA#",');
                rows = rows.replaceAll('",",','","#COMMA#');
                // checking 
                if(rows.substring(rows.length() - 2,rows.length()) == ',"'){rows= rows.substring(0,rows.length() - 2);rows= rows+'#COMMA#"';
                }
                system.debug('####################'+rows);
                List<String> fields = rows.split(',', -1);  
                List<String> cleanFields = new List<String>();
                String compositeField;
                Boolean makeCompositeField = false;                
                for(String field : fields) 
                {
                    if (field.startsWith('"') && field.endsWith('"') ){cleanFields.add(field.replaceAll('DBLQT','"'));
                    } else if (field.startsWith('"') ){makeCompositeField = true;compositeField = field;
                    } else if (field.endsWith('"') )
                    {
                        compositeField += ',' + field;
                        cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                        makeCompositeField = false;
                    } else if (makeCompositeField)
                    {
                        compositeField +=  ',' + field;
                    } else
                    {
                        cleanFields.add(field.replaceAll('DBLQT','"'));
                    }
                }
               // System.debug(' #### compositeField '+compositeField);                
                // Remove double quotes (if present) from start and end of each field
                List<String> noQuoteFields = new List<String>();
                for(String field : cleanFields)
                {
                    if(field.startsWith('"') && field.endsWith('"') )
                    {
                        if(field == '"'){
                            field = ',';
                        }  
                        else{
                            field = field.substring(1, field.length() - 1);
                        }
                    }
                    field = field.replaceAll('#COMMA#',',');
                    noQuoteFields.add(field);
                }
                allFields.add(noQuoteFields);
            }
        }     
        // Remove any rows before header row so that header row is first row:
        Integer headerRow = -1;
        for(Integer i=0; (i < allFields.size() && headerRow == -1) ; i++) {
            // Determine if all fields in this row are non-blank:
            List<String> row = allFields.get(i);
            Boolean isHeaderRow = true;            
            for(String field : row) {
                if(field == '') { // field is blank
                    isHeaderRow = false;
                }
            }            
            if(isHeaderRow)
            {
                headerRow = i;
            }
        }        
        for(Integer i=0; i < headerRow; i++)
        {
            allFields.remove(0);
        }
        return allFields;
    }
    
    public static void addError(String error) //CCEN-598
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
    }
   
}