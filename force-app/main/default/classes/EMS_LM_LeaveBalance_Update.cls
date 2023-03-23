public without sharing class EMS_LM_LeaveBalance_Update {
    //EMS_LM_Status__c = 'Approver 1 Pending' OR EMS_LM_Status__c = 'Pending' OR EMS_LM_Status__c = 'Approved' OR EMS_LM_Status__c = 'Approver 2 Pending'
    //c.EMS_LM_No_Of_Maternity_Leaves_Credit__c =  c.EMS_LM_No_Of_Maternity_Leaves_Credit__c -  + l4.EMS_LM_Leave_Duration__c ;
     // this method is called in Leave Credit trigger to calculate available leave balnce of the employee   ----- need to bulkify this code 
     public static void availableLeaveBalanceCalculation(List<EMS_LM_Leave_Credit__C> lcc){
        //  List<EMS_LM_Leave_Credit__C> l = new List<EMS_LM_Leave_Credit__C>();
          List<Contact> clu = new List<Contact> ();
          for(EMS_LM_Leave_Credit__C lc : lcc){
              Decimal availableAnnualLeave = 0;
              Decimal availablecompoffLeave = 0;
              Decimal availablePaternityLeave = 0;
              Decimal availableMaternityLeave = 0;
              Decimal availableBereavementLeave = 0; 
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
              try{
                  List<EMS_LM_Leave_Credit__C> l3 = new List<EMS_LM_Leave_Credit__C>();
              l3 = [select Id, Name, EMS_LM_Leaves_Credited__c, EMS_LM_Select_Leave_Type__c From EMS_LM_Leave_Credit__C 
                     where EMS_LM_Employee__c=:lc.EMS_LM_Employee__c AND (EMS_LM_Select_Leave_Type__c = 'Maternity Leave' OR 
                     EMS_LM_Select_Leave_Type__c = 'Bereavement Leave' OR EMS_LM_Select_Leave_Type__c = 'Loss of Pay'
                     OR EMS_LM_Select_Leave_Type__c = 'Paternity Leave')];
              for(EMS_LM_Leave_Credit__C l4 : l3){
                  if(l4.EMS_LM_Select_Leave_Type__c == 'Maternity Leave'){
                      
                      availableMaternityLeave = availableMaternityLeave + l4.EMS_LM_Leaves_Credited__c;
                      
                  }
                  if(l4.EMS_LM_Select_Leave_Type__c == 'Bereavement Leave'){
                      availableBereavementLeave = availableBereavementLeave + l4.EMS_LM_Leaves_Credited__c;
                      
                  }
                  if(l4.EMS_LM_Select_Leave_Type__c =='Paternity Leave'){
                      availablePaternityLeave = availablePaternityLeave + l4.EMS_LM_Leaves_Credited__c;
                      
                  }
                  // if(l1.EMS_LM_Select_Leave_Type__c == 'Loss of Pay'){// not required for credit
                      
                  // }              
              }  
              } 
              catch(Exception e){
                  system.debug(e.getMessage());
              }  
              if(c != null){
              c.EMS_LM_No_of_Bereavement_Leaves_Credit__c = availableBereavementLeave;
              c.EMS_LM_No_Of_Compensatory_Off_Credit__c = availablecompoffLeave;
              c.EMS_LM_No_Of_Leaves_Credit__c = availableAnnualLeave;
              c.EMS_LM_No_Of_Maternity_Leaves_Credit__c = availableMaternityLeave;
              c.EMS_LM_No_Of_Paternity_Leaves_Credit__c = availablePaternityLeave;
              system.debug(availableBereavementLeave + 'ss' +availablecompoffLeave + 'ss'+ availableAnnualLeave);
              clu.add(c); 
              }             
              
              
          }
          if(clu.size()>0){

          }
          try{
              Update clu;
          }
          Catch(Exception e){
              system.debug(e.getMessage());
          }  
      }


      // this method is called in Leave History trigger to calculate utilized Leave balnce of the employee  ----- need to bulkify this code 
      public static void utilizedLeaveBalanceCalculation(List<EMS_LM_Leave_History__C> lhc){
          List<Contact> clu = new List<Contact> ();
          for(EMS_LM_Leave_History__C l : lhc){
             //if(l.EMS_LM_Status__c == 'Approved' || l.EMS_LM_Status__c == 'Pending' || l.EMS_LM_Status__c == 'Approver 2 Pending' || l.EMS_LM_Status__c == 'Approver 1 Pending' ){
              Decimal utilizedAnnualLeave = 0;
              Decimal utilizedLossOfPay = 0;            
              Decimal utilizedcompoffLeave = 0;
              Decimal utilizedBereavementLeave = 0;
              Decimal utilizedPaternityLeave = 0;
              Decimal utilizedMaternityLeave = 0;
              Decimal availbalupdate = 0;
              List<EMS_LM_Leave_History__C> l1 = new List<EMS_LM_Leave_History__C>();
              List<EMS_LM_Leave_History__C> l3 = new List<EMS_LM_Leave_History__C>();
                  Contact c = new Contact();
                  try{
                      c = [Select Id, EMS_LM_No_of_Bereavement_Leaves_Credit__c,EMS_LM_No_Of_Compensatory_Off_Credit__c,
                          EMS_LM_No_Of_Leaves_Credit__c,EMS_LM_No_Of_Maternity_Leaves_Credit__c,EMS_LM_No_Of_Paternity_Leaves_Credit__c,
                          EMS_LM_No_Of_Utilized_Bereavement_Leaves__c,EMS_LM_No_OF_Utilized_Compensatory_Off__c,EMS_LM_No_Of_Utilized_Leaves__c,
                          EMS_LM_No_Of_Utilized_Loss_Of_Pay__c,EMS_LM_No_Of_Utilized_Maternity_Leaves__c,No_Of_Utilized_Paternity_Leaves__c
                          from Contact where Id =: l.EMS_LM_Contact__c];
                  }
                  catch(Exception e){
                      system.debug(e.getMessage());
                  }
                  try{
                      l1 = [select Id, Name, EMS_LM_Leave_Duration__c,EMS_LM_Leave_Type_Name__c, EMS_LM_Status__c, EMS_LM_Contact__c 
                              From EMS_LM_Leave_History__C where EMS_LM_Contact__c=:l.EMS_LM_Contact__c And  CreatedDate = This_Year AND 
                              (EMS_LM_Status__c = 'Approver 1 Pending' OR EMS_LM_Status__c = 'Pending' OR EMS_LM_Status__c = 'Approved' OR EMS_LM_Status__c = 'Approver 2 Pending') 
                              AND (EMS_LM_Leave_Type_Name__c = 'Annual Leave' OR EMS_LM_Leave_Type_Name__c = 'Compensatory Off')];
  
                  for(EMS_LM_Leave_History__C l2 : l1){
                      if(l2.EMS_LM_Leave_Type_Name__c == 'Annual Leave'){
                          utilizedAnnualLeave = utilizedAnnualLeave + l2.EMS_LM_Leave_Duration__c ;
                          
                      }
                      if(l2.EMS_LM_Leave_Type_Name__c == 'Compensatory Off' ){
                          utilizedcompoffLeave = utilizedcompoffLeave + l2.EMS_LM_Leave_Duration__c ;
                          
                          
                      }                    
                  }  
  
                  }
                  catch(Exception e){
                      system.debug(e.getMessage());
                  }
                  try{
                      
                  l3 = [select Id, Name, EMS_LM_Leave_Duration__c,EMS_LM_Leave_Type_Name__c, EMS_LM_Status__c, EMS_LM_Contact__c
                          From EMS_LM_Leave_History__C where EMS_LM_Contact__c=:l.EMS_LM_Contact__c AND 
                          (EMS_LM_Status__c = 'Approver 1 Pending' OR EMS_LM_Status__c = 'Pending' OR EMS_LM_Status__c = 'Approved' OR EMS_LM_Status__c = 'Approver 2 Pending') 
                          AND (EMS_LM_Leave_Type_Name__c = 'Maternity Leave' OR EMS_LM_Leave_Type_Name__c = 'Bereavement Leave' OR 
                          EMS_LM_Leave_Type_Name__c = 'Loss of Pay' OR EMS_LM_Leave_Type_Name__c = 'Paternity Leave')];
                  for(EMS_LM_Leave_History__C l4 : l3){
                      if(l4.EMS_LM_Leave_Type_Name__c == 'Maternity Leave'){
                          utilizedMaternityLeave = utilizedMaternityLeave + l4.EMS_LM_Leave_Duration__c ;                        
                      }
                      if(l4.EMS_LM_Leave_Type_Name__c == 'Bereavement Leave'){
                          utilizedBereavementLeave = utilizedBereavementLeave + l4.EMS_LM_Leave_Duration__c ;   
                      }
                      if(l4.EMS_LM_Leave_Type_Name__c =='Paternity Leave'){
                          utilizedPaternityLeave  =  utilizedPaternityLeave + l4.EMS_LM_Leave_Duration__c ;    
                      }
                      if(l4.EMS_LM_Leave_Type_Name__c == 'Loss of Pay'){
                          utilizedLossOfPay = utilizedLossOfPay + l4.EMS_LM_Leave_Duration__c ;   
                          
                       }              
                  }  
                  } 
                  catch(Exception e){
                      system.debug(e.getMessage());
                  }  
                  if(c != null){
                  c.No_Of_Utilized_Paternity_Leaves__c = utilizedPaternityLeave;
                  c.EMS_LM_No_OF_Utilized_Compensatory_Off__c = utilizedcompoffLeave;
                  c.EMS_LM_No_Of_Utilized_Leaves__c = utilizedAnnualLeave ;
                  c.EMS_LM_No_Of_Utilized_Bereavement_Leaves__c =  utilizedBereavementLeave;
                  c.EMS_LM_No_Of_Utilized_Maternity_Leaves__c = utilizedMaternityLeave ;
                  c.EMS_LM_No_Of_Utilized_Loss_Of_Pay__c = utilizedLossOfPay ;
                  clu.add(c); 
                  }  
                  system.debug(utilizedAnnualLeave + 'ss' + utilizedcompoffLeave + 'ss' + utilizedPaternityLeave + 'ss' + utilizedBereavementLeave + 'ss' +utilizedMaternityLeave);
                  if(clu.size()>0){
                      try{
                          Update clu;
                      }
                      Catch(Exception e){
                          system.debug(e.getMessage());
                      }  
              }                
              //}
          }    
       }

}