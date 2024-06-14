public without sharing class ContactInformationController {
  @AuraEnabled(Cacheable=true)
    Public static Contact contctInfoMethod(ID userId){
        Contact conDetails=new Contact();
        User usr=[SELECT Id,ContactId FROM User Where Id =: userId];
        if(usr.ContactId != null){
             conDetails=[SELECT Id,EMS_LM_No_Of_Utilized_Leaves__c,EMS_LM_No_Of_Leaves_Credit__c,EMS_LM_No_Of_Availble_Leaves__c,
                               No_of_Avilable_floatLeave_credits__c,UtlizedFloatLeaves__c,EMS_LM_No_Of_Utilized_Loss_Of_Pay__c,No_OF_Utilized_Work_from_Home__c
                               FROM Contact WHERE ID =: usr.ContactId Limit 1];
            
        }
        return conDetails;
    }
}