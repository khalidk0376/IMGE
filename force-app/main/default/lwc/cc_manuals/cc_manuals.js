/* eslint-disable no-console */
import {LightningElement,track,api,wire} from 'lwc';
import getDatas from '@salesforce/apex/CommonTableController.getGenericObjectRecord';


import getFileDetail from '@salesforce/apex/CommonTableController.getFileDetail';
import manual from '@salesforce/label/c.Manual';
import name from '@salesforce/label/c.Name';
import provider from '@salesforce/label/c.Provider';
import type from '@salesforce/label/c.Type';
import deadline from '@salesforce/label/c.Deadline';
import viewed from '@salesforce/label/c.Viewed';
import agreed from '@salesforce/label/c.Agreed';
import save from '@salesforce/label/c.Save';
import close from '@salesforce/label/c.Close';
import downloadpdf from '@salesforce/label/c.Download_PDF';
import readandagree from '@salesforce/label/c.Read_and_Agree';
import required from "@salesforce/label/c.Required";
import manuals from "@salesforce/label/c.Manuals";
import additional from "@salesforce/label/c.Additional";
import userId from '@salesforce/user/Id';
import {handleErrors, showToast} from 'c/lWCUtility';
import { CurrentPageReference } from 'lightning/navigation';
import updateManualAction from '@salesforce/apex/CC_ManualsCtrl.updateUserAction';
import getManualSetting from "@salesforce/apex/LtngUtilityCtrl.getRecords";
import getContentVerId from '@salesforce/apex/OPS_FormTemplatesCtrl.getContentVersionId';
import LastUpdated from '@salesforce/label/c.Last_Updated';
import By from '@salesforce/label/c.By';


const DELAY=300;
var manualPermId;
var eventcode;
export default class DrawerTable extends LightningElement {
    label = {manual,name,provider,type,deadline,viewed,agreed,save,close,downloadpdf,readandagree,required, manuals, additional,LastUpdated,By };
    lastUpdatedBy = this.label.LastUpdated+' '+this.label.By;
    //action properties
    @api isSupportNewRecord='false';
    @track isOpenSingleDeleteModal=false;
    @track selectedRecordId;

    //Pagination properties
    @track pagesize=50;
    @track currentPageNo=1;
    @track totalPages=0;    
    // pagination item list like (1..2-3-4-5..6)    
    @track pageList; 
    @track totalrows=0;
    @track offst=0;
    @track hasNext=false;
    @track hasPrev=false;
    @track searchValue='';
    @track showPageView='0';
    @track sortByFieldName='';
    @track sortByName='Manual_Permission__r.Manuals__r.Name';
    @track sortType='asc';
    @track lastind;
    @track showSpinner = true;

    //Set object and fields to create datatable
    @track tableData;
    @track tableColumn;
    @api objectName='User_Manual_Action__c';
    @api objectLabel='User Manual Action';    
    @api fields='Manual_Permission__r.Manuals__r.Name,Manual_Permission__r.Manuals__r.Provider__c,Manual_Permission__r.Manuals__r.Manual_Type__c,Manual_Permission__r.Manuals__r.Deadline__c,Is_Viewed__c,Is_Agree__c,Manual_Permission__r.Manuals__r.Allow_Submit_After_Deadline__c,Manual_Permission__r.Manuals__r.Uploaded_Attachment_Id__c,Manual_Permission__r.Id,Manual_Permission__r.Manuals__r.Url__c,Manual_Permission__r.Manuals__r.Id,LastModifiedBy.ContactId,LastModifiedBy.Name,LastModifiedDate,LastModifiedBy.Id';
    @api fieldsLabel='Id,Name';
    @api condition='Name!=\'\'';
    @track tempCondition='';
    @api profile='';    
    @api isViewFile='false';
    @track downloadModal = false;
    @track pdf='';
    @track view;
  
    @track errorModal = false;
    @track buttonView;
    @track eventDtls;
    @track showpagination;
    @api manualtype;
    @track showRequired;
    @track showAddtional;
    @track showTable;
    @track showUpdatedHeading = false;

    
    @api isShowAction='false';
    @api showActionButton='false';
    //Filter property
    //Owner Filter
    @api isFilterByOwner;    
    @api selectedOwner;


