/**
* @author Subba Kalavala
* @date 22/01/2023
* @description  BatchToCalculateTheAvailableLeaves Batch to calculate available leave balance of the employee 
*              
*               Schedule class 
*               - BatchToCalculateTheAvaiLeaves_sch
*               Test code coverage provided by the following test class:
*               - BatchToCalculateTheAvalLeavesTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global without sharing class BatchToCalculateTheAvailableLeaves implements Database.Batchable<sObject> {

 /**
* @author Subba
* @date 22/01/2023
* @description start query to get the data of the object that required to process.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,EMS_LM_No_of_Bereavement_Leaves_Credit__c,
                                         EMS_LM_No_Of_Compensatory_Off_Credit__c,
                                         EMS_LM_No_Of_Leaves_Credit__c,
                                         EMS_LM_No_Of_Maternity_Leaves_Credit__c,
                                         EMS_LM_No_Of_Paternity_Leaves_Credit__c,
                                         (SELECT EMS_LM_Employee__c,
                                          EMS_LM_Leave_Credited_Date__c,Leave_Type_Name__c, 
                                          EMS_LM_Leave_Type__c,EMS_LM_Leaves_Credited__c  FROM Leave_Credits__r WHERE EMS_LM_Leave_Credited_Date__c = THIS_YEAR ),
                                         (SELECT Id,Leave_Type_Name__c,EMS_LM_Leave_Duration__c FROM Leaves_History__r 
                                          WHERE EMS_LM_Leave_End_Date__c = THIS_YEAR AND EMS_LM_Status__c != 'Cancelled' AND EMS_LM_Status__c != 'Rejected' )
                                         FROM CONTACT WHERE RecordTypeId =:ContactConstant.RESOURCE_RECORDTYPEID AND (EMS_RM_ApplicantStatus_Update__c = 'Active' OR EMS_RM_ApplicantStatus_Update__c = 'Active - Probation' ) ]);
    }
  
/**
* @author Subba
* @date 22/01/2023
* @description  Execute method to process the business logic.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
         List<Contact> finalContactList = new List<Contact>();
        for(Contact contactRec : conList){  
            contactRec.EMS_LM_No_Of_Leaves_Credit__c = 0;
            contactRec.EMS_LM_No_Of_Compensatory_Off_Credit__c = 0;
            contactRec.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            contactRec.EMS_LM_No_of_Bereavement_Leaves_Credit__c = 0;
            contactRec.EMS_LM_No_Of_Paternity_Leaves_Credit__c = 0;
            contactRec.No_Of_Utilized_Paternity_Leaves__c = 0;
            contactRec.EMS_LM_No_OF_Utilized_Compensatory_Off__c = 0;
            contactRec.EMS_LM_No_Of_Utilized_Leaves__c = 0 ;
            contactRec.EMS_LM_No_Of_Utilized_Bereavement_Leaves__c =  0;
            contactRec.EMS_LM_No_Of_Utilized_Maternity_Leaves__c = 0 ;
            contactRec.EMS_LM_No_Of_Utilized_Loss_Of_Pay__c = 0 ;           
        for(EMS_LM_Leave_Credit__c leaveCreditRec : contactRec.Leave_Credits__r){
            system.debug('------------Leave record-----'+leaveCreditRec);
                String leaveTypeRec = leaveCreditRec.Leave_Type_Name__c ;
                Switch on leaveTypeRec{
            
                    when 'Annual Leave'{
                        contactRec.EMS_LM_No_Of_Leaves_Credit__c = contactRec.EMS_LM_No_Of_Leaves_Credit__c + leaveCreditRec.EMS_LM_Leaves_Credited__c;
                        
                    }
                    when 'Paid time off'{
                        contactRec.EMS_LM_No_Of_Leaves_Credit__c = contactRec.EMS_LM_No_Of_Leaves_Credit__c + leaveCreditRec.EMS_LM_Leaves_Credited__c;
                        
                    }
                    when 'Compensatory Off'{
                        contactRec.EMS_LM_No_Of_Compensatory_Off_Credit__c = contactRec.EMS_LM_No_Of_Compensatory_Off_Credit__c + leaveCreditRec.EMS_LM_Leaves_Credited__c;
                    }
                    when 'Maternity Leave'{
                        contactRec.EMS_LM_No_Of_Maternity_Leaves_Credit__c = contactRec.EMS_LM_No_Of_Maternity_Leaves_Credit__c + leaveCreditRec.EMS_LM_Leaves_Credited__c;
                    }
                    when 'Bereavement Leave'{
                        contactRec.EMS_LM_No_of_Bereavement_Leaves_Credit__c = contactRec.EMS_LM_No_of_Bereavement_Leaves_Credit__c + leaveCreditRec.EMS_LM_Leaves_Credited__c;
                    }
                    when 'Paternity Leave'{
                        contactRec.EMS_LM_No_Of_Paternity_Leaves_Credit__c = contactRec.EMS_LM_No_Of_Paternity_Leaves_Credit__c + leaveCreditRec.EMS_LM_Leaves_Credited__c;
                    }
                }   
            }
            
          for(EMS_LM_Leave_History__c  leaveutilRec : contactRec.Leaves_History__r){
                String leaveTypeRec = leaveutilRec.Leave_Type_Name__c ;
                Switch on leaveTypeRec{
                    when 'Annual Leave'{
                        contactRec.EMS_LM_No_Of_Utilized_Leaves__c = contactRec.EMS_LM_No_Of_Utilized_Leaves__c + leaveutilRec.EMS_LM_Leave_Duration__c;
                    }
                    when 'Paid time off'{
                        contactRec.EMS_LM_No_Of_Utilized_Leaves__c = contactRec.EMS_LM_No_Of_Utilized_Leaves__c + leaveutilRec.EMS_LM_Leave_Duration__c;
                    }
                    when 'Compensatory Off'{
                        contactRec.EMS_LM_No_OF_Utilized_Compensatory_Off__c = contactRec.EMS_LM_No_OF_Utilized_Compensatory_Off__c + leaveutilRec.EMS_LM_Leave_Duration__c;
                    }
                    when 'Maternity Leave'{
                        contactRec.EMS_LM_No_Of_Utilized_Maternity_Leaves__c = contactRec.EMS_LM_No_Of_Utilized_Maternity_Leaves__c + leaveutilRec.EMS_LM_Leave_Duration__c;
                    }
                    when 'Bereavement Leave'{
                        contactRec.EMS_LM_No_Of_Utilized_Bereavement_Leaves__c = contactRec.EMS_LM_No_Of_Utilized_Bereavement_Leaves__c + leaveutilRec.EMS_LM_Leave_Duration__c;
                    }
                    when 'Paternity Leave'{
                        contactRec.No_Of_Utilized_Paternity_Leaves__c = contactRec.No_Of_Utilized_Paternity_Leaves__c + leaveutilRec.EMS_LM_Leave_Duration__c;
                    }
                }               
          }
            
             finalContactList.add(contactRec);
        }
        
       try{
            if(finalContactList.size()>0){
                Update finalContactList;   
            }
        }
        Catch(Exception excp){
			LogException.logHandledException(excp, 'BatchToCalculateTheAvailableLeaves', 'execute');        
        } 
    }
    
/**
* @author Subba
* @date 22/01/2023
* @description process the failures.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global void finish(Database.BatchableContext BC) {
        
    }
}