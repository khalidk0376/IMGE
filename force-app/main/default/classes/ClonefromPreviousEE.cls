/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          04/09/2020      
 * Description/Purpose: This Class is used for clone the cc objects
 * Test Class:          ClonefromPreviousEE_Test
 * Code Coverage:       92%
 * Last Modified By :   [Aishwarya 9 Sep 2020 BK-5284] //Added Code By Rajesh Kumar :: BK-11012 on 10-12-2020 
**/

public class ClonefromPreviousEE{
    public string sErrorMsg { get; set; }
    public string sAlreadyCloneMsg { get; set; }
    public string sAlreadyEveSettingMsg { get; set; }
    public string firstClone { get; set; }
    public string secondClone { get; set; }
    public string firstCloneMsg { get; set; }
    private String sEventEditionId = '';
    public string sErrorCatch ='';
    public Event_Edition__c  oEventEdition;
    public List<ContentVersion > insertFiles = new List<ContentVersion >();
    public List < ContentDocumentLink > lstContentDocumentLink  = new List <ContentDocumentLink> ();
    public List < ContentDocumentLink > lstInsertContentDocumentLink  = new List <ContentDocumentLink> (); 
    transient List <ContentVersion> lstcontentversion = new List <ContentVersion> ();
    public set <id> setids = new set<id>();
    public ClonefromPreviousEE(ApexPages.StandardController controller) {
        sEventEditionId = apexpages.currentpage().getparameters().get('id');
        oEventEdition = new Event_Edition__c();
        sErrorMsg ='';
        sAlreadyCloneMsg ='';
        sAlreadyEveSettingMsg ='';
        firstClone ='';
        secondClone ='';
        firstCloneMsg ='';
        if(!String.isBlank(sEventEditionId)){
            oEventEdition = [Select Id, Name, Previous_Event_Edition__c FROM Event_Edition__c where Id =:sEventEditionId LIMIT 1];
        }
    }
    
    public void cloneData(){
        List<Event_Settings__c> eveSetting = new List<Event_Settings__c>();
        eveSetting = [Select Id, isAlreadyCloned__c, createdBy.Name, Event_Cloned_Date__c, EventClonedByUser__c FROM Event_Settings__c where Event_Edition__c =:sEventEditionId LIMIT 1];
        if(oEventEdition != null && oEventEdition.Previous_Event_Edition__c == null) {
            sErrorMsg = 'Error! Cannot proceed with cloning Customer Center data for '+oEventEdition.Name;            sErrorMsg += '. Please enter a value for the "Previous Event Edition" field and try again.';             return;
        }
        else if(!eveSetting.isEmpty() && eveSetting.size()>0 && eveSetting[0].isAlreadyCloned__c == false){
            sAlreadyEveSettingMsg = System.Label.ClonefromPreviousEE;            return;
        }
        else if(!eveSetting.isEmpty() && eveSetting.size()>0 && eveSetting[0].isAlreadyCloned__c == true){
            String clonedDate ='';
            if(eveSetting[0].Event_Cloned_Date__c != null){
                clonedDate = string.valueof(eveSetting[0].Event_Cloned_Date__c).left(11);
            }
            sAlreadyCloneMsg = 'WARNING : \n The data for '+oEventEdition.Name+' has already been cloned on '+clonedDate+' by '+eveSetting[0].EventClonedByUser__c+'.';
            sAlreadyCloneMsg += ' If you proceed with cloning a second time, all changes made to the '+oEventEdition.Name+' Customer Center data will be overwritten.';
            sAlreadyCloneMsg += '\n\n Do you wish to proceed and overwrite changes?';
        }
        else{
            //cloneDataFirstTime();
            firstClone = 'Are you sure you wish to clone the Customer Center data for '+oEventEdition.Name+'?';
        }
    } 
   
