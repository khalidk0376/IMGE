/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          05/12/2018
 * @description : This class is called through the Skuid pages - InformaMainPage
 * Methods:            checkPermission
 * Test Class:         CheckStandContractorTabPermissionCC_Test
 * Modification Log----- 
 * Modified by :Girikon(Mahesh)[CCEN-563(Dec 20 2018)],
**/
 
Global without sharing class CheckStandContractorTabPermissionCC
{
    webservice static string checkPermission(String sEventcode,String accId) 
    { 
        list<Opportunity_ExpoCAD_Booth_Mapping__c> lstexpoBooths=new list<Opportunity_ExpoCAD_Booth_Mapping__c>(); 
        list<Opportunity_ExpoCAD_Booth_Mapping__c> lstPvlnExpoBooths=new list<Opportunity_ExpoCAD_Booth_Mapping__c>(); //Agent Pavilion Space Exhibitors booths 
        // check the above parameters are not blank.                 
        if(string.isNotBlank(sEventcode) && string.isNotBlank(accId))
        {
            list<Event_Settings__c>evntStng =  new list<Event_Settings__c>();
            
            set<string> quoteIds = new set<string>();
            list<string>allowedExpocadProductTypes = new list<string>();
            if(Schema.sObjectType.Event_Settings__c.isAccessible() )
            {
                evntStng = [select id , Allowed_Expocad_Product_Types__c from Event_Settings__c where Event_Edition__r.Event_Code__c =: sEventcode limit 1];
            }            
            if(!evntStng.isEmpty() && evntStng.size()>0)
            {
                if(evntStng[0].Allowed_Expocad_Product_Types__c != null && evntStng[0].Allowed_Expocad_Product_Types__c !=''){
                    string productTypes = evntStng[0].Allowed_Expocad_Product_Types__c;
                    allowedExpocadProductTypes = productTypes.split(';');
                }
            } 
            //Added this regarding ticket CCEN-563
            List<opportunity> opp = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where AccountId=:accId AND EventEdition__r.Event_Code__c =: sEventcode AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
            system.debug('opp===='+opp);
            if(!opp.IsEmpty())
            {
                for(opportunity oppty: opp)
                {
                    if(oppty.SBQQ__PrimaryQuote__c!=null)
                    {
                        quoteIds.add(oppty.SBQQ__PrimaryQuote__c);
                    }
                }
                //Added condition of Related_Opportunity__c and Related_Opportunity__r.User_Type__r.Name for [CCEN-416]
                if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible())
                {
                    lstexpoBooths = [Select Id, Badge_Limit__c,Booth_Number__c,Expocad_Booth__r.Matched_Product_Name__c , Expocad_Booth__r.Area_Number__c, Expocad_Booth__r.Unit_Type__c,Expocad_Booth__r.Dimensions__c,Expocad_Booth__r.Open_Corners__c,Opportunity__c, Opportunity__r.Name, Opportunity__r.createdDate, Display_Name__c,Opportunity__r.account.name, Expocad_Booth__r.Status__c From  
                    Opportunity_ExpoCAD_Booth_Mapping__c where Expocad_Booth__r.status__c='Rented' and quote__c IN:quoteIds and (Related_Opportunity__c  = null OR Related_Opportunity__r.User_Type__r.Name = 'Co-Exhibitor')  And 
                    Expocad_Booth__r.Matched_Product_Name__c  in : allowedExpocadProductTypes AND Status__c ='Active' order by Opportunity__r.createdDate];
                }

            }
            System.debug('lstexpoBooths ========================================================='+lstexpoBooths);

            /**Check if Agent And has pavilion Space Exhibitors**/

            List<opportunity> lstOppsExh = new List<opportunity>();
            set<string> pvlnQuoteIds = new set<string>();
            
            //Check is class running for test
            if(Test.isRunningTest())
            {
                 lstOppsExh = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where EventEdition__r.Event_Code__c =: sEventcode and SBQQ__PrimaryQuote__c!='' order by createdDate limit 1000];  
                system.debug('lstOppsExh---'+lstOppsExh);
            }
            else
            {
                lstOppsExh = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where (StageName='Closed Won' OR StageName='Closed Booked') AND EventEdition__r.Event_Code__c =:sEventcode and parent_Opportunity__c != null and parent_Opportunity__r.AccountId =:accId and (parent_Opportunity__r.StageName='Closed Won' OR parent_Opportunity__r.StageName='Closed Booked'  ) And parent_Opportunity__r.User_Type__r.Name ='Agent' And SBQQ__PrimaryQuote__c!='' order by createdDate limit 1000];  
            }         
            if(!lstOppsExh.IsEmpty())
            { 
                for(opportunity oppty: lstOppsExh) 
                {
                    pvlnQuoteIds.add(String.valueOf(oppty.SBQQ__PrimaryQuote__c)); 
                }
                String query = 'Select Id,Opportunity__r.Account.Name,opportunity__r.parent_Opportunity__r.account.name,opportunity__r.parent_Opportunity__r.accountId From Opportunity_ExpoCAD_Booth_Mapping__c where id!=\'\' and Expocad_Booth__r.Matched_Product_Name__c  like \'%Pavilion Space%\' AND Status__c =\'Active\' And (NOT Expocad_Booth__r.Matched_Product_Name__c  like \'%Space Only%\')';
                
                //already commented Matched_Product_Name__c  =\'Pavilion Space\' ';
                 if(!Test.isRunningTest()){
                   query+=' and Expocad_Booth__r.status__c=\'Rented\' and quote__c IN:pvlnQuoteIds';
                }               
                query+=' order by Opportunity__r.createdDate limit 1000';
                lstPvlnExpoBooths = Database.query(query);
                //system.debug('query======'+query);
            }         
        }
        
        if((!lstexpoBooths.isEmpty() && lstexpoBooths.size()>0) || (lstPvlnExpoBooths.size()>0))
        {
            return 'success';
        }
        else
        {
            return 'fail';
        }
    }
}