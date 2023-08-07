({
	doInit : function(component, event, helper) {	
		helper.getOppDetail(component);
        helper.getUserTypeButtonAccess(component);
	},
	refreshButton:function(component, event, helper) {		
		helper.getOppDetail(component);
	},
	runCancelOppScript:function(component, event, helper) {
		helper.cancelOpps(component);
	},
	sendFloorPlanInfo:function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
	    urlEvent.setParams({
	      "url": "/apex/SendBoothLinkVF?Id="+component.get("v.recordId")
	    });
	    urlEvent.fire();
	},
	openAmendContractLink:function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
	    urlEvent.setParams({
	      "url": "/apex/vf_amendContract?oppId="+component.get("v.recordId")
	    });
	    urlEvent.fire();
	},
	openAttachAggrementLink:function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
	    urlEvent.setParams({
	      "url": "/apex/AttachAggrement?id="+component.get("v.recordId")
	    });
	    urlEvent.fire();
	},
	openResubmitForAccApprovalModal:function(component, event, helper) {
		component.set("v.isResubmitForAccApprovalModal",true);
	},
	closeWonToZeroAmount :function(component, event, helper) {		
		helper.closeWonToZeroAmountHelper(component);
	},
	openNewContactModal : function(component, event, helper) {
		component.set("v.isOpenNewContactModal",true);
	},
	openOppCloneModal: function(component, event, helper) {
		//var delay=2000; //2 seconds
		//setTimeout(function() {
			component.set("v.isOpenOppCloneModal",true);
		//}, delay);		
	},
	openOppRecallModal: function(component, event, helper) {		
        component.set("v.isOpenOppRecallModal",true); 
	},
    openNewQuoteModal : function(component, event, helper) {
		component.set("v.isOpenCreateNewQuoteModal",true);
	},
	openUploadDocModal : function(component, event, helper) {
		component.set("v.isOpenDocModal",true);
	},
	/** Rajesh Kumar - 31-03-2020 : BK- BK-3775 --> */
	openSubmitForChangeModal:function(component, event, helper) {
		component.set("v.isOpenSubmitForChangeModal",true);
	},
    /** Rajesh Kumar - 31-03-2020 : BK- BK-3775 --> */
    openUserTypeUpdateModal:function(component, event, helper) {
		component.set("v.isOpenUpdateUserTypeModal",true);    
	},
    openCancelOppModal:function(component, event, helper) {
    	var accessObj = component.get("v.accessObj");
        if(!accessObj.HasEditAccess){
            window._LtngUtility.toast('Warning','warning','You did not have permission to cancel this opportunity');
            return;
        }
		component.set("v.isOpenCancelOppModal",true);
	},
	closeModal : function(component, event, helper) {
		component.set("v.isResubmitForAccApprovalModal",false);
	},
	reSubmitOpp:function(component, event, helper) {
		//Update two fields
		//StageName = Closed Won
		//Status__c = Pending Accounting Approval
		helper.reSubmitHelper(component);
	},
    /** Palla Kishore - 22-10-2021 : EMEA-24 --> */
    reSubmitToSalesOpp:function(component, event, helper) {
		//Update two fields
		//StageName = Closed Won
		//Status__c = Sales Ops Review - Pending
		helper.reSubmitToSalesOppHelper(component);
        
	},
    
	isCancelOppChange:function(component, event, helper) {
		if(!component.get("v.isOpenCancelOppModal"))
		{
			helper.getOppDetail(component);
		}
	},
    openUploadDocument : function(component, event, helper) {
		component.set("v.isOpenUploadDocument",true);
	}
})