    public pageReference cloneOverwrite(){
        // delete existing data if cloning 2nd time i.e t. totally erase existing data
        List<Event_Settings__c> eveSetting = new List<Event_Settings__c>();
        eveSetting = [Select Id, Name FROM Event_Settings__c where Event_Edition__c =:oEventEdition.Id LIMIT 1];
        
        list<Event_Edition_Form__c> eventEdtFormLst = new list<Event_Edition_Form__c>();                
        eventEdtFormLst = [select id, Event_Edition__c FROM Event_Edition_Form__c where Event_Edition__c =:oEventEdition.Id];
        
        list<Manual__c> manualLst = new list<Manual__c>();
        ManualLst = [select Id, Event_Edition__c FROM Manual__c where Event_Edition__c =:oEventEdition.Id];
        
        list<Event_Edition_Email_Template__c> eventEmaillLst = new list<Event_Edition_Email_Template__c>();
        eventEmaillLst = [select Id FROM Event_Edition_Email_Template__c where Event_Edition__c =:oEventEdition.Id];
        
        list<Booth_Size_Badge_Limit__c> boothSizeLst = new list<Booth_Size_Badge_Limit__c>();
        boothSizeLst = [SELECT Id, Name FROM Booth_Size_Badge_Limit__c WHERE Event_Edition__c =:oEventEdition.Id AND Booth_Type__c = null];
        
        List<ComponentUserTypeMapping__c> componentUserTypeMappingLst = new List<ComponentUserTypeMapping__c>();
        componentUserTypeMappingLst = [Select Id, Name FROM ComponentUserTypeMapping__c where Event_Edition__c =:oEventEdition.Id];
        
        try{
            if(eventEdtFormLst.size()>0)
                delete eventEdtFormLst;
            if(ManualLst.size()>0)
                delete ManualLst;
            if(eventEmaillLst.size()>0)
                delete eventEmaillLst;
            if(boothSizeLst.size()>0)
                delete boothSizeLst;
            if(componentUserTypeMappingLst.size()>0)
                delete componentUserTypeMappingLst;
            if(eveSetting.size()>0)
                delete eveSetting;
            if(eveSetting.size()>0){
                cloneDataFirstTime();
                secondClone = 'clone 2ndtime.';
                firstCloneMsg ='';
            }
        }
        catch(exception ex){
            system.debug('some error'+ex.getMessage());
        }
        return null;
    }
    
