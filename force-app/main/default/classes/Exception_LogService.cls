/*
 * @group service
 * @description Service class for Exception_Log
 * @author Cloud Peritus Inc
 * @created date (mm/dd/yyyy) 01/09/2023
 * @last modified date
 */
public
without sharing class Exception_LogService {
 public
  static final Integer Count_RETRY_EXCEPTION =
      Integer.valueOf(System.Label.Retry_Exception);
 public
  static Map<Id, Exception_Log__c> mapRecordExceptionLog =
      new Map<Id, Exception_Log__c>();
  /*
   * @description retry an exception log based on the high priority Ownership transfer
   * @param newExceptionLog
   */
 public
  static void retryExceptionBasedOnPriority(
      List<Exception_Log__c> newExceptionLog) {
    List<SObject> records = new List<SObject>();
    Set<Id> successRecordIds = new Set<Id>();
    for (Exception_Log__c exceptionLog : newExceptionLog) {
      if (!exceptionLog.Bypass_Retry_Exception__c &&
          exceptionLog.Priority__c != null &&
          exceptionLog.Priority__c.equals('High') &&
          exceptionLog.Retry_Count__c <= Count_RETRY_EXCEPTION &&
          exceptionLog.Data_Log__c != null) {
        String jsonStr = exceptionLog.Data_Log__c;
        // Code to convert JSON string to SObject
        List<SObject> record =
            (List<SObject>)JSON.deserialize(jsonStr, List<SObject>.Class);
        records.addAll(record);
        for (Sobject rec : record) {
          mapRecordExceptionLog.put(rec.Id, exceptionLog);
        }
      }
    }
    if (records != null && !records.isEmpty()) {
      successRecordIds = dynamicUpsert(records);
    }
          if (successRecordIds != null){
                    updateExceptionLog(successRecordIds, mapRecordExceptionLog);
          }
  }
  /*
   * @description Upserting data dyamically irrespective of Type based
   * @param records
   */
 public
  static Set<Id> dynamicUpsert(List<SObject> records) {
    Set<Id> recordIds = new Set<Id>();
    List<SObject> castRecords = null;
    for (SObject record : records) {
      Schema.SObjectType sObjectType = record.getSObjectType();
      String listType = 'List<' + sObjectType + '>';
      castRecords = (List<SObject>)Type.forName(listType).newInstance();
    }
    for (SObject record : records) {
      castRecords.add(record);
    }
    Database.UpsertResult[] results = Database.upsert(castRecords, false);
    for (Database.upsertResult result : results) {
      if (result.isSuccess()) {
        if (result.isCreated()) {
          recordIds.add(result.id);
        } else {
          recordIds.add(result.id);
        }
      }
    }
    return recordIds;
  }
  /*
   * @description Update flags on exception log object when retry is complete
   * @param records ,mapRecordExceptionLog
   */
 public
  static void updateExceptionLog(
      Set<Id> records, Map<Id, Exception_Log__c> mapRecordExceptionLog) {
    List<Exception_Log__c> updateExceptionLogLst = new List<Exception_Log__c>();
    map<Id, Exception_Log__c> exceptionMap = new map<Id, Exception_Log__c>();
    set<Id> successIds = new set<Id>();
    try {
        for (Id succRecord : records) {
            successIds.add(mapRecordExceptionLog.get(succRecord).Id);
        }
       // clang-format off
        for (Exception_Log__c exceptionRec : [SELECT Id,
                                                   Name,
                                                   Exception_Resolved__c,
                                                   Retry_Count__c,
                                                   Exception_Retry_Complete__c,
                                                   High_Priority_triggered__c
                                              FROM Exception_Log__c
                                              WHERE Id IN :successIds]) {
         // clang-format on
          exceptionRec.Exception_Resolved__c = true;
          if (exceptionRec.Retry_Count__c == null){
                exceptionRec.Retry_Count__c = 0;
                exceptionRec.Retry_Count__c = exceptionRec.Retry_Count__c + 1; 
          }

        if (exceptionRec.Retry_Count__c == Count_RETRY_EXCEPTION) {
          exceptionRec.Exception_Retry_Complete__c = true;
        } else {
          exceptionRec.Exception_Retry_Complete__c = false;
        }
        exceptionRec.High_Priority_triggered__c = true;
        updateExceptionLogLst.add(exceptionRec);
        }
        
     /* for (Id succRecord : records) {
          
        // clang-format off
        Exception_Log__c exceptionLog =
             [SELECT Id,
                  Name,
                  Exception_Resolved__c,
                  Retry_Count__c,
                  Exception_Retry_Complete__c,
                  High_Priority_triggered__c
              FROM Exception_Log__c
              WHERE Id =:mapRecordExceptionLog.get(succRecord).Id ];
        // clang-format on
        exceptionLog.Exception_Resolved__c = true;
          if (exceptionLog.Retry_Count__c == null){
                exceptionLog.Retry_Count__c = 0;
                exceptionLog.Retry_Count__c = exceptionLog.Retry_Count__c + 1; 
          }

        if (exceptionLog.Retry_Count__c == Count_RETRY_EXCEPTION) {
          exceptionLog.Exception_Retry_Complete__c = true;
        } else {
          exceptionLog.Exception_Retry_Complete__c = false;
        }
        exceptionLog.High_Priority_triggered__c = true;
        updateExceptionLogLst.add(exceptionLog);
      }*/
      if (updateExceptionLogLst != null && !updateExceptionLogLst.isEmpty()) {
        exceptionMap.putall(updateExceptionLogLst);
        if (exceptionMap.size() > 0) {
          update exceptionMap.values();
        }
      }
    } catch (Exception ex) {
      LogException.logHandledException(ex, 'Exception_LogService',
                                       'updateExceptionLog');
    }
  }
}