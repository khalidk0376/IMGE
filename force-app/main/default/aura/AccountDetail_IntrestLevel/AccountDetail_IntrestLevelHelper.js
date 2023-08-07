({
    fetchData: function(component) {
        var action = component.get("c.getInterestLevelMappings");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var resInterestLevel = res.getReturnValue();
                for (var i = 0; i < resInterestLevel.length; i++) {
                    if (resInterestLevel[i].hasOwnProperty('L1__r')) { resInterestLevel[i].l1Value = resInterestLevel[i].L1__r.LevelValue__c }
                    if (resInterestLevel[i].hasOwnProperty('L2__r')) { resInterestLevel[i].l2Value = resInterestLevel[i].L2__r.LevelValue__c }
                    if (resInterestLevel[i].hasOwnProperty('L3__r')) { resInterestLevel[i].l3Value = resInterestLevel[i].L3__r.LevelValue__c }
                    if (resInterestLevel[i].hasOwnProperty('SFDCOpportunityID__r')) {
                        resInterestLevel[i].opplink = '/lightning/r/Opportunity/' + resInterestLevel[i].SFDCOpportunityID__c + '/view';
                        resInterestLevel[i].oppName = resInterestLevel[i].SFDCOpportunityID__r.Name;
                    }

                }
                component.set("v.data", resInterestLevel);
            } else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    }
})