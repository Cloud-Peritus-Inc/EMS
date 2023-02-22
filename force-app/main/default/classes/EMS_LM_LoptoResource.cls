/**
* @author Sangharsh Kamble
* @date 16/02/2023
* @description Class for Create Leave Credit Record to add loss of pay if Resource has no annual leave.
*
*               Test code coverage provided by the following test class: 
*               - EMS_LM_LoptoResource_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing  class EMS_LM_LoptoResource implements TriggerAction.Afterupdate{
    
    public void afterupdate(List<Contact> ResourceList ,List<Contact> mapResourceList) {      
        LoptoResourcemethod(ResourceList);     
    }
    
    
    @TestVisible
    private void LoptoResourcemethod(list<Contact> ResourceList){

    Set<String> usedPicklistValues = new Set<String>();
        
    for (EMS_LM_Leave_Credit__c child : [SELECT EMS_LM_Employee__c , Leave_Type_Name__c 
                                         FROM EMS_LM_Leave_Credit__c 
                                         WHERE EMS_LM_Employee__c IN :ResourceList AND Leave_Type_Name__c =:LeaveRequestConstant.LOSS_OF_PAY]) {
                                             
        usedPicklistValues.add(child.Leave_Type_Name__c);
    }
        
        
    EMS_LM_Leave__c leavetype = [SELECT Id , EMS_LM_Leave_Type__c FROM EMS_LM_Leave__c WHERE EMS_LM_Leave_Type__c = :LeaveRequestConstant.LOSS_OF_PAY LIMIT 1]; 
     
        

    
    List<EMS_LM_Leave_Credit__c> childrenToInsert = new List<EMS_LM_Leave_Credit__c>();
        
    for (Contact parent : ResourceList) {
        
         if (leaveType != null) {
    		String leaveTypeId = leaveType.Id;
  	// check if the picklist value is already used in child records
        if (!usedPicklistValues.contains(LeaveRequestConstant.LOSS_OF_PAY) && leaveTypeId != Null && parent.EMS_LM_No_Of_Availble_Leaves__c <=-4) {
            // create a new leave credit record
            EMS_LM_Leave_Credit__c child = new EMS_LM_Leave_Credit__c();
            child.EMS_LM_Employee__c = parent.Id;
            child.EMS_LM_Leave_Type__c = leaveTypeId;
            child.EMS_LM_Leave_Credited_Date__c = System.today();
            childrenToInsert.add(child);
        	}
		}       
    }

    
        if( !childrenToInsert.isEmpty()){
            insert childrenToInsert;
        }
    }

}