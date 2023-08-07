import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAsyncJob from '@salesforce/apex/SyncRecords3EExpocadUtil.getJobs';
import getTransactionDetail from '@salesforce/apex/SyncRecords3EExpocadUtil.getTransactionDetail';
import syncExhibitorInvite from '@salesforce/apex/SyncRecords3EExpocadUtil.syncExhibitorInvite';
import getCompanyListFrom3E from '@salesforce/apex/SyncRecords3EExpocadUtil.getCompanyListFrom3E';
import getContractsFrom3E from '@salesforce/apex/SyncRecords3EExpocadUtil.getContractsFrom3E';
import getBoothDetailsFromExpocad from '@salesforce/apex/SyncRecords3EExpocadUtil.getBoothDetailsFromExpocad';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getProfile from '@salesforce/apex/SyncRecords3EExpocadUtil.profileDetail';
//import LWCExternal from '@salesforce/resourceUrl/LWCExternal';
//import { loadStyle } from 'lightning/platformResourceLoader';

export default class LWCProgressBar extends NavigationMixin(LightningElement){ 
    @track progress = 0;
    @track processStatus = ''; 
    @track totalJobItems;
    @track allErrors;
    @track jobsProcessed;
    @track isAccount = false;
    @track thirdParty = "MYS";
    @api recordId;
    @api syncProcess;
    @api syncAccount;
    @api syncAccountContact;
    @api syncContact;
    @api batchId;
    @api tranId;
    @api logId;
    @api exhibitorOnly = false;
    @track JobItemsProcessed;
    @track totalProgress;
    @track bShowModalAcc = false;
    @track bShowModalAccWithCon = false;
    @track bShowModalCon = false;
    @track showLogButton = false;
    @track showTranButton = false;
    @track showAbortButton = true;
    @track buttonIsVisible = false;
    @track isShowTransactionDetail = false;
    @track isShowStatusProgress = false;
    @track isShowItemProgress = false;
    @track currentStep = 0;
    @track hasError = false;
    @track batchStatus = [];
    @track transDetail = {};
    @track headerText = '';
    @track buttonText = '';
    @track isShowViewButton = false;
    @track callCount = 0;
    @track isLoaded = true;

    userProfile()
    {
        getProfile()
        .then(data => {
            this.buttonIsVisible = data;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
        });
    }

