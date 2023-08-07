({
    OnloadData: function (component, event, helper) {
       helper.GetOpportunity(component, event, helper);//get data from the helper
      // console.log('uType =='+component.get("v.uType"));
    },
    handleClick: function (component, event, helper) {
       helper.SendEmail(component, event, helper);//get data from the helper
        component.set("v.isForReset",false);
       component.set("v.isOpen", true);
    },
    resetPassword: function (component, event, helper) {
        helper.resetPassword(component, event, helper);//get data from the helper
        component.set("v.isForReset",true);
        component.set("v.isOpen", true);
    },
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
         component.set("v.isForReset",false);
        component.set("v.isOpen", true);
    },
    customerCenter:function(component, event, helper) 
    {  
        window.open("","_blank");
    },
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
         component.set("v.isForReset",false);
        component.set("v.isOpen", false);
    },
    loginAsUser : function(component, event, helper)
    {
        var UserId=event.getSource().get("v.value"); 
        var wrap =  component.get("v.OppWrapper");
        if(wrap)
        {
            var networkID = wrap.sNetworkid;
            var orgID = wrap.sOrgId;
            var baseurl = wrap.baseUrl;
            var redirectLink =  '/servlet/servlet.su?oid='+orgID+'&retURL= '+'&sunetworkid='+networkID+'&sunetworkuserid='+UserId;
            var url = baseurl+redirectLink; 
            //console.log('url ===== '+url);
            window.open(url,"_blank");
        }
     
    }
})