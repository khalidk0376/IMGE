/**
 * Created/Modified By: Girikon(Mahesh)
 * Created On:          26 June 2018
 * Description/Purpose: Using in Visulforce Page passing Questionnaire ID
 * Test Class:   FormReportCtrl_Test 
 * Code Coverage: 100%
 * Modified By : Himanshu Jasuja - BK - 3458
**/
public class FormPreviewOpsAdminctr {
    public string formQnaireId{get;set;}  
    public string accontId{get;set;}  
    public FormPreviewOpsAdminctr(){
        string sId = ApexPages.currentPage().getParameters().get('id');
        string accId = ApexPages.currentPage().getParameters().get('AccId');
        if(sId != null && sId != '')
        {                  
                Questionnaire__c quennaire =[select id, name from Questionnaire__c WHERE id =: sId];
                //BK - 3458
                if(quennaire.id!=null){
                    formQnaireId= quennaire.id;
                }
        }    
        if(accId != null && accId != '')
        {
            Account accotId =[select Id, Name from Account WHERE id =:accId];
            accontId=accotId.id;
        }
    }
}