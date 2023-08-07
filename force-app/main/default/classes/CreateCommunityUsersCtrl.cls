/**
 * Created By: Girikon(Sunil)
 * Created On: 02/19/2018
 * Modified by :  
 * Modified On: 
 * Description/Purpose: This class creates Contact-EventEdition mapping for contacts input by user and send welcome email.
                        Also if user is already existing then only welcome email is sent out. Else creates community user (welcome email sent out automatically from community).
                        Update contact type.
                        Create "UserFormAction" and "UserManualAction" records. 
     * Test Class:  CreateCommunityUsersCtrl_Test,CreateCommunityStandControllerUser
**/
public without sharing class CreateCommunityUsersCtrl 
{
    //input contact id's
    public string contIds{get;set;}
    //input contact id's for existing mapping 
    public string contIdsNewUser{get;set;}
    //input contact id's for existing mapping and users
    public string contIdsExistingUser{get;set;}
    //input event id's
    public string eventId{get;set;}
    //Active users list
    public List<User> ActiveUserList {get;set;}
    //Inactive users list
    public List<User> InActiveUserList {get;set;}
    //Contact list for which user created
    public List<Contact> CreateUserList {get;set;}
    //input event id's
    public string eventIdExsMap{get;set;}
    //Active users list
    public List<User> ActiveUserListNewUser {get;set;}
    //Inactive users list
    public List<User> InActiveUserListNewUser {get;set;}
    //Contact list for which user created
    public List<Contact> CreateUserListNewUser {get;set;}
    
    //input contact id's
    public string contIdsActions{get;set;}
    //input event id's
    public string eventIdActions{get;set;}
    //input event id's
    public string eventIdExsUsr{get;set;}
    
    public CreateCommunityUsersCtrl() 
    {
        ActiveUserList=new List<User> ();
        InActiveUserList=new List<User> ();
        CreateUserList=new List<Contact> ();
        ActiveUserListNewUser=new List<User> ();
        CreateUserListNewUser=new List<Contact> ();
        InActiveUserListNewUser=new List<User> ();
    }
    
    //send email to existing users
    public void SendEmailtoExistingUsers()  
    {
        ActiveUserList=new List<User> ();
        InActiveUserList=new List<User> ();
        CreateUserList=new List<Contact> ();
        set<id> conids=new set<id>();
        for (string cid : contIdsExistingUser.split(',')) 
        {
            if(validateId(cid.trim()))conids.add(cid.trim());
        }
        System.Debug('conids= '+conids);
        if(contIdsExistingUser=='' || conids.isEmpty())
        { 
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter valid contact id.'));
        }
        else
        {         
            System.Debug('conids after remove= '+conids);
            System.Debug('eventIdExsUsr= '+eventIdExsUsr);
            //Get existing user of contact with community profile 
            List<User> users=[Select Id,Email,username,firstname,Contact.Type__c,ContactId,Contact.account.name,Contact.name,Contact.email,IsActive,IsPortalEnabled from User where ContactId IN: conids and IsPortalEnabled=true And Profile.Name=:UtilityMethods.getProfileid().name];            
            System.Debug('users= '+users);
            
            EmailTemplate templateId = [Select id from EmailTemplate where DeveloperName = 'Exhibitor_Welcome_Email_Existing_User'];
            for(User usr: users) 
            {
                if(!usr.IsActive)
                {
                    usr.IsActive=true; //Set inactive user as active
                    InActiveUserList.Add(usr);
                    conids.Remove(usr.ContactId);
                }
            }
            
            try
            {
                //Activate existing inactive users
                if(!InActiveUserList.isEmpty())
                    update InActiveUserList;     
                    
                set<Id> setEventId = new  set<Id>();
                setEventId.add(eventIdExsUsr);
                UtilityMethods.sendEmailToExistingUser(conids,setEventId);
                UtilityMethods.updateContactsSentEmail(conids);
                 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.confirm,'Email sent.'));  
            }            
            catch(Exception e)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'SendEmailtoExistingUsers function Exception Message: '+e.getMessage()+'**Line Number='+e.getLineNumber()));
            }
        }        
    }
    
    //Get contact id's from vf page & create user for existing mapping
    public void createUsersforExistingMapping()
    {
        ActiveUserListNewUser=new List<User> ();
        InActiveUserListNewUser=new List<User> ();
        CreateUserListNewUser=new List<Contact> ();
        set<id> AllContids=new set<id>();
        set<id> conids=new set<id>();
        for (string cid : contIdsNewUser.split(',')) {
            if(validateId(cid.trim()))conids.add(cid.trim());
        }
        if(contIdsNewUser=='' || conids.isEmpty()){ 
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter valid contact id.'));  
        }
        else
        {   
            
            AllContids=conids.clone(); 
            Set<Id> lstConEEIds = new Set<Id>();
            for(ContactEventEditionMapping__c objCS : [select id,SFContactID__c,SFEventEditionID__c from ContactEventEditionMapping__c where SFContactID__c IN :conids and SFEventEditionID__c =: eventIdExsMap and IsEmailSent__c=true])
            {
                conids.Remove(objCS.SFContactID__c);
            }
            List<User> users=[Select Id,Contact.Type__c,ContactId,Contact.name,Contact.email,IsActive,IsPortalEnabled from User where ContactId IN: conids and IsPortalEnabled=true And Profile.Name=:UtilityMethods.getProfileid().name];
            for(User usr: users) 
            {
                //Remove those contacts which are already having community users 
                conids.Remove(usr.ContactId);
                ActiveUserListNewUser.add(usr);
                if(!usr.IsActive)
                {
                    usr.IsActive=true; //Set inactive user as active
                    InActiveUserListNewUser.Add(usr);
                }
            }
            //Activate existing inactive users
            if(!InActiveUserListNewUser.isEmpty()) 
                update InActiveUserListNewUser;    
            
            // For updated Welcome Email we used ContactEventEditionMapping__c instead of contactIds [CCEN-585]
            for(ContactEventEditionMapping__c objCS : [select id,SFContactID__c,SFEventEditionID__c from ContactEventEditionMapping__c where SFContactID__c IN :conids and SFEventEditionID__c =: eventIdExsMap])
            {
                lstConEEIds.add(objCS.id); if(objCS.IsEmailSent__c=true) { conids.Remove(objCS.SFContactID__c);lstConEEIds.Remove(objCS.id);}
         
            }
            CreateUserListNewUser = [Select Id,Email,name,FirstName,LastName,Account.Name from Contact where id IN: conids ];
            
            // For updated Welcome Email we used ContactEventEditionMapping__c instead of contactIds [CCEN-585]
            BatchCreateCommunityUsers objbatch= new BatchCreateCommunityUsers(lstConEEIds,UtilityMethods.getProfileid().Id);
            Database.executeBatch(objbatch,1); 
        } 
    }
    
    //Get contact id's from vf page and create new community users
    public void createUsers()
    {
        ActiveUserList=new List<User> ();
        InActiveUserList=new List<User> ();
        CreateUserList=new List<Contact> ();
        set<id> conids=new set<id>();
        for (string cid : contIds.split(',')) {
            if(validateId(cid.trim()))conids.add(cid.trim());
        }
        
        if(contIds=='' || conids.isEmpty()){ 
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter valid contact id.'));  
        }
        else if(eventId=='' || !validateId(eventId)){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter event id.'));  
        }
        else
        {      
            CreateCommunityUser(conids);
        } 
    }
    
    //Activate existing community user & create contacteventeditionmapping and then create new users
    public void CreateCommunityUser(set<id> contIDs)  
    {       
        //Get existing user of contact with community profile 
        List<User> users=[Select Id,Contact.Type__c,ContactId,Contact.name,Contact.email,IsActive,IsPortalEnabled from User where ContactId IN: contIDs and IsPortalEnabled=true And Profile.Name=:UtilityMethods.getProfileid().name];
        system.debug('users'+users);
        for(User usr: users) 
        {
            //Remove those contacts which are already having community users 
            contIDs.Remove(usr.ContactId);if(!usr.IsActive)
            {
                usr.IsActive=true; //Set inactive user as active
                InActiveUserList.Add(usr);
            }
            else{
                ActiveUserList.add(usr);
            }
        }
        //Activate existing inactive users
        if(!InActiveUserList.isEmpty())
            update InActiveUserList; 
        
       for(ContactEventEditionMapping__c objCS : [select id,SFContactID__c,SFEventEditionID__c from ContactEventEditionMapping__c where SFContactID__c IN :contIDs and SFEventEditionID__c =: eventId])
        {
             contIDs.Remove(objCS.SFContactID__c);
        }
        //method to create contact and event edition mapping
        createEventMapping(contIDs);
    }
    //Create mapping with event edition(if not already existing) for contact
    private void createEventMapping(set<id> contIds)
    {
        System.Debug('contIds1111 : '+contIds);
        //Check Event Edition is live or not
        Event_Edition__c SingleEventEdition = [SELECT Id, Is_Offline__c FROM Event_Edition__c WHERE Id= :eventId];
        List<ContactEventEditionMapping__c> listConEveEdtMapping=new List<ContactEventEditionMapping__c>();    
        for(Id con: contIds)
        {
            ContactEventEditionMapping__c newConEveEdtMap = new ContactEventEditionMapping__c();
            newConEveEdtMap.SFContactID__c=con;
            newConEveEdtMap.SFEventEditionID__c=eventId;
            if(SingleEventEdition.Is_Offline__c == false){
                newConEveEdtMap.IsEmailSent__c=false;
            }
            else {
              newConEveEdtMap.IsEmailSent__c=true   ;
            }
            listConEveEdtMapping.add(newConEveEdtMap);
        } 
        System.Debug('listConEveEdtMapping : '+listConEveEdtMapping);
        if(!listConEveEdtMapping.isEmpty())
        {
            try
            {
                //Create contact and event mapping
                insert listConEveEdtMapping;
                // For updated Welcome Email we used ContactEventEditionMapping__c instead of contactIds [CCEN-585]
                Set<Id> lstConEEIds = new Set<Id>();
                for(ContactEventEditionMapping__c conEE : listConEveEdtMapping)
                {
                    lstConEEIds.add(conEE.id);
                }
                //Batch class to create community user for remaining contacts
                system.debug(UtilityMethods.getProfileid().Id);
                if(listConEveEdtMapping[0].IsEmailSent__c==true){
                    BatchCreateCommunityUsers objbatch= new BatchCreateCommunityUsers(lstConEEIds,UtilityMethods.getProfileid().Id);
                    Database.executeBatch(objbatch,2);
                }
                //Create community user for remaining contacts in contactEEM
                CreateUserList = [Select Id,Email,name,FirstName,LastName,Account.Name from Contact where id IN: contIds ];
            }
            catch(Exception e)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Contact Event Mapping Exception Message: '+e.getMessage()+'**Line Number='+e.getLineNumber())); 
              
            }    
        }
    }
      //Create "UserFormAction" and "UserManualAction" records
      public void CreateUserActions() 
      { 
        set<id> conids=new set<id>();
        for (string cid : contIdsActions.split(',')) {
            if(validateId(cid.trim()))conids.add(cid.trim());
        }
        if(contIdsActions=='' || conids.isEmpty()){ 
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter valid contact id.'));  
        }
        else if(eventIdActions=='' || !validateId(eventIdActions)){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter event id.'));  
        }
        else{ 
            set<id> eventEdition=new set<id>();
            eventEdition.add(eventIdActions);
            Map<String,List<String>> mapUserTypeContact=new Map<String,List<String>>();
            List<User_Form_Action__c> userFormActList = new List<User_Form_Action__c>();
            List<User_Manual_Action__c> userManualActList = new List<User_Manual_Action__c>();
            
            List<User_Form_Action__c> formActionLst = [Select id,name,User_Form_Contact__c from User_Form_Action__c where User_Form_Contact__c IN: conids];
            if(formActionLst!=null && formActionLst.size()>0)
            {
                for(User_Form_Action__c objFormAction :formActionLst) { conids.Remove(objFormAction.User_Form_Contact__c);
                }
                
            }
            //Get users of contact(s)
            List<User> users=[Select Id,Contact.Type__c,ContactId from User where ContactId IN: conids];
            //Iterate user list
            for(User usr: users)
            {
                //Create map of contact type & contacts
                List<String> conts=new List<String>();
                if(mapUserTypeContact.ContainsKey(usr.Contact.Type__c))
                {
                    conts=mapUserTypeContact.get(usr.Contact.Type__c);
                }
                conts.Add(usr.Id+'#'+usr.ContactId);
                mapUserTypeContact.put(usr.Contact.Type__c,conts);
            }
            //Add records of User Form Action in a list as per the user
            List<Forms_Permission__c> formPermList = [Select Id,Event_Edition_Form__c,User_Type__c from Forms_Permission__c where Event_Edition_Form__r.Event_Edition__c in: eventEdition AND User_Type__c IN:mapUserTypeContact.KeySet()];
            for(Forms_Permission__c fp: formPermList){
                List<String> fpConts=new List<String>();
                fpConts =mapUserTypeContact.get(fp.User_Type__c);
                for(String s: fpConts){
                    List<string> usrConts=s.split('#');
                    User_Form_Action__c uFA = new User_Form_Action__c(User__c=usrConts[0],User_Form_Contact__c =usrConts[1],Form_Permission__c = fp.Id);
                    userFormActList.Add(uFA);
                }
            }
            
            //Add records of User Manual Action in a list as per the user
            List<Manuals_Permission__c> manualPermList = [Select Id,Manuals__c,User_Type__c from Manuals_Permission__c where Manuals__r.Event_Edition__c in: eventEdition AND User_Type__c IN:mapUserTypeContact.KeySet()];
            for(Manuals_Permission__c mp: manualPermList){ 
                List<String> fpConts=new List<String>();
                fpConts =mapUserTypeContact.get(mp.User_Type__c);
                for(String s: fpConts){
                    List<string> usrConts=s.split('#');
                    User_Manual_Action__c mFA = new User_Manual_Action__c(User__c=usrConts[0],User_Manual_Contact__c =usrConts[1],Manual_Permission__c = mp.Id);
                    userManualActList.Add(mFA);
                }
            }
            try{
                //Insert records in User_Form_Action__c 
                If(userFormActList.size()>0)
                {
                    Insert userFormActList;
                }    
                
                //Insert records in User_Manual_Action__c 
                If(userManualActList.size()>0)
                {
                    Insert userManualActList;
                }
            }
            catch(Exception ex){ ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,'Create User Action Exception Message: '+ex.getMessage()+'**Line Number='+ex.getLineNumber()));    
            }  
        } 
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.confirm,'Action Created'));            
    }
    
    //Validate input id's
    static public boolean validateId(String Idparam) 
    {
        String id = String.escapeSingleQuotes(Idparam);
        if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
            return true;
        }
        return false;
    }
}