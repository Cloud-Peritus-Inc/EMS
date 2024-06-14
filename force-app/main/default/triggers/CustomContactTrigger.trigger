trigger CustomContactTrigger on CP_Sales_Contact__c (before insert,before update,after update,after insert) {
    //sales custamisation...    If(System.isBatch()==false)
     
    
     
                  
       If(System.isBatch()==false)
               {      
                If (Trigger.isAfter && Trigger.isUpdate )
             {
                   CustomContactHandler.updateStadContactFromCustom(Trigger.new);
             }
        
    
                If (Trigger.isAfter && Trigger.isInsert )
             {
                  If(!StandardLeadContactHandler.firstTime)
              { 
                  StandardLeadContactHandler.firstTime=true;
                 CustomContactHandler.insertStadContact(Trigger.new);
              }
             }

       
   }
}