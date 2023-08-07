/**
* Project:         GAP
* Date:            03/04/2019
* Test Class Name :EmailMessagingContact_Test   
* Code Coverage:   100%
* Created By:      Rajesh Kumar
* *************************************************************************
* @Description:     This test class covers "EmailMessagingContact_Test " Apex class.
* *************************************************************************
* History:Ticket :GGCW-2845 
Modified By Rajesh Kr - 09-04-2021 - BK - 15073
*
*/

Public class EmailMessagingContact_Class{

	/**
	* lstEmailMessage
	* @description apex variable
	*/
	List<EmailMessage> lstEmailMessage             		{ get; set; }

	/**
	* oldEmailMessageMap
	* @description apex variable
	*/
    Map<Id , EmailMessage> oldEmailMessageMap           { get; set; }

    /**
	* isInsert
	* @description apex variable
	*/
    Boolean isInsert                        			{ get; set; }

    /**
	* isAfter
	* @description apex variable
	*/
    Boolean isAfter                         			{ get; set; }

    /**
	* contactAttachmentList
	* @description apex variable
	*/
	List <ContentDocumentLink> lstContentDocumentLinks  {get; set;}

    /**
	* attachmentListID
	* @description apex variable
	*/
    Set <Id> attachmentListID						    { get; set; }	

    Public EmailMessagingContact_Class(List<EmailMessage> lstEmailMessage , Map<Id , EmailMessage> oldEmailMessageMap , Boolean isInsert , Boolean isAfter){
    	this.lstEmailMessage = lstEmailMessage;
    	this.oldEmailMessageMap = oldEmailMessageMap;
    	this.isInsert = isInsert;
    	this.isAfter = isAfter;


		lstContentDocumentLinks = new List <ContentDocumentLink>();
    	attachmentListID = new set<id> ();
    }

    Public void createContactAttachment (){
	    for(EmailMessage mail : lstEmailMessage){

	        if(mail.RelatedToId !=null ){
	            attachmentListID.add(mail.RelatedToId);//Save Content Document Id on this fields.

	        }        
	    }
	 
	    if(attachmentListID.size() > 0){


	        Map<Id,ContentDocumentLink> mapEmailMessageAttmntId = new map<Id,ContentDocumentLink>([SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, ShareType FROM ContentDocumentLink  where LinkedEntityId IN : attachmentListID 
			]);
			for(EmailMessage mail : lstEmailMessage){
				for (ContentDocumentLink ocontentDocLinks : mapEmailMessageAttmntId.values()){
					ContentDocumentLink cDocLink = new ContentDocumentLink();
					cDocLink.ContentDocumentId = ocontentDocLinks.ContentDocumentId;//Add ContentDocumentId
					cDocLink.LinkedEntityId =  mail.Id;//Add attachment parentId
					cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
					cDocLink.Visibility = 'AllUsers';
					lstContentDocumentLinks.add(cDocLink);

	            }
	        }
	    }
	    if(lstContentDocumentLinks.size() > 0 && lstContentDocumentLinks != null){

	        insert lstContentDocumentLinks;

	    } 
    }
}