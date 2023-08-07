/**
 * Created By   : Girikon(Sunil) 
 * Created On   : 04/11/2018
 * @description : This class provides following functionalities:
 *                Allow contractor to accept or reject the exhibitors request, upload stand design and details.
 * Helper Class : UtilityMethods
 * Test Class   : MyExhibitorsCtrl_Test(84%)
 *
 * Modification Log----- Girikon(Prashant)[CCEN-315 (Sept 24 2018), CCEN-656 (Feb 4 2019)],Girikon(Sunil)[CCEN-335 (Oct 4 2018)],Girikon(Ashish)[CCEN-412 (Nov 11 2018),CCEN-355 (Nov 15 2018)
 * Modified by : CCEN-699 (march 5 2019),CCEN-742 (April 3 2019 ),CCEN-754 (April 10 2019 ), Aishwarya BK-4682 June 7 2020], [Aishwarya BK-15540 Apr 29 2021],[Aishwarya BK-17609 10 Aug 2021]
 **/
public without sharing class MyExhibitorsCtrl 
{    
    @AuraEnabled //Fetch event details 
    public static Event_Settings__c getEventDetails(String sEventcode) 
    {
        return UtilityMethods.getEventDetails(sEventcode); 
    }
    @AuraEnabled //Fetch Exhibitors 
    public static list<BoothContractorMapping__c> getExhibitors(String sEventcode) // Expocad Change [CCEN-742]
    {
        User usr = new User();
        if(Schema.sObjectType.User.isAccessible())
        {
            usr = [SELECT Id, Contactid,Accountid  
                   FROM User 
                   WHERE Id = : UserInfo.getUserId()]; 
        }
        list<BoothContractorMapping__c> lstboothmap= new  list<BoothContractorMapping__c>();
        //Check is class runnig for test
        If(Test.isRunningTest() && Schema.sObjectType.BoothContractorMapping__c.isAccessible())
        {
            //Fetch Exhibitors
            lstboothmap =  [Select Id,contact__r.AccountId,Opp_Booth_Mapping__c,ExpocadBooth__c,ExpocadBooth__r.Opportunity__r.Account.Name,ExpocadBooth__r.Booth_Number__c,ExpocadBooth__r.Display_Name__c, Booth_Detail_Status__c, Booth_Design_Status__c,ContractorRequestStatus__c,Amount__c ,Createdby.Contact.Account.Name,(select Id,ContractorService__r.Contractor_Service__c from CustomerContractorServices__r),(SELECT Id, TempContact__r.Name__c FROM BoothContractorMappings__r),Paid_Status__c,EAC_Fees__c  
                            From BoothContractorMapping__c  
                            Order by createddate desc 
                            Limit 100];
        }
        else
        {
            //Fetch Exhibitors            
            lstboothmap = [Select Id,contact__r.AccountId,ExpocadBooth__c,Opp_Booth_Mapping__c,Opp_Booth_Mapping__r.Opportunity__r.Account.Name,Opp_Booth_Mapping__r.Booth_Number__c,Opp_Booth_Mapping__r.Display_Name__c, Booth_Detail_Status__c, Booth_Design_Status__c,ContractorRequestStatus__c,Amount__c,Event_Edition__r.Event_Code__c ,Createdby.Contact.Account.Name,(select Id,ContractorService__r.Contractor_Service__c from CustomerContractorServices__r),(SELECT Id, TempContact__r.Name__c FROM BoothContractorMappings__r),Paid_Status__c,EAC_Fees__c 
                           From BoothContractorMapping__c  
                           Where contact__c=:usr.Contactid 
                           And Opp_Booth_Mapping__r.Opportunity__c!= NULL 
                           And Opp_Booth_Mapping__r.Status__c = 'Active' 
                           And Opp_Booth_Mapping__r.Expocad_Booth__r.status__c = 'Rented' 
                           And IsManagedbyAgent__c = FALSE 
                           And Approved__c = TRUE 
                           And Event_Edition__r.Event_Code__c =:sEventcode
                           Order by createddate desc 
                           Limit 100 ];
        }
        //Fetch Stand Details
        Map<String,Stand_Detail__c> mapAccStndDetail = StandContractorUtils.getAllStandDetail(sEventcode);
        
        //Fetch Stand Designs
        Map<String,Stand_Design__c> mapAccStndDesign = StandContractorUtils.getAllStandDesign(sEventcode);
        for(BoothContractorMapping__c boothMap : lstboothmap)
        {
            string boothKey=string.valueof(boothMap.contact__r.AccountId)+'_'+string.valueof(boothMap.Opp_Booth_Mapping__c); //Expocad Change CCEN- 754

            //Check Stand Details Status
            if(mapAccStndDetail.containsKey(boothKey))
            {
                boothMap.Booth_Detail_Status1__c= boothMap.Booth_Detail_Status__c ; //mapAccStndDetail.get(boothKey).Booth_Detail_Status__c;
            }
            else
            {
                boothMap.Booth_Detail_Status1__c='Not Submitted';//Set deafult status 
            }
            //Check Stand Design Status
            if(mapAccStndDesign.containsKey(boothKey))
            {
                boothMap.Booth_Design_Status1__c=mapAccStndDesign.get(boothKey).Booth_Design_Status__c;
            }
            else
            {
                boothMap.Booth_Design_Status1__c='No Design'; //Set deafult status 
            }
        }

        return lstboothmap;
    }
    /* fatch Agents   [CCEN-432] */ 
     @AuraEnabled  
    public static list<BoothContractorMapping__c> getAgents(String sEventcode)
    {
        User usr = [SELECT Id, Contactid,Accountid  
                    FROM User 
                    WHERE Id = : UserInfo.getUserId()]; 
        list<BoothContractorMapping__c> lstboothmap= new  list<BoothContractorMapping__c>();
        //Check is class runnig for test
        If(Test.isRunningTest() && Schema.sObjectType.BoothContractorMapping__c.isAccessible() && Schema.sObjectType.CustomerContractorService__c.isAccessible()){
            //Fetch Agents
             lstboothmap =  [Select Id,contact__r.AccountId,ExpocadBooth__c,ExpocadBooth__r.Opportunity__r.Account.Name,ExpocadBooth__r.Booth_Number__c,ExpocadBooth__r.Display_Name__c, Booth_Detail_Status__c, Booth_Design_Status__c,ContractorRequestStatus__c,Amount__c ,Createdby.Contact.Account.Name,(select Id,ContractorService__r.Contractor_Service__c from CustomerContractorServices__r),(SELECT Id, TempContact__r.Name__c FROM BoothContractorMappings__r),Paid_Status__c,EAC_Fees__c
                             From BoothContractorMapping__c  
                             order by createddate desc 
                             Limit 100];
        }
        else{
            //Fetch Agents
            lstboothmap = [select Id,contact__r.AccountId,ExpocadBooth__c,ExpocadBooth__r.Opportunity__r.Account.Name,ExpocadBooth__r.Booth_Number__c,ExpocadBooth__r.Display_Name__c, Booth_Detail_Status__c, Booth_Design_Status__c,
            Agent_Contact__c,Agent_Contact__r.Name,Agent_Contact__r.Account.Id,Agent_Contact__r.Account.Name,
            ContractorRequestStatus__c,Amount__c,Event_Edition__r.Event_Code__c ,Createdby.Contact.Account.Name,(select Id,ContractorService__r.Contractor_Service__c from CustomerContractorServices__r),(SELECT Id, TempContact__r.Name__c FROM BoothContractorMappings__r),Paid_Status__c,EAC_Fees__c  
                           From BoothContractorMapping__c 
                           Where contact__r.Account.Id =: usr.Accountid 
                           And IsManagedbyAgent__c = TRUE 
                           And ExpocadBooth__c = null 
                           And Approved__c = TRUE 
                           And Event_Edition__r.Event_Code__c =:sEventcode 
                           Order by createddate desc 
                           Limit 100 ];
        }      
        return lstboothmap;
    }
    /*  */

    @AuraEnabled //Fetch Stand Detail
    public static Stand_Detail__c getStandDetail(String boothId,String accId,string eventCode,string agentId)
    {
        //Added Is_Vehicles__c field in query for [CCEN-315]
        //Added Amount__c field in query for [CCEN-355]
         Stand_Detail__c standDetail= new Stand_Detail__c();
        list<Stand_Detail__c> lststand= new  list<Stand_Detail__c>();

        lststand = StandContractorUtils.getSingleStandDetail(boothId,accId,eventCode,agentId);  //Expocad Change CCEN- 754
        if(lststand.size()>0) 
        {
            standDetail = lststand[0];
        }      
        return standDetail;      
    } 
    @AuraEnabled //Fetch Stand Design 
    public static Stand_Design__c getStandDesign(String boothId,String accId,string eventCode,string agentId) 
    { 
        Stand_Design__c standDesign= new Stand_Design__c();

        list<Stand_Design__c> lstDesign=  new  list<Stand_Design__c>(); 
        
        if(string.isBlank(agentId) && Schema.sObjectType.Stand_Design__c.isAccessible() && Schema.sObjectType.DesignAttachmentType__c.isAccessible())
        {
            lstDesign = [Select Id, AttachmentId__c, BoothContractorMapping__c, Booth_Design_Status__c, Contractor_Agreement_CA__c, File_Name__c, Stand_Type__c, Submitted_to_Venue_On__c,Signatory_Name__c,(select id,name, AttachmentId__c,File_Name__c,File_Type__c,IsRejected__c from DesignAttachmentTypes__r where IsRejected__c=false) 
                         From Stand_Design__c 
                         Where Is_Rejected__c=false 
                         And Account__c=:accID 
                         And Opp_Booth_Mapping__c =: boothID];
        }
        else 
        {
            lstDesign = [Select Id, AttachmentId__c, BoothContractorMapping__c, Booth_Design_Status__c,Contractor_Agreement_CA__c, File_Name__c, Stand_Type__c, Submitted_to_Venue_On__c,Signatory_Name__c,(select id,name, AttachmentId__c,File_Name__c,File_Type__c,IsRejected__c from DesignAttachmentTypes__r where IsRejected__c=false) 
                         From Stand_Design__c 
                         Where Is_Rejected__c=false 
                         And Account__c=:accID 
                         And Agent_Account__c=:agentId 
                         And Event_Edition__r.Event_Code__c =:eventCode];           
        }             
        //lstDesign = StandContractorUtils.getSingleStandDesign(boothId,accId,eventCode,agentId);
        if(lstDesign.size()>0) 
        {
            standDesign = lstDesign[0];
        }
        return standDesign;       
    }  

    @AuraEnabled //Fetch mapping by id
    public static BoothContractorMapping__c getExhibitorMapbyId(String mapId) 
    {
        list<BoothContractorMapping__c> lstboothmap = new list<BoothContractorMapping__c>();
        lstboothmap =  [Select Id,Agent_Contact__r.AccountId,Event_Edition__c,ExpocadBooth__c,Opp_Booth_Mapping__c,Opp_Booth_Mapping__r.Booth_Number__c,Contact__c,Opp_Booth_Mapping__r.Opportunity__r.Account.Name,Opp_Booth_Mapping__r.Expocad_Booth__r.Open_Corners__c,Opp_Booth_Mapping__r.Expocad_Booth__r.Dimensions__c,ContractorRequestStatus__c,Stand_Height__c,Is_One_side_open_stand__c,Is_Two_side_open_stand__c,Is_Three_side_open_stand__c,Island_Booth_4_sides__c,IsRigging__c,Rigging_Height__c,IsDoubleDecker__c ,Createdby.Contact.Account.Name,Booth_Design_Status__c,IsAgree__c,Signatory_Name__c,Contact__r.AccountId,Is_Self_Managed__c,(select Id,Stand_Type__c,File_Name__c from Stand_Designs__r)
                        From BoothContractorMapping__c 
                        Where id=:mapId ];
        return lstboothmap[0];
    }
    @AuraEnabled //Fetch contractor booth
    public static list<BoothContractorMapping__c> updateStatus(String sEventcode,String mapId,String status)
    {
        list<BoothContractorMapping__c> lstboothmap = [select Id,Status__c from BoothContractorMapping__c where Id =:mapId]; 
        if(lstboothmap.size()>0)
        {
            lstboothmap[0].ContractorRequestStatus__c=status;
            if(status=='Accepted')
            {
                map<string,string> mapProduct = GetProductPriceOnCustomerPortal.getProductDetails(sEventcode); 
                decimal amount=decimal.valueOf(mapProduct.get('Price'));
                lstboothmap[0].Amount__c=amount;
                lstboothmap[0].Product__c= mapProduct.get('ProductID');
                if(amount>0)
                {
                    lstboothmap[0].Paid_Status__c='Pending'; 
                    lstboothmap[0].Status__c='Accepted and Not Paid'; 
                    lstboothmap[0].EAC_Fees__c=true;
                }
                else
                {
                    lstboothmap[0].Paid_Status__c='Paid'; 
                    lstboothmap[0].Status__c='Accepted'; 
                    lstboothmap[0].EAC_Fees__c=false;
                }   
            }
            else if(status=='Declined')
            {
                lstboothmap[0].Status__c='Rejected'; 
                lstboothmap[0].Amount__c=0.00;
            }
            if(Schema.sObjectType.BoothContractorMapping__c.isUpdateable())
            {
                update lstboothmap;
            }
        }
        return getExhibitors(sEventcode);
    }
    @AuraEnabled //fetch contractor status values
    public static list<string> getContartorStatus()
    { 
        list<string> listState= new list<string>();
        Schema.DescribeFieldResult fieldResult = BoothContractorMapping__c.ContractorRequestStatus__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            listState.add(f.getValue() +'__$__'+ f.getLabel() );
        }
        return listState;
    }
    @AuraEnabled //check contractor read the manuals or not 
    public static boolean checkManuals(String sEventcode,string contactId,string accountId)
    {
        boolean isManualsRead=false;
        Integer counter=0;
        User usr = [SELECT Id, ContactId,Accountid  FROM User WHERE Id = : UserInfo.getUserId()];
        Id accId = string.isNotBlank(accountId)? accountId : usr.Accountid; // [C2E-17]
        Id conId = string.isNotBlank(contactId)? contactId : usr.ContactId; // [C2E-17]
        list<ContactEventEditionMapping__c> objConEvntEdtnMap = new list<ContactEventEditionMapping__c>();
        if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible())
        {
            objConEvntEdtnMap = [select id,User_Type__r.Name from ContactEventEditionMapping__c where SFContactID__c =: conId and SFEventEditionID__r.Event_Code__c =: sEventcode limit 1];
        }
        if(!objConEvntEdtnMap.isEmpty() && Schema.sObjectType.User_Manual_Action__c.isAccessible())
        {
            string userType=objConEvntEdtnMap[0].User_Type__r.Name; 
            list<User_Manual_Action__c> lstUserManualAction=[SELECT Is_Viewed__c, Is_Agree__c,Id,Manual_Permission__r.Manuals__r.Deadline__c,Manual_Permission__r.Manuals__r.Required__c,Manual_Permission__r.Active__c FROM User_Manual_Action__c
            where Account__c=:accId and Manual_Permission__r.Manuals__r.Event_Edition__r.Event_Code__c =: sEventcode AND Manual_Permission__r.Manuals__r.Required__c=true and User_Type__r.Name =:userType and Manual_Permission__r.Manuals__r.Manual_Type__c!='Link' and ((Manual_Permission__r.Manuals__r.Allow_Submit_After_Deadline__c=true and Manual_Permission__r.Manuals__r.Deadline__c!=null) 
            OR (Manual_Permission__r.Manuals__r.Allow_Submit_After_Deadline__c !=true And Manual_Permission__r.Manuals__r.Deadline__c!=null ) 
            OR(Manual_Permission__r.Manuals__r.Allow_Submit_After_Deadline__c !=true  And Manual_Permission__r.Manuals__r.Deadline__c=null)
            OR(Manual_Permission__r.Manuals__r.Allow_Submit_After_Deadline__c =true  And Manual_Permission__r.Manuals__r.Deadline__c=null)) ];//and Manual_Permission__r.Manuals__r.Allow_Submit_After_Deadline__c=true and Manual_Permission__r.Manuals__r.Deadline__c!=null
            for(User_Manual_Action__c uma : lstUserManualAction){
                if(uma.Is_Viewed__c && uma.Is_Agree__c){
                        counter++;
                    } 
            }
            isManualsRead=counter==lstUserManualAction.size()?true:false;  
        }
           
        return isManualsRead;
    }

    @AuraEnabled //Update or Insert Stand Details
    public static Stand_Detail__c updateStandDetails(Stand_Detail__c standDetail)
    {
        list<Stand_Detail__c> lstStandDetail = new list<Stand_Detail__c>();
        if(!String.isEmpty(standDetail.Agent_Account__c) && !String.isEmpty(standDetail.Event_Edition__c))
        {
            lstStandDetail = [Select id,Account__c 
                              From Stand_Detail__c 
                              Where Account__c = : standDetail.Account__c 
                              And Event_Edition__c=:standDetail.Event_Edition__c 
                              And Agent_Account__c=:standDetail.Agent_Account__c];
        }
        else
        {
            lstStandDetail = [Select id,Account__c 
                              From Stand_Detail__c 
                              Where Account__c = : standDetail.Account__c
                              AND Opp_Booth_Mapping__c =:standDetail.Opp_Booth_Mapping__c]; //BK-17609
                              //And ExpocadBooth__c=:standDetail.ExpocadBooth__c];
        }
        if(!standDetail.IsRigging__c) //CCEN-699
        {
            standDetail.Riggering_Options__c = null;
            standDetail.Rigging_Height__c = null;
        }
        if(lstStandDetail.size()>0 && Schema.sObjectType.Stand_Detail__c.isUpdateable()){
            standDetail.id = lstStandDetail[0].Id;
            update standDetail;//Update Stand Details
        }
        else if(Schema.sObjectType.Stand_Detail__c.IsCreateable()){
            //standDetail.Account__c = usr.AccountId;
            standDetail.id = null;
            insert standDetail; //Insert Stand Details
        }
        
        return standDetail;
    }
    @AuraEnabled //Update Stand Design
    public static void updateStandDesign (Stand_Design__c standdesign )
    {
        update standdesign;  //Update Stand Design
    }
    @AuraEnabled //Delete stand design file(attchamnet)
    public static Boolean deleteFile(String attId,String designRecID)
    {        
        list<ContentDocument> lstCntDocsToDelete = new list<ContentDocument>();
        for(ContentDocumentLink iterator : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:designRecID]) {
            lstCntDocsToDelete.add(new ContentDocument(Id = iterator.ContentDocumentId));
        }
        /***** BK-15540
        if(!lstCntDocsToDelete.isEmpty() && lstCntDocsToDelete != null) {
            Database.delete(lstCntDocsToDelete, false);
            Database.emptyRecycleBin(lstCntDocsToDelete);
        }  ****/
         
        //list<attachment> lstattachment= [Select id From attachment Where parentid=:designRecID];
        list<Stand_Design__c> lstStandDesign = [Select id From Stand_Design__c Where id =:designRecID];
         //delete the stand design record if the deleted file is the only one
        if(lstCntDocsToDelete.size()==1 && Stand_Design__c.sObjectType.getDescribe().isDeletable()) {
            delete lstStandDesign;
        }
        delete [Select Id From ContentDocument Where Id =: attId];
        delete [Select Id  From DesignAttachmentType__c Where AttachmentId__c=:attId];
        return true;
    }
    @AuraEnabled //Save stand design file in chunks
    public static Id saveChunk(Id sMapId,string accountId ,String fileName, String base64Data, String contentType, String fileId, String standType,String boothId,String boothCode,String uploadFileType,string eventId,string agentId)
    {
        if (fileId == '')
        {
            fileId = saveTheFile(sMapId,accountId, fileName, base64Data, contentType,standType,boothId,boothCode,uploadFileType,eventId, agentId);
        } else
        {
            appendToFile(fileId, base64Data);
        }
        return Id.valueOf(fileId);
    }
    //Save stand design file
    public static Id saveTheFile(Id sMapId,string accountId,String fileName, String base64Data, String contentType,String standType,String boothId,String boothCode,String uploadFileType,string eventId,string agentId)
    {
        User usr = [SELECT Id, Contactid,Accountid,Account.Name  FROM User WHERE Id = : UserInfo.getUserId()];
        Id accId = string.isNotBlank(accountId) ? accountId : usr.Accountid;
        Id standDesingid;        
        Opportunity_ExpoCAD_Booth_Mapping__c expocadBoothMaplstStandDesign = new Opportunity_ExpoCAD_Booth_Mapping__c(); //Expocad Change CCEN- 754
        Account agentAccount = new Account();
        //Added Soql query to find Exhibitor Company Name from ExpocadBooth [CCEN-656] 
        if( string.isNotBlank(boothId) && Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible())
        {
            expocadBoothMaplstStandDesign = [Select Opportunity__r.Account.Name 
                                             From Opportunity_ExpoCAD_Booth_Mapping__c 
                                             Where id =: boothId 
                                             Limit 1];
        }
        string exhCompName = '';
        string newExhCompName = '';
        if(string.isNotBlank(agentId) && Schema.sObjectType.Account.isAccessible())        
        {
            agentAccount = [Select id,Name 
                            From Account 
                            Where id =: agentId
                            Limit 1];
            exhCompName = agentAccount.Name;
            newExhCompName = exhCompName.replaceAll('\\s+','_'); 
            newExhCompName = newExhCompName.replaceAll('[,.]','');  
        }
        else
        {
            exhCompName = expocadBoothMaplstStandDesign.Opportunity__r.Account.Name;
            newExhCompName = exhCompName.replaceAll('\\s+','_'); 
            newExhCompName = newExhCompName.replaceAll('[,.]',''); 
        }
        
        list<Stand_Design__c> lstStandDesign = new list<Stand_Design__c>();
        if(!String.isEmpty(agentId))
        {
            lstStandDesign = [Select Id From Stand_Design__c
                              Where Is_Rejected__c=false 
                              And Account__c=:accId 
                              And Event_Edition__c=:eventId 
                              And Agent_Account__c=:agentId];
        }
        else
        {
            lstStandDesign = [Select Id From Stand_Design__c
                              Where  Is_Rejected__c=False 
                              And Account__c=:accId 
                              And Opp_Booth_Mapping__c=:boothId];
        }
        Stand_Design__c standDesign= new Stand_Design__c();
        String finalFileName = boothCode +'_'+newExhCompName+'_'+uploadFileType; 
        if(lstStandDesign.size()>0)
        {
            standDesingid=lstStandDesign[0].Id;
        }
        else
        {   
            standDesign.Event_Edition__c = eventId;
            standDesign.Agent_Account__c = agentId;
            standDesign.BoothContractorMapping__c=sMapId; 
            standDesign.Stand_Type__c =standType; 
            standDesign.File_Name__c=finalFileName+'.pdf';
            standDesign.Account__c= accId;
            standDesign.Opp_Booth_Mapping__c=boothId;
            standDesign.Booth_Design_Status__c= 'No Design';
            if(Schema.sObjectType.Stand_Design__c.isCreateable())
            {
                insert standDesign;
            }            
            standDesingid=standDesign.Id;
        }/* // Showing a version number when uploading two PDF's with the same Attachment label [CCEN-412]*/
        string fileSearchkey = finalFileName+'%';
        list<DesignAttachmentType__c> files = new list<DesignAttachmentType__c>();
        files = [Select id,File_Name__c 
                 From DesignAttachmentType__c
                 Where Stand_Design__c =:standDesingid 
                 And IsRejected__c = false
                 And File_Name__c 
                 like :fileSearchkey 
                 ORDER BY File_Name__c];
        
        Integer fileSize = files.size();
        if(fileSize !=0)
            {
                string val =  files[fileSize-1].File_Name__c;
                val = val.removeStart(finalFileName+'.0');
                val = val.removeEnd('.pdf');
                val = val.removeStart(finalFileName+'.');
                fileSize = Integer.valueOf(val);
            }
        if(fileSize<9)
        {
            finalFileName = finalFileName+'.0'+String.valueOf(fileSize+1)+'.pdf';  
        }else
        {
            finalFileName = finalFileName+'.'+String.valueOf(fileSize+1)+'.pdf'; 
        }

        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');   
        /*Attachment oAttachment = new Attachment();
        oAttachment.parentId = standDesingid;
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = finalFileName;
        oAttachment.ContentType = contentType;
        insert oAttachment;*/
        
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = '/' + finalFileName;//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = UserInfo.getUserId();//Owner of the file
        cVersion.Title = finalFileName;//Name of the file
        cVersion.IsMajorVersion = false;
        cVersion.VersionData = EncodingUtil.base64Decode(base64Data);//File content
        insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = standDesingid;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        DesignAttachmentType__c  newDesignAttachmentType = new DesignAttachmentType__c ();
        newDesignAttachmentType.AttachmentId__c = conDocument;
        newDesignAttachmentType.File_Name__c = finalFileName;
        newDesignAttachmentType.File_Type__c = uploadFileType;
        newDesignAttachmentType.Stand_Design__c = standDesingid;
        if(Schema.sObjectType.DesignAttachmentType__c.IsCreateable())
        {
            insert newDesignAttachmentType;
        }
        return conDocument;
    }
     //Update stand design file
    private static void appendToFile(Id fileId, String base64Data)
    {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        //Attachment a = [SELECT Id, Body FROM Attachment WHERE Id =: fileId];
        //a.Body = EncodingUtil.base64Decode(EncodingUtil.base64Encode(a.Body) + base64Data);
        //update a;
        ContentVersion oContentVersion = [SELECT Id, Title, PathOnClient, VersionData, OwnerId, ContentDocumentId FROM ContentVersion where ContentDocumentId =: fileId  Order By LastModifiedDate Desc];
        String existingBody = EncodingUtil.base64Encode(oContentVersion.VersionData);
        oContentVersion.VersionData =  EncodingUtil.base64Decode(EncodingUtil.base64Encode(oContentVersion.VersionData) + base64Data);
        update oContentVersion;
    }
    @AuraEnabled //fetch open side picklist values.
    public static list<string> getOpenSides()
    { 
        list<string> lstOpenSide= new list<string>();
        Schema.DescribeFieldResult fieldResult = Stand_Detail__c.Open_Side__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            lstOpenSide.add(f.getValue() +'__$__'+ f.getLabel() );
        }   
        return lstOpenSide;
    }
    @AuraEnabled //Fetch Stand Design 
    public static list<Stand_Design_Attachments__c> getStandDesignAttTypes() 
    {
        list<Stand_Design_Attachments__c> lstDesign=  [select Id, Name,Design_Category__c  
                                                       From Stand_Design_Attachments__c 
                                                       Limit 100];
        return lstDesign;
    } 
    // To fetch required manuals for account  [CCEN-335]
    @AuraEnabled 
    public static list<User_Manual_Action__c> fetchReqManuals(String sEventcode,string contactId,string accountId)
    {
        boolean isManualsRead=false;
        Integer counter=0;
        User usr = [SELECT Id, ContactId,Accountid  FROM User WHERE Id = : UserInfo.getUserId()];
        Id accId = string.isNotBlank(accountId)? accountId : usr.Accountid; // [C2E-17]
        Id conId = string.isNotBlank(contactId)? contactId : usr.ContactId; // [C2E-17]
        list<ContactEventEditionMapping__c> objConEvntEdtnMap = [Select id,User_Type__r.Name 
                                                                 From ContactEventEditionMapping__c 
                                                                 Where SFContactID__c =:conId 
                                                                 And SFEventEditionID__r.Event_Code__c =: sEventcode 
                                                                 Limit 1];
        if(!objConEvntEdtnMap.isEmpty())
        {   
            string userType=objConEvntEdtnMap[0].User_Type__r.Name; 
            list<User_Manual_Action__c> lstUserManualAction=[SELECT Is_Viewed__c, Is_Agree__c,Id,Manual_Permission__r.Manuals__r.Deadline__c,Manual_Permission__r.Manuals__r.Required__c,Manual_Permission__r.Active__c,Manual_Permission__r.Manuals__r.Provider__c,Manual_Permission__r.Manuals__r.Manual_Type__c,Manual_Permission__r.Manuals__r.Name,Manual_Permission__r.Manuals__r.Allow_Submit_After_Deadline__c,Manual_Permission__r.Manuals__r.Uploaded_Attachment_Id__c,Manual_Permission__r.Manuals__r.Uploaded_Attachment_Name__c, Manual_Permission__r.Manuals__r.Content_Version_Id__c  
                                                             FROM User_Manual_Action__c 
                                                             Where Account__c=:accId
                                                             And Manual_Permission__r.Manuals__r.Event_Edition__r.Event_Code__c =: sEventcode 
                                                             AND Manual_Permission__r.Manuals__r.Required__c=true 
                                                             And User_Type__r.Name =:userType 
                                                             And Manual_Permission__r.Manuals__r.Manual_Type__c!='Link'];//Manual_Permission__r.Manuals__r.Deadline__c<=TODAY 
            if (lstUserManualAction.size()>0)
            {
               return lstUserManualAction;
            }
        }
         return null;  
    }

    @AuraEnabled//Update user manual actions [CCEN-335]
    public static void  updateUserManualAction(User_Manual_Action__c userManualAction ){
        update userManualAction;
    }
    @AuraEnabled//Get Agents booths [CCEN-335]
    public static list<Opportunity_ExpoCAD_Booth_Mapping__c>  getAgentBooths(String sEventcode,string accid,string srchText)
    {
        //list<ExpocadBooth__c> listExpo = new list<ExpocadBooth__c>();
        return StandContractorUtils.getPavilionSpaceExhibitorsBooths(sEventcode,accid,srchText);
    }
}