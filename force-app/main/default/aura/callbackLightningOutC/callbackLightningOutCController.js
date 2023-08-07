({
   init: function (cmp, event, helper) {
        cmp.set('v.mycolumns', [
            { label: 'Opportunity Name', fieldName: 'Name', type: 'text'},
            // Commented by Palla Kishore for the ticket BK-24786
          //  { label: 'Amount', fieldName: 'Amount', type: 'currency', typeAttributes: {currencyCode: { fieldName: 'CurrencyIsoCode' }}},
            { label: 'Amount', fieldName: 'Amount_Custom_Code__c', type: 'text'},
            { label: 'Opportunity Stage', fieldName: 'StageName', type: 'text'},
            { label: 'Event Edition', fieldName: 'Event_Edition_Name__c', type: 'text'},
            { label: 'Source Org', fieldName: 'Data_Source__c', type: 'text'},
            { label: 'Rented Area', fieldName: 'Total_Area_Rented__c', type: 'Double'}
        ]);
       
        helper.getData(cmp);
    }
})