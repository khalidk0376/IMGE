({
    /* Modification Log----- 
    * Modified by : Girikon(Ashish)[CCEN-430] Dec 16 2018,Girikon(Himanshu [BK-2876 15 Dec 2019]
    **/
    loadOptions: function (component, event, helper) {
        helper.getOrgType(component);
        helper.fetchPicklistValues(component,'BoothContractorMapping__c','Status__c','v.options','--Designation Status--');
        helper.fetchPicklistValues(component,'Stand_Design__c','Booth_Design_Status__c','v.optionsBoothStatus','');
        helper.fetchPicklistValues(component,'Stand_Detail__c','Riggering_Options__c','v.riggeringOptions','');
        helper.getAggregateResults(component);
        helper.getDesignationInfos(component);
        var selCols = localStorage.getItem('selectedColumns'); 
               
        if (selCols) 
        { 
            //localStorage.removeItem('selectedColumns');  
            component.set("v.selectedColumns",JSON.parse(selCols));            
        }
        else 
        {
            component.set("v.selectedColumns",{exh:true,usrType:true,exhName:true,agntName:true,booth:true,boothType:true,comp:true,prfbnd:true,prfAmt:true,rig:true,doub:true,heavy:true,sub:true,ca:true,sts:true,desig:true,note:true,reqErlyAcc:true,erlyaccDte_Time:true,erlyAccCost:true,comphone:true,exhopCon:true,exhopEmail:true,exhopConMobile:true,exhopConTel:true,contContName:true,contContMobile:true,contContTel:true,contContEmail:true,exhUsname:true,contusrname:true,bostand:true,borigg:true,bvech:true,blen:true,bwdt:true}); 
            
        }
		helper.toggleColumnCheck(component);
        helper.filterContractor(component);//get data from the helper
        //console.log('PrntEventEditionId>>>>>>>>>>>>>>>>>>>>>>>'+component.get("v.PrntEventEditionId")); 
        //var scrollFunc = component.get("v.scrollFunc"); 
        
        window.onscroll = function () {

            var tabat = component.get("v.tabCssAtts");
            //console.log('length  #' +JSON.stringify(tabat.length));
            if (tabat) {
                for (var i = 0; i < tabat.length; i++) {
                    if (tabat[i].tabId == component.get("v.selTabVal")) {

                        CopyToClipBoard.ScrollFunction(tabat[i].hraderId, tabat[i].tabledataId, tabat[i].tableId, 355,48, true, component.get("v.isSandbox"));
                    
                    }
                }
            }
        };
     },
    onfilterContractor:function(component,event,helper) {
        component.set("v.PageNumber",1);  
        helper.filterContractor(component);
    }, 
    waiting: function(component, event, helper) {
        //component.set("v.isSpinner", true);// Adding values in Aura attribute variable. 
    },
    doneWaiting: function(component, event, helper) {
        //component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
    },
    sortContractor:function(component,event,helper) {
        //var a = document.getElementById("userType");
        //console.log('strExhibitor ===      ' +a.offsetWidth);
		var columnName = event.currentTarget.id;
        var sortingOrder = component.get("v.sortingOrder");
       	var oldSortingColumnName = component.get("v.sortingColumn");
        if(columnName!=oldSortingColumnName && sortingOrder=='asc'){            
            sortingOrder='desc';
        }
        else if(columnName!=oldSortingColumnName && sortingOrder=='desc'){
            sortingOrder='asc';
        }
            else if(columnName==oldSortingColumnName && sortingOrder=='asc'){
                sortingOrder='desc';
            }
                else if(columnName==oldSortingColumnName && sortingOrder=='desc'){
                    sortingOrder='asc';
                }
        
        component.set("v.sortingOrder",sortingOrder);
        component.set("v.sortingColumn",columnName);
        helper.sortData(component,columnName,sortingOrder);
        //console.log(columnName+'::'+oldSortingColumnName+'::'+sortingOrder);
    },
    hideConfirmModal : function(component, event, helper){
        helper.filterContractor(component); 
        document.getElementById('confirm').style.display = "none";
        component.set("v.PrntPopupclosed", true); 
        component.set("v.selTabId","tab1")
    },
    
    showConfirmModal : function(component, event, helper) {
        component.set("v.PrntAccountId", "");
        component.set("v.PrntBoothId", "");
        component.set("v.PrntPopupclosed", false);
        component.set("v.isSpinner", true);// Adding values in Aura attribute variable.
        helper.singleRecord(component, event, helper);
    },    
    handleActive: function (component, event, helper) {
        helper.loadTabs(component, event, helper);
        
    },
    tabSelected: function(component,event,helper) {
        //alert(component.get("v.selTabId"));
    },
    export: function(component, event,  helper){
        
        var csv = helper.exportData(component,event,helper); 
        if (csv == null){return;} 
        
        //Generate a file name
        var fileName = "All_Assigned_Contractors";
        //this will remove the blank-spaces from the title and replace it with an underscore
        //fileName += PositionTitle.replace(/ /g,"_");   
        fileName += ".csv";
        //Initialize file format you want csv or xls
        var uri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv); 
        
        if (navigator.msSaveBlob) { // IE 10+
            //console.log('----------------if-----------');
            var blob = new Blob([csv],{type: "text/csv;charset=utf-8;"});
            //console.log('----------------if-----------'+blob);
            navigator.msSaveBlob(blob, fileName);
        }
        else{
            var hiddenElement=  document.createElement("a");
            hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
            hiddenElement.target = '_blank';
            hiddenElement.download = fileName; 
            document.body.appendChild(hiddenElement);
            hiddenElement.click();
            document.body.removeChild(hiddenElement);
        }
    },
    showTableSettings: function(component,event,helper) {
        document.getElementById('modalTableSet').style.display = "block";
    },
    hideModalDeleteStandContractor: function(component,event,helper) {
        document.getElementById('reasonForCancel').style.display = "none"; 
       	document.getElementById('modalDeleteStandContractor').style.display = "none";
        document.getElementById('reasonForDontWantToCancel').style.display = "none";  
    },
    checkModalThenClose:function(component,event,helper) {
       var rejectionReason = component.find("rject").get("v.value");
        console.log('test',rejectionReason);
        if(rejectionReason!=''){
            document.getElementById('reasonForCancel').style.display = "none";  
            document.getElementById('reasonForDontWantToCancel').style.display = "block";  
        }
        else{
            document.getElementById('reasonForCancel').style.display = "none";  
            document.getElementById('reasonForDontWantToCancel').style.display = "none";  
            document.getElementById('modalDeleteStandContractor').style.display = "none";
        }
    },
    showModalDeleteStandContractor: function(component,event,helper) {
        var target = event.getSource();
        var bthConID = target.get("v.value");
        component.set("v.toDeleteVal",bthConID);
        console.log('Id::' + bthConID);
        document.getElementById('modalDeleteStandContractor').style.display = "block";
    },
    hideModalDeleteStandDetailsDesign: function(component,event,helper) { // Delete Stand Design And details
        document.getElementById('modalDeleteStandDetailsDesign').style.display = "none";
    },
    showModalDeleteStandDetailsDesign: function(component,event,helper) {
        var target = event.getSource();
        var bthConID = target.get("v.value");
        component.set("v.toDeleteDetials",bthConID);
        //console.log('showModalDeleteStandDetailsDesign = '+bthConID);
        document.getElementById('modalDeleteStandDetailsDesign').style.display = "block";
    },
    hideTableSettings: function(component,event,helper) {
        helper.toggleColumnCheck(component);
        document.getElementById('modalTableSet').style.display = "none";
    },
    applySettings: function(component,event,helper) { //need to some Code for type
        
        document.getElementById('viewExhTable').style.display = "none";
        var cols=component.get("v.tableColumns");
        var selCols=component.get("v.selectedColumns");
        console.log('testolvalue',JSON.stringify(selCols));
        selCols.exh=cols[0].visible;
        selCols.usrType=cols[1].visible;
        selCols.exhName=cols[2].visible;
        selCols.agntName=cols[3].visible;
        selCols.booth=cols[4].visible;
        selCols.boothType=cols[5].visible;
        selCols.comp=cols[6].visible;
        selCols.prfbnd=cols[7].visible;
        selCols.prfAmt=cols[8].visible;
        selCols.rig=cols[9].visible;
        selCols.doub=cols[10].visible;
        selCols.heavy=cols[11].visible;
        selCols.bvech=cols[12].visible; 
		selCols.sub=cols[13].visible;
        selCols.ca=cols[14].visible;
        selCols.sts=cols[15].visible;
        selCols.desig=cols[16].visible;
        selCols.note=cols[17].visible;
        selCols.reqErlyAcc=cols[18].visible;
        selCols.erlyaccDte_Time=cols[19].visible;
        selCols.erlyAccCost=cols[20].visible;
        selCols.comphone=cols[21].visible;
        selCols.exhopCon=cols[22].visible;
        selCols.exhopEmail=cols[23].visible;
        selCols.exhopConMobile=cols[24].visible;
        selCols.exhopConTel=cols[25].visible;
        selCols.contContName=cols[26].visible;
        selCols.contContMobile=cols[27].visible;
        selCols.contContTel=cols[28].visible;
        selCols.contContEmail=cols[29].visible;
      	selCols.exhUsname=cols[30].visible;
        selCols.contusrname=cols[31].visible;
        selCols.bostand=cols[32].visible;
        selCols.borigg=cols[33].visible;
        selCols.blen=cols[34].visible;
        selCols.bwdt=cols[35].visible;
         
       	component.set("v.selectedColumns",selCols);
        console.log('testColValue'+JSON.stringify(component.get("v.tableColumns")));
        localStorage.setItem('selectedColumns',JSON.stringify(selCols));
        localStorage.setItem('allColumns',JSON.stringify(cols));
        document.getElementById('modalTableSet').style.display = "none";
        document.getElementById('viewExhTable').style.display = "block";
        //helper.filterContractor(component);//get data from the helper
        //console.log('allColumns   '+ JSON.stringify(cols)+ '   \nselectedColumns   '+JSON.stringify(selCols));
        
		        

      
    },
    handleSelectChangeEvent: function(component, event, helper) {
        var items = event.getParam("values");
       	var data='';
        for (var i = 0; i < items.length; i++) {
            data+=data==''?items[i]: ','+items[i]; 
        }
       	if(data)
        {
            component.set("v.selectedValue2", data);
            helper.filterContractor(component);
        }
        else
        {
            component.set("v.selectedValue2", "All"); 
            helper.filterContractor(component);
        }
    },
    selectChangeEventRigging: function(component, event, helper) {
        var items = event.getParam("values");
        var data='';
        for (var i = 0; i < items.length; i++) {
            data+=data==''?items[i]: ','+items[i]; 
        }
        if(data)
        {
            component.set("v.selectedRiggedOption", data);
            helper.filterContractor(component);
        }
        else
        {
            component.set("v.selectedRiggedOption", "All"); 
            helper.filterContractor(component);
        }
    },
    removeStandDetailsDesign : function(component, event, helper) {
        var bthConMapID =component.get("v.toDeleteDetials");
        if(bthConMapID)
        {
            helper.deleteDesignDetails(component,bthConMapID);
        }    
        document.getElementById('modalDeleteStandDetailsDesign').style.display = "none";
    },
    removeStandContractor : function(component, event, helper) {
        var rejectionReason = component.find("rject").get("v.value");
        console.log('test',rejectionReason);
        if(rejectionReason===''){
            document.getElementById('reasonForDontWantToCancel').style.display = "none";  
            document.getElementById('reasonForCancel').style.display = "block";
        }
        else{
            var bthConMapID =component.get("v.toDeleteVal");
            if(bthConMapID){
                helper.deleteContractor(component,bthConMapID,rejectionReason);
            }    
            document.getElementById('modalDeleteStandContractor').style.display = "none";
            document.getElementById('reasonForCancel').style.display = "none";
        }
    },
    downloadexcel: function(component){
        //console.log('1');
        var url = window.location.origin + '/apex/c__AllContractorsReportExport?event=' + component.get("v.EventId") + '&bdstatus=' + component.get("v.selectedValue2");
        
        console.log(component.get("v.selectedValue2") );
        url = url+ '&status='+component.get("v.selectedValue")+'&rigged='+component.get("v.selectedRiggedOption")+'&search='+component.get("v.searchTearm")+'&bDblDckrStatus='+component.get("v.isDoubleDecker");
        
        //console.log('3');
        url = url+ '&bCA='+component.get("v.isCA")+'&pbs='+component.get("v.isPBS")+'&pbns='+component.get("v.isPBNS")+'&sme='+component.get("v.isSME") +'&isAllAgt='+component.get("v.isAllAgt")+'&isAgtPvnSpc='+component.get("v.isAgtPvnSpc")+'&compName=AllAssigned&reportName=AllContractors';
        
        console.log(url);
        window.location = url;
    },
    onfilterExhibitor: function (component, event, helper) {
        helper.fetchPavilionSpaceExhibitors(component);
    },
    showModalViewAll: function(component, event, helper) {
        var agentAccID = event.currentTarget.getAttribute("data-id");
        var agentAccName = event.currentTarget.getAttribute("data-Name");
        var Agent =
            {
                type: "Agent",
                Id: agentAccID,
                Name: agentAccName
            };
        component.set("v.CurrentAgent", Agent);// Adding values in Aura attribute variable.
        //console.log('agentAccID============  '+agentAccID+ ' agentAccName '+agentAccName);
        //component.set("v.Spinner", true); 
        helper.fetchPavilionSpaceExhibitors(component);
    },
    hideViewAll: function(component, event, helper) {
        document.getElementById('Agent_Exhibitormodel').style.display = "none";
    },
    handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        pageNumber++;
        component.set("v.PageNumber",pageNumber);   
        helper.filterContractor(component);
    },
    handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        pageNumber--;
        component.set("v.PageNumber",pageNumber);  
        helper.filterContractor(component);
    },
    onSelectChange: function(component, event, helper) {
        var pageSize = component.find("pageSize").get("v.value"); 
        component.set("v.PageNumber",1);  
        component.set("v.pageSize",pageSize);  
        helper.filterContractor(component); 
    },
})