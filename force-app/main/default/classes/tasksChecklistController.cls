public without sharing class tasksChecklistController {
    @AuraEnabled
    public static String getRecordTypeName(String recordIdContact){
        String recordTypeName = [SELECT Id, RecordType.Name from Contact where id =: recordIdContact].RecordType.Name;
        return recordTypeName;
    }
}