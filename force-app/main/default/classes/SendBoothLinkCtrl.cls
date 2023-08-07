/**
 * File:        SendBoothLinkCtrl.cls
 * Project:     GAP
 * Date:        March 21, 2018
 * Test Calss : SendBootLinkCtrl_Test
 * Created By:  Kumar Gaurav
 * *************************************************************************
 * Description: Controller to send an Email Notification to Primary Contact related to Expocad Booth.
 * *************************************************************************
 * History:
 */

public class SendBoothLinkCtrl  {
    /*
    * Member variables
    */
    Id OpportuinityId ;
    public String sRequiredMsg {get;set;}
    
    /** 
     * Constructor, Getting required values for this class like, OpportuinityId.
     * @param  StandardController
     */
    public SendBoothLinkCtrl (ApexPages.StandardController controller){
        OpportuinityId = apexpages.currentpage().getparameters().get('Id').escapeHtml4();
    }
    
    /**
     * Sends Email To Oppty's PrimaryContact
     * @return [pageReference]
     */
    public pageReference sendEmailToPrimaryContact (){
        if(!String.isBlank(OpportuinityId)){
            Opportunity oOpportuinity = [SELECT StageName, Opportunity_Contact__r.Id, Opportunity_Contact__r.Email From Opportunity WHERE Id =: OpportuinityId] ;
            if(oOpportuinity.StageName != 'Closed Lost'){
                List<ExpocadBooth__c> lstEB = [SELECT Booth_Number__c from ExpocadBooth__c where Opportunity__c =: OpportuinityId  AND Quote__c != NULL AND Status__c != 'Released' AND Quote__r.SBQQ__Primary__c = TRUE ORDER BY createdDate ASC LIMIT 1000];
                system.debug('olstEEB' + lstEB);
                if(!lstEB.isEmpty()){
                    EmailTemplate[] templateId = [Select id from EmailTemplate where name = 'Send Booth Floorplan Info Template'];
                    List < Messaging.SingleEmailMessage > lstMailMsg = new List < Messaging.SingleEmailMessage > ();
                    List <String> toAddresses = new List <String>();
                    toAddresses.add(oOpportuinity.Opportunity_Contact__r.Email);
                    OrgWideEmailAddress[]  oWideEmailAdrs = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'GE Exhibitions' LIMIT 1];
                    if (!toAddresses.isEmpty() && !oWideEmailAdrs.isEmpty() && !templateId.isEmpty()) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(toAddresses);
                        mail.setTemplateID(templateId.get(0).Id);
                        mail.setTargetObjectId(oOpportuinity.Opportunity_Contact__r.Id);
                        mail.setWhatId(OpportuinityId);
                        mail.setOrgWideEmailAddressId(oWideEmailAdrs.get(0).Id);
                        mail.setSaveAsActivity(false);
                        lstMailMsg.add(mail);
                        Messaging.sendEmail(lstMailMsg, false);
                        return new PageReference('/'+OpportuinityId);
                    }
                    else if(templateId.isEmpty()){ sRequiredMsg = 'Template "Send Booth Floorplan Info Template" is not found.'; return null;
                    }
                }
                else { sRequiredMsg = 'There is no booth associated with this Opportunity, So Email can not be sent.'; return null;
                }
            }
            else{ sRequiredMsg = 'Email can not send for Closed Lost Opportunity'; return null;
            }
        }
        sRequiredMsg = 'Please provide an Opportunity Id'; return Null;
    }
    
    /**
     * Redirect To Record
     * @return [pageReference]
     */
    public pageReference redirectOpportunity(){
        return new PageReference('/'+OpportuinityId);
    }
}