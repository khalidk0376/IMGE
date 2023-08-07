({
  loadData: function(component, event, helper) {
    component.set("v.columnsInactiveMappings", [
      {
        label: "Booth Number",
        fieldName: "Booth_Number__c",
        type: "text",
        sortable: true
      }
    ]);
    component.set("v.columnsActiveMappings", [
      {
        label: "Booth Number",
        fieldName: "Booth_Number__c",
        type: "text",
        sortable: true
      }
    ]);
  },
  moveCCData: function(component, event, helper) {
    helper.moveCCDataUpdate(component, event, helper);
  },
  handleSort: function(component, event, helper) {
    var table = 1;
    var evt = event.getSource();
    var componentId = evt.getLocalId();
    var sortBy = event.getParam("fieldName");
    var sortDirection = event.getParam("sortDirection");
    if (componentId == "tableActive") {
      table = 2;
      component.set("v.sortBy2", sortBy);
      component.set("v.sortDirection2", sortDirection);
    } else {
      component.set("v.sortBy1", sortBy);
      component.set("v.sortDirection1", sortDirection);
    }
    helper.sortData(component, sortBy, sortDirection, table);
  },
  selectRow: function(component, event, helper) {
    var evt = event.getSource();
    var componentId = evt.getLocalId();
    var selectedRows = event.getParam("selectedRows");
    if (selectedRows !== undefined) {
      if (componentId == "tableInactive" && selectedRows.length > 0) {
        component.set("v.selectedInactiveId", selectedRows[0].Id);
      } else if (componentId == "tableActive" && selectedRows.length > 0) {
        component.set("v.selectedActiveId", selectedRows[0].Id);
      } else if(componentId == "tableInactive" && selectedRows.length == 0){
        component.set("v.selectedInactiveId", null);
      } else if(componentId == "tableActive" && selectedRows.length == 0){
        component.set("v.selectedActiveId", null);
      }
    }
  },
  toggleBack: function(component, event) {
    var cmpEvent = component.getEvent("userTypeCCToggle");
    cmpEvent.fire();
  }
});