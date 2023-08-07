import { LightningElement, track , api} from 'lwc';
import getdata from '@salesforce/apex/SSCDashboardLtngCtrl.getSSCTeamMember';
import getRecordDetail from '@salesforce/apex/CommonTableController.getRecordDetail';
import strUserId from '@salesforce/user/Id';
import {handleErrors} from 'c/lWCUtility';
const DELAY=300;

//Retrieve Custom Labels
import Account_Name from '@salesforce/label/c.Account_Name';
import Submission_Date from '@salesforce/label/c.Submission_Date';
import Opportunity_Owner from '@salesforce/label/c.Opportunity_Owner';


export default class DoNotBillDashboard extends LightningElement {

    @track openActionModal=false;
    @track recordId='';
    @track error;
    @track doNotBillCond;
    @track oppFields = '';
    @track oppFieldsLabels = '';
    @track toggleDelegateOppCon;
    @api isSalesOpsTeamMember;
    currentDate = new Date();
    /**
    * Description: This method will call at the time of load.
    */
    connectedCallback(){
        this.getUserDetail();
        this.getSSCTeamMember();
    }
    
    /**
    * Description: This method will fetch the list of event series from ssc team member.
    */
    getSSCTeamMember(){
        getdata()
        .then(data=>{
            let ids = [];
            let datas = JSON.parse(JSON.stringify(data));
           
            for(let i=0; i<datas.length; i++){
                if(datas[i].SSC_Team__r.Event_Series__c!==undefined){
                    ids.push(datas[i].SSC_Team__r.Event_Series__c);
                }                
            }
        // Added by Palla Kishore for the ticket BK-26708
        let currentYear = this.currentDate.getFullYear();
        console.log('currentYear:::'+currentYear);
        let currentAndNextYear = currentYear + ',' + (currentYear + 1);
        console.log('currentAndNextYear:::'+currentAndNextYear);
        // Modified by Palla Kishore for the ticket BK-26535
        this.doNotBillCond = '(Status__c = \'Do Not Bill Status\' AND Amount>0 AND StageName=\'Closed Won\' AND Exhibitor_Paid_By__c != \'Delegate Sales\' AND EventEdition__r.Part_of_Series__c IN (\''+ids.join('\',\'')+'\') AND Do_not_activate_Billing__c = true AND CALENDAR_YEAR(Event_Edition_Start_Date__c) IN ('+currentAndNextYear+')'+')';
        console.log('doNotBillCond:::'+this.doNotBillCond);
        this.toggleDelegateOppCon = '(Status__c = \'Do Not Bill Status\' AND Amount>0 AND StageName=\'Closed Won\' AND Exhibitor_Paid_By__c = \'Delegate Sales\' AND EventEdition__r.Part_of_Series__c IN (\''+ids.join('\',\'')+'\') AND Do_not_activate_Billing__c = true AND CALENDAR_YEAR(Event_Edition_Start_Date__c) IN ('+currentAndNextYear+')'+')';
        console.log('this.toggleDelegateOppCon:::'+this.toggleDelegateOppCon); 
        })
        .catch(error=>{
           handleErrors(this,error);
        });
    }

    /**
    * Description: This method will fetch the list of userrole from user based on login user id.
    */
    getUserDetail(){
        getRecordDetail({objectName:'User',allFields:'UserRole.Name',recordId:strUserId})
        .then(res=>{
            if(res.length > 0){
                if(res[0].UserRole.Name === 'SSC-Brazil'){
                    this.oppFields = 'Name,Account.Name,ISO_Code__c,Amount_Custom__c,CloseDate,Submission_Date__c,StageName,Status__c,Tax_Rule_SAP__c,SSC_Brazil_Status__c,Sales_Ops_Rejection_Reason__c,Sales_Ops_Notes__c,EventEdition__r.Name,Owner.Name,Exhibitor_Paid_By__c,User_Type__r.Name,Do_not_activate_Billing__c';
                    this.oppFieldsLabels = 'Opportunity Name,'+Account_Name+',ISO Code,Contract Total,Close Date,'+Submission_Date+',Stage,Status,TAX Rule,SSC Brazil Status,Sales Ops Rejection Responses,Sales Ops Notes,Event Edition,'+Opportunity_Owner+'Exhibitor Paid By,User Type,Do Not Active Billing';
                } else if(res[0].UserRole.Name !== 'SSC-Brazil') {
                    this.oppFields = 'Name,Account.Name,ISO_Code__c,Amount_Custom__c,CloseDate,StageName,Status__c,Tax_Rule_SAP__c,Sales_Ops_Rejection_Reason__c,Sales_Ops_Notes__c,EventEdition__r.Name,Owner.Name,Exhibitor_Paid_By__c,User_Type__r.Name,Do_not_activate_Billing__c';
                    this.oppFieldsLabels = 'Opportunity Name,'+Account_Name+',ISO Code,Contract Total,Close Date,Stage,Status,TAX Rule,Sales Ops Rejection Responses,Sales Ops Notes,Event Edition,'+Opportunity_Owner+'Exhibitor Paid By,User Type,Do Not Active Billing';
                }
            }
        })
        .catch(error=>{
            handleErrors(this,error);
        })
    }
}