/**
* @author Eswar
* @date 11/01/2023
* @description  CalculateAvailableLeaveBalance Class to calculate available leave balance of the employee 
*              
*
*               Test code coverage provided by the following test class:
*               - CalculateAvailableLeaveBalanceTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CalculateAvailableLeaveBalance implements TriggerAction.AfterInsert{
    /**
* @author Eswar
* @date 11/01/2023
* @description After Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void afterInsert(List<EMS_LM_Leave_Credit__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'CalculateAvailableLeaveBalance.afterInsert() : BEGIN');
        calculateEmployeeAvailableLeaveBalance(newList);
        System.debug(LoggingLevel.DEBUG, 'CalculateAvailableLeaveBalance.afterInsert() : END');       
    }
    /**
*   {Purpose} - Method for calculate available leave balance of the employee
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    private void calculateEmployeeAvailableLeaveBalance(List<EMS_LM_Leave_Credit__c> leaveCreditList){       
        List<Contact> finalContactList = new List<Contact> ();
        set<string> employeeSet = new set<String>();
        Decimal availableAnnualLeave = 0;
        Decimal availablecompoffLeave = 0;
        Decimal availablePaternityLeave = 0;
        Decimal availableMaternityLeave = 0;
        Decimal availableBereavementLeave = 0; 
        for(EMS_LM_Leave_Credit__c leaveCredit : leaveCreditList){
                employeeSet.add(leaveCredit.EMS_LM_Employee__c); 
        }
        
        Map<Id,Contact> contactMap = new Map<Id,Contact>(
            								[SELECT Id, 
                                                 EMS_LM_No_of_Bereavement_Leaves_Credit__c,
                                                 EMS_LM_No_Of_Compensatory_Off_Credit__c,
                                                 EMS_LM_No_Of_Leaves_Credit__c,
                                                 EMS_LM_No_Of_Maternity_Leaves_Credit__c,
                                                 EMS_LM_No_Of_Paternity_Leaves_Credit__c
                                             FROM Contact
                                             WHERE Id IN: employeeSet]);
       
        for(EMS_LM_Leave_Credit__C leaveCreditRec : leaveCreditList){
            if(contactMap.containsKey(leaveCreditRec.EMS_LM_Employee__c)){
              contact contactRec =  contactMap.get(leaveCreditRec.EMS_LM_Employee__c);
                String leaveTypeRec = leaveCreditRec.EMS_LM_Select_Leave_Type__c;
                Switch on leaveTypeRec{
                    when 'Annual Leave'{
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
               finalContactList.add(contactRec); 
            }  
        }
        
        try{
            if(finalContactList.size()>0){
                Update finalContactList;   
            }
        }
        Catch(Exception excp){
			LogException.logHandledException(excp, 'CalculateAvailableLeaveBalance', 'calculateEmployeeAvailableLeaveBalance');        
        }  
    }
}