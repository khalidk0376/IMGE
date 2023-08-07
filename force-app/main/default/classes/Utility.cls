/**
* File:        Utility.cls
* Project:     GAP
* Date:        Sep 06, 2016
* Created By:  Kumar Gaurav
* *************************************************************************
* @description: This class contains common methods for all Expocad realated
               Classes and triggers. 
* *************************************************************************
* History: Change : triggerExecuted variable added and initialised with false value.
           Added by : Avinash Shukla, Dated : 29 Nov 2019
* Modified By Rajesh Kumar : BK-5419 on 17-06-2020
*/

public without sharing class Utility {

  public static boolean isRebookInProcess = false;
  /**
    Adding this variable on Utility to check and restrict triggers running in recursive manner. This change is related to BK-2992
    Change : triggerExecuted variable added and initialised with false value.
    Added by : Avinash Shukla, Dated : 29 Nov 2019
   */
  public static boolean triggerAUExecuted = false;
  public static boolean triggerAIExecuted = false;
  public static boolean triggerBUExecuted = false;
  public static boolean triggerBIExecuted = false;
  public static Integer countOppTriCalled = 0;
  
  public static boolean isReviewProcess = false;
  public static boolean byPassClosedWon = false;
  public static Boolean quoteTriggerMargeisFirstTime = false;
  public static Boolean quoteTriggerMargeisFirstTimeBefore = false;
  public static Boolean isAttachAgreement = false;
  public static Boolean isAmendmentProcess = false;
  public static Boolean isUpdateRollUpFields = false;
  

  /*
  *Catching all expocad exception using passed exception parameter details.
  ***/
  public static void logError(String sMessage, Exception sCause, Integer sLineNumber , string sStackTraceString , string sMethodName) {
    ExpoCad_Error__c oExpocadError = new ExpoCad_Error__c();
    oExpocadError.Errors__c = 'Message: ' + sMessage +   'Cause: ' +  sCause + '  Line number: ' + sLineNumber + ' Stack trace: ' +  sStackTraceString ;
    oExpocadError.Description__c = 'Error Message : ' + sMessage + 'Function/Method Name : ' +  sMethodName;
    insert oExpocadError ;
  }
  public static void logsError(String sMessage, Exception sCause, Integer sLineNumber , string sStackTraceString , string sMethodName, String serviceSource) {
    Error_Log__c errorLog = new Error_Log__c();
    errorLog.Service_Source__c = serviceSource;
    errorLog.Source_Name__c = sMethodName;
    errorLog.Description__c =  'Error Message: ' + sMessage +   'Cause: ' +  sCause + '  Line number: ' + sLineNumber + ' Stack trace: ' +  sStackTraceString ;
    insert errorLog ;
  }
  // Method to encode using base64
  public static String encode(String str) {
    if (str != null && str != '') {
      return EncodingUtil.base64Encode(blob.valueof(str + '-INF17-AXUS-KG17'));
    }
    return str;
  }

  // Method to decode using base64
  public static String decode(String str) {
    if (str != null && str != '') {
      return EncodingUtil.base64Decode(str).toString().substringBefore('-INF17-AXUS-KG17');
    }
    return str;
  }

  // String to Currency format
  public static String currencyFormat(String str) {
    if (str != null && str != '') {
      Decimal dNumberToFormat = Decimal.valueof(str);
      List<String> args = new String[] {'0', 'number', '###,###,##0.00'};
      String sFormattedValue = String.format(dNumberToFormat.format(), args);
      return sFormattedValue;
    }
    return str;
  }

  // Return true if Lightning page is accessed from Lightning Env.
  public static Boolean isLightning (String sURL) {
    Boolean isLightning = False;
    if (!String.isBlank(sURL) && sURL.tolowercase().contains('lightning')) {isLightning = True;
    }
    return isLightning;
  }

  // Return true if Record is updating using Asynchronous ways.
  public static Boolean isAsync() {
    return System.isBatch() || System.isQueueable() || System.isScheduled() || System.isFuture();
  }

// Return Map of string and Booth Product Type Configuration object as per the new logic of MPN tickets.
  public static Map<String, Booth_Product_Type_Configuration__c> mapBoothProductType() {
    Map<String, Booth_Product_Type_Configuration__c> mapBoothPrdType = new Map<String, Booth_Product_Type_Configuration__c>();
    List<Booth_Product_Type_Configuration__c> lstBPT = [SELECT Id, Name, Matched_Product_Name__c, Booth_Product_Type__c FROM Booth_Product_Type_Configuration__c Limit 49000];
    if (lstBPT.size()  > 0) {
      for (Booth_Product_Type_Configuration__c bpt : lstBPT) {
        mapBoothPrdType.put(bpt.Booth_Product_Type__c, bpt);
      }
    }
    return mapBoothPrdType;
  }
  // Add BY Rajesh Kumar - BK-5419 - 17-06-2020 and for Increase Code coverge please run BatchRemoveAccountTeamMember_test class.
  public static string removeAccountTeammember(set<Id> sAccountid) {
    List<Opportunity >  lstopplists = new List<Opportunity>(); 
    Map<id , Set<Id>> mapuserid = new Map <Id, Set<Id>>( );
    List <Id> accTeamMemberLstDelIds = new List <Id>();
    try{
      if (!Schema.sObjectType.Opportunity.fields.OwnerId.isAccessible()){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));  return null; }
      else{
        lstopplists = [Select Id , OwnerId, AccountId from Opportunity where AccountId IN : sAccountid ];
      }

      for (Opportunity opplists : lstopplists ){
        if ( mapuserid.containsKey(opplists.accountId)) { 
            mapuserid.get( opplists.AccountId ).add( opplists.OwnerId );
        }
        else {
            Set<Id> newUserIdSet = new Set<Id>();
            newUserIdSet.add(opplists.OwnerId);
            mapuserid.put( opplists.accountId , newUserIdSet); 
        }
      }

      if (!Schema.sObjectType.AccountTeamMember.fields.UserId.isAccessible()){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access')); return null; }
      else {
        List<AccountTeamMember> lstAccountTeamMembers = [Select Id, AccountId , UserId From AccountTeamMember where AccountId IN : sAccountid];
        for(AccountTeamMember accTeamMember : lstAccountTeamMembers){
          if(mapuserid.containsKey(accTeamMember.AccountId)){
              if(!mapuserid.get(accTeamMember.AccountId).contains(accTeamMember.UserId)){
                  accTeamMemberLstDelIds.add(accTeamMember.Id);
              }
          }
        }
      }
      if(!accTeamMemberLstDelIds.isEmpty()){  List<AccountTeamMember> lstAtm =  [Select id,UserId,AccountId from AccountTeamMember where id IN : accTeamMemberLstDelIds];  Database.DeleteResult[] drListAtm = Database.delete(lstAtm, false);      } 
      return 'Success';  
    }
    catch(QueryException ex){ Utility.logsError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'removeAccountTeammember' , 'Integration');    }
    return 'failed';
  }
}