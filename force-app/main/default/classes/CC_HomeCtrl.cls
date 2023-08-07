/*
Created By		: Girikon(Sunil[STL-18])
Created On		: Aug 01 2019
@description 	: This class is used to fetch booth summary data of current login user's account.
Test Class		: 

Modification log --
Modified By		:  Mukesh Gupta([STL-429], 18 Nov,2019)
*/
public without sharing  class CC_HomeCtrl {
    /**
     * @description         [Fetch booth summary of current login user's account]
     * @param  eventCode    [Event Code]
     * @return              [List of wrapper class]
     */
    @AuraEnabled(Cacheable=true)
    public static List<OppBoothDetailsWrapper> getOppBoothDetails(String eventCode)
    {
        List<User> lstUser = new List<User>([SELECT id,ContactId,AccountId,Account.Name FROM User WHERE id=:UserInfo.getUserId()]); 
        if(!lstUser.isEmpty()) 
        {
            string accountId=lstUser[0].AccountId;
            List<Event_Settings__c> eventSetList = new List<Event_Settings__c>();
            map<string,Opportunity_ExpoCAD_Booth_Mapping__c> mapExpocadmapping = new map<string,Opportunity_ExpoCAD_Booth_Mapping__c>();
            if(Schema.sObjectType.Event_Settings__c.isAccessible())
            {   
                eventSetList = [Select Id, Name, Branding_Color__c,Map_it_button_visibility__c, Button_colors__c, Button_Text_Color__c, Booth_Name__c,Booth_size__c,
                                Classification__c,Exhibiting_As__c,Open_Sides__c,Event_Edition__c, Event_Edition__r.Event_Code__c 
                                From Event_Settings__c
                                Where  Event_Edition__r.Event_Code__c=: eventCode];
                               
            }
            Event_Settings__c eventSet = new Event_Settings__c();
            if(!eventSetList.isEmpty())
            {
                eventSet = eventSetList[0]; 
            }
             System.debug('eventSet=='+eventSet);
            Set<string> quoteIds = new Set<string>();
            List<OppBoothDetailsWrapper> oppBoothWrprLst =new List<OppBoothDetailsWrapper>();
            List<Opportunity_ExpoCAD_Booth_Mapping__c> expoBooths= new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
            if(string.isNotBlank(accountId) && string.isNotBlank(eventSet.Event_Edition__c)) 
            {
                List<opportunity> opp = [Select id,Name,SBQQ__PrimaryQuote__c 
                                         From opportunity 
                                         Where AccountId=:accountId 
                                         AND EventEdition__c=:eventSet.Event_Edition__c 
                                         AND (StageName='Closed Won' OR StageName='Closed Booked') 
                                         And (User_Type__r.name != 'Agent' or Parent_Opportunity__r.AccountId =:accountId )
                                         order by createdDate]; 
                if(!opp.IsEmpty()) 
                {
                    for(opportunity oppty: opp)
                    {
                        if(oppty.SBQQ__PrimaryQuote__c!=null)
                        {
                            quoteIds.add(oppty.SBQQ__PrimaryQuote__c);
                        }
                    }
                    
                    if(!quoteIds.IsEmpty() && Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible())
                    {
                        expoBooths = [Select Id,Display_Name__c,Quote__r.SBQQ__Opportunity2__r.Account.name ,Expocad_Booth__c, Expocad_Booth__r.Matched_Product_Name__c, Account__r.Name, Expocad_Booth__r.Booth_Type__c, Expocad_Booth__r.Booth_Number__c, Expocad_Booth__r.Area_Number__c, Expocad_Booth__r.Unit_Type__c,Expocad_Booth__r.Dimensions__c,Expocad_Booth__r.Open_Corners__c,Expocad_Booth__r.Open_Sides__c,Expocad_Booth__r.Booth_Product_Type__c,Opportunity__c, Opportunity__r.Name, Opportunity__r.createdDate, Expocad_Booth__r.Display_Name__c, Expocad_Booth__r.Status__c
                                      From   Opportunity_ExpoCAD_Booth_Mapping__c
                                      Where Expocad_Booth__r.status__c='Rented'
                                      AND quote__c IN:quoteIds 
                                      AND Status__c='Active' 
                                      order by Opportunity__r.createdDate];
                    }     
                    if(!expoBooths.IsEmpty())
                    {
                        for(Opportunity_ExpoCAD_Booth_Mapping__c ecbmap: expoBooths)
                        {
                            mapExpocadmapping.put(ecbmap.Expocad_Booth__r.Booth_Number__c,ecbmap);
                        }
                        for(Opportunity_ExpoCAD_Booth_Mapping__c ecb: mapExpocadmapping.values())
                        {                       
                            OppBoothDetailsWrapper bdw=new OppBoothDetailsWrapper();
                            bdw.boothName=ecb.Expocad_Booth__r.Booth_Number__c;
                            bdw.boothArea = string.valueOf(ecb.Expocad_Booth__r.Dimensions__c);
                            bdw.BoothType=ecb.Expocad_Booth__r.Matched_Product_Name__c;
                            bdw.Corners=ecb.Expocad_Booth__r.Open_Corners__c;
                            bdw.openSides=ecb.Expocad_Booth__r.Open_Sides__c;
                            bdw.exhibitingAs = ecb.Display_Name__c!=null?ecb.Display_Name__c:'';
                            bdw.exhibitingAcc=ecb.Quote__r.SBQQ__Opportunity2__r.Account.name ;
    
                            if(eventSet!=null)
                            {
                                bdw.boothNameTitle = eventSet.Booth_Name__c;
                                bdw.boothAreaTitle = eventSet.Booth_size__c;
                                bdw.BoothTypeTitle = eventSet.Classification__c;
                                bdw.openSidesTitle = eventSet.Open_Sides__c;
                                bdw.exhibitingAsTitle = eventSet.Exhibiting_As__c;
                                bdw.evnSetting = eventSet.Map_it_button_visibility__c;
                            }
                            else
                            {
                                bdw.boothNameTitle = 'Booth Name';
                                bdw.boothAreaTitle = 'Booth Area';
                                bdw.BoothTypeTitle = 'Classification';
                                bdw.openSidesTitle = 'Open Sides';
                                bdw.exhibitingAsTitle = 'Exhibiting As';
                            }
                            oppBoothWrprLst.add(bdw);
                        }
                    }
                }
            }
        return oppBoothWrprLst;
        }
        else
        {
            return null;
        }
        
    }
	
    /**
     * @description         [Check community user permission, Using exsitng class "CheckStandContractorTabPermissionCC" to achive this feature]
	 * @param  				eventCode    [Event Code], accId
     * @return              [String]
     */
    @AuraEnabled(Cacheable=true)
    public static String checkPermission(String sEventcode,String accId){
        return CheckStandContractorTabPermissionCC.checkPermission(sEventcode,accId);
    }
    
    //purpose for bind Opp booth Detail
    public class OppBoothDetailsWrapper
    {
        @AuraEnabled public String  boothName;
        @AuraEnabled public String  boothArea;
        @AuraEnabled public String  boothType;
        @AuraEnabled public Decimal corners;
        @AuraEnabled public String openSides;
        @AuraEnabled public String  exhibitingAs;
        @AuraEnabled public String  boothNameTitle;
        @AuraEnabled public String  boothAreaTitle;
        @AuraEnabled public String  boothTypeTitle;
        @AuraEnabled public String  openSidesTitle;
        @AuraEnabled public String  exhibitingAsTitle;
        @AuraEnabled public String  exhibitingAcc;
        @AuraEnabled public Boolean evnSetting;
        public OppBoothDetailsWrapper()
        {
            boothName='';
            boothArea='';
            boothType='';
            corners=0.0;
            exhibitingAs='';
            boothNameTitle='';
            boothAreaTitle='';
            boothTypeTitle='';
            openSidesTitle='';
            exhibitingAsTitle=''; 
            exhibitingAcc='';
            evnSetting=false;
        }
    }
}