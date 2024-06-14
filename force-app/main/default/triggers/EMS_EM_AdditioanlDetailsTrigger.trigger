trigger EMS_EM_AdditioanlDetailsTrigger on ems_EM_Additional_Detail__c (before insert,before update,after update,after insert)
{
    If(Trigger.isAfter && Trigger.isInsert)
    {
        EMS_EM_Additional_Details_Handler.updateOnboardObjectFromAdditionalDetails(Trigger.New);
    }
    If(Trigger.isAfter && Trigger.isUpdate){
     //eMS_EM_UpdateContentDocumentLink.update_eMS_EM_ContentDocumentLink(Trigger.New);
    }
}