/*
 * @group service
 * @description Util class for constants values used in
 * LogException,CDLLogExceptionTest classes
 * @author Cloud Peritus Inc
 * @created date (mm/dd/yyyy) 09/21/2022
 * @last modified date
 */
public
with sharing class UtilErrorConstants {
  // Variables to hold Class constants
 public
  static final Integer EXCEPTION_CODE_SIZE_LIMIT = 100;
 public
  static final Integer EXCEPTION_DETAILS_SIZE_LIMIT = 32768;
 public
  static final String STATUS_RAISED = 'Raised';
 public
  static final String PREFIX_FW = 'fw: ';
 public
  static final String PREFIX_FWD = 'fwd: ';
 public
  static final String PREFIX_RE = 're:';
 public
  static final String CAUSED_BY = 'caused by:';
 public
  static final String PREFIX_CLASS = 'Class.';
 public
  static final String PREFIX_TRIGGER = 'Trigger.';
 public
  static final String LINE_NO = ': line';
 public
  static final String EXCEPTION_CODE_FILTER = 'first error:';
 public
  static final String START_APEX_SCRIPT = 'Apex script';
 public
  static final String IDENTIFY_TRIGGER = 'Apex script unhandled trigger';
 public
  static final String SANDBOX_EMAIL = 'Sandbox';
 public
  static final String USER = 'user/organization';
 public
  static final String BATCH_CLASS_NAME = 'BATCH_PurgeOldExcption';
 public
  static final String BATCH_METHOD_NAME = 'execute';
 public
  static final String DML_EXCEPTION = 'System.DMLException';
 public
  static final String BATCH_CUSTOM_SETTING_RECORD =
      'ExceptionRecordDeletionFilter';
 public
  static final String PAGINATION_CUSTOM_SETTING_RECORD = 'ExceptionSearch';
 public
  static final String SEVERITY_LEVEL_CUSTOM_SETTING_RECORD = 'LogLevelError';
 public
  static final String SEVERITY_LEVEL_ERROR = 'ERROR';
 public
  static final String SEVERITY_LEVEL_FOR_DEFECT = '1 - Low';
 public
  static final String DEFECT = 'Defect';
 public
  static final String BLANK_SPACE = '';
 public
  static final String RELATED_OBJECT = 'Related Object : ';
 public
  static final String OTHER_EXCEPTION = 'Miscellaneous Exception';
 public
  static final String COLON = ':';
 public
  static final String APOSTROPHE = '\'';
 public
  static final String DOUBLE_QUOTE = '\"';
 public
  static final String FULLSTOP = '.';
 public
  static final String FORWARD_SLASH = '/';
 public
  static final String ERROR_APPLICATION = 'Error Logging Framework';
 public
  static final String ERROR_LOG_CLASS = 'UTIL_LoggingService';
 public
  static final String UNHANDLED_ERROR_LOG_METHOD = 'processExceptionEmail';
 public
  static final String RECORD_ID = 'Record Id:';
 public
  static final String ENTER = '\n';
 public
  static final String HEADER =
      'Name,Exception Type,Exception Code,Class,Method,Apex Trigger,Handled,No. of Times Occured,Converted to Defect,Severity,Context User\r\n';
 public
  static final String DATE_FORMAT = 'MM/dd/YYYY';
 public
  static final String DATE_NULL_ERROR_MESSAGE =
      'Please Select Start Date and End Date';
 public
  static final String START_DATE_GREATER_MESSAGE =
      'Start Date must be same as or before End Date';
 public
  static final String START_DATE_AFTER_TODAY_MESSAGE =
      'Start Date must be same as or before Today';
 public
  static final String EXCEPTION_SEARCH_CLASS = 'VFC_ExceptionSearch';
 public
  static final String EXCEPTION_SEARCH_METHOD = 'search';
 public
  static final String GENERIC_ERROR_MESSAGE = 'Exception Occured';
 public
  static final String DELETE_EXCEPTION = 'deleteException';
 public
  static final String CONVERT_EXCEPTION = 'convertException';
 public
  static final String CONVERT_TO_CSV_LINK = '/apex/VFP_ExportToCSV';
 public
  static final String BATCH_PFLOG_CS = 'PerformanceLogDeletionFilter';
 public
  static final String BATCH_PURGE_PFLOG = 'BATCH_PurgeOldPerformanceLog';
 public
  static final String QUERY_PURGE_PFLOG =
      'SELECT Id FROM PerformanceLog__c WHERE CreatedDate = N_DAYS_AGO:';
}