/*
 * @group Apex Test
 * @description This is a Test class for LogException
 * @author Cloud Peritus Inc
 * @created date (mm/dd/yyyy)
 * @cast modified date
 */
@isTest public class LogExceptionTest {
  // Constants for Test Methods
 private
  static final String TEST_CLASS = 'TestClass';
 private
  static final String TEST_METHOD = 'TestMethod';
 private
  static final String WS_TRASCT_ID = 'abcd12345';
 private
  static final String WS_CALLING_APPLN = 'AWS';
 private
  static final String EXCEPT_DETAILS =
      'Inserting Exception without exception object';

  /**
  * @description       This Test Method is to verify that Exception_Log__c
  record is logged in case of any program throwing a Handled Exception.
  */
@istest private
  static  void handledException() {
    try {
      Account testData = new Account();
      insert(testData);
    } catch (DMLException excp) {
      Test.startTest();
      LogException.logHandledException(excp, TEST_CLASS, TEST_METHOD);
      Test.stopTest();
    }
    // clang-format off
    Exception_Log__c excpData =[SELECT ClassName__c,
                                       MethodName__c
                                FROM Exception_Log__c
                                WHERE ClassName__c =:TEST_CLASS ];
    // clang-format on
    System.assertEquals(excpData.MethodName__c, TEST_METHOD,'Method name should be matched');
  }

  /**
 * @description       This Test Method is to verify that Exception_Log__c
 record is logged in case of any program throwing a Handled Service Exception.
 */
@istest private
  static  void handledServiceException() {
    try {
      Account testData = new Account();
      insert(testData);
    } catch (DMLException excp) {
      Test.startTest();
      LogException.logServiceException(excp, TEST_CLASS, TEST_METHOD,
                                       WS_CALLING_APPLN, WS_TRASCT_ID);
      Test.stopTest();
    }
    // clang-format off
    Exception_Log__c excpData =[SELECT WSCallingApplication__c,
                                      WSTransactionID__c
                                FROM Exception_Log__c
                                WHERE WSCallingApplication__c =:WS_CALLING_APPLN ];
    // clang-format on
    System.assertEquals(excpData.WSTransactionID__c, WS_TRASCT_ID,'WSTransactionID__c should be matched');
  }

  /**
  * @description       This Test Method is to verify that Exception_Log__c
                       record is merged with an existing Exception_Log__c record
                       in case of any program throwing a Handled Exception.
  */
@istest private
  static  void handledExceptionMerge() {
    try {
      Account testData1 = new Account();
      insert(testData1);
    } catch (DMLException excp) {
      try {
        Account testData2 = new Account();
        insert(testData2);
      } catch (DMLException dmlExcp) {
        Test.startTest();
        LogException.logHandledException(excp, TEST_CLASS, TEST_METHOD);
        LogException.logHandledException(excp, TEST_CLASS, TEST_METHOD);
        Test.stopTest();
      }
      // clang-format off
      Exception_Log__c excpData =[SELECT ClassName__c,
                                        MethodName__c
                                  FROM Exception_Log__c
                                  WHERE ClassName__c =:TEST_CLASS
                                  LIMIT 1];
      // clang-format on
      System.assertEquals(excpData.MethodName__c, TEST_METHOD,'Method name should be matched');
    }
  }

  /**
* @description       This Test Method is to verify that Exception_Log__c
                     record is logged in case of any program throwing a Handled
Service Exception.
*/
@istest private
  static void handledServiceExceptionMerge() {
    String jsonStr;
    try {
      Account testData1 = new Account();
      insert(testData1);
      jsonStr = JSON.serialize(testData1);
    } catch (DMLException excp) {
      try {
        Account testData2 = new Account();
        insert(testData2);
      } catch (DMLException dmlExcp) {
        Test.startTest();
        LogException.logServiceException(excp, TEST_CLASS, TEST_METHOD,
                                         WS_CALLING_APPLN, WS_TRASCT_ID);
        LogException.logServiceException(excp, TEST_CLASS, TEST_METHOD,
                                         WS_CALLING_APPLN, WS_TRASCT_ID);
        LogException.logServiceIntegrationException(
            excp, TEST_CLASS, TEST_METHOD, WS_CALLING_APPLN, WS_TRASCT_ID, null,
            jsonStr);
        Test.stopTest();
      }
      // clang-format off
      Exception_Log__c excpData =[SELECT WSCallingApplication__c,
                                         WSTransactionID__c,
                                         NumberOfTimesOccured__c,
                                         MethodName__c
                                  FROM Exception_Log__c
                                  WHERE WSCallingApplication__c =:WS_CALLING_APPLN
                                  LIMIT 1 ];
      // clang-format on
      System.assertEquals(excpData.MethodName__c, TEST_METHOD,'Method name should be matched');
    }
  }

