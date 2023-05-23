public class ResourceriseToHR  implements TriggerAction.AfterInsert{
        
        /**
    * @author Naga
    * @date 2/22/2023
    * @description Before Insert 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
        public void AfterInsert(list<Resource_Request__c> Resource){      
            // System.debug(LoggingLevel.DEBUG, 'restrictSameDateLeaves.beforeInsert() : BEGIN');
            SendmailToHr(Resource);
            SendmailToTA(Resource);
            //System.debug(LoggingLevel.DEBUG, 'restrictSameDateLeaves.beforeInsert() : END');       
        }
        
        public static  void SendmailToHr(list<Resource_Request__c> Resource){
            for(Resource_Request__c req:Resource){
                List<Messaging.SingleEmailMessage> mailsList =  new List<Messaging.SingleEmailMessage>(); 
                EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                              where name ='Resource_Request_Email _HRTeam' LIMIT 1];
                system.debug('emailTemplate  ----------------------------------------------------'+emailTemplate);
                String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
                List<string> emailList = new List<string>();
                Employee_Details__mdt mc = Employee_Details__mdt.getInstance('HR_Team');
                system.debug('mc=================>'+mc);
                emaillist.add(mc.email__c);
                
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = emailList;
                message.setTemplateID(emailTemplate.Id);
                message.setTreatTargetObjectAsRecipient(false);
                message.setOrgWideEmailAddressId(fromEmail);
                message.whatid=req.Id;
                message.setTargetObjectId(req.Requested_By__c);
                message.setSaveAsActivity(false);
                mailsList.add(message);
                Messaging.sendEmail(mailsList);  
            }
        }
            
 public static  void SendmailToTA(list<Resource_Request__c> Resourcelist){
     
                for(Resource_Request__c req2:Resourcelist){
                    List<Messaging.SingleEmailMessage> mailsList =  new List<Messaging.SingleEmailMessage>(); 
                    EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                                  where name ='Resource_Request_Email _TATeam' LIMIT 1];
                    system.debug('emailTemplate  ----------------------------------------------------'+emailTemplate);
                    String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
                    List<string> emailList = new List<string>();
                    Employee_Details__mdt mc = Employee_Details__mdt.getInstance('TA_Team');
                    system.debug('mc=================>'+mc);
                    emaillist.add(mc.email__c);
                    
                    
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = emailList;
                    message.setTemplateID(emailTemplate.Id);
                    message.setTreatTargetObjectAsRecipient(false);
                    message.setOrgWideEmailAddressId(fromEmail);
                    message.whatid=req2.Id;
                    message.setTargetObjectId(req2.Requested_By__c);
                    message.setSaveAsActivity(false);
                    mailsList.add(message);
                    Messaging.sendEmail(mailsList);  
                }
                
            }



}