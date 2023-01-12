public with sharing class EMS_LM_LeaveBalance {

@AuraEnabled(Cacheable=true)
public static contact getLeaveBalance(Id userid){
contact c ;
    if(userid !=null){
        System.debug('userid: '+ userid);
        user u =[Select id,ContactId, Email from User where id =: userid];
        System.debug('u: '+ u);
    if(u.ContactId !=null){
        c = [Select id,name,EMS_LM_No_Of_Available_Maternity_Leave__c, EMS_LM_No_Of_Available_Paternity_Leave__c,
                EMS_LM_No_Of_Utilized_Maternity_Leaves__c, No_Of_Utilized_Paternity_Leaves__c,
                EMS_LM_No_Of_Availble_Leaves__c,EMS_LM_No_Of_Utilized_Leaves__c,
                EMS_LM_No_Of_Available_Bereavement_Leave__c,EMS_LM_No_Of_Utilized_Bereavement_Leaves__c,
                EMS_LM_No_Of_Available_Compensatory_Off__c,EMS_LM_No_OF_Utilized_Compensatory_Off__c,
                EMS_LM_No_Of_Utilized_Loss_Of_Pay__c
                from Contact where id =:u.ContactId];
        System.debug('c: '+ c);
        }
        if(u.ContactId == null){
            c = [Select id,name,EMS_LM_No_Of_Available_Maternity_Leave__c, EMS_LM_No_Of_Available_Paternity_Leave__c,
                EMS_LM_No_Of_Utilized_Maternity_Leaves__c, No_Of_Utilized_Paternity_Leaves__c,
                EMS_LM_No_Of_Availble_Leaves__c,EMS_LM_No_Of_Utilized_Leaves__c,
                EMS_LM_No_Of_Available_Bereavement_Leave__c,EMS_LM_No_Of_Utilized_Bereavement_Leaves__c,
                EMS_LM_No_Of_Available_Compensatory_Off__c,EMS_LM_No_OF_Utilized_Compensatory_Off__c,
                EMS_LM_No_Of_Utilized_Loss_Of_Pay__c
                from Contact  where Official_Mail__c=:u.Email AND EMS_TM_User__c = :userId Limit 1];
        System.debug('c: '+ c);
         }
    }
return c;
}

}