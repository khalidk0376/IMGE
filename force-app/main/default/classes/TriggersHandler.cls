/**
 * Created/Modified By: Girikon(Aishwarya)/Aishwarya,Sunil CCEN-344, Amish CCEN 764
 * Created On:          12/12/2017
 * Modified On:         09/17/2018, 04/26/2018
 * Modified By:         Girikon[Prashant(C2E-12) 20 Sept 2019] Girikon[Rajeev(BK-3335) 5 Feb 2020],[Aishwarya BK-4069 May 15 2020],[Aishwarya BK-3754 25 june 2020 ]
 * @description : Handler class which will be called by the trigger on Objects - EventEdition, Attachment, Event_Edition_Form, Email Templates/ CCEN-47, CCEN-234, 
 * Methods:             CheckFileExtension, CreateEEEmailTempRecordOnEmailTemplate, CheckDuplicateFormPermissionRecords, CreateFormPermissionRecords, 
                        CreateFormPermissionRecordsUpdate, AssignManualPermission, AssignManualPermissionRecordsUpdate, CloneEventEditionCS
 * Test Class:          triggersHandler_Test (89%)
**/

public without sharing class TriggersHandler{ 

    /**
    * @description : Method CheckFileExtension Start
    **/
    public void checkFileExtension(List<Attachment> listAttachment)
    {
        String sFileTypes = (AllowedFileTypes__c.getValues('FileTypes') != null) ? AllowedFileTypes__c.getValues('FileTypes').Value__c : 'pdf'; //retrieve file type format name from custom setting.
        set<String> setExtAllowed = new set<String>(sFileTypes.split(',')); //Adding file format type.
     
        String sFormPrefix = Form__c.sobjecttype.getDescribe().getKeyPrefix(); // Get Form object prefix.
        
        String sManualPrefix = Manual__c.sobjecttype.getDescribe().getKeyPrefix(); // Get Manual object prefix.
        
        for (Attachment attachment :ListAttachment)
        {
            if(attachment!=null)
            {
                String strFilename = attachment.Name.toLowerCase(); //converting attachment name to lowercase.
                
                List<String> parts = strFilename.splitByCharacterType(); //split Attachment name.
                String sParendId ='';
                if(attachment.parentId != null)
                {
                    sParendId = attachment.parentId; 
                }
                if(String.isNotBlank(sParendId) && (sParendId.contains(sFormPrefix) || sParendId.contains(sManualPrefix))) //Checking attachment parentId have form or manual object.
                {
                    if(!setExtAllowed.contains(parts[parts.size()-1])) // checking file format.
                    {
                        attachment.addError('File with extension other than '+sFileTypes.toUppercase()+' could not be attached!!'); //show error file format does not have pdf format. 
                    }
                }
            }        
        }
    }
    // Method CheckFileExtension End
    
    /**
    * @description : Method CreateEEEmailTempRecordOnEmailTemplate Start
    **/
    public void createEEEmailTempRecordOnEmailTemplate(List<Email_Templates__c> listEmailTemplates)
    {
        List<Email_Templates__c> etList = new List<Email_Templates__c>();
        List<Event_Edition_Email_Template__c> eetList = new List<Event_Edition_Email_Template__c>();
        List<Event_Edition__c> eventList = new List<Event_Edition__c>();
        Set<String> emailTemplateId=new Set<String>();
        
        //Getting Email Template Id 
        for(Email_Templates__c et: ListEmailTemplates)
        {
            emailTemplateId.Add(et.Id);
        }
        if(Schema.sObjectType.Email_Templates__c.isAccessible())
        {
           etList = [SELECT Id, Name, Content__c, Group_Name__c, Subject__c, Template_Code__c FROM Email_Templates__c WHERE ID in: emailTemplateId limit 1]; 
        }
        if(Schema.sObjectType.Event_Edition__c.isAccessible())
        {
            eventList = [SELECT Id,Name FROM Event_Edition__c WHERE End_Date__c > Today AND Event_Edition_Status__c ='Confirmed'];
        }
        //eventList = [SELECT Id,Name FROM Event_Edition__c WHERE Start_Date__c > Today];
        system.debug('etList==== '+etList);  system.debug('eventList==== '+eventList );
        
        //Creating records for Event_Edition_Email_Template__c
        if(eventList.size()>0)
        {
            for(Event_Edition__c ee:eventList ){    
                system.debug('test===='+ee.Name);
                Event_Edition_Email_Template__c eeet = new Event_Edition_Email_Template__c();
                eeet.Event_Edition__c = ee.Id;
                eeet.Email_Template__c = etList[0].Id;
                eeet.Name = etList[0].Name;
                eeet.Content__c = etList[0].Content__c;
                eeet.Subject__c = etList[0].Subject__c;
                eeet.Email_Template_Code__c = etList[0].Template_Code__c;
                eetList.add(eeet);
            }
        }
        system.debug('eetList===='+eetList);
        if(eetList.size()>0 && Schema.sObjectType.Event_Edition_Email_Template__c.isCreateable())
        {
            insert(eetList);
        }
    }
    // Method CreateEEEmailTempRecordOnEmailTemplate End
    
    /**
    * @description : Method CheckDuplicateFormPermissionRecords Start
    **/
    public void checkDuplicateFormPermissionRecords(List<Event_Edition_Form__c> listEventEditionForms)
    {
        Set<Id> setFormIds = new Set<Id>();
        Set<Id> setEventEditionIds = new Set<Id>();
        // To check if a Form is already exist with the existing Event Edition
        for(Event_Edition_Form__c eVF : ListEventEditionForms)
        {
            setFormIds.add(eVF.Forms__c);
            setEventEditionIds.add(eVF.Event_Edition__c);
        }
        List<Event_Edition_Form__c> listExistingEVF = New List<Event_Edition_Form__c>();
        Map<String,String> mapExistingEVF=new Map<String,String>();
        if(Schema.sObjectType.Event_Edition_Form__c.isAccessible())
        {
            listExistingEVF =[Select Id,Event_Edition__c,Forms__c from Event_Edition_Form__c where Forms__c IN: setFormIds AND Event_Edition__c IN: setEventEditionIds];
        }
        If(listExistingEVF!=null && listExistingEVF.size()>0){for(Event_Edition_Form__c evf:listExistingEVF){mapExistingEVF.Put(evf.Event_Edition__c+'#'+evf.Forms__c,evf.Id);
            }
        }
        
        for(Event_Edition_Form__c eVF : ListEventEditionForms)
        {
            If(mapExistingEVF!=null && mapExistingEVF.size()>0 && mapExistingEVF.ContainsKey(eVF.Event_Edition__c+'#'+eVF.Forms__c))
            {
               system.debug('==========================MATCH: mapExistingEVF:: '+mapExistingEVF);
               Final String errMsg = 'Selected form is already added to this Event Edition';
               eVF.addError(errMsg);
            }    
        }
    }
    // Method CheckDuplicateFormPermissionRecords End
    
    /**
    * @description : Method CreateFormPermissionRecords Start
    **/
    public void createFormPermissionRecords(List<Event_Edition_Form__c> listEventEditionForms, Set<Id> eEFIds)
    {
        Map<string,string> mapUserType = new Map<string,string>();
        List<Forms_Permission__c> listFormPermissionToInsert = new List<Forms_Permission__c>();
        // put UserType Name from object - UserType into map in order to match the UserType id for providing the Form Permission
        for(User_Type__c userType :[select id, Name from User_Type__c LIMIT 100])
        {
            mapUserType.put(userType.Name, userType.Id);
            system.debug('==================MAP'+mapUserType);
        }
        system.debug('####################LIST '+ListEventEditionForms); system.debug('####################SETIds '+EEFIds);
        
        Set<String> setUTypeAndEEForm = new Set<String>();
        Map<Id, Forms_Permission__c> mapExistingFormPermission;
        
        // check existing Form Permission for this EEForm and associated User Type
        mapExistingFormPermission = new Map<Id, Forms_Permission__c>([Select Id, Event_Edition_Form__c, Event_Edition_Form__r.Event_Edition__c, User_Type__r.Name
                                                                      FROM Forms_Permission__c Where Event_Edition_Form__c IN:EEFIds]);
        system.debug('####################FP Records '+mapExistingFormPermission);
        
        for(Forms_Permission__c fp :mapExistingFormPermission.values()){setUTypeAndEEForm.add(fp.User_Type__r.Name +''+ fp.Event_Edition_Form__c);
        }
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@ '+setUTypeAndEEForm);
        for(Event_Edition_Form__c eVF : ListEventEditionForms)
        {
            String uType = eVF.User_Type__c; 
            system.debug('+++++++++++++++'+uType);
            List<String> userType = new List<String>();
            If(uType != null){
                userType = uType.split(';'); // split the UserType by ';' as there may be more than one User Type selected and add them to list.
            }

            If(userType.size()>0)
            {
                // creating Form Permission records on basis of the number of UserType selected. e.g Agent, Exhibitor 
                for(Integer i=0; i<userType.size(); i++)
                {
                    if(!setUTypeAndEEForm.contains(userType[i] +''+eVF.Id)){
                        // initialize form permission object
                        Forms_Permission__c formPermission = new Forms_Permission__c();
                        formPermission.Active__c = True;
                        formPermission.Event_Edition_Form__c = eVF.Id;
                        if(mapUserType.containsKey(userType[i]))
                        {
                            formPermission.User_Type__c = mapUserType.get(userType[i]);
                        } 
                        listFormPermissionToInsert.add(formPermission);
                    }
                }
            }
        }
        system.debug('========================='+listFormPermissionToInsert);
        try{
            if(listFormPermissionToInsert.size()>0 && Schema.sObjectType.Forms_Permission__c.isCreateable()){
                insert listFormPermissionToInsert; // Insert List
            }
            else{
                update mapExistingFormPermission.values();
            }
        }catch(exception ex){ex.getMessage();}
    }
    // Method CreateFormPermissionRecords End
    
    /**
    * @description : Method CreateFormPermissionRecords Start
    **/
    public void createFormPermissionRecordsUpdate(List<Event_Edition_Form__c> listEventEditionForms, Set<Id> eEFIds, List<String> listUserTypeForDelete)
    {
        List<Forms_Permission__c> listFPermissionsForDelete = new List<Forms_Permission__c>();
        Map<string,string> mapUserType = new Map<string,string>();
        List<Forms_Permission__c> listFormPermissionToInsert = new List<Forms_Permission__c>();
        system.debug('========================UType'+listUserTypeForDelete);
        listFPermissionsForDelete = [Select Id, Name FROM Forms_Permission__c where User_Type__r.Name IN:listUserTypeForDelete AND Event_Edition_Form__c IN:EEFIds];
        system.debug('########################FP Delete '+listFPermissionsForDelete +'Size:: '+listFPermissionsForDelete.size());
        if(listFPermissionsForDelete.size() >0){
            delete listFPermissionsForDelete;
        }
        // put UserType Name from object - UserType into map in order to match the UserType id for providing the Form Permission
        for(User_Type__c userType :[select id, Name from User_Type__c LIMIT 100])
        {
            mapUserType.put(userType.Name, userType.Id);
            system.debug('==================MAP'+mapUserType);
        }
        system.debug('####################LIST '+ListEventEditionForms); system.debug('####################SETIds '+EEFIds);
        
        Set<String> setUTypeAndEEForm = new Set<String>();
        Map<Id, Forms_Permission__c> mapExistingFormPermission;
        
        // check existing Form Permission for this EEForm and associated User Type
        mapExistingFormPermission = new Map<Id, Forms_Permission__c>([Select Id, Event_Edition_Form__c, Event_Edition_Form__r.Event_Edition__c, User_Type__r.Name
                                                                      FROM Forms_Permission__c Where Event_Edition_Form__c IN:EEFIds AND User_Type__r.Name NOT IN:listUserTypeForDelete]);
        system.debug('####################FP Records '+mapExistingFormPermission);
        
        for(Forms_Permission__c fp :mapExistingFormPermission.values()){
            setUTypeAndEEForm.add(fp.User_Type__r.Name +''+ fp.Event_Edition_Form__c);
        }
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@ '+setUTypeAndEEForm);
        for(Event_Edition_Form__c eVF : ListEventEditionForms)
        {
            String uType = eVF.User_Type__c; 
            system.debug('+++++++++++++++'+UType);
            List<String> userType = new List<String>();
            If(uType != null)
                UserType = uType.split(';'); // split the UserType by ';' as there may be more than one User Type selected and add them to list.
            
            If(userType.size()>0)
            {
                // creating Form Permission records on basis of the number of UserType selected. e.g Agent, Exhibitor 
                for(Integer i=0; i<userType.size(); i++)
                {
                    if(!setUTypeAndEEForm.contains(UserType[i] +''+eVF.Id)){
                        // initialize form permission object
                        Forms_Permission__c formPermission = new Forms_Permission__c();
                        FormPermission.Active__c = True;
                        FormPermission.Event_Edition_Form__c = eVF.Id;
                        if(mapUserType.containsKey(UserType[i]))
                            FormPermission.User_Type__c = mapUserType.get(UserType[i]);
                        listFormPermissionToInsert.add(FormPermission);
                    }
                }
            }
        }
        system.debug('========================='+listFormPermissionToInsert);
        try{
            if(listFormPermissionToInsert.size()>0)
                insert listFormPermissionToInsert; // Insert List
            if(mapExistingFormPermission.size()>0){
                update mapExistingFormPermission.values();
            }
        }catch(exception ex){ex.getMessage();}
    }
    // Method CreateFormPermissionRecordsUpdate End
    
    /**
    * @description : Method AssignManualPermission Start
    **/
    public void assignManualPermission(List<Manual__c> manualList, Set<Id> manualIds)
    {
        Map<string,string> mapUserType = new Map<string,string>();
        List<Manuals_Permission__c> listManualPermissionToInsert = new List<Manuals_Permission__c>();
        // put UserType Name from object - UserType into map in order to match the UserType id for providing the Manual Permission
        for(User_Type__c userType :[select id, Name from User_Type__c LIMIT 100])
        {
            mapUserType.put(UserType.Name, UserType.Id);
        }
        Set<String> setUTypeAndManual = new Set<String>();
        Map<Id, Manuals_Permission__c> mapExistingManualPermission;
        
        // check existing Manual Permission for this EEManual and associated User Type
        mapExistingManualPermission = new Map<Id, Manuals_Permission__c>([Select Id, Manuals__c, Manuals__r.Event_Edition__c, User_Type__r.Name
                                                                      FROM Manuals_Permission__c Where Manuals__c IN:ManualIds]);
        system.debug('####################FP Records '+mapExistingManualPermission);
        for(Manuals_Permission__c mp :mapExistingManualPermission.values()){SetUTypeAndManual.add(mp.User_Type__r.Name +''+ mp.Manuals__c);
        }
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@ '+SetUTypeAndManual);
        for(Manual__c manual : manualList)
        {
            String uType = Manual.User_Type__c; 
            system.debug('+++++++++++++++'+uType);
            List<String> userType = new List<String>();
            If(uType != null)
                userType = uType.split(';'); // split the UserType by ';' as there may be more than one User Type selected and add them to list.
            
            If(userType.size()>0)
            {
                // creating Manual Permission records on basis of the number of UserType selected. e.g Agent, Exhibitor 
                for(Integer i=0; i<userType.size(); i++)
                {
                    if(!SetUTypeAndManual.contains(userType[i] +''+manual.Id)){
                        // initialize Manual permission object
                        Manuals_Permission__c manualPermission = new Manuals_Permission__c();
                        manualPermission.Active__c = True;
                        manualPermission.Manuals__c = Manual.Id;
                        //if( (mapUserType.containsKey(UserType[i]) && !mapUserType.containsKey('Stand Contractor'))  )
                         if(mapUserType.containsKey(userType[i]))
                            ManualPermission.User_Type__c = mapUserType.get(userType[i]);
                         listManualPermissionToInsert.add(manualPermission);
                    }
                }
            }
        }
        system.debug('========================='+ListManualPermissionToInsert);
        try{
        if(ListManualPermissionToInsert.size()>0)
            insert ListManualPermissionToInsert; // Insert List
        else
            update mapExistingManualPermission.values();
        }catch(exception ex){ex.getMessage();} 
     }
     // Method AssignManualPermission End
    
    /**
    * @description : Method AssignManualPermissionRecordsUpdate Start
    **/
    public void assignManualPermissionRecordsUpdate(List<Manual__c> manualList, Set<Id> manualIds, List<String> listUserTypeForDelete)
    {
        Map<string,string> mapUserType = new Map<string,string>();
        List<Manuals_Permission__c> listManualPermissionToInsert = new List<Manuals_Permission__c>();
        List<Manuals_Permission__c> listMPermissionForDelete = new List<Manuals_Permission__c>();
        
        listMPermissionForDelete = [Select Id, Name FROM Manuals_Permission__c where User_Type__r.Name IN:listUserTypeForDelete AND Manuals__c IN:ManualIds];
        system.debug('########################MP Delete '+listMPermissionForDelete +'Size:: '+listMPermissionForDelete.size());
        if(listMPermissionForDelete.size() >0)
            delete listMPermissionForDelete;
        //put UserType Name from object - UserType into map in order to match the UserType id for providing the Manual Permission
        for(User_Type__c userType :[select id, Name from User_Type__c LIMIT 100]){
            mapUserType.put(userType.Name, userType.Id);
        }
        Set<String> setUTypeAndManual = new Set<String>();
        Map<Id, Manuals_Permission__c> mapExistingManualPermission;
        
        // check existing Manual Permission for this EEManual and associated User Type
        mapExistingManualPermission = new Map<Id, Manuals_Permission__c>([Select Id, Manuals__c, Manuals__r.Event_Edition__c, User_Type__r.Name
                                                  FROM Manuals_Permission__c Where Manuals__c IN:ManualIds AND User_Type__r.Name NOT IN:listUserTypeForDelete]);
        system.debug('####################FP Records '+mapExistingManualPermission);
        for(Manuals_Permission__c mp :mapExistingManualPermission.values()){SetUTypeAndManual.add(mp.User_Type__r.Name +''+ mp.Manuals__c);
        }
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@ '+SetUTypeAndManual);
        for(Manual__c manual : manualList)
        {
            String uType = Manual.User_Type__c; 
            system.debug('+++++++++++++++'+UType);
            List<String> userType = new List<String>();
            If(uType != null)
                userType = uType.split(';'); // split the UserType by ';' as there may be more than one User Type selected and add them to list.
            
            If(userType.size()>0)
            {
                // creating Manual Permission records on basis of the number of UserType selected. e.g Agent, Exhibitor 
                for(Integer i=0; i<UserType.size(); i++)
                {
                    if(!SetUTypeAndManual.contains(UserType[i] +''+Manual.Id)){
                        // initialize Manual permission object
                        Manuals_Permission__c manualPermission = new Manuals_Permission__c();
                        manualPermission.Active__c = True;
                        manualPermission.Manuals__c = Manual.Id;
                        if(mapUserType.containsKey(UserType[i]))
                            ManualPermission.User_Type__c = mapUserType.get(UserType[i]);
                        listManualPermissionToInsert.add(manualPermission);
                    }
                }
            }
        }
        system.debug('========================='+ListManualPermissionToInsert);
        try{
        if(ListManualPermissionToInsert.size()>0)
            insert ListManualPermissionToInsert; // Insert List
        if(mapExistingManualPermission.size()>0)
            update mapExistingManualPermission.values();
        }catch(exception ex){ex.getMessage();} 
     }
     // Method AssignManualPermissionRecordsUpdate End
     
     //:: trgCloneEventEditionCS :: triggersHandler

    /** commented BK-5511
    * @description : Method CloneEventEditionCS Start */ 
    
    public void cloneEventEditionCS(Map<Id, Event_Edition__c> mapEventEditionClone)
    {
        // Added by Palla Kishore for the ticket BK-19604
        system.debug('cloneEventEditionCS Method is Invoked');
    /*
        map<Id,Event_Edition__c> mapEventEditon = mapEventEditionClone;
        map<string,string> mapEditionSeries = new map<string,string>();
        map<string,string> mapNewAndLastEditionId = new map<string,string>();
        //map<string,string> mapNewEditionIdName = new map<string,string>();
        List<Event_Edition_Form__c> formLstToInsert = new List<Event_Edition_Form__c>();
        List<Manual__c> manualLstToInsert = new List<Manual__c>();
        List<Event_Edition_Email_Template__c> eventEmailLstToInsert = new List<Event_Edition_Email_Template__c>();
        List<Event_Settings__c> eventsettingLstToInsert = new List<Event_Settings__c >();
        List<Booth_Size_Badge_Limit__c> boothSizeLstToInsert = new List<Booth_Size_Badge_Limit__c>();
        List<attachment> manualAttLstToInsert = new List<attachment>();
        List<string> firstNewEEIDs=new List<string>();
        
        for(Event_Edition__c event :mapEventEditon.values())
        {
            mapEditionSeries.put(event.id,event.Part_of_Series__c);
        }
        
        if(mapEditionSeries.size()>0 && mapEditionSeries!=null)
        {               
            list<Event_Series__c> seriesLst =[SELECT ID,(select id,name,CreatedDate,Year__c from Event_Edition__r where Year__c!=null order By Year__c Desc Limit 2) from Event_Series__c WHERE Id IN :mapEditionSeries.values()]; //BK-4069 update reference of End Date to Year
            system.debug('seriesLst='+seriesLst);
            if(seriesLst!=null && seriesLst.size()>0)
            {
                for(Event_Series__c series :seriesLst)
                { 
                    if (series.Event_Edition__r.size() > 0 ){
                        if(series.Event_Edition__r!=null && series.Event_Edition__r.size()>1)
                        {   
                            if(series.Event_Edition__r[1].Year__c!=null)
                            {
                                system.debug('testseriesdata'+series.Event_Edition__r[1].id+'========'+series.Event_Edition__r[1].name);
                                mapNewAndLastEditionId.put(series.Event_Edition__r[1].id,series.Event_Edition__r[0].id); 
                                //mapNewEditionIdName.put(series.Event_Edition__r[0].Id,series.Event_Edition__r[0].Name);
                            }
                            else
                            {
                                mapNewAndLastEditionId.put(series.Event_Edition__r[0].id,series.Event_Edition__r[1].id);  
                                //mapNewEditionIdName.put(series.Event_Edition__r[1].Id,series.Event_Edition__r[1].Name); 
                            }                        
                        }
                        else {
                            if(series.Event_Edition__r[0].id!=null){
                              firstNewEEIDs.Add(series.Event_Edition__r[0].id);  
                            }
                        } 
                    }
                }
                system.debug('mapNewAndLastEditionId='+mapNewAndLastEditionId.KeySet()); 
                //system.debug('mapNewEditionIdName='+mapNewEditionIdName);
                
                // insert Event Edition Form
                list<Event_Edition_Form__c> eventEdtFormLst = new list<Event_Edition_Form__c>();                
                eventEdtFormLst = [select id,Allow_Submit_After_Deadline__c,Event_Edition__c,Deadline__c,Exclusive__c,Forms__c,Form_Group__c,Form_Type__c,
                                   Mandatory__c,Provider__c,User_Type__c from Event_Edition_Form__c where Event_Edition__c IN : mapNewAndLastEditionId.KeySet()];
                system.debug('eventEdtFormLst='+eventEdtFormLst);
                if(eventEdtFormLst!=null && eventEdtFormLst.size()>0)
                {
                    for(Event_Edition_Form__c editionForm : eventEdtFormLst)
                    {
                        string newEditionId = mapNewAndLastEditionId.get(editionForm.Event_Edition__c);
                        Event_Edition_Form__c evtEditionFrm = editionForm.clone(false, true, false, false);
                        evtEditionFrm.Event_Edition__c = newEditionId;
                        formLstToInsert.add(evtEditionFrm);
                    }
                    if(formLstToInsert.size()>0 && formLstToInsert!=null)
                    {
                        insert formLstToInsert;                 
                    }
                }
                
                // Insert Manuals
                list<Manual__c> manualLst = new list<Manual__c>();
                list<string> attLst = new list<string>();
                map<string,Id> attAndNewManualIdMap = new map<string,Id>();
                
                ManualLst = [select id,name,Event_Edition__c,Manual_Description__c,Required__c,Section__c,Uploaded_Attachment_Id__c,Uploaded_Attachment_Name__c,User_Type__c from Manual__c where Event_Edition__c IN : mapNewAndLastEditionId.KeySet()];
                if(ManualLst!=null && ManualLst.size()>0)
                {
                    for(Manual__c manual : manualLst)
                    {
                        string newEditionId = mapNewAndLastEditionId.get(Manual.Event_Edition__c);   
                        Manual__c newManual = Manual.clone(false, true, false, false);
                        newManual.Event_Edition__c = newEditionId;
                        manualLstToInsert.add(newManual);
                        attLst.add(manual.Uploaded_Attachment_Id__c);               
                        
                    }
                    if(manualLstToInsert.size()>0 && manualLstToInsert!=null)
                    {
                        insert manualLstToInsert;
                        
                        for(Manual__c manual :manualLstToInsert)
                        {
                            attAndNewManualIdMap.put(manual.Uploaded_Attachment_Id__c,manual.Id);
                        }
                        
                        list<attachment> oldAttList = new list<attachment>([select id,name,body from attachment where Id IN :attLst]);
                        {
                            system.debug('oldAttList ='+oldAttList);
                            for(attachment att : oldAttList){
                                string newManualId = attAndNewManualIdMap.get(att.id);
                                attachment newAtt = att.clone(false, true, false, false);
                                newAtt.parentId = newManualId;
                                manualAttLstToInsert.add(newAtt);
                            }
                        }
                        
                        system.debug('manualLstToInsert='+manualLstToInsert);
                        if(manualAttLstToInsert.size()>0 && manualAttLstToInsert!=null){insert manualAttLstToInsert;
                        }
                    }
                }
                
                // Insert Email - Template
                list<Event_Edition_Email_Template__c> eventEmaillLst = new list<Event_Edition_Email_Template__c>();
                eventEmaillLst = [select id,name,Content__c,Email_Template__c,Email_Template_Code__c,Event_Edition__c,Subject__c from Event_Edition_Email_Template__c where Event_Edition__c IN : mapNewAndLastEditionId.KeySet()];
                if(eventEmaillLst!=null && eventEmaillLst.size()>0)
                {
                    for(Event_Edition_Email_Template__c eventEmail : eventEmaillLst)
                    {
                        string newEditionId = mapNewAndLastEditionId.get(eventEmail.Event_Edition__c);                        
                        Event_Edition_Email_Template__c neweventEmail = eventEmail.clone(false, true, false, false);
                        neweventEmail.Event_Edition__c = newEditionId;
                        eventEmailLstToInsert.add(neweventEmail);  
                    }
                    system.debug('eventEmailLstToInsert='+eventEmailLstToInsert);
                }
                
                // CCEN-344
                // Insert Email - Template from global email templates, for Event Edition(s) which are very first in event series
                list<Email_Templates__c> globalEmaillLst = new list<Email_Templates__c>();
                globalEmaillLst = [select id,name,Content__c,Template_Code__c,Subject__c from Email_Templates__c];
                if(firstNewEEIDs!=null && !firstNewEEIDs.IsEmpty())
                {
                    for(string newEditionId : firstNewEEIDs)
                    {
                        
                        if(globalEmaillLst!=null && !globalEmaillLst.IsEmpty())
                        {
                            
                            for(Email_Templates__c eventEmail : globalEmaillLst)
                            {                    
                                Event_Edition_Email_Template__c neweventEmail = new Event_Edition_Email_Template__c();
                                neweventEmail.name = eventEmail.Name;
                                neweventEmail.Content__c = eventEmail.Content__c;
                                neweventEmail.Email_Template__c = eventEmail.Id;
                                neweventEmail.Email_Template_Code__c = eventEmail.Template_Code__c;
                                neweventEmail.Subject__c = eventEmail.Subject__c;
                                neweventEmail.Event_Edition__c = newEditionId;
                                eventEmailLstToInsert.add(neweventEmail);               
                            }
                            system.debug('eventEmailLstToInsert='+eventEmailLstToInsert);
                        }
                    }
                }
                
                if(eventEmailLstToInsert.size()>0 && eventEmailLstToInsert!=null)
                {
                   insert eventEmailLstToInsert;                   
                }
                
                // insert Booth Size Badge Limit
                list<Booth_Size_Badge_Limit__c> boothSizeLst = new list<Booth_Size_Badge_Limit__c>();
                boothSizeLst = [SELECT id,  Name ,Event_Edition__c,Booth_Size_To__c,Booth_Size_From__c,Badges_Allowed__c from Booth_Size_Badge_Limit__c WHERE Event_Edition__c IN : mapNewAndLastEditionId.KeySet() And Booth_Type__c = null];
               
                if(boothSizeLst!=null && boothSizeLst.size()>0)
                {
                    for(Booth_Size_Badge_Limit__c boothSize:boothSizeLst)
                    {
                        string newEditionId = mapNewAndLastEditionId.get(boothSize.Event_Edition__c);
                        Booth_Size_Badge_Limit__c newBoothSize = boothSize.clone(false, true, false, false);
                        newBoothSize.Event_Edition__c = newEditionId;
                        boothSizeLstToInsert.add(newBoothSize);                        
                    }
                   if(boothSizeLstToInsert.size()>0 && boothSizeLstToInsert!=null)
                    {
                        insert boothSizeLstToInsert;                 
                    }
                }
                
                // insert Event-Setting
                // Added Welcome_Text_Agent_Exhibitor_Details__c in Event settings[C2E-12]
                list<Event_Settings__c> eventSettinglLst = new list<Event_Settings__c>();
                eventSettinglLst = [Select Id, IsDeleted, Name, Welcome_Message__c, Welcome_Text_Agent_Exhibitor_Details__c, Welcome_Text_Upload_Center__c, Badge_First_Name__c, Event_Edition__c,
                                    Badge_Last_Name__c, Forms_Title__c, Forms_Sub_Title__c, Badge_Job_Title__c, Manuals_Title__c, Manuals_Sub_Title__c, Badge_Address__c,
                                    Profiles_Title__c, Profiles_Sub_Title__c, Badge_City__c, Badges_Title__c, Badges_Sub_Title__c, Badge_State__c, Insurance_Title__c, 
                                    Insurance_Sub_Title__c, Badge_Country__c, Marketing_Title__c, Marketing_Sub_Title__c, Badge_Nationality__c, E_Commerce_Title__c,
                                    E_Commerce_Sub_Title__c, Badge_Mobile_Number__c, Know_deadlines_Title__c, Know_deadlines_Sub_Title__c, Badge_Email__c, Fill_forms_Title__c,
                                    Fill_forms_Sub_Title__c, Badge_Age_Bracket__c, Read_manuals_Title__c, Read_manuals_Sub_Title__c, Active__c, Forms_Redirect_URL__c,
                                    Manuals_Redirect_URL__c, Profiles_Redirect_URL__c, Badges_Redirect_URL__c, Insurance_Redirect_URL__c, E_Commerce_Redirect_URL__c,
                                    Know_deadlines_Redirect_URL__c, Fill_forms_Redirect_URL__c, Read_manuals_Redirect_URL__c, Marketing_Redirect_URL__c, Booth_Name__c,
                                    Booth_size__c, Amount__c, Remaining_Balance__c, Deadline_Reached_Message__c, UserType__c, Accounts_and_Billing_Title__c,
                                    Accounts_and_Billing_Sub_Title__c, Accounts_and_Billing_Redirect_URL__c, Exhibitor_Directory_Title__c, Exhibitor_Directory_Sub_Title__c,
                                    Exhibitor_Directory_Redirect_URL__c, Welcome_Text_Badges__c, Welcome_Text_Forms__c, OpportunityName__c, Upload_Center_Title__c,
                                    Upload_Center_Sub_Title__c, Upload_Center_Redirect_URL__c, Third_Party_Integrations_Title__c, Third_Party_Integrations_Sub_Title__c, 
                                    Third_Party_Integrations_Redirect_URL__c, Welcome_Text_Manuals__c, Branding_Color__c, ShowHours1__c, ShowHours2__c, About_Show__c,
                                    Link_1__c, Link_2__c, Link_3__c, Link_4__c,Link_1_Label__c, Link_2_Label__c, Link_3_Label__c, Link_4_Label__c,Is_Account_and_Billing_Active__c, Is_Customer_Badges_Active__c,
                                    Is_Customer_Profile_Active__c,Is_E_Commerce_Active__c,Is_Form_Active__c,Is_Freeman_Active__c, Is_Manual_Active__c, Is_Stand_Contractor_Active__c,Is_Upload_Center_Active__c,
                                     Welcome_Text_Exhibitor_Profile__c,Freeman_Redirect_Url__c,Freeman_Sub_Title__c,Freeman_Title__c,
                                    Is_Freeman_Visible__c,Is_Account_and_Billing_Visible__c,Is_Customer_Badges_Visible__c,Is_Customer_Profile_Visible__c,Is_E_Commerce_Visible__c,Is_Form_Visible__c,Is_Manual_Visible__c,
                                    Is_Stand_Contractor_Visible__c,Is_Upload_Center_Visible__c, Facebook__c, Twitter__c, Youtube__c,Linkedin__c, Homepage_Right_Panel_Custom_Content__c,Homepage_Right_Panel_Content_Header__c,
                                    Welcome_Text_Account_Contacts__c,Product_List_Intro_Paragraph__c,Exhibiting_As__c,Stand_Contractor_Title__c,Stand_Contractor_Sub_Title__c,Welcome_Message_Customer_Portal_Homepage__c,AccountBoothContactDescription__c,AccountHealthSafetyContactDescription__c,
                                    AccountInvoiceContactDescription__c,AccountOperationsContactDescription__c,AccountPrimaryContactDescription__c,Agent_Email_Content1__c,Agent_Email_Content2__c,
                                    Agent_Owned_Exhibitor_Email_Content1__c,Agent_Owned_Exhibitor_Email_Content2__c,Agent_Own_Exhibitor_Redirect_URL__c,Agent_Own_Exhibitor_Sub_Title__c,Agent_Own_Exhibitor_Title__c,
                                    Badge_Address_Character_Limit__c,Badge_City_Character_Limit__c,Badge_Deadline__c,Badge_Email_Character_Limit__c,Badge_FName_Character_Limit__c,Badge_FName_To_UpperCase__c,Badge_JobTitle_Character_Limit__c,Badge_LName_Character_Limit__c,Badge_LName_To_UpperCase__c,Badge_Mobile_Character_Limit__c,Button_colors__c,Button_Text_Color__c,Classification__c,Contractor_Email_Content1__c,Contractor_Email_Content2__c,Contractor_MyExhibitor_Detail_Tab_1__c,Contractor_MyExhibitor_Detail_Tab_2__c,
                                    Contractor_MyExhibitor_Detail_Tab_3__c,Contractor_MyExhibitor_Detail_Tab_4__c,Cont_MyExhibitor_Detail_Tab_1_Title_Intr__c,Cont_MyExhibitor_Detail_Tab_1_Title__c,Cont_MyExhibitor_Detail_Tab_2_Title_Intr__c,
                                    Cont_MyExhibitor_Detail_Tab_2_Title__c,Cont_MyExhibitor_Detail_Tab_3_Title__c,Cont_MyExhibitor_Detail_Tab_4_Title_Intr__c,Cont_MyExhibitor_Detail_Tab_4_Title__c,Cont_MyExh_Detail_Tab_3_Design_Label_1__c,
                                    Cont_MyExh_Detail_Tab_3_Design_Label_2__c,Cont_MyExh_Detail_Tab_3_Design_Label_3__c,Cont_MyExh_Detail_Tab_3_Design_Text_1__c,Cont_MyExh_Detail_Tab_3_Design_Text_2__c,Cont_MyExh_Detail_Tab_3_Design_Text_3__c,
                                    Co_Exhibitor_Email_Content1__c,Co_Exhibitor_Email_Content2__c,custom_1_Left_panel__c,Custom_1_Redirect_URL__c,custom_1_Right_panel__c,Custom_1_Sub_Title__c,Custom_1_Title__c,Deadline_Reached_Message_for_Forms__c,
                                    Deadline_Reached_Message_for_Manuals__c,Disable_Shopping_Cart__c,Disable_this_information__c,Event_Summary_Visibility__c,Exhibitor_Email_Content1__c,Exhibitor_Email_Content2__c,Footer_background_color__c,Footer_text_color__c,
                                    Is_Agent_Own_Exhibitor_Active__c,Is_Agent_Own_Exhibitor_Visible__c,Is_Amount_Visible__c,Is_Booth_Contact_Visible__c,Is_Cont_MyExh_Tab_4_Signature_Visible__c,
                                    Is_Cont_MyEx_Detail_Tab_3_Status_Visible__c,Is_Cont_MyEx_Detail_Tab_4_Agree_Visible__c,Is_Custom_1_Active__c,Is_Custom_1_Visible__c,Is_Disable_E_Commerce__c,Is_Health_And_Safety_Contact_Visible__c,Is_Invoice_Contact_Visible__c,Is_My_Exhibitor_Active__c,Is_My_Exhibitor_Visible__c,
                                    Is_Operations_Contact_Visible__c,Is_Pop_Up_Greeting__c,Is_Primary_Contact_Visibile__c,Is_Stand_Design_Visible__c,Is_Stand_Detail_Visible__c,Is_SubContractors_Active__c,Is_SubContractors_Visible__c,
                                    Main_Nav_Background_Color__c,Main_Nav_Text_Color__c,My_Exhibitor_Redirect_URL__c,My_Exhibitor_Sub_Title__c,My_Exhibitor_Title__c,On_Off_Form_Status__c,
                                    Open_Sides__c,Organization_Id_Ops_Admin__c,Pop_Up_Greeting_Header__c,Pop_Up_Greeting__c,Show_Hide_Manual_Agreed__c,Stand_Contractor_Content1__c,Stand_Contractor_Content2__c,
                                    Stand_Contractor_Redirect_URL__c,Subcontractor_Redirect_Url__c,Subcontractor_Sub_Title__c,Subcontractor_Title__c,Utility_Navigation_text_Color__c,Welcome_Email_Banner__c,
                                    Welcome_Stand_Contractor__c,Welcome_Sub_Contractor__c,Welcome_Text_Agent_Own_Exhibitors__c,Welcome_Text_Contractor_Service__c,Welcome_Text_My_Exhibitor_Booth_Details__c,Welcome_Text_My_Exhibitor_Portal__c,Welcome_Text_SubContractor_Service__c FROM Event_Settings__c where Event_Edition__c IN : mapNewAndLastEditionId.KeySet()];
                if(eventSettinglLst!=null && eventSettinglLst.size()>0)
                {
                    for(Event_Settings__c eventSetting : eventSettinglLst)
                    {
                        string newEditionId = mapNewAndLastEditionId.get(eventSetting.Event_Edition__c);                        
                        Event_Settings__c neweventSetting = eventSetting.clone(false, true, false, false);
                        neweventSetting.Event_Edition__c = newEditionId;
                        eventsettingLstToInsert.add(neweventSetting);                    
                    }
                    system.debug('eventsettingLstToInsert='+eventsettingLstToInsert);
                }
                
                // CCEN-366
                // Insert Event Settings for Event Edition(s) which are very first in event series
                if(firstNewEEIDs!=null && !firstNewEEIDs.IsEmpty())
                {
                    for(string newEditionId : firstNewEEIDs)
                    {
                        string eventEditionName = ''; 
                        if(!mapEventEditon.isEmpty() && mapEventEditon.size()>0 && mapEventEditon.containsKey(newEditionId)){
                            eventEditionName=mapEventEditon.get(newEditionId).Name+ '';//mapNewEditionIdName.get(newEditionId)+ ' Setting';  
                        }
                        if(eventEditionName.length()>70)
                            eventEditionName = eventEditionName.substring(0, 69);
                        
                        Event_Settings__c neweventSetting=new Event_Settings__c();
                        neweventSetting.Name= eventEditionName+'_Setting';
                        neweventSetting.Event_Edition__c = newEditionId;
                        eventsettingLstToInsert.add(neweventSetting);                    
                    } 
                }
                if(eventsettingLstToInsert.size()>0 && eventsettingLstToInsert!=null)
                {
                    insert eventsettingLstToInsert;                 
                }
                
                system.debug('At ComponentUserTypeMapping');
                // insert User Type and Component(E.g. Forms, Manauls, Badges, Product Catalogue, Accounts & Billing, Exhibitor Profile, Upload Center, Freeman Show)                
                List<ComponentUserTypeMapping__c> componentUserTypeMappingToInsert = new List<ComponentUserTypeMapping__c>();
                List<ComponentUserTypeMapping__c> componentUserTypeMappingLst = new List<ComponentUserTypeMapping__c>();
                componentUserTypeMappingLst=[Select Id,Name,Accounts_and_Billing_Show__c,Badges_Show__c,Event_Edition__c,E_Commerce_Show__c,Exhibitor_Directory_Show__c,
                                            FormQuickView__c,Form_Show__c,Freeman_Show__c,Insurance_Show__c,Know_deadlines_Show__c,ManualQuickView__c,Manual_Show__c,
                                            Marketing_Show__c,Profile_Show__c,Standard_Contractor_Show__c,Third_Party_Integrations_Show__c,Upload_Center_Show__c,
                                            User_Type__c,User_Type__r.Name,Agent_Own_Exhibitor_Show__c,Custom_1_Show__c,My_Exhibitor_Show__c,Pop_Up_Greeting_Show__c,SubContractor_Show__c
                                            From ComponentUserTypeMapping__c
                                            where Event_Edition__c IN : mapNewAndLastEditionId.KeySet()];
                if(componentUserTypeMappingLst!=null && componentUserTypeMappingLst.size()>0)
                {
                    for(ComponentUserTypeMapping__c componentUserTypeMapping : componentUserTypeMappingLst)
                    { 
                        string newEditionId = mapNewAndLastEditionId.get(ComponentUserTypeMapping.Event_Edition__c);                                             
                        System.debug('newEditionId' + newEditionId);
                        string newEditionName= string.valueOf(mapEventEditon.get(newEditionId).Name); //mapNewEditionIdName.get(newEditionId);
                        System.debug('NewEditionName' + NewEditionName);
                        if(NewEditionName.length()>50)
                            NewEditionName = NewEditionName.substring(0, 49);
                        
                        ComponentUserTypeMapping__c newComponentUserTypeMapping = ComponentUserTypeMapping.clone(false, true, false, false);
                        newComponentUserTypeMapping.Event_Edition__c = newEditionId;
                        newComponentUserTypeMapping.Name=ComponentUserTypeMapping.User_Type__r.Name+'_Permission_'+NewEditionName;
                        ComponentUserTypeMappingToInsert.add(newComponentUserTypeMapping);                    
                    }
                    system.debug('ComponentUserTypeMappingToInsert='+ComponentUserTypeMappingToInsert.size());
                    if(ComponentUserTypeMappingToInsert.size()>0 && ComponentUserTypeMappingToInsert!=null)
                    {
                        insert ComponentUserTypeMappingToInsert;                 
                    }
                }
            }
        } */
    } 
    // Method CloneEventEditionCS End
    
}