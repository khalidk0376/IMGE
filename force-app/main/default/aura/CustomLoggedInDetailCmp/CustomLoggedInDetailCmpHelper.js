({
	getTableData : function(component,next,prev,offset) {
        offset = offset || 0;
        var sColumn = component.get("v.fields");
        var sObject = component.get("v.object");
        var pagesize = component.get("v.pagesize");
        var orderby = component.get('v.sortedBy');
        var direction = component.get('v.sortedDirection');
        var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");
        if(!$A.util.isEmpty(startDate)){            
            startDate = this.getFormattedDate(new Date(startDate))
        }
        else{
            startDate='';
        }

        if(!$A.util.isEmpty(endDate)){            
            endDate = this.getFormattedDate(new Date(endDate))
        }
        else{
            endDate='';
        }

        component.set("v.Spinner",true);
        var action = component.get("c.getGenericObjectRecord");
        action.setParams({
            objectName : sObject,
            fieldstoget : sColumn,
            pagesize : pagesize,
            next : next,
            prev : prev,
            off : offset,
            orderby:orderby,
            direction:direction,
            startDate:startDate,
            endDate:endDate
        });
        action.setCallback(this,function(res){
            component.set("v.Spinner",false);
            var state = res.getState();            
            if(state=="SUCCESS"){
                var result = res.getReturnValue();
                result.ltngTabWrap.tableColumn = [{label: 'Login As', fieldName: 'Field1', type: 'text'},	            
	            {label: 'Login As Username', fieldName: 'Field3', type: 'text'},
	            {label: 'Logged in Person', fieldName: 'Field2', type: 'text'},
	            {label: 'Logged in Date', fieldName: 'CreatedDate', type: 'date',sortable:true}];                
                component.set("v.mycolumn",result.ltngTabWrap.tableColumn);
                component.set("v.mydata",result.ltngTabWrap.tableRecord);  
                component.set('v.offset',result.offst);                
                component.set('v.next',result.hasnext);
                component.set('v.prev',result.hasprev);
                component.set("v.totalrows",result.total);
                var totalItems = result.total;

                if(result.offst+pagesize>result.total){
                    totalItems = result.total;
                }
                else
                {
                    totalItems = result.offst+pagesize;    
                }

                component.set("v.show_page_view",'Shows: '+parseInt(result.offst+1)+'-'+totalItems);
            }            
        });        
        $A.enqueueAction(action);
    },
    getFormattedDate : function(todayTime) {        
        var dd = todayTime.getDate();
        var mm = todayTime.getMonth()+1; 
        var yyyy = todayTime.getFullYear();
        if(dd<10) 
        {
            dd='0'+dd;
        } 
        if(mm<10) 
        {
            mm='0'+mm;
        } 
        return mm+'/'+dd+'/'+yyyy;
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
    },
})