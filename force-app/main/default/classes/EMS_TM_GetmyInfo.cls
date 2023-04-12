public class EMS_TM_GetmyInfo {
        @AuraEnabled(cacheable=true)
public static contact getUserContactInfo(Id userId){
    //  id userid = userinfo.getUserId();
   // System.debug(userId+'uuuseerrid');
    user u =[Select id,name,Contactid from user where id =: userId  AND Contactid != null];
    System.debug('userid'+U);
    contact contactDetails =[SELECT  LastName, FirstName, Name, EMS_RM_Industry__c, EMS_RM_Employee_Id__c,
                                                EMS_RM_Domain_Technology__c,EMS_Domain_Technology__c, EMS_RM_Current_Job_Role__c,
                                            EMS_Phone_Number__c,EMS_RM_Resource_Email_id__c  FROM Contact where id =: u.contactid];

      return contactDetails;

}

}