/**
* File:             ReleaseNotification.cls
* Project:          GAP
* Date:             Sep 06, 2017
* Test Class Name:  ReleaseNotification_Test
* Code Coverage:    89%
* Created By:       Kumar Gaurav
* *************************************************************************
* Description:      Sends an alert before and after releasing Booths.
* *************************************************************************
* History:
*/
public class ReleaseNotification{
  //Variables
  public Id OpportunityID {get;set;}

  /**
   * Getting Booth Nos after releasing the Booths.
   * @return [sBoothName]
   */
  public String getBoothNamesAfterRelease(){
    String sBoothName = '';
    Set<String> setBoothNos ;
    for(ExpocadBooth__c oEB :[SELECT Booth_Number__c from ExpocadBooth__c where Opportunity__c =: OpportunityID  AND Quote__c != NULL AND Opportunity__r.StageName NOT IN ('Closed Booked', 'Closed Lost') AND Quote__r.SBQQ__Status__c NOT IN ('Quote Approved', 'Contract Sent', 'Contract In Review', 'Contract Approved') AND Max_Date_To_Release__c =:date.today() AND Status__c != 'Released' ORDER BY createdDate ASC LIMIT 10000]){
      if(String.isEmpty(sBoothName)){
        sBoothName = oEB.Booth_Number__c;
      }
      else {
        setBoothNos = new Set<String>(sBoothName.split(','));
        if(!setBoothNos.contains(oEB.Booth_Number__c))
          sBoothName += ', '+oEB.Booth_Number__c;
      }
    }
    return sBoothName;
  }
  
  /**
   * Getting Booth Nos before releasing the Booths.
   * @return [sBoothName]
   */
  public String getBoothNames(){
    String sBoothName = '';
    Set<String> setBoothNos ;
    for(ExpocadBooth__c oEB :[SELECT Booth_Number__c from ExpocadBooth__c where Opportunity__c =: OpportunityID  AND Quote__c != NULL AND Opportunity__r.StageName NOT IN ('Closed Booked', 'Closed Lost') AND Quote__r.SBQQ__Status__c NOT IN ('Quote Approved', 'Contract Sent', 'Contract In Review', 'Contract Approved') AND Max_Date_To_Release__c =:date.today().addDays(1) AND Status__c != 'Released' ORDER BY createdDate ASC LIMIT 10000]){
      if(String.isEmpty(sBoothName)){
        sBoothName = oEB.Booth_Number__c;
      }
      else {
        setBoothNos = new Set<String>(sBoothName.split(','));
        if(!setBoothNos.contains(oEB.Booth_Number__c))
          sBoothName += ', '+oEB.Booth_Number__c;
      }
    }
    return sBoothName;
  }
  
  /**
   * Getting Booth status.
   * @return [BoothStatus]
   */
  public string getBoothStatus(){
    String BoothStatus ='';
    for(Booth_Approval_Dashboard__c oBAD :[SELECT Status__c from Booth_Approval_Dashboard__c where Opportunity__c =: OpportunityID AND Opportunity__r.StageName NOT IN ('Closed Booked', 'Closed Lost') AND Status__c != 'Released' ORDER BY createdDate ASC LIMIT 10000]){
      if(String.isEmpty(BoothStatus)){
        BoothStatus = oBAD.Status__c;
      }
      else if(!BoothStatus.contains(oBAD.Status__c)){
        BoothStatus += ', '+oBAD.Status__c;
      }
    }
    return BoothStatus;
  }
  
  /**
   * Getting held Booth Nos.
   * @return [sBoothName]
   */
  public String getHeldBooths(){
    String sBoothName = '';
    Set<String> setBoothNos ;
    for(ExpocadBooth__c oEB :[SELECT Booth_Number__c from ExpocadBooth__c where Opportunity__c =: OpportunityID  AND Quote__c != NULL AND Opportunity__r.StageName NOT IN ('Closed Lost') AND Status__c != 'Released' AND Quote__r.SBQQ__Primary__c = TRUE ORDER BY createdDate ASC LIMIT 5000]){
      if(String.isEmpty(sBoothName)){
        sBoothName = oEB.Booth_Number__c;
      }
      else {
        setBoothNos = new Set<String>(sBoothName.split(','));
        if(!setBoothNos.contains(oEB.Booth_Number__c))
          sBoothName += ','+oEB.Booth_Number__c;
      }
    }
    return sBoothName;
  }

  /**
   * Getting host URL.
   * @return [sBoothName]
   */
  public String getHostUrl(){
    String sHostURL = 'https://www.expocad.com/host/fx/informa';
    ExpocadCredential__c oExpocadCredential = ExpocadCredential__c.getValues('ExpocadApiCredential');
    if(oExpocadCredential != NULL && String.isNotBlank(oExpocadCredential.Expocad_Host_URL__c)){
      sHostURL = oExpocadCredential.Expocad_Host_URL__c ;
    }
    return sHostURL;
  }

  /**
   * Getting Expocad Code.
   * @return [sExpocadCode]
   */
  public String getExpocadCode(){
    String sExpocadCode = '';
    Opportunity oOpportunity = [SELECT EventEdition__r.Event_Code__c FROM Opportunity WHERE ID =: OpportunityID];
    if(oOpportunity != NULL && String.isNotBlank(oOpportunity.EventEdition__r.Event_Code__c)){
      sExpocadCode = oOpportunity.EventEdition__r.Event_Code__c ;
    }
    return sExpocadCode;
  }

  /**
   * Getting Header Logo.
   * @return [sHeaderLogo]
   */
  public String getHeaderLogo(){
    String sHeaderLogo = '';
    Opportunity oOpportunity = [SELECT Base_Url__c FROM Opportunity WHERE ID =: OpportunityID];
    Document oDocHeaderImage = [SELECT ID FROM Document WHERE DeveloperName = 'EmailTemplateHeader_Logo'];
    if(oOpportunity != NULL && oDocHeaderImage != NULL ){
      sHeaderLogo = oOpportunity.Base_Url__c+'/servlet/servlet.FileDownload?file='+oDocHeaderImage.Id ;
    }
    return sHeaderLogo;
  }

  /**
   * Getting Footer Logo.
   * @return [sHeaderLogo]
   */
  public String getFooterLogo(){
    String sFooterLogo = '';
    Opportunity oOpportunity = [SELECT Base_Url__c FROM Opportunity WHERE ID =: OpportunityID];
      Document oDocFooterImage = new Document();
      if(!test.isRunningTest())
     oDocFooterImage = [SELECT ID FROM Document WHERE DeveloperName = 'EmailTemplateFooter_Logo'];
    if(oOpportunity != NULL && oDocFooterImage != NULL ){
      sFooterLogo = oOpportunity.Base_Url__c+'/servlet/servlet.FileDownload?file='+oDocFooterImage.Id ;
    }
    return sFooterLogo ;
  }
}