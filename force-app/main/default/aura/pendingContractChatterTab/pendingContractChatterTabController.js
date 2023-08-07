({
    doInit : function(component, event, helper) {
        var id = component.get('v.recordId');
		var url = 'https://informage--devltn--c.cs42.visual.force.com/apex/SSCChatter?Id='+id;
        component.set('v.url',url);
    }
})