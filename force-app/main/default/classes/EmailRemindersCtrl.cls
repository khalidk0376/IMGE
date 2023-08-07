/**
* Created By    :  Girikon(Ashish)
* Created On    :  03/10/2018
* @description   :  Allows Ops Admin to Send Additional Stand Contractor Reminder Emails & Exhibitor Reminder Emails .[CCEN-302]&[CCEN-368 ] 
* Test Class    :  EmailRemindersCtrl_Test (88%)
* Modification Log----- 
* Modified by : Girikon(Mahesh)[CCEN-358 (Oct 22 2018)],Girikon(Ashish)[CCEN-455 (Nov 19 2018)],Girikon[Prashant] [CCEN-692 (March 8 2019)],Girikon(Garima)[CCEN-751 April 4 2019]
**/
public without sharing class EmailRemindersCtrl 
{
    @AuraEnabled  // Send Reminder mails to all Exhibitors without Contractor
    public static string mailExhibitorswithoutContractor(string evntId,string ccAddress) 
    { 
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        string evntCode = [select Event_Code__c from Event_Edition__c where id =:evntId ].Event_Code__c; 
        list<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpoBoth =  new list<Opportunity_ExpoCAD_Booth_Mapping__c>();
        Map<String,string> mapBooth = new Map<string,string>();
        set<id>conIDs = new set<id>(); // Email reminders ... Send to Space Only exhibitors [CCEN-455] 
        
        //Updated reference of ExpocadBooth Object to the new object regarding [CCEN-751]
        if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible() && Schema.sObjectType.BoothContractorMapping__c.isAccessible())
        {
            lstExpoBoth = [select id,Booth_Number__c,Opportunity__r.Operations_Contact__c from Opportunity_ExpoCAD_Booth_Mapping__c where Status__c = 'Active' And Expocad_Booth__r.Status__c = 'Rented' And Expocad_Booth__r.Matched_Product_Name__c like '%Space Only%' And (Opportunity__r.User_Type__r.name = 'Exhibitor' or Opportunity__r.User_Type__r.name = 'Agent Owned Exhibitor' )  And (Opportunity__r.StageName = 'Closed Won' OR Opportunity__r.StageName = 'Closed Booked') And Opportunity__r.EventEdition__c=: evntId  And id not In (select Opp_Booth_Mapping__c from BoothContractorMapping__c WHERE Event_Edition__c =: evntId and Opp_Booth_Mapping__r.Opportunity__c!= NULL And Opp_Booth_Mapping__r.Expocad_Booth__c != NULL And Opp_Booth_Mapping__r.Status__c = 'Active' And Opp_Booth_Mapping__r.Expocad_Booth__r.status__c = 'Rented' And (Contact__c != NULL AND Approved__c = TRUE))];
        }
        for(Opportunity_ExpoCAD_Booth_Mapping__c exbth :lstExpoBoth)
        {
            conIDs.add(exbth.Opportunity__r.Operations_Contact__c);
            System.debug('conIDs ==='+conIDs.size());
            if(mapBooth.containsKey(exbth.Opportunity__r.Operations_Contact__c)) 
            { 
                mapBooth.put(exbth.Opportunity__r.Operations_Contact__c ,mapBooth.get(exbth.Opportunity__r.Operations_Contact__c)+' , '+exbth.Booth_Number__c) ; 
            }
            else 
            {
                mapBooth.put(exbth.Opportunity__r.Operations_Contact__c,exbth.Booth_Number__c);
            }           
        }
        sendEmailByCode(conIDs,'EWC',evntId,ccAddress,mapBooth); 
        
        System.debug('lstExpoBoth ==='+lstExpoBoth);   
        String rtn = JSON.serialize(conIDs.size());
        return rtn;    
    } 
    
    @AuraEnabled // Send Reminder mails to all Exhibitors before Show
    public static string exhibitorPreShowReminder(string evntId,string ccAddress) 
    { 
        /**variables : company name, stand # **/
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        list<ContactEventEditionMapping__c> lstConEvtmap = new list<ContactEventEditionMapping__c>();
        list<BoothContractorMapping__c> lstBothConmap = new list<BoothContractorMapping__c>();
        Map<String,string> mapBooth = new Map<string,string>();
        //Updated reference of ExpocadBooth Object to the new object regarding [CCEN-751]
        if( Schema.sObjectType.BoothContractorMapping__c.isAccessible())
        {
            lstBothConmap = [select id , Contact__c, Opp_Booth_Mapping__c , Opp_Booth_Mapping__r.Booth_Number__c,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c,Contact__r.account.name ,(select id,Amount__c,Opp_Booth_Mapping__c  from Stand_Details__r limit 1)from BoothContractorMapping__c where Contact__c != null And Opp_Booth_Mapping__c != null And Opp_Booth_Mapping__r.Opportunity__c !=  null And Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c != null and Event_Edition__c = :evntId];
        }
        string pbAmount = '';
        for(BoothContractorMapping__c bcm :lstBothConmap )
        {
            if(mapBooth.containsKey(bcm.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c )) 
            {
                mapBooth.put(bcm.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c ,mapBooth.get(bcm.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c)+' , '+bcm.Contact__r.account.name+' :# '+bcm.Opp_Booth_Mapping__r.Booth_Number__c) ;
            } 
            else
            {
                mapBooth.put(bcm.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c,bcm.Contact__r.account.name+' :# '+bcm.Opp_Booth_Mapping__r.Booth_Number__c);
            }
            //Added this for fetching performance Bond Amount from Stand Detail for placeholder variable[CCEN-692]
            for(Stand_Detail__c stdDetails : bcm.Stand_Details__r)
            {
                if(stdDetails.Amount__c != null)
                {
                    pbAmount = stdDetails.Amount__c;
                }
            }
        } 
        if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible())
        {
            lstConEvtmap =[select id ,SFContactID__r.account.name,SFContactID__r.name,SFContactID__r.email,SFContactID__c,SFEventEditionID__r.Name from ContactEventEditionMapping__c where SFEventEditionID__c =: evntId  And SFContactID__c != null And(User_Type__r.name = 'Exhibitor' or User_Type__r.name = 'Agent Owned Exhibitor')];
        }
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c>();
        if(Schema.sObjectType.Event_Edition_Email_Template__c.isAccessible())
        {
             eeeTemplateList = [Select Id, Name, Content__c,From_Email_Address__r.Org_Wide_From_Email_Addresses__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:evntId AND Email_Template_Code__c = 'EPSR'];
        }
       
        String fromAdd;
        //added this functionality regarding ticket [CCEN-358]
        if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
        {
         fromAdd = eeeTemplateList[0].From_Email_Address__r.Org_Wide_From_Email_Addresses__c;      
        } 
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromAdd];               
        for(ContactEventEditionMapping__c cEvMp : lstConEvtmap)
        {
            list<string> ccAddresses = new list<string>();
            contact con =  new contact(id=cEvMp.SFContactID__c,email=cEvMp.SFContactID__r.email);
            string content=' ' ;
            string subject ='';
            
            if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
            {     
                content = eeeTemplateList[0].Content__c;
                subject=eeeTemplateList[0].Subject__c;
                content= content.replaceAll('\\{Account.Name\\}',cEvMp.SFContactID__r.account.name);
                subject= subject.replaceAll('\\{Account.Name\\}',cEvMp.SFContactID__r.account.name);
                
                content= content.replaceAll('\\{Event_Edition__c.Name\\}',cEvMp.SFEventEditionID__r.Name);
                if(mapBooth!= null  && mapBooth.containsKey(cEvMp.SFContactID__c))
                {
                    content= content.replaceAll('\\{Contractor : # booth\\}',mapBooth.get(cEvMp.SFContactID__c));
                    subject= subject.replaceAll('\\{Contractor : # booth\\}',mapBooth.get(cEvMp.SFContactID__c));
                }
                else 
                {
                    content= content.replaceAll('\\{Contractor : # booth\\}',' ');
                    subject= subject.replaceAll('\\{Contractor : # booth\\}',' ');
                } 
                if(pbAmount != '')
                {
                    content= content.replaceAll('\\{Stand_Detail__c.Amount__c\\}',pbAmount); 
                    subject= subject.replaceAll('\\{Stand_Detail__c.Amount__c\\}',pbAmount); 
                }
                else
                {
                    content= content.replaceAll('\\{Stand_Detail__c.Amount__c\\}',''); 
                    subject= subject.replaceAll('\\{Stand_Detail__c.Amount__c\\}',''); 
                }
                content= content.replaceAll('\\{Stand_Detail__c.Amount__c\\}','');               
                subject= subject.replaceAll('\\{Event_Edition__c.Name\\}',cEvMp.SFEventEditionID__r.Name);
            }
            
            if(ccAddress !=  null && ccAddress != ' ') 
            {
                ccAddresses = ccAddress.split(',');
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {con.email});
            
            if(!ccAddresses.isEmpty() && ccAddresses.size()>0)
            {
                email.setccAddresses(ccAddresses);
            }
           //added this functionality regarding ticket [CCEN-358]
            if(!owea.isEmpty() && owea.size()>0)
            {
              email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            email.setSaveAsActivity(false);
            email.setTargetObjectId(con.Id);
            email.setHtmlBody(content);
            email.setSubject(subject);
            
            //add emailmessage to list
            massEmailLst.Add(email); 
        }        
        //Send all emails if list is not empty
        if(massEmailLst!=null && massEmailLst.size()>0)
        {
            Messaging.sendEmail(massEmailLst,false);
        } 
        //String rtn = JSON.serialize(lstConEvtmap);
        System.debug('lstConEvtmap ==='+lstConEvtmap);
        return string.valueOf(massEmailLst.size());   
    }
    
    @AuraEnabled  // Send Reminder mails to all Contractor before Show 
    public static string contractorPreShowReminder(string evntId,string ccAddress) 
    { 
        /**variables : company name, stand # **/
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c> ();
        list<BoothContractorMapping__c> lstBothConmap = new list<BoothContractorMapping__c>();
        if(Schema.sObjectType.BoothContractorMapping__c.isAccessible())
        {
            lstBothConmap = [select id,Contact__r.email ,Opp_Booth_Mapping__r.Booth_Number__c ,Contact__r.name,Contact__c,Contact__r.account.name,(select id,Amount__c,Opp_Booth_Mapping__c  from Stand_Details__r limit 1) from BoothContractorMapping__c where ((Opp_Booth_Mapping__r.Opportunity__c!= NULL  And Opp_Booth_Mapping__r.Expocad_Booth__r.status__c = 'Rented' And Opp_Booth_Mapping__r.Status__c = 'Active') or (IsManagedbyAgent__c = true And Opp_Booth_Mapping__c = null)) AND (Contact__c != NULL AND Approved__c = TRUE) And Event_Edition__c =:evntId];
        }
        if(Schema.sObjectType.Event_Edition_Email_Template__c.isAccessible())
        {
            eeeTemplateList = [Select Id, Name,From_Email_Address__r.Org_Wide_From_Email_Addresses__c, Content__c, Subject__c, Email_Template__c, Event_Edition__c,Event_Edition__r.name from Event_Edition_Email_Template__c where Event_Edition__c =:evntId AND Email_Template_Code__c = 'CPSR'];
        }
        String fromAdd;
        //added this functionality regarding ticket [CCEN-358]
        if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
        {
         fromAdd = eeeTemplateList[0].From_Email_Address__r.Org_Wide_From_Email_Addresses__c;      
        } 
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromAdd];               
        
        for(BoothContractorMapping__c bcm : lstBothConmap)
        { 
            list<string> ccAddresses = new list<string>();
            contact con =  new contact(id=bcm.Contact__c,email=bcm.Contact__r.email);
            
            string content=' ';
            string subject =' ';
            string pbAmount = '';
            //Added this for fetching performance Bond Amount from Stand Detail for placeholder variable[CCEN-692]
            for(Stand_Detail__c stdDetails : bcm.Stand_Details__r)
            {
                if(stdDetails.Amount__c != null)
                {
                    pbAmount = stdDetails.Amount__c;
                }
            }
            if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
            {   
                content = eeeTemplateList[0].Content__c;
                subject=eeeTemplateList[0].Subject__c;
               
                content= content.replaceAll('\\{Account.Name\\}',bcm.Contact__r.account.name);
                subject= subject.replaceAll('\\{Account.Name\\}',bcm.Contact__r.account.name);
                content= content.replaceAll('\\{Event_Edition__c.Name\\}',eeeTemplateList[0].Event_Edition__r.Name);
                content= content.replaceAll('\\{ExpocadBooth__c.Booth_Number__c\\}',bcm.Opp_Booth_Mapping__r.Booth_Number__c);
                subject= subject.replaceAll('\\{ExpocadBooth__c.Booth_Number__c\\}',bcm.Opp_Booth_Mapping__r.Booth_Number__c);
                subject= subject.replaceAll('\\{Event_Edition__c.Name\\}',eeeTemplateList[0].Event_Edition__r.Name);
                if(pbAmount != '')
                {
                    content= content.replaceAll('\\{Stand_Detail__c.Amount__c\\}',pbAmount); 
                    subject= subject.replaceAll('\\{Stand_Detail__c.Amount__c\\}',pbAmount); 
                }
                else
                {
                    content= content.replaceAll('\\{Stand_Detail__c.Amount__c\\}',''); 
                    subject= subject.replaceAll('\\{Stand_Detail__c.Amount__c\\}',''); 
                }
            }
            if(ccAddress !=  null && ccAddress != ' ' ) 
            {
                ccAddresses = ccAddress.split(',');
            }
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {con.email});
            
                        
            if(!ccAddresses.isEmpty() && ccAddresses.size()>0)
            {
                email.setccAddresses(ccAddresses);
            } 
            //added this functionality regarding ticket [CCEN-358]
            if(!owea.isEmpty() && owea.size()>0)
            {
              email.setOrgWideEmailAddressId(owea.get(0).Id);
            }           
            email.setSaveAsActivity(false);
            email.setTargetObjectId(con.Id);
            email.setHtmlBody(content);
            email.setSubject(subject);  
            //add emailmessage to list
            massEmailLst.Add(email); 
            
        }
        
        //Send all emails if list is not empty
        if(massEmailLst!=null && massEmailLst.size()>0)
        {
            Messaging.sendEmail(massEmailLst,false);
        }
        
        System.debug('lstBothConmap ==='+lstBothConmap);
        //String rtn = JSON.serialize(lstBothConmap);
        return string.valueOf(massEmailLst.size());   
    }
    
    @AuraEnabled // Send Reminder mails to all Contractor with design status as 'No Design','Contractor Resubmit' OR 'Pending Sales Approval'
    public static String contractorStatusReminder(string evntId ,string dsnStatus,string tmpCode,string ccAddress ) 
    { 
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        list<BoothContractorMapping__c> lstBothConmap = new list<BoothContractorMapping__c>();
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c>();
        //Updated reference of ExpocadBooth Object to the new object regarding [CCEN-751]
        if(dsnStatus != 'No Design')
        {
            lstBothConmap = [select id ,Contact__r.name,Contact__r.Account.Name,Booth_Design_Status__c,Opp_Booth_Mapping__r.Booth_Number__c,Contact__r.email,Contact__c ,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.email,Opp_Booth_Mapping__r.Opportunity__r.Account.Name, Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.name, (select id,Amount__c,Opp_Booth_Mapping__c from Stand_Details__r limit 1) from BoothContractorMapping__c where ((Opp_Booth_Mapping__r.Opportunity__c!= NULL   And Opp_Booth_Mapping__r.Expocad_Booth__r.status__c = 'Rented' And Opp_Booth_Mapping__r.Status__c = 'Active') or (IsManagedbyAgent__c = true And Opp_Booth_Mapping__c = null)) AND (Contact__c != NULL AND Approved__c = TRUE) And Event_Edition__c =: evntId And Booth_Design_Status__c =: dsnStatus];
        }
        else
        {
            lstBothConmap = [select id ,Contact__r.name,Contact__r.Account.Name,Booth_Design_Status__c,Contact__r.email,Opp_Booth_Mapping__r.Booth_Number__c,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.email,Opp_Booth_Mapping__c, Opp_Booth_Mapping__r.Opportunity__r.Account.Name, Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.name,  (select id,Amount__c,Opp_Booth_Mapping__c   from Stand_Details__r limit 1)    from BoothContractorMapping__c where ((Opp_Booth_Mapping__r.Opportunity__c!= NULL   And Opp_Booth_Mapping__r.Expocad_Booth__r.status__c = 'Rented' And Opp_Booth_Mapping__r.Status__c = 'Active') or (IsManagedbyAgent__c = true And Opp_Booth_Mapping__c = null)) AND Contact__c != NULL AND Approved__c = TRUE  And (Booth_Design_Status__c = 'No Design' OR Booth_Design_Status__c = null) And Event_Edition__c =:evntId ];
        }
        if(Schema.sObjectType.Event_Edition_Email_Template__c.isAccessible())
        {
            eeeTemplateList = [Select Id, Name, Content__c,From_Email_Address__r.Org_Wide_From_Email_Addresses__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:evntId AND Email_Template_Code__c =: tmpCode];
        }
        String fromAdd;
        //added this functionality regarding ticket [CCEN-358]
        if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
        {
         fromAdd = eeeTemplateList[0].From_Email_Address__r.Org_Wide_From_Email_Addresses__c;      
        } 
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromAdd];    
        System.debug('lstBothConmap ==='+lstBothConmap);
        string exhAccName='';
        for(BoothContractorMapping__c bcm : lstBothConmap)
        {   
            list<string> ccAddresses = new list<string>();
            contact con =  new contact(id=bcm.Contact__c,email=bcm.Contact__r.email);
            contact exhCon = new contact(id=bcm.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c,email=bcm.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.email);
            string pbAmount = '';
            exhAccName = bcm.Opp_Booth_Mapping__r.Opportunity__r.Account.Name;
            
            //Added this for fetching performance Bond Amount from Stand Detail for placeholder variable[CCEN-692]
            for(Stand_Detail__c stdDetails : bcm.Stand_Details__r)
            {
                if(stdDetails.Amount__c != null)
                {
                    pbAmount = stdDetails.Amount__c;
                }
            }
            string sts = ((bcm.Booth_Design_Status__c == null) ? 'No Design': bcm.Booth_Design_Status__c );
            string content=' ';
            string subject ='';
            
            
            if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
            {   
                content = eeeTemplateList[0].Content__c;
                subject=eeeTemplateList[0].Subject__c;
                content = content.replaceAll('\\{ExpocadBooth__c.Booth_Number__c\\}',bcm.Opp_Booth_Mapping__r.Booth_Number__c);
                content = content.replaceAll('\\{Account.Name\\}',bcm.Contact__r.Account.Name);
                content = content.replaceAll('\\{Stand_Design__c.Booth_Design_Status__c\\}',sts);
                subject = subject.replaceAll('\\{ExpocadBooth__c.Booth_Number__c\\}',bcm.Opp_Booth_Mapping__r.Booth_Number__c);
                subject = subject.replaceAll('\\{Stand_Design__c.Booth_Design_Status__c\\}',sts);
                content = content.replaceAll('\\{Designating-Exhibitor.Account.Name\\}',exhAccName);
                subject = subject.replaceAll('\\{Designating-Exhibitor.Account.Name\\}',exhAccName);
                content = content.replaceAll('\\{Designating-Exhibitor.ExpocadBooth__c.Booth_Number__c\\}',bcm.Opp_Booth_Mapping__r.Booth_Number__c);
                subject = subject.replaceAll('\\{Designating-Exhibitor.ExpocadBooth__c.Booth_Number__c\\}',bcm.Opp_Booth_Mapping__r.Booth_Number__c);
                
                if(pbAmount != '')
                {
                    content = content.replaceAll('\\{Stand_Detail__c.Amount__c\\}',pbAmount);
                    subject = subject.replaceAll('\\{Stand_Detail__c.Amount__c\\}',pbAmount);
                }
                else
                {
                    content = content.replaceAll('\\{Stand_Detail__c.Amount__c\\}','');
                    subject = subject.replaceAll('\\{Stand_Detail__c.Amount__c\\}','');
                }
            }
            if(ccAddress !=  null && ccAddress != ' ') 
            {
                ccAddresses = ccAddress.split(',');
            }
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setToAddresses(new String[] {con.email});
            ccAddresses.add(exhCon.email);
            
            if(!ccAddresses.isEmpty() && ccAddresses.size()>0)
            {
                email.setccAddresses(ccAddresses);
            }
            //added this functionality regarding ticket [CCEN-358]
            if(!owea.isEmpty() && owea.size()>0)
            {
               email.setOrgWideEmailAddressId(owea.get(0).Id);
            } 
            email.setSaveAsActivity(false);
            email.setTargetObjectId(con.Id);
            email.setHtmlBody(content);
            email.setSubject(subject);
            
            massEmailLst.Add(email); 
        }
        
        if(massEmailLst!=null && massEmailLst.size()>0)
        {
            Messaging.sendEmail(massEmailLst,false);
        }
        
        return string.valueOf(massEmailLst.size());
    }
    @AuraEnabled  // Send Reminder mails to all Contractor with all Performance Bond details 
    public static string contractorPerformanceBondReminder(string evntId,string ccAddress) 
    {          
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        list<Stand_Detail__c>lststndDtls = new list<Stand_Detail__c>();
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c> ();
        //Updated reference of ExpocadBooth Object to the new object regarding [CCEN-751]
        if(Schema.sObjectType.Stand_Detail__c.isAccessible())
        {
            lststndDtls = [select id,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.email,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c ,Amount__c,IsReceived__c,Receipt__c,Riggering_Options__c,BoothContractorMapping__r.Contact__r.email,BoothContractorMapping__r.Contact__c,BoothContractorMapping__r.Contact__r.account.name,BoothContractorMapping__r.Performance_Bond_Submitted__c from Stand_Detail__c where BoothContractorMapping__c in (select id from BoothContractorMapping__c where ((Opp_Booth_Mapping__r.Opportunity__c!= NULL And Opp_Booth_Mapping__r.Expocad_Booth__r.status__c = 'Rented' And Opp_Booth_Mapping__r.Status__c = 'Active') or (IsManagedbyAgent__c = true And Opp_Booth_Mapping__c = null)) AND (Contact__c != NULL AND Approved__c = TRUE) And Event_Edition__c =:evntId)];
        }
        if(Schema.sObjectType.Event_Edition_Email_Template__c.isAccessible())
        {
            eeeTemplateList = [Select Id, Name,From_Email_Address__r.Org_Wide_From_Email_Addresses__c, Content__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:evntId AND Email_Template_Code__c = 'CPBR'];
        }
        String fromAdd;
        //added this functionality regarding ticket [CCEN-358]
        if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
        {
         fromAdd = eeeTemplateList[0].From_Email_Address__r.Org_Wide_From_Email_Addresses__c;      
        } 
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromAdd];   
        for(Stand_Detail__c sd :lststndDtls )
        {
            list<string> ccAddresses = new list<string>();
            contact con =  new contact(id=sd.BoothContractorMapping__r.Contact__c,email=sd.BoothContractorMapping__r.Contact__r.email);
            contact exhCon = new contact(id=sd.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c,email=sd.Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.email);
            
            string content='';
            string subject='';
            
            if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())     
            {    
                content = eeeTemplateList[0].Content__c;
                subject=eeeTemplateList[0].Subject__c;
                content= content.replaceAll('\\{Account.name\\}',sd.BoothContractorMapping__r.Contact__r.account.name);
                if(sd.Amount__c != null)
                {
                    content= content.replaceAll('\\{Amount\\}',sd.Amount__c);
                    subject= subject.replaceAll('\\{Amount\\}',sd.Amount__c);
                }
                else 
                {
                    content= content.replaceAll('\\{Amount\\}', ' ');
                    subject= subject.replaceAll('\\{Amount\\}', ' ');
                }
                if(sd.Receipt__c != null)
                {
                    content= content.replaceAll('\\{Receipt\\}',sd.Receipt__c);
                    subject= subject.replaceAll('\\{Receipt\\}',sd.Receipt__c);
                }
                else 
                {
                    content= content.replaceAll('\\{Receipt\\}',' ');
                    subject= subject.replaceAll('\\{Receipt\\}',' ');
                }
                if(sd.BoothContractorMapping__r.Performance_Bond_Submitted__c)
                {  
                    content= content.replaceAll('\\{Performance_Bond \\}','yes');
                    subject= subject.replaceAll('\\{Performance_Bond \\}','yes');
                }
                else
                {
                    content= content.replaceAll('\\{Performance_Bond \\}','No');
                    subject= subject.replaceAll('\\{Performance_Bond \\}','No');
                }
                
            }
            
            if(ccAddress !=  null && ccAddress != ' ' ) 
            {
                ccAddresses = ccAddress.split(',');
            }
            
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();    
            
            email.setToAddresses(new String[] {con.email});
            
            ccAddresses.add(exhCon.email);
            if(!ccAddresses.isEmpty() && ccAddresses.size()>0)
            {
                email.setccAddresses(ccAddresses);
            }
            //added this functionality regarding ticket [CCEN-358]
            if(!owea.isEmpty() && owea.size()>0)
            {
              email.setOrgWideEmailAddressId(owea.get(0).Id);
            } 
            email.setSaveAsActivity(false);
            email.setTargetObjectId(con.Id);
            email.setHtmlBody(content);
            email.setSubject(subject);
            // Add emails to list
            massEmailLst.Add(email); 
        }
        //Send all emails if list is not empty
        if(massEmailLst!=null && massEmailLst.size()>0)
        {
            Messaging.sendEmail(massEmailLst,false);
        }
        
        System.debug('lststndDtls ==='+lststndDtls);
        //return JSON.serialize(ccAddresses);
        return string.valueOf(massEmailLst.size());
        
    }
    @AuraEnabled  // get email Content using Email Template Code    
    public static Event_Edition_Email_Template__c getEmailContent(string evntId, string emailCode ) 
    {   
        Event_Edition_Email_Template__c et = new Event_Edition_Email_Template__c();
        list<Event_Edition_Email_Template__c> evntMail = new list<Event_Edition_Email_Template__c>();
        
        if(evntId != null && emailCode != null) 
        {
            evntMail = [select Subject__c,Content__c from Event_Edition_Email_Template__c where Event_Edition__c = :evntId And Email_Template__r.Template_Code__c =:emailCode limit 1];
        }
        
        if(!evntMail.isEmpty() && evntMail.size()>0) {
            et =  evntMail[0]; 
        } 
        return et;     
    }
    @AuraEnabled  // get email Content using Email Template Code    
    public static string updateEmailContent(Event_Edition_Email_Template__c evtTmp ) 
    {
        string msg = 'Upadted !' ;
        try 
        { 
            update evtTmp;
        } 
        catch(DmlException e) 
        {
            msg = e.getMessage();
        }
        return msg;   
    }

    
    @AuraEnabled  // Send Reminder mails to all Exhibitors without submitted Profiles [CCEN-368]
    public static string mailExhibitorswithoutProfiles(string evntId) 
    {   
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        string evntCode = [select Event_Code__c from Event_Edition__c where id =:evntId ].Event_Code__c; 
        list<ExpocadBooth__c> lstExpoBoth =  new list<ExpocadBooth__c>();
        list<Opportunity_ExpoCAD_Booth_Mapping__c> lstOppExpoBoothsMapping=new list<Opportunity_ExpoCAD_Booth_Mapping__c>();
        Map<String,string> mapBooth = new Map<string,string>();
        set<id>conIDs = new set<id>(); 
        if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible() && Schema.sObjectType.Customer_Product_Category__c.isAccessible() && Schema.sObjectType.BoothContactInfo__c.isAccessible())
        {
            lstOppExpoBoothsMapping = [select id,Booth_Number__c,Opportunity__r.Operations_Contact__c,Opportunity__r.Operations_Contact__r.email 
                        from Opportunity_ExpoCAD_Booth_Mapping__c where Status__c = 'Active' and Expocad_Booth__r.Status__c = 'Rented' And Opportunity__r.Operations_Contact__c != null  
                        And Opportunity__c != null And Event_Code__c =: evntCode 
                        And (Opportunity__r.StageName = 'Closed Won' or Opportunity__r.StageName = 'Closed Booked') 
                        And (Opportunity__r.User_Type__r.name = 'Exhibitor' or Opportunity__r.User_Type__r.name = 'Agent Owned Exhibitor' )
                        And id not In (select Opp_Booth_Mapping__c from Customer_Product_Category__c where Event_Edition__c =: evntId) 
                        And id not In ( select Opportunity_Booth_Mapping__c from BoothContactInfo__c where IsSubmitted__c = true And Event_Edition__c =:evntId)];
        }
        

          for(Opportunity_ExpoCAD_Booth_Mapping__c exbth :lstOppExpoBoothsMapping)
        {
            conIDs.add(exbth.Opportunity__r.Operations_Contact__c);
            if(mapBooth.containsKey(exbth.Opportunity__r.Operations_Contact__c)) 
            { 
                mapBooth.put(exbth.Opportunity__r.Operations_Contact__c ,mapBooth.get(exbth.Opportunity__r.Operations_Contact__c)+' , '+exbth.Booth_Number__c) ; 
            }
            else 
            {
                mapBooth.put(exbth.Opportunity__r.Operations_Contact__c,exbth.Booth_Number__c);
            }           
        }

        string ccAddress ;
        sendEmailByCode(conIDs,'EWSP',evntId,ccAddress,mapBooth);
        System.debug('lstOppExpoBoothsMapping ==='+lstOppExpoBoothsMapping);   
        String rtn = JSON.serialize(conIDs.size());
        return rtn;
    }
    
    
    //Send Email to contact 
    public static void sendEmailByCode(set<id> conIds,string templateCode,string eventId,string ccAddress,Map<String,string> mapBooth)
    {
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        if(Schema.sObjectType.User.isAccessible())
        {
            User usr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()];
        }
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c> ();
        if(Schema.sObjectType.Event_Edition_Email_Template__c.isAccessible())
        {
            eeeTemplateList = [Select Id, Name,From_Email_Address__r.Org_Wide_From_Email_Addresses__c, Content__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventId AND Email_Template_Code__c =: templateCode];
        }         
        String fromAdd;
        //added this functionality regarding ticket [CCEN-358]
        if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
        {
         fromAdd = eeeTemplateList[0].From_Email_Address__r.Org_Wide_From_Email_Addresses__c;      
        } 
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromAdd];  

        for(contact con : [Select Email, id, Name, AccountId,Account.Name FROM Contact where Id IN:conIds])
        {
            list<string> ccAddresses = new list<string>();
            string content='';
            string subject='';
            if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())                
            {   
                content = eeeTemplateList[0].Content__c;
                subject=eeeTemplateList[0].Subject__c;
                content= content.replaceAll('\\{Account.Name\\}',con.account.name);
                if(mapBooth!= null  && mapBooth.containsKey(con.id))
                {
                    content= content.replaceAll('\\{ExpocadBooth__c.Booth_Number__c\\}',mapBooth.get(con.id));
                }
                else 
                {
                    content= content.replaceAll('\\{ExpocadBooth__c.Booth_Number__c\\}','');
                } 
                content= content.replaceAll('\\{Stand_Detail__c.Amount__c\\}','');
                subject= subject.replaceAll('\\{Stand_Detail__c.Amount__c\\}','');
            }
            if(ccAddress !=  null && ccAddress != ' ' ) 
            {
                ccAddresses = ccAddress.split(',');
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            email.setToAddresses(new String[] {con.email});
            email.setSaveAsActivity(false);
            email.setTargetObjectId(con.Id);
            if(!ccAddresses.isEmpty() && ccAddresses.size()>0){
                email.setccAddresses(ccAddresses);
            }
            //added this functionality regarding ticket [CCEN-358]
            if(!owea.isEmpty() && owea.size()>0)
            {
              email.setOrgWideEmailAddressId(owea.get(0).Id);
            }    
            email.setHtmlBody(content); 
            email.setSubject(subject);
            massEmailLst.Add(email);          
        }
        //Send all emails if list is not empty
        if(massEmailLst!=null && massEmailLst.size()>0)   
        { 
            Messaging.sendEmail(massEmailLst,false);
        }   
    }    
}