    connectedCallback() {
        //loadStyle(this);//, LWCExternal
        if(this.syncProcess == 'syncExhibitorInvite' && this.recordId != undefined){
            this.batchStatus.push({label:"Holding",step:1,hasError:false});
            this.batchStatus.push({label:"Queued",step:2,hasError:false});
            this.batchStatus.push({label:"Preparing",step:3,hasError:false});
            this.batchStatus.push({label:"Processing",step:4,hasError:false});
            this.batchStatus.push({label:"Completed",step:5,hasError:false});
            this.batchStatus.push({label:"Failed",step:6,hasError:true});
            this.batchStatus.push({label:"Aborted",step:7,hasError:true});
            this.thirdParty = '3E ExpoCAD';
            this.getBatchIdForExhibitorInvite();

            this.totalProgress = 0;
            this.bShowModalAcc = true;
            this.headerText = 'Invite Exhibitor';
            this.buttonText = 'View Details';
            this.isShowViewButton = false;//false
        }else if(this.syncProcess == 'getCompanyList' && this.recordId != undefined){
            this.batchStatus.push({label:"Holding",step:1,hasError:false});
            this.batchStatus.push({label:"Queued",step:2,hasError:false});
            this.batchStatus.push({label:"Preparing",step:3,hasError:false});
            this.batchStatus.push({label:"Processing",step:4,hasError:false});
            this.batchStatus.push({label:"Completed",step:5,hasError:false});
            this.batchStatus.push({label:"Failed",step:6,hasError:true});
            this.batchStatus.push({label:"Aborted",step:7,hasError:true});
            this.thirdParty = '3E ExpoCAD';
            this.getBatchIdForGetCompanyList();

            this.totalProgress = 0;
            this.bShowModalAcc = true;
            this.headerText = 'Get Company List';
            this.buttonText = 'View Details';
            this.isShowViewButton = false;//false getContractsFrom3E
        }else if(this.syncProcess == 'getContractsFrom3E' && this.recordId != undefined){
            this.batchStatus.push({label:"Holding",step:1,hasError:false});
            this.batchStatus.push({label:"Queued",step:2,hasError:false});
            this.batchStatus.push({label:"Preparing",step:3,hasError:false});
            this.batchStatus.push({label:"Processing",step:4,hasError:false});
            this.batchStatus.push({label:"Completed",step:5,hasError:false});
            this.batchStatus.push({label:"Failed",step:6,hasError:true});
            this.batchStatus.push({label:"Aborted",step:7,hasError:true});
            this.thirdParty = '3E ExpoCAD';
            this.getBatchIdForContacts();

            this.totalProgress = 0;
            this.bShowModalAcc = true;
            this.headerText = 'Get Contracts';
            this.buttonText = 'View Details';
            this.isShowViewButton = false;//false getContractsFrom3E
        }else if(this.syncProcess == 'getBoothsAllInfoFromExpo' && this.recordId != undefined){
            this.batchStatus.push({label:"Holding",step:1,hasError:false});
            this.batchStatus.push({label:"Queued",step:2,hasError:false});
            this.batchStatus.push({label:"Preparing",step:3,hasError:false});
            this.batchStatus.push({label:"Processing",step:4,hasError:false});
            this.batchStatus.push({label:"Completed",step:5,hasError:false});
            this.batchStatus.push({label:"Failed",step:6,hasError:true});
            this.batchStatus.push({label:"Aborted",step:7,hasError:true});
            this.thirdParty = '3E ExpoCAD';
            this.getBoothFromExpo();

            this.totalProgress = 0; 
            this.bShowModalAcc = true;
            this.headerText = 'Get Booths';
            this.buttonText = 'View Details';
            this.isShowViewButton = false;//false getContractsFrom3E
        }
        
        /*if(this.syncAccount == 'synccontactfromopportunity' && this.recordId != undefined){
            this.batchStatus.push({label:"Holding",step:1,hasError:false});
            this.batchStatus.push({label:"Queued",step:2,hasError:false});
            this.batchStatus.push({label:"Preparing",step:3,hasError:false});
            this.batchStatus.push({label:"Processing",step:4,hasError:false});
            this.batchStatus.push({label:"Completed",step:5,hasError:false});
            this.batchStatus.push({label:"Failed",step:6,hasError:true});
            this.batchStatus.push({label:"Aborted",step:7,hasError:true});
            this.thirdParty = 'ExpoCAD';
            this.getBatchIdForConSyncFromOpportunity();

            this.totalProgress = 0;
            this.bShowModalAcc = true;
            this.headerText = 'Sync Contact';
            this.buttonText = 'View Contact Details';
            this.isShowViewButton = true;//false
        }*/
        /*else{
            getBypassExternalSync()
            .then(data => {
                if(data === false){
                    console.log('recordId ' +this.recordId);
                    this.batchStatus.push({label:"Holding",step:1,hasError:false});
                    this.batchStatus.push({label:"Queued",step:2,hasError:false});
                    this.batchStatus.push({label:"Preparing",step:3,hasError:false});
                    this.batchStatus.push({label:"Processing",step:4,hasError:false});
                    this.batchStatus.push({label:"Completed",step:5,hasError:false});
                    this.batchStatus.push({label:"Failed",step:6,hasError:true});
                    this.batchStatus.push({label:"Aborted",step:7,hasError:true});
                    this.userProfile();
                    
                    if((this.syncAccount == 'syncaccount' || this.syncAccountContact == 'syncaccountContact') && this.recordId != undefined)
                    {
                        //this.isAccount = true;
                        this.processRecords();
                    }
                    if(this.syncContact == 'syncContact'  &&  this.recordId != undefined) 
                    {
                        this.getBatchIdForContacts();
                        this.totalProgress = 0;
                        this.bShowModalCon = true;
                        this.headerText = 'Sync Contact';
                        this.buttonText = 'View Contact Details';
                        this.isShowViewButton = true;
                    } 
                }
                else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: 'You are not allowed to sync data to external system.',
                            variant: 'error'
                        })
                    );
                    this.cancel();
                }
            })
            .catch(error => {
                this.error = error;
            });
        }*/
    }

    processRecords()
    {
        if(this.syncAccount == 'syncaccount' && this.recordId != undefined)
        {
            this.getBatchIdAccounts();
            this.totalProgress = 0;
            this.bShowModalAcc = true;
            this.headerText = 'Sync Account';
            this.buttonText = 'View Account Details';
            this.isShowViewButton = true;
        }
        if(this.syncAccountContact == 'syncaccountContact' && this.recordId != undefined)
        {
            this.getBatchIdAccContacts();
            this.totalProgress = 0;
            this.bShowModalAccWithCon = true;
            this.headerText = 'Sync Account with Contacts';
            this.buttonText = 'View Account Details';
            this.isShowViewButton = true;
        }
    }