  /**
  * @description       This Test Method is to verify that Exception_Log__c
  record is logged in case of any program throwing a Handled Exception.
  */
@istest private
  static void writeToObjectIfExceptNull() {
    try {
      Account testData = new Account();
      insert(testData);
    } catch (DMLException excp) {
      Test.startTest();
      LogException.writeToObjectIfExceptNull(
          TEST_CLASS, TEST_METHOD,
          'Inserting Exception without exception object', 'Line No -20');
      Test.stopTest();
    }
    // clang-format off
    Exception_Log__c excpData =[SELECT ClassName__c,
                                      MethodName__c
                                FROM Exception_Log__c
                                WHERE ClassName__c =:TEST_CLASS ];
    // clang-format on
    System.assertEquals(excpData.MethodName__c, TEST_METHOD,'Method name should be matched');
  }

  /**
   * @description       This Test Method is to verify that ExceptionLog__c
   *					 record is logged in case of any program
   *throwing an Exception due to Database.insert() operation.
   * @param             NA
   * @return            void
   * @throws            NA
   */
@istest private
  static void handledExceptionSave() {
    List<Account> accList = new List<Account>();
    Account accData1 = new Account(Name = 'Name1');
    Account accData2 = new Account();
    Account accData3 = new Account(Name = 'Name2');
    accList.add(accData1);
    accList.add(accData2);
    Database.SaveResult[] svRes = Database.insert(accList, false);
    Test.startTest();
    LogException.logDmlResults(svRes, accList, TEST_CLASS, TEST_METHOD);
    LogException.logDmlJSONResults(svRes, accList, TEST_CLASS, TEST_METHOD);
    Test.stopTest();
    // clang-format off
    List<Exception_Log__c> excpData =[SELECT ClassName__c,
                                             MethodName__c
                                      FROM Exception_Log__c
                                      WHERE ClassName__c =:TEST_CLASS ];
    System.assertEquals(excpData[0].MethodName__c, TEST_METHOD,'Method name should be matched');
    Integer noOfExcep = [SELECT COUNT()
                         FROM Exception_Log__c
                         WHERE ClassName__c =:TEST_CLASS];
    // clang-format on
  }

  /**
  * @description       This Test Method is to verify that ExceptionLog__c
  record is merged with an existing ExceptionLog__c record in case of any
  program throwing an Exception due to Database.insert() operation.
  * @param             NA
  * @return            void
  * @throws            NA
  */
@istest private
  static void handledExceptionSaveMerge() {
    List<Account> accList1 = new List<Account>();
    List<Account> accList2 = new List<Account>();
    Account accData1 = new Account(Name = 'Name1');
    Account accData2 = new Account();
    Account accData3 = new Account(Name = 'Name2');
    accList1.add(accData1);
    accList1.add(accData2);
    accList2.add(accData3);
    accList2.add(accData2);
    Database.SaveResult[] svRes1 = Database.insert(accList1, false);
    Database.SaveResult[] svRes2 = Database.insert(accList2, false);
    Test.startTest();
    LogException.logDmlResults(svRes1, accList1, TEST_CLASS, TEST_METHOD);
    LogException.logDmlResults(svRes2, accList2, TEST_CLASS, TEST_METHOD);
    Test.stopTest();
    // clang-format off
    List<Exception_Log__c> excpData =[SELECT NumberOfTimesOccured__c,
                                            ClassName__c,
                                            ContextUser__c,
                                            ExceptionLogTimestamp__c,
                                            WSCallingApplication__c,
                                            ExceptionDetails__c, WSTransactionID__c,
                                            MethodName__c
                                      FROM Exception_Log__c
                                      WHERE ClassName__c =:TEST_CLASS ];
    // clang-format on
    System.assertEquals(excpData[0].MethodName__c, TEST_METHOD,'Method name should be matched');
    system.debug('Size of' + excpData.size());
    system.debug('Data' + excpData);
  }
}