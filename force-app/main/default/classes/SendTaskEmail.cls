/*
 * File         :   SendTaskEmail
 * Project      :   IM GE
 * Created Date :   14th Oct 2022
 * Created By   :   Girikon(Palla Kishore)
 * Test Class   :   SendTaskEmail_Test (100%)
 * ***************************************************************************
 * @description : To send Task assigned email to all the queue members (UK SSC, Egypt SSC)
 */

public without sharing class SendTaskEmail {
    
    @InvocableMethod
    public static void sendEmail(List<SObject> sObjectList) {
        List<Task> taskList = (List<Task>)sObjectList;
        Map<Id, Id> taskIdToQueueMap = new Map<Id,Id>();
        Map<Id, List<Id>> userToQueuesMap = new Map<Id, List<Id>>();
        Map<Id, List<String>> queueToUserEmailMap = new Map<Id, List<String>>();
        Map<Id, Task> taskMap = new Map<Id, Task>();
        Set<Id> oppIds = new Set<Id>();
        for (Task task : taskList) {
            taskIdToQueueMap.put(task.Id, task.OwnerId);
            taskMap.put(task.Id, task);
            oppIds.add(task.WhatId);
        }
        for (GroupMember member : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE Group.Type = 'Queue' AND GroupId IN: taskIdToQueueMap.values()]) {
            if (String.valueOf(member.UserOrGroupId).startsWith('005')) {
                if (userToQueuesMap.containsKey(member.UserOrGroupId)) {
                    List<Id> queueIdList = userToQueuesMap.get(member.UserOrGroupId);
                    queueIdList.add(member.GroupId);
                    userToQueuesMap.put(member.UserOrGroupId, queueIdList);
                } else {
                    userToQueuesMap.put(member.UserOrGroupId, new List<Id>{member.GroupId});
                }
            }
        }
        system.debug('userToQueuesMap ==> ' + userToQueuesMap);
        for (User u : [SELECT Id, Email FROM User WHERE Id IN: userToQueuesMap.keySet()]) {
            List<Id> queueList = userToQueuesMap.get(u.Id);
            for (Id qId : queueList) {
                if (queueToUserEmailMap.containsKey(qId)) {
                    List<String> userEmailList = queueToUserEmailMap.get(qId);
                    userEmailList.add(u.Email);
                    queueToUserEmailMap.put(qId, userEmailList);
                } else {
                    queueToUserEmailMap.put(qId, new List<String>{u.Email});
                }
            }
        }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE DeveloperName =: System.label.Task_Queue_Email LIMIT 1];
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String strSubject = emailTemplate.Subject;
        String strHTMLBody = emailTemplate.HtmlValue;
        if (!queueToUserEmailMap.isEmpty()) {
            Map<Id, Opportunity> oppMap = getOppInformation(oppIds);
            for (Id taskId : taskIdToQueueMap.keySet()) {
                system.debug('sent email');
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String subject = strSubject;
                String htmlBody = strHTMLBody;
                system.debug('taskMap.get(taskId).WhatId ' + taskMap.get(taskId).WhatId);
                email.setWhatId(taskMap.get(taskId).WhatId);
                if (String.isNotBlank(strHTMLBody)) {
                    htmlBody = htmlBody.replace('{!User.Name}', Userinfo.getName());
                    htmlBody = htmlBody.replace('{!Task.Link}', baseURL + '/' + taskId);
                    htmlBody = htmlBody.replace('{!Opportunity.Name}', oppMap.get(taskMap.get(taskId).WhatId).Name);
                }
                email.setSubject(subject);
                email.setHtmlBody(htmlBody);
                email.setToAddresses(queueToUserEmailMap.get(taskIdToQueueMap.get(taskId)));
                emails.add(email);
            }
        }
        system.debug('emails print ==> ' + emails);
        if (!emails.isEmpty()) {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);
        }
    }
    public static Map<Id, Opportunity> getOppInformation(Set<Id> oppIds) {
        return new Map<Id, Opportunity>([SELECT Id, Name FROM Opportunity WHERE Id IN: oppIds]);
    }
}