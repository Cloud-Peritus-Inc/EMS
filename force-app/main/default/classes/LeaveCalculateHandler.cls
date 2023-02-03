/**
* @author Sangharsh Kamble
* @date 20/01/2023
* @description When Leave created update Annual Leave and Comp Off Leave on Contact object(Resource Object).
*
*               Test code coverage provided by the following test class: 
*               - LeaveCalculateHandler_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class LeaveCalculateHandler implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate{
    
    public void afterInsert(List<EMS_LM_Leave_History__c> newList) {      
        leaveCalculateMethod(newList);     
    }
    
    public void afterUpdate(List<EMS_LM_Leave_History__c> newList,List<EMS_LM_Leave_History__c> oldList) {      
        leaveCalculateMethod(newList);
    }
    
    
    @TestVisible
   private void leaveCalculateMethod(list<EMS_LM_Leave_History__c> newList){
       set<id> setId=New set<id>();
        for(EMS_LM_Leave_History__c leaveall:newList){
            setId.add(leaveall.EMS_LM_Contact__c);
        }
        
        List<Contact> Resourceleave = [SELECT Id FROM Contact where Id=:setId ];
        list<EMS_LM_Leave_History__c> l1 = [select	Id, 
                                            		Name,
                                            		EMS_LM_Leave_Type_Name__c,
                                            		EMS_LM_Leave_Duration__c,
                                            		EMS_LM_Status__c 
                                            From EMS_LM_Leave_History__c 
                      						where EMS_LM_Contact__c=:setId 
                                            		And CreatedDate = This_Year 
                                            		AND (EMS_LM_Status__c='Pending' 
                                                     	OR EMS_LM_Status__c='Approved' 
                                                     	OR EMS_LM_Status__c='Waiting For Approver 2' 
                                                     	OR EMS_LM_Status__c='Waiting For Approver 3')];
       
       //AND (EMS_LM_Leave_Type_Name__c = 'Annual Leave' OR EMS_LM_Leave_Type_Name__c ='Compensatory Off')
        
        List<Contact> conlist = new List<Contact> ();
        Decimal Utilized_Leaves=0;
        Decimal utilizedcompoffLeave = 0;
        Decimal utilizedMaternityLeave = 0;
       
       Decimal utilizedPaternityLeave = 0;
       Decimal utilizedBereavementLeave = 0;
       Decimal utilizedLossOfPay = 0;
       Decimal utilizedWorkfromhome = 0;
        for(EMS_LM_Leave_History__c l2 : l1){
                  if(l2.EMS_LM_Leave_Type_Name__c == 'Annual Leave' && l2.EMS_LM_Leave_Duration__c !=Null  && (l2.EMS_LM_Status__c=='Pending' || 
              																					l2.EMS_LM_Status__c=='Approved' || 
                                                                                              	l2.EMS_LM_Status__c=='Waiting For Approver 2'|| 
                                                                                               	l2.EMS_LM_Status__c=='Waiting For Approver 3'))
                  {
                      Utilized_Leaves = Utilized_Leaves + l2.EMS_LM_Leave_Duration__c;
                  } 
            	if(l2.EMS_LM_Leave_Type_Name__c == 'Compensatory Off' && l2.EMS_LM_Leave_Duration__c !=Null && (l2.EMS_LM_Status__c=='Pending' || 
                                                                        l2.EMS_LM_Status__c=='Approved' || 
                                                                        l2.EMS_LM_Status__c=='Waiting For Approver 2'||
                                                                       l2.EMS_LM_Status__c=='Waiting For Approver 3'))
                {
                      utilizedcompoffLeave = utilizedcompoffLeave + l2.EMS_LM_Leave_Duration__c;
                  }
            	if(l2.EMS_LM_Leave_Type_Name__c == 'Maternity Leave' && l2.EMS_LM_Leave_Duration__c !=Null && (l2.EMS_LM_Status__c=='Pending' || 
                                                                        l2.EMS_LM_Status__c=='Approved' || 
                                                                        l2.EMS_LM_Status__c=='Waiting For Approver 2'||
                                                                       l2.EMS_LM_Status__c=='Waiting For Approver 3'))
                {
                      utilizedMaternityLeave = utilizedMaternityLeave + l2.EMS_LM_Leave_Duration__c;
                  }
            //Paternity Leave
            if(l2.EMS_LM_Leave_Type_Name__c == 'Paternity Leave' && l2.EMS_LM_Leave_Duration__c !=Null && (l2.EMS_LM_Status__c=='Pending' || 
                                                                        l2.EMS_LM_Status__c=='Approved' || 
                                                                        l2.EMS_LM_Status__c=='Waiting For Approver 2'||
                                                                       l2.EMS_LM_Status__c=='Waiting For Approver 3'))
                {
                      utilizedPaternityLeave = utilizedPaternityLeave + l2.EMS_LM_Leave_Duration__c;
                  }
            
            if(l2.EMS_LM_Leave_Type_Name__c == 'Bereavement Leave' && l2.EMS_LM_Leave_Duration__c !=Null && (l2.EMS_LM_Status__c=='Pending' || 
                                                                        l2.EMS_LM_Status__c=='Approved' || 
                                                                        l2.EMS_LM_Status__c=='Waiting For Approver 2'||
                                                                       l2.EMS_LM_Status__c=='Waiting For Approver 3'))
                {
                      utilizedBereavementLeave = utilizedBereavementLeave + l2.EMS_LM_Leave_Duration__c;
                  }
            
            if(l2.EMS_LM_Leave_Type_Name__c == 'Loss of Pay' && l2.EMS_LM_Leave_Duration__c !=Null && (l2.EMS_LM_Status__c=='Pending' || 
                                                                        l2.EMS_LM_Status__c=='Approved' || 
                                                                        l2.EMS_LM_Status__c=='Waiting For Approver 2'||
                                                                       l2.EMS_LM_Status__c=='Waiting For Approver 3'))
                {
                      utilizedLossOfPay = utilizedLossOfPay + l2.EMS_LM_Leave_Duration__c;
                  }
            
            if(l2.EMS_LM_Leave_Type_Name__c == 'Work from Home' && l2.EMS_LM_Leave_Duration__c !=Null && (l2.EMS_LM_Status__c=='Pending' || 
                                                                        l2.EMS_LM_Status__c=='Approved' || 
                                                                        l2.EMS_LM_Status__c=='Waiting For Approver 2'||
                                                                       l2.EMS_LM_Status__c=='Waiting For Approver 3'))
                {
                      utilizedWorkfromhome = utilizedWorkfromhome + l2.EMS_LM_Leave_Duration__c;
                  }
              } 
        
        for(Contact con:Resourceleave){     
            con.EMS_LM_No_Of_Utilized_Leaves__c=Utilized_Leaves;
            con.EMS_LM_No_OF_Utilized_Compensatory_Off__c=utilizedcompoffLeave;
            con.EMS_LM_No_Of_Utilized_Maternity_Leaves__c=utilizedMaternityLeave;
            
            con.No_Of_Utilized_Paternity_Leaves__c = utilizedPaternityLeave;       
            con.EMS_LM_No_Of_Utilized_Bereavement_Leaves__c =  utilizedBereavementLeave;                  
            con.EMS_LM_No_Of_Utilized_Loss_Of_Pay__c = utilizedLossOfPay ;
            con.No_OF_Utilized_Work_from_Home__c = utilizedWorkfromhome;
            conlist.add(con);
        }
        
        if(conlist.size()>0){
            update conlist;
        }
       
    }
}