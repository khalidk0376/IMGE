({
	GetQS: function(url, key) {
       var a = "";
        if(url.includes('?'))
        {
            var Qs = url.split('?')[1].replace(/^\s+|\s+$/g, '');
            console.log('tt23',Qs);
            if (Qs !== "") {
                let qsArr = Qs.split("&");
                for (let i = 0; i < qsArr.length; i++)
                    if (qsArr[i].split("=")[0] === key)
                        a = qsArr[i].split("=")[1];
            }
            console.log('a...code',a);
            return a;
        }
		//window.location.href='/CustomerCenter/s/'
     }
})