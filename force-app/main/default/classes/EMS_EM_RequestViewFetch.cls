public class EMS_EM_RequestViewFetch {
    @AuraEnabled(cacheable=true)
    public static EMS_EM_Request__c getUserContactInfo(ID reqrecordId){
        //  id userid = userinfo.getUserId();
        System.debug('inside apex' + reqrecordId);
        
        EMS_EM_Request__c contactDetails =[SELECT id, EMS_EM_Employee_Name__c, Contact__c, EMS_EM_Request_Type__c, What_do_you_want_to_change__c, 
                                           EMS_EM_Add_Education__c, EMS_EM_Mstatus_Old__c, EMS_EM_Mstatus__c from EMS_EM_Request__c where id =: reqrecordId];
        
        return contactDetails;
        
    }
}