    public pageReference cloneDataFirstTime(){
        List<Event_Edition_Form__c> formLstToInsert = new List<Event_Edition_Form__c>();
        List<Manual__c> manualLstToInsert = new List<Manual__c>();
        List<Event_Edition_Email_Template__c> eventEmailLstToInsert = new List<Event_Edition_Email_Template__c>();
        List<Event_Settings__c> eventsettingLstToInsert = new List<Event_Settings__c >();
        List<Booth_Size_Badge_Limit__c> boothSizeLstToInsert = new List<Booth_Size_Badge_Limit__c>();
        //List<attachment> manualAttLstToInsert = new List<attachment>();
        
        // insert Event Edition Form records
        list<Event_Edition_Form__c> eventEdtFormLst = new list<Event_Edition_Form__c>();                
        eventEdtFormLst = [select id, Allow_Submit_After_Deadline__c, Event_Edition__c, Deadline__c,Exclusive__c, Forms__c, Form_Group__c, Form_Type__c,
                                   Mandatory__c, Provider__c, User_Type__c FROM Event_Edition_Form__c where Event_Edition__c =: oEventEdition.Previous_Event_Edition__c];
        if(eventEdtFormLst!=null && eventEdtFormLst.size()>0)
        {
            for(Event_Edition_Form__c editionForm : eventEdtFormLst)
            {
                Event_Edition_Form__c evtEditionFrm = editionForm.clone(false, true, false, false);
                evtEditionFrm.Event_Edition__c = oEventEdition.Id;
                formLstToInsert.add(evtEditionFrm);
            }
            try{
                if(formLstToInsert.size()>0 && formLstToInsert!=null)
                {
                    Database.insert(formLstToInsert);                 
                }
            }
            catch(exception ex){
               sErrorCatch = ex.getMessage();
            }
        }
                
        // Insert Manuals
        list<Manual__c> manualLst = new list<Manual__c>();
        Set<string> attLst = new set<string>();
        Set<string> setParentIds = new set<string>();
        map<string,Id> attAndNewManualIdMap = new map<string,Id>();
        Set<Id> setManualIds = new set<Id>();
        ManualLst = [select id,name,Event_Edition__c,Manual_Description__c,Required__c,Section__c,Uploaded_Attachment_Id__c,Uploaded_Attachment_Name__c,User_Type__c, (Select LinkedEntityId, ContentDocumentId from ContentDocumentLinks) from Manual__c where Event_Edition__c =: oEventEdition.Previous_Event_Edition__c];
        if(ManualLst!=null && ManualLst.size()>0)
        {
            for(Manual__c manual : manualLst)
            {
                Manual__c newManual = Manual.clone(false, true, false, false);
                newManual.Event_Edition__c = oEventEdition.Id;
                manualLstToInsert.add(newManual);
                if (manual.ContentDocumentLinks.size() > 0 ){
                    attLst.add(manual.Uploaded_Attachment_Id__c);
                    setParentIds.add(manual.Id);
                }
            }
            if(manualLstToInsert.size()>0 && manualLstToInsert!=null)
            {
                insert manualLstToInsert;
                //Added Code By Rajesh Kumar :: BK-11012 on 10-12-2020 
                for(Manual__c manual :manualLstToInsert){
                    setManualIds.add(manual.Id);
                }
                for ( Manual__c manuals : [Select Id, Name, Uploaded_Attachment_Id__c FROM Manual__c where Uploaded_Attachment_Id__c IN : attLst AND Id IN : setManualIds AND Manual_Type__c = 'Downloadable PDF']){
                    attAndNewManualIdMap.put(manuals.Uploaded_Attachment_Id__c,manuals.Id);
                }
                lstContentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, ShareType FROM ContentDocumentLink  WHERE ContentDocumentId IN : attLst AND LinkedEntityId IN : setParentIds]; 
                if (!lstContentDocumentLink.isEmpty()){
                    for(ContentDocumentLink objContentDocumentLink : lstContentDocumentLink){
                        setids.add(objContentDocumentLink.ContentDocumentId);
                    }       
                    lstcontentversion = [SELECT Id, Title, PathOnClient, VersionData, OwnerId, ContentDocumentId FROM ContentVersion where ContentDocumentId IN: setids];
                    if (!lstcontentversion.isEmpty()){
                        for (ContentVersion ocontentver : lstcontentversion ){
                            if (String.IsNotBlank(attAndNewManualIdMap.get(ocontentver.ContentDocumentId))){
                                ContentDocumentLink cDocLink = new ContentDocumentLink();
                                cDocLink.ContentDocumentId = ocontentver.ContentDocumentId;//Add ContentDocumentId
                                cDocLink.LinkedEntityId = attAndNewManualIdMap.get(ocontentver.ContentDocumentId);//Add attachment parentId
                                cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                                cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                                lstInsertContentDocumentLink.add(cDocLink);
                            }
                        }
                        if (!lstInsertContentDocumentLink.isEmpty()){
                            insert lstInsertContentDocumentLink;
                        }
                    }
                }
                //Added Code By Rajesh Kumar :: BK-11012 on 10-12-2020 
            }
        }
        // Insert Email - Template
        list<Event_Edition_Email_Template__c> eventEmaillLst = new list<Event_Edition_Email_Template__c>();
        eventEmaillLst = [select id,name,Content__c,Email_Template__c,Email_Template_Code__c,Event_Edition__c,Subject__c from Event_Edition_Email_Template__c where Event_Edition__c =: oEventEdition.Previous_Event_Edition__c];
        if(eventEmaillLst!=null && eventEmaillLst.size()>0)
        {
            for(Event_Edition_Email_Template__c eventEmail : eventEmaillLst)
            {                  
                Event_Edition_Email_Template__c neweventEmail = eventEmail.clone(false, true, false, false);
                neweventEmail.Event_Edition__c = oEventEdition.Id;
                eventEmailLstToInsert.add(neweventEmail);  
            }
        }
        
