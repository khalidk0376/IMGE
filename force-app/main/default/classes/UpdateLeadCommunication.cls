/**
* File:        UpdateLeadCommunication.cls
* Project:     GAP
* Date:        12 June 2017
* Created By:  Rajesh Kumar
* *************************************************************************
* Description: Update Lead address from associated Communication directry.
               
* *************************************************************************
* 
* History:
*/

public class UpdateLeadCommunication
{
  public Communication_Directory__c lObj;
  public Id CommucationId;
  public UpdateLeadCommunication(ApexPages.StandardController stdController){
    //Get Communication Dire Id form Url
    CommucationId = ApexPages.currentPage().getParameters().get('id');
    System.debug('CommucationId ' + CommucationId );
    //Query in Lead Object whenever you have pass value in account , Contact & Opportunity 
    lObj = (CommucationId == null) ? new Communication_Directory__c():[SELECT id , Lead_MDM_Id__c , Communication_Group__c ,Mailing_city__c ,Mailing_Country__c,Mailing_State__c ,Mailing_Street__c ,Mailing_Zip__c ,Value__c FROM Communication_Directory__c WHERE Id =: CommucationId LIMIT 1 ];
    System.debug('CommucationId 12 ' + lObj.Communication_Group__c);
    
  }
  //Pass Directly in Associated Vf Page
  public PageReference UpdateAddress(){
    //Lead Address Updated  from Lead Skuid page Layout .
    if (lObj.Lead_MDM_Id__c != null ){
      Lead olead = [SELECT  Id, Name, Company,  FirstName , LastName,   NumberOfEmployees ,Phone , MobilePhone , Status , Ownerid ,Title , Street ,City ,   State , PostalCode , Country  , LeadSource ,Event_Edition__c , Event_Series__c , Account_MDM_ID__c , MDM_ID__c ,Referred_By__c from Lead  where MDM_ID__c =: lObj.Lead_MDM_Id__c LIMIT 1];
      System.debug('test' + olead);
      if(olead != null){
        if (lObj.Communication_Group__c == 'Email'){
          System.debug('Email' +  lObj.Value__c);
          olead.Email = lObj.Value__c;
        }
        else if (lObj.Communication_Group__c == 'Phone'){
          System.debug('Phone' +  lObj.Value__c);
          olead.Phone = lObj.Value__c;
        }
        else if (lObj.Communication_Group__c == 'Direct Post'){
          System.debug('Direct Post' +  lObj.Value__c);
          olead.Street  = lObj.Mailing_Street__c;
          olead.city  = lObj.Mailing_city__c;
          olead.State  = lObj.Mailing_State__c;
          olead.Country  = lObj.Mailing_Country__c;
          olead.Postalcode  = lObj.Mailing_Zip__c;
        }
        Update olead;
      }
      PageReference Page = new PageReference('/' + olead.id );
      Page.setRedirect(true);
      return Page;
    }
    return null;
  } 
}