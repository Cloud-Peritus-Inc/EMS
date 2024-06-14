/**
* @author Rohit Bhupati
* @date 8/02/2023
* @description  BatchToForwordAvailableLeaveBalanceToNextYear Batch to Forword available leave balance of the employee to Next Year
*              
*               Schedule class 
*               - BatchToForwordLeaveBalanceToNextYear_sch
*               Test code coverage provided by the following test class:
*               - BatchToForwordLeaveBalanceToNextYearTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/

global class BatchToForwordLeaveBalanceToNextYear implements Database.Batchable<sObject> {
  /**
* @author Rohit Bhupati
* @date 8/02/2023
* @description start query to get the data of the object that required to process.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    
  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator([
      SELECT Id,AccountId,EMS_LM_No_Of_Carry_Forward_Leaves__c, EMS_LM_No_Of_Leaves_Credit__c,
                                         EMS_LM_No_Of_Availble_Leaves__c, EMS_LM_No_Of_Available_Paternity_Leave__c,
                                         EMS_LM_No_Of_Available_Maternity_Leave__c, EMS_LM_No_Of_Available_Compensatory_Off__c,
                                         EMS_LM_No_Of_Available_Bereavement_Leave__c,EMS_EM_JD__c,EMS_LM_No_Of_Utilized_Leaves__c 
                                         FROM Contact WHERE RecordTypeId =:ContactConstant.RESOURCE_RECORDTYPEID AND AccountId !=Null 
    ]);
  }

    /**
* @author Rohit Bhupati
* @date 8/02/2023
* @description  Execute method to process the business logic.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
  
  global void execute(Database.BatchableContext bc, List<Contact> Conlist) {
   
  }

  global void finish(Database.BatchableContext bc) {
  }

}