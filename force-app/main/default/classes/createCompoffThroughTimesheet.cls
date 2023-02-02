public without sharing class createCompoffThroughTimesheet {

    @AuraEnabled
    public static EMS_LM_Leave_Credit__c createCompOff(Id userId, Decimal compoffhours,Date compOffweek){
        System.debug('compOffweek'+compOffweek);
      
       Contact contactRec =[SELECT Id,
                                     EMS_TM_User__c 
                                     FROM contact 
                                     WHERE EMS_TM_User__c =: userId];
       List<EMS_LM_Leave_Credit__c> compOffRecord=[Select Id 
                                                    FROM EMS_LM_Leave_Credit__c 
                                                    WHERE EMS_LM_Employee__c =: contactRec.Id 
                                                    AND CompOff_Week__c =:compOffweek ];
   If(compOffRecord.isEmpty()){
  try{
        EMS_LM_Leave_Credit__c comoffRecord = new EMS_LM_Leave_Credit__c();
        comoffRecord.EMS_LM_Select_Leave_Type__c ='Compensatory Off';
        comoffRecord.EMS_LM_Employee__c =contactRec.Id;
        comoffRecord.EMS_LM_Leave_Credited_Date__c= System.today();
        comoffRecord.EMS_LM_Leaves_Credited__c = compoffhours/8;
        comoffRecord.CompOff_Week__c = compOffweek;

        insert comoffRecord;
        return comoffRecord;
  }catch(Exception e){
      String errorOccuredWith = e.getMessage();
     throw new AuraHandledException(errorOccuredWith);

  }
   }else{
       String errorOccuredWith ='You have already Compoff Record in This Week';
     throw new AuraHandledException(errorOccuredWith);

   } 

    }
    @AuraEnabled
     public static Boolean  checkCompOff(Id userId,Date compOffweek){
         date weekStart;
         System.debug('userId'+userId);
        System.debug('compOffweek'+compOffweek);
         if (compOffweek == null){
            Date today = Date.today();
            weekStart = today.toStartofWeek().addDays(1);
         System.debug('weekStart'+weekStart);
         }else{
             weekStart= compOffweek;
             System.debug('else weekStart'+weekStart);
         }
        boolean compOffAlredyExist = false;
       Contact contactRec =[SELECT Id,
                                     EMS_TM_User__c 
                                     FROM contact 
                                     WHERE EMS_TM_User__c =: userId];
       List<EMS_LM_Leave_Credit__c> compOffRecord=[Select Id 
                                                    FROM EMS_LM_Leave_Credit__c 
                                                    WHERE EMS_LM_Employee__c =: contactRec.Id 
                                                    AND CompOff_Week__c =: weekStart];
         System.debug('compOffRecord'+compOffRecord);
         If(!compOffRecord.isEmpty()){
              compOffAlredyExist = True;
             return compOffAlredyExist;
         }else{
             compOffAlredyExist = false;
               return compOffAlredyExist;
         }
     }

}