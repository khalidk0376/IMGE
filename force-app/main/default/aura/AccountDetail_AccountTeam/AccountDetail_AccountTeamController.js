({
    loadData: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        var actions = [
            { label: 'Edit', name: 'Edit' },
            { label: 'Delete', name: 'Delete' }
        ]
        var recordId = component.get("v.recordId");
        var columns; {
            columns = [
                { label: 'Team Member', fieldName: 'userLink', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_self' } },
                { label: 'Role', fieldName: 'TeamMemberRole', type: 'text' },
                { label: 'Title', fieldName: 'Title', type: 'text' },
                { type: 'action', typeAttributes: { rowActions: actions } }
            ];
        }
        component.set('v.columns', columns);
        helper.fetchData(component, pageNumber);
        helper.isCurrentUserInTeam(component);
        component.set("v.AccountTeamObject",{sobjectType:'AccountTeamMember', TeamMemberRole :'Account Executive' });
        helper.getUserDetails(component);
        //helper.validate(component);
    },
    handleRowAction: function(cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        if (action.name == 'Edit') {
            helper.editRecord(cmp, row.Id);
        } else if (action.name == 'Delete') {
            helper.deleteAcTeam(cmp, row.Id);
        }
    },
    addNewTeamCCc: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        component.set("v.showSpinner", true);
        var action = component.get("c.addNewTeam");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                helper.fetchData(component, pageNumber);
                component.set("v.showButton", false);
            } else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    handleNext: function(component, event, helper) {
        component.set("v.showSpinner", true);
        var pageNumber = component.get("v.PageNumber");
        //var pageSize = component.find("pageSize").get("v.value");
        pageNumber++;
        helper.fetchData(component, pageNumber);
    },
    handlePrev: function(component, event, helper) {
        component.set("v.showSpinner", true);
        var pageNumber = component.get("v.PageNumber");
        //var pageSize = component.find("pageSize").get("v.value");
        pageNumber--;
        helper.fetchData(component, pageNumber);
    }, 
    // Function to  call and open new Popup for Account Team Memeber Screen : Rajesh  Kumar - 16-06-2020 BK-5025
    addAccountTeamMember :  function(component, event, helper) {
        var getNewButtonValue = component.get("v.newAddAccountTeam");
        component.set("v.newAddAccountTeam",true);
    },
    closeModal : function(component, event, helper) {
        component.set("v.AccountTeamObject",{});
        component.set("v.newAddAccountTeam",false);
    },
    saveandnew: function(component, event, helper) {       
        component.set("v.isClickSaveAndNew",true);
    },
    handleSuccess: function(component, event, helper) {
        var isSavenew = component.get("v.isClickSaveAndNew");
        var pageNumber = component.get("v.PageNumber");
        if (isSavenew){            
            component.set("v.spinner", false);
            window._LtngUtility.toast('Success', 'success', 'New Account Team Member has been added.');
            helper.fetchData(component, pageNumber);
            component.set("v.newAddAccountTeam",false);
            component.set("v.AccountTeamObject",{sobjectType:'AccountTeamMember', TeamMemberRole :'Account Executive' });
            var delay=2000; //2 seconds
            setTimeout(function() {
                component.set("v.newAddAccountTeam",true);
                component.set("v.isClickSaveAndNew",false);
            }, delay);
        }
        else{
            component.set("v.spinner", false);
            window._LtngUtility.toast('Success', 'success', 'New Account Team Member has been added.');
            helper.fetchData(component, pageNumber);
            component.set("v.AccountTeamObject",{sobjectType:'AccountTeamMember', TeamMemberRole :'Account Executive' });
            component.set("v.newAddAccountTeam",false);
        }
    },
    
    handleSubmit: function(component, event, helper) {
        event.preventDefault(); // stop the form from submitting
        if (helper.validate(component)){
            var fields = event.getParam('fields');
            debugger;
            //alert(fields.Event_Edition_Currency__c);            
            component.find('editForm2').submit(fields);
            component.set("v.spinner", true);
        }

    },
    
    handleError: function(component, event, helper) {
        component.set("v.spinner", false);
        window._LtngUtility.handleError(event.getParams().error);
    },
    
    validateForm: function(component, event, helper) {
        helper.validate(component);
    }
})