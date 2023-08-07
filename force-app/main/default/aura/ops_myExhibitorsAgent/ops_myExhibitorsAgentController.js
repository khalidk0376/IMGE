({
    onLoad : function(component, event, helper) {
        let fullUrl = window.location.href;
        var eId=helper.GetQS(fullUrl,'id');
        component.set("v.eventId",eId);
        if(eId)
        {
            helper.fetchPicklist(component,eId);
        }
    },
    goToCustomerCenter : function(component, event, helper) {
        var redirectUrl = '/lightning/n/ops_customer_centre';
        window.location.href = redirectUrl;
    },
    goToCustomerCenterSetting : function(component, event, helper) {
        var redirectUrl = '/lightning/n/ops_customer_centre_settings#id=' +component.get("v.eventId");
        window.location.href = redirectUrl;
    }
})