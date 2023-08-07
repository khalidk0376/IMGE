/**
* File:        PopulateExpoDetailsCtrl.cls
* Project:     GAP
* Date:        Nov 21, 2016
* Created By:  Kumar Gaurav
* Test Class:  PopulateExpoDetailsCtrl_Test
* *************************************************************************
* @description Controller to populate the Booth Type, Number of Corners, Booth Size in to the event edition object fields using the
ExpoCAD API on button click.
* *************************************************************************
* History: Modified by Avinash for Jira Ticket GGCW-2191
*/

Public class PopulateExpoDetailsCtrl {

  /**
  * sEventEditionId
  * @description Apex variable
  */
  private String sEventEditionId ;
  @TestVisible
  /**
  * queryString
  * @description Apex variable
  */
  private string queryString;
  /**
  * oEventEdition
  * @description Apex variable
  */
  private Event_Edition__c oEventEdition ;
  /**
  * sErrorMsg
  * @description Apex variable
  */
  public String sErrorMsg {get; set;}
  /**
  * lstExpoBooth
  * @description Apex variable
  */
  private List<ExpocadClasses.Booth> lstExpoBooth;

  /**
  * @description Default Standard Constructor
  * @param  controller
  */
  public PopulateExpoDetailsCtrl(ApexPages.StandardController controller) {
    sEventEditionId = apexpages.currentpage().getparameters().get('id');
    queryString = ApexPages.currentPage().getParameters().get('from');
    if (!String.isBlank(sEventEditionId) && Schema.sObjectType.Event_Edition__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Event_Code__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Expocad_API_Url__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Booth_Type__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.No_Of_Corner__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Booth_Size__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Show_in_Show__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Pavilion__c.isAccessible()) {
      oEventEdition = [select Event_Code__c, Expocad_API_Url__c, Booth_Type__c, Booth_Class__c, No_Of_Corner__c, Booth_Size__c, Show_in_Show__c, Pavilion__c from Event_Edition__c where Id = : sEventEditionId LIMIT 1];
    }
  }

  /**
  * @description Constructor
  * @param  sEventEditionId
  */
  public PopulateExpoDetailsCtrl(Id sEventEditionId) {
    if (Schema.sObjectType.Event_Edition__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Event_Code__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Expocad_API_Url__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Booth_Type__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.No_Of_Corner__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Booth_Size__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Show_in_Show__c.isAccessible() && Schema.sObjectType.Event_Edition__c.fields.Pavilion__c.isAccessible()) {
      oEventEdition = [select Event_Code__c, Expocad_API_Url__c, Booth_Type__c, No_Of_Corner__c, Booth_Size__c, Show_in_Show__c, Pavilion__c from Event_Edition__c where Id = : sEventEditionId LIMIT 1];
    }
  }

  /**
  * @description This method syncs Expocad booth's parameter details to Event Edition.
  * @return PageReference
  */
  Public PageReference autorun() {
    PageReference pg = null;
    try {
      if (oEventEdition != null && String.isBlank(oEventEdition.Event_Code__c)) {
        sErrorMsg = System.Label.Event_Code_Not_Configured_Msg;
      } else if (oEventEdition != null && String.isBlank(oEventEdition.Expocad_API_Url__c)) {
        sErrorMsg = System.Label.Expocad_API_Url_Not_Configured_Msg;
      } else if (oEventEdition != null && !String.isBlank(oEventEdition.Event_Code__c)) {
        String sAPIUrl = oEventEdition.Expocad_API_Url__c + '/booths/all/?databaseName=' + oEventEdition.Event_Code__c;
        // GGCW-2191 - Modified By Avinash.
        HttpResponse res = new ExpocadResponses().request(sAPIUrl, 'GET', '');
        String sResBody = res.getBody();
        If(Test.isRunningTest()) {
          sResBody = '[{"ExhibitorId":"0012C000004oaCvQAI","BoothNumber":"KG7","Dimensions":"10","XSize":"10","YSize":"10","Area":"100 SqFt","Status":"Unknown","BoothClass":"Indoor","Pavilion":"pav1","ShowInShow":"Indoor","BoothType":"Peninsula","UnitType":"ftin","HoldExhibitorId":"","HoldExhibitorName":"","OpenCorners":2,"IsDeleted":false,"IsOnHold":false,"IsRented":false},{"ExhibitorId":"0012C000004oaCvQAI","BoothNumber":"KG7","Dimensions":"10","XSize":"10","YSize":"10","Area":"10.5 SqFt","Status":"Unknown","BoothClass":"Indoor","Pavilion":"Pav2","ShowInShow":"Indoor2","BoothType":"Peninsula","UnitType":"ftin","HoldExhibitorId":"","HoldExhibitorName":"","OpenCorners":0,"IsDeleted":false,"IsOnHold":false,"IsRented":false}]';
        }
        if (res.getStatus() == null) {
          sErrorMsg = System.Label.ExpoCAD_API_Down_Msg;
        } else if (res.getStatusCode() == 200) {
          System.debug('Response === ' + sResBody);
          lstExpoBooth  = (List<ExpocadClasses.Booth>)JSON.deserialize(sResBody, List<ExpocadClasses.Booth>.class);
          if (lstExpoBooth != null && lstExpoBooth.size() > 0) {
            Set<String> setProtectDupArea = new Set<String>();
            Set<String> setProtectDupPavilion = new Set<String>();
            Set<String> setProtectDupSIS = new Set<String>();
            Set<String> setProtectDupBoothType = new Set<String>();
            Set<String> setProtectDupOpenCorner = new Set<String>();
            Set<String> setProtectDupBoothClasses = new Set<String>();

            String sBoothType;
            String sNoOfCorner;
            String sBoothSize;
            String sPavilion;
            String sShowInShow;
            List<Double> tempBSlst = new List<Double>();
            String sTemp;
            String sUnit;
            for (ExpocadClasses.Booth oBooth : lstExpoBooth) {
              if (!String.isBlank(oBooth.Area) && !setProtectDupArea.contains(oBooth.Area)) {
                sTemp = oBooth.Area ;
                if (sUnit == null) {
                  sUnit = sTemp.substringAfter(' ');
                }
                sTemp = sTemp.substringBefore(' ');
                tempBSlst.add(double.valueOf(sTemp));
                setProtectDupArea.add(oBooth.Area);
              }
              if (!String.isBlank(oBooth.BoothType) && !setProtectDupBoothType.contains(oBooth.BoothType) && sBoothType == null) {
                sBoothType = oBooth.BoothType;
                setProtectDupBoothType.add(oBooth.BoothType);
              } else If(!String.isBlank(oBooth.BoothType) && !setProtectDupBoothType.contains(oBooth.BoothType) && sBoothType != null) {
                sBoothType += ',' + oBooth.BoothType;
                setProtectDupBoothType.add(oBooth.BoothType);
              }

              if (!String.isBlank(oBooth.Pavilion ) && !setProtectDupPavilion.contains(oBooth.Pavilion ) && sPavilion == null) {
                sPavilion = oBooth.Pavilion ;
                setProtectDupPavilion.add(oBooth.Pavilion );
              } else If(!String.isBlank(oBooth.Pavilion ) && !setProtectDupPavilion.contains(oBooth.Pavilion ) && sPavilion != null) {
                sPavilion += ',' + oBooth.Pavilion ;
                setProtectDupPavilion.add(oBooth.Pavilion);
              }

              if (!String.isBlank(oBooth.ShowInShow) && !setProtectDupSIS.contains(oBooth.ShowInShow) && sShowInShow == null) {
                sShowInShow = oBooth.ShowInShow ;
                setProtectDupSIS.add(oBooth.ShowInShow);
              } else If(!String.isBlank(oBooth.ShowInShow) && !setProtectDupSIS.contains(oBooth.ShowInShow) && sShowInShow != null) {
                sShowInShow += ',' + oBooth.ShowInShow ;
                setProtectDupSIS.add(oBooth.ShowInShow);
              }

              if (!setProtectDupOpenCorner.contains(String.valueof(oBooth.OpenCorners)) && sNoOfCorner == null) {
                sNoOfCorner = String.valueof(oBooth.OpenCorners);
                setProtectDupOpenCorner.add(String.valueof(oBooth.OpenCorners));
              } else If(!setProtectDupOpenCorner.contains(String.valueof(oBooth.OpenCorners)) && sNoOfCorner != null) {
                sNoOfCorner += ',' + String.valueof(oBooth.OpenCorners);
                setProtectDupOpenCorner.add(String.valueof(oBooth.OpenCorners));
              }
              If(oBooth.BoothClasses != NULL && oBooth.BoothClasses.size() > 0) {
                for (String sBoothClass : oBooth.BoothClasses) {
                  if (!String.isBlank(sBoothClass)) {
                    setProtectDupBoothClasses.add(sBoothClass);
                  }
                }
              }
            }
            if (tempBSlst.size() > 0) {
              tempBSlst.sort();
            }
            for (Double tempNum : tempBSlst) {
              sTemp = String.valueOf(tempNum);
              if (sBoothSize == null) {
                if (sTemp.substringAfter('.') == '0') {
                  sBoothSize = sTemp.substringBefore('.') + ' ' + sUnit;
                } else {
                  sBoothSize = sTemp + ' ' + sUnit;
                }
              } else {
                if (sTemp.substringAfter('.') == '0') {
                  sBoothSize += ',' + sTemp.substringBefore('.') + ' ' + sUnit;
                } else {
                  sBoothSize += ',' + sTemp + ' ' + sUnit;
                }
              }
            }

            //Modifed By Avinash :GGCW-2191
            String boothClasses = '';
            boothClasses = String.join(new List<String>(setProtectDupBoothClasses), ',');

            if (!boothClasses.equals(oEventEdition.Booth_Class__c) || !sBoothType.equals(oEventEdition.Booth_Type__c) || !sNoOfCorner.equals(oEventEdition.No_Of_Corner__c) || !sBoothSize.equals(oEventEdition.Booth_Size__c) || (!String.isBlank(sShowInShow) && !sShowInShow.equals(oEventEdition.Show_in_Show__c)) || (!String.isBlank(sPavilion) && !sPavilion.equals(oEventEdition.Pavilion__c))) {
              oEventEdition.Booth_Type__c     = sBoothType;
              oEventEdition.No_Of_Corner__c   = sNoOfCorner;
              oEventEdition.Booth_Size__c     = sBoothSize;
              oEventEdition.Show_in_Show__c   = sShowInShow;
              oEventEdition.Pavilion__c       = sPavilion;
              oEventEdition.Booth_Class__c    = boothClasses;
            }
            if (Schema.sObjectType.Event_Edition__c.isUpdateable()) {
              update oEventEdition;
            }
            pg = returnToPT();
          } else {
            sErrorMsg = 'No details found for event Code ' + oEventEdition.Event_Code__c + ' !';
          }
        }
      }
    } catch (Exception ex) {
      Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'autorun (@PopulateExpoDetailsCtrl)');
    }
    return pg;
  }

  /**
  * @description Return to Event edition Record
  * @return PageReference
  */
  public PageReference returnToPT() {
    //Modified by Mukesh[25 Nov,2019](remove skuid)
     pageReference pg = new pageReference('/' + sEventEditionId);
     pg.setRedirect(true);
     return pg;
  }
}