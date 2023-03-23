public class EMS_TM_ContactBillableclose {
    
    public static void closeBillableCheckbox(list<EMS_TM_Assignment__c> newAssignment){
        Set<id> contactids = new set<id>();
        map<id,EMS_TM_Assignment__c> assigndata = new map<id,EMS_TM_Assignment__c>();
        for(EMS_TM_Assignment__c et: newAssignment){
            if(et.EMS_TM_EmployeeName__c != null){
                contactids.add(et.EMS_TM_EmployeeName__c);
                assigndata.put(et.EMS_TM_EmployeeName__c,et);
            }
        }
        list<EMS_TM_Assignment__c> assignDataList =  new list<EMS_TM_Assignment__c>();
        for(EMS_TM_Assignment__c at : [Select id,EMS_TM_EmployeeName__c,EMS_TM_Status_Asgn__c,EMS_TM_Billable__c from EMS_TM_Assignment__c 
                                       where EMS_TM_EmployeeName__c =:assigndata.keyset()]){
                     if(at.EMS_TM_Status_Asgn__c == 'Active' && at.EMS_TM_Billable__c == true){
                         assignDataList.add(at);
                     }
                     }
        System.debug('assignDataList'+assignDataList);
        list<contact> updatedConList = new list<contact>();
        for(contact c :[SELECT Id, Official_Mail__c, EMS_TM_In_Billing__c 
                        FROM Contact where id =:assigndata.keyset() ]){
                            if(assignDataList.size() > 0){
                                System.debug('I am in If Condition');
                                c.EMS_TM_In_Billing__c = true;
                            }
                            else{
                                System.debug('I am in Else Condition');
                               c.EMS_TM_In_Billing__c = false ;
                            }
                
            updatedConList.add(c);
        }
        System.debug('con'+updatedConList);
        if(updatedConList.size() != null){
        update updatedConList;
            }
    }

}