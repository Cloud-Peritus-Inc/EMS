trigger Sales_LeadTrigger on CP_Sales_lead__c (before insert,before update,after update,after insert) {
    //sales custamisation...
           
     If(System.isBatch()==false)
    {
        
        If (Trigger.isAfter && Trigger.isUpdate && (CustomLeadUpdateHandler.isLeadTriggerExecuted == false || Test.isRunningTest()))
      {
        LeadHandler.updateStandardHandler(Trigger.New);
       }
         If (Trigger.isAfter && Trigger.isInsert )
       {
        
         If(!StandardLeadContactHandler.firstTime)
        {
        StandardLeadContactHandler.firstTime=true;
       
        LeadHandler.insertCustomHandler(Trigger.New);
         }
      }
  }


}