/**
* Project:     GAP
* Date:        26/11/2019
* Created By:  Adarsh Sharma
* Class:       SyncfromPreviousEE_Cls
* Coverage:    97%
* Test Class:  Test_SyncfromPreviousEE_Cls
* *********************************************************************************************************************************
* Description: Sync present event Edition from previous event edition (This calls the Visualforce Page Sync_from_Previous_EE.vfp).
* *********************************************************************************************************************************
*/
public Without Sharing class SyncfromPreviousEE_Cls {
    private String sEventEditionId = '';
    public string sErrorMsg {get; set;}
    public Event_Edition__c  oEventEdition;
    public List<Event_Edition__c> eeListUpdate  = new List<Event_Edition__c>();
    public SyncfromPreviousEE_Cls(ApexPages.StandardController controller) {
        sEventEditionId = apexpages.currentpage().getparameters().get('id');
        oEventEdition = new Event_Edition__c();
        if (!String.isBlank(sEventEditionId)) {
            oEventEdition = [select Id , Event_Currency__c , Alternate_Currency__c, Venue__c , Measurement__c , Event_Website__c , Event_Edition_Image_URL__c , Logo_Shape__c , Event_Price_Book__c , No_Billing__c ,All_Contract_Need_Accounting_Approval__c , Allow_Docusign_Counter_Sign__c , X1st_Stage_Email_Template__c , Subsequent_Email_Template__c , Quote_Template__c , Contract_Template__c , Invoice_Template__c , Credit_Note_Template__c , Credit_Note_Email_Template__c , Terms_Condition_Template__c , Max_Hold_Days__c, Max_Hold_Booth__c , Put_Booth_OnHold__c ,Corner_Validation__c , Corner_Configuration_Check__c , Allow_Unrenting_Rented_booths__c , Previous_Event_Edition__c ,
                             Previous_Event_Edition__r.Alternate_Currency__c, Previous_Event_Edition__r.Venue__c , Previous_Event_Edition__r.Measurement__c , Previous_Event_Edition__r.Event_Website__c , Previous_Event_Edition__r.Event_Edition_Image_URL__c , Previous_Event_Edition__r.Logo_Shape__c , Previous_Event_Edition__r.Event_Price_Book__c , Previous_Event_Edition__r.No_Billing__c , Previous_Event_Edition__r.All_Contract_Need_Accounting_Approval__c , Previous_Event_Edition__r.Allow_Docusign_Counter_Sign__c , Previous_Event_Edition__r.X1st_Stage_Email_Template__c , Previous_Event_Edition__r.Subsequent_Email_Template__c , Previous_Event_Edition__r.Quote_Template__c , Previous_Event_Edition__r.Contract_Template__c , Previous_Event_Edition__r.Invoice_Template__c , Previous_Event_Edition__r.Credit_Note_Template__c , Previous_Event_Edition__r.Credit_Note_Email_Template__c , Previous_Event_Edition__r.Terms_Condition_Template__c , Previous_Event_Edition__r.Max_Hold_Days__c, Previous_Event_Edition__r.Max_Hold_Booth__c , Previous_Event_Edition__r.Put_Booth_OnHold__c ,Previous_Event_Edition__r.Corner_Validation__c,Previous_Event_Edition__r.Corner_Configuration_Check__c , Previous_Event_Edition__r.Allow_Unrenting_Rented_booths__c , Previous_Event_Edition__r.Previous_Event_Edition__c , Previous_Event_Edition__r.Event_Currency__c from Event_Edition__c where Id = : sEventEditionId LIMIT 1];
        }
    }
    
    public PageReference autorun() {
        Boolean isSuccess = false;
        PageReference pg = null;
        if (oEventEdition != null && oEventEdition.Previous_Event_Edition__c == null) {
            sErrorMsg = System.Label.Sync_from_Previous_EE;
        }
        else {
            if (String.isBlank (oEventEdition.Event_Currency__c)){
                oEventEdition.Event_Currency__c = oEventEdition.Previous_Event_Edition__r.Event_Currency__c;
            }
            if (String.isBlank (oEventEdition.Alternate_Currency__c)){
                oEventEdition.Alternate_Currency__c = oEventEdition.Previous_Event_Edition__r.Alternate_Currency__c;
            }
            if (String.isBlank (oEventEdition.Venue__c)){
                oEventEdition.Venue__c = oEventEdition.Previous_Event_Edition__r.Venue__c;
            }
            if (String.isBlank (oEventEdition.Measurement__c)){
                oEventEdition.Measurement__c = oEventEdition.Previous_Event_Edition__r.Measurement__c;
            }
            if (String.isBlank (oEventEdition.Event_Website__c)){
                oEventEdition.Event_Website__c = oEventEdition.Previous_Event_Edition__r.Event_Website__c;
            }
            if (String.isBlank (oEventEdition.Event_Edition_Image_URL__c)){
                oEventEdition.Event_Edition_Image_URL__c = oEventEdition.Previous_Event_Edition__r.Event_Edition_Image_URL__c;
            }
            if (String.isBlank (oEventEdition.Logo_Shape__c)){
                oEventEdition.Logo_Shape__c = oEventEdition.Previous_Event_Edition__r.Logo_Shape__c;
            }
            if (String.isBlank (oEventEdition.Event_Price_Book__c)){
                oEventEdition.Event_Price_Book__c = oEventEdition.Previous_Event_Edition__r.Event_Price_Book__c;
            }
            if (!oEventEdition.No_Billing__c){
                oEventEdition.No_Billing__c = oEventEdition.Previous_Event_Edition__r.No_Billing__c;
            }if (!oEventEdition.All_Contract_Need_Accounting_Approval__c){
                oEventEdition.All_Contract_Need_Accounting_Approval__c = oEventEdition.Previous_Event_Edition__r.All_Contract_Need_Accounting_Approval__c;
            }
            if (!oEventEdition.Allow_Docusign_Counter_Sign__c){
                oEventEdition.Allow_Docusign_Counter_Sign__c = oEventEdition.Previous_Event_Edition__r.Allow_Docusign_Counter_Sign__c;
            }
            if (String.isBlank (oEventEdition.X1st_Stage_Email_Template__c)){
                oEventEdition.X1st_Stage_Email_Template__c = oEventEdition.Previous_Event_Edition__r.X1st_Stage_Email_Template__c;
            }
            if (String.isBlank (oEventEdition.Subsequent_Email_Template__c)){
                oEventEdition.Subsequent_Email_Template__c = oEventEdition.Previous_Event_Edition__r.Subsequent_Email_Template__c;
            }
            if (String.isBlank (oEventEdition.Quote_Template__c)){
                oEventEdition.Quote_Template__c = oEventEdition.Previous_Event_Edition__r.Quote_Template__c;
            }
            if (String.isBlank (oEventEdition.Contract_Template__c)){
                oEventEdition.Contract_Template__c = oEventEdition.Previous_Event_Edition__r.Contract_Template__c;
            }
            if (String.isBlank (oEventEdition.Invoice_Template__c)){
                oEventEdition.Invoice_Template__c = oEventEdition.Previous_Event_Edition__r.Invoice_Template__c;
            }
            if (String.isBlank (oEventEdition.Credit_Note_Template__c)){
                oEventEdition.Credit_Note_Template__c = oEventEdition.Previous_Event_Edition__r.Credit_Note_Template__c;
            }
            if (String.isBlank (oEventEdition.Credit_Note_Email_Template__c)){
                oEventEdition.Credit_Note_Email_Template__c = oEventEdition.Previous_Event_Edition__r.Credit_Note_Email_Template__c;
            }
            if (String.isBlank (oEventEdition.Terms_Condition_Template__c)){
                oEventEdition.Terms_Condition_Template__c = oEventEdition.Previous_Event_Edition__r.Terms_Condition_Template__c;
            }
            if (oEventEdition.Max_Hold_Days__c == null){
                oEventEdition.Max_Hold_Days__c = oEventEdition.Previous_Event_Edition__r.Max_Hold_Days__c;
            }
            if (oEventEdition.Max_Hold_Booth__c == null){
                oEventEdition.Max_Hold_Booth__c = oEventEdition.Previous_Event_Edition__r.Max_Hold_Booth__c;
            }
            if (!oEventEdition.Put_Booth_OnHold__c){
                oEventEdition.Put_Booth_OnHold__c = oEventEdition.Previous_Event_Edition__r.Put_Booth_OnHold__c;
            }
            if (!oEventEdition.Corner_Validation__c){
                oEventEdition.Corner_Validation__c = oEventEdition.Previous_Event_Edition__r.Corner_Validation__c;
            }
            if (!oEventEdition.Corner_Configuration_Check__c){
                oEventEdition.Corner_Configuration_Check__c = oEventEdition.Previous_Event_Edition__r.Corner_Configuration_Check__c;
            }
            if (!oEventEdition.Allow_Unrenting_Rented_booths__c){
                oEventEdition.Allow_Unrenting_Rented_booths__c = oEventEdition.Previous_Event_Edition__r.Allow_Unrenting_Rented_booths__c;
            }
            eeListUpdate.add(oEventEdition);
            if (Schema.sObjectType.Event_Edition__c.isUpdateable()) {
                Database.SaveResult srList = Database.update(eeListUpdate.get(0), false);
                If(srList.isSuccess()){
                    isSuccess = true;          
                }
                update oEventEdition;
            }
            if (isSuccess){
                pg = returnToPT(); 
            }
        }       
        return pg;
    }
    
    public PageReference returnToPT() {
        pageReference pg = new pageReference('/' + sEventEditionId);
        pg.setRedirect(true);
        return pg;
    }
}