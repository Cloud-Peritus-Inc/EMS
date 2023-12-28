public without sharing class generatePerformanceKRAController {
    public generatePerformanceKRAController() {

    }

    @AuraEnabled(cacheable=true)
    public static Contact getResourceDetails(Id selectedresource){
        Contact con;
        try {
            con = [ SELECT Id,Name,Email,Work_Location_Country__c,Resource_Role__c,EMS_EM_JD__c,
            EMS_Employee_Type__c,Appraisal_Date__c,EMS_TM_User__c,Last_Appraisal_Date__c,Next_Appraisal_Date__c
            FROM Contact
            WHERE Id =: selectedresource
            ];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return con;
    }

    @AuraEnabled(cacheable=true)
    public static List<Goal__c> getResourceKraRecords(Contact member,Id fy){
        System.debug('#Member ' + member);
        Id KRARecTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('KRA').getRecordTypeId();
        System.debug('#KRARecTypeId ' + KRARecTypeId);

        List<Goal__c> kraGoalRecords = Null;
        try {
            if (member != Null && member.Id != Null) {
                if ( member.Last_Appraisal_Date__c != Null && member.Next_Appraisal_Date__c != Null ) {
                    System.debug('#IF ');
                    kraGoalRecords = [Select Id,Name,Resource__c, Status__c, Overall_Average_Section_Rating__c,Fulfillment__c,
                    Start_Date__c,End_Date__c,RecordTypeId,
                    Fulfillment__r.Fiscal_Year__c
                    
                    FROM  Goal__c 
                    WHERE Resource__c =: member.Id 
                    AND RecordTypeId =: KRARecTypeId
                    AND Start_Date__c >= :member.Last_Appraisal_Date__c
                    AND End_Date__c <= :member.Next_Appraisal_Date__c
                    AND Fulfillment__r.Fiscal_Year__c =: fy
                    
                    ];
                }else if(member.Last_Appraisal_Date__c == Null && member.Next_Appraisal_Date__c != Null){
                    System.debug('#ELSE ');
                    kraGoalRecords = [Select Id,Name,Resource__c, Status__c, Overall_Average_Section_Rating__c,Fulfillment__c,
                    Start_Date__c,End_Date__c,RecordTypeId,
                    Fulfillment__r.Fiscal_Year__c
                    
                    FROM  Goal__c 
                    WHERE Resource__c =: member.Id 
                    AND RecordTypeId =: KRARecTypeId
                    AND Start_Date__c >= :member.EMS_EM_JD__c
                    AND End_Date__c <= :member.Next_Appraisal_Date__c
                    AND Fulfillment__r.Fiscal_Year__c =: fy
                    
                    ];
                }
            }
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return kraGoalRecords;
    }

    @AuraEnabled(cacheable=true)
    public static Compensation__c getCompensationDetails(Id selectedresource){
        System.debug('selectedresource :' + selectedresource);
        
        List<Compensation__c> compList = new List<Compensation__c>();
        Compensation__c comp = Null;
        
        try {
            compList = [SELECT Id, Name, Appraisal_Date__c, Comments__c, Finalized_Hike__c, Next_Appraisal_Date__c, Resource__c, Reviewed_By__c
                        FROM Compensation__c 
                        WHERE Resource__c = :selectedresource LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        if (!compList.isEmpty()) {
            System.debug(' compList ' + compList);
            comp = compList[0];
        }
        return comp;
    }

    @AuraEnabled
    public static Compensation__c updateCompensationDetails(Compensation__c record,Id fy){
        System.debug('record :' + record);
        
        try {
            record.Appraisal_Date__c = Date.today();
            Upsert record;
            updateContactDetails(record);
            updateFulfillmentDetails(record,fy);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return record;
    }

    @AuraEnabled
    public static void updateContactDetails(Compensation__c record){
        try {
            Contact con = [Select Id,Appraisal_Date__c,Next_Appraisal_Date__c FROM Contact WHERE Id=: record.Resource__c ];
            con.Appraisal_Date__c = Date.today();
            con.Last_Appraisal_Date__c = Date.today();
            con.Next_Appraisal_Date__c = record.Next_Appraisal_Date__c;
            update con;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateFulfillmentDetails(Compensation__c record,Id fy){
        try {
            Fulfillment__c ff = [Select Id,Appraisal_Date__c,Fiscal_Year__c,Overall_Comments__c,Resource__c FROM Fulfillment__c WHERE Resource__c =: record.Resource__c AND Fiscal_Year__c =: fy];
            ff.Appraisal_Date__c = Date.today();
            ff.Overall_Comments__c = record.Comments__c;
            update ff;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}