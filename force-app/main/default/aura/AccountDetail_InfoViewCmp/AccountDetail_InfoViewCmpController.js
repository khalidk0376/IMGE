({
    loadData: function(cmp, event, helper) {
        helper.fetchUser(cmp);
        helper.getUserAccess(cmp);
        helper.fetchData(cmp);
        var getSelected = localStorage.getItem('selectedAccordiansAcc');
        if (getSelected) {
            cmp.set("v.activeSections", JSON.parse(getSelected));
        }
    },
    handleSectionToggle: function(cmp, event) {
        localStorage.setItem('selectedAccordiansAcc', JSON.stringify(cmp.find("accAccordion").get('v.activeSectionName')));
    },
    editRecord: function(cmp, event, helper) {
        if (cmp.get("v.usrAccess").HasEditAccess) {
            cmp.set("v.isEditForm", true);
        } else {
            window._LtngUtility.toast('Error', 'error', 'You have no access to edit this record.');
        }
    }
})