    //filter1
    @api filterField1;
    @api filter1Label;
    @api isMultiPicklistFilter1;
    @track filterField1Options;
    @track filterField1Value='';
    
    //filter 2
    @api filterField2;
    @api filter2Label;
    @api isMultiPicklistFilter2;
    @track filterField2Options;
    @track filterField2Value='';

    //filter 3
    @api filterField3;
    @api filter3Label;
    @api isMultiPicklistFilter3;
    @track filterField3Options;
    @track filterField3Value='';

    @track error;
    @track firstTime;
    @track spinner;
    @track isShow;
    @track colSpan;

    @api eventEditionCode; // added by Mukesh Gupta[STL-216]

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        //this.selectedOwner = userId;
        this.firstTime=true;
        this.spinner = false;
        this.hasNext = false;
        this.hasPrev = false;
        this.pagesize = 50;
        this.offst = 0;
        const col = [];
        if(typeof this.fields === 'string'){
            this.fields.split(',').forEach((item,i) => {                
                col.push({label:this.fieldsLabel.split(',')[i],fieldName:item.trim()});
            });
            this.colSpan = col.length+1;
        }
        else{
            this.fields='';
        }
        
        if(typeof this.objectName !='string'){
            this.objectName = '';
        }        
        this.tableColumn = col;

