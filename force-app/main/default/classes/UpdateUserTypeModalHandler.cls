/**
* Created By   :   Girikon(Shiv Raghav)
* Created On   :   Dec 31 2019
* @description :   This class is use for updating Expocad ,Opportunity Mapping records for particular opportunity.
* Test Class   :   UpdateUserTypeModalHandler_Test (89%)
* Modified by  :   Himanshu jasuja[BK - 3593]
* Modified by  :   Adarsh Sharma [BK - 3658]
* Modified by  :   Avinash Shukla [BK - 3658]
* Modified by  :   Avinash Shukla [BK -4061]
* Modified by  :   Shiv - Bk-4367
**/
public class UpdateUserTypeModalHandler {
    
    @AuraEnabled
    // Modfied by Adarsh Sharma [BK - 3658] START
    public static Map<String,Object> getAllOppMapping(Opportunity opp){ 
        List <Opportunity_ExpoCAD_Booth_Mapping__c> inActiveMapping = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        List <Opportunity_ExpoCAD_Booth_Mapping__c> activeMapping = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        String eventeditionName = geteventeditionname(opp);
        //BK -4061 - Added status__c = 'Active' in this query.
        List <Opportunity_ExpoCAD_Booth_Mapping__c> oppExpBthMappingList = [Select id, Booth_Number__c, Account__r.Name , Opportunity__r.Name , Event_Edition_Name__c, Relation__c, Related_Opportunity__c , Related_Opportunity__r.Name, Status__c, Expocad_booth__c, Expocad_booth__r.Status__c from Opportunity_ExpoCAD_Booth_Mapping__c where Account__c =: opp.AccountId And Event_Edition_Name__c =: eventeditionName];         
        
        for(Opportunity_ExpoCAD_Booth_Mapping__c expMapping : oppExpBthMappingList){
            
            if( expMapping.Expocad_booth__r.Status__c == 'Rented'){
                activeMapping.add(expMapping);
            }
            if(expMapping.Expocad_booth__r.Status__c == 'Released'){
                inActiveMapping.add(expMapping);
            }
        }
        return new Map<String,Object>{
            //Updated By Shiv - Bk-4367
            'expocad_Mapping' => activeMapping,
            'inactiveMapping' => inActiveMapping.size() > 0 ? inActiveMapping : null,
            'activeMapping' => activeMapping.size()>0 ? activeMapping : null 
        };
    }

    @AuraEnabled
    public static Boolean moveAndUpdateCCObjects(Id inactiveBoothSelected, Id activeBoothSelected){
        try{
            System.debug('inactiveBoothSelected---'+inactiveBoothSelected + '             ' + 'activeBoothSelected' +activeBoothSelected);
            List<Exhibitor_Badge__c> eBadges = new List<Exhibitor_Badge__c>();
            List<Stand_Design__c> sDesigns = new List<Stand_Design__c>();
            List<Stand_Detail__c> sDetails = new List<Stand_Detail__c>();
            List<BoothContractorMapping__c> bConMaps = new List<BoothContractorMapping__c>();
            eBadges = [Select Id, Opp_Booth_Mapping__c from Exhibitor_Badge__c WHERE Opp_Booth_Mapping__c =: inactiveBoothSelected];
            sDesigns = [Select Id, Opp_Booth_Mapping__c from Stand_Design__c WHERE Opp_Booth_Mapping__c =: inactiveBoothSelected];
            sDetails = [Select Id, Opp_Booth_Mapping__c from Stand_Detail__c WHERE Opp_Booth_Mapping__c =: inactiveBoothSelected];
            bConMaps = [Select Id, Opp_Booth_Mapping__c from BoothContractorMapping__c WHERE Opp_Booth_Mapping__c =: inactiveBoothSelected];
            
            for(Exhibitor_Badge__c eBadge : eBadges){ eBadge.Opp_Booth_Mapping__c = activeBoothSelected;
            }
            for(Stand_Design__c sDesign : sDesigns){ sDesign.Opp_Booth_Mapping__c = activeBoothSelected;
            }
            for(Stand_Detail__c sDetail : sDetails){ sDetail.Opp_Booth_Mapping__c = activeBoothSelected;
            }
            for(BoothContractorMapping__c bConMap : bConMaps){ bConMap.Opp_Booth_Mapping__c = activeBoothSelected;
            }
            Update eBadges;
            Update sDesigns;
            Update sDetails;
            Update bConMaps;
            return true;
        }
        catch(Exception exe){
            return false;
        }
    }
        // Modfied by Adarsh Sharma [BK - 3658] END
    @AuraEnabled
    public static List <Opportunity_ExpoCAD_Booth_Mapping__c > updateOppMappingRecords(List<Opportunity_ExpoCAD_Booth_Mapping__c> OppMapping ){
        update OppMapping;
        return OppMapping;
    }
    
