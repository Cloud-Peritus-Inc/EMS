trigger CampaignMemberTrigger on CampaignMember (before insert,before update,after update,after insert)
{  //sales custamisation...
    If(Trigger.isAfter && Trigger.isInsert && (LeadHandler.isCustomLeadExcecution == false || Test.isRunningTest() ))
    {
        StandardLeadContactHandler.insertLead(Trigger.New);

    }
      If(Trigger.isAfter && Trigger.isInsert && (CustomContactHandler.isCustomContactExcecution == false || Test.isRunningTest() ))
    {
        StandardLeadContactHandler.insertContact(Trigger.New);

    }
   
}