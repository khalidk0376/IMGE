/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          12/21/2017
 * Modified On:         06/05/2018, [Aishwarya BK-3759 27 Aug 2020],[16/07/2021 BK-14824]
 * Description/Purpose: This batch class is called through the class: MassFormReminderEmail
 * Methods:             execute, finish
 * Test Class:          MassFormReminderEmail_Test
**/

public class MassFormReminderEmailBatch implements Database.Batchable<sObject>{
    public String eventEditionId { get; set; }
    public String uFAList { get; set; }
    
    public MassFormReminderEmailBatch(String eventEditionId){
        this.eventEditionId = eventEditionId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        List<User_Form_Action__c> userAFList = [select Id, Name, Is_Filled_Up__c, Form_Permission__r.Event_Edition_Form__r.Name, Form_Permission__r.Event_Edition_Form__r.Deadline__c, Account__c, 
                                                User_Form_Contact__c FROM User_Form_Action__c where Account__c != null AND Form_Permission__r.Event_Edition_Form__r.Event_Edition__c =:eventEditionId];       
        system.debug('###############SIZEUFA '+userAFList.size());
        Set<Id> conIds = new Set<Id>();
        Set<Id> accIds= new Set<Id>();
        for(User_Form_Action__c uAF: userAFList){
            if(string.isNotBlank(uAF.Account__c)) 
            {
                accIds.add(uAF.Account__c);
            }
        }
        List<ContactEventEditionMapping__c>ccEList= [Select Id, SFContactID__c, SFContactID__r.AccountId from ContactEventEditionMapping__c where SFContactID__r.AccountId IN: accIds 
                                                                                AND SFEventEditionID__c =: eventEditionId AND User_Type__c != null];
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
        return Database.getQueryLocator('Select Email, Id, Name, AccountId FROM Contact where Id IN:conIds');
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> conList){
        System.debug('#### ConList'+ConList.size());
        List<Event_Edition__c > eventName= [Select Id,Name from Event_Edition__c where id =: eventEditionId];
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        String tempSubject='';       
        if(string.isNotBlank(eventEditionId)){
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c ='FOMSRM'];                 
        }
        List<User_Form_Action__c> userAFList = [select Id, Name, Is_Filled_Up__c, Form_Permission__r.Event_Edition_Form__r.Name, Form_Permission__r.Event_Edition_Form__r.Deadline__c, Account__c, 
                                                User_Form_Contact__c FROM User_Form_Action__c where Account__c != null AND Form_Permission__r.Event_Edition_Form__r.Event_Edition__c =:eventEditionId];
        System.debug('#### uFAList'+userAFList.size());                                                                          
                                                                                    
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();       
        for(Contact con: conList) 
        { 
             List<String> tempFormList= new  List<String>();
             integer i = 0; 
             integer nonFill=0;
             integer assign=0;  
             integer fill;     
             for(User_Form_Action__c uAF: userAFList)
             {
                 if (uAF.Account__c==con.AccountId)
                 {
                     assign++; 
                     if(uAF.Is_Filled_Up__c!=true&& uAF.Account__c==con.AccountId)              
                     {
                         i++;
                         nonFill++;
                         DateTime newDate = uAF.Form_Permission__r.Event_Edition_Form__r.Deadline__c;
                         if(newDate != null){
                             //String deadline= newDate.format('MM-dd-yyyy');
                             String deadline= newDate.format('dd-MM-yyyy');                        
                             tempFormList.add(i+'.'+uAF.Form_Permission__r.Event_Edition_Form__r.Name+'('+'Deadline: '+deadline+')');
                         }
                         else
                             //tempFormList.add(i+'.'+uAF.Form_Permission__r.Event_Edition_Form__r.Name+'('+'Deadline:'+')'); 
                             tempFormList.add(i+'.'+uAF.Form_Permission__r.Event_Edition_Form__r.Name);              
                     }
                 }
             }
             fill = assign-nonFill;
             String filled= String.valueOf(fill);
             String assigned= String.valueOf(assign);
             system.debug(filled);
             system.debug(assigned);
             string forms='';
             for(String tempFList: tempFormList){
                 forms=forms+tempFList+'<br/>';               
             }    

            if(tempFormList!=null && tempFormList.size()>0)
            {
                if(eeeTemplateList!=null && eeeTemplateList.size()>0 )
                {   
                    //tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{User.Name\\}',uId.Name);
                    tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{Event_Edition_Form__c.Name\\}',forms);
                    tempContent = tempContent.replaceAll('\\{Event_Edition_Form__c.Deadline__c\\}','');
                    //tempContent = tempContent.replaceAll('\\{Event_Edition_Form__c.Name\\}',forms);
                    tempContent = tempContent.replaceAll('\\{Number_of_Filled\\}',filled);
                    tempContent = tempContent.replaceAll('\\{Number_of_Assigned\\}',assigned);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,con.Id);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,con.AccountId);
                    //system.debug('tempContent==='+tempContent);                                      
                    tempSubject = eeeTemplateList[0].Subject__c.replaceAll('\\{Event_Edition__c.Name\\}',eventName[0].Name);
                    tempSubject = tempSubject.replaceAll('\\{Number_of_Filled\\}',filled);
                    tempSubject = tempSubject.replaceAll('\\{Number_of_Assigned\\}',assigned);
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
        if(massEmailLst!=null && massEmailLst.size()>0){
            Messaging.sendEmail(massEmailLst);
        }
    }
    public void finish(Database.BatchableContext bc)
    {
        System.debug('Batch is Completed');
    }
}