    get options() {
        return [
            { label: 'ExpoCAD3E', value: 'ExpoCAD3E' }
        ];
    }

    handleChange(event) {//{ label: 'MYS', value: 'MYS' },
        this.thirdParty = event.detail.value;
    }

    handleClick() {
        this.isAccount = false;
        this.processRecords();
    }

    cancel()
    {
        this.dispatchEvent(new CustomEvent('close'));   
    }

    getBatchIdAccounts(){
        getBatchIdForAccounts({ accId : this.recordId, thirdParty : this.thirdParty})
        .then(data => {
            if(data)
            {
                console.log("getBatchIdAccounts====",JSON.stringify(data));
                if(data.trasactionId == "no Data"){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: 'There is no data for syncing with external system.',
                            variant: 'error'
                        })
                    );
                    this.cancel();
                }
                else{
                    this.batchId = data.batchId;
                    this.tranId = data.trasactionId;
                    this.logId = data.interfaceLogId;
                    this.error = undefined;
                    this.currentStep = 1;
                    this.isShowStatusProgress = true;
                    console.log(' JSON.stringify158 ');
                    this.batchinProgress();
                }
            }
        })
        .catch(error => {
            this.error = error; 
        });
    }

    getBoothFromExpo(){
        getBoothDetailsFromExpocad({ oppId : this.recordId})
        .then(data => {
            if(data)
            {
                if(data.trasactionId == "no Data"){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: 'There is no data for syncing with external system.',
                            variant: 'error'
                        })
                    );
                    this.cancel();
                }
                else{
                    this.batchId = data.batchId;
                    this.tranId = data.trasactionId;
                    this.logId = data.interfaceLogId;
                    this.error = undefined;
                    this.currentStep = 1;
                    this.isShowStatusProgress = true;
                    this.batchinProgress();
                }
            }
        })
        .catch(error => {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: error.body.message,
                    variant: 'error'
                })
            );
            this.cancel();
        });
    }

    getBatchIdForContacts(){
        getContractsFrom3E({ oppId : this.recordId})
        .then(data => {
            if(data)
            {
                if(data.trasactionId == "no Data"){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: 'There is no data for syncing with external system.',
                            variant: 'error'
                        })
                    );
                    this.cancel();
                }
                else{
                    this.batchId = data.batchId;
                    this.tranId = data.trasactionId;
                    this.logId = data.interfaceLogId;
                    this.error = undefined;
                    this.currentStep = 1;
                    this.isShowStatusProgress = true;
                    this.batchinProgress();
                }
            }
        })
        .catch(error => {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: error.body.message,
                    variant: 'error'
                })
            );
            this.cancel();
        });
    }

    getBatchIdAccContacts(){
        getBatchIdForAccContacts({ accId : this.recordId, thirdParty : this.thirdParty})
        .then(data => {
            if(data)
            {
                if(data.trasactionId == "no Data"){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: 'There is no data for syncing with external system.',
                            variant: 'error'
                        })
                    );
                    this.cancel();
                }
                else{
                    this.batchId = data.batchId;
                    this.tranId = data.trasactionId;
                    this.logId = data.interfaceLogId;
                    this.error = undefined;
                    this.currentStep = 1;
                    this.isShowStatusProgress = true;
                    this.batchinProgress();
                }  
            }
            
        })
        .catch(error => {
            this.error = error;
        });
    }

    getBatchIdForExhibitorInvite(){
        syncExhibitorInvite({ recId : this.recordId})//, thirdParty: this.thirdParty, exhibitorOnly: this.exhibitorOnly
        .then(data => {
            if(data)
            {
                console.log("syncExhibitorInvite====",JSON.stringify(data));
                if(data.errorMessage != '' && data.errorMessage != null){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: data.errorMessage,
                            variant: 'error'
                        })
                    );
                    this.cancel();
                }else{
                    if(data.trasactionId == "no Data"){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!',
                                message: 'There is no data for syncing with external system.',
                                variant: 'error'
                            })
                        );
                        this.cancel();
                    }
                    else{
                        this.batchId = data.batchId;
                        this.tranId = data.trasactionId;
                        
                        this.logId = data.interfaceLogId;
                        this.error = undefined;
                        this.currentStep = 1;
                        this.isShowStatusProgress = true;
                        this.batchinProgress();
                    }
                }
            }
        })
        .catch(error => {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: error.body.message,
                    variant: 'error'
                })
            );
            this.cancel();
        });
    }

    getBatchIdForGetCompanyList(){
        getCompanyListFrom3E({ recId : this.recordId})//, thirdParty: this.thirdParty, exhibitorOnly: this.exhibitorOnly
        .then(data => {
            if(data)
            {
                console.log("getCompanyListFrom3E====",JSON.stringify(data));
                if(data.trasactionId == "no Data"){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: 'There is no data for syncing with external system.',
                            variant: 'error'
                        })
                    );
                    this.cancel();
                }
                else{
                    this.batchId = data.batchId;
                    this.tranId = data.trasactionId;
                    
                    this.logId = data.interfaceLogId;
                    this.error = undefined;
                    this.currentStep = 1;
                    this.isShowStatusProgress = true;
                    this.batchinProgress();
                }
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    getBatchIdForGetContracts(){
        getCompanyListFrom3E({ recId : this.recordId})//, thirdParty: this.thirdParty, exhibitorOnly: this.exhibitorOnly
        .then(data => {
            if(data)
            {
                console.log("getCompanyListFrom3E====",JSON.stringify(data));
                if(data.trasactionId == "no Data"){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: 'There is no data for syncing with external system.',
                            variant: 'error'
                        })
                    );
                    this.cancel();
                }
                else{
                    this.batchId = data.batchId;
                    this.tranId = data.trasactionId;
                    
                    this.logId = data.interfaceLogId;
                    this.error = undefined;
                    this.currentStep = 1;
                    this.isShowStatusProgress = true;
                    this.batchinProgress();
                }
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

   /* getBatchIdForConSyncFromOpportunity(){
        syncContactFromOpportunity({ oppConId : this.recordId})//, thirdParty: this.thirdParty
        .then(data => {
            if(data)
            {
                console.log("getBatchIdForConSyncFromOpportunity====",JSON.stringify(data));
                if(data.trasactionId == "no Data"){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: 'There is no data for syncing with external system.',
                            variant: 'error'
                        })
                    );
                    this.cancel();
                }
                else{
                    this.batchId = data.batchId;
                    this.tranId = data.trasactionId;
                    
                    this.logId = data.interfaceLogId;
                    this.error = undefined;
                    this.currentStep = 1;
                    this.isShowStatusProgress = true;
                    this.batchinProgress();
                }
            }
        })
        .catch(error => {
            this.error = error;
        });
    }*/

    batchinProgress(){
        this._interval = setInterval(() => {
            getAsyncJob({ batchId : this.batchId})
            .then(data => {
                console.log('wrapperData ' +JSON.stringify(data));
                this.totalJobItems = data['TotalJobItems'];
                this.allErrors = data['NumberOfErrors'];
                this.jobsProcessed = data['JobItemsProcessed'];
                let currentStatus = data.Status;
                for(let i=0;i<this.batchStatus.length;i++){
                    if(this.batchStatus[i].label == currentStatus){
                        this.currentStep = this.batchStatus[i].step;
                        this.hasError = this.batchStatus[i].hasError;
                    }
                }
                this.progress = this.jobsProcessed;
                if(currentStatus == 'Processing' || currentStatus == 'Completed')
                {
                    this.isShowItemProgress = true;
                }
                if(currentStatus == 'Completed')
                {
                    this.showAbortButton = false;
                }

                if(!this.isShowItemProgress)
                {
                    this.processStatus = currentStatus + '...';
                }
                
                if(this.isShowItemProgress)
                {
                    this.processStatus = this.progress +'/'+ this.totalJobItems + ' Records Synced Successfully and ' +this.allErrors+ ' errors encountered' ;
                    if(this.totalProgress === 100 && currentStatus == 'Completed') 
                    {
                        //if(this.buttonIsVisible){
                            this.showTranButton = true;
                        //}
                        this.processStatus = this.progress +'/'+ this.totalJobItems + ' Records Synced Successfully, ' +this.allErrors+ ' errors encountered';
                        clearInterval(this._interval);
                        this.transactionDetail();
                    }
                    else if(this.totalProgress !== 100 && this.totalJobItems !== 0){
                        console.log(' totalProgress1 ' +this.totalProgress);
                        this.totalProgress = Math.round((this.jobsProcessed/this.totalJobItems)*100);
                    }
                }
            })
            .catch(error => {
                this.error = error;
            });
        }, 500);
    }

    transactionDetail(){
        this.isLoaded = false;
        this.processStatus = 'Completed' + '...';
        this._interval2 = setInterval(() => {
            getTransactionDetail({ txnId : this.tranId})
            .then(data => {
                console.log(' transactionDetail==== ' +JSON.stringify(data));
                if(data){
                    if(data.Status__c == 'Completed' || data.Status__c == 'Completed With Errors'){
                        this.isShowTransactionDetail = true;
                        this.transDetail.Status = data.Status__c;
                        this.transDetail.Total = data.API_Synchronization_Items__r.length;
                        this.transDetail.Processed = 0;
                        this.transDetail.Success = 0;
                        this.transDetail.Error = 0;
                        this.transDetail.InterfaceLog = data.Interface_Log__c;
                        if(data.Interface_Log__c != '' && data.Interface_Log__c != null)
                        {
                            this.showLogButton = true;
                            this.logId = data.Interface_Log__c;
                        }
                        for(let i=0;i<data.API_Synchronization_Items__r.length;i++){
                            let item = data.API_Synchronization_Items__r[i];
                            if(item.Status__c !== 'Paused'){
                                this.transDetail.Processed++;
                            }
                            if(item.Status__c === 'Completed'){
                                this.transDetail.Success++;
                            }
                            if(item.Status__c === 'Error'){
                                this.transDetail.Error++;
                            }
                        }
                        this.transDetail.hasError = (this.transDetail.Error>0);
                        this.isLoaded = true;
                        this.processStatus = 'Completed' + '...';
                        if(this._interval2){
                            clearInterval(this._interval2);
                        }
                    }
                }else{
                    if(this._interval2){
                        clearInterval(this._interval2);
                    }
                }
            })
            .catch(error => {
                console.log("error" + JSON.stringify(error));
                this.error = error;
                if(this._interval2){
                    clearInterval(this._interval2);
                }
                this.isLoaded = true;
            });
        }, 1000);
    }

    disconnectedCallback() {
        if(this._interval){
            clearInterval(this._interval);
        }
        if(this._interval2){
            clearInterval(this._interval2);
        }
    }

    abortBatch()
    {
        clearInterval(this._interval);
        abortbatchJob({ batchId : this.batchId, apiTransId: this.tranId})
        .then(data => {
            console.log('wrapperData' +JSON.stringify(data));
            this.totalJobItems = data['TotalJobItems'];
            this.allErrors = data['NumberOfErrors'];
            this.jobsProcessed = data['JobItemsProcessed'];
            this.progress = this.jobsProcessed;
            this.showAbortButton = false;
            this.isShowItemProgress = false;
            this.showLogButton = false;

            let currentStatus = data.Status;
            for(let i=0;i<this.batchStatus.length;i++){
                if(this.batchStatus[i].label == currentStatus){
                    this.currentStep = this.batchStatus[i].step;
                    this.hasError = this.batchStatus[i].hasError;
                }
            }

            this._interval = setInterval(() => {
                getAsyncJob({ batchId : this.batchId})
                .then(data2 => {
                    this.totalJobItems = data2['TotalJobItems'];
                    this.allErrors = data2['NumberOfErrors'];
                    this.jobsProcessed = data2['JobItemsProcessed'];
                    let currentStatus2 = data2.Status;
                    for(let i=0;i<this.batchStatus.length;i++){
                        if(this.batchStatus[i].label == currentStatus2){
                            this.currentStep = this.batchStatus[i].step;
                            this.hasError = this.batchStatus[i].hasError;
                        }
                    }
                    this.progress = this.jobsProcessed;
                    this.isShowItemProgress = true;
                    this.showAbortButton = false;
                    if(currentStatus2 == 'Aborted'){
                        this.processStatus = currentStatus2 + "...";
                    }
                    else{
                        this.processStatus = this.progress +'/'+ this.totalJobItems + ' Records Synced Successfully and ' +this.allErrors+ ' errors encountered' ;
                    }
                    this.transactionDetail();
                    if(this.callCount == 10)
                    {
                        clearInterval(this._interval);
                    }
                    this.callCount++;
                    console.log("this.callCount ---> " + this.callCount);
                })
                .catch(error2 => {
                    this.error = error2;
                    this.transactionDetail();
                    if(this.callCount == 10)
                    {
                        clearInterval(this._interval);
                    }
                    this.callCount++;
                });
            }, 1000);
        });
    }

    navigateToTransactionRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.tranId,
                "objectApiName": "API_Synchronization_Transaction__c",
                "actionName": "view"
            },
        });
    }

    navigateToInterfaceLogRecordPage() {
        if(this.logId != '' && this.logId != null){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    "recordId": this.logId,
                    "objectApiName": "Interface_Log__c",
                    "actionName": "view"
                },
            });
        }
    }
}