        // CCEN-344
        // Insert Email - Template from global email templates, for Event Edition(s) which are very first in event series
        list<Email_Templates__c> globalEmaillLst = new list<Email_Templates__c>();
        globalEmaillLst = [select Id, Name, Content__c, Template_Code__c, Subject__c from Email_Templates__c];
        if(oEventEdition.Id != null)
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
                    neweventEmail.Event_Edition__c = oEventEdition.Id;
                    eventEmailLstToInsert.add(neweventEmail);               
                }
            }
        }
        
        if(eventEmailLstToInsert.size()>0 && eventEmailLstToInsert!=null)
        {
           insert eventEmailLstToInsert;                   
        }
                
        // insert Booth Size Badge Limit
        list<Booth_Size_Badge_Limit__c> boothSizeLst = new list<Booth_Size_Badge_Limit__c>();
        boothSizeLst = [SELECT id,  Name ,Event_Edition__c,Booth_Size_To__c,Booth_Size_From__c,Badges_Allowed__c from Booth_Size_Badge_Limit__c WHERE Event_Edition__c =: oEventEdition.Previous_Event_Edition__c And Booth_Type__c = null];
       
        if(boothSizeLst!=null && boothSizeLst.size()>0)
        {
            for(Booth_Size_Badge_Limit__c boothSize:boothSizeLst)
            {
                Booth_Size_Badge_Limit__c newBoothSize = boothSize.clone(false, true, false, false);
                newBoothSize.Event_Edition__c = oEventEdition.Id;
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
                            Welcome_Stand_Contractor__c,Welcome_Sub_Contractor__c,Welcome_Text_Agent_Own_Exhibitors__c,Welcome_Text_Contractor_Service__c,Welcome_Text_My_Exhibitor_Booth_Details__c,Welcome_Text_My_Exhibitor_Portal__c,Welcome_Text_SubContractor_Service__c FROM Event_Settings__c where Event_Edition__c =: oEventEdition.Previous_Event_Edition__c];
        if(eventSettinglLst!=null && eventSettinglLst.size()>0)
        {
            for(Event_Settings__c eventSetting : eventSettinglLst)
            {                   
                string eventEditionName ='';
                string eventEditionNameNew ='';
                eventEditionName = oEventEdition.Name;
                if(eventEditionName.length()>70){
                    eventEditionNameNew = eventEditionName.substring(0, 69);
                }
                else{
                    eventEditionNameNew = eventEditionName;
                }
                Event_Settings__c neweventSetting = eventSetting.clone(false, true, false, false);
                neweventSetting.Event_Edition__c = oEventEdition.Id;
                neweventSetting.Name = eventEditionNameNew + '_Setting';
                neweventSetting.isAlreadyCloned__c = true;
                neweventSetting.Event_Cloned_Date__c = Datetime.Now();
                neweventSetting.EventClonedByUser__c = UserInfo.getName();
                eventsettingLstToInsert.add(neweventSetting);                    
            }
        }
        if(eventsettingLstToInsert !=null && eventsettingLstToInsert.size()>0)
            insert eventsettingLstToInsert;
        // insert User Type and Component(E.g. Forms, Manauls, Badges, Product Catalogue, Accounts & Billing, Exhibitor Profile, Upload Center, Freeman Show)                
        List<ComponentUserTypeMapping__c> componentUserTypeMappingToInsert = new List<ComponentUserTypeMapping__c>();
        List<ComponentUserTypeMapping__c> componentUserTypeMappingLst = new List<ComponentUserTypeMapping__c>();
        componentUserTypeMappingLst=[Select Id,Name,Accounts_and_Billing_Show__c,Badges_Show__c,Event_Edition__c,E_Commerce_Show__c,Exhibitor_Directory_Show__c,
                                    FormQuickView__c,Form_Show__c,Freeman_Show__c,Insurance_Show__c,Know_deadlines_Show__c,ManualQuickView__c,Manual_Show__c,
                                    Marketing_Show__c,Profile_Show__c,Standard_Contractor_Show__c,Third_Party_Integrations_Show__c,Upload_Center_Show__c,
                                    User_Type__c,User_Type__r.Name,Agent_Own_Exhibitor_Show__c,Custom_1_Show__c,My_Exhibitor_Show__c,Pop_Up_Greeting_Show__c,SubContractor_Show__c
                                    From ComponentUserTypeMapping__c
                                    where Event_Edition__c =: oEventEdition.Previous_Event_Edition__c];
        if(componentUserTypeMappingLst!=null && componentUserTypeMappingLst.size()>0)
        {
            for(ComponentUserTypeMapping__c componentUserTypeMapping : componentUserTypeMappingLst)
            { 
                string newEditionName= oEventEdition.Name;
                if(NewEditionName.length()>50)
                    NewEditionName = NewEditionName.substring(0, 49);
                
                ComponentUserTypeMapping__c newComponentUserTypeMapping = ComponentUserTypeMapping.clone(false, true, false, false);
                newComponentUserTypeMapping.Event_Edition__c = oEventEdition.Id;
                newComponentUserTypeMapping.Name=ComponentUserTypeMapping.User_Type__r.Name+'_Permission_'+NewEditionName;
                ComponentUserTypeMappingToInsert.add(newComponentUserTypeMapping);                    
            }
            if(ComponentUserTypeMappingToInsert.size()>0 && ComponentUserTypeMappingToInsert!=null)
            {
                insert ComponentUserTypeMappingToInsert;                 
            }
        }
        firstCloneMsg ='clone successful';
        return null;
    }
        
    public PageReference returnToPT(){
        pageReference pg = new pageReference('/' + sEventEditionId);
        pg.setRedirect(true);
        return pg;
    }
}