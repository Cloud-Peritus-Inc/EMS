public class AssignmentShare {
    
    public static void assignemntSharetoLead(List<EMS_TM_Assignment__c> newList){
        Set<Id> contactIds = new Set<Id>();
        Map<Id,EMS_TM_Assignment__c> assignmentMap = new  Map<Id,EMS_TM_Assignment__c>();
        for(EMS_TM_Assignment__c assignrec : newList){
            assignmentMap.put(assignrec.EMS_TM_EmployeeName__c,assignrec);
        }
        SYstem.debug('assignmentMap'+assignmentMap);
        List<EMS_TM_Assignment__Share> assignShareRec = new List<EMS_TM_Assignment__Share>();
        for(Resource_Resource_Relationship__c rrrRecod:[SELECT Id, 
                                                        		Resource__c,
                                                        		Resource_Reports_To__c,
                                                                Resource_Reports_To__r.EMS_TM_user__c,
                                                                Resource_Reports_To_User__c
                                                        		FROM Resource_Resource_Relationship__c
                                                       			WHERE Resource__c IN:assignmentMap.keyset()]){
                                                System.debug('rrrRecod'+rrrRecod+'..........'+rrrRecod.Resource_Reports_To__r.EMS_TM_user__c);
                           EMS_TM_Assignment__Share assignmentShare = new EMS_TM_Assignment__Share();
                           assignmentShare.ParentId = assignmentMap.get(rrrRecod.Resource__c).Id;
                           assignmentShare.UserOrGroupId = '00552000007YXDRAA4';
                           assignmentShare.AccessLevel = 'Read';
                           assignShareRec.add(assignmentShare);                                                                                                                   
        }
         SYstem.debug('assignShareRec'+assignShareRec);
        try{
        if(!assignShareRec.IsEmpty()){
            insert assignShareRec;
            // Database.SaveResult[] jobShareInsertResult = Database.insert(assignShareRec,false);
        }
        }catch(Exception e){
            System.debug('assinmentshare'+e.getMessage());
        }
    }

}