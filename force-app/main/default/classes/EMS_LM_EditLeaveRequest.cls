/**
* @author Sangharsh Kamble
* @date 24/01/2023
* @description Class for get leave request record to edit record.
*
*               Test code coverage provided by the following test class: 
*               - EMS_LM_ContactLeaveUpdate_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class EMS_LM_EditLeaveRequest {
	
    // This method is used to get the Leave types of Leve Credit records of of particular loggedin Employee
   @AuraEnabled(Cacheable=true)
   public static List<String> getLeaveType(Id userid) {
   List<String> s = new List<String>();
   if(userid !=null){
      user u =[Select id, ContactId, Email from user where id =: userid];
      try{         
   if(u.ContactId !=null){ // if contact Id is not null we will retrieve the data using User contact Id
   set<String> i = new set<String>();
   List<EMS_LM_Leave_Credit__c> i1 = new List<EMS_LM_Leave_Credit__c>();
   i1 = [SELECT EMS_LM_Select_Leave_Type__c
               FROM EMS_LM_Leave_Credit__c
               WHERE EMS_LM_Employee__c = :u.ContactId ORDER BY EMS_LM_Select_Leave_Type__c ASC];
               for(EMS_LM_Leave_Credit__c i2:i1){
                  i.add(i2.EMS_LM_Select_Leave_Type__c);
               }
   for(String s1 : i){
      s.add(s1);
   }
 
   
   }
else{ //if contact Id is null(For Org Users(Like Sys Admin Profiles)) we will retrieve the data using User Email which is mapped to contact as Official Email
   set<String> i = new set<String>();
   List<EMS_LM_Leave_Credit__c> i1 = new List<EMS_LM_Leave_Credit__c>();
   contact c = [Select Id from contact where Official_Mail__c=:u.Email AND EMS_TM_User__c = :userid];
   i1 = [SELECT EMS_LM_Select_Leave_Type__c
               FROM EMS_LM_Leave_Credit__c
               WHERE EMS_LM_Employee__c = :c.Id ORDER BY EMS_LM_Select_Leave_Type__c ASC];
               for(EMS_LM_Leave_Credit__c i2:i1){
                  i.add(i2.EMS_LM_Select_Leave_Type__c);
               }
               for(String s1 : i){
                  s.add(s1);
               }
   /*List<EMS_LM_Leave__c> l = new List<EMS_LM_Leave__c>();
   l = [select Id, EMS_LM_Leave_Type__c from EMS_LM_Leave__C where id IN : i ];
   for(EMS_LM_Leave__c lt : l){
      s.add(lt.EMS_LM_Leave_Type__c);
   }*/
   }   
   }
   catch(Exception e){
      system.debug(e.getMessage());
   }
   }
      return s;

}
    
    
    @AuraEnabled
    public static EMS_LM_Leave_History__c getLeaveRequestMethod( String getrecordId ) {
        if(getrecordId != Null){
      		EMS_LM_Leave_History__c leaverecord = [Select id , EMS_LM_Leave_Start_Date__c , EMS_LM_Leave_End_Date__c , EMS_LM_Leave_Duration__c,
                                                   			EMS_LM_Leave_Type_Name__c , EMS_LM_Reason__c , EMS_LM_Status__c , Name ,EMS_LM_Day__c
                                                 	from EMS_LM_Leave_History__c 
                                                    where Id =: getrecordId];
            return leaverecord;
        }
        else{
                return null;
            }
    }
    
    @AuraEnabled
    public static EMS_LM_Leave_History__c updateleaveRequest(EMS_LM_Leave_History__c newRecord,string recordId) {
       newRecord.id=recordId;
       update newRecord;
       return newRecord;
    }
}