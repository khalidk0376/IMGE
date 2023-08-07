/**
* Project:     GAP
* Date:        Nov, 21 2018
* Created By:  Avinash Shukla
* Test Class:  Association_EB_CtrlEnh_Test 85%
* *************************************************************************
* @description Controller for PurchasedBoothsEnhanced page for Association Process
* *************************************************************************
* History: Modified by Avinash for Jira Ticket GGCW-2690 on 20/11/2018
*          Modified by Avinash for Jira Ticket GGCW-2707 on 06/12/2018
*          MOdified by Avinash for Jira Ticket GGCW-2879 on 07/01/2019
*          MOdified by Avinash for Jira Ticket GGCW-3005 on 29/01/2019
*          MOdified by Avinash for Jira Ticket GGCW-3255 on 25/04/2019
*          MOdified by Avinash for Jira Ticket BK-1221 on 31/07/19
*          MOdified by Avinash for Jira Ticket BK-2134 on 7/08/19
*          MOdified by Avinash for Jira Ticket BK-2085 on 13/08/19
*          MOdified by Avinash for Jira Ticket BK-2700 on 10/10/19
*          Modified BY Rajesh Kr for Jira ticket bk - 2264 16/10/19 
*          Modified BY Adarsh for Jira ticket BK-3355 16/10/19
*     Test Class coverage updated by Adarsh (Present Coverage : 85%)
*/
Public class Association_Eb_CtrlEnh {
  public List<Opportunity_ExpoCAD_Booth_Mapping__c> lstEbM {get; set;}
  //public List<ExpocadBooth__c> lstHeldBoothtoUpdate {get; set;}// Commented bcz it is not used in class
  public boolean isMainOpp {get; set;}
  public Opportunity oOpportunity {get; set;}
  public Boolean isShowMsg {get; set;}
  private ApexPages.StandardController stdController;
  //public transient List<Contact> lstExistingContact {get; set;}// Commented bcz it is not used in class
  public Id selectedAccountId {get; set;}
  public Id selectedContactId {get; set;}
  public String sOpptyName {public get; public set;}
  public String sOpptyName2 {public get; public set;}
  public String sOpptyName3 {public get; public set;}
  public String sDisplayName {public get; public set;}
  //public transient SavePoint mySavePoint {public get; private set;}// Commented bcz it is not used in class
  public opportunity relatedOppty {public get; private set;}
  public Account oAccount {get; set;}
  public Contact oContact {get; set;}
  public Contact oContact2 {get; set;}  public SBQQ__Quote__c objQuote {get; set;}
  public Boolean shouldRedirect {get; set;}
  public String redirectUrl {get; set;}
  //public transient Map<Id, Account> mapExistingAccount {get; set;}// Commented bcz it is not used in class
  public transient Map<ID, Contact> mapExistingContact {get; set;}
  public Integer mapExistingContactSize {get; set;}   public ExpocadClasses.Booth oExpoBooth {get; set;}
  public Boolean isLightingEnv ;
  public String sHost {get; set;}
  public Map<String, SBQQ__ProductOption__c> mapProductOptions {get; set;}
  public Map<Id, SBQQ__ProductOption__c> mapProductOptionsId {get; set;}
  public Product2 boothPackageProduct {get; set;}
  public String cornerProductName {get; set;}
  public String lblViewFloorplanButtonValidationNoExbMessage {get; set;}
  public String lblCreateRelatedOpportunityButtonValidationMessage {get; set;}
  public String lblConfirmMessagetoCreateRelatedOpportunity {get; set;}
  public String sEBDisplayName {get; set;}
  public integer limitSize   { get; set; }
  public integer offsetSize  { get; set; }
  public integer totalRecs   { get; set; }
  public integer pageNumber  { get; set; }
  public String accountName  { get; set; }
  public String sShowMsg     { get; set; }
  public String exhibitorPaidAcc { get; set; }
  public Id opptyId { get; set; }
  public Boolean isAmendOpportunity { get; set; }
  public Integer boothCount { get; set; }
  public Boolean hasCCData { get; set; }


  public Boolean bExbhitorBadge {get;set;}
  public Boolean bStandContractor {get;set;}
  public Boolean bBadges {get;set;}
  public Boolean bStandDetails {get;set;}
  public Boolean bStandDesigns {get;set;}


  public Association_Eb_CtrlEnh(ApexPages.StandardController controller) {
    this.stdController = controller;
    isMainOpp = true;
    isAmendOpportunity = false;
    hasCCData = false;


    bExbhitorBadge = false;
    bStandContractor = false;
    bBadges = false;
    bStandDetails = false;
    bStandDesigns = false;


    lstEbM = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
    oAccount = new Account();
    oContact = new Contact();
    oContact2 = new Contact();
    isShowMsg = false;
    shouldRedirect = false;
    sHost = URL.getSalesforceBaseUrl().toExternalForm();
    isLightingEnv = Utility.isLightning(ApexPages.currentPage().getURL());
    mapExistingContactSize = offsetSize = totalRecs = 0;
    opptyId = apexpages.currentpage().getparameters().get('id').escapeHtml4();
    lblViewFloorplanButtonValidationNoExbMessage = System.Label.View_Floorplan_Button_Validation_NoExb_Message.escapeHtml4();
    lblCreateRelatedOpportunityButtonValidationMessage = System.Label.Create_Related_Opportunity_Button_Validation_Message.escapeHtml4();
    lblConfirmMessagetoCreateRelatedOpportunity = System.Label.Confirm_Message_to_Create_Related_Opportunity.escapeHtml4();
    pageNumber = 1;
    limitSize = 10;
    accountName = sShowMsg = exhibitorPaidAcc = '';

    if (!String.isBlank(opptyId) && Schema.sObjectType.Opportunity.isAccessible() && Schema.sObjectType.opportunity.fields.Name.isAccessible() && Schema.sObjectType.User_Type__c.fields.Name.isAccessible() && Schema.sObjectType.opportunity.fields.isFirstChild__c.isAccessible() && Schema.sObjectType.opportunity.fields.isSecondChild__c.isAccessible() && Schema.sObjectType.opportunity.fields.Event_Edition_Currency__c.isAccessible() && Schema.sObjectType.opportunity.fields.AccountId.isAccessible() && Schema.sObjectType.opportunity.fields.Amount.isAccessible() && Schema.sObjectType.opportunity.fields.Opportunity_Contact__c.isAccessible() && Schema.sObjectType.opportunity.fields.Multiple_Stands_Approval__c.isAccessible() && Schema.sObjectType.User.fields.Id.isAccessible() && Schema.sObjectType.Account.fields.Name.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Booth_Size__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.No_Of_Corner__c.isAccessible() && Schema.sObjectType.opportunity.fields.CurrencyIsoCode.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Start_Date__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Event_Code__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Booth_Product_Type__c.isAccessible() && Schema.sObjectType.Brand__c.fields.SSC_Email_Distribution_ID__c.isAccessible() && Schema.sObjectType.Event_Series__c.fields.Package_Identifier__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Booth_Type__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Name.isAccessible() && Schema.sObjectType.opportunity.fields.EventEdition__c.isAccessible() && Schema.sObjectType.opportunity.fields.Event_Series__c.isAccessible() && Schema.sObjectType.opportunity.fields.Billing_Contact__c.isAccessible() && Schema.sObjectType.opportunity.fields.MSA_Requested__c.isAccessible() && Schema.sObjectType.opportunity.fields.Parent_Opportunity__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Expocad_API_Url__c.isAccessible() && Schema.sObjectType.opportunity.fields.SBQQ__PrimaryQuote__c.isAccessible() && Schema.sObjectType.opportunity.fields.Exhibitor_Paid_by__c.isAccessible() && Schema.sObjectType.opportunity.fields.Agent_s_Opportunity__c.isAccessible() && Schema.sObjectType.opportunity.fields.stageName.isAccessible() && Schema.sObjectType.opportunity.fields.Allow_Unrenting_Rented_booths__c.isAccessible()) {
      // Modified by Avinash : GGCW-2690, GGCW-2880.
      List < Opportunity > lstOppo = [SELECT Id,EventEdition__r.Booth_Bundle_Type__c, (Select Id, Name from Opportunities__r), User_Type__r.Name, isFirstChild__c, isSecondChild__c, Event_Edition_Currency__c, AccountId, Amount, Opportunity_Contact__c, Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, EventEdition__r.No_Of_Corner__c, CurrencyIsoCode, EventEdition__r.Start_Date__c, EventEdition__r.Event_Code__c, EventEdition__r.Booth_Product_Type__c, Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name, EventEdition__c, Event_Series__c, Billing_Contact__c, MSA_Requested__c, Parent_Opportunity__c, EventEdition__r.Expocad_API_Url__c, SBQQ__PrimaryQuote__c, Exhibitor_Paid_by__c, Agent_s_Opportunity__c,EventEdition__r.Allow_Related_Opps_Without_a_Stand__c, stageName, Allow_Unrenting_Rented_booths__c, Is_Amend_Opportunity__c , Type FROM Opportunity WHERE Id = : opptyId];
      if (lstOppo != null && lstOppo.size() > 0) {
        oOpportunity = lstOppo.get(0);
        if (oOpportunity.Parent_Opportunity__c != NULL) { isMainOpp = false; }
        sEBDisplayName = oOpportunity.Account.Name.replace('\'', '\\\'');


      }
    }

    //Modified by Avinash : GGCW 2690
    //Modified by Avinash Shukla on 31/07/19 : BK-1221
    lstEbM = [SELECT id, Area__c, Selected_Booth_Product_Type__c, Event_Code__c, Relation__c, Count_Related_Exhibitors__c, Exhibitor_Rented__c, Expocad_API_URL__c, BoothProduct_Type_from_Quote__c, Quote__c, Booth_Product_type_From_Expocad_Booth__c, Expocad_Booth__c, Related_Opportunity__c, Related_Opportunity__r.Name, Expocad_Booth__r.Display_Name__c, Display_Name__c , Expocad_Booth__r.Selected__c, Expocad_Booth__r.Matched_Product_Name__c, Quote__r.Name, Quote__r.SBQQ__Primary__c, Expocad_Booth__r.User__r.Name, Expocad_Booth__r.Area__c, Expocad_Booth__r.Unit_Type__c, Expocad_Booth__r.Open_Corners__c, Expocad_Booth__r.Booth_Type__c, Expocad_Booth__r.Booth_Number__c, Booth_Number__c, Expocad_Booth__r.Dimensions__c, Expocad_Booth__r.Last_Action_Date__c, Expocad_Booth__r.Status__c, Opportunity__c, Account__c, Expocad_Booth__r.Related_Opportunity__c, Expocad_Booth__r.Related_Opportunity__r.Name, Opportunity__r.Name, Expocad_Booth__r.ShowInShow__c, Expocad_Booth__r.Pavilion__c, Expocad_Booth__r.Booth_Classes__c, Primary_Contact__r.Name, Expocad_Booth__r.Primary_Contact__c, Parent_Opp_EB_Mapping__c, Expocad_Booth__r.BoothContact__r.Name, Expocad_Booth__r.Booth_Product_Type_EE__c , Account__r.Name , Expocad_Booth__r.Event_Code__c , Is_Parent_Mapping__c ,Event_Edition_Name__c from Opportunity_ExpoCAD_Booth_Mapping__c where Status__c = 'Active' AND Opportunity__c =: opptyId order by LastModifiedDate desc LIMIT 1000];
    boothCount = lstEbM.Size();
  }

  /**
   * Display existing Account with offset and limit
   * @return [List<Account>]
   * @description getAllaccouts to associate new opportunity to.
   */
  public List<Account> getAccounts( ) {
    List<Account> accounts;
    if ( accountName != '' ) {
      String accName = '%' + accountName + '%';
      accounts = [ SELECT Id, Name, Brand__c, BillingCity, BillingState, Type, Owner.Name, Count_of_Won_Opportunities__c, LastViewedDate  FROM Account WHERE name like : accName  ORDER BY LastViewedDate DESC NULLS LAST LIMIT : limitSize OFFSET : offsetSize ];
    } else {
      accounts = [ SELECT Id, Name, Brand__c, BillingCity, BillingState, Type, Owner.Name, Count_of_Won_Opportunities__c, LastViewedDate  FROM Account ORDER BY LastViewedDate DESC NULLS LAST LIMIT : limitSize OFFSET : offsetSize ];
    }
    if ( exhibitorPaidAcc != '' ) {      accounts = [ SELECT Id, Name, Brand__c, BillingCity, BillingState, Type, Owner.Name, Count_of_Won_Opportunities__c, LastViewedDate  FROM Account where id = : exhibitorPaidAcc  ORDER BY LastViewedDate DESC NULLS LAST LIMIT : limitSize OFFSET : offsetSize ];
    }
    //getContact();
    return accounts;

  }

  /**
   * Counts existing Account no.
   * @return [totalRecs]
   * @description getting count of all accounts.
   */
  public integer getTotalAccounts( ) {
    List <Account> accList = new List <Account> ( );
    if ( accountName != '' ) {      String accName = '%' + accountName + '%'; accList = [ SELECT Id FROM Account WHERE name like : accName ORDER BY LastViewedDate DESC LIMIT 2000 ];
    } else {
      accList = [ SELECT Id FROM Account ORDER BY LastViewedDate DESC LIMIT 2000 ];
    }
    if ( exhibitorPaidAcc != '' ) {      accList = [ SELECT Id FROM Account WHERE id = : exhibitorPaidAcc ];
    }
    totalRecs = accList.size();
    return totalRecs;
  }
  public void firstPage( ) {
    offsetSize = 0;
    pageNumber = 1;
  }
  public void previous( ) {
    offsetSize = offsetSize - limitSize;
    pageNumber -= 1;
  }
  public void next( ) {
    offsetSize = offsetSize + limitSize;
    pageNumber += 1;
    if ( offsetSize >= 2000 ) { offsetSize = 2000 - 10; }
  }
  public void lastPage( ) {
    offsetSize = totalrecs - math.mod( totalRecs, limitSize );
    if ( math.mod( totalRecs, limitSize ) > 0 )  {pageNumber = ( integer ) totalRecs / limitSize + 1;}    else {pageNumber = ( integer ) totalRecs / limitSize;}
    if ( offsetSize >= 2000 ) {offsetSize = 2000 - 10;}
  }
  public boolean getprev( ) {
    if ( offsetSize == 0 ) {return true;}    else {return false;}
  }
  public boolean getnxt( ) {
    if ( offsetSize >= 1990 ||  ( offsetSize + limitSize ) >= totalRecs )  {return true;}    else {return false;}
  }
  public pageReference viewFloorPlan() {
    shouldRedirect = true;
    // GGCW-2580 : Kumar
    Set<String> setExbToAvoidCornerChk =  new Set<String> {'exhibitor paid by agent', 'subagent paid by subagent', 'subagent paid by exhibitor', 'exhibitor paid by exhibitor'};
    if (oOpportunity.Exhibitor_Paid_by__c != NULL && setExbToAvoidCornerChk.contains(oOpportunity.Exhibitor_Paid_by__c.toLowerCase())) {
      redirectUrl = sHost + '/apex/ReplaceBooth_extend?id=' + oOpportunity.Id;    } else {      redirectUrl = sHost + '/apex/ReplaceBooth?id=' + oOpportunity.Id + '&src=purchaseBooths';
    }
    if (isLightingEnv) {
      pageReference pg;
      if (oOpportunity.Exhibitor_Paid_by__c != NULL && setExbToAvoidCornerChk.contains(oOpportunity.Exhibitor_Paid_by__c.toLowerCase()))
      {pg = new pageReference('/apex/ReplaceBooth_extend?id=' + oOpportunity.Id);}      else      {pg = new pageReference('/apex/ReplaceBooth?id=' + oOpportunity.Id + '&src=purchaseBooths');}
      return pg;
    }
    return null;
  }
  public pageReference checkIsCChasData() {
    List<BoothContractorMapping__c> listBCM = new List<BoothContractorMapping__c>(); 
    set<id> setids = new set<id>(); 
    for (Opportunity_ExpoCAD_Booth_Mapping__c oEbm : lstEbM) {
      if (oEbm.Expocad_Booth__r.Selected__c && oEbm.Expocad_Booth__r.Booth_Number__c != null) {


        setids.add(oEbm.Id);
      }
    }
    listBCM = [Select Id, Name, Opp_Booth_Mapping__r.Account__c , Event_Edition__r.Name FROM BoothContractorMapping__c where Opp_Booth_Mapping__c IN : setids];
    if (listBCM.Size() > 0){      bStandContractor = true;
    }
    List<Exhibitor_Badge__c> listBadges  = [SELECT Id FROM Exhibitor_Badge__c WHERE Event_Edition__c !=null AND Opp_Booth_Mapping__c IN : setids];
    if (listBadges.size() > 0){      bExbhitorBadge = true;
    }

    List<BoothContactInfo__c> listExhibitorProfile = [Select Id FROM BoothContactInfo__c WHERE Opportunity_Booth_Mapping__c IN:setids AND IsSubmitted__c = true AND Opportunity_Booth_Mapping__c !=null AND Event_Edition__c !=null ] ;
    if(listExhibitorProfile.size() > 0 ){      bBadges= true;
    }
    List<Stand_Design__c> lstStandDesign = [Select Id, Opp_Booth_Mapping__c from Stand_Design__c WHERE Opp_Booth_Mapping__c IN : setids];
    if (lstStandDesign.size() > 0){      bStandDesigns = true;
    }

    List<Stand_Detail__c> lstStandDetail = [Select Id, Opp_Booth_Mapping__c from Stand_Detail__c WHERE Opp_Booth_Mapping__c IN : setids];
    if(lstStandDetail.size() > 0 ){      bStandDetails= true;
    }

    if((listBCM.size()>0) || (listExhibitorProfile.size()>0) || (listBadges.size()>0) || (lstStandDetail.size() >0 ) || (lstStandDesign.size() > 0) ){


      hasCCData = true;      return null;
    }
    else {
      unRentedbooth();
    }
    return null;
  }


  public pageReference cancelPopPup() {
    hasCCData = false;    redirectUrl = sHost + '/' + oOpportunity.Id;    if (isLightingEnv) {pageReference pg = new pageReference('/' + oOpportunity.Id); return pg;
    }
    return null;
  }



  /**
   * @description The functionality is used to Unrent the booth
   * @return pageReference
   */
  public pageReference unRentedbooth() {
    Map<Id, Set<String>> quoteToBoothNumber = new Map<Id, Set<String>>();
    /*
    This block runs when the opportunity is the main opportunity.
     */
    hasCCData = false;
    if (isMainOpp) {
        System.debug('isMainOpp' + isMainOpp);
      Set<Id> ebIds = new Set<Id>();
      list <ExpocadBooth__c> expoUnrent = new list < ExpocadBooth__c > ();
      if (test.isRunningTest()) {lstEbM.add([SELECT id, Area__c, Event_Code__c, Relation__c, Exhibitor_Rented__c, Expocad_API_URL__c, BoothProduct_Type_from_Quote__c, Quote__c, Booth_Product_type_From_Expocad_Booth__c, Expocad_Booth__c, Related_Opportunity__c, Related_Opportunity__r.Name, Expocad_Booth__r.Display_Name__c, Display_Name__c , Expocad_Booth__r.Selected__c, Expocad_Booth__r.Matched_Product_Name__c, Quote__r.Name, Quote__r.SBQQ__Primary__c, Expocad_Booth__r.User__r.Name, Expocad_Booth__r.Area__c, Expocad_Booth__r.Unit_Type__c, Expocad_Booth__r.Open_Corners__c, Expocad_Booth__r.Booth_Type__c, Expocad_Booth__r.Booth_Number__c, Booth_Number__c, Expocad_Booth__r.Dimensions__c, Expocad_Booth__r.Last_Action_Date__c, Expocad_Booth__r.Status__c, Opportunity__c, Account__c, Expocad_Booth__r.Related_Opportunity__c, Expocad_Booth__r.Related_Opportunity__r.Name, Opportunity__r.Name, Expocad_Booth__r.ShowInShow__c, Expocad_Booth__r.Pavilion__c, Expocad_Booth__r.Booth_Classes__c, Primary_Contact__r.Name, Expocad_Booth__r.Primary_Contact__c, Parent_Opp_EB_Mapping__c, Expocad_Booth__r.BoothContact__r.Name, Expocad_Booth__r.Booth_Product_Type_EE__c , Account__r.Name from Opportunity_ExpoCAD_Booth_Mapping__c Limit 1]);}
      for (Opportunity_ExpoCAD_Booth_Mapping__c oEbm : lstEbM) {
        if (Test.isRunningTest()) {
          oEbm.Expocad_Booth__r.Selected__c = true;
          oEbm.Expocad_Booth__r.Booth_Number__c = 'EB-102';
        }
        if (oEbm.Expocad_Booth__r.Selected__c && oEbm.Expocad_Booth__r.Booth_Number__c != null) {
         // String sUrlToUnhold = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/booths/unrent?boothNumber=' + oEbm.Expocad_Booth__r.Booth_Number__c + '&databaseName=' + oOpportunity.EventEdition__r.Event_Code__c;
         // HttpResponse unholdRes = new ExpocadResponses().request(sUrlToUnhold, 'PUT', '');
          //if (Test.isRunningTest()) {
            //unholdRes.setStatusCode(200);
         // }
         // if (unholdRes.getStatusCode() == 200) {
            ebIds.add(oEbm.Expocad_Booth__c);
            if (quoteToBoothNumber.containsKey(oEbm.Quote__c)) {              quoteToBoothNumber.get(oEbm.Quote__c).add(oEbm.Booth_Number__c);
            } else {
              Set<String> boothNumberSet = new Set<String>();
              boothNumberSet.add(oEbm.Booth_Number__c);
              quoteToBoothNumber.put(oEbm.Quote__c, boothNumberSet);
            }
          //}
        }
      }
      if (!ebIds.isEmpty()) {
        for (ExpocadBooth__c oEb : EBEnhancementUtil.ebListFromEbm(ebIds)) {
          oEb.status__c = 'Released';
          oEb.Selected__c = false;
          oEb.IsUnrentedByExhibitor__c = true;
          oEb.IsrentedByExhibitor__c = true;
          expoUnrent.add(oEb);
        }
      }
      if (!expoUnrent.isEmpty() && Schema.sObjectType.ExpocadBooth__c.isUpdateable()) {
        update expoUnrent;
        //Removing booth Number reference from quotelineitems.
        if (!quoteToBoothNumber.isEmpty()) {
          EBEnhancementUtil.removeBNFromQLi(quoteToBoothNumber);
        }
      }
      shouldRedirect = true;
      redirectUrl = sHost + '/' + oOpportunity.Id;
      if (isLightingEnv) {pageReference pg = new pageReference('/' + oOpportunity.Id); return pg;
      }
    } 
  /*    else {
        //Set to hold id of opportunity and eb mapping records to remove related opp. This is done to make booth available to other opportunities when it(booth) is relased from related opportunity. Imp : Booth is not actually released from a related opportunity, but the mapping is deactivated.
        Set<Id> ebmToDeactivate = new Set<Id>();
        System.debug('lstEbM 256' + lstEbM);
        
        for (Opportunity_ExpoCAD_Booth_Mapping__c oEbm : lstEbM) {
            if (oEbm.Expocad_Booth__r.Selected__c && oEbm.Expocad_Booth__r.Booth_Number__c != null) {
                if (Test.isRunningTest()) {
                    oEbm.Expocad_Booth__r.Selected__c = true;
                    oEbm.Expocad_Booth__r.Booth_Number__c = 'EB-102';
                }
                ebmToDeactivate.add(oEbm.Id);
                if (quoteToBoothNumber.containsKey(oEbm.Quote__c)) {
                    quoteToBoothNumber.get(oEbm.Quote__c).add(oEbm.Booth_Number__c);
                } else {
                    Set<String> boothNumberSet = new Set<String>();
                    boothNumberSet.add(oEbm.Booth_Number__c);
                    quoteToBoothNumber.put(oEbm.Quote__c, boothNumberSet);
                }
            }
        }
        
        // Deactivate oppEbMapping to inactive to show unrent.
        if (!ebmToDeactivate.isEmpty()) {
            EBEnhancementUtil.deactivateEBOppMapping(ebmToDeactivate);
            if (!quoteToBoothNumber.isEmpty()) {
                EBEnhancementUtil.removeBNFromQLi(quoteToBoothNumber);
            }
        }
        
        shouldRedirect = true;
        redirectUrl = sHost + '/' + oOpportunity.Id;
        if (isLightingEnv) {
        pageReference pg = new pageReference('/' + oOpportunity.Id);
        return pg;
      }
    }   */
    return null;
  }

  /**
   * @description Creating Account, Contact and Opportunity using new account details
   * @return PageReference
   */
  public pageReference createOpptybyNewAccount() {
    try {
      if (!String.isBlank(oAccount.Name) && !String.isBlank(oAccount.CurrencyIsoCode) && Schema.sObjectType.Account.isCreateable()) {
        insert oAccount;
        if (!String.isBlank(oAccount.Id) && Schema.sObjectType.Contact.isCreateable()) {
          oContact.AccountId = oAccount.Id;          insert oContact;          if (!String.isBlank(oContact.Id)) {            selectedAccountId = oAccount.Id;
            selectedContactId = oContact.Id;            sOpptyName2 = sOpptyName;            return this.createRelatedOppty();
          }
        }
      }
    } catch (Exception ex) {Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'createOpptybyNewAccount(@Association_Eb_CtrlEnh.Class)');} return null;
  }

  /**
   * @description Creating  Contact and Opportunity using existing account
   * @return PageReference
   */
  public pageReference createOpptyNewContact() {
    try {
      if (!String.isBlank(selectedAccountId) && Schema.sObjectType.Contact.isCreateable()) { oContact2.AccountId = selectedAccountId; insert oContact2; if (!String.isBlank(oContact2.Id)) { selectedContactId = oContact2.Id; sOpptyName2 = sOpptyName3; return this.createRelatedOppty();}}    } catch (Exception ex) {Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'createOpptyNewContact(@Association_Eb_CtrlEnh.Class)');
    }
    return null;
  }

  public pageReference updateDisplayName() {
    List<Opportunity_ExpoCAD_Booth_Mapping__c> lstEbMUpdate = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
    try {
      for (Opportunity_ExpoCAD_Booth_Mapping__c oppEbm : lstEbM) {oppEbm.Display_Name__c = sDisplayName;
        //BK-2085 Modified By Avinash Shukla -13 Aug 2019
        lstEbMUpdate.add(oppEbm);
      }
      if (lstEbMUpdate.size() > 0 && Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isUpdateable()) {update lstEbMUpdate;      }    } catch (Exception ex) {Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'updateDisplayName(@Association_Eb_CtrlEnh.Class)');
    }
    PageReference tempPage = new PageReference( '/' + oOpportunity.Id );            
    tempPage.setRedirect(true);
    return tempPage;
    //return null;
  }

  /**
  * @description Creating  Opportunity using existing account and Contact
  * @return PageReference
  */
  public pageReference createRelatedOppty() {
    Savepoint spRollBack = Database.setSavepoint();
    System.debug('Test Rajesh created oppp');
    
    try {
      // GGCW-2690 : Modified By Avinash, GGCW-2880,2881 : Modified By Avinash , Only one exhibitor per agent's opportunity.
      String selectedProductType = '';
      Boolean checkIfExhibitor = false;
      String ebIdToUpdateMPN = '';
      String sPrdNameToAdd = '';
      ExhibitorForUserType__c exhibitorUserType;
      if ( oOpportunity.Exhibitor_Paid_By__c == NULL ) {        exhibitorUserType = ExhibitorForUserType__c.getValues( 'NULL' );
      } else if ( oOpportunity.Exhibitor_Paid_By__c != NULL ) {
        exhibitorUserType = ExhibitorForUserType__c.getValues( oOpportunity.Exhibitor_Paid_By__c );      } 



      List<Opportunity_ExpoCAD_Booth_Mapping__c> lstEbmtoInsert = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
      List<Opportunity_ExpoCAD_Booth_Mapping__c> lstEbmtoUpdate = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
      
      /**
            Modified By: Yash Gupta
            @description As per ticket no. GGCW-3351, I have assign contact Id in billing contact while creating related opportunity.
      */
      /*List<Contact> oCont = new List<Contact>();
      if(String.isNotBlank(selectedContactId)){
        oCont = [select Id from Contact where Id=:selectedContactId AND Contact_Type__c INCLUDES ('Billing','Invoice Contact')];
      }*/
      relatedOppty = new opportunity();
      relatedOppty.Name = sOpptyName2;
      String stageName = System.Label.Opportunity_Stage_Name_Discover;
      relatedOppty.stageName = stageName;
      relatedOppty.accountId = selectedAccountId;
      relatedOppty.CloseDate = oOpportunity.EventEdition__r.Start_Date__c;
      relatedOppty.Parent_Opportunity__c = oOpportunity.id;
      relatedOppty.CurrencyIsoCode = oOpportunity.CurrencyIsoCode;
      relatedOppty.Event_Edition_Currency__c = oOpportunity.Event_Edition_Currency__c;
      relatedOppty.Opportunity_Contact__c = selectedContactId;
      relatedOppty.Billing_Contact__c = selectedContactId;
      relatedOppty.Type = oOpportunity.Type;


      
      /**
            Modified By: Yash Gupta
            @description As per ticket no. GGCW-3351, I have assign contact Id in billing contact while creating related opportunity.
      */
      /*if(oCont.size() > 0){
        relatedOppty.Billing_Contact__c = selectedContactId;
      }*/
        relatedOppty.Event_Series__c = oOpportunity.Event_Series__c;
        relatedOppty.EventEdition__c = oOpportunity.EventEdition__c;
        relatedOppty.Exhibitor_Paid_By__c = oOpportunity.Exhibitor_Paid_By__c;
        relatedOppty.Agent_s_Opportunity__c = oOpportunity.Agent_s_Opportunity__c;
        //update boolean check box after create related opportunity : BK - 2264
        relatedOppty.RelatedOpportunityForZeroAmount__c  = true;
        // Updating fields to check if the opportunity is the first child or the second child.
        // Modified By Avinash.

        //By pass validation rule if we are using releated opportunity button
        relatedOppty.By_Pass_Validation_Rule__c  = true;
        if (!isMainOpp) {
            if (oOpportunity.isFirstChild__c) {                relatedOppty.isFirstChild__c = true;   relatedOppty.isSecondChild__c = true;  if (oOpportunity.User_Type__r.Name == 'Agent Owned Exhibitor') {   relatedOppty.Exhibitor_Paid_By__c = 'Co-Exhibitor Paid by Exhibitor';
               // GGCW-2707 - Modified By Avinash.                                                                                                                                               
                } 
            }
        } else if (isMainOpp) {            relatedOppty.isFirstChild__c = true;            if (oOpportunity.Exhibitor_Paid_By__c == 'Individual Contract') { relatedOppty.Exhibitor_Paid_By__c = 'Co-Exhibitor Paid by Exhibitor';
            }
        }


      //Insert related opportunity.
      Database.SaveResult svResult = Database.insert(relatedOppty, false);
      if (!svResult.isSuccess()) {
        String errorMsg = svResult.getErrors()[0].getMessage();
          system.debug('tets rajesh ssss' + errorMsg);
        // GGCW- 2729 - Modified by Avinash
        if (errorMsg.IndexOf('first error:') != -1) {          errorMsg = errorMsg.substring(errorMsg.IndexOf('first error:') + 13, errorMsg.IndexOf('.', errorMsg.IndexOf('first error:')));isShowMsg = true ;          sShowMsg = errorMsg;          return null;
        } else {
          errorMsg = svResult.getErrors()[0].getMessage();
          isShowMsg = true ;          sShowMsg = errorMsg;          return null;
        }
      } 
      else {
        for (Opportunity_ExpoCAD_Booth_Mapping__c oEbm : lstEbM) {
          if (oEbm.Expocad_Booth__r.Selected__c) {            if (oEbm.Relation__c == 'Agent') {              oEbm.Related_Opportunity__c = relatedOppty.id;              checkIfExhibitor = true;              ebIdToUpdateMPN = oEbm.Expocad_Booth__r.Id;
            }
            //MOdified by Avinash for Jira Ticket BK-2134
              if(oOpportunity.User_type__r.Name == 'Agent'){selectedProductType = oEbm.Selected_Booth_Product_Type__c;    
              }
              else{                  selectedProductType = oEbm.Expocad_Booth__r.Booth_Product_Type_EE__c;
              }
              lstEbmtoUpdate.add(oEbm);
              //MOdified by Avinash for Jira Ticket BK-2134   
            }
        }
        
        // Creating quote for related opportunity.
        objQuote = new SBQQ__Quote__c();        objQuote.SBQQ__Opportunity2__c = relatedOppty.id;        objQuote.SBQQ__Account__c = relatedOppty.Accountid;        objQuote.SBQQ__StartDate__c = date.today();
        objQuote.SBQQ__Primary__c = false;        objQuote.SBQQ__ExpirationDate__c = date.today().adddays(30);        objQuote.CurrencyIsoCode = relatedOppty.CurrencyIsoCode;        objQuote.SBQQ__PrimaryContact__c = relatedOppty.Opportunity_Contact__c;
        //MOdified by Avinash for Jira Ticket BK-2134
        objQuote.Booth_Product_Type__c = selectedProductType;        objQuote.Billing_Contact__c = selectedContactId;
        // GGCW-2079
        objQuote.Parent_Opp_Primary_Quote_Total__c = oOpportunity.Amount;
        // Inserting quote for related opportunity.
        Database.SaveResult svResultQt = Database.insert(objQuote, false);
        if (!svResultQt.isSuccess()) {          String errorMsg = svResultQt.getErrors()[0].getMessage();if (errorMsg.IndexOf('first error:') != -1) {  errorMsg = errorMsg.substring(errorMsg.IndexOf('first error:') + 13, errorMsg.IndexOf('.', errorMsg.IndexOf('first error:')));isShowMsg = true ;    sShowMsg = errorMsg;  Database.rollback(spRollBack);  return null;} else {errorMsg = svResultQt.getErrors()[0].getMessage();   isShowMsg = true ;  sShowMsg = errorMsg;  Database.rollback(spRollBack);  return null;}
        } 
        else { 

          // GGCW-2690 : Modified By Avinash
          if (!lstEbmtoUpdate.isEmpty()) {
            List < SBQQ__QuoteLine__c > lstQuoteLine = new List < SBQQ__QuoteLine__c > ();            List < SBQQ__QuoteLine__c > lstPackageQuoteLine = new List < SBQQ__QuoteLine__c > ();
            SBQQ__QuoteLine__c oQuoteLine;            this.getBoothProducts();            Integer quoteLineNumber = 1;
            // GGCW-2690 : Modified By Avinash
            // GGCW-2879 : Modified By Avinash
            Opportunity_ExpoCAD_Booth_Mapping__c oEbm = lstEbmtoUpdate.get(0);

            ExpocadClasses.Booth oExpoBooth = new ExpocadClasses.Booth();            oExpoBooth.BoothType = oEbm.Expocad_Booth__r.Booth_Type__c;
            oExpoBooth.ShowInShow = oEbm.Expocad_Booth__r.ShowInShow__c;            oExpoBooth.Pavilion = oEbm.Expocad_Booth__r.Pavilion__c;
            if (!String.isBlank(oEbm.Expocad_Booth__r.Booth_Classes__c)) {              oExpoBooth.BoothClasses = oEbm.Expocad_Booth__r.Booth_Classes__c.split(';;');
            }
            //oExpoBooth.BoothClass = oEbm.Expocad_Booth__r.Booth_Product_Type_EE__c;BK-2134
            oExpoBooth.BoothClass = selectedProductType;     BoothSelectionCtrl.mapProductOptionsId = this.mapProductOptionsId;
            sPrdNameToAdd = BoothSelectionCtrl.SBPrd(oExpoBooth, oOpportunity, boothPackageProduct);            Map < String, Id > mapPackageprdIds = new Map < String, Id > ();
              
            if ((!String.isBlank(sPrdNameToAdd) && mapProductOptions.get(sPrdNameToAdd) != null) || test.isRunningTest()) {
              Double quantity = getQuantity(oEbm.Expocad_Booth__r.Area__c);
              /* Adding Package Product*/
              String packageId;
              oQuoteLine = new SBQQ__QuoteLine__c();              oQuoteLine.SBQQ__Quote__c = objQuote.Id;              oQuoteLine.SBQQ__Product__c = boothPackageProduct.Id; //LinearProduct.ID;
              oQuoteLine.SBQQ__Quantity__c = 1;              oQuoteLine.SBQQ__NonDiscountable__c = boothPackageProduct.SBQQ__NonDiscountable__c;              oQuoteLine.SBQQ__Hidden__c = boothPackageProduct.SBQQ__Hidden__c;              oQuoteLine.SBQQ__Number__c = quoteLineNumber;
              oQuoteLine.Booth_Number__c = oEbm.Expocad_Booth__r.Booth_Number__c;              oQuoteLine.Open_Corners__c = oEbm.Expocad_Booth__r.Open_Corners__c;              oQuoteLine.Booth__c = true;              oQuoteLine.Show_In_Show__c = oEbm.Expocad_Booth__r.ShowInShow__c;
              oQuoteLine.Booth_Pavilion__c = oEbm.Expocad_Booth__r.Pavilion__c;              oQuoteLine.Booth_Type__c = oEbm.Expocad_Booth__r.Booth_Type__c;              oQuoteLine.Booth_Classes__c = oEbm.Expocad_Booth__r.Booth_Classes__c;
              //oQuoteLine.Booth_Product_Type__c = oEbm.Expocad_Booth__r.Booth_Product_Type_EE__c;
              //MOdified by Avinash for Jira Ticket BK-2134
              oQuoteLine.Booth_Product_Type__c = selectedProductType;
              //update boolean check box after create related opportunity : BK - 2264
              oQuoteLine.RelatedOppQLForZeroAmount__c = true;              lstPackageQuoteLine.add(oQuoteLine);              if (oQuoteLine.Booth_Number__c != NULL) {                mapPackageprdIds.put(oQuoteLine.Booth_Number__c, oQuoteLine.id);
              }
              quoteLineNumber++;

              SBProductConfiguration oPrdConfiguration = new SBProductConfiguration();              SBProductConfiguration.TinyConfigurationModel oPrdConfigurationModel = new SBProductConfiguration.TinyConfigurationModel();
              oPrdConfigurationModel = oPrdConfiguration.getConfigurationAfterFireProductRule(boothPackageProduct.Id, objQuote.SBQQ__PriceBook__c, mapProductOptions.get(sPrdNameToAdd).Id, mapProductOptions.get(sPrdNameToAdd).SBQQ__OptionalSKU__c, quantity);
              if (!oPrdConfigurationModel.optionConfigurations.isEmpty()) {                for (SBProductConfiguration.TinyConfigurationModel oTempConfgModel : oPrdConfigurationModel.optionConfigurations) { if (mapProductOptions.get(cornerProductName) != null && mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__c != oTempConfgModel.optionData.SBQQ__OptionalSKU__c) {
                    // Adding Products to quote line item
                    oQuoteLine = new SBQQ__QuoteLine__c(); oQuoteLine.SBQQ__Quote__c = objQuote.Id; oQuoteLine.SBQQ__ProductOption__c = oTempConfgModel.optionData.Id;   oQuoteLine.SBQQ__Product__c = oTempConfgModel.optionData.SBQQ__OptionalSKU__c; oQuoteLine.SBQQ__Quantity__c = oTempConfgModel.optionData.SBQQ__Quantity__c; oQuoteLine.SBQQ__Number__c = quoteLineNumber;  oQuoteLine.SBQQ__NonDiscountable__c = mapProductOptionsId.get(oTempConfgModel.optionData.Id).SBQQ__OptionalSKU__r.SBQQ__NonDiscountable__c; oQuoteLine.SBQQ__Hidden__c = mapProductOptionsId.get(oTempConfgModel.optionData.Id).SBQQ__OptionalSKU__r.SBQQ__Hidden__c;oQuoteLine.SBQQ__PricingMethodEditable__c = True;  oQuoteLine.SBQQ__BundledQuantity__c = oTempConfgModel.optionData.SBQQ__Quantity__c;                        oQuoteLine.Line_Description__c = oEbm.Expocad_Booth__r.Booth_Number__c + '-' + oEbm.Expocad_Booth__r.Booth_Type__c; oQuoteLine.Booth_Number__c = oEbm.Expocad_Booth__r.Booth_Number__c;   oQuoteLine.Open_Corners__c = oEbm.Expocad_Booth__r.Open_Corners__c;oQuoteLine.Booth__c = true;  oQuoteLine.Show_In_Show__c = oEbm.Expocad_Booth__r.ShowInShow__c; oQuoteLine.Booth_Pavilion__c = oEbm.Expocad_Booth__r.Pavilion__c; oQuoteLine.Booth_Type__c = oEbm.Expocad_Booth__r.Booth_Type__c;oQuoteLine.Booth_Classes__c = oEbm.Expocad_Booth__r.Booth_Classes__c; oQuoteLine.RelatedOppQLForZeroAmount__c = true; oQuoteLine.Booth_Product_Type__c = selectedProductType; oQuoteLine.SBQQ__OptionType__c = 'Component';oQuoteLine.SBQQ__OptionLevel__c = 1  ;       
                    lstQuoteLine.add(oQuoteLine);   quoteLineNumber++;
                  }
                }
              }
              // Adding Corner Product
              if (oEbm.Expocad_Booth__r.Open_Corners__c != 0 && mapProductOptions.get(cornerProductName) != null) {
                oQuoteLine = new SBQQ__QuoteLine__c();                oQuoteLine.SBQQ__Quote__c = objQuote.Id; oQuoteLine.SBQQ__Product__c = mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__c; oQuoteLine.SBQQ__Quantity__c = oEbm.Expocad_Booth__r.Open_Corners__c; oQuoteLine.SBQQ__Number__c = quoteLineNumber; oQuoteLine.SBQQ__NonDiscountable__c = mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__r.SBQQ__NonDiscountable__c; oQuoteLine.SBQQ__Hidden__c = mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__r.SBQQ__Hidden__c; oQuoteLine.SBQQ__PricingMethodEditable__c = True; oQuoteLine.SBQQ__BundledQuantity__c = oEbm.Expocad_Booth__r.Open_Corners__c; oQuoteLine.SBQQ__OptionLevel__c = 1;  oQuoteLine.SBQQ__ProductOption__c = mapProductOptions.get(cornerProductName).Id;oQuoteLine.RelatedOppQLForZeroAmount__c = true;
                oQuoteLine.Line_Description__c = oEbm.Expocad_Booth__r.Booth_Number__c + '-' + oEbm.Expocad_Booth__r.Booth_Type__c; oQuoteLine.Booth_Number__c = oEbm.Expocad_Booth__r.Booth_Number__c;oQuoteLine.Open_Corners__c = oEbm.Expocad_Booth__r.Open_Corners__c;oQuoteLine.Booth__c = true; oQuoteLine.Show_In_Show__c = oEbm.Expocad_Booth__r.ShowInShow__c;oQuoteLine.Booth_Pavilion__c = oEbm.Expocad_Booth__r.Pavilion__c; oQuoteLine.Booth_Type__c = oEbm.Expocad_Booth__r.Booth_Type__c; oQuoteLine.Booth_Classes__c = oEbm.Expocad_Booth__r.Booth_Classes__c;oQuoteLine.Booth_Product_Type__c = selectedProductType; oQuoteLine.Corner_Premium__c = true; oQuoteLine.SBQQ__OptionType__c = 'Component'; 
                lstQuoteLine.add(oQuoteLine);                quoteLineNumber++;
              }
            } else if (String.isBlank(sPrdNameToAdd)) {              sShowMsg = 'Booth Product Type not present for the selected booth [' + oEbm.Expocad_Booth__r.Booth_Number__c + ']';
              isShowMsg = true;              Database.rollback(spRollBack);              return null;
            } else if (mapProductOptions.get(sPrdNameToAdd) == null) {
              sShowMsg = 'Product [' + selectedProductType + '] is not found for selected Booth [' + oEbm.Expocad_Booth__r.Booth_Number__c + ']';
              isShowMsg = true;              Database.rollback(spRollBack);              return null;
            }
            // GGCW-2690 : Modified By Avinash.
            Opportunity_ExpoCAD_Booth_Mapping__c objEbm = new Opportunity_ExpoCAD_Booth_Mapping__c();            objEbm.Opportunity__c = relatedOppty.Id;            objEbm.Account__c = selectedAccountId;objEbm.Expocad_Booth__c = oEbm.Expocad_Booth__r.Id; objEbm.Quote__c = objQuote.id;objEbm.Status__c = 'Active';  objEbm.Parent_Opp_EB_Mapping__c = oEbm.Id; objEbm.Primary_Contact__c = selectedContactId;
            /*** Modified By Yash Gupta [As per ticket GGCW-3307]*/           
            // GGCW-2709 : Modified By Avinash.
            if (exhibitorUserType != NULL) {              if (relatedOppty.isFirstChild__c && ! relatedOppty.isSecondChild__c) { objEbm.Relation__c = exhibitorUserType.Relation_for_Related_Oppty__c; }
              else if (relatedOppty.isFirstChild__c && relatedOppty.isSecondChild__c) {objEbm.Relation__c = exhibitorUserType.User_Type_of_Nested_Related__c;}
            }
            lstEbmtoInsert.add(objEbm);
            if (lstQuoteLine.size() > 0 && lstPackageQuoteLine.size() > 0 && Schema.sObjectType.SBQQ__QuoteLine__c.isUpdateable() && Schema.sObjectType.SBQQ__QuoteLine__c.isCreateable()) {
              Database.SaveResult[] sRlstPackageQuoteLine = Database.insert(lstPackageQuoteLine, true);              
              for (SBQQ__QuoteLine__c oQLI : lstQuoteLine) {                oQLI.SBQQ__RequiredBy__c = mapPackageprdIds.get(oQLI.Booth_Number__c);
              }
              If(!lstQuoteLine.IsEmpty()) {             insert lstQuoteLine;             
               }
            }

            if (!lstEbmtoInsert.isEmpty() && Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isCreateable() && Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isUpdateable()) {
              insert lstEbmtoInsert;  update lstEbmtoUpdate;
              //Modified by Avinash Shukla on 31/07/19 : BK-1221
              RemovedCoExhibitorClosedLost_class clsInstance = new RemovedCoExhibitorClosedLost_class(lstEbmtoInsert,NULL,True,false,false,True);clsInstance.mapOfParentEbm();
            }
            //Start GGCW-3256 - Rajesh Kumar
            Opportunity_ExpoCAD_Booth_Mapping__c oEbmToProcess = new Opportunity_ExpoCAD_Booth_Mapping__c();
            if (!lstEbmtoInsert.isEmpty()) { oEbmToProcess = lstEbmtoInsert.get(0);  String sDisplayNames = '';
              if (String.isBlank(oEbmToProcess.Expocad_Booth__r.Display_Name__c)) {sDisplayNames = oEbmToProcess.Account__r.Name;
              } else {sDisplayNames = oEbmToProcess.Expocad_Booth__r.Display_Name__c;}              BoothSelectionHlpr.AsyncExhibitor(oEbm.Expocad_Booth__r.Booth_Number__c, oEbm.Expocad_Booth__r.Event_Code__c, relatedOppty.id , objQuote.Id, relatedOppty.AccountId , oEbm.Expocad_API_URL__c , sDisplayNames) ;
            }
            //End GGCW-3256- Rajesh Kumar
          }
        }
      }
      //GGCW-3005 : Modified By Avinash Shukla, Calling method to update MPN on Expocad records as we are reaching salesforce governor limits.
      if (relatedOppty.Id != null) {
        //GGCW-3005 : Modified By Avinash, Adding condition : If related opportunity is from Agent's Opportunity then we enter the BPT, MPN details in EB record.
        if (checkIfExhibitor && ebIdToUpdateMPN != NULL && selectedProductType != NULL) {EBEnhancementUtil.udtEbMPN(ebIdToUpdateMPN, selectedProductType, sPrdNameToAdd);
        }
        shouldRedirect = true;        redirectUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + relatedOppty.Id;
      }
    } catch (exception ex) {Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'createRelatedOppty(@Association_Eb_CtrlEnh.Class)');  isShowMsg = true ; sShowMsg = ex.getMessage(); Database.rollback(spRollBack); return null;} return null;
  }

  /*** @description Getting all products for opportunity's event edition.*/
  public void getBoothProducts() {
    try {
      mapProductOptions = new Map < String, SBQQ__ProductOption__c > ();
      mapProductOptionsId = new Map < Id, SBQQ__ProductOption__c > ();
      String sBoothPackagePrdName;
      boothPackageProduct = new Product2();
      if (String.isNotBlank(oOpportunity.Event_Series__r.Package_Identifier__c)) {
      /*Changes done by Faisal for BK-23090*/
               if(String.isNotBlank(oOpportunity.EventEdition__r.Booth_Bundle_Type__c)){
                  sBoothPackagePrdName = oOpportunity.EventEdition__r.Booth_Bundle_Type__c+' '+oOpportunity.Event_Series__r.Package_Identifier__c;
                }
                else{
                    sBoothPackagePrdName = 'Booth Package ' + oOpportunity.Event_Series__r.Package_Identifier__c;
                }
      }
      //Updated filter criteria for product from product brand to event edition name in query.
      //Modified by Avinash BK-2700
      if (String.isNotBlank(sBoothPackagePrdName) && Schema.sObjectType.Product2.isAccessible()) {
        List < Product2 > lstTemp = [SELECT Id, Name, Number_of_Corners__c, Booth_Product_Type__c, SBQQ__NonDiscountable__c, SBQQ__Hidden__c FROM Product2 where Name = : sBoothPackagePrdName AND Event_Edition_Name__c = : oOpportunity.EventEdition__r.Name order by createdDate ASC LIMIT 1];
        if (lstTemp != null && lstTemp.size() > 0) {          boothPackageProduct = lstTemp.get(0);
        }
      }
      if (boothPackageProduct.Id != null) {        for (SBQQ__ProductOption__c oProductOption : [SELECT Id, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.Expiry_Date__c, SBQQ__OptionalSKU__r.SBQQ__NonDiscountable__c, SBQQ__OptionalSKU__r.SBQQ__Hidden__c, SBQQ__OptionalSKU__r.Booth_Type__c, SBQQ__OptionalSKU__r.Show_In_Show__c, SBQQ__OptionalSKU__r.Booth_Pavilion__c, SBQQ__OptionalSKU__r.Booth_Class__c, SBQQ__OptionalSKU__r.Booth_Product_Type__c FROM SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c = : boothPackageProduct.Id AND SBQQ__OptionalSKU__c != null LIMIT 1000]) {          mapProductOptions.put(oProductOption.SBQQ__OptionalSKU__r.Name, oProductOption);          mapProductOptionsId.put(oProductOption.Id, oProductOption);
          if (oProductOption.SBQQ__OptionalSKU__r.Name.toLowerCase().contains('corner booth fee')) {            cornerProductName = oProductOption.SBQQ__OptionalSKU__r.Name;
          }
        }
      }
    } catch (exception ex) {Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'getBoothProducts(@Association_Eb_CtrlEnh.Class)');isShowMsg = True ;sShowMsg = 'Please contact your system administrator to report this error' + '\n' + 'Debugged Error : ' + ex.getCause();}
  }
  /**
   * @description converting String value to double.
   * @param sQuantity
   * @return Double
   */
  public Double getQuantity(String sQuantity) {
    String sTempQuantity = sQuantity.substringBefore(' ');
    sTempQuantity = sTempQuantity.trim();
    return Double.valueof(sTempQuantity);
  }
  /**
   * @description creates a dynamic picklist values for BoothProductType, Called by page "Expocad_Booth_Plan" and "Boothselectionlghtn"
   * @return List <SelectOption>
   */
  public List < SelectOption > getBoothProductType() {
    List < SelectOption > lstSelectOption = new List < SelectOption > ();    if (oOpportunity != null) {      String sBoothType = oOpportunity.EventEdition__r.Booth_Product_Type__c;
      if (!String.isBlank(sBoothType)) {        List < SelectOption > lstSelectOption2 = new List < SelectOption > ();
        for (String sTemp : sBoothType.split(';')) {          lstSelectOption2.add(new SelectOption(sTemp, sTemp));        }
        lstSelectOption2.sort();        for (Integer i = lstSelectOption2.size() - 1; i >= 0; i--) {          lstSelectOption.add(lstSelectOption2.get(i));        }
        lstSelectOption.add(new SelectOption('Please Select', 'Please Select')) ;
                                                                                  
      } else {lstSelectOption.add(new SelectOption('No Product Type', 'No Product Type'));
      }
    }
    return lstSelectOption;
  }
  
  /**
   * @description This method queries all Contact data according to the passed accountId
   * @return PageReference
   */
  public void getContact() {  
    mapExistingContact = new Map < ID, Contact > ([SELECT Id, Name, Email, Phone FROM Contact WHERE AccountId = : selectedAccountId AND Inactive__c = false order by LastModifiedDate desc]);
    mapExistingContactSize = mapExistingContact.size(); 
    //return null;
  }
  /**
   * @description returns to a current Opportunity.
   * @return PageReference
   */
  public pageReference returnToPT() {
    pageReference pg = new pageReference('/' + oOpportunity.Id);
    return pg;
  }
  /**
   * @description directs to replace booth page.
   * @return PageReference
   */
  public pageReference replaceBooth() {
    shouldRedirect = true;
    redirectUrl = sHost + '/apex/ReplaceBooth?id=' + oOpportunity.Id;
    if (isLightingEnv) {
      pageReference pg;
      pg = new pageReference('/apex/ReplaceBooth?id=' + oOpportunity.Id + '&src=purchaseBooths');
      return pg;
    }
    return null;
  }
  
  /*public List<Opportunity_ExpoCAD_Booth_Mapping__c> getExpocadBoothMapping() {
    List<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpocadBooth = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
    If(String.IsNotBlank(opptyId)) {
      lstExpocadBooth = [SELECT id, Name , Area__c, Event_Code__c, Relation__c, Exhibitor_Rented__c, Expocad_API_URL__c, BoothProduct_Type_from_Quote__c, Quote__c, Booth_Product_type_From_Expocad_Booth__c, Expocad_Booth__c, Related_Opportunity__c, Related_Opportunity__r.Name, Expocad_Booth__r.Display_Name__c, Display_Name__c , Expocad_Booth__r.Selected__c, Expocad_Booth__r.Matched_Product_Name__c, Quote__r.Name, Quote__r.SBQQ__Primary__c, Expocad_Booth__r.User__r.Name, Expocad_Booth__r.Area__c, Expocad_Booth__r.Unit_Type__c, Expocad_Booth__r.Open_Corners__c, Expocad_Booth__r.Booth_Type__c, Expocad_Booth__r.Booth_Number__c, Booth_Number__c, Expocad_Booth__r.Dimensions__c, Expocad_Booth__r.Last_Action_Date__c, Expocad_Booth__r.Status__c, Opportunity__c, Account__c, Expocad_Booth__r.Related_Opportunity__c, Expocad_Booth__r.Related_Opportunity__r.Name, Opportunity__r.Name, Expocad_Booth__r.ShowInShow__c, Expocad_Booth__r.Pavilion__c, Expocad_Booth__r.Booth_Classes__c, Primary_Contact__r.Name, Expocad_Booth__r.Primary_Contact__c, Parent_Opp_EB_Mapping__c, Expocad_Booth__r.BoothContact__r.Name, Expocad_Booth__r.Booth_Product_Type_EE__c , Account__r.Name , Expocad_Booth__r.Event_Code__c , Is_Parent_Mapping__c from Opportunity_ExpoCAD_Booth_Mapping__c where Master_Opportunity__c = :opptyId AND Status__c = 'Active' ];
    }
    return lstExpocadBooth;
  }*/
}