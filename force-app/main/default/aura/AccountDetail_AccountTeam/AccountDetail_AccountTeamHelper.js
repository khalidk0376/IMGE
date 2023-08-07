({
    fetchData: function(component,pageNumber) {
        var pageSize = 10;
        var action = component.get("c.getRecords");
        action.setParams({ objName: "AccountTeamMember", fieldNames: 'Id, AccountId, TeamMemberRole, Title, User.Name', compareWith: 'AccountId', recordId: component.get("v.recordId"), pageNumber: pageNumber, pageSize: pageSize });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var result = res.getReturnValue();
                var resActeams = res.getReturnValue().recordList;
                console.log(resActeams);
                for (var i = 0; i < resActeams.length; i++) {
                    if (resActeams[i].hasOwnProperty('User')) {
                        resActeams[i].userLink = '/lightning/r/User/' + resActeams[i].User.Id + '/view';
                        resActeams[i].Name = resActeams[i].User.Name;
                    }
                }
                component.set("v.data", resActeams);
                component.set("v.PageNumber", result.pageNumber);
                component.set("v.TotalRecords", result.totalRecords);
                component.set("v.RecordStart", result.recordStart);
                component.set("v.RecordEnd", result.recordEnd);
                component.set("v.TotalPages", Math.ceil(result.totalRecords / pageSize));
                component.set("v.showSpinner", false);
            } else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    isCurrentUserInTeam: function(component) {
        var action = component.get("c.isAMember");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var resActeams = res.getReturnValue();
                if (resActeams == true) {
                    component.set("v.showButton", false);
                } else {
                    component.set("v.showButton", true);
                }
            } else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    deleteAcTeam: function(component, acId) {
        var pageNumber = component.get("v.PageNumber");
        component.set("v.showSpinner", true);
        var action = component.get("c.deleteAcTeam");
        action.setParams({ recordId: acId });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                window._LtngUtility.toast('Success', 'success', 'Success');
                this.fetchData(component,pageNumber);
                this.isCurrentUserInTeam(component);
            } else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    editRecord: function(component, acId) {
        var pageNumber = component.get("v.PageNumber");
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": acId
        });
        editRecordEvent.fire();
        this.fetchData(component,pageNumber);
    },
    
    getUserDetails: function(component) {
        var action = component.get("c.getCurrentUserDtls");
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var userDtls = res.getReturnValue();
                if (userDtls.Profile.Name == 'System Administrator' || userDtls.Profile.Name == 'GE BA Administrator' || userDtls.Profile.Name == 'GE System Administrator') {
                    component.set("v.isNotVisibleforNoAdmin", true);
                }
                else {
                    component.set("v.isNotVisibleforNoAdmin", false); 
                }
            }
        });
        $A.enqueueAction(action);
    },

    validate:function(component){
        var isvalid = true;
        if($A.util.isEmpty(component.find("TeamMemberRoles").get("v.value"))){
            isvalid = false;
            $A.util.addClass(component.find("TeamMemberRoles"),"slds-has-error");
        }
        if(!isvalid){
            window._LtngUtility.toast('Error!','error','Please Enter Team Role.');
        }
        return isvalid; 
    },
})