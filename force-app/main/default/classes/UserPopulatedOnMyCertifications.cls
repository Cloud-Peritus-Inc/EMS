/**
* @author Lokesh Onkolu
* @date 08/21/2023
* @description If contact is not pupulated during certification creation, the user will populate the contact field.
*
*               Test code coverage provided by the following test class: 
*               - UserPopulatedOnMyCertificationsTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class UserPopulatedOnMyCertifications implements TriggerAction.BeforeInsert {
 public void beforeInsert(List<Certifications__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'UserPopulatedOnMyCertifications.beforeInsert() : BEGIN');
        userPopulatedOnMyCertificationsMethod(newList);
        System.debug(LoggingLevel.DEBUG, 'UserPopulatedOnMyCertifications.beforeInsert() : END');       
    }
  public void userPopulatedOnMyCertificationsMethod(List<Certifications__c> newlist) {
      system.debug('the new listchecking'+newlist);
     User usVar=[SELECT Id,Name,contactId,Email FROM User WHERE Id=:LeaveRequestConstant.LOGGEDIN_USERID LIMIT 1];
      system.debug('the user details checking checking'+usVar);
              for(Certifications__c cerVar:newlist){
			     if(cerVar.Contact__c == null){
			       cerVar.Contact__c=usVar.contactId;
				 }
			  }
			 
}
}