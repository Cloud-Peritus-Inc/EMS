public class CP_AutoFillHrTaMails implements TriggerAction.BeforeInsert{
    
	public void beforeInsert(List<Contact> newList) {      
         System.debug(LoggingLevel.DEBUG, 'CP_AutoFillHrTaMails.beforeInsert() : BEGIN');
         updateEmails(newList);
         System.debug(LoggingLevel.DEBUG, 'CP_AutoFillHrTaMails.beforeInsert() : END');       
     }
    
    private void updateEmails(List<Contact> contactList){
        String hrTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'HR_Team'].Email__c;
        String taTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'TA_Team'].Email__c;        
        for(Contact contactRec : contactList){
            if(hrTeamEmail != NULL){
                contactRec.HR_Email__c = hrTeamEmail;
            }
            if(taTeamEmail != NULL){
                contactRec.TA_Email__c = taTeamEmail;
            }
        }
    }
}