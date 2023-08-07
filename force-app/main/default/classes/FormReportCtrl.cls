/**
* Created/Modified By    : Girikon(Mahesh)
* Created On             : 29 May 2018
* @description           : Using for Excel Report Export from Form Builder 
* Test Class             : FormReportCtrl_Test 
* Code Coverage          : 80%

* Modification Log----- RKY BK-10852/50
* Modified by            :Girikon (Mahesh)[CCEN-480 (Nov 22 2018), CCEN-523 (Dec 7 2018),CCEN-569(Dec 19 2018),CCEN-673(Feb 22 2019)], Girikon(Prashant)[CCEN-597(Jan 10 2019), Aishwarya[CCEN-735 April 3 2019], Mukesh (change siteurl fetching code, line 30.),[Aishwarya 31 Aug 2020 BK-6577]]
**/
public without sharing class FormReportCtrl 
{
    Public Map<String,map<string,Question_Response__c>> questAnsMap {get;set;}
    public Map<String,String> userMap{get;set;}
    public Map<String,String> accMap{get;set;}
    public Map<String,String> lstKeys{get;set;}
    public Map<String,String >expoBoothStandType{get;set;}
    public Map<String,String> expoBoothStandNumber{get;set;}
    public set<String> ranksList{get;set;}
    
    public string extrnalSiteURl{get;set;}
    public Map<String,String> encrptAttVal{get;set;}
    public Map<String,String> linkedDocsMaps{get;set;}
    Public FormReportCtrl()
    {   
        extrnalSiteURl = System.URL.getSalesforceBaseUrl().toExternalForm();
        //if(!Test.isRunningTest())
        //{
        Network myNetwork = [SELECT Id FROM Network WHERE Name ='Customer Centre' ];
        System.debug('myNetwork ' + myNetwork);
        extrnalSiteURl = Network.getLoginUrl(myNetwork.id);
        extrnalSiteURl = extrnalSiteURl.replace('/UserLogin','').trim(); 
        // }              
        encrptAttVal = new Map<String,String>();
        linkedDocsMaps = new Map<string,string>();
        userMap = new Map<String,String>();
        accMap = new Map<String,String>();
        expoBoothStandType = new Map<String,String>();
        expoBoothStandNumber = new Map<String,String>();
        String qid = ApexPages.currentPage().getParameters().get('formId');
        //Added this regarding Ticket [CCEN-480] 
        String evntCode = ApexPages.currentPage().getParameters().get('EveId');
        List<Question_Questionnaire__c> quest = new List<Question_Questionnaire__c>();
        if(Schema.sObjectType.Question_Questionnaire__c.isAccessible())
        {   
            quest = [SELECT Question__c, Question__r.Label__c,Question_Group__r.Sort_Order__c,Question_Order__c,Related_To_Column__c FROM Question_Questionnaire__c 
                     WHERE Questionnaire__c=:qid AND is_Delete__c=false AND Question__r.Type__c!='Information' AND Question__r.Type__c!='Header/Footer' AND 
                     Question__c!=null ORDER BY Question_Group__r.Sort_Order__c,Related_To_Column__c,Question_Order__c ASC];
        }   
        lstKeys = new Map<String,String>();
        List<ID> idSet=new List<Id>();
        For(Question_Questionnaire__c quest2 :quest)
        {
            if(quest2.Question__r.Label__c!='')
            {
                idSet.add(quest2.Question__c);
                lstKeys.put(quest2.Question__c,quest2.Question__r.Label__c);
            }
        }     
        
        ranksList = new set<string>();
        ranksList.addAll(lstKeys.keySet());  
        
        questAnsMap=new map<String, map<string,Question_Response__c>>();
        List<String> qstnAns=new List<String>();
        // Added inner Query for related Attachments [CCEN-597]
        Transient List<Question_Response__c> questAns = new List<Question_Response__c>();
        if(Schema.sObjectType.Question_Response__c.isAccessible())
        {
            questAns = [Select id,Answer__c,Question__c,Question__r.Label__c,Question__r.Type__c,Question__r.Allow_Attachments__c,User__c,User__r.Account.Name,User__r.Contact.Email,User__r.AccountId,(SELECT Id, ShareType,ContentDocumentId,ContentDocument.LatestPublishedVersion.Id,LinkedEntityId, ContentDocument.Title, ContentDocument.ContentSize FROM ContentDocumentLinks) from Question_Response__c where User__r.AccountId != null AND Question__c  in : idSet ORDER BY  Question_Questionnaire__r.Question_Group__c,Question__c ASC]; 
        }
        System.debug('QuestAns ' +questAns);     
        set<id> accountId= new set<id>();
        set<ID> questionResponsec = new set<ID>();
        Map<Id,Id> linkedDocsMap = new Map<Id,Id>();
        for(Question_Response__c questRes: questAns)
        {
            questionResponsec.add(questRes.Id);
            if(questRes.ContentDocumentLinks.size()>0  || questRes.Answer__c!=null) //-Reagrding ticket CCEN-673 
            {
                accountId.add(questRes.User__r.AccountId);
                expoBoothStandType.put(questRes.User__r.AccountId,'');
                expoBoothStandNumber.put(questRes.User__r.AccountId,'');   
            }
            for(ContentDocumentLink att:questRes.ContentDocumentLinks)
            {
                linkedDocsMap.put(att.ContentDocumentId,att.ContentDocument.LatestPublishedVersion.Id);     
            }
        }
        set<id> contentversionId= new set<id>();
        set<ID> vcid = new set<ID>();
        system.debug('linkedDocsMap.keySet()' + linkedDocsMap.keySet());
        system.debug('questionResponsec' + questionResponsec);
        if(!questionResponsec.isEmpty()){
            List<ContentDocumentLink>  sContentDocumentLink= new List<ContentDocumentLink>([SELECT id,contentDocument.title, contentDocumentid FROM ContentDocumentLink WHERE LinkedEntityId =:questionResponsec and contentDocumentid IN:linkedDocsMap.keySet()]);
            system.debug('sContentDocumentLink' + sContentDocumentLink);
            for(ContentDocumentLink sd :sContentDocumentLink){
                vcid.add(sd.contentDocumentid);
            }
        }
        system.debug('vcid-->:' + vcid);
        if(!vcid.isEmpty())
        {
            List<ContentVersion> ContentVersionss = new List<ContentVersion>([SELECT PathOnClient,Title,Description,VersionData,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =:vcid] );
            system.debug('ContentVersionss-->:' + ContentVersionss);
            for(ContentVersion attContentVersion :ContentVersionss)
            {
                contentversionId.add(attContentVersion.id);
            }
        }
        system.debug('contentversionId' + contentversionId);
        system.debug('linkedDocsMap.keySet()' + linkedDocsMap.keySet());
        List<ContentDistribution> idToExternalURL = new List<ContentDistribution>([SELECT Id, DistributionPublicUrl,ContentDocumentId,ContentVersionId FROM ContentDistribution where ContentDocumentId in:linkedDocsMap.keySet() and ContentVersionId =:contentversionId]);  
        system.debug('idToExternalURL' + idToExternalURL);
        for(ContentDistribution sCoDi: idToExternalURL){
            if(!linkedDocsMaps.containsKey(sCoDi.ContentDocumentId)){
                linkedDocsMaps.put(sCoDi.ContentDocumentId, sCoDi.DistributionPublicUrl);
                system.debug('linkedDocsMaps' + linkedDocsMaps);
            }
        }
        system.debug('linkedDocsMaps' + linkedDocsMaps);
        Map<string,string> linkedDocsMapURL = new Map<string,string>();
        for(Question_Response__c questRes: questAns)
        {
            for(ContentDocumentLink att:questRes.ContentDocumentLinks)
            {
                system.debug('linkedDocsMaps.containsKey(att.ContentDocumentId)' + linkedDocsMaps.containsKey(att.ContentDocumentId));
                if(linkedDocsMaps.containsKey(att.ContentDocumentId)){
                    encrptAttVal.put(att.ContentDocumentId,linkedDocsMaps.get(att.ContentDocumentId));
                }
                if(!linkedDocsMaps.containsKey(att.ContentDocumentId)){
                    encrptAttVal.put(att.ContentDocumentId,'No Url link');
                  }
            }
        }
        system.debug('linkedDocsMapURL' + linkedDocsMapURL);
        system.debug('encrptAttVal' + encrptAttVal);
        /* CCEN-735 changes corresponding to expocad new object start*/
        if(evntCode!=null && evntCode!='')
        {
            //[CCEN-523] Added condition for Status.
            for(Opportunity_ExpoCAD_Booth_Mapping__c expoBooth: [Select Id, Booth_Number__c, Expocad_Booth__r.Matched_Product_Name__c, Opportunity__r.Accountid, Expocad_Booth__r.User__c, Event_Code__c, Expocad_Booth__r.Status__c FROM Opportunity_ExpoCAD_Booth_Mapping__c 
                                                                 WHERE Opportunity__r.Accountid IN: accountId AND Expocad_Booth__r.Status__c='Rented' AND (Opportunity__r.StageName='Closed Won' OR Opportunity__r.StageName='Closed Booked') AND Event_Code__c=:evntCode AND Status__c ='Active'])
            {
                //Added condition for [CCEN-569] 
                if(string.isnotBlank(expoBooth.Expocad_Booth__r.Matched_Product_Name__c)) 
                {
                    if(expoBoothStandType.get(expoBooth.Opportunity__r.Accountid)!='')
                    {
                        expoBoothStandType.put(expoBooth.Opportunity__r.Accountid, expoBoothStandType.get(expoBooth.Opportunity__r.Accountid)+','+expoBooth.Expocad_Booth__r.Matched_Product_Name__c);
                    }
                    else
                    {
                        expoBoothStandType.put(expoBooth.Opportunity__r.Accountid,expoBooth.Expocad_Booth__r.Matched_Product_Name__c);
                    }
                }
                /* CCEN-735 changes corresponding to expocad new object start*/  
                
                if(string.isnotBlank(expoBooth.Booth_Number__c) ) 
                {
                    if(expoBoothStandNumber.get(expoBooth.Opportunity__r.Accountid)!=''){
                        expoBoothStandNumber.put(expoBooth.Opportunity__r.Accountid, expoBoothStandNumber.get(expoBooth.Opportunity__r.Accountid)+','+expoBooth.Booth_Number__c); 
                    }
                    else{
                        expoBoothStandNumber.put(expoBooth.Opportunity__r.Accountid,expoBooth.Booth_Number__c);
                    }
                }      
            }
        }
        Transient Map<String,Question_Option__c> optionMap = new Map<String,Question_Option__c>([SELECT Id, Name FROM Question_Option__c WHERE Name!='Checked' AND Name!='Unchecked']);
        String tempstr='';
        
        for(Question_Response__c qR:questAns)
        {
            if(optionMap.containsKey(qR.Answer__c))
            {
                qR.Answer__c = optionMap.get(qR.Answer__c).Name; 
            }
            if(qR.ContentDocumentLinks.size()>0 || qR.Answer__c != null){
                accMap.put(qR.User__r.AccountId,qR.User__r.Account.Name);
                userMap.put(qR.User__r.AccountId,qR.User__r.Contact.Email);
            }
            if(accountId.contains(qR.User__r.AccountId))
            {
                if(questAnsMap.containsKey(qR.User__r.AccountId))
                {
                    if(lstKeys.containsKey(qR.Question__c))
                    {
                        map<string,Question_Response__c> objmap = questAnsMap.get(qR.User__r.AccountId);
                        objmap.put(qR.Question__c,qR);
                        questAnsMap.put(qR.User__r.AccountId,objmap);
                    }                    
                }   
                else
                {                    
                    map<string,Question_Response__c> objmap = new map<string,Question_Response__c>();
                    objmap.put(qR.Question__c,qR);
                    questAnsMap.put(qR.User__r.AccountId,objmap);                                       
                }                
            }  
            
        }
        
        //validating Data For CSV 
        for(string aCCID : questAnsMap.keySet())
        {
            map<string,Question_Response__c> objmap = new map<string,Question_Response__c>();
            objmap = questAnsMap.get(aCCID);
            
            for(string key:lstKeys.keySet())
            {   
                if(!objmap.containsKey(key) || Test.isRunningTest())
                {                   
                    Question_Response__c qR = new Question_Response__c();
                    objmap.put(key,qR);
                    questAnsMap.put(aCCID,objmap);
                }
            }
        }        
        system.debug('questAnsMap==='+questAnsMap);
    }
}