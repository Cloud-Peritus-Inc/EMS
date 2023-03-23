/**
* @author Suneel and Rakshitha
* @date 11/01/2023
* @description  This class is used for leave balance updating after utilized leaves
*
*               Test code coverage provided by the following test class:
*               - CP_utilizedLeaveBalanceTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CP_utilizedLeaveBalance implements TriggerAction.AfterUpdate{
    /**
    * @author Suneel and Rakshitha
    * @date 11/01/2023
    * @description Before Insert 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    public static void afterUpdate(List<EMS_LM_Leave_History__c> newList, List<EMS_LM_Leave_History__c> oldList) {
        try {
            System.debug(LoggingLevel.DEBUG, 'CP_utilizedLeaveBalance.afterUpdate() : BEGIN');
            List<EMS_LM_Leave_History__c> l = new List<EMS_LM_Leave_History__c>();
            Map<Id, EMS_LM_Leave_History__c> oldMap = new Map<Id, EMS_LM_Leave_History__c>(oldList);
            for(EMS_LM_Leave_History__c e: newList) {
                if(e.EMS_LM_Status__c != oldMap.get(e.Id).EMS_LM_Status__c) {
                    l.add(e);
                }
            }
            if(l.size()>0) {
                utilizedLeaveBalanceCalculation(l);
            }
            System.debug(LoggingLevel.DEBUG, 'CP_utilizedLeaveBalance.afterUpdate() : END');
        } catch(Exception e ) {
            LogException.logHandledException(e, 'CP_utilizedLeaveBalance', 'afterUpdate');
        }
    }
    /**
    *   {Purpose} - Method to populate used for leave balance updating after utilized leaves
    *
    *   CHANGE HISTORY
    *   ====================================================================================================
    *   Date        Name                    Description
    *   N/A         N/A                     N/A
    *   ====================================================================================================
    **/
    public static void utilizedLeaveBalanceCalculation(List<EMS_LM_Leave_History__c> leaveHistory) {
        try {
            List<Id> leaveIdsList = new List<Id>();
            for (EMS_LM_Leave_History__c leaveRecord : leaveHistory) {
                leaveIdsList.add(leaveRecord.EMS_LM_Contact__c);
            }
            List<Contact> conlist = new List<Contact> ();
            Decimal utilizedAnnualLeave = 0;
            Decimal utilizedLossOfPay = 0;            
            Decimal utilizedcompoffLeave = 0;
            Decimal utilizedBereavementLeave = 0;
            Decimal utilizedPaternityLeave = 0;
            Decimal utilizedMaternityLeave = 0;
            Decimal availbalupdate = 0;
            List<EMS_LM_Leave_History__c> annualCompList = [SELECT Id, Name, EMS_LM_Leave_Duration__c,
                                                        Leave_Type_Name__c ,
                                                        EMS_LM_Status__c, EMS_LM_Contact__c 
                                                FROM EMS_LM_Leave_History__c
                                                WHERE EMS_LM_Contact__c  IN :leaveIdsList
                                                AND CreatedDate = This_Year
                                                AND (EMS_LM_Status__c = :CP_leaveHistoryConstants.APPROVER_1_PENDING
                                                OR EMS_LM_Status__c = :CP_leaveHistoryConstants.PENDING
                                                OR EMS_LM_Status__c = :CP_leaveHistoryConstants.APPROVED
                                                OR EMS_LM_Status__c = :CP_leaveHistoryConstants.APPROVER_2_PENDING) 
                                                AND (Leave_Type_Name__c  = :CP_leaveHistoryConstants.ANNUAL_LEAVE
                                                OR Leave_Type_Name__c  = :CP_leaveHistoryConstants.COMPENSATORY_OFF)];
            List<EMS_LM_Leave_History__c> otherList = [SELECT Id, Name, EMS_LM_Leave_Duration__c,Leave_Type_Name__c ,
                                                        EMS_LM_Status__c, EMS_LM_Contact__c
                                                FROM EMS_LM_Leave_History__c
                                                WHERE EMS_LM_Contact__c  IN :leaveIdsList
                                                AND (EMS_LM_Status__c = :CP_leaveHistoryConstants.APPROVER_1_PENDING
                                                OR EMS_LM_Status__c = :CP_leaveHistoryConstants.PENDING
                                                OR EMS_LM_Status__c = :CP_leaveHistoryConstants.APPROVED
                                                OR EMS_LM_Status__c = :CP_leaveHistoryConstants.APPROVER_2_PENDING) 
                                                AND (Leave_Type_Name__c  = 'Maternity Leave'
                                                OR Leave_Type_Name__c  = 'Bereavement Leave'
                                                OR Leave_Type_Name__c  = 'Loss of Pay'
                                                OR Leave_Type_Name__c  = 'Paternity Leave')];
            Map<Id, List<EMS_LM_Leave_History__c>> annualCompLeaves = new Map<Id, List<sObject>>();
            for(EMS_LM_Leave_History__c leavRecord: annualCompList){
                if (annualCompLeaves.containsKey(leavRecord.EMS_LM_Contact__c)) {
                    List<EMS_LM_Leave_History__c> eLeave = annualCompLeaves.get(leavRecord.EMS_LM_Contact__c);
                    eLeave.add(leavRecord);
                    annualCompLeaves.put(leavRecord.EMS_LM_Contact__c,eLeave);
                } else {
                    List<EMS_LM_Leave_History__c> leave = new List<EMS_LM_Leave_History__c>();
                    leave.add(leavRecord);
                    annualCompLeaves.put(leavRecord.EMS_LM_Contact__c,leave);
                }
            }
            Map<Id, List<EMS_LM_Leave_History__c>> otherLeaves = new Map<Id, List<sObject>>();
            for(EMS_LM_Leave_History__c leavRecord: otherList){
                if (otherLeaves.containsKey(leavRecord.EMS_LM_Contact__c)) {
                    List<EMS_LM_Leave_History__c> eLeave = otherLeaves.get(leavRecord.EMS_LM_Contact__c);
                    eLeave.add(leavRecord);
                    otherLeaves.put(leavRecord.EMS_LM_Contact__c,eLeave);
                } else {
                    List<EMS_LM_Leave_History__c> leave = new List<EMS_LM_Leave_History__c>();
                    leave.add(leavRecord);
                    otherLeaves.put(leavRecord.EMS_LM_Contact__c,leave);
                }
            }
            Map<Id, Contact> contact = new Map<Id,Contact>([SELECT Id, EMS_LM_No_of_Bereavement_Leaves_Credit__c,
                                                                    EMS_LM_No_Of_Compensatory_Off_Credit__c,
                                                                    EMS_LM_No_Of_Leaves_Credit__c, EMS_LM_No_Of_Maternity_Leaves_Credit__c,
                                                                    EMS_LM_No_Of_Paternity_Leaves_Credit__c, EMS_LM_No_Of_Utilized_Bereavement_Leaves__c,
                                                                    EMS_LM_No_OF_Utilized_Compensatory_Off__c, EMS_LM_No_Of_Utilized_Leaves__c,
                                                                    EMS_LM_No_Of_Utilized_Loss_Of_Pay__c, EMS_LM_No_Of_Utilized_Maternity_Leaves__c,
                                                                    No_Of_Utilized_Paternity_Leaves__c
                                                            FROM Contact
                                                            WHERE Id  IN :leaveIdsList]);
            for(EMS_LM_Leave_History__c leaveHistoryRecord : leaveHistory) {
                for(EMS_LM_Leave_History__c leave : annualCompLeaves.get(leaveHistoryRecord.EMS_LM_Contact__c)) {
                    if(leave.Leave_Type_Name__c  == CP_leaveHistoryConstants.ANNUAL_LEAVE) {
                        utilizedAnnualLeave = utilizedAnnualLeave + leave.EMS_LM_Leave_Duration__c ;
                    }
                    if(leave.Leave_Type_Name__c  == CP_leaveHistoryConstants.COMPENSATORY_OFF ) {
                        utilizedcompoffLeave = utilizedcompoffLeave + leave.EMS_LM_Leave_Duration__c ;
                    }
                }

                for(EMS_LM_Leave_History__c leave : otherLeaves.get(leaveHistoryRecord.EMS_LM_Contact__c)) {
                    if(leave.Leave_Type_Name__c  == 'Maternity Leave') {
                        utilizedMaternityLeave = utilizedMaternityLeave + leave.EMS_LM_Leave_Duration__c ;                        
                    }
                    if(leave.Leave_Type_Name__c  == 'Bereavement Leave') {
                        utilizedBereavementLeave = utilizedBereavementLeave + leave.EMS_LM_Leave_Duration__c ;   
                    }
                    if(leave.Leave_Type_Name__c  =='Paternity Leave') {
                        utilizedPaternityLeave  =  utilizedPaternityLeave + leave.EMS_LM_Leave_Duration__c ;    
                    }
                    if(leave.Leave_Type_Name__c  == 'Loss of Pay') {
                        utilizedLossOfPay = utilizedLossOfPay + leave.EMS_LM_Leave_Duration__c ;
                    }
                }
                Contact con = contact.get(leaveHistoryRecord.EMS_LM_Contact__c);
                if(con != null) {
                    con.No_Of_Utilized_Paternity_Leaves__c = utilizedPaternityLeave;
                    con.EMS_LM_No_OF_Utilized_Compensatory_Off__c = utilizedcompoffLeave;
                    con.EMS_LM_No_Of_Utilized_Leaves__c = utilizedAnnualLeave ;
                    con.EMS_LM_No_Of_Utilized_Bereavement_Leaves__c =  utilizedBereavementLeave;
                    con.EMS_LM_No_Of_Utilized_Maternity_Leaves__c = utilizedMaternityLeave ;
                    con.EMS_LM_No_Of_Utilized_Loss_Of_Pay__c = utilizedLossOfPay ;
                    conlist.add(con); 
                }  
                system.debug(utilizedAnnualLeave + 'ss' + utilizedcompoffLeave + 'ss' + utilizedPaternityLeave + 'ss' + utilizedBereavementLeave + 'ss' +utilizedMaternityLeave);
                if(conlist.size()>0) {
                    Update conlist;
                }
            }
        } catch(Exception e ) {
            LogException.logHandledException(e, 'CP_utilizedLeaveBalance', 'utilizedLeaveBalanceCalculation');
        }
    }
    
    
}