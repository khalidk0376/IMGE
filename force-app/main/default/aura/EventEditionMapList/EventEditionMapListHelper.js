({
    fetchData : function(component,pageNumber) {
        component.set("v.showSpinner", true);
        var pageSize=5;
        var action = component.get("c.getRecords");
        action.setParams({ 
            objName:'ContactEventEditionMapping__c',
            fieldNames:'Id,SFEventEditionID__r.Name,SFEventEditionID__r.Part_of_Series__r.Name ,Status__c',
            compareWith:'SFContactID__c',
            recordId : component.get("v.recordId"),
            pageNumber:pageNumber,
            pageSize:pageSize
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") { 
                var resContMap =res.getReturnValue();
                var conmapList =resContMap.recordList;
                //console.log('result'+JSON.stringify(conmapList)); 
                for(var i=0;i<conmapList.length;i++){
                    if(conmapList[i].hasOwnProperty('SFEventEditionID__r')){
                        conmapList[i].eventLink = '/lightning/r/Event_Edition__c/' + conmapList[i].SFEventEditionID__c + '/view';
                        conmapList[i].Event = conmapList[i].SFEventEditionID__r.Name;
                    }
                    if(conmapList[i].hasOwnProperty("SFEventEditionID__r")){
                        conmapList[i].seriesLink = '/lightning/r/Event_Series__c/' + conmapList[i].SFEventEditionID__r.Part_of_Series__c + '/view';
                        conmapList[i].Series = conmapList[i].SFEventEditionID__r.Part_of_Series__r.Name;
                    }
                    component.set("v.data", conmapList);
                    //console.log("test"+JSON.stringify(component.get("v.data")));
                    component.set("v.PageNumber", resContMap.pageNumber);
                	component.set("v.TotalRecords", resContMap.totalRecords);
                	component.set("v.RecordStart", resContMap.recordStart);
                	component.set("v.RecordEnd", resContMap.recordEnd);
                	component.set("v.TotalPages", Math.ceil(resContMap.totalRecords / pageSize));
                }
            }
            else 
            {
                window._LtngUtility.handleErrors(res.getError());
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action); 
    }
})