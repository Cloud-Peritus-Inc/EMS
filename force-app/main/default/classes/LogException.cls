/*
 * @group Service
 * @description Service class Exception Record creation
 * @author Cloud Peritus Inc
 * @created date (mm/dd/yyyy)
 * @last modified date
 */
public
class LogException extends Exception {
  /**
   * @description       This method is called to create an Exception_Log__c
   * record in case of Exception object is null
   * @param             className the Class Name
   * @param             methodName the Method Name
   */
 public
  static void writeToObjectIfExceptNull(String className, String methodName,
                                        String details, String lineNo) {
    Exception_Log__c logger = new Exception_Log__c();
    logger.ClassName__c = className;
    logger.ContextUser__c = userinfo.getuserId();
    logger.MethodName__c = methodName;
    if (details != null) {
      logger.ExceptionDetails__c = details + lineNo;
    }
    logger.ExceptionLogTimeStamp__c = System.now();
    insert logger;
  }

  /**
   * @description       This method is called in case the User obtains a handled
   * Exception. This method in turn calls methods to build and insert
   * ExceptionLog__c records. It also checks if the record can be merged with a
   * pre-existing record.
   * @param             excp the Exception object
   * @param             className the Class Name
   * @param             methodName the Method Name
   * @return            void
   * @usage
   */
 public
  static void logHandledException(Exception excp, String className,
                                  String methodName) {
    List<Exception_Log__c> excpLogVal = new List<Exception_Log__c>();
    Exception_Log__c exceptionLog =
        buildExceptionObject(excp, className, methodName, false);
    excpLogVal =
        mergeExistingErrorLogs(new List<Exception_Log__c>{exceptionLog});
    if (excpLogVal != null && excpLogVal.size() == 1) {
      logException(exceptionLog);
    }
  }

  /**
   * @description       This method is called in case the User obtains a handled
   * Exception. This method in turn calls methods to build and insert High
   * Priority ExceptionLog__c records. It also checks if the record can be
   * merged with a pre-existing record.
   * @param             excp the Exception object
   * @param             className the Class Name
   * @param             methodName the Method Name
   * @return            void
   * @usage
   */
 public
  static void logHandledHPException(Exception excp, String className,
                                    String methodName) {
    List<Exception_Log__c> excpLogVal = new List<Exception_Log__c>();
    Exception_Log__c exceptionLog =
        buildExceptionObject(excp, className, methodName, true);
    excpLogVal =
        mergeExistingErrorLogs(new List<Exception_Log__c>{exceptionLog});
    if (excpLogVal != null && excpLogVal.size() == 1) {
      logException(exceptionLog);
    }
  }

  /**
   * @description       This method is used to build the ExceptionLog__c record
   * to be inserted.
   * @param             excp the Exception object
   * @param             className the Class Name
   * @param             methodName the Method Name
   * @param				highPriority high priority Exceptioons
   * @return            Exception_Log__c
   */
 private
  static Exception_Log__c buildExceptionObject(Exception excp, String className,
                                               String methodName,
                                               Boolean highPriority) {
    Exception_Log__c exceptionLog = new Exception_Log__c();
    exceptionLog.ExceptionDetails__c = buildExceptionDetails(excp);
    exceptionLog.ExceptionType__c = excp.getTypeName();
    exceptionLog.ClassName__C = className;
    exceptionLog.MethodName__c = methodName;
    exceptionLog.Status__c = UtilErrorConstants.STATUS_RAISED;
    exceptionLog.ContextUser__c = UserInfo.getUserId();
    exceptionLog.High_Priority_triggered__c = highPriority;
    // exceptionLog.RecordTypeId = expRecordTypeId;
    Integer startPoint =
        excp.getMessage().IndexOf(UtilErrorConstants.EXCEPTION_CODE_FILTER) +
        UtilErrorConstants.EXCEPTION_CODE_FILTER.length();
    String excpCode = excp.getMessage().substring(startPoint).trim();
    excpCode = (excpCode.split(UtilErrorConstants.BLANK_SPACE))[0];
    exceptionLog.ExceptionCode__c = excpCode.left(excpCode.length() - 1);

    exceptionLog.ExceptionDescription__c =
        excp.getMessage().left(UtilErrorConstants.EXCEPTION_CODE_SIZE_LIMIT);
    exceptionLog.ExceptionLogTimeStamp__c = System.now();
    exceptionLog.NumberOfTimesOccured__c = 1;

    return exceptionLog;
  }

