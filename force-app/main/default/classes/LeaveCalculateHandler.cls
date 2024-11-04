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
        private static Boolean hasExecuted = false;
    public void afterInsert(List<EMS_LM_Leave_History__c> newList) {      
        leaveCalculateMethod(newList,null);
                for(EMS_LM_Leave_History__c Pmtoemail:newList){
                    if(!hasExecuted){
            if(Pmtoemail.EMS_LM_Status__c=='auto approved'){
                Pmtogetmail.getemails(Pmtoemail.EMS_LM_Contact__c,Pmtoemail.Id);
            }
                }
             }
    }
    
    public void afterUpdate(List<EMS_LM_Leave_History__c> newList,List<EMS_LM_Leave_History__c> oldList) {      
        leaveCalculateMethod(newList,new Map<Id,EMS_LM_Leave_History__c>(oldList));
        for(EMS_LM_Leave_History__c Pmtoemail:newList){
            if(!hasExecuted){
            if(Pmtoemail.EMS_LM_Status__c=='approved'){
                Pmtogetmail.getemails(Pmtoemail.EMS_LM_Contact__c,Pmtoemail.Id);
            }
            }
             }
    }
    
    //@sangharsh @shubham 23/Sep/2024 optimized code for bulk leave approval duration calculation issue for different contacts(Resource)
    // issue raised on 23/Sep/2024
   /* @TestVisible
    private void leaveCalculateMethod(list<EMS_LM_Leave_History__c> newList,Map<Id,EMS_LM_Leave_History__c> newmap){
        set<id> setId=New set<id>();
        Map<Id,list<EMS_LM_Leave_History__c>> conMap =New Map<Id,list<EMS_LM_Leave_History__c>>();
        for(EMS_LM_Leave_History__c leaveall:newList){
            setId.add(leaveall.EMS_LM_Contact__c);          
            
            if(!conMap.containskey(leaveall.EMS_LM_Contact__c)){
                conMap.put(leaveall.EMS_LM_Contact__c,new list<EMS_LM_Leave_History__c>());
            }
            
        }
        
        List<Contact> Resourceleave = [SELECT Id,EMS_LM_No_Of_Leaves_Credit__c,EMS_LM_No_Of_Availble_Leaves__c,EMS_LM_No_Of_Utilized_Leaves__c FROM Contact where Id=:setId ];
        list<EMS_LM_Leave_History__c> l1 = [select	Id, 
                                            Name,
                                            EMS_LM_Contact__r.EMS_LM_No_Of_Availble_Leaves__c,
                                            EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c,
                                            EMS_LM_Leave_Duration__c,
                                            EMS_LM_Status__c,EMS_LM_Leave_End_Date__c,CreatedDate 
                                            From EMS_LM_Leave_History__c 
                                            where EMS_LM_Contact__c=:setId  
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
        Integer thisYear = System.today().year();
		Integer nextYear = thisYear + 1;

        for(EMS_LM_Leave_History__c l2 : l1){
            system.debug('This_YearDate-->'+thisYear);
            system.debug('l2.EMS_LM_Leave_End_Date__c'+l2.EMS_LM_Leave_End_Date__c);
            if((l2.EMS_LM_Leave_End_Date__c.year() == thisYear && l2.CreatedDate.year() == thisYear) || (l2.EMS_LM_Leave_End_Date__c.year() == nextYear && l2.CreatedDate.year() == thisYear) ){
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
    }*/
    
    @TestVisible
