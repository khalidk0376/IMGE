/**
* Created By    :  Girikon(Ashish)
* Created On    :  17 Sep 2019 [C2E-105]
* @description  :  Shows  The Report list view of all Agents in a Event (Ctrl Class of [AgentBadgesReportOps])
* Test Class    :  AgentBadgesReportOpsCtrl_Test (82%)
* Modification Log----- 
* Modified by : 
**/
public without sharing class  AgentBadgesReportOpsCtrl 
{
    public class AggregateResultResp
    {
        @AuraEnabled public String companyName;
        @AuraEnabled public String companyAccId;
        @AuraEnabled public Integer submitted;
        @AuraEnabled public Integer approved;
        @AuraEnabled public Decimal totalBadgesAllowed;
        public AggregateResultResp()
        {
            companyName = '';
            companyAccId = '';
            submitted=0;
            approved=0;
            totalBadgesAllowed=0.0;            
        }
    }
    //Wrapper Class For Aggregate Result Wrapper 
    public class AggregateResultWrapper
    {
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer pageNumber {get;set;}
        @AuraEnabled public Integer totalRecords {get;set;}
        @AuraEnabled public Integer recordStart {get;set;}
        @AuraEnabled public Integer recordEnd {get;set;}
        @AuraEnabled public List<AggregateResultResp> aggregateResult {get;set;}
        public AggregateResultWrapper()
        {
            aggregateResult = new List<AggregateResultResp>();
        }
    }

    @AuraEnabled //Fetch Agent Badge Aggregate Result 
    public static AggregateResultWrapper getAgentBadgeAggregate(String sEventId,Decimal pageNumber, Decimal pageSize,string status)
    {
        list<AggregateResultResp> listExhBadgeAgg = new list<AggregateResultResp>(); 
        AggregateResultWrapper agrResultWrap = new AggregateResultWrapper();

        Integer pSize =  (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
         
        //Offset for SOQL 
        Integer offset = (pNumber - 1) * pSize;

        if(String.isNotBlank(sEventId))
        {
            String query = '';
            String fields  =  ' Account__c,Account__r.Name,ApprovedBadgeCount__c,Total_Badges__c,Badge_Limit__c ';
            string condition = ' from AgentEventEditionMapping__c where  EventEdition__c =: sEventId AND Is_Active__c = true' ;

            if(status == 'All VIP')
            {
                condition = condition + ' And Vip_Count__c > 0';
            }
            else if(status == 'VIP Pending Review')
            {
                condition = condition + ' And VIP_Pending_Count__c > 0';
            }
            else if(status == 'Submitted')
            {
                condition = condition + ' And Total_Badges__c > 0';
            }
            else if(status == 'Not Submitted')
            {
                condition = condition + ' And Total_Badges__c = 0';
            }

            query = 'select '+String.escapeSingleQuotes(fields)+ condition ;


            if(pSize>0)
            {  
                query = query+' LIMIT '+ pSize +' OFFSET ' + offset  ;
            }
            list<AgentEventEditionMapping__c>  listAgentEventMapping = new list<AgentEventEditionMapping__c>(); 
            listAgentEventMapping = Database.query(query);
            
            Integer totalRecords = database.countQuery('select Count() '+condition);
            Integer recordEnd = pSize * pNumber;

            agrResultWrap.pageSize = pSize;
            agrResultWrap.pageNumber = pNumber;
            agrResultWrap.recordStart = offset + 1;
            agrResultWrap.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            agrResultWrap.totalRecords = totalRecords;

            Decimal agentbadgeLimit = 0;
            list<Event_Settings__c> evntStng = new list<Event_Settings__c>([select Agent_Badge_Limit__c,Event_Edition__c 
                                                                            from Event_Settings__c 
                                                                            where Event_Edition__c =: sEventId]);
            if(!evntStng.isEmpty())
            {
                agentbadgeLimit = String.isNotBlank(evntStng[0].Agent_Badge_Limit__c)?decimal.valueOf(evntStng[0].Agent_Badge_Limit__c):0;
            }

            if(!listAgentEventMapping.isEmpty())
            {
                for(AgentEventEditionMapping__c agentMp : listAgentEventMapping)
                {
                    AggregateResultResp objSummaryClass =   new AggregateResultResp();
                    objSummaryClass.companyName         =   agentMp.Account__r.Name;
                    objSummaryClass.companyAccId        =   agentMp.Account__c;
                    objSummaryClass.submitted           =   Integer.valueOf(agentMp.Total_Badges__c);
                    objSummaryClass.approved            =   Integer.valueOf(agentMp.ApprovedBadgeCount__c);
                    objSummaryClass.totalBadgesAllowed  =   agentMp.Badge_Limit__c != null ? (agentbadgeLimit + agentMp.Badge_Limit__c) :agentbadgeLimit;

                    listExhBadgeAgg.add(objSummaryClass);
                }               
            }                              
        } 
        agrResultWrap.aggregateResult = listExhBadgeAgg;
        return agrResultWrap;
    } 
    
    @AuraEnabled //Fetch Agent Badge From Account Id
    public static list<Agent_Badges__c> getAgentBadges (String sAccId,String sEventId)
    {           
        list <Agent_Badges__c> listAgentBadges = new list <Agent_Badges__c>();
        if(Schema.sObjectType.Agent_Badges__c.isAccessible())
        {
            listAgentBadges= [Select Id, AgentEventEditionMapping__r.Account__c,Account_Name__c, AgentEventEditionMapping__r.Account__r.Name,Is_VIP__c,First_Name__c,Last_Name__c,Job_Title__c,Address__c,City__c,Country__c,Nationality__c,State__c,Status__c,Age_Bracket__c,Mobile_Number__c,Email__c,Country_Code__c
                              from Agent_Badges__c 
                              WHERE AgentEventEditionMapping__r.Account__c =:sAccId 
                              And AgentEventEditionMapping__r.EventEdition__c =:sEventId 
                              AND AgentEventEditionMapping__r.Is_Active__c = true 
                              order by createdDate DESC limit 600];
        }        
        return listAgentBadges;
    }
        
    @AuraEnabled //fetch picklist values.
    public static List<String> getPicklistValues(String objApi,String fieldName)
    { 
        List<String> lstPickvals=new List<String>();    
        lstPickvals = UtilityMethods.getPicklistValues(objApi,fieldName);
        return lstPickvals;  
    }
    @AuraEnabled //Fetch event details
    public static Event_Settings__c getEventSettings(String eventId)
    {
        Event_Settings__c eventSetting = new Event_Settings__c ();
        if(Schema.sObjectType.Event_Settings__c.isAccessible())
        {
            eventSetting=[select id,Badge_State__c,Allow_VIP_Badges__c,Badge_Nationality__c,Badge_Mobile_Number__c,Badge_Last_Name__c,Badge_Job_Title__c,Badge_First_Name__c,Badge_Email__c,Badge_Country__c,Company_Name_on_Badge_ToUpperCase__c,Company_Name_on_Badge_Character_Limit__c,Badge_City__c,Badges_Title__c,Badges_Sub_Title__c,Badges_Redirect_URL__c,Badge_Mobile_Character_Limit__c,Badge_LName_To_UpperCase__c,Badge_LName_Character_Limit__c,Badge_JobTitle_Character_Limit__c,Badge_FName_To_UpperCase__c,Badge_FName_Character_Limit__c,Badge_Email_Character_Limit__c,Badge_Deadline__c,Badge_City_Character_Limit__c,Badge_Address_Character_Limit__c,Badge_Age_Bracket__c,Badge_Address__c,Company_Name_on_Badge__c,Co_Exhibitor_Badge_Limit__c
                          from Event_Settings__c 
                          where  Event_Edition__c = :eventId 
                          limit 1];
        }
        return eventSetting;
    }

    @AuraEnabled //Update Agent Badge status
    public static void updateAgentBadge(List<String> idStr,String status,Boolean sendEmail,String notes)
    {
        List<Agent_Badges__c> ebList =  [Select id,Status__c from Agent_Badges__c where id In :idStr];
        if(ebList.size()>0)
        {   
            set<string> ebIds = new set<String>();
            for(Agent_Badges__c eb : ebList)
            {
                eb.Status__c = status;//'pending';
                ebIds.add(eb.Id);
            }
            if(Schema.sObjectType.Agent_Badges__c.isUpdateable())
            {
                update ebList;
            }
            if(sendEmail == true)
            {
                BatchAgentBadgesStatusEmail objBatch = new BatchAgentBadgesStatusEmail(ebIds,status,notes);
                Database.executeBatch(objBatch,5);
            }            
        }
    }
    @AuraEnabled//Update Agent Badge
    public static String updateBadgeAllFields(Agent_Badges__c ebObj,Boolean sendEmail,String notes)
    {   
        String msg = 'Record Saved!'; 
        try
        {
            update ebObj;
        }
         catch(DmlException ex)
        {
            msg=ex.getMessage();
            msg=msg+' #   At Line No =: '+ex.getLineNumber();
        }
        if(sendEmail == true && (ebObj.Status__c == 'Approved' || ebObj.Status__c == 'Rejected'))
        {
            set<string> ebIds = new set<String>();
            ebIds.add(ebObj.Id);

            BatchAgentBadgesStatusEmail objBatch = new BatchAgentBadgesStatusEmail(ebIds,ebObj.Status__c,notes);
            Database.executeBatch(objBatch,1);
        }
        return msg;        
    }
     @AuraEnabled //Send Mass Badges Email Reminder
    public static Boolean massBadgesEmailReminder(string sEventId)
    { 
        set<String>accIDS= new set<string>();
        for(AgentEventEditionMapping__c agntMp : [Select id,Account__c from AgentEventEditionMapping__c
                                                  Where EventEdition__c=:sEventId 
                                                  And Total_Badges__c = 0 
                                                  AND Is_Active__c = true])
        {
            accIDS.add(agntMp.Account__c);
        }
        if(accIDS.size()>0)
        {
            string accList = JSON.serialize(accIDS);
            MassBadgeReminderEmailBatch batch = new MassBadgeReminderEmailBatch(sEventId,accList);
            Database.executeBatch(batch, 10);
            return true;
        }
        else
        {
            return false; 
        }
    }
}