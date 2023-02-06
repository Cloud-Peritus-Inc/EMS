public class EMS_EM_GridConfigurationSettings {
  @AuraEnabled(cacheable=true)
  public static List<Grid_Configuration__c> getCompanyInformation() {
  return [SELECT Id, Name, CreatedDate, Description__c FROM Grid_Configuration__c where Name = 'Company Information'];
  }
}