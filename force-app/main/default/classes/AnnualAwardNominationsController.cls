public without sharing class AnnualAwardNominationsController {

    public static final String RECORD_TYPE_NAME = 'Nominations'; 
    public static final String STATUS_NOMINATED = 'Nominated';

    @AuraEnabled(cacheable=true)
    public static List<Reward_And_Recognition__c> getAnnualAwardNominationRecords() {
        Id UserId = UserInfo.getUserId();
        List<Reward_And_Recognition__c> annualAwardList;
        Id nominationsRecTypeId = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByName().get(RECORD_TYPE_NAME).getRecordTypeId();
        try {
            annualAwardList = [
                            SELECT Id, Award_Type__c,Fiscal_Year__c,Primary_Nomination__c,Secondary_Nomination__c,Nomination_Submitted__c,
                            Reason_for_award__c,Recognization_By__c,Resource__c,Resource__r.Name,Status__c,Type__c,RecordTypeId,CreatedById
                            FROM Reward_And_Recognition__c
                            WHERE CreatedById =: UserId AND RecordTypeId =: nominationsRecTypeId AND Recognization_By__c =:UserId AND Status__c =: STATUS_NOMINATED
        ];
        } catch (Exception e) {
            throw new AuraHandledException('Unable to retrieve AnnualAwardNomination records: ' + e.getMessage());
        }
        System.debug('IN annualAwardList ' + annualAwardList.toString());
        return annualAwardList;    
    }

    @AuraEnabled
    public static List<Reward_And_Recognition__c> createAnnualAwardNominationRecords(List<Reward_And_Recognition__c> recordsToCreate,Id currentfy) {
        List<Reward_And_Recognition__c> awardListToInsert = new List<Reward_And_Recognition__c>();
        Id nominationsRecTypeId = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByName().get(RECORD_TYPE_NAME).getRecordTypeId();
        System.debug('### INSIDE createAnnualAwardNominationRecords');
        System.debug('### recordsToCreate value ' + recordsToCreate);

        for(Reward_And_Recognition__c rrr : recordsToCreate) {
            rrr.RecordTypeId = nominationsRecTypeId;
            rrr.Fiscal_Year__c = currentfy;
            awardListToInsert.add(rrr);
        }
        
        List<Database.UpsertResult> results;
        try {
            System.debug('### awardListToInsert value ' + awardListToInsert.toString());
            results = Database.upsert(awardListToInsert, false);
        } catch (DmlException e) {
            throw new AuraHandledException('Unable to perform the DML operation on Reward_And_Recognition__c records: ' + e.getMessage());
        }

        for (Database.UpsertResult result : results) {
            if (result.isSuccess()) {
                System.debug('Successfully inserted Reward_And_Recognition__c record: ' + result.getId());
            } else {
                for (Database.Error error : result.getErrors()) {
                    System.debug('Error Status: ' + error.getStatusCode() + ', Error Fields: ' + error.getFields());
                }
            }
        }
        System.debug('B4 RETURN : ' + awardListToInsert.toString());
        return awardListToInsert;
    }

    @AuraEnabled
    public static List<Reward_And_Recognition__c> submitAnnualAwardNominationRecords(List<Reward_And_Recognition__c> recordsToSubmit,Id currentfy) {
        List<Reward_And_Recognition__c> awardListToSubmit = new List<Reward_And_Recognition__c>();
        Id nominationsRecTypeId = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByName().get(RECORD_TYPE_NAME).getRecordTypeId();
        System.debug('### INSIDE submitAnnualAwardNominationRecords');
        System.debug('### recordsToSubmit value ' + recordsToSubmit);
        System.debug('### nominationsRecTypeId value ' + nominationsRecTypeId);

        for(Reward_And_Recognition__c rrr : recordsToSubmit) {
            rrr.RecordTypeId = nominationsRecTypeId;
            rrr.Fiscal_Year__c = currentfy;
            rrr.Nomination_Submitted__c = true;
            awardListToSubmit.add(rrr);
        }
        
        List<Database.UpsertResult> results;
        try {
            results = Database.upsert(awardListToSubmit, false);
        } catch (DmlException e) {
            throw new AuraHandledException('Unable to perform the DML operation on Reward_And_Recognition__c records: ' + e.getMessage());
        }

        for (Database.UpsertResult result : results) {
            if (result.isSuccess()) {
                System.debug('Successfully inserted Reward_And_Recognition__c record: ' + result.getId());
            } else {
                for (Database.Error error : result.getErrors()) {
                    System.debug('Error Status: ' + error.getStatusCode() + ', Error Fields: ' + error.getFields());
                }
            }
        }
        return awardListToSubmit;
    }
}