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
        leaveCalculateMethod(newList,null);
                for(EMS_LM_Leave_History__c Pmtoemail:newList){
            if(Pmtoemail.EMS_LM_Status__c=='auto approved'){
                Pmtogetmail.getemails(Pmtoemail.EMS_LM_Contact__c,Pmtoemail.Id);
            }
             }
    }
    
    public void afterUpdate(List<EMS_LM_Leave_History__c> newList,List<EMS_LM_Leave_History__c> oldList) {      
        leaveCalculateMethod(newList,new Map<Id,EMS_LM_Leave_History__c>(oldList));
        for(EMS_LM_Leave_History__c Pmtoemail:newList){
            if(Pmtoemail.EMS_LM_Status__c=='approved'){
                Pmtogetmail.getemails(Pmtoemail.EMS_LM_Contact__c,Pmtoemail.Id);
            }
             }
    }
    
    
    @TestVisible
    private void leaveCalculateMethod(list<EMS_LM_Leave_History__c> newList,Map<Id,EMS_LM_Leave_History__c> newmap){
        set<id> setId=New set<id>();
        for(EMS_LM_Leave_History__c leaveall:newList){
            setId.add(leaveall.EMS_LM_Contact__c);
        }
        
        List<Contact> Resourceleave = [SELECT Id,EMS_LM_No_Of_Leaves_Credit__c,EMS_LM_No_Of_Availble_Leaves__c,EMS_LM_No_Of_Utilized_Leaves__c FROM Contact where Id=:setId ];
        list<EMS_LM_Leave_History__c> l1 = [select	Id, 
                                            Name,
                                            EMS_LM_Contact__r.EMS_LM_No_Of_Availble_Leaves__c,
                                            EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c,
                                            EMS_LM_Leave_Duration__c,
                                            EMS_LM_Status__c 
                                            From EMS_LM_Leave_History__c 
                                            where EMS_LM_Contact__c=:setId 
                                            And CreatedDate = This_Year 
                                            AND (EMS_LM_Status__c=: LeaveRequestConstant.PENDING
                                                 OR EMS_LM_Status__c =: LeaveRequestConstant.APPROVED 
                                                 OR EMS_LM_Status__c=: LeaveRequestConstant.APPROVER_2_WAITING
                                                 OR EMS_LM_Status__c=: LeaveRequestConstant.APPROVER_3_WAITING
                                                 OR EMS_LM_Status__c=: LeaveRequestConstant.AUTO_APPROVED)];
        
        //AND (EMS_LM_Leave_Type_Name__c = 'Annual Leave' OR EMS_LM_Leave_Type_Name__c ='Compensatory Off')
        
        List<Contact> conlist = new List<Contact> ();
        Decimal Utilized_Leaves=0;
        Decimal utilizedcompoffLeave = 0;
        Decimal utilizedMaternityLeave = 0;
        Decimal utlilizedfloatleaves=0;
        Decimal utilizedPaternityLeave = 0;
        Decimal utilizedBereavementLeave = 0;
        Decimal utilizedLossOfPay = 0;
        Decimal utilizedWorkfromhome = 0;
        Decimal utilizedMarriageLeave = 0;
        for(EMS_LM_Leave_History__c l2 : l1){
            
            if((l2.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c == LeaveRequestConstant.ANNUAL_LEAVE || l2.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c == LeaveRequestConstant.PAID_TIMEOFF )&& l2.EMS_LM_Leave_Duration__c !=Null  && 
               (l2.EMS_LM_Status__c== LeaveRequestConstant.PENDING || l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVED  || 
                l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_2_WAITING|| l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_3_WAITING ||
                l2.EMS_LM_Status__c== LeaveRequestConstant.AUTO_APPROVED))
            {
                Utilized_Leaves = Utilized_Leaves + l2.EMS_LM_Leave_Duration__c;
            } 
            if(l2.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c == 'Compensatory Off' && l2.EMS_LM_Leave_Duration__c !=Null && (l2.EMS_LM_Status__c==LeaveRequestConstant.PENDING || 
                                                                                                                            l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVED || 
                                                                                                                            l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_2_WAITING||
                                                                                                                            l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_3_WAITING ||
                                                                                                                            l2.EMS_LM_Status__c== LeaveRequestConstant.AUTO_APPROVED))
            {
                utilizedcompoffLeave = utilizedcompoffLeave + l2.EMS_LM_Leave_Duration__c;
            }
            if(l2.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c == 'Maternity Leave' && l2.EMS_LM_Leave_Duration__c !=Null && (l2.EMS_LM_Status__c==LeaveRequestConstant.PENDING || 
                                                                                                                           l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVED || 
                                                                                                                           l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_2_WAITING||
                                                                                                                           l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_3_WAITING ||
                                                                                                                           l2.EMS_LM_Status__c== LeaveRequestConstant.AUTO_APPROVED))
            {
                utilizedMaternityLeave = utilizedMaternityLeave + l2.EMS_LM_Leave_Duration__c;
            }
            //Paternity Leave
            if(l2.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c == 'Paternity Leave' && l2.EMS_LM_Leave_Duration__c !=Null && (l2.EMS_LM_Status__c==LeaveRequestConstant.PENDING || 
                                                                                                                           l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVED || 
                                                                                                                           l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_2_WAITING||
                                                                                                                           l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_3_WAITING ||
                                                                                                                           l2.EMS_LM_Status__c== LeaveRequestConstant.AUTO_APPROVED))
            {
                utilizedPaternityLeave = utilizedPaternityLeave + l2.EMS_LM_Leave_Duration__c;
            }
            
            if(l2.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c == 'Bereavement Leave' && l2.EMS_LM_Leave_Duration__c !=Null && (l2.EMS_LM_Status__c==LeaveRequestConstant.PENDING || 
                                                                                                                             l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVED || 
                                                                                                                             l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_2_WAITING||
                                                                                                                             l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_3_WAITING ||
                                                                                                                             l2.EMS_LM_Status__c== LeaveRequestConstant.AUTO_APPROVED))
            {
                utilizedBereavementLeave = utilizedBereavementLeave + l2.EMS_LM_Leave_Duration__c;
            }
            
            if((l2.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c == LeaveRequestConstant.LOSS_OF_PAY ||l2.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c == LeaveRequestConstant.UNPAID_TIMEOFF) && l2.EMS_LM_Leave_Duration__c !=Null && (l2.EMS_LM_Status__c==LeaveRequestConstant.PENDING || 
                                                                                                                                          l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVED || 
                                                                                                                                          l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_2_WAITING ||
                                                                                                                                          l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_3_WAITING ||
                                                                                                                                          l2.EMS_LM_Status__c== LeaveRequestConstant.AUTO_APPROVED))
            {
                utilizedLossOfPay = utilizedLossOfPay + l2.EMS_LM_Leave_Duration__c;
            }
            
            if(l2.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c == LeaveRequestConstant.WORK_FROM_HOME && l2.EMS_LM_Leave_Duration__c !=Null && (l2.EMS_LM_Status__c==LeaveRequestConstant.PENDING || 
                                                                                                                                             l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVED || 
                                                                                                                                             l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_2_WAITING||
                                                                                                                                             l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_3_WAITING ||
                                                                                                                                             l2.EMS_LM_Status__c== LeaveRequestConstant.AUTO_APPROVED))
            {
                utilizedWorkfromhome = utilizedWorkfromhome + l2.EMS_LM_Leave_Duration__c;
                
            } 
            if(l2.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c == 'Marriage Leave' && l2.EMS_LM_Leave_Duration__c !=Null && (l2.EMS_LM_Status__c==LeaveRequestConstant.PENDING || 
                                                                                                                                             l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVED || 
                                                                                                                                             l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_2_WAITING||
                                                                                                                                             l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_3_WAITING ||
                                                                                                                                             l2.EMS_LM_Status__c== LeaveRequestConstant.AUTO_APPROVED))
            {
                utilizedMarriageLeave = utilizedMarriageLeave + l2.EMS_LM_Leave_Duration__c;
                
            }
            
            if(l2.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c == 'Floating Holiday' && l2.EMS_LM_Leave_Duration__c!=Null && (l2.EMS_LM_Status__c==LeaveRequestConstant.PENDING || 
                                                                                                                                            l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVED || 
                                                                                                                                             l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_2_WAITING||
                                                                                                                                             l2.EMS_LM_Status__c==LeaveRequestConstant.APPROVER_3_WAITING ||
                                                                                                                                             l2.EMS_LM_Status__c== LeaveRequestConstant.AUTO_APPROVED)){
                utlilizedfloatleaves=utlilizedfloatleaves+l2.EMS_LM_Leave_Duration__c;
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
            	con.EMS_LM_No_of_Utilized_Marriage_Leave__c = utilizedMarriageLeave;
                con.UtlizedFloatLeaves__c =  utlilizedfloatleaves;
                        conlist.add(con); 
        }
        try{
             if(conlist.size()>0){
            update conlist;
        }
        }catch(exception ex){
            system.debug('LeaveCalculateHandler exception'+ex);
            newList[0].adderror(ex.getMessage().substring(115, 200));
            
        }     
    }
}