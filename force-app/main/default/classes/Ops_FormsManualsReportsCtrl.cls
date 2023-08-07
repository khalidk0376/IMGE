/**
 * Created By       :   Girikon(Himanshu[STL-145])
 * Created On       :   10/23/2019
 * @description     :   Used by For Forms and manuals Export Report Functionality
 * Test Class       :  Ops_FormsManualsReportsCtrl_Test(87%)
 **/


public class Ops_FormsManualsReportsCtrl {
    public list < User_Manual_Action__c > lstData {
        get;
        set;
    }
     public list < User_Form_Action__c > lstDataForm {
        get;
        set;
    }
    public string fileName {
        get;
        set;
    }
    public string table {
        get;
        set;
    }
    public List < wrapperClass > lstwrapper {
        get;
        set;
    }
    // Method name is changed by Palla Kishore for the ticket BK-19606
    public void Ops_FormsManualsReportsCtrlMethod() {
        string recordId = ApexPages.currentPage().getParameters().get('recordid');
        lstwrapper = new List < wrapperClass > ();

    }
    
        /*
* @description [getReport data from user form and manual custom objects]
* @return [ void ]
*/
    public void fetchData() {
        string recordId = ApexPages.currentPage().getParameters().get('recordid');
        string action = ApexPages.currentPage().getParameters().get('action');
        string tab = ApexPages.currentPage().getParameters().get('tab');
        string type = ApexPages.currentPage().getParameters().get('type');

        if (type == 'manuals')
         {
            if (action == 'Viewed' && tab == 't1') {
                lstData = [Select id,User_Manual_Contact__r.Name, Manual_Permission__r.Manuals__r.name, Account__r.Name, User_Type__r.Name, Is_Viewed__c, Is_Agree__c, User_Manual_Contact__r.Email 
                           From User_Manual_Action__c 
                           Where Manual_Permission__r.Active__c = true
                           And Is_Viewed__c = true 
                           And Manual_Permission__r.Manuals__c =: recordId 
                           Limit 10000];
                table = 'Secondary';
                if (lstData != null && !lstData.isEmpty()) {
                    fileName = 'Manual- ' + lstData[0].Manual_Permission__r.Manuals__r.Name + '.csv';

                }
            } else if (action == 'Viewed' && tab == 't2') {
                lstData = [Select id,User_Manual_Contact__r.Name, Manual_Permission__r.Manuals__r.name, Account__r.Name, User_Type__r.Name, Is_Viewed__c, Is_Agree__c, User_Manual_Contact__r.Email 
                           From User_Manual_Action__c
                           Where Manual_Permission__r.Active__c = true 
                           And Is_Viewed__c = false 
                           And Manual_Permission__r.Manuals__c =: recordId  
                           Limit 10000];
                table = 'Secondary';
                if (lstData != null && !lstData.isEmpty()) {
                    fileName = 'Manual- ' + lstData[0].Manual_Permission__r.Manuals__r.Name + '.csv';

                }
            } else if (action == 'Agreed' && tab == 't1') {
                lstData = [Select id,User_Manual_Contact__r.Name, Manual_Permission__r.Manuals__r.name, Account__r.Name, User_Type__r.Name, Is_Viewed__c, Is_Agree__c, User_Manual_Contact__r.Email 
                           From User_Manual_Action__c 
                           Where Manual_Permission__r.Active__c = true 
                           And Is_Agree__c = true 
                           And Manual_Permission__r.Manuals__c =: recordId  
                           Limit 10000];
                table = 'Secondary';
                if (lstData != null && !lstData.isEmpty()) {
                    fileName = 'Manual- ' + lstData[0].Manual_Permission__r.Manuals__r.Name + '.csv';

                }
            } else if (action == 'Agreed' && tab == 't2') {
                lstData = [Select id,User_Manual_Contact__r.Name, Manual_Permission__r.Manuals__r.name, Account__r.Name, User_Type__r.Name, Is_Viewed__c, Is_Agree__c, User_Manual_Contact__r.Email 
                           From User_Manual_Action__c 
                           Where Manual_Permission__r.Active__c = true 
                           And Is_Agree__c = false 
                           And Manual_Permission__r.Manuals__c =: recordId  
                           Limit 10000];
                table = 'Secondary';
                if (lstData != null && !lstData.isEmpty()) {
                    fileName = 'Manual- ' + lstData[0].Manual_Permission__r.Manuals__r.Name + '.csv';

                }
            } 
            else {
                string eventedition = ApexPages.currentPage().getParameters().get('eventedtid');
                lstData = [Select id, Manual_Permission__r.Manuals__r.Name,Account__r.Name, User_Manual_Contact__r.Account.Name, User_Manual_Contact__r.Name,User_Manual_Contact__r.Email, Is_Viewed__c, Is_Agree__c, User_Type__r.Name 
                           From User_Manual_Action__c 
                           Where Manual_Permission__r.Manuals__r.Event_Edition__c =: eventedition 
                           And Manual_Permission__r.Active__c = true 
                           And Account__c != null  
                           Limit 10000];
                if (lstData != null && !lstData.isEmpty()) {
                    fileName = 'ManualExportData.csv';
                }
                table = 'Primary';
            }


            if (lstData != null && lstData.size() > 0) {
                lstwrapper = new list<wrapperClass>();
                for (User_Manual_Action__c data: lstData) {
                    wrapperClass objWrapperClass = new wrapperClass(); // wrapper class to store the data

                    objWrapperClass.Name = data.Manual_Permission__r.Manuals__r.Name;
                    objWrapperClass.AccountName = data.Account__r.Name;
                    objWrapperClass.ContactName = data.User_Manual_Contact__r.Name;
                    objWrapperClass.IsViewed = data.Is_Viewed__c;
                    objWrapperClass.IsAgree = data.Is_Agree__c;
                    objWrapperClass.UserType = data.User_Type__r.Name;
                    objWrapperClass.Email = data.User_Manual_Contact__r.Email;

                    lstwrapper.add(objWrapperClass);
                }
            }

        }
        else{
 			 table = 'FormReport';
            if (action == 'Viewed' && tab == 't1') {
                    lstDataForm = [Select id,User_Form_Contact__r.Name,Is_Viewed__c,Is_Filled_Up__c,Form_Submitted__c,Form_Permission__r.Event_Edition_Form__r.Forms__r.Name,Account__r.Name,User_Type__r.Name,User_Form_Contact__r.Email 
                                   From User_Form_Action__c 
                                   Where Form_Permission__r.Active__c = true 
                                   And Is_Viewed__c  = true 
                                   And Form_Permission__r.Event_Edition_Form__c=:recordId 
                                   AND Account__c!=null  
                                   Limit 10000] ;
                    if (lstDataForm != null && !lstDataForm.isEmpty()) {
                        fileName = 'Form- ' + lstDataForm[0].Form_Permission__r.Event_Edition_Form__r.Forms__r.Name  + '.csv';
                    }
                } else if (action == 'Viewed' && tab == 't2') {
    
                    lstDataForm = [Select id,User_Form_Contact__r.Name,Is_Viewed__c,Is_Filled_Up__c,Form_Submitted__c,Form_Permission__r.Event_Edition_Form__r.Forms__r.Name,Account__r.Name,User_Type__r.Name,User_Form_Contact__r.Email 
                                   From User_Form_Action__c 
                                   Where Form_Permission__r.Active__c = true 
                                   And Is_Viewed__c = false 
                                   And Form_Permission__r.Event_Edition_Form__c =: recordId 
                                   AND Account__c!=null  
                                   Limit 10000] ;
                    table = 'FormReport';
                    if (lstDataForm != null && !lstDataForm.isEmpty()) {
                        fileName = 'Form- ' + lstDataForm[0].Form_Permission__r.Event_Edition_Form__r.Forms__r.Name  + '.csv';
                    }
                } else if (action == 'Agreed' && tab == 't1') {
                    // for submitted 
                     lstDataForm = [Select id,Is_Viewed__c,Is_Filled_Up__c,User_Form_Contact__r.Name,Form_Submitted__c,Form_Permission__r.Event_Edition_Form__r.Forms__r.Name,Account__r.Name,User_Type__r.Name,User_Form_Contact__r.Email
                                    From User_Form_Action__c 
                                    Where Form_Permission__r.Active__c = true 
                                    And Is_Filled_Up__c = true 
                                    And Form_Permission__r.Event_Edition_Form__c =: recordId 
                                    AND Account__c!=null 
                                    limit 10000] ;
                    
                    if (lstDataForm != null && !lstDataForm.isEmpty()) {
                    fileName = 'Form- ' + lstDataForm[0].Form_Permission__r.Event_Edition_Form__r.Forms__r.Name  + '.csv';
                   table = 'FormReportSubmitted';
                    }
                } else if (action == 'Agreed' && tab == 't2') {
                        lstDataForm = [Select id,Is_Viewed__c,User_Form_Contact__r.Name,Is_Filled_Up__c,Form_Submitted__c,Form_Permission__r.Event_Edition_Form__r.Forms__r.Name,Account__r.Name,User_Type__r.Name,User_Form_Contact__r.Email
                                       From User_Form_Action__c
                                       Where Form_Permission__r.Active__c = true 
                                       And Is_Filled_Up__c = false 
                                       And Form_Permission__r.Event_Edition_Form__c =: recordId 
                                       AND Account__c!=null  
                                       Limit 10000] ;
                    if (lstDataForm != null && !lstDataForm.isEmpty()) {
                        fileName = 'Form- ' + lstDataForm[0].Form_Permission__r.Event_Edition_Form__r.Forms__r.Name  + '.csv';
                    }
                      table ='FormReportNotSubmitted';
                } 
                else {
                   // for drop down first option 

                    table ='FormReportExportMarketing';
                    string eventedition = ApexPages.currentPage().getParameters().get('eventedtid');
                    lstDataForm = [Select id,Is_Filled_Up__c,Form_Submitted__c,User_Form_Contact__r.Name,Is_Viewed__c,Form_Permission__r.Event_Edition_Form__r.Forms__r.Name,Account__r.Name,User_Type__r.Name,User_Form_Contact__r.Email
                                   From User_Form_Action__c
                                   Where Form_Permission__r.Active__c = true 
                                   And Is_Filled_Up__c = true 
                                   And  Form_Permission__r.Event_Edition_Form__c =: recordId 
                                   AND Account__c!=null  
                                   Limit 10000] ;


                    if (lstDataForm != null && !lstDataForm.isEmpty()) {
                        fileName = 'Form- ' + lstDataForm[0].Form_Permission__r.Event_Edition_Form__r.Forms__r.Name  + '.csv';
                    }
                    }
                // assign value to wrapper class 
                if (lstDataForm != null && lstDataForm.size() > 0) {
                    lstwrapper = new list<wrapperClass>();
                    for (User_Form_Action__c data: lstDataForm) {
                        wrapperClass objWrapperClass = new wrapperClass(); // wrapper class to store the data
                        objWrapperClass.Name = data.Form_Permission__r.Event_Edition_Form__r.Forms__r.Name;
                        objWrapperClass.IsViewed = data.Is_Viewed__c;
                        objWrapperClass.AccountName = data.Account__r.Name;
                        objWrapperClass.UserType = data.User_Type__r.Name;
                        objWrapperClass.Email = data.User_Form_Contact__r.Email;
                        objWrapperClass.IsFilledUp = data.Is_Filled_Up__c;
                        objWrapperClass.ContactName = data.User_Form_Contact__r.Name;
                        objWrapperClass.FormSubmitted = data.Form_Submitted__c;
                        lstwrapper.add(objWrapperClass);
                    }
                }
            }


        
        }

     //Wrapper Class For report  DataTable
   
    public class wrapperClass {
        public string Name {
            get;
            set;
        }
        public string AccountName {
            get;
            set;
        }
        public string ContactName {
            get;
            set;
        }
        public boolean IsViewed {
            get;
            set;
        }
        public boolean IsAgree {
            get;
            set;
        }
        public string UserType {
            get;
            set;
        }
        public string Email {
            get;
            set;
        }
         public boolean IsFilledUp {
            get;
            set;
        }
         public string FormSubmitted {
            get;
            set;
        }
    }
}