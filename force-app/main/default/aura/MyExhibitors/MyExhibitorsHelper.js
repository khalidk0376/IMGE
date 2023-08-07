({
    //Apex class : MyExhibitorsCtrl 
    fetchEventDetails: function (component,event) {
        var sEventCode = component.get("v.eventcode");//Getting values from Aura attribute variable.
        var action = component.get("c.getEventDetails");//Calling Apex class controller 'getEventDetails' method.
        action.setParams({
            sEventcode: sEventCode
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //console.log('fetchEventDetails'+JSON.stringify(response.getReturnValue()));
                component.set("v.Event_Setting", response.getReturnValue());// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
    },
    fetchExhibitors: function (component) {
        var sEventCode = component.get("v.eventcode");//Getting values from Aura attribute variable.
        var action = component.get("c.getExhibitors"); //Calling Apex class controller 'getExhibitors' method.
        action.setParams({
            sEventcode: sEventCode
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                //console.log('fetchExhibitors : '+JSON.stringify(response.getReturnValue()));
                var result = response.getReturnValue();
                var total = 0.00;
                for (var i = 0; i < result.length; i++) {
                    if (result[i].Amount__c) total = total + result[i].Amount__c;
                }
                component.set("v.totalAmount", total);// Adding values in Aura attribute variable.
                component.set("v.boothmap", result);// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
    },
    fetchAgents: function (component)
    {
        var sEventCode = component.get("v.eventcode");//Getting values from Aura attribute variable.
        var action = component.get("c.getAgents"); //Calling Apex class controller 'getExhibitors' method.
        action.setParams({
            sEventcode: sEventCode
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //console.log('fetchAgents : '+JSON.stringify(response.getReturnValue()));
                var result = response.getReturnValue();
                if (result) 
                {
                    var total = 0.00;
                    for (var i = 0; i < result.length; i++) {
                        if (result[i].Amount__c) total = total + result[i].Amount__c;
                    }
                    //component.set("v.totalAmount", total);// Adding values in Aura attribute variable.
                    component.set("v.boothAgentMap", result);// Adding values in Aura attribute variable.
                    if(result.length <=0)
                    {
                        component.set("v.hasAgentExh", false);// Adding values in Aura attribute variable.   
                    }
                }else
                {
                    component.set("v.hasAgentExh", false);// Adding values in Aura attribute variable.  
                }
            }
        });
        $A.enqueueAction(action);
    },
    updateConStatus: function (component, mid, sts) {
        var sEventCode = component.get("v.eventcode");//Getting values from Aura attribute variable.
        var action = component.get("c.updateStatus");//Calling Apex class controller 'updateStatus' method.
        action.setParams({
            sEventcode: sEventCode,
            mapId: mid,
            status: sts
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                this.fetchExhibitors(component);
                this.fetchContarctorStatus(component);
                this.fetchAgents(component);
                //console.log('Hiiii');
            }
            else {
                console.log('Some Error Occured');
            }
        });
        $A.enqueueAction(action);
    },
    getAgentsbooths: function (component, accid) {
        
        var sEventCode = component.get("v.eventcode");//Getting values from Aura attribute variable.
        var action = component.get("c.getAgentBooths");//Calling Apex class controller 'getAgentBooths' method.
        action.setParams({
            sEventcode: sEventCode,
            accid: accid,
            srchText: null
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                //console.log('Exhibitors'+JSON.stringify(result));
                component.set("v.Exhibitors", result);// Adding values in Aura attribute variable.Agents-Exhibitors
                document.getElementById('modalViewAll').style.display = "block";
                
            }
            else
            {
                component.set("v.Exhibitors", []);
                console.log('Some Error Occured!');
            }
        });
        $A.enqueueAction(action);        
    },
    fetchContarctorStatus: function (component) {
        var action = component.get("c.getContartorStatus");//Calling Apex class controller 'getContartorStatus' method.
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                var opts = [];
                for (var i = 0; i < response.getReturnValue().length; i++) {
                    opts.push({ label: response.getReturnValue()[i].split('__$__')[1].replace('Pending', '--Select--'), value: response.getReturnValue()[i].split('__$__')[0].replace('Pending', '') });
                }
                component.set("v.lstStatus", opts);// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
    },
    fetchPavilionSpaceExhibitors: function (component) {
        
        var srchTxt = component.get("v.searchTearm");
        var sEventCode = component.get("v.eventcode");
        var Agent = component.get("v.CurrentAgent");
        //console.log(Agent.Id + '      fetchPavilionSpaceExhibitors       ' + srchTxt);
        var action = component.get("c.getAgentBooths"); //Calling Apex class controller 'EventDetailMethod' method
        action.setParams({
            sEventcode: sEventCode,
            accid: Agent.Id,
            srchText: srchTxt
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                //console.log('fetchPavilionSpaceExhibitors'+JSON.stringify(response.getReturnValue()));
                component.set("v.Exhibitors", result);// Adding values in Aura attribute variable.Agents-Exhibitors
                document.getElementById('modalViewAll').style.display = "block";
            }
            else {
                component.set("v.Exhibitors", []);
                console.log('Some Error Occured!');
            }
        });
        $A.enqueueAction(action);
    },
    exportExhibitors: function (component) {
        // get the Records [Exhibitors] list from 'ViewContractor.cmp' component 
        var Exhibitor = component.get("v.Exhibitors");
        var Records = []; //final list 
        // check if "Records" parameter is null, then return from function
        if (Exhibitor == null || !Exhibitor.length) {
            return null;
        } else {
            for (var i = 0; i < Exhibitor.length; i++) {
                var exh = {
                    type: "Exhibitor",
                    sExhibitor: Exhibitor[i].Opportunity__r.Account.Name,
                    sBooths: Exhibitor[i].Booth_Number__c
                };
                Records.push(exh);
            }
        }
        // declare variables
        var csvStringResult;
        var counter;
        var keys;
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        var columnDivider = ',';
        var lineDivider = '\n';
        // check if "Records" parameter is null, then return from function
        if (Records == null || !Records.length) {
            return null;
        }
        // in the keys variable store fields API Names as a key 
        // these labels use in CSV file header  
        keys = ['sExhibitor', 'sBooths'];
        var map = {
            'sExhibitor': 'EXHIBITOR',
            'sBooths': 'BOOTH'
        };
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        for (var i = 0; i < Records.length; i++) {
            counter = 0;
            
            for (var sTempkey in keys) {
                var skey = keys[sTempkey];
                
                // add , [comma] after every String value,. [except first]
                if (counter > 0) {
                    csvStringResult += columnDivider;
                }
                csvStringResult += '"' + Records[i][skey] + '"';
                counter++;
            } // inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
        var FinalcsvStringResult = csvStringResult.split('\n');
        FinalcsvStringResult[0] = FinalcsvStringResult[0].replace(/sExhibitor|sBooths/gi, function (matched) {
            return map[matched];
        });
        FinalcsvStringResult = FinalcsvStringResult.join('\n');
        return FinalcsvStringResult.replace(/undefined|FALSE/gi, '');
    },
    getUrlParameter: function (component, parameterName) {
        var url = window.location.href;
        //console.log('url : '+url);
        var allParams = url.split('?')[1];
        var paramArray = allParams.split('&');
        var val;
        for (var i = 0; i < paramArray.length; i++) {
            var curentParam = paramArray[i];
            //console.log('curentParam : '+curentParam);
            if (curentParam.split('=')[0] == parameterName) {
                //console.log('Code ' + curentParam.split('=')[1]);
                val = curentParam.split('=')[1];
                //component.set("v.accountId",curentParam.split('=')[1]);
            }
        }
        return val;
    },
    
})