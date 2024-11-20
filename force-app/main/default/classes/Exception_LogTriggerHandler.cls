/*
* @group Handler
* @description Service class for Exception_LogHandler
* @author Cloud Peritus Inc
*/
public
class Exception_LogTriggerHandler extends TriggerHandler {
 public
  List<Exception_Log__c> newExceptionLog = new List<Exception_Log__c>();
 public
  Map<Id, Exception_Log__c> oldExceptionLogMap =
      new Map<Id, Exception_Log__c>();
 public
  Exception_LogTriggerHandler() {
    this.newExceptionLog = (List<Exception_Log__c>)Trigger.new;
    this.oldExceptionLogMap = (Map<Id, Exception_Log__c>)Trigger.oldMap;
  }
  /**
   * @description : Method to handle before insert events
   */
 public
  override void afterInsert() {
    if (RecursiveCheck.runOnce()) {
      Exception_LogService.retryExceptionBasedOnPriority(newExceptionLog);
    }
  }
}