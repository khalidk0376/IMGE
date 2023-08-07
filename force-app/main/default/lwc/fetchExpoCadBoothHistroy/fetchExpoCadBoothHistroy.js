import { LightningElement, track, wire, api } from 'lwc';
import getBoothHistory from '@salesforce/apex/FetchExpoCadBoothHistroy.fetchhistory';
import TIME_ZONE  from '@salesforce/i18n/timeZone';

const COLUMNS  = [
        { label: 'Booth Name', fieldName: 'ExpocadURL', type: 'url',typeAttributes: {label: {fieldName: 'ExpocadBoothName'},target: '_blank'}},
        { label: 'Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: { day: 'numeric', month: 'numeric', year: "numeric" , hour: '2-digit', minute: '2-digit', second: '2-digit', timeZone: TIME_ZONE} },
        { label: 'Field', fieldName: 'FieldVal', type: 'text' },
        { label: 'User', fieldName: 'CreatedById', type: 'url', typeAttributes: { label: { fieldName: 'CreatedByName' }, target: '_blank' } },
        { label: 'Original Value', fieldName: 'OldValue', type: 'text' },
        { label: 'New Value', fieldName: 'NewValue', type: 'text'}
    ];
export default class FetchExpoCadBoothHistroy extends LightningElement {
   
    @track finalTableData ;
    @api recordId;
    @track isShowTable = false;
    @track isShowMSG = false;
    columns = COLUMNS;
    @track FieldValue;
    
    @wire(getBoothHistory, { OppId: '$recordId' })
    wiredExpocadBoothHistory({ data, error }) {
        if (data) {
            this.finalTableData = data.map(row => {
                    console.log('row:', row);
                    this.isShowTable = true;
                    this.isShowMSG = false;
            if(row.Field=='Booth_Number__c'){
              this.FieldValue='Booth Number';
            }
           else if(row.Field=='Status__c'){
            this.FieldValue='Status';
          }
					else if(row.Field=='created'){
            this.FieldValue='Created';
          }			
          else{
            this.FieldValue=row.Field
          }
        return {
          ...row,
          CreatedById: '/' + row.CreatedById,
          CreatedByName: row.CreatedBy.Name,
          ExpocadBoothName:row.Parent.Name,
          ExpocadBoothNumber: row.Parent.Booth_Number__c,
          FieldVal: this.FieldValue,
          ExpocadURL:'/lightning/r/ExpocadBooth__c/' +row.ParentId +'/view'

        };
      });
        if(this.finalTableData.length < 1){
            this.isShowTable = false;
            this.isShowMSG = true;
        }
            console.log('data::::',data);
        } else if (error) {
            console.error(error);
        }  

    }
   
}