trigger EMS_RM_Vacanciesdecrease on Contact (before insert, before update, after insert,after update) {
   
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        //EMS_TM_UpdateContactEmail.updatecontactEmail(Trigger.new); // Revamped by Eswar and Shireesha
    }
    
    if(trigger.isBefore && trigger.isUpdate){
        //EMS_TM_UpdateContactEmail.sendWelcomeMailtoEmployee(trigger.new,trigger.oldmap);  These are commented earliar itself.
        //EMS_EM_aplicantConvertResource.sendTheWelcomeMailtoEmployee(trigger.new,trigger.oldmap); These are commented earliar itself.

    }
    
    if(trigger.isAfter && trigger.isInsert){
      //  EMS_TM_UpdateContactEmail.updateAnnualLeave(Trigger.new); // Revamped by Eswar and Shireesha
    }

    
    /*List <Contact> sponsToInsert = new List <Contact>();
        map<string,contact> contactids = new map<string,contact>();
        set< string> mailids = new set<string>();
        RecordType contactrecordId=[SELECT Id, Name, IsActive, SobjectType FROM RecordType where Name= 'Applicant'];
        for (Contact o : Trigger.new) {
        Contact oldOpp = Trigger.oldMap.get(o.Id);
        if(oldOpp.EMS_RM_ApplicantStatus_Update__c != 'Hired' && o.EMS_RM_ApplicantStatus_Update__c=='Hired'){
        contactids.put(o.EMS_RM_CheckUserMail__c,o); 
         mailids.add(o.EMS_RM_CheckUserMail__c);
        }
        }
        //system.debug(contactids);
        // system.debug('size of the set'+contactids.size());
        for(EMS_RM_Job_Application__c jobapp :[SELECT Id, Job_Opening_del__c,Job_Opening_del__r.EMS_Vacant_Positions__c from EMS_RM_Job_Application__c WHERE
        EMS_RM_CheckUserMail__c=:contactids.keyset()]){*/             
                                                                               
   /* if(trigger.isbefore && trigger.isInsert){
        list<contact> conlist = new list<contact>();
        for(Contact con : Trigger.new){
           con.EMS_LM_No_Of_Leaves_Credit__c = LeaveBalanceCalculator.calculateLeaveBalance(con.EMS_EM_JD__c);
            conlist.add(con);
        }
        
        
    }*/
    
}