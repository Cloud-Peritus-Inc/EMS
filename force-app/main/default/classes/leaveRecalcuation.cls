public class leaveRecalcuation {
 public static void availableLeaveBalanceCalculation(List<EMS_LM_Leave_Credit__C> lcc){
          List<Contact> clu = new List<Contact> ();
          for(EMS_LM_Leave_Credit__C lc : lcc){
              Decimal availableAnnualLeave = 0;
              Decimal availablecompoffLeave = 0;
              List<EMS_LM_Leave_Credit__C> l1 = new List<EMS_LM_Leave_Credit__C>();
              Contact c = new Contact();
              try{
                  c = [Select Id, EMS_LM_No_of_Bereavement_Leaves_Credit__c,EMS_LM_No_Of_Compensatory_Off_Credit__c,
                      EMS_LM_No_Of_Leaves_Credit__c,EMS_LM_No_Of_Maternity_Leaves_Credit__c,EMS_LM_No_Of_Paternity_Leaves_Credit__c,
                      EMS_LM_No_Of_Utilized_Bereavement_Leaves__c,EMS_LM_No_OF_Utilized_Compensatory_Off__c,EMS_LM_No_Of_Utilized_Leaves__c,
                      EMS_LM_No_Of_Utilized_Loss_Of_Pay__c,EMS_LM_No_Of_Utilized_Maternity_Leaves__c,No_Of_Utilized_Paternity_Leaves__c
                      from Contact where Id =: lc.EMS_LM_Employee__c];
              }
              catch(Exception e){
                  system.debug(e.getMessage());
              }
              try{
                  l1 = [select Id, Name, EMS_LM_Leaves_Credited__c, EMS_LM_Select_Leave_Type__c From EMS_LM_Leave_Credit__C 
                      where EMS_LM_Employee__c=:lc.EMS_LM_Employee__c And  CreatedDate = This_Year AND 
                      (EMS_LM_Select_Leave_Type__c = 'Annual Leave' OR EMS_LM_Select_Leave_Type__c = 'Compensatory Off')];

              for(EMS_LM_Leave_Credit__C l2 : l1){
                  if(l2.EMS_LM_Select_Leave_Type__c == 'Annual Leave'){
                      availableAnnualLeave = availableAnnualLeave + l2.EMS_LM_Leaves_Credited__c;
                  }
                  if(l2.EMS_LM_Select_Leave_Type__c == 'Compensatory Off' ){
                      availablecompoffLeave = availablecompoffLeave + l2.EMS_LM_Leaves_Credited__c;
                      
                  }                    
              }  
}
              catch(Exception e){
                  system.debug(e.getMessage());
    }
 }
 }
}