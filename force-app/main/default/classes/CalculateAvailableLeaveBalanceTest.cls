/**
* @author Eswar
* @date 11/01/2023
* @description This test class to calculate available leave balance of the employee 
*            
*
*               
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class CalculateAvailableLeaveBalanceTest {
    @TestSetup static void setupData(){
        Contact contactRec = new Contact();
        contactRec.lastName = 'Test';
        contactRec.EMS_Phone_Number__c = '9898989898';
        contactRec.Official_Mail__c = null;
        contactRec.Email = 'test@gmail.com';
        contactRec.EMS_LM_No_Of_Leaves_Credit__c = 20;
        contactRec.EMS_LM_No_Of_Compensatory_Off_Credit__c = 1;
        contactRec.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 120;
        contactRec.EMS_LM_No_of_Bereavement_Leaves_Credit__c = 2;
        contactRec.EMS_LM_No_Of_Paternity_Leaves_Credit__c = 4;
        insert contactRec;
    }
	public static testmethod void calculateAvailableLeaveBalanceAnnualLeaveTest(){
        
        Contact contactRec = [select id, lastName from Contact where lastName = 'Test'];
        
        Test.startTest();
        EMS_LM_Leave_Credit__C leavesCredit = new EMS_LM_Leave_Credit__C();
        leavesCredit.EMS_LM_Employee__c = contactRec.id;
        leavesCredit.EMS_LM_Leaves_Credited__c = 20;
        leavesCredit.EMS_LM_Select_Leave_Type__c = 'Annual Leave';
        insert leavesCredit;
        Test.stopTest();
        
        System.assertEquals([SELECT Id,EMS_LM_No_Of_Leaves_Credit__c FROM Contact].EMS_LM_No_Of_Leaves_Credit__c, 40);
		
    }
    
    public static testmethod void calculateAvailableLeaveBalanceCompensatoryOffTest(){
        
        Contact contactRec = [select id, lastName from Contact where lastName = 'Test'];
        
        Test.startTest();
        EMS_LM_Leave_Credit__C leavesCredit = new EMS_LM_Leave_Credit__C();
        leavesCredit.EMS_LM_Employee__c = contactRec.id;
        leavesCredit.EMS_LM_Leaves_Credited__c = 2;
        leavesCredit.EMS_LM_Select_Leave_Type__c = 'Compensatory Off';
        insert leavesCredit;
        Test.stopTest();
        
        System.assertEquals([SELECT Id,EMS_LM_No_Of_Compensatory_Off_Credit__c FROM Contact].EMS_LM_No_Of_Compensatory_Off_Credit__c, 3);

    }
    
    public static testmethod void calculateAvailableLeaveBalanceMaternityLeaveTest(){
        
        Contact contactRec = [select id, lastName from Contact where lastName = 'Test'];
        
        Test.startTest();
        EMS_LM_Leave_Credit__C leavesCredit = new EMS_LM_Leave_Credit__C();
        leavesCredit.EMS_LM_Employee__c = contactRec.id;
        leavesCredit.EMS_LM_Leaves_Credited__c = 182;
        leavesCredit.EMS_LM_Select_Leave_Type__c = 'Maternity Leave';
        insert leavesCredit;
        Test.stopTest();
        
        System.assertEquals([SELECT Id,EMS_LM_No_Of_Maternity_Leaves_Credit__c FROM Contact].EMS_LM_No_Of_Maternity_Leaves_Credit__c, 302);

    }
    
    public static testmethod void calculateAvailableLeaveBalanceBereavementLeaveTest(){
        
        Contact contactRec = [select id, lastName from Contact where lastName = 'Test'];
        
        Test.startTest();
        EMS_LM_Leave_Credit__C leavesCredit = new EMS_LM_Leave_Credit__C();
        leavesCredit.EMS_LM_Employee__c = contactRec.id;
        leavesCredit.EMS_LM_Leaves_Credited__c = 2;
        leavesCredit.EMS_LM_Select_Leave_Type__c = 'Bereavement Leave';
        insert leavesCredit;
        Test.stopTest();
        
        System.assertEquals([SELECT Id,EMS_LM_No_of_Bereavement_Leaves_Credit__c FROM Contact].EMS_LM_No_of_Bereavement_Leaves_Credit__c, 4);

    }
    
    public static testmethod void calculateAvailableLeaveBalancePaternityLeaveTest(){
        
        Contact contactRec = [select id, lastName from Contact where lastName = 'Test'];
        
        Test.startTest();
        EMS_LM_Leave_Credit__C leavesCredit = new EMS_LM_Leave_Credit__C();
        leavesCredit.EMS_LM_Employee__c = contactRec.id;
        leavesCredit.EMS_LM_Leaves_Credited__c = 5;
        leavesCredit.EMS_LM_Select_Leave_Type__c = 'Paternity Leave';
        insert leavesCredit;
        Test.stopTest();
        
        System.assertEquals([SELECT Id,EMS_LM_No_Of_Paternity_Leaves_Credit__c FROM Contact].EMS_LM_No_Of_Paternity_Leaves_Credit__c, 9);

    }
}