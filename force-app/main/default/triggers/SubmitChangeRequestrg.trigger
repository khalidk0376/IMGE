trigger SubmitChangeRequestrg on Change_Request__c (After Insert) {
    System.debug('Trigger is start');
    System.enqueueJob(new CalloutActionSubmitChange(Trigger.newMap.keySet()));
}