private void leaveCalculateMethod(List<EMS_LM_Leave_History__c> newList, Map<Id, EMS_LM_Leave_History__c> newMap) {
    // Step 1: Gather all contact IDs
    Set<Id> contactIds = new Set<Id>();
    for (EMS_LM_Leave_History__c leave : newList) {
        contactIds.add(leave.EMS_LM_Contact__c);
    }

    // Step 2: Query all related contacts
    List<Contact> contacts = [SELECT Id, EMS_LM_No_Of_Leaves_Credit__c, EMS_LM_No_Of_Availble_Leaves__c, EMS_LM_No_Of_Utilized_Leaves__c
                               FROM Contact
                               WHERE Id IN :contactIds];

    // Step 3: Query all leave histories and group by contact
    Map<Id, List<EMS_LM_Leave_History__c>> contactLeaveHistoryMap = new Map<Id, List<EMS_LM_Leave_History__c>>();
    List<EMS_LM_Leave_History__c> leaveHistories = [SELECT Id, EMS_LM_Contact__c, EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c,
                                                          EMS_LM_Leave_Duration__c, EMS_LM_Status__c, EMS_LM_Leave_End_Date__c,
                                                          CreatedDate
                                                    FROM EMS_LM_Leave_History__c
                                                    WHERE EMS_LM_Contact__c IN :contactIds
                                                      AND EMS_LM_Status__c IN (:LeaveRequestConstant.PENDING,
                                                                                :LeaveRequestConstant.APPROVED,
                                                                                :LeaveRequestConstant.APPROVER_2_WAITING,
                                                                                :LeaveRequestConstant.APPROVER_3_WAITING,
                                                                                :LeaveRequestConstant.AUTO_APPROVED)];

    // Group leave histories by Contact Id
    for (EMS_LM_Leave_History__c leaveHistory : leaveHistories) {
        if (!contactLeaveHistoryMap.containsKey(leaveHistory.EMS_LM_Contact__c)) {
            contactLeaveHistoryMap.put(leaveHistory.EMS_LM_Contact__c, new List<EMS_LM_Leave_History__c>());
        }
        contactLeaveHistoryMap.get(leaveHistory.EMS_LM_Contact__c).add(leaveHistory);
    }

    // Step 4: Initialize a list to update contacts later
    List<Contact> contactsToUpdate = new List<Contact>();

    // Step 5: Process each contact's leave history
    Integer thisYear = System.today().year();
    Integer nextYear = thisYear + 1;

    for (Contact contact : contacts) {
        Decimal utilizedLeaves = 0;
        Decimal utilizedCompOff = 0;
        Decimal utilizedMaternityLeave = 0;
        Decimal utilizedPaternityLeave = 0;
        Decimal utilizedBereavementLeave = 0;
        Decimal utilizedLossOfPay = 0;
        Decimal utilizedWorkFromHome = 0;
        Decimal utilizedMarriageLeave = 0;
        Decimal utilizedFloatLeaves = 0;

        // Fetch leave histories for the contact
        List<EMS_LM_Leave_History__c> contactLeaves = contactLeaveHistoryMap.get(contact.Id);

        if (contactLeaves != null) {
for (EMS_LM_Leave_History__c leave : contactLeaves) {
    if ((leave.EMS_LM_Leave_End_Date__c.year() == thisYear && leave.CreatedDate.year() == thisYear)
        || (leave.EMS_LM_Leave_End_Date__c.year() == nextYear && leave.CreatedDate.year() == thisYear)) {

        String leaveType = leave.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c;

        if (leave.EMS_LM_Leave_Duration__c != null) {
            // Replace the switch with if-else statements
            if (leaveType == LeaveRequestConstant.ANNUAL_LEAVE || leaveType == LeaveRequestConstant.PAID_TIMEOFF) {
                utilizedLeaves += leave.EMS_LM_Leave_Duration__c;
            } else if (leaveType == 'Compensatory Off') {
                utilizedCompOff += leave.EMS_LM_Leave_Duration__c;
            } else if (leaveType == 'Maternity Leave') {
                utilizedMaternityLeave += leave.EMS_LM_Leave_Duration__c;
            } else if (leaveType == 'Paternity Leave') {
                utilizedPaternityLeave += leave.EMS_LM_Leave_Duration__c;
            } else if (leaveType == 'Bereavement Leave') {
                utilizedBereavementLeave += leave.EMS_LM_Leave_Duration__c;
            } else if (leaveType == LeaveRequestConstant.LOSS_OF_PAY || leaveType == LeaveRequestConstant.UNPAID_TIMEOFF) {
                utilizedLossOfPay += leave.EMS_LM_Leave_Duration__c;
            } else if (leaveType == LeaveRequestConstant.WORK_FROM_HOME) {
                utilizedWorkFromHome += leave.EMS_LM_Leave_Duration__c;
            } else if (leaveType == 'Marriage Leave') {
                utilizedMarriageLeave += leave.EMS_LM_Leave_Duration__c;
            } else if (leaveType == 'Floating Holiday') {
                utilizedFloatLeaves += leave.EMS_LM_Leave_Duration__c;
            }
        }
    }
}
        }

        // Update contact's utilized leave fields
        contact.EMS_LM_No_Of_Utilized_Leaves__c = utilizedLeaves;
        contact.EMS_LM_No_OF_Utilized_Compensatory_Off__c = utilizedCompOff;
        contact.EMS_LM_No_Of_Utilized_Maternity_Leaves__c = utilizedMaternityLeave;
        contact.No_Of_Utilized_Paternity_Leaves__c = utilizedPaternityLeave;
        contact.EMS_LM_No_Of_Utilized_Bereavement_Leaves__c = utilizedBereavementLeave;
        contact.EMS_LM_No_Of_Utilized_Loss_Of_Pay__c = utilizedLossOfPay;
        contact.No_OF_Utilized_Work_from_Home__c = utilizedWorkFromHome;
        contact.EMS_LM_No_of_Utilized_Marriage_Leave__c = utilizedMarriageLeave;
        contact.UtlizedFloatLeaves__c = utilizedFloatLeaves;

        contactsToUpdate.add(contact);
    }

    // Step 6: Perform bulk update
    if (!contactsToUpdate.isEmpty()) {
        try {
            update contactsToUpdate;
        } catch (Exception ex) {
            System.debug('LeaveCalculateHandler exception: ' + ex);
            if (!newList.isEmpty()) {
                newList[0].addError('Error: ' + ex.getMessage());
            }
        }
    }
}
    
}