  /**
   * @description       This method is used to build the ExceptionDetail__c
   * field value for ExceptionLog__c record to be inserted.
   * @param             excp the Exception object
   * @return            String
   * @throws            NA
   */
 private
  static String buildExceptionDetails(Exception excp) {
    string details = excp.getTypeName() + UtilErrorConstants.COLON +
                     excp.getMessage() + UtilErrorConstants.ENTER +
                     excp.getStackTraceString();
    return details.left(UtilErrorConstants.EXCEPTION_DETAILS_SIZE_LIMIT);
  }

  /**
   * @description       This method is called by multiple methods, to check if
   * the current Exception_Log__c record can be merged with any pre-existing
   * record if they have the same class and method name or trigger name.
   * @param             exceptionLogList the List of Exceptions__c records to be
   * inserted
   * @return            List<Exception_Log__c>
   * @throws            NA
   */
 private
  static List<Exception_Log__c> mergeExistingErrorLogs(
      List<Exception_Log__c> exceptionLogList) {
    String lineColumn = UtilErrorConstants.BLANK_SPACE;
    List<String> exceptionType = new List<String>();
    List<Exception_Log__c> existingExceptionLogs = new List<Exception_Log__c>();
    List<Exception_Log__c> exExcpLogs = new List<Exception_Log__c>();
    List<Exception_Log__c> exceptionLogToBeUpdated =
        new List<Exception_Log__c>();
    List<Exception_Log__c> exceptionLogToBeInserted =
        new List<Exception_Log__c>();
    Set<Exception_Log__c> logList = new Set<Exception_Log__c>();
    exceptionLogToBeInserted.addAll(exceptionLogList);

    return exceptionLogToBeInserted;
  }

  /**
   * @description       This method is used to insert Exception_Log__c record if
   * their Severity__c value is ERROR.
   * @param             exceptionLog the Exception_Log__c record to be created
   * @return            void
   */
 private
  static void logException(Exception_Log__c exceptionLog) {
    Database.insert(exceptionLog, false);
  }

  /**
   * @description       This method is called to log ExceptionLog__c record,
   * when an Exception occurs due to a Webservice call in the code.
   * @return            ex The Exception Object
   * @param             className the Class Name
   * @param             methodName the Method Name
   * @param             ws_application the Webservice Application Name
   * @param             ws_transactionID the Webservice Transaction Id
   * @usage
   */
 public
  static void logServiceException(Exception ex, String className,
                                  String methodName, String ws_application,
                                  String ws_transactionID) {
    List<Exception_Log__c> filteredRecords = new List<Exception_Log__c>();
    Exception_Log__c exceptionLog =
        buildExceptionObject(ex, className, methodName, false);
    exceptionLog.WSCallingApplication__c = ws_application;
    exceptionLog.WSTransactionID__c = ws_transactionID;
    // exceptionLog.RecordTypeId = expRecordTypeId;
    filteredRecords =
        mergeExistingErrorLogs(new List<Exception_Log__c>{exceptionLog});
    if ((filteredRecords != null) && filteredRecords.size() == 1) {
      logException(exceptionlog);
    }
  }

  /**
   * @description       This method is called to log ExceptionLog__c record,
   * when an Exception occurs due to a Webservice call in the code.
   * @return            ex The Exception Object
   * @param             className the Class Name
   * @param             methodName the Method Name
   * @param             ws_application the Webservice Application Name
   * @param             ws_transactionID the Webservice Transaction Id
   * @param             salesforceIds the salesforce objects Id
   * @param             payload the Webservice JSON
   * @usage
   */
 public
  static void logServiceIntegrationException(
      Exception ex, String className, String methodName, String ws_application,
      String ws_transactionID, String salesforceIds, String payload) {
    Exception_Log__c exceptionLog =
        buildExceptionObject(ex, className, methodName, false);
    exceptionLog.WSCallingApplication__c = ws_application;
    exceptionLog.WSTransactionID__c = ws_transactionID;
    exceptionLog.Data_Log__c = payload;
    exceptionlog.Salesforce_Ids__c = salesforceIds;
    // exceptionLog.RecordTypeId = expRecordTypeId;
    if (exceptionLog != null) {
      logException(exceptionlog);
    }
  }

  /**
   * @description       This method logs ExceptionLog__c records in case of
   * Exception obtained due to Database.SaveResult
   * @param             svResults A List of Database.Saveresult object records
   * @param             delResults A List of Database.Deleteresult object
   * records
   * @param             objs A List of sObject records which threw the exception
   * when being saved
   * @param             className the Class Name
   * @param             methodName the Method Name
   * @usage             CDLLogException.logDmlResults(svRes_A, accList_A,
   * TEST_CLASS, TEST_METHOD);
   */

