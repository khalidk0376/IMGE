import { LightningElement, wire, api, track } from 'lwc';
import getEventEditionBillingSchedule from '@salesforce/apex/EventEditionBillingScheduleController.getPaymentSchedule';
import iomLWCMS from "@salesforce/messageChannel/IOM_LWCMessageService__c";
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import { refreshApex } from '@salesforce/apex';

export default class Iom_EventEditionBillingSchedule extends LightningElement {
    @api recordId;
    @track customPayment = false;
    defaultBilling;
    cutoffDate1;
    cutoffDate2;
    cutoffDate3;
    cutoffDate4;
    subscription = null;
    wiredData;

    @wire(MessageContext)
    messageContext;

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                iomLWCMS,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage(message) {
        console.log("message==",message);
        if(message.iomLWCMessage == 'opportunity custotom billing updated.' && message.sourceLWC == 'iom_OppCustomPaymentSchedule'){
            refreshApex(this.wiredData);
        }
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }
    
    @wire(getEventEditionBillingSchedule, { opportunityId: '$recordId' })
    wiredEventEditionBillingSchedule(valueData) {
        this.wiredData = valueData;
        const { data, error } = valueData;
        if (data) {
            let paymentschaftersplit = [];
            var paymentsch = data.EventEdition__r.Payment_Schedule__c;
            if(paymentsch != '' && paymentsch != null){
                paymentschaftersplit = paymentsch.split('-');
            }
            if(paymentschaftersplit.length > 0 && (data.EventEdition__r.Cutoff_Date_1__c != null && data.EventEdition__r.Cutoff_Date_1__c != '')){
                this.cutoffDate2 = data.EventEdition__r.Cutoff_Date_1__c;
            }else if(paymentschaftersplit.length > 1 && (data.EventEdition__r.Cutoff_Date_2__c != null && data.EventEdition__r.Cutoff_Date_2__c != '')){
                this.cutoffDate3 = data.EventEdition__r.Cutoff_Date_2__c;
            }else if(paymentschaftersplit.length > 2 && (data.EventEdition__r.Cutoff_Date_3__c != null && data.EventEdition__r.Cutoff_Date_3__c != '')){
                this.cutoffDate4 = data.EventEdition__r.Cutoff_Date_3__c;
            }
            this.customPayment = data.Custom_Payment__c;
            this.defaultBilling = data.EventEdition__r.Payment_Schedule__c;
            this.cutoffDate1 = data.EventEdition__r.X50_Cutoff_Date__c;
            
        } else if (error) {
            console.error(error);
        }
    }
}