    @AuraEnabled
    public static List<ExpocadBooth__c> getAllExpocadRecords(Opportunity opp){
        String eventeditionName = geteventeditionname(opp);
        return [Select Booth_Number__c, Account__r.Name ,Opportunity__r.Name ,Booth_Product_Type_EE__c,Matched_Product_Name__c,Event_Edition_Name__c from ExpocadBooth__c where Status__c = 'Rented' And Account__c =: opp.AccountId And Event_Edition_Name__c =: eventeditionName];         
    }
    
    @AuraEnabled
    public static List <ExpocadBooth__c > updateExpocadRecords(List<ExpocadBooth__c> ExpocadRecords ){
        update ExpocadRecords;
        return ExpocadRecords;
    }
    
    @AuraEnabled
    public static List<ContactEventEditionMapping__c> getAllCCMappingRecords(Opportunity opp){ 
        String eventeditionName = geteventeditionname(opp);
        return [Select SFContactID__c, SFEventEditionID__c , SFEventEditionID__r.Name , User_Type__c ,  User_Type__r.Name ,SFContactID__r.Name , SFContactID__r.Accountid,SFContactID__r.Account.Name from ContactEventEditionMapping__c where SFContactID__r.id =: opp.Operations_Contact__c And SFEventEditionID__r.Name =: eventeditionName];           
    }
    
    @AuraEnabled
    public static List < String > getselectOptions(sObject objObject, string fld) {
        List < String > allOpts = new list < String > ();
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        list < Schema.PicklistEntry > values = fieldMap.get(fld).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        allOpts.sort();
        return allOpts;
    }
    
    @AuraEnabled
    public static void updateExpocadRelationOnOpp(String userType , id oppid)
    {
        User_Type__c usrtype = [Select id, Name from User_Type__c where Name =: userType Limit 1];
        Opportunity opp = [Select id , User_Type__c from opportunity where id =: oppid];
        opp.User_Type__c = usrtype.id;
        update opp;
    }
    
    @AuraEnabled
    public static List <ContactEventEditionMapping__c > updateCCMappingRecords(List<ContactEventEditionMapping__c> CCMapingRecords ){
        System.debug('CCMapingRecords' +CCMapingRecords);
        update CCMapingRecords;
        return CCMapingRecords;
    }
    
    @AuraEnabled
    @future(callout=true)
    public static void AsyncupdateComment2onExbhitor(Id oppId , String SelectedRelation ) {
        String sExecutionMsg =  updateComment2onExbhitor(oppId , SelectedRelation );
        System.debug('sExecutionMsg' +sExecutionMsg);
    }
    
    public static String updateComment2onExbhitor(Id oppId , String SelectedRelation) {
        
        try {
            Opportunity oOpportunity = [SELECT Id, Name, EventEdition__r.Event_Code__c, EventEdition__r.Expocad_API_Url__c, AccountId, Account.Name, SBQQ__PrimaryQuote__c , User_Type__r.Name FROM Opportunity where Id =: oppId];
            ExpocadClasses.Exhibitor oExibitor = new ExpocadClasses.Exhibitor(); 
            oExibitor.ExhibitorId = oOpportunity.AccountId;                  
            oExibitor.ExhibitorName = subString(oOpportunity.Account.Name, 50);  
            
            if (!String.isBlank(SelectedRelation) && SelectedRelation == 'Agent') {  
                oExibitor.Comments2 = subString(SelectedRelation, 50);     
            } 
            else if(!String.isBlank(SelectedRelation) && SelectedRelation == 'Exhibitor')
            {
                oExibitor.Comments2 = ' ';
                System.debug('oExibitor.Comments2' + oExibitor.Comments2);
            }
            
            String sExbBody = JSON.serialize(oExibitor);
            String sAPIUrl = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/exhibitors/update?id=' + oOpportunity.AccountId + '&databaseName=' + oOpportunity.EventEdition__r.Event_Code__c;        
            HttpResponse res2 = new ExpocadResponses().request(sAPIUrl, 'PUT', sExbBody);
            
            if (res2.getStatusCode() == 200 && res2.getBody() != null)
            {
                System.debug('Response' + res2);             
            }
        }
        catch (exception ex) 
        { 
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'updateDisplayDrawingNameToExibitor Method (@BoothSelectionHlpr.Class)');  System.debug('Exception : ' + Ex);                               
        } 
        return Null;
    }
    
    Public static String subString(String sTemp, Integer iLength) {
        if (sTemp.length() > iLength) { sTemp = sTemp.substring(0, iLength); }
        return sTemp;
    }
    
    /**
* @description [Fetch Current user details]
* @return [user record]
*/
    @AuraEnabled
    public static string getCurrentUserDtls() {
        
        return  LtngUtilityCtrl.getCurrentUserDtls().Profile.Name;
    }
    
    public static string geteventeditionname(Opportunity opp)
    {
        opportunity oppnty =  [Select EventEdition__r.Name from opportunity where id =: opp.id limit 1];
        return oppnty.EventEdition__r.Name;
    }
  
}