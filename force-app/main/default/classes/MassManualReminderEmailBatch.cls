/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          12/21/2017
 * Modified On:         06/05/2018,[Aishwarya BK-3759 27 Aug 2020],[16/07/2021  BK-14824]
 * Description/Purpose: This batch class is called through the class: MassManualReminderEmail
 * Methods:             execute, finish
 * Test Class:          MassManualReminderEmail_Test
**/

public class MassManualReminderEmailBatch implements Database.Batchable<sObject>{
    public String eventEditionId { get; set; }
    
    public MassManualReminderEmailBatch(String eventEditionId){
        this.eventEditionId = eventEditionId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        List<User_Manual_Action__c> userAMList = [select id, Name,Is_Agree__c,Manual_Permission__r.Manuals__r.Name,Account__c, User_Manual_Contact__c from User_Manual_Action__c 
                                                  where Account__c != null AND Manual_Permission__r.Manuals__r.Event_Edition__c =:eventEditionId];
        Set<Id> conIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        system.debug('================uASize: '+userAMList.size());
        for(User_Manual_Action__c uAM: userAMList ){
            if(string.isNotBlank(uAM.Account__c)){
                accIds.add(uAM.Account__c); // getting accountIds from UserManualAction
            }
        }
        List<ContactEventEditionMapping__c>ccEList= [Select Id, SFContactID__c, SFContactID__r.AccountId FROM ContactEventEditionMapping__c where 
                                                            SFContactID__r.AccountId IN: accIds AND SFEventEditionID__c =: eventEditionId AND User_Type__c != null];
        if(!ccEList.IsEmpty())
        {
            for (ContactEventEditionMapping__c ceem: ccEList)
            {
                if(string.isNotBlank(ceem.SFContactID__c)) 
                {
                    conIds.add(ceem.SFContactID__c);
                }
            }
        }
        return Database.getQueryLocator('Select Id, Email, Name, AccountId from Contact where Id IN: conIds');
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> conList){
        //System.debug('#### eventEditionId'+eventEditionId);
        //System.debug('#### uMAList'+uMAList);
        System.debug('#### SCOPE '+conList+'SIZE::'+conList.Size());
        //MassManualReminderEmailHandler.MassManualReminderEmail(eventEditionId, uMAList);
        List<Event_Edition__c > eventName= [Select Id, Name FROM Event_Edition__c where id =: eventEditionId];    
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        String tempSubject='';       
        if(string.isNotBlank(eventEditionId)){
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c FROM Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c ='MAMSRM'];                 
        }
        
        List<User_Manual_Action__c> userAMList = new List<User_Manual_Action__c>();
        userAMList = [select Id, Name, Is_Agree__c, Manual_Permission__r.Manuals__r.Name, Account__c, User_Manual_Contact__c FROM User_Manual_Action__c where Account__c != null AND Manual_Permission__r.Manuals__r.Event_Edition__c =:eventEditionId]; 
        system.debug('================uMAList: '+userAMList+'SIZE '+userAMList.size()); 
        
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        for(Contact con: conList) 
        { 
             List<String> tempManualList= new  List<String>();
             integer i = 0; 
             integer nonAgree=0;
             integer assign=0;  
             integer agree;     
             for(User_Manual_Action__c uAM: userAMList )
             {
                 // if (uAM.User_Manual_Contact__c ==con.Id)
                 if(string.isNotBlank(uAM.Account__c))
                 {
                     if (uAM.Account__c==con.AccountId)
                     {
                         assign++; 
                         if (uAM.Is_Agree__c!=true && uAM.Account__c==con.AccountId)   //   uAM.User_Manual_Contact__c ==con.Id )   //            
                         {
                             //System.Debug(uAM.Manual_Permission__r.Manuals__r.Name +'/' +uId);
                             i++;
                             nonAgree++;                                                      
                             tempManualList.add(i+'.'+uAM.Manual_Permission__r.Manuals__r.Name);              
                         }
                     }
                 }
             }
             agree = assign-nonAgree;
             String agreeed= String.valueOf(agree);
             String assigned= String.valueOf(assign);
             system.debug(agreeed);
             system.debug(assigned);

             string manuals='';
             for(String tempMList: tempManualList){
                 manuals=manuals+tempMList+'<br/>';               
             }    
            //system.debug('Email==='+uId.email);
            //system.debug('UName==='+uId.Name);
            if (tempManualList!=null && tempManualList.size()>0)
            {
                if(eeeTemplateList!=null && eeeTemplateList.size()>0 )
                {   
                    //tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{User.Name\\}',uId.Name);
                    //tempContent = tempContent.replaceAll('\\{Manual__c.Name\\}',manuals);
                    tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{Manual__c.Name\\}',manuals);
                    tempContent = tempContent.replaceAll('\\{Number_of_agreed\\}',agreeed);
                    tempContent = tempContent.replaceAll('\\{Number_of_Assigned\\}',assigned);
                    //system.debug(tempContent );
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, eventEditionId);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,con.Id);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,con.AccountId);
                    //system.debug('tempContent==='+tempContent);
                    //tempSubject = eeeTemplateList[0].Subject__c.replaceAll('\\{Event_Edition__c.Name\\}',eventName[0].Name);
                    //tempSubject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c);
                    tempSubject = eeeTemplateList[0].Subject__c.replaceAll('\\{Event_Edition__c.Name\\}',eventName[0].Name);
                    tempSubject = tempSubject.replaceAll('\\{Number_of_agreed\\}',agreeed);
                    tempSubject = tempSubject.replaceAll('\\{Number_of_Assigned\\}',assigned);
                    tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c, eventEditionId);
                    tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,con.Id);
                    tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,con.AccountId);    
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {con.email});           
                email.setSaveAsActivity(false);
                email.setTargetObjectId(con.Id); 
                email.setHtmlBody(tempContent);
                email.setSubject(tempSubject);     
                massEmailLst.Add(email);  
                system.debug(massEmailLst);
            }                       
        }
        system.debug('massEmailLst==='+massEmailLst);
        if(massEmailLst !=null && massEmailLst.size()>0){
            Messaging.sendEmail(massEmailLst);
        }
    }
    
    public void finish(Database.BatchableContext bc)
    {
        System.debug('Batch is Completed'); 
    }
}