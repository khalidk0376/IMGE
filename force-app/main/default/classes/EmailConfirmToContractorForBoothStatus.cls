/**
* Created By: Girikon(Amish)
* Created On:  05/02/2017
* Modified by:  
* Modified On:
* @description : This class is called through the SKUID page: StandContractorSetting
*                      This Class is used for capturing EmailTempate as per status and send email confirmation to contractor on booth status.
* Test Class:  EmailCtoCforBS_Test(88%)      
* Modification Log----- 
* Modified by   : Girikon(Prashant)[CCEN-326],Girikon(Mahesh)[CCEN-358],Girikon(Prashant)[CCEN-411,CCEN-499,CCEN-692(March 7 2019), CCEN-688 (March 18 2019)],[Girikon(Ashish) CCEN-421(march 15 2019),CCEN-753(April 15 2019)],[ Girikon(Aishwarya) CCEN-389 March 19 2019],[Girikon(Garima) CCEN-761(April 22 2019)],[Girikon(Ashish) CCEN-591(June 03 2019)]
* Modified On   : 10/03/2018,10/22/2018,11/01/2018,12/05/2018,12/17/2018,[Aishwarya 16 Sep 2020 BK-8006]
**/


public  without sharing class EmailConfirmToContractorForBoothStatus 
{
    // wrapper class to return Email template name and Email Content 
    public class wrapperClass
    {        
        @AuraEnabled public string emailTempName;
        @AuraEnabled public string emailContent;
        @AuraEnabled public string emailSubject;   //  CCEN-591
        @AuraEnabled public list<BoothContractorMapping__c> BoothConMapWrpr;
        public wrapperClass()
        {
            EmailTempName='';
            EmailContent= '';
            emailSubject ='';
            BoothConMapWrpr = new list<BoothContractorMapping__c>();
        }        
    }
    //captureEmailTemplate will return the Email template name and Email content
    public static wrapperClass captureEmailTemplate (String boothStatus,String eEId,String accId, String boothId,string agentId) 
    {
        wrapperClass wrprObj=new wrapperClass();
        String eTemCode;
        string eTName;
        string eTContent;
        eTemCode= returnEmailTempCode (boothStatus);
        List<Event_Edition_Email_Template__c> eTList = new List<Event_Edition_Email_Template__c >();
        if(string.isNotBlank(eTemCode))
        {   
            if(Schema.sObjectType.Event_Edition_Email_Template__c.isAccessible())
            {
                eTList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eEId AND Email_Template_Code__c =: eTemCode];
            }
            if(eTList!=null && eTList.size()>0)
            {
                wrprObj.emailTempName = eTList[0].Name;
                wrprObj.emailContent =  eTList[0].Content__c;
                wrprObj.emailSubject =  eTList[0].Subject__c;  // Added Subject [CCEN-591]
            }
            
        }
        List <BoothContractorMapping__c> boothConList = new List <BoothContractorMapping__c>();
        if(Schema.sObjectType.BoothContractorMapping__c.isAccessible())
        {
            if(String.isNotBlank(agentId))
            {
                boothConList=[SELECT id,Product__c, Contact__c,Contact__r.Name,Contact__r.Email, TempContact__c, Amount__c,Event_Edition__c  from BoothContractorMapping__c where Contact__r.accountId =: accId AND  Event_Edition__c =:eEId AND Agent_Contact__r.accountId =: agentId ];
            }
            else
            {
                boothConList=[SELECT id,Product__c, Contact__c,Contact__r.Name,Contact__r.Email, TempContact__c, Amount__c,Event_Edition__c  from BoothContractorMapping__c where Contact__r.accountId =: accId AND Event_Edition__c =:eEId AND Opp_Booth_Mapping__c =:boothId ];
            }
        }                
        if(boothConList!=null && boothConList.size()>0)
        {
            wrprObj.BoothConMapWrpr.addAll(boothConList);
        }
        return wrprObj;
        
    }
    // sendEmailToContractoForBoothStatus will send the Email
    public static void sendEmailToContractoForBoothStatus (String eventEditionId,String accountId, String boothStatus, String boothId, string boothContMappingId, string ccInMail,string agentAccID) //Added ccInMail for CC email address in ops admin[CCEN- 326]
    { 
        // Expocad Change CCEN-753
        List <BoothContractorMapping__c> boothConMap= [SELECT id,Product__c,Opp_Booth_Mapping__c,Opp_Booth_Mapping__r.Expocad_Booth__c,Opp_Booth_Mapping__r.Booth_Number__c, Contact__c,TempContact__c, Amount__c,Event_Edition__c,Opp_Booth_Mapping__r.Opportunity__r.Account.Name  from BoothContractorMapping__c where Id =: boothContMappingId]; 
        Set<Id> conList = new Set<Id>();
        string exhAccName='';
       
        List <Stand_Detail__c>  stDList = StandContractorUtils.getSingleStandDetail(boothId,accountId,eventEditionId,agentAccID);
        List <Stand_Design__c>  sDnList = StandContractorUtils.getSingleStandDesign(boothId,accountId,eventEditionId,agentAccID);
        string expoBhId ;
        string expoBoothNo;
        for (BoothContractorMapping__c bCM :boothConMap ) 
        {
            conList.add(bCM.Contact__c);
            expoBhId = bcm.Opp_Booth_Mapping__r.Expocad_Booth__c;
            exhAccName = bCM.Opp_Booth_Mapping__r.Opportunity__r.Account.Name;
            expoBoothNo = bCM.Opp_Booth_Mapping__r.Booth_Number__c;
        }
        system.debug('conList==='+conList);
        List <Contact > contactList = new  List <Contact >();
        if(Schema.sObjectType.Contact.isAccessible())
        {
            contactList = [SELECT id, Email from Contact where Id IN: conList ];
        }
        String emailTemCode;
        emailTemCode= returnEmailTempCode (boothStatus);       
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        String tempSubject='';  
        //Added this for fetching performance Bond Amount from Stand Detail for placeholder variable[CCEN-692]
        String standDetailAmount = '';
        if(stDList.size() > 0)
        {
            standDetailAmount = stDList[0].Amount__c;
        }
        if(string.isNotBlank(eventEditionId))
        {                   
            eeeTemplateList = [Select Id, Name, From_Email_Address__r.Org_Wide_From_Email_Addresses__c, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c  from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c =: emailTemCode];                     
        } 
        String fromAdd;
        //added this functionality regarding ticket [CCEN-358]
        if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
        {
         fromAdd = eeeTemplateList[0].From_Email_Address__r.Org_Wide_From_Email_Addresses__c;                  
        } 
        OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where Address =:fromAdd];  
                  
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        
        if(!eeeTemplateList.isEmpty())
        {
            tempSubject = eeeTemplateList[0].Subject__c;
            tempContent= ParsePlaceholders.renderTemplate(eeeTemplateList[0].Content__c,eeeTemplateList[0].Event_Edition__c, accountId); 
            
            if(!stDList.isEmpty()){
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, stDList[0].id);
                
            }
                
            if(!sDnList.IsEmpty()){
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, sDnList[0].id);
                
            }   
            if(String.isBlank(standDetailAmount))
            {
                tempContent = tempContent.replaceAll('\\{Stand_Detail__c.Amount__c\\}','');
                tempSubject = tempSubject.replaceAll('\\{Stand_Detail__c.Amount__c\\}','');
            } 
            if(String.isNotBlank(agentAccID)) // Added "Agent Pavilion Space" For Agent booths [CCEN-430]
            {
                tempContent = tempContent.replaceAll('\\{ExpocadBooth__c.Booth_Number__c\\}','Agent Pavilion Space');
            }                            
            //tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, boothId );
            tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, expoBhId );
            
            if(!stDList.isEmpty())
            {
                tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,stDList[0].id);
            }
            tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,accountId);  
            
            if(!sDnList.IsEmpty())
            {
                tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,sDnList[0].id);
            }                
            if(String.isNotBlank(agentAccID)) // Added "Agent Pavilion Space" For Agent booths [CCEN-430]
            {
                tempSubject = tempSubject.replaceAll('\\{ExpocadBooth__c.Booth_Number__c\\}','Agent Pavilion Space');    
            } 
            if(String.isBlank(standDetailAmount))
            {
                tempContent = tempContent.replaceAll('\\{Stand_Detail__c.Amount__c\\}','');
            } 
            //tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,boothId );
            tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,expoBhId ); 
            tempSubject = tempSubject.replaceAll('\\{ExpocadBooth__c.Booth_Number__c\\}','Agent Pavilion Space'); 
            if(String.isNotBlank(exhAccName))
            {
                tempSubject = tempSubject.replaceAll('\\{Designating-Exhibitor.Account.Name\\}',exhAccName);
                tempContent = tempContent.replaceAll('\\{Designating-Exhibitor.Account.Name\\}',exhAccName);
            }
            if(String.isNotBlank(expoBoothNo))
            {
                tempSubject = tempSubject.replaceAll('\\{Designating-Exhibitor.ExpocadBooth__c.Booth_Number__c\\}',expoBoothNo);
                tempContent = tempContent.replaceAll('\\{Designating-Exhibitor.ExpocadBooth__c.Booth_Number__c\\}',expoBoothNo);
            }
            system.debug('tempContent==='+tempContent);
            system.debug('tempSubject==='+tempSubject);
        }

        List<Stand_Design_Message_History__c> stdDesignMsgHistory = new List<Stand_Design_Message_History__c>();
        for(Contact c: contactList )
        {
            
            String content = tempContent;
            String subject = tempSubject;
            if(eeeTemplateList!=null && eeeTemplateList.size()>0)
            {   
                content= ParsePlaceholders.renderTemplate(content,eeeTemplateList[0].Event_Edition__c, c.id);
                subject = ParsePlaceholders.renderTemplate(subject,eeeTemplateList[0].Event_Edition__c,c.id);
            }            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<String> sendToCC = new List<String>();
                if(!string.isBlank(ccInMail))
                {
                    sendToCC = ccInMail.split(',');
                }
                // added this functionality regarding ticket [CCEN-358]
                if(!owea.isEmpty() && owea.size()>0)
                {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
            email.setToAddresses(new String[] {c.email});  
            email.setCCAddresses(sendToCC);         
            email.setSaveAsActivity(false);
            email.setTargetObjectId(c.Id); 
            String imageURL = '';
            
            try{
                imageURL=System.Label.RTE_Image_Url;
            }catch(Exception e){ 
                   //BK-3754          
                 Utility.logsError(e.getMessage(), e.getCause(), e.getLineNumber(), e.getStackTraceString(), 'EmailConfirmToContractorForBoothStatus' , 'Integration');
            }
            
            content = content.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
            email.setHtmlBody(content);
            email.setSubject(subject);     
            massEmailLst.Add(email);    
            // added this functionality regarding ticket [CCEN-411]
            if(boothContMappingId != null && boothStatus != 'Edited Stand Details')
            {
                Stand_Design_Message_History__c sDMH = new Stand_Design_Message_History__c();
                sDMH.BoothContractorMapping__c = boothContMappingId;
                sDMH.Content__c = content;
                sDMH.Subject__c = subject;
                sDMH.Email_Template_Code__c = emailTemCode;
                if(!owea.isEmpty() && owea.size()>0)
                {
                    sDMH.From__c = owea.get(0).Address; 
                }
                else{
                    sDMH.From__c = UserInfo.getUserEmail();
                }
                if(sendToCC != null)
                {
                    sDMH.CCEmail__c = ccInMail;
                }
                sDMH.ToEmail__c = c.email;
                
                stdDesignMsgHistory.add(sDMH);
                System.debug('Subject t '+subject);
                System.debug('emailTemCode '+emailTemCode);
            }
        }     
        if(massEmailLst!=null && massEmailLst.size()>0)   
        { 
            Messaging.sendEmail(massEmailLst,false); //Added the false parameter so that if one of the email address is disposable/invalid then all the other valid emails will be sent the mail
        }
        try
        { 
            if(Schema.sObjectType.Stand_Design_Message_History__c.isCreateable())
            {
                insert stdDesignMsgHistory;
            }
        }
        catch(DmlException e)
        {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }
    
    //Return the Email Template code on the basis of Booth Status
    Public static string returnEmailTempCode( String boothStatus)
    {
        String emailtemplateCode;
        if (boothStatus!=null)
        {
            if (boothStatus=='Pending Review')          
            {
                emailtemplateCode='BDPR';
            }
            else if (boothStatus=='Pending Sales Approval')         
            {
                emailtemplateCode='BDPSA';
            }
            else if (boothStatus=='Contractor Resubmit (Incomplete)')           
            {
                emailtemplateCode='BDCR';
            }
            else if (boothStatus=='Pending Venue Approval')         
            {
                emailtemplateCode='BDPVN';
            }
            else if (boothStatus=='Submitted To Venue')         
            {
                emailtemplateCode='BDSV';
            }
            else if (boothStatus=='Tentative Approval')         
            {
                emailtemplateCode='BDTA';
            }
            else if (boothStatus=='Cancelled')          
            {
                emailtemplateCode='BDC';
            }
            else if (boothStatus=='No Design')          
            {
                emailtemplateCode='BDND';
            }
            else if (boothStatus=='Edited Stand Details')          
            {
                emailtemplateCode='ESD';
            }
            else
            {
                emailtemplateCode='';
            }                      
        }
        return emailtemplateCode;   
        
    }
    // Send Email to exhibitors when there Stand Contractors Are rejected by ops Admin With notes [CCEN-421]
    public Static string sendRejectMailToExh(Id sBthConIds ,string note)
    {
        string msg = 'Contractor Rejected & Email Sent successfully!';

        List<BoothContractorMapping__c> lstTempCon = new  List<BoothContractorMapping__c>();
        if(Schema.sObjectType.BoothContractorMapping__c.isAccessible())
        {
            lstTempCon = [select id, Event_Edition__c,IsManagedbyAgent__c,Agent_Contact__c,Agent_Contact__r.AccountId,Agent_Contact__r.Account.Name,Agent_Contact__r.email,Opp_Booth_Mapping__r.Booth_Number__c,Opp_Booth_Mapping__r.Display_Name__c,Opp_Booth_Mapping__r.Opportunity__r.Account.Name ,Opp_Booth_Mapping__r.Opportunity__r.AccountId,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Name,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Email from BoothContractorMapping__c where Id = :sBthConIds limit 1];
        }
        if(lstTempCon.size()>0) 
        {

            string booths = '';
            string exhAccName = '';
            string exhDisplayname = '';
            string conId = '';
            string accId = '';
            string exhEmail = '';
            string eventEditionId = lstTempCon[0].Event_Edition__c;

            if(!lstTempCon[0].IsManagedbyAgent__c)
            {
                booths = lstTempCon[0].Opp_Booth_Mapping__r.Booth_Number__c;
                exhAccName = lstTempCon[0].Opp_Booth_Mapping__r.Opportunity__r.Account.Name;
                exhDisplayname = lstTempCon[0].Opp_Booth_Mapping__r.Display_Name__c;
                conId = lstTempCon[0].Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__c;
                accId = lstTempCon[0].Opp_Booth_Mapping__r.Opportunity__r.AccountId;
                exhEmail = lstTempCon[0].Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Email;
                if(string.isNotBlank(lstTempCon[0].Opp_Booth_Mapping__r.Display_Name__c))
                {
                    exhDisplayname = lstTempCon[0].Opp_Booth_Mapping__r.Display_Name__c;
                }else
                {
                    exhDisplayname = exhAccName;
                }
            }else
            {
                booths = 'Agent Pavilion Space';
                exhAccName = lstTempCon[0].Agent_Contact__r.Account.Name;
                exhDisplayname = lstTempCon[0].Agent_Contact__r.Account.Name;
                conId = lstTempCon[0].Agent_Contact__c;
                accId = lstTempCon[0].Agent_Contact__r.AccountId;
                exhEmail = lstTempCon[0].Agent_Contact__r.Email;
            }

            List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c>();
            if(Schema.sObjectType.Event_Edition_Email_Template__c.isAccessible())
            {
                eeeTemplateList = [Select Id,From_Email_Address__r.Org_Wide_From_Email_Addresses__c,Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c = 'OADC'];
            }

            String fromAdd;
            //added this functionality regarding ticket [CCEN-358]
            if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
            {
                fromAdd = eeeTemplateList[0].From_Email_Address__r.Org_Wide_From_Email_Addresses__c;      
            } 
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromAdd];


            List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
            string content = '';
            string subject='';
            System.debug('eeeTemplateList' + eeeTemplateList);
            System.debug('eeeTemplateList size' + eeeTemplateList.size());
            if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
            {
                content = eeeTemplateList[0].Content__c;
                subject= eeeTemplateList[0].Subject__c ;
                content= content.replaceAll('\\{Designating-Exhibitor.ExpocadBooth__c.Booth_Number__c\\}',booths);
                content= content.replaceAll('\\{Designating-Exhibitor.Account.Name\\}',exhAccName);
                content= content.replaceAll('\\{Account.Name\\}',exhAccName);
                content= content.replaceAll('\\{ExpocadBooth__c.Display_Name__c\\}',exhDisplayname);
                content= content.replaceAll('\\{ExpocadBooth__c.Booth_Number__c\\}',booths);
                content= ParsePlaceholders.renderTemplate(content,eeeTemplateList[0].Event_Edition__c, conId);
                content= ParsePlaceholders.renderTemplate(content,eeeTemplateList[0].Event_Edition__c, accId);
                subject=subject.replace('{ExpocadBooth__c.Booth_Number__c}',booths);
                subject=subject.replace('{Designating-Exhibitor.ExpocadBooth__c.Booth_Number__c}',booths);
                subject=subject.replace('{Designating-Exhibitor.Account.Name}',exhAccName);
                subject=subject.replaceAll('\\{Account.Name\\}',exhAccName);
                subject=subject.replaceAll('\\{ExpocadBooth__c.Display_Name__c\\}',exhDisplayname);
                subject = ParsePlaceholders.renderTemplate(subject ,eeeTemplateList[0].Event_Edition__c,conId);
                subject = ParsePlaceholders.renderTemplate(subject ,eeeTemplateList[0].Event_Edition__c,accId);
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(!owea.isEmpty() && owea.size()>0)
            {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            } 
            email.setToAddresses(new String[] {exhEmail});
            email.setSaveAsActivity(false);
            email.setTargetObjectId(conId);            
            email.setHtmlBody(content+'[<b>Note:</b> '+note+ ' ]');        
            email.setSubject(subject);
            if(string.isNotBlank(exhEmail))
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email },false);
            } 
        }           
        return msg;
    }
    //Send email to ops admin upon creating StandContractor - CCEN-389
      public static void sendEmailToOpsAdmin(string templateCode, String eventId,list<string> lstBoothIds)
      { 
        User usr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()];
        String exhAccId = usr.Accountid;
        string exhAccName='';
        string exhDisplayname ='     ';        
        string booths='';
        
        list<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpocadBooth= new list<Opportunity_ExpoCAD_Booth_Mapping__c>();
        
        if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible())
        {
            lstExpocadBooth = [select id,Booth_Number__c,Display_Name__c,Opportunity__r.Operations_Contact__r.accountId,Opportunity__r.Operations_Contact__r.account.Name from Opportunity_ExpoCAD_Booth_Mapping__c where Id In :lstBoothIds];  
        }
        
        for(Opportunity_ExpoCAD_Booth_Mapping__c expBooth : lstExpocadBooth)
        {   
            booths+=(booths==''?expBooth.Booth_Number__c:','+expBooth.Booth_Number__c);
            if(expBooth.Opportunity__r.Operations_Contact__r.accountId != null)
            {
                exhAccId = expBooth.Opportunity__r.Operations_Contact__r.accountId; // Account Id from ExpocadBooth  for [CCEN-457]
                exhAccName=expBooth.Opportunity__r.Operations_Contact__r.account.Name;
                exhDisplayname=expBooth.Display_Name__c;
            }
            if(string.isBlank(exhDisplayname))
            {
                exhDisplayname = expBooth.Opportunity__r.Operations_Contact__r.account.Name;
            }            
        }  
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        List<String> emailAddresses = new List<String>();
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c>();
        if(Schema.sObjectType.Event_Edition_Email_Template__c.isAccessible())
        {
            eeeTemplateList = [Select Id, Name,From_Email_Address__r.Org_Wide_From_Email_Addresses__c, Content__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventId AND Email_Template_Code__c =: templateCode];
        }
        String fromAdd;
        string content='';
        string subject='';
        //added this functionality regarding ticket [CCEN-389]
        if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
        {
            fromAdd = eeeTemplateList[0].From_Email_Address__r.Org_Wide_From_Email_Addresses__c;
            content = eeeTemplateList[0].Content__c;
            subject = eeeTemplateList[0].Subject__c;
            content= content.replaceAll('\\{Designating-Exhibitor.ExpocadBooth__c.Booth_Number__c\\}',booths);
            content= content.replaceAll('\\{Designating-Exhibitor.Account.Name\\}',exhAccName);
            content= content.replaceAll('\\{Account.Name\\}',exhAccName);
            if(string.isNotBlank(exhDisplayname))
            {
                content= content.replaceAll('\\{ExpocadBooth__c.Display_Name__c\\}',exhDisplayname); 
                subject= subject.replaceAll('\\{ExpocadBooth__c.Display_Name__c\\}',exhDisplayname);
            }else
            {
                content= content.replaceAll('\\{ExpocadBooth__c.Display_Name__c\\}',' ');
                subject= subject.replaceAll('\\{ExpocadBooth__c.Display_Name__c\\}',' ');
            }            
            content= content.replaceAll('\\{ExpocadBooth__c.Booth_Number__c\\}',booths);
            
            subject=subject.replace('{ExpocadBooth__c.Booth_Number__c}',booths);
            subject=subject.replace('{Designating-Exhibitor.ExpocadBooth__c.Booth_Number__c}',booths);
            subject=subject.replace('{Designating-Exhibitor.Account.Name}',exhAccName);
            
            
            
           
        }
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromAdd];
        Event_Edition__c evtEdition = new Event_Edition__c();
        if(Schema.sObjectType.Event_Edition__c.isAccessible())
        {
            evtEdition = [Select id,Name from Event_Edition__c where id = :eventId limit 1];
        }
        
        if(evtEdition !=null)
        {
            //content = content.replaceAll('\\{Account.Name\\}',acc.name);
            content = content.replaceAll('\\{Event_Edition__c.Name\\}',evtEdition.Name);
            subject = subject.replaceAll('\\{Event_Edition__c.Name\\}',evtEdition.Name);
        }
        Event_Settings__c evntSetting = new Event_Settings__c();
        if(Schema.sObjectType.Event_Settings__c.isAccessible())
        {
            evntSetting=[select id,Stand_Contractor_notification_recipient__c  from Event_Settings__c where Event_Edition__c = :eventId limit 1];
        }
        String emailAddress = evntSetting.Stand_Contractor_notification_recipient__c ;
        if(emailAddress !=  null && emailAddress != ' ')
        {
            emailAddresses = emailAddress.split(',');
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();    
            
            email.setToAddresses(emailAddresses);
            //added this functionality regarding ticket [CCEN-389]
            if(!owea.isEmpty() && owea.size()>0)
            {
              email.setOrgWideEmailAddressId(owea.get(0).Id);
            } 
            email.setSaveAsActivity(false);
            email.setHtmlBody(content);
            email.setSubject(subject);
            // Add emails to list
            massEmailLst.Add(email); 
        
        //Send all emails if list is not empty
        if(massEmailLst!=null && massEmailLst.size()>0)
        {
            Messaging.sendEmail(massEmailLst,false);
        }
    }

    // Added this method to forward email from Messages tab in Stand Contractor(Ops Admin) section [CCEN-688]
    public static string forwardEmailToCon(Stand_Design_Message_History__c stdHistory)
    {
        string msg= 'Email Forwarded Succesfully.';

        List<String> toEmailAddress = new List<String>();
        List<String> ccEmailAddress = new List<String>();
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        String fromAdd;
        string toEmail ='';
        string ccEmail = '';
        string evntEdition = '';
        //Insert forwarded messages in Stand_Design_Message_History__c custom object[CCEN-688]
        List<Stand_Design_Message_History__c> stdDesignMsgHistory = new List<Stand_Design_Message_History__c>();
        if(stdHistory != null)
        {
            Stand_Design_Message_History__c sDMH = new Stand_Design_Message_History__c();
            sDMH.BoothContractorMapping__c = stdHistory.BoothContractorMapping__c;
            sDMH.Content__c = stdHistory.Content__c;
            sDMH.Email_Template_Code__c = stdHistory.Email_Template_Code__c;
            sDMH.From__c = stdHistory.From__c;
            sDMH.Is_Forwarded__c = true;
            sDMH.Subject__c= stdHistory.Subject__c;
            sDMH.ToEmail__c = stdHistory.ToEmail__c;

            stdDesignMsgHistory.add(sDMH);
            try{
                if(Schema.sObjectType.Stand_Design_Message_History__c.isCreateable())
                {
                    insert stdDesignMsgHistory;
                }
            }
            catch(DmlException e)
            {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
            }

            evntEdition = stdHistory.BoothContractorMapping__r.Event_Edition__c;
            if(string.isNotBlank(evntEdition))
            {                   
                eeeTemplateList = [Select  id,From_Email_Address__r.Org_Wide_From_Email_Addresses__c
                               from Event_Edition_Email_Template__c where Event_Edition__c =:evntEdition AND Email_Template_Code__c =: stdHistory.Email_Template_Code__c];                     
            }
            if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
            {
                fromAdd = eeeTemplateList[0].From_Email_Address__r.Org_Wide_From_Email_Addresses__c;      
            } 
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromAdd];
            toEmail = stdHistory.ToEmail__c;
            ccEmail = stdHistory.CCEmail__c;
           
            if(toEmail !=  null && toEmail != '')
            {
                toEmailAddress = toEmail.split(',');
            }
            if(ccEmail !=  null && ccEmail != '')
            {
                ccEmailAddress = ccEmail.split(',');
            }

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();     
            
            email.setToAddresses(toEmailAddress);
            //added this functionality regarding ticket [CCEN-358]
            if(!owea.isEmpty() && owea.size()>0)
            {
              email.setOrgWideEmailAddressId(owea.get(0).Id);
            } 
            email.setCcAddresses(ccEmailAddress);
            email.setSaveAsActivity(false);
            email.setHtmlBody(stdHistory.Content__c);
            email.setSubject(stdHistory.Subject__c); 

            if(email!=null)
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email }, false); 
            }
        }
        return msg;
    }
      

}