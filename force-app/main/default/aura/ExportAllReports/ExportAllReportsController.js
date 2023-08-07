/**
 * Created By   :   Girikon(Suraj)
 * Created On   :   10/01/2019
 * Description  :   Allow ops admin to generate reports .
 **/
({
	export : function(component, event, helper) {
		var reportname = component.get('v.ReportName');
		
		var url = window.location.origin + '/apex/c__AllReportsExport?event=' +component.get("v.eventId") + '&compName='+reportname;
		if(reportname == 'MatchProductType'){            
			url+= '&reportName=Match_Product_Type';
		}else if(reportname == 'LastLogin'){
			url+= '&reportName=Last_Login_report';
        }else if(reportname == 'ShowCategory'){             
            url+= '&reportName=Show_Category_report';
        }
		window.location =  url;
	}
})