 public
  static void logDmlResults(List<Database.Saveresult> svResults,
                            List<sObject> objs, String className,
                            String methodName) {
    List<Exception_Log__c> exceptionLogList = new List<Exception_Log__c>();
    // Method called in case of save exception
    if (svResults != null) {
      exceptionLogList =
          createExceptionForSaveResults(svResults, objs, className, methodName);
    }
    // Implementing logic to check if this record can be merged with any
    // pre-existing Exception_Log__c record
    if (exceptionLogList.size() > 0 && svResults != null) {
      List<Exception_Log__c> mergeLogList = new List<Exception_Log__c>();
      mergeLogList = mergeExistingErrorLogs(exceptionLogList);
      insertExceptionList(mergeLogList);
    } else if (exceptionLogList.size() > 0 && svResults == null) {
      Database.insert(exceptionLogList, false);
    }
  }

  /**
   * @description       This method creates Exception_Log__c records in case of
   * Exception obtained due to Database.SaveResult operation.
   * @param             svResults A List of Database.Saveresult object records
   * @param             relatedsObjects A List of sObject records which threw
   * the exception when being saved
   * @param             appName the Application Name
   * @param             className the Class Name
   * @param             methodName the Method Name
   * @param             triggerName the Trigger Name
   * @param             level the system.LoggingLevel variable to determine the
   * exception level
   * @return            List<Exception_Log__c>
   * @throws            NA
   */
 private
  static List<Exception_Log__c> createExceptionForSaveResults(
      List<Database.SaveResult> saveResults, List<sObject> relatedsObjects,
      String className, string methodName) {
    List<Exception_Log__c> exceptionLogList = new List<Exception_Log__c>();
    for (integer i = 0; i < saveResults.size(); ++i) {
      Database.SaveResult saveresult = saveResults[i];
      if (!saveresult.isSuccess()) {
        Database.Error[] errors = saveresult.getErrors();
        String relatedObjectString = UtilErrorConstants.BLANK_SPACE;
        if (relatedsObjects.size() > i) {
          relatedObjectString =
              UtilErrorConstants.RELATED_OBJECT + relatedsObjects[i];
        }
        system.debug('error11 = ' + errors);
        String errorMessage =
            (buildErrorMessageFromErrorList(saveresult.getId(), errors) +
             relatedObjectString.left(
                 UtilErrorConstants.EXCEPTION_DETAILS_SIZE_LIMIT));
        system.debug('errorMessage1234 ' + errorMessage);
        String exceptionCode = UtilErrorConstants.BLANK_SPACE;
        if (errors.size() > 0) {
          exceptionCode = errors[0].statusCode.name();
        }
        exceptionLogList.add(new Exception_Log__c(
            ExceptionCode__c = exceptionCode, ClassName__C = className,
            MethodName__c = methodname, ContextUser__c = UserInfo.getUserId(),
            NumberOfTimesOccured__c = 1,
            ExceptionLogTimestamp__c = System.Now(),
            ExceptionDetails__c = errorMessage,
            Status__c = UtilErrorConstants.STATUS_RAISED,
            ExceptionType__c = UtilErrorConstants.DML_EXCEPTION,
            Data_Log__c = !relatedsObjects.isEmpty()
                              ? JSON.serialize(relatedsObjects)
                              : '' ));
      }
    }

    return exceptionLogList;
  }

  /**
   * @description       This method compares in the List of Exception_Log__c
   records to be inserted to check if any record is repeated. If so, that record
   is eliminated.
   * @param             mergeLogList the List of Exception_Log__c records
   obtained from the merge method
   * @return            void
   */
 private
  static void insertExceptionList(List<Exception_Log__c> mergeLogList) {
    List<Exception_Log__c> filteredList = new List<Exception_Log__c>();

    for (Exception_Log__c exceptionLog : mergeLogList) {
      if (filteredList.size() == 0) {
        filteredList.add(exceptionLog);
      }
    }
    if (!filteredList.isEmpty()) {
      Database.insert(filteredList, false);
    }
  }

