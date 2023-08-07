({
    getDetailData : function(component,fields,recordId) {
       var action = component.get("c.getRecordDetail");
        action.setParams({objectName:component.get("v.object"),fields:fields,recordId:recordId});
        action.setCallback(this,function(res){
            var state = res.getState();            
            if(state=="SUCCESS"){                
                component.set("v.contactObj",res.getReturnValue()[0]);
                component.set("v.isOpenNewContactModal",true);
            }
            else{
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);                   
    },
    openFile : function(component,fields,parentId) {
        $A.util.removeClass(component.find("gkn_spinner"),"slds-hide");
        $A.util.addClass(component.find("gkn_spinner"),"slds-show");
        var action = component.get("c.getFilePreview");
        action.setParams({objectName:'ContentDocumentLink',fields:'Id, ContentDocumentId',parentId:parentId});
        action.setCallback(this,function(res){
            $A.util.removeClass(component.find("gkn_spinner"),"slds-show");
            $A.util.addClass(component.find("gkn_spinner"),"slds-hide");
            var state = res.getState(); 
            if(state=="SUCCESS"){
				var obj = res.getReturnValue();
                if(obj!='[]' && obj.length>0){
                    const attId = [];
                    attId.push(obj[0].ContentDocumentId);
                    $A.get('e.lightning:openFiles').fire({
                    	recordIds: attId
                    });                   
                }
                else{
                    window._LtngUtility.toast('Warning','warning','No file found to view');
                }
                
            }
            else{
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);                   
    },
    openModel:function(component){
      	$A.util.addClass(component.find('detail-edit-view'),"slds-fade-in-open");
      	$A.util.addClass(component.find('backdrop'),"slds-backdrop_open");
      	$A.util.removeClass(component.find('detail-edit-view'),"slds-fade-in-close");
      	$A.util.removeClass(component.find('backdrop'),"slds-backdrop_close");
    },
    closeModel:function(component){        
        $A.util.addClass(component.find('detail-edit-view'),"slds-fade-in-close");
      	$A.util.addClass(component.find('backdrop'),"slds-backdrop_close");
      	$A.util.removeClass(component.find('detail-edit-view'),"slds-fade-in-open");
      	$A.util.removeClass(component.find('backdrop'),"slds-backdrop_open");
        
        //var bodyComp = component.get("v.body");
        component.set("v.body", []);
    },
    getTableData : function(component,next,prev,offset) {
        offset = offset || 0;
        
        $A.util.removeClass(component.find("gkn_spinner"),"slds-hide");
        $A.util.addClass(component.find("gkn_spinner"),"slds-show");
        
        var sColumn = component.get("v.fields");
        var sObject = component.get("v.object");
        var pagesize = component.get("v.pagesize");
        
        var action = component.get("c.getGenericObjectRecord");
        action.setParams({
            ObjectName : sObject,
            fieldstoget : sColumn,
            pagesize : pagesize,
            next : next,
            prev : prev,
            off : offset,
            whField:component.get("v.whereField"),
            whValue:component.get("v.whereValue"),
            inlineEditable:component.get("v.inlineEditable"),
            operator:component.get("v.operator")
        });
        action.setCallback(this,function(res){
            var state = res.getState();            
            if(state=="SUCCESS"){
                var result = res.getReturnValue();
                console.log(result);
                component.set('v.isBrasilConUpdateUser',result.checkBrasilContactUpdate);
                var actions = [
                    { label: 'Preview','iconName':'utility:preview', name: 'preview'},
                    { label: 'Clone','iconName':'utility:copy', name: 'clone' },
                    { label: 'Edit','iconName':'utility:edit', name: 'edit' },
                    { label: 'Share','iconName':'utility:share', name: 'share' }
                ];
                //result.ltngTabWrap.tableColumn.push({label:'Actions', type: 'action', typeAttributes: { rowActions: actions } });
                
                //component.set("v.mycolumn",result.ltngTabWrap.tableColumn);
                
                this.setParentFieldColumn(component,result.ltngTabWrap.tableColumn,sColumn,result.ltngTabWrap.tableRecord);

                //component.set("v.mydata",result.ltngTabWrap.tableRecord);

                component.set('v.offset',result.offst);
                //component.set('v.accounts',result.acc);
                component.set('v.next',result.hasnext);
                component.set('v.prev',result.hasprev);
                component.set("v.totalrows",result.total);
                
                var lastind = parseInt(result.offst+pagesize,10);
                var total = parseInt(result.total,10);                
                if(total<lastind){
                    lastind=total;
                }
                component.set("v.show_page_view",'Shows: '+parseInt(result.offst+1)+'-'+lastind);
                
            }
            $A.util.addClass(component.find("gkn_spinner"),"slds-hide");
            $A.util.removeClass(component.find("gkn_spinner"),"slds-show");
        });        
        $A.enqueueAction(action);
    },
    setParentFieldValue:function(component, datas){
        for(var i=0;i<datas.length;i++){
            //build link
            if(datas[i].hasOwnProperty('Name')){
                datas[i].NameLink='/lightning/r/'+component.get('v.object')+'/'+datas[i].Id+'/view';
            }
            if(datas[i].hasOwnProperty('FirstName')){
                datas[i].FirstNameLink='/lightning/r/'+component.get('v.object')+'/'+datas[i].Id+'/view';
            }
            if(datas[i].hasOwnProperty('LastName')){
                datas[i].LastNameLink='/lightning/r/'+component.get('v.object')+'/'+datas[i].Id+'/view';
            }

            if(datas[i] instanceof Object){
                for (var k in datas[i]) {
                    if (datas[i].hasOwnProperty(k) && datas[i][k].hasOwnProperty('Name')) {                    
                        datas[i][k+'Name'] = datas[i][k].Name;
                        datas[i][k+'NameLink']='/lightning/r/'+k+'/'+datas[i][k].Id+'/view';
                    }
                    if (datas[i].hasOwnProperty(k)){
                        for (var j in datas[i][k]) {
                            if (datas[i][k].hasOwnProperty(j)&&datas[i][k][j].hasOwnProperty('Name')){
                                datas[i][k+j+'Name'] = datas[i][k][j].Name;
                            }
                        }
                    }
                }
            }
        }
        component.set("v.mydata",datas);
    },
    setParentFieldColumn:function(component, columnObj,columnList,datas){
        if(columnList.indexOf('.')>0){
            var col = columnList.split(',');
            for(var i=0;i<col.length;i++){
                var test = col[i].split('.');
                if(col[i].indexOf('.')>0 && test.length==2){
                    columnObj.splice(i,0,{label:col[i].split('.')[0]+' '+col[i].split('.')[1], fieldName: col[i].split('.')[0]+col[i].split('.')[1]});
                }
                if(col[i].indexOf('.')>0 && test.length==3){
                    columnObj.splice(i,0,{label:col[i].split('.')[1]+' '+col[i].split('.')[2], fieldName: col[i].split('.')[0]+col[i].split('.')[1]+col[i].split('.')[2]});
                }
            }
        }
        if(component.get("v.isViewFile")){
            columnObj.splice(0, 0, {type: "button",initialWidth:'100px', typeAttributes: {iconName: 'utility:preview',label: '',
                             name: 'viewFile',title: 'View File',disabled: false,
                                                         value: {fieldName: 'Id'}}})
            
        }                                 
        for(var i=0;i<columnObj.length;i++){
            //format date field
            if(columnObj[i].type=='datetime'||columnObj[i].type=='date'){
                columnObj[i].type='date';
                columnObj[i].typeAttributes= {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                }
            }
            if(columnObj[i].type=='currency'){
                columnObj[i].cellAttributes = { alignment: 'left' };
            }
            if(columnObj[i].fieldName =='Name'){
                columnObj[i].type='url';
                columnObj[i].fieldName='NameLink';
                columnObj[i].typeAttributes = {label: {fieldName: 'Name' }, target: '_self'}    
            }
            if(columnObj[i].fieldName =='ContactName'){
                columnObj[i].type='url';
                columnObj[i].fieldName='ContactNameLink';
                columnObj[i].typeAttributes = {label: {fieldName: 'ContactName' }, target: '_self'}    
            }
            
            if(columnObj[i].fieldName =='SBQQ__PrimaryContact__rName'){
                columnObj[i].type='url';
                columnObj[i].label='Primary Contact';
                columnObj[i].fieldName='SBQQ__PrimaryContact__rNameLink';
                columnObj[i].typeAttributes = {label: {fieldName: 'SBQQ__PrimaryContact__rName' }, target: '_self'}    
            }
            if(columnObj[i].fieldName =='Billing_Contact__rName'){
                columnObj[i].type='url';
                columnObj[i].label='Billing Contact';
                columnObj[i].fieldName='Billing_Contact__rNameLink';
                columnObj[i].typeAttributes = {label: {fieldName: 'Billing_Contact__rName' }, target: '_self'}    
            }
            
            if(columnObj[i].fieldName =='AccountName'){
                columnObj[i].type='url';
                columnObj[i].fieldName='AccountNameLink';
                columnObj[i].typeAttributes = {label: {fieldName: 'AccountName' }, target: '_self'}    
            }
            if(columnObj[i].fieldName =='SBQQ__Account__rName'){
                columnObj[i].type='url';
                columnObj[i].label='Account Name';
                columnObj[i].fieldName='SBQQ__Account__rNameLink';
                columnObj[i].typeAttributes = {label: {fieldName: 'SBQQ__Account__rName' }, target: '_self'}    
            }
            if(columnObj[i].fieldName =='FirstName'){
                columnObj[i].type='url';
                columnObj[i].fieldName='FirstNameLink';
                columnObj[i].typeAttributes = {label: {fieldName: 'FirstName' }, target: '_self'}    
            }
            if(columnObj[i].fieldName =='LastName'){
                columnObj[i].type='url';
                columnObj[i].fieldName='LastNameLink';
                columnObj[i].typeAttributes = {label: {fieldName: 'LastName' }, target: '_self'}    
            }
        }
        var actions = [
            { label: 'Edit',title: 'Click to Edit', name: 'edit',iconName: 'utility:edit'}
        ]
        if(component.get("v.profile")=='System Administrator'||component.get("v.profile")=='GE System Administrator'||component.get("v.profile")=='GE BA Administrator' || (component.get("v.profile")=='Read Only' && component.get("v.isBrasilConUpdateUser"))){
            actions.push({ label: 'Delete',title: 'Click to Delete', name: 'delete',iconName: 'utility:delete'})
        }

        if(component.get("v.profile")=='System Administrator'||component.get("v.profile")=='GE System Administrator'||component.get("v.profile")=='GE BA Administrator'||component.get("v.profile")=='SSC Finance-Accounting' || (component.get("v.profile")=='Read Only' && component.get("v.isBrasilConUpdateUser"))){
            columnObj.push({label: 'Action', type: 'action', typeAttributes: { rowActions: actions }});
        }
        console.log(columnObj);
        component.set("v.mycolumn",columnObj);
        this.setParentFieldValue(component,datas)
    },
    handleSubmit : function(component,data) {
        $A.util.removeClass(component.find("gkn_spinner"),"slds-hide");
        $A.util.addClass(component.find("gkn_spinner"),"slds-show");                 
        var action = component.get("c.updateDataTable");
        action.setParams({
            params : data
        });
        action.setCallback(this,function(res){
            $A.util.removeClass(component.find("gkn_spinner"),"slds-show");
            $A.util.addClass(component.find("gkn_spinner"),"slds-hide");        
            var state = res.getState();            
            if(state=="SUCCESS"){
                component.set('v.errors', []);
                component.set('v.draftValues', []);
                window._LtngUtility.toast('Success','success','Record Updated');
                
                var offset = component.get("v.offset");
                this.getTableData(component,false,false,offset); 
            }
            else
            {
                window._LtngUtility.handleErrors(res.getError());
                component.set('v.errors', res.errors);
            }
        });        
        $A.enqueueAction(action);
    },
    deleteContact: function(component,data) {
        $A.util.removeClass(component.find("gkn_spinner"),"slds-hide");
        $A.util.addClass(component.find("gkn_spinner"),"slds-show");                 
        var action = component.get("c.deleteRecord");
        action.setParams({
            cont_obj : data
        });
        action.setCallback(this,function(res){
            $A.util.removeClass(component.find("gkn_spinner"),"slds-show");
            $A.util.addClass(component.find("gkn_spinner"),"slds-hide");        
            var state = res.getState();            
            if(state=="SUCCESS"){
                component.set('v.errors', []);
                component.set('v.draftValues', []);
                window._LtngUtility.toast('Success','success','Record deleted');                
                var offset = component.get("v.offset");
                this.getTableData(component,false,false,offset); 
            }
            else
            {
                window._LtngUtility.handleErrors(res.getError());
                component.set('v.errors', res.errors);
            }
        });        
        $A.enqueueAction(action);
    },
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.mydata");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.mydata", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})