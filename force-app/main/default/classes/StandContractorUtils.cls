/**
 * Created By       :   Girikon(Ashish) 
 * Created On       :   28 march 2019  After Expocad Change [CCEN-742]
 * @description     :   This class provides functionalities For Stand Contractor Module:  *                                 
 * Test Class       :   StandContractorUtils_Test(88%)
 * Modification log --
 * Modified by      :   Girikon(Sunil[CCEN-787 May 29 2019],Garima[CCEN-761],Ashish[C2E-8 Sep 02 2019],[Rajeev BK-2349 Seb 24 2019],[Rajeev BK-2346 Seb 30 2019 ,BK-2969 Nov 21 2019],[Prashant[STL-282 Oct 16 2019],[Himanshu[BK - 2876 Dec 15 2019]],[Rajeev[BK-3250 Dec 22 2020]])
                        Aishwarya[BK-3273 Jan 23 2020],Aishwarya[BK-10223 23 Dec 2020]
 **/
public without sharing class StandContractorUtils
{
    // Methord To get all booths for customer from all there opps of a Event
    public static list<Opportunity_ExpoCAD_Booth_Mapping__c> getCustomerBooths(String customerAccId,String eventCode)
    {
        set<string> quoteIds = new set<string>(); // Customer Quotes Ids
        List<opportunity> lstOppsExh = new List<opportunity>();  // Customer opp .
        list<Opportunity_ExpoCAD_Booth_Mapping__c> boothlist = new list<Opportunity_ExpoCAD_Booth_Mapping__c>();  //Customer Booths Data
        list<Event_Settings__c>evntStng =  new list<Event_Settings__c>(); //Event Settings
        list<string>allowedExpocadProductTypes = new list<string>();  // Booth product types
        if(Schema.sObjectType.Event_Settings__c.isAccessible())
        {
            evntStng = [select id , Allowed_Expocad_Product_Types__c from Event_Settings__c where Event_Edition__r.Event_Code__c =: eventCode limit 1]; 
        }
        if(evntStng.size()>0)
        {
            if(String.IsNotBlank(evntStng[0].Allowed_Expocad_Product_Types__c))
            {
                allowedExpocadProductTypes = evntStng[0].Allowed_Expocad_Product_Types__c.split(';');
            }
        }
        lstOppsExh = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where (StageName='Closed Won' OR StageName='Closed Booked') And SBQQ__PrimaryQuote__c!=''And (EventEdition__r.Event_Code__c =: eventCode or EventEdition__c=:eventCode) And AccountId =:customerAccId order by createdDate limit 1000];
        if(!lstOppsExh.IsEmpty())
        {
            for(opportunity oppty: lstOppsExh)  
            {
                quoteIds.add(String.valueOf(oppty.SBQQ__PrimaryQuote__c)); 
            }
            if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible() && allowedExpocadProductTypes.size() > 0 ) 
            {
                boothlist = [select id,Booth_Number__c,Expocad_Booth__r.Matched_Product_Name__c from Opportunity_ExpoCAD_Booth_Mapping__c where Status__c = 'Active' And Expocad_Booth__r.Status__c = 'Rented' And (Opportunity__r.StageName = 'Closed Won' OR Opportunity__r.StageName = 'Closed Booked') and (Related_Opportunity__c  = null OR Related_Opportunity__r.User_Type__r.Name = 'Co-Exhibitor') And Expocad_Booth__r.Matched_Product_Name__c in:allowedExpocadProductTypes And Quote__c in:quoteIds ];
            }
        }
        return boothlist;
    }

    // Methord To get all feilds for one Stand Contractor From  Booth Contractor Mapping from Id
    // Added TempAccount Address Field Regarding Ticket BK-2969
    public static List<BoothContractorMapping__c> getSingleContractorDetail(Id singleBthConId)
    {
        List<BoothContractorMapping__c> singleBooth = new List<BoothContractorMapping__c>();
        if(Schema.sObjectType.BoothContractorMapping__c.isAccessible() && Schema.sObjectType.CustomerContractorService__c.isAccessible())
        {
            singleBooth = [select Id,TempContact__r.TempAccount__r.Id, TempContact__r.TempAccount__r.Zip__c,Opp_Booth_Mapping__r.Expocad_Booth__c,TempContact__r.MobilePhone__c,Opp_Booth_Mapping__r.Expocad_Booth__r.Booth_Type__c,Opp_Booth_Mapping__r.Expocad_Booth__r.Dimensions__c,TempContact__r.TempAccount__r.Country__c,TempContact__r.TempAccount__r.Address__c,TempContact__r.TempAccount__r.State__c,TempContact__r.TempAccount__r.City__c, Opp_Booth_Mapping__c,Contact__r.Phone,Contact__r.Email,Contact__r.MobilePhone,TempContact__r.Phone__c,TempContact__r.Email__c,Opp_Booth_Mapping__r.Booth_Number__c,Contact__c,IsManagedbyAgent__c,Agent_Contact__r.AccountId,Agent_Contact__r.MobilePhone,Agent_Contact__r.Contact_Type__c,Agent_Contact__r.account.Name,Agent_Contact__r.account.BillingStreet,Agent_Contact__r.account.BillingCity,Agent_Contact__r.account.Phone,Agent_Contact__r.Name,Agent_Contact__r.Phone,Agent_Contact__r.Email,Agent_Contact__r.account.BillingState,TempContact__r.FirstName__c,TempContact__r.LastName__c,TempContact__c,TempContact__r.Name__c,TempContact__r.Account__r.Name,TempContact__r.TempAccount__r.Name,Contact__r.Name,Contact__r.AccountId,contact__r.Account.Name,Opp_Booth_Mapping__r.Opportunity__r.User_Type__r.Name,Agent_Contact__r.account.BillingPostalCode,contact__r.Account.BillingStreet,contact__r.Account.billingstate,contact__r.Account.billingcity,contact__r.Account.BillingPostalCode,contact__r.Account.billingCountry,status__c,createdby.contact.account.Name,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.account.name,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.account.Phone,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.account.BillingStreet,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.account.BillingCity,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.account.BillingState,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.account.BillingPostalCode,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.account.BillingCountry,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Name,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.MobilePhone,Opp_Booth_Mapping__r.Opportunity__r.Account.Name,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Contact_Type__c,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Phone,Opp_Booth_Mapping__r.Opportunity__r.Operations_Contact__r.Email,Opp_Booth_Mapping__r.Display_Name__c,(SELECT Id, ContractorService__r.Contractor_Service__c from CustomerContractorServices__r),Event_Edition__c from BoothContractorMapping__c where Id = :singleBthConId];
        }
        return singleBooth;
    }

    //Fetch pavailion space booths for agent
     public static list<Opportunity_ExpoCAD_Booth_Mapping__c>  getPavilionSpaceExhibitorsBooths(String sEventcode,string accId,string srchText) 
    { 
        set<string> quoteIds = new set<string>(); // Agent owned Exh Quotes Ids
        List<opportunity> lstOppsExh = new List<opportunity>();  // Agent owned Exhibitor opp .
        List<Opportunity_ExpoCAD_Booth_Mapping__c> lstAOEBooths = new List<Opportunity_ExpoCAD_Booth_Mapping__c>(); // Agent owned Exh Booths Data
        //lstOppsExh = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where (StageName='Closed Won' OR StageName='Closed Booked') And SBQQ__PrimaryQuote__c!='' And (parent_Opportunity__r.StageName='Closed Won' OR parent_Opportunity__r.StageName='Closed Booked') And parent_Opportunity__r.User_Type__r.name = 'Agent' AND (EventEdition__r.Event_Code__c =: sEventcode or EventEdition__c=:sEventcode) And parent_Opportunity__r.AccountId =:accId order by createdDate limit 1000];
        //BK-3273(Modified the query Limit)
        lstOppsExh = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where (StageName='Closed Won' OR StageName='Closed Booked') And SBQQ__PrimaryQuote__c!='' And (parent_Opportunity__r.StageName='Closed Won' OR parent_Opportunity__r.StageName='Closed Booked') And parent_Opportunity__r.User_Type__r.name = 'Agent' AND (EventEdition__r.Event_Code__c =: sEventcode or EventEdition__c=:sEventcode) And parent_Opportunity__r.AccountId =:accId order by createdDate limit 3000];
        if(!lstOppsExh.IsEmpty())
        {
            for(opportunity oppty: lstOppsExh)  
            {
                quoteIds.add(String.valueOf(oppty.SBQQ__PrimaryQuote__c)); 
            }              
            string fields = ' Id,Booth_Number__c,Opportunity__r.Account.Name ';
            string conditions = ' Status__c = \'Active\' And Expocad_Booth__r.Status__c = \'Rented\' And Opportunity__r.parent_Opportunity__c != null And Opportunity__r.User_Type__r.name = \'Agent Owned Exhibitor\' And Opportunity__r.parent_Opportunity__r.User_Type__r.name = \'Agent\' And (Opportunity__r.StageName = \'Closed Won\' OR Opportunity__r.StageName = \'Closed Booked\') And Quote__c in:quoteIds And Expocad_Booth__r.Matched_Product_Name__c like \'%Pavilion Space%\' And (NOT Expocad_Booth__r.Matched_Product_Name__c like \'%Space Only%\')';
            String query = 'select '+ fields + ' from Opportunity_ExpoCAD_Booth_Mapping__c where '+conditions;
            if(String.isNotBlank(srchText))
            {
                query=query+' and Opportunity__r.Account.Name like \'%'+ String.escapeSingleQuotes(srchText) +'%\' ';
            }       
            query+=' order by Opportunity__r.createdDate limit 3000';
            lstAOEBooths = Database.query(query);
        }
        return lstAOEBooths;
    }
    //Send Email to contact
    public static void sendEmailToContractorByCode(string eventEditionId, string emailTemCode,contact cont,list<string> lstBoothIds)
    {
        system.debug('test::');
        User usr = [SELECT Id, Contactid,Accountid  FROM User WHERE Id = : UserInfo.getUserId()];
        contact con = new contact();
        if(Schema.sObjectType.contact.isAccessible()){
            con = [select Id,email,AccountId from  contact where id =:cont.Id];
        }        
        String exhAccId = usr.Accountid;
        string exhAccName='';
        string exhDisplayname ='     ';        
        string booths='';
        string stdDetailAmt = '';
        string expoArea = '';
        string boothType = '';
        string boothClass = '';
        String rejectionReason ='';
        list<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpocadBooth= new list<Opportunity_ExpoCAD_Booth_Mapping__c>();
        list<Stand_Detail__c> lstStandDetail= new list<Stand_Detail__c>();
        list<Stand_Design__c> lstStandDesign= new list<Stand_Design__c>();
        List<BoothContractorMapping__c> bthContmappng = new List<BoothContractorMapping__c>();
          if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible()){
            bthContmappng=[select id , name ,Rejection_Reason__c from BoothContractorMapping__c where Opp_Booth_Mapping__c IN :lstBoothIds];
        }
        if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible()){
            lstExpocadBooth = [select id,Booth_Number__c,Expocad_Booth__r.Area__c,Expocad_Booth__r.Booth_Classes__c,Expocad_Booth__r.Matched_Product_Name__c,Display_Name__c,Opportunity__r.Operations_Contact__r.accountId,Opportunity__r.Operations_Contact__r.account.Name from Opportunity_ExpoCAD_Booth_Mapping__c where Id In :lstBoothIds];  
        }
        //Added this for fetching performance Bond Amount from Stand Detail for placeholder variable[CCEN-692]
        if(Schema.sObjectType.Stand_Detail__c.isAccessible()){
            lstStandDetail = [select id,Amount__c,Opp_Booth_Mapping__c,IsDoubleDecker__c,Is_Heavy_Machinery__c,Island_Booth_4_sides__c,Is_One_side_open_stand__c,IsRigging__c,Rigging_Height__c,Is_Three_side_open_stand__c,Is_Two_side_open_stand__c,Stand_Height__c,Is_Vehicles__c  from Stand_Detail__c where Opp_Booth_Mapping__c In :lstExpocadBooth];
        }
        if(Schema.sObjectType.Stand_Design__c.isAccessible()){
            lstStandDesign = [Select id,Booth_Design_Status__c,Booth_Design_Submitted_On__c,Is_Rejected__c,Opp_Booth_Mapping__c,Stand_Type__c from Stand_Design__c where Opp_Booth_Mapping__c In :lstExpocadBooth];
        }
        for(BoothContractorMapping__c bthMappng :bthContmappng){
           if(bthMappng.Rejection_Reason__c!=null){
               rejectionReason=bthMappng.Rejection_Reason__c;
           }
        }
        for(Opportunity_ExpoCAD_Booth_Mapping__c expBooth : lstExpocadBooth){   
            booths+=(booths==''?expBooth.Booth_Number__c:','+expBooth.Booth_Number__c);
            if(expBooth.Opportunity__r.Operations_Contact__r.accountId != null){
                exhAccId = expBooth.Opportunity__r.Operations_Contact__r.accountId; // Account Id from ExpocadBooth  for [CCEN-457]
                exhAccName=expBooth.Opportunity__r.Operations_Contact__r.account.Name;
                exhDisplayname=expBooth.Display_Name__c;
            }
            if(expBooth.Expocad_Booth__r.Area__c != null){
                expoArea = ((expBooth.Expocad_Booth__r.Area__c != null ) ? expBooth.Expocad_Booth__r.Area__c : ''); 
            }
            if(string.isBlank(exhDisplayname)){exhDisplayname = expBooth.Opportunity__r.Operations_Contact__r.account.Name;
            }
            if(expBooth.Expocad_Booth__r.Matched_Product_Name__c != null){
                boothType = expBooth.Expocad_Booth__r.Matched_Product_Name__c;
            } 
            if(expBooth.Expocad_Booth__r.Booth_Classes__c != null){
                boothClass = expBooth.Expocad_Booth__r.Booth_Classes__c;
            }
        }
        if(lstStandDetail.size()>0){ stdDetailAmt = lstStandDetail[0].Amount__c;
        }
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c>();
        if(Schema.sObjectType.Event_Edition_Email_Template__c.isAccessible()){
            eeeTemplateList = [Select Id,From_Email_Address__r.Org_Wide_From_Email_Addresses__c,Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c =: emailTemCode];
        }    
        String fromAdd;
        //added this functionality regarding ticket [CCEN-358]
        if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty()){
            fromAdd = eeeTemplateList[0].From_Email_Address__r.Org_Wide_From_Email_Addresses__c; 
        } 

        system.debug('test1::' + fromAdd);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromAdd];  
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        string content = '';
        string subject='';
        if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
        {
            content = String.isNotEmpty(eeeTemplateList[0].Content__c) ? eeeTemplateList[0].Content__c : '';
            subject= String.isNotEmpty(eeeTemplateList[0].Subject__c) ? eeeTemplateList[0].Subject__c : '' ;
            content= content.replaceAll('\\{Designating-Exhibitor.ExpocadBooth__c.Booth_Number__c\\}',booths);
            content= content.replaceAll('\\{Designating-Exhibitor.Account.Name\\}',exhAccName);
            content= content.replaceAll('\\{Account.Name\\}',exhAccName);
            if(string.isNotBlank(exhDisplayname)){
                content= content.replaceAll('\\{ExpocadBooth__c.Display_Name__c\\}',exhDisplayname);
                subject= subject.replaceAll('\\{ExpocadBooth__c.Display_Name__c\\}',exhDisplayname);
            }else{
                content= content.replaceAll('\\{ExpocadBooth__c.Display_Name__c\\}',' ');
                subject= subject.replaceAll('\\{ExpocadBooth__c.Display_Name__c\\}',' ');
            }            
            content= content.replaceAll('\\{ExpocadBooth__c.Booth_Number__c\\}',booths);
            if(String.isNotBlank(stdDetailAmt)){
                content= content.replaceAll('\\{Stand_Detail__c.Amount__c\\}',stdDetailAmt);
            }
            else{
                content= content.replaceAll('\\{Stand_Detail__c.Amount__c\\}','');
            }
            if(String.isNotBlank(expoArea)){
                content= content.replaceAll('\\{ExpocadBooth__c.Area__c\\}',expoArea);
                subject= subject.replaceAll('\\{ExpocadBooth__c.Area__c\\}',expoArea);
            }
            else{
                content= content.replaceAll('\\{ExpocadBooth__c.Area__c\\}','');
                subject= subject.replaceAll('\\{ExpocadBooth__c.Area__c\\}','');
            }
            if(String.isNotBlank(boothType)){
                content= content.replaceAll('\\{ExpocadBooth__c.Booth_Type__c\\}',boothType);
                subject= subject.replaceAll('\\{ExpocadBooth__c.Booth_Type__c\\}',boothType);
            }
            else{
                content= content.replaceAll('\\{ExpocadBooth__c.Booth_Type__c\\}','');
                subject= subject.replaceAll('\\{ExpocadBooth__c.Booth_Type__c\\}','');
            }
            if(String.isNotBlank(boothClass)){
                content= content.replaceAll('\\{ExpocadBooth__c.Booth_Classes__c\\}',boothClass);
                subject= subject.replaceAll('\\{ExpocadBooth__c.Booth_Classes__c\\}',boothClass);
            }
            else{
                content= content.replaceAll('\\{ExpocadBooth__c.Booth_Classes__c\\}','');
                subject= subject.replaceAll('\\{ExpocadBooth__c.Booth_Classes__c\\}','');
            }
            if(String.isNotBlank(rejectionReason)){
                 content= content.replaceAll('\\{BoothContractorMapping__c.Rejection_Reason__c\\}',rejectionReason); //BK-2349
            }
            else{
                 content= content.replaceAll('\\{BoothContractorMapping__c.Rejection_Reason__c\\}',''); 
            }
            content= ParsePlaceholders.renderTemplate(content,eeeTemplateList[0].Event_Edition__c, con.Id);
            content= ParsePlaceholders.renderTemplate(content,eeeTemplateList[0].Event_Edition__c, con.AccountId);
            
            if(!lstStandDetail.isEmpty()){
            content= ParsePlaceholders.renderTemplate(content,eeeTemplateList[0].Event_Edition__c, lstStandDetail[0].id);
            subject= ParsePlaceholders.renderTemplate(subject,eeeTemplateList[0].Event_Edition__c, lstStandDetail[0].id);
            }
            if(!lstStandDesign.isEmpty()){
            content= ParsePlaceholders.renderTemplate(content,eeeTemplateList[0].Event_Edition__c, lstStandDesign[0].id);
            subject= ParsePlaceholders.renderTemplate(subject,eeeTemplateList[0].Event_Edition__c, lstStandDesign[0].id);
            }
            subject= ParsePlaceholders.renderTemplate(subject,eeeTemplateList[0].Event_Edition__c, con.Id);
            subject= ParsePlaceholders.renderTemplate(subject,eeeTemplateList[0].Event_Edition__c, con.AccountId);
            
            
            subject=subject.replace('{ExpocadBooth__c.Booth_Number__c}',booths);
            subject=subject.replace('{Designating-Exhibitor.ExpocadBooth__c.Booth_Number__c}',booths);
            subject=subject.replace('{Designating-Exhibitor.Account.Name}',exhAccName);
            if(String.isNotBlank(stdDetailAmt)){
                subject= subject.replaceAll('\\{Stand_Detail__c.Amount__c\\}',stdDetailAmt);
            }
            else{
                subject= subject.replaceAll('\\{Stand_Detail__c.Amount__c\\}','');
            }
             
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if(!owea.isEmpty() && owea.size()>0){email.setOrgWideEmailAddressId(owea.get(0).Id);
        } 
        system.debug('test2::');
        email.setToAddresses(new String[] {con.email});
        email.setSaveAsActivity(false);
        email.setTargetObjectId(con.Id);
        email.setHtmlBody(content);
        email.setSubject(subject);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email },false);
    }
    // this 
    public static string approveStandContractor(Id sboothConMapId,string requestedBy)
    {        
        Savepoint sp = Database.setSavepoint();
        set<Id> sConIds = new set<Id>();
        List<Contact> createCon = new List<Contact>();
        List<Account> createAcc = new List<Account>();
        List<Contact> updateCon = new List<Contact>();
        List<Id> lstTempAcc= new List<Id>();
        List<Id> lstTempCon= new List<Id>();
        string sIdsCon = null;
        string sEventId = null;
        list<string>boothIDs = new list<string>();
        List<BoothContractorMapping__c> updateBoothmap = new List<BoothContractorMapping__c>();
        Id sTypeId = [SELECT Id, Name FROM User_Type__c WHERE Name='Stand Contractor'].Id;
        List<BoothContractorMapping__c> lstBoothConMap = [select id, Contact__c,TempContact__r.TempAccount__c,TempContact__r.TempAccount__r.Address__c,ExpocadBooth__c,Opp_Booth_Mapping__c,TempContact__r.TempAccount__r.Zip__c,Event_Edition__c,TempContact__r.TempAccount__r.State__c,TempContact__r.TempAccount__r.Country__c,TempContact__r.TempAccount__r.City__c,TempContact__r.TempAccount__r.Name,TempContact__r.Phone__c,TempContact__r.MobilePhone__c, TempContact__r.Email__c,ExpocadBooth__r.Booth_Number__c, TempContact__r.Account__c,TempContact__c,TempContact__r.FirstName__c,TempContact__r.LastName__c from BoothContractorMapping__c where Id = :sboothConMapId limit 1];
        if(lstBoothConMap != null && lstBoothConMap.size()>0)
        {
            for(BoothContractorMapping__c oBooth: lstBoothConMap)
            {
                if(oBooth.Contact__c != null)
                {
                    sIdsCon=oBooth.Contact__c;
                    createContractorUser(sIdsCon,oBooth.Event_Edition__c);
                }                
                if(oBooth.Event_Edition__c != null)
                {
                    sEventId = oBooth.Event_Edition__c;
                }      
                if(oBooth.TempContact__r.TempAccount__c != null && oBooth.TempContact__r.Account__c == null)
                {                   
                    Account oAcc = new Account();
                    oAcc.Name = oBooth.TempContact__r.TempAccount__r.Name;
                    oAcc.BillingStreet = oBooth.TempContact__r.TempAccount__r.Address__c; 
                    oAcc.BillingCity = oBooth.TempContact__r.TempAccount__r.City__c;
                    oAcc.BillingCountrycode = oBooth.TempContact__r.TempAccount__r.Country__c;
                    oAcc.BillingStatecode = oBooth.TempContact__r.TempAccount__r.State__c;
                    oAcc.BillingPostalCode = oBooth.TempContact__r.TempAccount__r.Zip__c;
                    oAcc.Type='Stand Contractor';
                    createAcc.add(oAcc);
                    lstTempAcc.add(oBooth.TempContact__r.TempAccount__c);
                }
                boothIDs.add(oBooth.Opp_Booth_Mapping__c);
            }
            if(createAcc != null && createAcc.size()>0 && Schema.sObjectType.Account.IsCreateable())
            {
                try 
                {
                    insert createAcc;
                } 
                catch(DmlException e) 
                {
                    //return('This Account already exist in the system so can not be approved.');
                    Database.rollback(sp);
                    return('DmlException----'+e.getMessage());
                }     
            }      
            for(BoothContractorMapping__c oBooth: lstBoothConMap)
            {  
                if(oBooth.TempContact__c != null )
                {   
                    Contact oObjCon=new Contact();
                    oObjCon.FirstName = oBooth.TempContact__r.FirstName__c;
                    oObjCon.LastName = oBooth.TempContact__r.LastName__c; 
                    /*Changes Regarding BK-3250 */
                    oObjCon.Email = oBooth.TempContact__r.Email__c;
                    oObjCon.MobilePhone = oBooth.TempContact__r.MobilePhone__c;
                    if(oBooth.TempContact__r.Phone__c!=null)
                    {
                      oObjCon.Phone = oBooth.TempContact__r.Phone__c;  
                    }
                    /* Ends here */
                    oObjCon.Contact_Type__c = 'Primary Contact';
                    oObjCon.Type__c = sTypeId;
                    if(createAcc != null && createAcc.size()>0){ oObjCon.AccountId = createAcc[0].Id;
                    }
                    else
                    {
                        oObjCon.AccountId = oBooth.TempContact__r.Account__c;
                    }
                    createCon.add(oObjCon);
                    lstTempCon.add(oBooth.TempContact__c);
                }      
            }            
            if(createCon != null && createCon.size()>0 && Schema.sObjectType.Contact.IsCreateable())
            {
                try 
                {
                    insert createCon;  
                    //create a ContactEventEditionMapping__c record for newly approved Contact with User type 'Stand Contractor'
                    List<User_Type__c> lstUsrType=[SELECT Id from User_Type__c WHERE Name='Stand Contractor' LIMIT 1];
                    ContactEventEditionMapping__c oObjConEvntEdtionMap= new ContactEventEditionMapping__c();
                    oObjConEvntEdtionMap.User_Type__c=lstUsrType[0].Id;
                    oObjConEvntEdtionMap.SFContactID__c=createCon[0].Id;
                    oObjConEvntEdtionMap.SFEventEditionID__c=sEventId;
                    insert oObjConEvntEdtionMap;
                } 
                catch(DmlException e) 
                {
                    //return('This Contact already exist in the system so can not be approved.');
                    Database.rollback(sp);
                    return(e.getMessage());
                }
            }
            if(sIdsCon != null && sIdsCon != '')
            {
                List<Contact> lstCon = [SELECT Id, Contact_Type__c, Type__c FROM Contact WHERE Id =: sIdsCon];           
                if(lstCon != null && lstCon.size()>0)
                {
                    for(Contact oUpdateCon : lstCon)
                    {
                        oUpdateCon.Contact_Type__c = 'Primary Contact';
                        oUpdateCon.Type__c = sTypeId;
                        updateCon.add(oUpdateCon);  
                    }
                }
            }
            if(updateCon != null && updateCon.size()>0 && Schema.sObjectType.Contact.isUpdateable())
            {
                Update updateCon;
            }
            for(BoothContractorMapping__c updateBooth: lstBoothConMap)
            {
                if(updateBooth.TempContact__c != null)
                {
                    updateBooth.Contact__c = createCon[0].Id;
                }
                updateBooth.Approved__c = true;
                updateBooth.Status__c = 'Accepted';
                updateBooth.Approval_Date__c=System.now();
                updateBoothmap.add(updateBooth);     
            }
            if(updateBoothmap != null && updateBoothmap.size()>0 &&  Schema.sObjectType.BoothContractorMapping__c.isUpdateable())
            {
                update updateBoothmap;
            }
            if(createCon.size()>0)
            {
                for(Contact oConId : createCon)
                {
                    sConIds.add(oConId.Id);
                }
            }
            if(updateCon.size()>0)
            {
                for(Contact oConId : updateCon)
                {
                    sConIds.add(oConId.Id); 
                }
            }
        }
        //Invitation Email should be send to stand contractor only after the approval is done from ops admin. [CCEN-457]
        string emailtmpCode = 'ISC' ;  
        if(requestedBy == 'opsAdmin'){emailtmpCode = 'OPSISC';
        }
        //CCEN-787 Stand Contractor ... Turn off Designation Email for new users
        //if(String.isNotBlank(sEventId) && sConIds != null && Schema.sObjectType.contact.isAccessible())
        //{
        //    //CreateCommunityUsersCtrl oCreateUser = new CreateCommunityUsersCtrl();
        //    list<contact>listCon = new list<contact>();
        //    listCon = [select id , email from contact where id in :sConIds ];
        //    if(listCon.size() > 0)
        //    {   
        //        if(boothIDs.size()>0)                
        //        {
        //            StandContractorUtils.sendEmailToContractorByCode(sEventId,emailtmpCode,listCon[0],boothIDs);
        //        }                 
        //    }
        //}        
        if(!lstTempAcc.isEmpty())
        {
            DELETE [SELECT Id from TempAccount__c where Id IN:lstTempAcc];
        }
        if(!lstTempCon.isEmpty())
        {
            DELETE [SELECT Id from TempContact__c where Id IN:lstTempCon];
        } 

        return ('Successfully  Approved!');
    }
    //create commuinty user if not eixists For Stand Contractor CCEN-360
    public static void createContractorUser(Id conId,string sEventId)
    {
        list<ContactEventEditionMapping__c> objContactEventEditionMapping = new list<ContactEventEditionMapping__c> ();
        if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible())
        {
            objContactEventEditionMapping = [select id,SFContactID__c,SFEventEditionID__c from ContactEventEditionMapping__c where SFContactID__c =:conId and Status__c= true and SFEventEditionID__c =: sEventId];
        }
        if(objContactEventEditionMapping.isEmpty() || objContactEventEditionMapping.size()<=0 )
        {
            list<User_Type__c> lstUserType = new List<User_Type__c>();
            if(Schema.sObjectType.User_Type__c.isAccessible())
            {
                lstUserType = [select id,name from User_Type__c Where name='Stand Contractor'];
            }            
            if(!lstUserType.isEmpty())
            {
                ContactEventEditionMapping__c newConEveEdtMap = new ContactEventEditionMapping__c();
                newConEveEdtMap.SFContactID__c=conId;
                newConEveEdtMap.SFEventEditionID__c=sEventId;
                newConEveEdtMap.User_Type__c=lstUserType[0].Id;
                if(Schema.sObjectType.ContactEventEditionMapping__c.IsCreateable())
                {
                    insert newConEveEdtMap;
                }                
            } 
        }
        else 
        {
            List<User> users = new List<User>();
            if(Schema.sObjectType.User.isAccessible())
            {
                users=[Select Id,Contact.Type__c,ContactId,Contact.name,Contact.email,IsActive,IsPortalEnabled from User where ContactId =:conId and IsPortalEnabled=true And Profile.Name=:UtilityMethods.getProfileid().Name];
            }            
            List<User> inActiveUserList = new List<User>();
            if(!users.isEmpty())
            {
                for(User usr: users) 
                {
                    if(!usr.IsActive)
                    {
                        usr.IsActive=true; //Set inactive user as active
                        inActiveUserList.Add(usr);
                    }
                }
                if(!inActiveUserList.isEmpty() && Schema.sObjectType.User.isUpdateable())
                {
                    update inActiveUserList; 
                }
            }
            else
            {   
                if(objContactEventEditionMapping.size()>0)
                {                     
                    //Batch class to create community user  [CCEN-585]                    
                    set<Id> conEEEmIds = new set<Id>();
                    conEEEmIds.add(objContactEventEditionMapping[0].Id); //objContactEventEditionMapping Send Id as Pram 
                    BatchCreateCommunityUsers objbatch= new BatchCreateCommunityUsers(conEEEmIds,UtilityMethods.getProfileid().Id);
                    Database.executeBatch(objbatch,1); 
                }                
            }
        }
    }
    // get Single Stand Design Data
    public static list<Stand_Design__c> getSingleStandDesign(String boothId,String accId,string sEventId,string agentId) 
    {
        list<Stand_Design__c> lstDesign=  new  list<Stand_Design__c>();        
        if(Schema.sObjectType.Stand_Design__c.isAccessible() && Schema.sObjectType.DesignAttachmentType__c.isAccessible())
        {
            if(string.isBlank(agentId))
            {
                lstDesign = [select Id, AttachmentId__c, BoothContractorMapping__c, Booth_Design_Status__c,Contractor_Agreement_CA__c, File_Name__c, Stand_Type__c, Submitted_to_Venue_On__c,Signatory_Name__c,(select id,name,CreatedDate, AttachmentId__c,File_Name__c,File_Type__c,IsRejected__c from DesignAttachmentTypes__r) from Stand_Design__c where Account__c=:accID and Opp_Booth_Mapping__c =: boothID And (Event_Edition__c =:sEventId OR Event_Edition__r.Event_Code__c =:sEventId) limit 1];
            }
            else 
            {
                lstDesign = [select Id, AttachmentId__c, BoothContractorMapping__c, Booth_Design_Status__c, Contractor_Agreement_CA__c, File_Name__c, Stand_Type__c, Submitted_to_Venue_On__c,Signatory_Name__c,(select id,name,CreatedDate,AttachmentId__c,File_Name__c,File_Type__c,IsRejected__c from DesignAttachmentTypes__r ) from Stand_Design__c where Account__c=:accID and Agent_Account__c=:agentId And (Event_Edition__c =:sEventId OR Event_Edition__r.Event_Code__c =:sEventId) limit 1];           
            }
        }
        return lstDesign;
    }
    // get Single Stand Detail Data
    public static list<Stand_Detail__c> getSingleStandDetail(String boothId,String accId,string sEventId,string agentId)
    {
        List<Stand_Detail__c> lstStndDtails= new List<Stand_Detail__c>();
        if(Schema.sObjectType.Stand_Detail__c.isAccessible())
        {
            if(string.isBlank(agentId))
            {
                lstStndDtails=[SELECT Id,ExpocadBooth__c,Opp_Booth_Mapping__c,ExpocadBooth__r.Booth_Number__c,ExpocadBooth__r.Dimensions__c,Stand_Height__c,Is_One_side_open_stand__c,Is_Two_side_open_stand__c,Is_Three_side_open_stand__c,Island_Booth_4_sides__c,IsRigging__c,Rigging_Height__c,IsDoubleDecker__c,Riggering_Options__c, Is_Heavy_Machinery__c,Open_Side__c,Amount__c,Receipt__c,IsReceived__c ,Require_Early_Access__c,Early_Access_Date_Time__c,Early_Access_Cost__c,Is_Vehicles__c from Stand_Detail__c where Account__c=:accId AND Opp_Booth_Mapping__c=:boothId  And (Event_Edition__c =:sEventId OR Event_Edition__r.Event_Code__c =:sEventId) ORDER BY CreatedDate limit 1]; 
            }
            else 
            {
                lstStndDtails=[SELECT Id,ExpocadBooth__c,Opp_Booth_Mapping__c,ExpocadBooth__r.Booth_Number__c,ExpocadBooth__r.Dimensions__c,Stand_Height__c, Is_One_side_open_stand__c,Is_Two_side_open_stand__c,Is_Three_side_open_stand__c, Island_Booth_4_sides__c,IsRigging__c,Rigging_Height__c,IsDoubleDecker__c,Riggering_Options__c, Is_Heavy_Machinery__c,Open_Side__c,Amount__c,Receipt__c,IsReceived__c ,Require_Early_Access__c,Early_Access_Date_Time__c,Early_Access_Cost__c,Is_Vehicles__c from Stand_Detail__c where Account__c=:accId and Agent_Account__c=:agentId And (Event_Edition__c =:sEventId OR Event_Edition__r.Event_Code__c =:sEventId) ORDER BY CreatedDate limit 1];
            }
        }                                      
        return lstStndDtails;
    }
  
    //Fetch Stand Details
    public static Map<String,Stand_Detail__c> getAllStandDetail(string sEventcode)
    {
        Map<String,Stand_Detail__c> mapAccStndDetail=new Map<String,Stand_Detail__c>();
        list<Stand_Detail__c> listSDetail =new list<Stand_Detail__c>();
        if(Schema.sObjectType.Stand_Detail__c.isAccessible()) // Added LastModifiedDate in query C2E-8
        {
            listSDetail=[SELECT id,Account__c,Riggering_Options__c,Amount__c,IsReceived__c,Early_Access_Date_Time__c,Early_Access_Cost__c,Require_Early_Access__c,Opp_Booth_Mapping__c,ExpocadBooth__c,Booth_Detail_Status__c,IsRigging__c,IsDoubleDecker__c,Contractor_Agreement_CA__c, Is_Heavy_Machinery__c,LastModifiedDate,Stand_Height__c, Rigging_Height__c,Is_Vehicles__c FROM Stand_Detail__c WHERE Account__c !=null AND Opp_Booth_Mapping__c!=null and Opp_Booth_Mapping__r.Event_Code__c=:sEventcode]; 
        }
        if(listSDetail!=null && !listSDetail.IsEmpty())
        {
            for(Stand_Detail__c objSDtail:listSDetail)
            {
                String key=string.valueOf(objSDtail.Account__c)+'_'+string.valueOf(objSDtail.Opp_Booth_Mapping__c);
                if(!mapAccStndDetail.containsKey(key))
                {
                    mapAccStndDetail.put(key,objSDtail);
                }
            }
        }
        return mapAccStndDetail;
    }

    //Fetch Stand Design
    public static Map<String,Stand_Design__c> getAllStandDesign(string sEventcode)
    {
        Map<String,Stand_Design__c> mapAccStndDesign=new Map<String,Stand_Design__c>();
        list<Stand_Design__c> listSDsign =new list<Stand_Design__c>();
        if(Schema.sObjectType.Stand_Design__c.isAccessible())
        {
            listSDsign=[SELECT id,Account__c,ExpocadBooth__c,Opp_Booth_Mapping__c,Booth_Design_Submitted_On__c,Submitted_to_Venue_On__c,Contractor_Agreement_CA__c, Booth_Design_Status__c
                        FROM Stand_Design__c WHERE Account__c !=null AND Opp_Booth_Mapping__c!=null and Opp_Booth_Mapping__r.Event_Code__c=:sEventcode];
        }
        if(listSDsign!=null && !listSDsign.IsEmpty())
        {
            for(Stand_Design__c objSDsign:listSDsign)
            {
                String key=string.valueof(objSDsign.Account__c)+'_'+string.valueof(objSDsign.Opp_Booth_Mapping__c);
                if(!mapAccStndDesign.containsKey(key))
                {
                    mapAccStndDesign.put(key,objSDsign);   
                }                    
            }
        }
        return mapAccStndDesign;
    }

    // To get maping all booths and there design / detail status from account Id
    public static map<string,list<BoothContractorMapping__c>> getBoothsMappingFromAccId(String sEventcode,string accId)
    {  
        set<id> boothids= new set<id>();        
        map<string,list<BoothContractorMapping__c>> mapBooths = new map<string,list<BoothContractorMapping__c>>();
        for(Opportunity_ExpoCAD_Booth_Mapping__c sBooth :  StandContractorUtils.getCustomerBooths(accId,sEventcode)) // Expocad Change [CCEN-742]
        {
            list<BoothContractorMapping__c> obj= new list<BoothContractorMapping__c>();
            //mapBooths.put(sBooth.Booth_Number__c+'_$_'+sBooth.Id,obj);
            mapBooths.put(sBooth.Booth_Number__c+'_$_'+sBooth.Id+'_$_'+sBooth.Expocad_Booth__r.Matched_Product_Name__c,obj); 
            boothids.add(sBooth.Id);
        }

        //Fetch Stand Details
        Map<String,Stand_Detail__c> mapAccStndDetail = StandContractorUtils.getAllStandDetail(sEventcode);

        //Fetch Stand Designs
        Map<String,Stand_Design__c> mapAccStndDesign = StandContractorUtils.getAllStandDesign(sEventcode);
        // Added Createdby.ContactId for [STL-282]
        for(BoothContractorMapping__c sBoothMap :  [select Id,Agent_Contact__c,Booth_Detail_Status__c,IsManagedbyAgent__c,ExpocadBooth__c,Opp_Booth_Mapping__c,Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c,Opp_Booth_Mapping__r.Booth_Number__c,TempContact__r.TempAccount__r.Name,TempContact__c,TempContact__r.Account__r.Name,TempContact__r.Name__c,Contact__c,Contact__r.Name,contact__r.AccountId,Contact__r.Account.Name,ContractorRequestStatus__c,Booth_Design_Status1__c,Booth_Detail_Status1__c,Is_Self_Managed__c,createdDate,Createdby.Name, Createdby.ContactId, Createdby.Profile.Name, Createdby.Id,lastModifiedDate,lastModifiedBy.name,(select Id,ContractorService__r.Contractor_Service__c from CustomerContractorServices__r)  from BoothContractorMapping__c where Opp_Booth_Mapping__c in :boothids and Event_Edition__r.Event_Code__c =:sEventcode and Parent_BoothMapping__c='' limit 1000])
        {   
            string sKey=sBoothMap.Opp_Booth_Mapping__r.Booth_Number__c+'_$_'+sBoothMap.Opp_Booth_Mapping__c+'_$_'+sBoothMap.Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c;
            if(mapBooths.containsKey(sKey))
            {
                list<BoothContractorMapping__c> lstmap = mapBooths.get(sKey);
                string boothKey=string.valueof(sBoothMap.contact__r.AccountId)+'_'+string.valueof(sBoothMap.Opp_Booth_Mapping__c);

                //Check Stand Details Status
                if(mapAccStndDetail.containsKey(boothKey))
                {
                    sBoothMap.Booth_Detail_Status1__c=  sBoothMap.Booth_Detail_Status__c ;//mapAccStndDetail.get(boothKey).Booth_Detail_Status__c;
                }
                else
                {
                    sBoothMap.Booth_Detail_Status1__c='Not Submitted';//Set default status 
                }

                //Check Stand Design Status
                if(mapAccStndDesign.containsKey(boothKey))
                {
                    sBoothMap.Booth_Design_Status1__c = mapAccStndDesign.get(boothKey).Booth_Design_Status__c;
                }
                else{
                    sBoothMap.Booth_Design_Status1__c='No Design'; //Set default status 
                }
                lstmap.add(sBoothMap); 
                mapBooths.put(sKey,lstmap);  
            } 
        } 
        return mapBooths;
    }
}