  /**
   * @description       This method is used to build the error message for the
   * ExceptionLog__c record to be inserted in case of Database.SaveResult or
   * Database.DeleteResult operation.
   * @param             idVal the Id of the record throwing exception during
   * Database.insert or Database.delete
   * @param             errorList the List of Database.Error Object records
   * @return            String
   */
 private
  static String buildErrorMessageFromErrorList(ID idVal,
                                               List<Database.Error> errorList) {
    string errorMessage =
        UtilErrorConstants.RECORD_ID + idVal + UtilErrorConstants.ENTER;
    for (database.Error error : errorList) {
      errorMessage += error + UtilErrorConstants.ENTER;
    }
    return errorMessage.left(UtilErrorConstants.EXCEPTION_DETAILS_SIZE_LIMIT);
  }

  /**
   * @description       This method logs ExceptionLog__c records in case of
   * Exception obtained due to Database.SaveResult
   * @param             svResults A List of Database.Saveresult object records
   * @param             delResults A List of Database.Deleteresult object
   * records
   * @param             objs A List of sObject records which threw the exception
   * when being saved
   * @param             className the Class Name
   * @param             methodName the Method Name
   * @usage             CDLLogException.logDmlResults(svRes_A, accList_A,
   * TEST_CLASS, TEST_METHOD);
   */

 public
  static void logDmlJSONResults(List<Database.Saveresult> svResults,
                                List<sObject> objs, String className,
                                String methodName) {
    List<Exception_Log__c> exceptionLogList = new List<Exception_Log__c>();
    // Method called in case of save exception
    if (svResults != null) {
      exceptionLogList = createExceptionJSONForSaveResults(
          svResults, objs, className, methodName);
    }

    // Implementing logic to check if this record can be merged with any
    // pre-existing Exception_Log__c record
    if (exceptionLogList.size() > 0 && svResults != null) {
      List<Exception_Log__c> mergeLogList = new List<Exception_Log__c>();
      mergeLogList = mergeExistingErrorLogs(exceptionLogList);
      insertExceptionList(mergeLogList);
    } else if (exceptionLogList.size() > 0 && svResults == null) {
      Database.insert(exceptionLogList, false);
    }
  }

  /**
   * @description       This method creates Exception_Log__c records in case of
   * Exception obtained due to Database.SaveResult operation.
   * @param             svResults A List of Database.Saveresult object records
   * @param             relatedsObjects A List of sObject records which threw
   * the exception when being saved
   * @param             appName the Application Name
   * @param             className the Class Name
   * @param             methodName the Method Name
   * @param             triggerName the Trigger Name
   * @param             level the system.LoggingLevel variable to determine the
   * exception level
   * @return            List<Exception_Log__c>
   * @throws            NA
   */
 private
  static List<Exception_Log__c> createExceptionJSONForSaveResults(
      List<Database.SaveResult> saveResults, List<sObject> relatedsObjects,
      String className, string methodName) {
    List<Exception_Log__c> exceptionLogList = new List<Exception_Log__c>();
    for (integer i = 0; i < saveResults.size(); ++i) {
      Database.SaveResult saveresult = saveResults[i];
      if (!saveresult.isSuccess()) {
        Database.Error[] errors = saveresult.getErrors();
        String relatedObjectString = UtilErrorConstants.BLANK_SPACE;
        if (relatedsObjects.size() > i) {
          relatedObjectString =
              UtilErrorConstants.RELATED_OBJECT + relatedsObjects[i];
        }
        String errorMessage =
            (buildErrorMessageFromErrorList(saveresult.getId(), errors) +
             relatedObjectString.left(
                 UtilErrorConstants.EXCEPTION_DETAILS_SIZE_LIMIT));
        String exceptionCode = UtilErrorConstants.BLANK_SPACE;
        if (errors.size() > 0) {
          exceptionCode = errors[0].statusCode.name();
        }
        schema.SObjectType objectType = relatedsObjects.getSobjectType();
        exceptionLogList.add(new Exception_Log__c(
            ExceptionCode__c = exceptionCode, ClassName__C = className,
            MethodName__c = methodname, ContextUser__c = UserInfo.getUserId(),
            NumberOfTimesOccured__c = 1,
            // RecordTypeId = expRecordTypeId,
            ExceptionLogTimestamp__c = System.Now(),
            ExceptionDetails__c = errorMessage,
            Status__c = UtilErrorConstants.STATUS_RAISED,
            ExceptionType__c = UtilErrorConstants.DML_EXCEPTION,
            Data_Log__c = !relatedsObjects.isEmpty()
                              ? JSON.serialize(relatedsObjects)
                              : '',
            objects__c = String.valueOf(objectType), Priority__c = 'High'));
      }
    }
    return exceptionLogList;
  }
}