        if(this.filterField1!==undefined){
            this.setFilterOptions(1,this.filterField1);
        }
        if(this.filterField2!==undefined){
            this.setFilterOptions(2,this.filterField2);
        }
        if(this.filterField3!==undefined){            
            this.setFilterOptions(3,this.filterField3);
        }
        this.isShow = this.spinner===false && this.firstTime;
        if(this.manualtype==='Required'){
            this.showRequired=true;
        }
        if(this.manualtype==='Additional'){
            this.showAdditional=true;
           //this.showSpinner = false;
        }
        if(currentPageReference && currentPageReference.state){
            eventcode=currentPageReference.state.eventcode;
            this.fetchManuals(eventcode);
        }
        else if(this.eventEditionCode){
            this.fetchManuals(this.eventEditionCode);
        }
    }
    fetchManuals(evntCode)
    {
      getManualSetting({objName:'Event_Settings__c',fieldNames:'id, Manuals_Title__c,Welcome_Text_Manuals__c,Show_Hide_Manual_Agreed__c,Deadline_Reached_Message_for_Manuals__c,Manuals_Sub_Title__c,Button_colors__c,Button_Text_Color__c',compareWith:'Event_Edition__r.Event_Code__c',recordId:evntCode,pageNumber:1,pageSize:1})
            .then(result => {
               
                this.eventDtls=result.recordList[0];
                this.handleFilterChange();
            })
            .catch(error => {
                window.console.log('error...'+JSON.stringify(error));
            });
    }
    @track showPdf;
    ViewedLink(event)
    {
        let tempArr = this.tableData;
        let manualType = tempArr[event.currentTarget.dataset.id].Manual_Permission__rManuals__rManual_Type__c;
        let manualUrl = tempArr[event.currentTarget.dataset.id].Manual_Permission__rManuals__rUrl__c;
        let allowSubmit = tempArr[event.currentTarget.dataset.id].Manual_Permission__rManuals__rAllow_Submit_After_Deadline__c;
        let deadlineManual = tempArr[event.currentTarget.dataset.id].Manual_Permission__rManuals__rDeadline__c;
        manualPermId = tempArr[event.currentTarget.dataset.id].Id;
        let uploadAttachId = tempArr[event.currentTarget.dataset.id].Manual_Permission__rManuals__rUploaded_Attachment_Id__c;
        let isAgree = tempArr[event.currentTarget.dataset.id].Is_Agree__c;
        let nowDate = new Date();
        let nowDt = nowDate.getFullYear()+'-'+(nowDate.getMonth()+1)+'-'+nowDate.getDate();
        let isError = false;
        
        if(!allowSubmit){
           
        if(Date.parse(deadlineManual) < Date.parse(nowDt))
            {
                
                isError = true;
            }
        }
        
         if(manualType==='Link'){
            if(!manualUrl.includes("http:") && !manualUrl.includes("https:")) // check if link url contains http or https
            {
                let newUrl= "https://" +manualUrl;
                manualUrl = newUrl;
            }
               if(allowSubmit){
                    window.open(manualUrl, '_blank');
                    this.updateUserViewed(manualPermId,true,false); 
               }
                else if(isError===true){
                  this.errorModal = true
               }
                else {
                     window.open(manualUrl, '_blank');
                     this.updateUserViewed(manualPermId,true,false); 
               }
             }
             else if(manualType==='Downloadable PDF'){
                //BK-27727
                /*let fileId1 = uploadAttachId.toString();
                let fileId2 = fileId1.match(/00P/);
                
                if(fileId2){
                    this.showPdf = '/CustomerCenter/servlet/servlet.FileDownload?file=' +uploadAttachId;
                    if(allowSubmit){
                    
                        if(isAgree){
                        this.buttonView = true; 
                        }
                        else
                        {
                            this.buttonView = false;  
                        }
    
                        this.pdf = this.showPdf;
                        this.downloadModal = true
                        this.updateUserViewed(manualPermId,true,false); 
                   }
                    else if(isError===true){
                       this.errorModal = true
                    }
                    else {
                        
                        if(isAgree){
                            this.buttonView = true; 
                            }
                            else
                            {
                                this.buttonView = false;  
                            }
                       this.pdf = this.showPdf;
                       this.downloadModal = true
                       this.updateUserViewed(manualPermId,true,false); 
                   }
                }*/ // BK-27727
                //else{
                   getContentVerId({
                       docId: uploadAttachId
                       })
                       .then(result => {
                           let fileId = result.Id;
                           this.showPdf = '/CustomerCenter/sfc/servlet.shepherd/version/download/'+fileId;
                           if(allowSubmit){
                    
                            if(isAgree){
                            this.buttonView = true; 
                            }
                            else
                            {
                                this.buttonView = false;  
                            }
        
                            this.pdf = this.showPdf;
                            this.downloadModal = true
                            this.updateUserViewed(manualPermId,true,false); 
                       }
                        else if(isError===true){
                           this.errorModal = true
                        }
                        else {
                            
                            if(isAgree){
                                this.buttonView = true; 
                                }
                                else
                                {
                                    this.buttonView = false;  
                                }
                           this.pdf = this.showPdf;
                           this.downloadModal = true
                           this.updateUserViewed(manualPermId,true,false); 
                       }
                       })
                       .catch(error => {
                           window.console.log("error..." + JSON.stringify(error));
                       });
                   //}
                
            }  
        } 
        ShowSaveButton(){
            if(this.buttonView){
                this.buttonView = false;
            }
            else{
                this.buttonView = true;
            }
        }
        userAgree()
        {
            this.updateUserViewed(manualPermId,false,true);
            this.downloadModal = false
        }

        updateUserViewed(manualPerId,isView,isAgree){
            updateManualAction({ sId : manualPerId , isViewed : isView , isAgreed : isAgree})
            .then(result => {
               this.result = result;
                this.getData();
            })
            .catch(error => {
                window.console.log('error...'+JSON.stringify(error));
                this.error = error;
            });
        }

    ClosedPopup(){
        this.downloadModal = false
        this.errorModal = false
    }
    @track pagesizeVisible
    getData(){
        
        this.pagesizeVisible = this.pagesize.toString();
        getDatas({searchValue:this.searchValue,objectName:this.objectName,fieldstoget:this.fields,pagesize:this.pagesize,
            next:this.hasNext,prev:this.hasPrev,off:this.offst,sortBy:this.sortByName,sortType:this.sortType,condition:this.tempCondition})
        .then(data=>{          
            this.renderSpinner = true;  
            if(this.offst === -1){
                this.offst = 0;
            }
            this.firstTime = false;
            this.spinner = false;
            this.isShow = this.spinner===false && this.firstTime;

            const totalRows = data.total>2000?2000:data.total;
                      
            
            this.tableColumn = data.ltngTabWrap.tableColumn;   
            this.setParentFieldColumn(this.tableColumn,this.fields,data.ltngTabWrap.tableRecord);
            this.totalPage = Math.ceil(totalRows/this.pagesize);
            this.totalRows = totalRows;
            this.isMoreThan2000 = data.total>2000?true:false;
            this.lastind = parseInt(data.offst+this.pagesize,10);                              
            
            if(data.total<this.lastind){
                this.lastind=data.total;
            }
            if(this.totalRows>15){
                this.showpagination = true;
            }
            this.showPageView = 'Showing: '+parseInt(data.offst+1,10)+'-'+this.lastind;

            this.generatePageListUtil();
            
            if(totalRows===0){
                this.error = 'No record found';
                this.tableData=undefined;
                this.pageList = undefined;
                //this.showSpinner = false;
            }
            else{
                this.error = undefined;
                this.showTable=true;
                //this.showSpinner = false;
            }  
            this.showSpinner = false;
        })
        .catch(error=>{
            this.tableData=undefined;
            this.error = error;
            handleErrors(this,error);
            this.showSpinner = false;
        });        
    }
    
    handleFilterChange(){
        const condition = this.buildCondition();
        window.clearTimeout(this.delayTimeout);
        
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(()=>{
            this.offst = 0;
            this.currentPageNo = 1;
            this.hasNext = false;
            this.hasPrev = false;
            this.tempCondition = condition;
            this.getData();
        },DELAY)
    }
    handleMultipicklistChange(event){
        
        window.clearTimeout(this.delayTimeout);
        const selectedOptions = event.target.selectedOptions;
        const filterName = event.target.filterName;        
        
        if(filterName==='3'){
            this.filterField3Value = selectedOptions;
        }
        if(filterName==='2'){
            this.filterField2Value = selectedOptions;
        }
        if(filterName==='1'){
            this.filterField1Value = selectedOptions;
        }
        const condition = this.buildCondition();
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(()=>{
            this.offst = 0;
            this.currentPageNo = 1;
            this.hasNext = false;
            this.hasPrev = false;
            this.tempCondition = condition;
            this.getData();
        },DELAY)
        
    }
    setParentFieldValue(tbldatas){ 
        let datas = JSON.parse(JSON.stringify(tbldatas));

        for(let i=0;i<datas.length;i++){
            datas[i].showUpdated = false;
            datas[i].RecordId = 'a'+datas[i].Id;
            //build link
            if(datas[i].hasOwnProperty('Name')){
                datas[i].NameLink='/lightning/r/'+this.objectName+'/'+datas[i].Id+'/view';
            }
            if(datas[i].LastModifiedBy.Id && datas[i].LastModifiedDate && userId !== datas[i].LastModifiedBy.Id && datas[i].LastModifiedBy.ContactId)
            {
                datas[i].showUpdated = true;
                this.showUpdatedHeading = true;
                datas[i].updatedBy = datas[i].LastModifiedBy.Name;
                datas[i].updatedDate = datas[i].LastModifiedDate;
            }

            if(typeof datas[i] === 'object'){
                // Parent table data
                // eslint-disable-next-line guard-for-in                
                for (let k in datas[i]) {                    
                    if (datas[i].hasOwnProperty(k) && typeof datas[i][k] === 'object'){                        
                        Object.keys(datas[i][k]).forEach(item=>{
                            datas[i][k+''+item] = datas[i][k][item];
                            if(item.toLowerCase()==='name'){
                                datas[i][k+'NameLink']='/lightning/r/'+k+'/'+datas[i][k].Id+'/view';
                            }
                        });

                        //three level data                        
                        for (let j in datas[i][k]) {
                            if (datas[i][k].hasOwnProperty(j) && typeof datas[i][k][j] === 'object'){
                                Object.keys(datas[i][k][j]).forEach(item=>{                                    
                                    if(typeof datas[i][k][j][item] !== 'object'){
                                        datas[i][k+''+j+''+item] = datas[i][k][j][item];
                                        if(item.toLowerCase()==='name'){
                                            datas[i][k+''+j+''+item+'Link'] = '/lightning/r/'+j+'/'+datas[i][k][j].Id+'/view';
                                        }
                                    }
                                    else{
                                        Object.keys(datas[i][k][j][item]).forEach(item2=>{
                                            datas[i][k+''+j+''+item+''+item2] = datas[i][k][j][item][item2];
                                            if(item2.toLowerCase()==='name'){
                                                datas[i][k+''+j+''+item+''+item2+'Link'] = '/lightning/r/'+item+'/'+datas[i][k][j][item].Id+'/view';
                                            }
                                        });
                                    }
                                });
                            }
                        }
                    
                    }
                }
            }
        }
        this.tableData = datas;        
    }

    setParentFieldColumn(columnObj,columnList,datas){
        columnObj = JSON.parse(JSON.stringify(columnObj));
        columnList = JSON.parse(JSON.stringify(columnList));
        if(columnList.indexOf('.')>0){
            let col = columnList.split(',');
            for(let i=0;i
		<col.length;i++){
                let test = col[i].split('.');
                let label = this.fieldsLabel.split(',')[i];                
                if(col[i].indexOf('.')>0 && test.length===2){
                    columnObj.splice(i,0,{fieldName: col[i],label:label});
                }
                if(col[i].indexOf('.')>0 && test.length===3){
                    columnObj.splice(i,0,{fieldName: col[i],label:label});
                }
            }
        }
        if(this.isViewFile==='true'){
            columnObj.splice(0, 0, 
                {
                    type: "button-icon",                    
                    typeAttributes: {
                        iconName: 'utility:preview',                        
                        name: 'viewfile',
                        title: 'View File',
                        variant:'bare',
                        disabled: false,
                        value: {fieldName: 'Id'}
                    }
                }
            );
        }
       

        for(let i=0;i
			<columnObj.length;i++){
            //format date field
            if(columnObj[i].type==='textarea' || columnObj[i].type==='button-icon' || columnObj[i].type==='multipicklist'){
                columnObj[i].sortable=false;
            }
            else{
                columnObj[i].sortable=true;
            }
            
            if(columnObj[i].type==='datetime'){
                columnObj[i].type='date';
                columnObj[i].typeAttributes= {day: 'numeric',month: 'short',year: 'numeric',hour: '2-digit',minute: '2-digit',second: '2-digit',hour12: true}
            }
            //format date field
            if(columnObj[i].type==='date'){                
                columnObj[i].typeAttributes= {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric'
                }
            }

            if(columnObj[i].type==='currency'){
                columnObj[i].cellAttributes = { alignment: 'left' };
            }
            if(columnObj[i].fieldName!==undefined && columnObj[i].fieldName.toLowerCase().indexOf('name')>=0){
                if(columnObj[i].fieldName.toLowerCase()!=='stagename'){
                    columnObj[i].type='url';
                    columnObj[i].typeAttributes = {label: {fieldName:columnObj[i].fieldName},tooltip:'Open in new tab', target: '_blank'};
                    columnObj[i].fieldName=columnObj[i].fieldName+'Link';
                }
            }
        }
        if(this.isShowAction==='true'){
            let actions = [
                { label: 'Edit',title: 'Click to Edit', name: 'edit',iconName: 'utility:edit'}
            ];
            if(this.profile==='System Administrator'||this.profile==='GE System Administrator'||this.profile==='GE BA Administrator'){
                actions.push({ label: 'Delete',title: 'Click to Delete', name: 'delete',iconName: 'utility:delete'})
            }

            if(this.profile==='System Administrator'||this.profile==='GE System Administrator'||this.profile==='GE BA Administrator'||this.profile==='SSC Finance-Accounting'){
                columnObj.push({label: 'Action', type: 'action', typeAttributes: { rowActions: actions }});
            }
        }
        this.tableColumn = columnObj;
        this.setParentFieldValue(datas)
    }

    // Table pagination, sorting and page size change actions Start
    getNextData(){   //Table Action 1
        if(this.lastind>=this.totalRows){
            return;
        }
        window.clearTimeout(this.delayTimeout);
        const nextPage = this.currentPageNo+1;
        const offset = (nextPage * this.pagesize)-this.pagesize;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.offst = offset;
            this.currentPageNo = nextPage;
            this.hasNext = true;
            this.hasPrev = false;
            this.highLightNumber(nextPage);
            this.getData();
        },DELAY);
    }

    getPrevData(){  //Table Action 2
        if(this.currentPageNo===1){return;}
        //this.spinner = true;
        window.clearTimeout(this.delayTimeout);
        const prevPage = this.currentPageNo-1;
        const offset = (prevPage * this.pagesize)-this.pagesize;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.offst = offset;
            this.currentPageNo = prevPage;
            this.hasNext = false;
            this.hasPrev = true;
            this.highLightNumber(prevPage);
            this.getData();
        },DELAY);
    }
    onPageSizeChange(event){
        //this.spinner = true;
        window.clearTimeout(this.delayTimeout);
        
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.offst = 0;
            this.currentPageNo = 1;
            this.hasNext = false;
            this.hasPrev = false;
            this.pagesize = parseInt(event.detail.value,10);
            this.highLightNumber(1);
            this.getData();
        },DELAY);
    }
    searchData(){        
        //this.spinner = true;
        const searchValue = this.template.querySelector(".search-box").value;
        if(searchValue.length>2 || searchValue.length===0){
            window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.offst = 0;
            this.currentPageNo = 1;
            this.hasNext = false;
            this.hasPrev = false;   
            this.searchValue = searchValue;
            this.highLightNumber(1);
            this.getData();
        },DELAY);
        }
        
    }

    handleSorting(event){
        let prevSortDir = this.sortType;
        let prevSortedBy = this.sortByName;
        const newSortedBy = event.currentTarget.id.split('-')[0];
        let iconName = 'utility:arrowup';
        let sortFieldName = newSortedBy;
        
        this.sortByFieldName = sortFieldName;
        if(sortFieldName.toLowerCase().indexOf('namelink')>=0 || sortFieldName.toLowerCase().indexOf('name__clink')>=0){
            const n = sortFieldName.lastIndexOf('Link');
            sortFieldName = sortFieldName.slice(0, n) + sortFieldName.slice(n).replace('Link', '').trim();
        }
        
        this.sortByName = sortFieldName;

        if(sortFieldName===prevSortedBy && prevSortDir==='asc'){            
            this.sortDirection = 'desc';
            this.sortType = 'desc';
            iconName = 'utility:arrowdown';
        }
        else if(sortFieldName===prevSortedBy && prevSortDir==='desc'){
            this.sortDirection = 'asc';
            this.sortType = 'asc';
            iconName = 'utility:arrowup';
        }
        else if(sortFieldName!==prevSortedBy){
            this.sortDirection = 'asc';
            this.sortType = 'asc';
            iconName = 'utility:arrowup';
        }
        window.clearTimeout(this.delayTimeout);
        //this.currentPageNo = 1;
        const ele = event.currentTarget;
        this.resetColumnClass();
        window.jQuery(ele).parent().addClass('slds-has-focus');
        event.currentTarget.querySelector('lightning-icon').iconName = iconName;        
        

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(()=>{
            this.currentPageNo = 1;
            this.offst = 0;            
            this.hasNext = false;
            this.hasPrev = false;
            
            this.highLightNumber(1);
            this.getData();
        },DELAY);
    }
    resetColumnClass(){
        const els = this.template.querySelectorAll(".slds-is-sortable");
        els.forEach((item)=>{
            window.jQuery(item).removeClass('slds-has-focus');
            item.querySelector('lightning-icon').iconName = 'utility:arrowup';
            item.querySelector('lightning-icon').style = 'fill:rgb(0, 112, 210)';
        });
    }

    processMe(event){ //Table Action 3
       
        window.clearTimeout(this.delayTimeout);
        let currentPageNumber = this.currentPageNo;
        let selectedPage = parseInt(event.target.name,10);        
        let pagesize = this.pagesize;        
        let next = selectedPage < currentPageNumber?false:true;
        let prev = selectedPage < currentPageNumber?true:false;
        const offset=(selectedPage*pagesize)-pagesize;
        
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.offst = offset;
            this.currentPageNo = selectedPage;
            this.hasNext = next;
            this.hasPrev = prev;
            this.highLightNumber(selectedPage);
            this.getData();
        },DELAY);
    }

    highLightNumber(pageNumber){ //Util method 1
        //reset 
        try{
            this.pageList.forEach(element => {
                if(this.template.querySelector('span[id*="'+element+'-"]')!==null && this.template.querySelector('span[id*="'+element+'-"]').firstChild!==null){
                    this.template.querySelector('span[id*="'+element+'-"]').firstChild.classList.remove('selected');    
                }
            });
            if(this.template.querySelector('span[id*="'+pageNumber+'-"]')!==null && this.template.querySelector('span[id*="'+pageNumber+'-"]').firstChild!==null){
                this.template.querySelector('span[id*="'+pageNumber+'-"]').firstChild.classList.add('selected');
            }
            
            
            if(pageNumber===1){
                if(this.template.querySelector(".prev-btn")!==null && this.template.querySelector(".prev-btn").firstChild!==null){
                    this.template.querySelector(".prev-btn").firstChild.setAttribute("disabled",true);
                }
            }
            if(pageNumber>=this.totalPage){
                if(this.template.querySelector(".next-btn")!==null && this.template.querySelector(".next-btn").firstChild!==null){
                    this.template.querySelector(".next-btn").firstChild.setAttribute("disabled",true);
                }
            }
        }
        catch(e){
            console.error(e);
        }
    }

    generatePageListUtil(){  // Util Method 2
        const pageNumber = this.currentPageNo;        
        const pageList = [];
        const totalPages = this.totalPage;

        if(totalPages > 1){
            if(totalPages <= 10){                
                for(let counter = 2; counter < (totalPages); counter++){
                    pageList.push(counter);
                } 
            } else{
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else{
                    if(pageNumber>(totalPages-5)){
                        pageList.push(totalPages-5, totalPages-4, totalPages-3, totalPages-2, totalPages-1);
                    } else{
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        }
        this.pageList = pageList;
    }

    handlePagesize(event){ //Table Action 4
        const pagesize = parseInt(event.target.value,10);        
        this.currentPageNo=1;
        window.clearTimeout(this.delayTimeout);
        const offset   = (this.currentPageNo*pagesize)-pagesize;

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(()=>{            
            this.pagesize = pagesize;
            this.offst = offset;            
            this.getData();
        },DELAY);
    }
    // Table pagination, sorting and page size change actions END

    

    get ownerOptions(){
       return [{'label':'My '+this.objectLabel,'value':userId},{'label':'All '+this.objectLabel,'value':''}];
    }
    get pagesizeList(){
        return [
            {'label':'15','value':'15'},
            {'label':'20','value':'20'},
             {'label':'30','value':'30'},
             {'label':'50','value':'50'}
        ];
    }
    get firstActiveClass(){
        return this.currentPageNo===1?'selected':'';
    }
    get lastActiveClass(){
        return this.currentPageNo===this.totalPage?'selected':'';
    }    

   
    buildCondition(){
        let condition = this.condition;

        //Only for Owner filter
        if(this.isFilterByOwner==='true'){
            this.selectedOwner = this.template.querySelector(".ownerfilter")?this.template.querySelector(".ownerfilter").value:userId;
            if(this.selectedOwner===''){
                return condition;   
            }
            return condition+' AND (OwnerId=\''+this.selectedOwner+'\')';
        }
        
        if(this.template.querySelector(".filter1")!==undefined && this.template.querySelector(".filter1")!==null){
            this.filterField1Value = this.template.querySelector(".filter1").value;
        }
        
        if(this.template.querySelector(".filter2")!==undefined && this.template.querySelector(".filter2")!==null){
            this.filterField2Value = this.template.querySelector(".filter2").value;
        }

        if(this.template.querySelector(".filter3")!==undefined && this.template.querySelector(".filter3")!==null){
            this.filterField3Value = this.template.querySelector(".filter3").value;
        }

        const selectedValue1 = this.filterField1Value?this.filterField1Value:'';
        const selectedValue2 = this.filterField2Value?this.filterField2Value:'';
        const selectedValue3 = this.filterField3Value?this.filterField3Value:'';

        let customCond = '';
        if(selectedValue1!=='' && selectedValue2!=='' && selectedValue3!=='')
        {            
            customCond = customCond + ' AND ('+this.filterField1+' IN (\''+selectedValue1+'\') ';
            customCond = customCond + ' OR '+this.filterField2+' IN (\''+selectedValue2+'\') ';
            customCond = customCond + ' OR '+this.filterField3+' IN (\''+selectedValue3+'\')) ';
        }
        else if(selectedValue1!=='' && selectedValue2!=='' && selectedValue3===''){
            customCond = customCond + ' AND ('+this.filterField1+' IN (\''+selectedValue1+'\') ';
            customCond = customCond + ' OR '+this.filterField2+' IN (\''+selectedValue2+'\')) ';
        }
        else if(selectedValue1!=='' && selectedValue2==='' && selectedValue3!==''){
            customCond = customCond + ' AND ('+this.filterField1+' IN (\''+selectedValue1+'\') ';
            customCond = customCond + ' OR '+this.filterField3+' IN (\''+selectedValue3+'\')) ';
        }
        else if(selectedValue1==='' && selectedValue2!=='' && selectedValue3!==''){
            customCond = customCond + ' AND ('+this.filterField2+' IN (\''+selectedValue2+'\') ';
            customCond = customCond + ' OR '+this.filterField3+' IN (\''+selectedValue3+'\')) ';
        }
        else if(selectedValue1!==''){
            customCond = customCond + ' AND ('+this.filterField1+' IN (\''+selectedValue1+'\')) ';
        }
        else if(selectedValue2!==''){
            customCond = customCond + ' AND ('+this.filterField2+' IN (\''+selectedValue2+'\')) ';
        }
        else if(selectedValue3!==''){
            customCond = customCond + ' AND ('+this.filterField3+' IN (\''+selectedValue3+'\')) ';
        }
        customCond = customCond.replace(/NULL/g,'');
        //alert(condition+customCond)
        return condition+customCond;
    }

    get isTrue(){
        return this.spinner && !this.firstTime;        
    }
    get showNewButton(){
        return this.isSupportNewRecord==='true'?true:false;
    }
    openFile(parentId){        
        if(parentId){
            this.spinner = true;
            getFileDetail({objectName:'Attachment',fields:'Id',parentId:parentId})
            .then(result=>{
                this.spinner = false;
                if(Array.isArray(result) && result.length>0){
                    let win = window.open("https://"+window.location.host+"/CustomerCenter/servlet/servlet.FileDownload?file="+result[0].Id,'_blank');                    
                    win.focus();
                }
                else{
                    showToast(this,'No file found','error','Error');
                }
            })
            .catch(error=>{
                this.spinner = false;
                console.error(error);
                handleErrors(this,error);
            })
        }
    }
    @api
    refreshTable(){
        this.getData();        
    }

    toggleDetail(event){
        try
        {
            if(event.target.iconName ==='utility:chevronright'){
                event.target.iconName = "utility:chevrondown";
            }
            else{
                event.target.iconName = "utility:chevronright";
            }

            const ele = this.template.querySelector("[id^="+event.target.value+"-]");
            window.jQuery(ele).css({width:window.jQuery(ele).parent().width()});
            window.jQuery(ele).find('td').css({width:window.jQuery(ele).parent().width()});
            window.jQuery(ele).slideToggle();
        }
        catch(e){
            console.error(e); 
        }
    }
    get buttonColor(){
        return 'background-color:'+ this.eventDtls.Button_colors__c+ ';color:'+this.eventDtls.Button_Text_Color__c;
    }
}