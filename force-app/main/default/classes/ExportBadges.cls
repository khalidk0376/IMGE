/**
 * Created By: Girikon(Aishwarya)
 * Created On:          04/12/2018
 * modified On:         13/2/2019
 * @description  : This class will be called through skuid page - "Badges_ExhibitorProfile_ForOps" for exporting the exhibitor badges
 * Test Class:          ExportBadges_Test (89%)
 * Last Modified By :   Suraj / CCEN-671
 * Last Modified On :    Girikon(Ashish [CCEN-652 Feb 6 2019],Aishwarya[CCEN-512],[CCEN-596,10 jan 2019] ,Suraj[CCEN-671], Aishwarya[CCEN-724 March 8 2019],Prashant [CCEN-737 April 3 2019],[BK-2895 Aishwarya Nov 26 2019])
**/

public without sharing class ExportBadges
{
    private LimitWrapper[] thousandBlocks = new LimitWrapper[]{};
    public string eveId = '';
    private final integer listLimit;
    public string reportName = ''; // report name
    

    public ExportBadges()
    {
        listLimit = 800;
        eveId = apexpages.currentpage().getparameters().get('eventId');
        reportName = apexpages.currentpage().getparameters().get('reportName'); // get the report name from the url [CCEN-596]
    } 
    
    public LimitWrapper[] getthousandBlocks()
    {
        thousandBlocks = new LimitWrapper[]{};
        integer loopCount = 0;
        Exhibitor_Badge__c [] badgeList = new Exhibitor_Badge__c[]{};
        List<Exhibitor_Badge__c> rawData;
        if( reportName == 'AllBadges'){
           getBadges();
        }else if(reportName == 'ExhibitorsWithoutBadges')
        {
           getExhibitorsWithoutBadges();
        }else if(reportName == 'AllAgentBadges')
        {
            getAllAgentsBadges();
        }
        return thousandBlocks;
    }
    
    //fetching data from Opportunity_ExpoCAD_Booth_Mapping__c for [CCEN-737]
    public void getExhibitorsWithoutBadges() // function to get exhibitors without badges [CCEN-671]
    {
        integer loopCount = 0; // initialize loopcount
        Opportunity_ExpoCAD_Booth_Mapping__c [] exhibitorsWObadgesList = new Opportunity_ExpoCAD_Booth_Mapping__c[]{}; // array of Opportunity_ExpoCAD_Booth_Mapping__c
        
        //CCEN-724 (updated filter(countbadges) in the below query)
        for(Opportunity_ExpoCAD_Booth_Mapping__c c:[select Account__r.Name,Opportunity__r.Account.Name,Expocad_Booth__r.Matched_Product_Name__c,Expocad_Booth__r.Dimensions__c,Booth_Number__c,Opportunity__r.Operations_Contact__r.Name,Opportunity__r.Parent_Opportunity__r.Account.Name, Opportunity__r.Operations_Contact__r.email,Opportunity__r.Operations_Contact__r.phone, Opportunity__r.User_Type__r.Name from Opportunity_ExpoCAD_Booth_Mapping__c WHERE Opportunity__r.EventEdition__c =:eveId  AND CountBadges__c = 0  AND Expocad_Booth__r.Status__c = 'Rented' AND Status__c = 'Active' AND Opportunity__c != null AND Opportunity__r.AccountId != null And Opportunity__r.User_Type__r.Name != 'Agent' And Is_Agent_Manged__c = false  AND quote__c !=null AND (Opportunity__r.StageName = 'Closed Won' OR Opportunity__r.StageName = 'Closed Booked') LIMIT 22000])  //// Added Is_Agent_Manged__c = false C2E-105
        {
            if(exhibitorsWObadgesList.size() < listLimit)
            {                                               
                exhibitorsWObadgesList.add(c);  
            }
            else
            {
                LimitWrapper chunk = new LimitWrapper();
                chunk.exhibitorsWObadges = exhibitorsWObadgesList;
                chunk.blockNumber = loopCount;
                loopCount++;
                thousandBlocks.add(chunk);
                exhibitorsWObadgesList = new Opportunity_ExpoCAD_Booth_Mapping__c[]{};                        
                exhibitorsWObadgesList.add(c);                        
            }            
        }
               
        if(exhibitorsWObadgesList.size()>0)
        {
            LimitWrapper chunk = new LimitWrapper();
            chunk.exhibitorsWObadges = exhibitorsWObadgesList;
            chunk.blockNumber = loopCount;
            loopCount++;
            thousandBlocks.add(chunk);
        }        
    }
    
    public void getBadges()   // Function to get All badges
    {
        integer loopCount = 0;
        
        Exhibitor_Badge__c [] badgeList = new Exhibitor_Badge__c[]{};        
        for(Exhibitor_Badge__c c: [Select User_Name__r.Contact.Account.Name,Opp_Booth_Mapping__r.Booth_Number__c, Account__r.Name, Account_Name__c, Exhibitor_Name__c, First_Name__c, Last_Name__c, Email__c, Is_VIP__c, toLabel(Country__c), Country_Code__c,Nationality__c, ExpoBoothNumber__c, State__c, City__c, Address__c, Age_Bracket__c, Job_Title__c,Mobile_Number__c,MatchMaking__c,Status__c FROM Exhibitor_Badge__c Where Event_Edition__c =:eveId AND Opp_Booth_Mapping__r.Expocad_Booth__r.Status__c = 'Rented' AND Account__c != null AND Opp_Booth_Mapping__r.Is_Agent_Manged__c = false LIMIT 17000]) // Added Is_Agent_Manged__c = false C2E-105
        {
            if(badgeList.size() < listLimit)
            {                                               
                badgeList.add(c);
            }
            else
            {
                LimitWrapper chunk = new LimitWrapper();
                chunk.badges = badgeList;
                chunk.blockNumber = loopCount;
                loopCount++;
                thousandBlocks.add(chunk);
                badgeList = new Exhibitor_Badge__c[]{};                        
                badgeList.add(c);                        
            }            
        }
               
        if(badgeList.size()>0)
        {
            LimitWrapper chunk = new LimitWrapper();
            chunk.badges = badgeList;
            chunk.blockNumber = loopCount;
            loopCount++;
            thousandBlocks.add(chunk);
        }
    }
     public void getAllAgentsBadges()   // Function to get All Agent badges
    {
        integer loopCount = 0;
        
        Agent_Badges__c [] badgeList = new Agent_Badges__c[]{};        
        //BK-2895 added matchmaking
        for(Agent_Badges__c c: [Select CreatedBy.Contact.Account.Name,Account_Name__c,AgentEventEditionMapping__r.Account__r.name, First_Name__c, Last_Name__c, Email__c, Is_VIP__c, toLabel(Country__c), Country_Code__c,Nationality__c, State__c, City__c, Address__c, Age_Bracket__c, Job_Title__c,Mobile_Number__c,Matchmaking__c,Status__c FROM Agent_Badges__c Where AgentEventEditionMapping__r.EventEdition__c =:eveId AND AgentEventEditionMapping__r.Is_Active__c = true LIMIT 18000])
        {
            if(badgeList.size() < listLimit)
            {                                               
                badgeList.add(c);
            }
            else
            {
                LimitWrapper chunk = new LimitWrapper();
                chunk.agentBadges = badgeList;
                chunk.blockNumber = loopCount;
                loopCount++;
                thousandBlocks.add(chunk);
                badgeList = new Agent_Badges__c[]{};                        
                badgeList.add(c);                        
            }
        }
               
        if(badgeList.size()>0)
        {
            LimitWrapper chunk = new LimitWrapper();
            chunk.agentBadges = badgeList;
            chunk.blockNumber = loopCount;
            loopCount++;
            thousandBlocks.add(chunk);
        }
    }
    public list<ContactEventEditionMapping__c> getagentsWithoutBadges()
    {
        list<ContactEventEditionMapping__c> agentContactWithoutBadges = new list<ContactEventEditionMapping__c>();
        if(string.isNotBlank(eveId) && reportName == 'AgentsWithoutBadges' && Schema.sObjectType.AgentEventEditionMapping__c.isAccessible())
        {
            set<Id> agentAccIds = new set<Id>();
            for(AgentEventEditionMapping__c agentmap :[select id , Account__c from AgentEventEditionMapping__c where Is_Active__c = true And Total_Badges__c = 0 And EventEdition__c =:eveId])
            {
                agentAccIds.add(agentmap.Account__c);
            }
            if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible())
            {
                agentContactWithoutBadges = [select id,SFContactID__r.name,SFContactID__r.phone,SFContactID__r.email,SFContactID__r.Account.Name from ContactEventEditionMapping__c where SFContactID__r.AccountId in:agentAccIds And SFEventEditionID__c =:eveId And User_Type__r.Name = 'Agent'];    
            }
        }
        return agentContactWithoutBadges;
    }
    
    public class LimitWrapper
    {
        public  list<Agent_Badges__c> agentBadges {get;set;}
        public  list<Exhibitor_Badge__c> badges {get;set;}
        public  list<Opportunity_ExpoCAD_Booth_Mapping__c> exhibitorsWObadges {get;set;} // list of expocadbooths
        public integer blockNumber {get;set;}
        public LimitWrapper()
        {
            badges = new list<Exhibitor_Badge__c>();
            exhibitorsWObadges = new list<Opportunity_ExpoCAD_Booth_Mapping__c>();
            blockNumber = 0;
        }
    }
}