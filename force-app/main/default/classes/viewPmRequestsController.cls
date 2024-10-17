public without sharing class viewPmRequestsController {
    
    public class viewPMTableWrapper {
        
        @AuraEnabled
        public String mentee{get;set;}
        @AuraEnabled
        public String menteeRole{get;set;}
        @AuraEnabled
        public String project{get;set;}
        @AuraEnabled
        public String projectManager{get;set;}
        @AuraEnabled
        public String kraStatus{get;set;}
        @AuraEnabled
        public string projectConId{get;set;}
         @AuraEnabled
        public String projectManagerId{get;set;}
        @AuraEnabled
        public String projectId{get;set;}
        @AuraEnabled
        public String kraId{get;set;}
        @AuraEnabled
        public boolean hideRecallButton{get;set;}
        @AuraEnabled
        public String recall_Reason{get;set;}
    }
    
    //smaske : PM_Def_174 : Changed this method as imperative from wire method
    @AuraEnabled
    public static List<viewPMTableWrapper> viewPMRequestsTable(String KraId){
        
        Id answerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
        List<PM_Configure__c> pmConfiglist = [Select Id,
                                              name,
                                              Mentee__r.name,
                                              Mentee__r.Resource_Role__r.name,
                                              KRA__r.Resource__r.name,
                                              KRA__r.Resource__r.Resource_Role__r.name,
                                              Mentor__r.name,
                                              Reporting_Contact__r.name,
                                              Reporting_Contact__c,
                                              Status__c,
                                              KRA__c,KRA__r.Resource__c,
                                              Project_Name__r.name,
                                              Recall_FeedBack_Comments__c,
                                              Project_Name__c From PM_Configure__c
                                              where recordtypeId =: answerRecordTypeId and Kra__c =:KraId  and Reporting_Contact__c != null
                                              and Status__c IN('Awaiting Response','Accepted','Rejected','Submitted','Cancelled')];
        system.debug('KraId---'+KraId);
        system.debug('pmConfiglist---'+pmConfiglist.size());

        Map<String, List<PM_Configure__c>> projectPMConfigData = new Map<String, List<PM_Configure__c>>();
         Map<String, Map<String, List<PM_Configure__c>>> managerProjPmAnsRecMap = new Map<String, Map<String, List<PM_Configure__c>>>();
        
          for(PM_Configure__c pm : pmConfiglist){
                if (!projectPMConfigData.containsKey(pm.Project_Name__c)) {
                    projectPMConfigData.put(pm.Project_Name__c, new List<PM_Configure__c>());
                }
                projectPMConfigData.get(pm.Project_Name__c).add(pm);
            }

           for (String projName : projectPMConfigData.keySet()) {
                List<PM_Configure__c> pmConfigRecs = projectPMConfigData.get(projName);
                for (PM_Configure__c pmRec : pmConfigRecs) {
                    if (!managerProjPmAnsRecMap.containsKey(pmRec.Reporting_Contact__c)) {
                        managerProjPmAnsRecMap.put(pmRec.Reporting_Contact__c, new Map<String, List<PM_Configure__c>>());
                    }
                    if (!managerProjPmAnsRecMap.get(pmRec.Reporting_Contact__c).containsKey(projName)) {
                        managerProjPmAnsRecMap.get(pmRec.Reporting_Contact__c).put(projName, new List<PM_Configure__c>());
                    }
                    managerProjPmAnsRecMap.get(pmRec.Reporting_Contact__c).get(projName).add(pmRec);
                }
            }
            system.debug('managerProjPmAnsRecMap-----'+managerProjPmAnsRecMap);        
        
        List<viewPMTableWrapper> updatedPMConfigList = new List<viewPMTableWrapper>();
        
         for (String managerId : managerProjPmAnsRecMap.keySet()) {
            Map<String, List<PM_Configure__c>> projectMap = managerProjPmAnsRecMap.get(managerId);
            for (String projectName : projectMap.keySet()) {
                List<PM_Configure__c> pmConfigRecs = projectMap.get(projectName);
                               
                         viewPMTableWrapper vpt = new viewPMTableWrapper();    
                         vpt.mentee = pmConfigRecs[0].KRA__r.Resource__r.name;
                         vpt.menteeRole = pmConfigRecs[0].KRA__r.Resource__r.Resource_Role__r.name;
                         vpt.project = pmConfigRecs[0].Project_Name__r.name;
                          if(pmConfigRecs[0].Status__c == 'Awaiting Response'){
                         vpt.kraStatus = 'Request Sent';
                         vpt.hideRecallButton = false;
                            }
                        else if(pmConfigRecs[0].Status__c == 'Accepted'){                       
                         vpt.kraStatus = 'Request Accepted';
                         vpt.hideRecallButton = false;
                            }
                       else if(pmConfigRecs[0].Status__c == 'Rejected'){
                         vpt.kraStatus = 'Request Rejected';
                         vpt.hideRecallButton = true;
                            }
                         else if(pmConfigRecs[0].Status__c == 'Submitted'){
                         vpt.kraStatus = 'Feedback Submitted';
                          vpt.hideRecallButton = true;
                            }
                        else if(pmConfigRecs[0].Status__c == 'Cancelled'){
                         vpt.kraStatus = 'Feedback Cancelled';
                         vpt.hideRecallButton = true;
                            }
                      
                         vpt.projectManager =pmConfigRecs[0].Reporting_Contact__r.name;
                         vpt.projectConId = pmConfigRecs[0].Reporting_Contact__r.name +''+pmConfigRecs[0].Project_Name__r.name;
                         vpt.projectManagerId = pmConfigRecs[0].Reporting_Contact__c;
                         vpt.projectId = pmConfigRecs[0].Project_Name__c;
                         vpt.kraId = pmConfigRecs[0].KRA__c;
                         vpt.recall_Reason = pmConfigRecs[0].Recall_FeedBack_Comments__c;

                         updatedPMConfigList.add(vpt);
                    
               
            }
         }

         system.debug('updatedPMConfigList---'+updatedPMConfigList);
         system.debug('updatedPMConfigList---'+updatedPMConfigList.size());
          return updatedPMConfigList;
       
    }

@AuraEnabled
    Public static void recallPmRequests(String KraId,String projectManager,String projectName, string rejectionReason){
       
       List<PM_Configure__c> updatedPmConfiglist = new List<PM_Configure__c>();
      Id answerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();   
       List<PM_Configure__c> pmConfiglist1 = [Select Id,
                                              name,
                                              Mentee__r.name,
                                              Mentee__r.Resource_Role__r.name,
                                              Mentor__r.name,
                                              Reporting_Contact__r.name,
                                              Reporting_Contact__c,Reporting_Contact__r.Email,
                                              Status__c,
                                              KRA__c,KRA__r.Resource__c,
                                              Project_Name__r.name,
                                              Recall_FeedBack_Comments__c,
                                              Project_Name__c From PM_Configure__c
                                              where recordtypeId =: answerRecordTypeId and Kra__c =:KraId  
                                              and Reporting_Contact__c != null                                               
                                              and Reporting_Contact__c =:projectManager
                                              and Project_Name__c =: projectName];
          system.debug('pmConfiglist1------'+pmConfiglist1);
        if(!pmConfiglist1.IsEmpty()){
        for(PM_Configure__c pm : pmConfiglist1){           
           pm.Status__c = 'Cancelled';
           pm.Recall_FeedBack_Comments__c = rejectionReason;
           updatedPmConfiglist.add(pm);
          }
        }
          system.debug('updatedPmConfiglist---'+updatedPmConfiglist);
        if(!updatedPmConfiglist.isEmpty()){
            update updatedPmConfiglist;
            //smaske : Calling email method for sending email
            sendEmailToPmForRecallRecords(updatedPmConfiglist);
        }


      }

      //smaske: 23/Aug/2024 : Created this method send email alerts to Project Managers when Mentor Recalls the send KRA request
      public static void sendEmailToPmForRecallRecords(List<PM_Configure__c> recalledPmConfiglist) {
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply.grid@cloudperitus.com'];
        Id templateIdForNotifyingProjManagerOnRecall = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Notifying_Project_Manager_Other_On_Project_Manager_feedback_Recall'].Id;
        List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        Set<String> toAddresses = new Set<String>();
        for (PM_Configure__c pmConfigRec : recalledPmConfiglist) {           
            toAddresses.add(pmConfigRec.Reporting_Contact__r.Email);
            msg.setTargetObjectId(pmConfigRec.Reporting_Contact__c);
            msg.setWhatId(pmConfigRec.Id);
        }
        msg.setToAddresses(new List<String>(toAddresses));
        msg.setOrgWideEmailAddressId(owea[0].Id); // Make sure 'owea' is properly defined
        msg.setTemplateId(templateIdForNotifyingProjManagerOnRecall); // Make sure 'templateIdForNotifyingProjManager' is properly defined
        msg.setSaveAsActivity(true);
        System.debug('ProjectManager  msg :: ' +  msg );
        emailListToSend.add(msg);

        System.debug('emailListToSend size :: ' +  emailListToSend.size());
        System.debug('emailListToSend :: ' +  emailListToSend.toString() );
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailListToSend);
        for (Messaging.SendEmailResult result : results) {
            if (result.isSuccess()) {
                System.debug('Email sent successfully.');
            } else {
                System.debug('Failed to send email. Error: ' + result.getErrors()[0].getMessage());
            }
        }
      }

     
    
}