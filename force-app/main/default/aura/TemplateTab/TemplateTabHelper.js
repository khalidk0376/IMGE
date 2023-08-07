({
    getParameterByName: function(component,name) {
        //changes regarding ticketno.BK-1841
        var url = new URL(window.location.href);
        //console.log(url);
        return url.searchParams.get(name);
        //ends here..
        /*
        name = name.replace(/[\[\]]/g, "\\$&");
        
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));*/
    }	
})