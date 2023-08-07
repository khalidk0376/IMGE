({
    doInit : function(component, event, helper) 
    {
        var key = component.get("v.key");
        var map = component.get("v.map");
        
        //console.log('map : '+ JSON.stringify(map));
        if(map[key])
        {
        	component.set("v.value" , map[key]);    
        }else
        {
            component.set("v.value",component.get("v.DefaultValue"));
        }
    },
})