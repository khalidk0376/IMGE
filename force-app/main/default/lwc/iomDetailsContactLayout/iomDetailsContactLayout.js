import { api,LightningElement,wire } from 'lwc';
import LWCExternal from '@salesforce/resourceUrl/IOM_LWCExternal';
import { loadStyle } from 'lightning/platformResourceLoader';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import hasReadyOnlyPermission from '@salesforce/customPermission/IOM_Read_Only_User';
import SYNC_STATUS from '@salesforce/schema/Contact.IOM_Sync_Status__c';
import OPP_NO from '@salesforce/schema/Contact.IOM_Contact_No__c';


export default class IomDetailsContactLayout extends LightningElement {
    
    @api recordId;
    activeSections = ['A','B','C'];
    isEditMode = false;
    showSpinner = false;
    showIOMOpporunity = false;
    isReadOnly = false;

    @wire(getRecord, { recordId: '$recordId', fields: [SYNC_STATUS,OPP_NO] })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading opportunity',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            // console.log('onload==>'+JSON.stringify(data));
            // console.log('VAL1==>'+data.fields.IOM_Sync_Status__c.value);
            // console.log('VAl2==>'+data.fields.IOM_Contact_No__c.value);
            if(data.fields.IOM_Sync_Status__c.value=='Complete'){
                this.showIOMOpporunity = true;
            }
            if(data.fields.IOM_Sync_Status__c.value=='Complete' && data.fields.IOM_Contact_No__c.value!=''){
                this.isReadOnly=true;
            }
            
        }
    }


    connectedCallback(){
        // console.log('recordId' +this.recordId);
        loadStyle(this, LWCExternal);
        this.isReadOnly= hasReadyOnlyPermission; //[GECI-940]
    }
    handleSuccess(event) {
        // let oppId = event.detail.id;
        // console.log('oppId '+oppId);
        this.showSpinner = false;
        this.isEditMode = false;
    }
    editRecord(){
        // console.log('isReadOnly' +this.isReadOnly);
        if(!this.isReadOnly){
            this.isEditMode = true;
        }
        else{
            this.isEditMode = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Record is Read Only!',
                    message: 'IOM Sync is completed and Record is not editable',
                    variant: 'info',
                }),
            );
        }
    }
    handleError(){
        this.showSpinner = false;
    }
    handleSubmit(event){        
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;       
        this.showSpinner = true;
        fields['Id'] =this.recordId;
        // console.log('Fields - '+JSON.stringify(fields));
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }    

    handleCancel(){
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        this.isEditMode = false;
    }
}