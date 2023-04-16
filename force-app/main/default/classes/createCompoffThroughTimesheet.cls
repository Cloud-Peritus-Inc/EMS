public without sharing class createCompoffThroughTimesheet {
  /*
    @AuraEnabled
    public static EMS_LM_Leave_Credit__c createCompOff(Id userId, Decimal compoffhours,Date compOffweek){
    EMS_LM_Leave__c leaveType = [SELECT Id FROM EMS_LM_Leave__c where Name ='Compensatory Off' LIMIT 1];
        System.debug('compOffweek'+compOffweek);
      System.debug('userId'+userId);
       Contact contactRec =[SELECT Id,
                                     EMS_TM_User__c 
                                     FROM contact 
                                     WHERE EMS_TM_User__c =: userId];
       List<EMS_LM_Leave_Credit__c> compOffRecordData=[Select Id 
                                                    FROM EMS_LM_Leave_Credit__c 
                                                    WHERE EMS_LM_Employee__c =: contactRec.Id 
                                                    AND CompOff_Week__c =:compOffweek 
                                                    ];
        SYstem.debug('compOffRecordData'+compOffRecordData);
   If(compOffRecordData.isEmpty()){
  try{
        EMS_LM_Leave_Credit__c comoffRecord = new EMS_LM_Leave_Credit__c();
        comoffRecord.EMS_LM_Select_Leave_Type__c ='Compensatory Off';
        comoffRecord.EMS_LM_Employee__c =contactRec.Id;
        comoffRecord.EMS_LM_Leave_Credited_Date__c= System.today();
        comoffRecord.EMS_LM_Leaves_Credited__c = compoffhours/8;
        comoffRecord.CompOff_Week__c = compOffweek;
        comoffRecord.EMS_LM_Leave_Type__c = leaveType.Id;

        insert comoffRecord;
        return comoffRecord;
  }catch(Exception e){
      String errorOccuredWith = e.getMessage();
     throw new AuraHandledException(errorOccuredWith);

  }
   }else{
                  compOffRecordData[0].EMS_LM_Leaves_Credited__c = compoffhours/8;
                  Update compOffRecordData[0];
       return compOffRecordData[0];

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
       List<Contact> contactRec =[SELECT Id,
                                     EMS_TM_User__c 
                                     FROM contact 
                                     WHERE EMS_TM_User__c =: userId];
                                     List<EMS_LM_Leave_Credit__c> compOffRecord;
        if(!contactRec.isEmpty()){         
        compOffRecord=[Select Id 
                                FROM EMS_LM_Leave_Credit__c 
                                WHERE EMS_LM_Employee__c =: contactRec[0].Id 
                                AND CompOff_Week__c =: weekStart];
        }
         System.debug('compOffRecord'+compOffRecord);
         If(!compOffRecord.isEmpty()){
              compOffAlredyExist = True;
             return compOffAlredyExist;
         }else{
             compOffAlredyExist = false;
               return compOffAlredyExist;
         }
     }*/

}