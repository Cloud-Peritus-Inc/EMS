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

    @AuraEnabled
    public static List<Goal__c> getResourceKraRecords(Contact member,Date startDate, Date endDate){
        System.debug('#Member ' + member);
        Id KRARecTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('KRA').getRecordTypeId();
        System.debug('#KRARecTypeId ' + KRARecTypeId);

        List<Goal__c> kraGoalRecords = Null;
        try {
            if (member != Null && member.Id != Null) {
                    kraGoalRecords = [Select Id,Name,Resource__c, Goal_Name__c, Status__c,Fulfillment__c,
                    Quarter_Start_Date__c,Quarter_End_Date__c,RecordTypeId,Overall_Rating__c,
                    Fulfillment__r.Fiscal_Year__c
                    FROM  Goal__c 
                    WHERE Resource__c =: member.Id 
                    AND RecordTypeId =: KRARecTypeId
					AND Status__c = 'KRA Completed'
                    AND Quarter_Start_Date__c >= :startDate
                    AND Quarter_End_Date__c <= :endDate];
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
            compList = [SELECT Id, Name, Appraisal_Date__c, Comments__c, Finalized_Hike__c, Next_Appraisal_Date__c, Resource__c, Reviewed_By__c,Fulfillment__c,
            //smaske : PM_079 : Created new field Compensation_Submitted__c
            Compensation_Submitted__c,
             //Mukesh :: Created new field Overall_KRA_Average_Rating__c
             Overall_KRA_Average_Rating__c
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
    public static Compensation__c updateCompensationDetails(Compensation__c record, List<Goal__c> kraRecords, Id fy){
        System.debug('record :' + record);
        System.debug('fy ID :' + fy);
        try {
            //smaske : Updated code to associate Compensation with Selected FY fulfilment record
            List<Fulfillment__c> FulfList = New List<Fulfillment__c>();
            List<Goal__c> KraList = New List<Goal__c>();
            if (record.Fulfillment__c == null) {
                FulfList = [select id,Resource__c,Fiscal_Year__c 
                FROM Fulfillment__c where Fiscal_Year__c =: fy AND Resource__c =: record.Resource__c
                ORDER BY CreatedDate DESC LIMIT 1];
            }
            if (record.Fulfillment__c == null && !FulfList.isEmpty() && FulfList.size() >= 1) {
                record.Fulfillment__c = FulfList[0].Id;
            }

            record.Appraisal_Date__c = Date.today();
            record.Compensation_Submitted__c = true;
            //smaske : PM_079 : Removed Upsert as multiple records were created.
            //Upsert record;
            if (record.Id == null) {
                insert record;
            } else {
                update record;
            }

            updateContactDetails(record);
            updateFulfillmentDetails(record,fy);
             // Update KRA records
        	if (!kraRecords.isEmpty()) {
            	for (Goal__c kra : kraRecords) {
                // Update KRA record fields
                	kra.Status__c = 'HR KRA Completed';
                    KraList.add(kra);
            	}
                update KraList;
        }
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
            Fulfillment__c ff = [Select Id,Appraisal_Date__c,Status__c,Fiscal_Year__c,Overall_Comments__c,Resource__c FROM Fulfillment__c WHERE Resource__c =: record.Resource__c AND Fiscal_Year__c =: fy];
            ff.Appraisal_Date__c = Date.today();
            ff.Overall_Comments__c = record.Comments__c;
            ff.Status__c='Completed';
            update ff;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}