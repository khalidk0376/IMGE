({
    onLoad : function(component, event, helper) {
        let fullUrl = window.location.href;
        var eId=helper.GetQS(fullUrl,'id');
        var esid=helper.GetQS(fullUrl, 'esid');
        
        component.set("v.eventId",eId);
        component.set("v.recordId",esid);
        
        helper.fetchPicklist(component,eId);
        helper.getcustomerBadgesChk(component,esid);
    },
    goToCustomerCenter : function(component, event, helper) {
        var redirectUrl = '/lightning/n/ops_customer_centre';
        window.location.href = redirectUrl;
    },
    goToCustomerCenterSetting : function(component, event, helper) {
        var redirectUrl = '/lightning/n/ops_customer_centre_settings#id=' +component.get("v.eventId");
        window.location.href = redirectUrl;
    },
    chkBadgesMethodBooth: function( component, event, helper) {
        var checkBooth =component.find("checkbox").get("v.value");
        component.set("v.chkBadgeValueBooth",checkBooth);
        if(checkBooth){
            component.set("v.chkFlagBooth",true);
            component.set("v.chkMatchedDisabled",true);
        }else{
            component.set("v.chkFlagBooth",false);
            component.set("v.chkMatchedDisabled",false);
        }
        var chkFlagMatch=component.get("v.chkFlagMatch");
        if(!chkFlagMatch){
            component.set("v.chkBoothDisabled",false);
        }else{
            component.set("v.chkBoothDisabled",true);
        }
        component.find('eventFormSize').submit();
    },
    chkBadgesMethodMatched: function( component, event, helper) {
        var checkMatched =component.find("checkbox1").get("v.value");
        component.set("v.chkBadgeValueMatched",checkMatched);
        if(checkMatched){
            component.set("v.chkFlagMatch",true);
            component.set("v.chkBoothDisabled",true);
        }else{
            component.set("v.chkFlagMatch",false);
            component.set("v.chkBoothDisabled",false);
        }
        var chkFlagBooth=component.get("v.chkFlagBooth");
        if(!chkFlagBooth){
            component.set("v.chkMatchedDisabled",false);
        }else{
            component.set("v.chkMatchedDisabled",true);
        }
         component.find('eventFormType').submit();
    },   
})