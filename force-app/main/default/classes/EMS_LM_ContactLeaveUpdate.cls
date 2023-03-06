/**
* @author Sangharsh Kamble
* @date 24/01/2023
* @description Class for Creating leave request from community.
*
*               Test code coverage provided by the following test class: 
*               - EMS_LM_ContactLeaveUpdate_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
Public without sharing class EMS_LM_ContactLeaveUpdate {
// This method is used to get the Leave types of Leve Credit records of of particular loggedin Employee
   @AuraEnabled(Cacheable=true)
   public static List<String> getLeaveType(Id userid) {
   List<String> s = new List<String>();
   if(userid !=null){
      user u =[Select id, ContactId, Email from user where id =: userid];
      try{         
   if(u.ContactId !=null){ // if contact Id is not null we will retrieve the data using User contact Id
   set<String> i = new set<String>();
   List<EMS_LM_Leave_Credit__c> i1 = new List<EMS_LM_Leave_Credit__c>();
   i1 = [SELECT Leave_Type_Name__c
               FROM EMS_LM_Leave_Credit__c
               WHERE Leave_Type_Name__c !=: LeaveRequestConstant.WORK_FROM_HOME AND EMS_LM_Employee__c = :u.ContactId ORDER BY Leave_Type_Name__c ASC];
               for(EMS_LM_Leave_Credit__c i2:i1){
                  i.add(i2.Leave_Type_Name__c);
               }
   for(String s1 : i){
      s.add(s1);
   }
 
   
   }
else{ //if contact Id is null(For Org Users(Like Sys Admin Profiles)) we will retrieve the data using User Email which is mapped to contact as Official Email
   set<String> i = new set<String>();
   List<EMS_LM_Leave_Credit__c> i1 = new List<EMS_LM_Leave_Credit__c>();
   contact c = [Select Id from contact where Email=:u.Email AND EMS_TM_User__c = :userid];
   i1 = [SELECT Leave_Type_Name__c
               FROM EMS_LM_Leave_Credit__c
               WHERE Leave_Type_Name__c !=: LeaveRequestConstant.WORK_FROM_HOME AND EMS_LM_Employee__c = :c.Id ORDER BY Leave_Type_Name__c ASC];
               for(EMS_LM_Leave_Credit__c i2:i1){
                  i.add(i2.Leave_Type_Name__c);
               }
               for(String s1 : i){
                  s.add(s1);
               }
   /*List<EMS_LM_Leave__c> l = new List<EMS_LM_Leave__c>();
   l = [select Id, EMS_LM_Leave_Type__c from EMS_LM_Leave__C where id IN : i ];
   for(EMS_LM_Leave__c lt : l){
      s.add(lt.EMS_LM_Leave_Type__c);
   }*/
   }   
   }
   catch(Exception e){
      system.debug(e.getMessage());
   }
   }
      return s;

}
    
    @AuraEnabled(Cacheable=true)
    public static EMS_LM_Leave__c getLeaveTypeid(string leavetype){
        EMS_LM_Leave__c el = [select Id from EMS_LM_Leave__c where EMS_LM_Leave_Type__c = :leavetype LIMIT 1];
        return el;
    }
    
// This method is used to get the leave history of particular loggedin Employee
@AuraEnabled(Cacheable=true)
   public static List<EMS_LM_Leave_History__c> getLeaveHistory(String stdate, String eddate, String status, String type){
      List<EMS_LM_Leave_History__c> lh = new List<EMS_LM_Leave_History__c>();
      String query = 'Select Id, EMS_LM_Leave_Type_Name__c,EMS_LM_Leave_Start_Date__c,EMS_LM_Final_Approver__c,' + 
      'EMS_LM_Leave_End_Date__c,EMS_LM_Leave_Duration__c,EMS_LM_Reason__c,EMS_LM_Status__c,EMS_LM_Approved_On__c,EMS_LM_Contact__R.Name From EMS_LM_Leave_History__c ';
      String userId = UserInfo.getUserId();
      user u =[Select id, ContactId, Email from user where id = :userId];
      string cid = '';
      if(u.ContactId != null){// if contact Id is not null we will retrieve the data using User contact Id
          cid = u.ContactId;
         query = query + ' where EMS_LM_Contact__c = :cid ';
      }
      if(u.ContactId == null){//if contact Id is null(For Org Users(Like Sys Admin Profiles)) we will retrieve the data using User Email which is mapped to contact as Official Email
         Contact c = [select Id from Contact where Email=:u.Email AND EMS_TM_User__c = :userId Limit 1];
         cid = c.Id;
          query = query + ' where EMS_LM_Contact__c = :cid ';    
      }
      if(stdate !='' && stdate != null){// this will check whether start date is null/blank or not if it has value wuery will update with start date
         Date d = date.valueOf(stdate);
         query = query + ' AND EMS_LM_Leave_Start_Date__c >= :d';    
      }
      if(eddate !='' && eddate != null){//this will check whether end date is null/blank or not if it has value wuery will update with endt date
         Date d1 = date.valueOf(eddate);
         query = query + ' AND EMS_LM_Leave_End_Date__c <= :d1';
      } 
      if(Status !='' && Status != null){//this will check whether Status is null/blank or not if it has value wuery will update with Status
         query = query + ' AND EMS_LM_Status__c = :Status';
      } 
      if(type !='' && type != null){//this will check whether Leave Type is null/blank or not if it has value wuery will update with Leave Type
        query = query + ' AND EMS_LM_Leave_Type_Name__c = :type';
      }
      system.debug(query);  
      query = query + ' ORDER BY CreatedDate DESC Limit 5'; 
      try{ 
         lh = Database.query(query);
         system.debug(lh);
      }
      catch(Exception e){
         system.debug(e.getMessage());
      }    
      return lh;  
}


// this method is used get the location of that current logged in employee to check the Organization wide holidays of that Location   
    @AuraEnabled(Cacheable=true)
   public static Contact getbilling(Id userid){
       Contact cnt = new Contact();
      
      if(userid !=null){
      user u =[Select id, ContactId, Email from user where id = :userid];
      try{
         if(u.ContactId !=null){
            cnt = [select Id, EMS_TM_In_Billing__c,Work_Location__r.Country__c from Contact where Id = :u.ContactId Limit 1];       
         }
         else{
            cnt = [select Id,EMS_TM_In_Billing__c,Work_Location__r.Country__c from Contact  where Email=:u.Email AND EMS_TM_User__c = :userid Limit 1];
         }
      }
      catch (Exception e){
         system.debug(e.getMessage());
      }
       
      }   
      return cnt; 
}

// this method is used to get the profile assigned to current loggedin User to show the Admin View
   @AuraEnabled(Cacheable=true)
   public static String getProfileName(Id userid){
      String profileName = '';
      if(userid !=null){
         try{
            user u =[Select id, ProfileId from user where id =: userid];
            Profile p = [Select Name from Profile where id=:u.ProfileId];
            profileName = p.name;
         }
         catch(Exception e){
            system.debug(e.getMessage());
         }         
      }
      return profileName;
   }

   // this method is used to get the current Available leave balance of loggedin User
   @AuraEnabled(Cacheable=true)
   public static Contact getLeaveBalance(Id userid){
      Contact cnt = new Contact();
      if(userid !=null){
         try{
            user u =[Select id, ContactId, Email from user where id =: userid];
            if(u.ContactId !=null){
               cnt = [select Id, EMS_LM_No_Of_Available_Bereavement_Leave__c, Email , EMS_LM_No_Of_Available_Compensatory_Off__c,
               EMS_LM_No_Of_Available_Maternity_Leave__c, EMS_LM_No_Of_Available_Paternity_Leave__c,
               EMS_LM_No_Of_Availble_Leaves__c from Contact where Id = :u.ContactId Limit 1];         
            }
            else{
               cnt = [select Id, EMS_LM_No_Of_Available_Bereavement_Leave__c,Email, EMS_LM_No_Of_Available_Compensatory_Off__c,
               EMS_LM_No_Of_Available_Maternity_Leave__c, EMS_LM_No_Of_Available_Paternity_Leave__c,
               EMS_LM_No_Of_Availble_Leaves__c from Contact where Email=:u.Email AND EMS_TM_User__c = :userid Limit 1];
            }
         }
         catch(Exception e){
            system.debug(e.getMessage());
         }         
      }
      return cnt;      
   }
   //this method is used to get user info of current logged in user
   @AuraEnabled(Cacheable=true)
   public static User getUserInfo(Id userid){
      user u =[Select id, ContactId, Email from user where id = :userid]; 
      return u;   
   }  

   // this method is used to get the leave request to approve or reject of the current loggedin User
   @AuraEnabled(Cacheable=true)
   public static List<EMS_LM_Leave_History__c> getPendingLeaveHistory(String name,String stdate, String eddate, String status){
      List<EMS_LM_Leave_History__c> lh = new List<EMS_LM_Leave_History__c>();
      String query = 'Select Id, EMS_LM_Leave_Type_Name__c,EMS_LM_Leave_Start_Date__c,EMS_LM_Final_Approver__c,' + 
      'EMS_LM_Leave_End_Date__c,EMS_LM_Leave_Duration__c,EMS_LM_Reason__c,EMS_LM_Status__c,EMS_LM_Approved_On__c,EMS_LM_Contact__R.Name From EMS_LM_Leave_History__c ';
      String userId = UserInfo.getUserId();
      user u =[Select id, ContactId, Email from user where id = :userId];
      string cid = '';
      if(u.Id != null){
          cid = u.Id;
         query = query + ' where (EMS_LM_Approver__c = :cid OR EMS_LM_2nd_Approver__c = :cid) ';
      }
      system.debug(query); 
      if(stdate !='' && stdate != null){
         Date d = date.valueOf(stdate);
         query = query + ' AND EMS_LM_Leave_Start_Date__c >= :d';    
      }
      system.debug(query); 
      if(eddate !='' && eddate != null){
         Date d1 = date.valueOf(eddate);
         query = query + ' AND EMS_LM_Leave_End_Date__c <= :d1';
      } 
      system.debug(query); 
      if(Status !='' && Status != null){
         query = query + ' AND EMS_LM_Status__c = :Status';
      } 
      system.debug(query); 
      if(name !='' && name != null){  
        String name1 = '%'+name+'%';
        system.debug(name1);
        query = query + ' AND EMS_LM_Contact__R.Name Like \'%' + name + '%\'';
      }
         query = query + ' ORDER BY CreatedDate DESC';

         system.debug(query);      
      try{ 
         lh = Database.query(query);
         system.debug(lh);
      }
      catch(Exception e){
         system.debug(e.getMessage());
      }    
      return lh;  
}
//this method is used to get the all Leave Hidtory records in the company to show in Admin View
@AuraEnabled(Cacheable=true)
   public static List<EMS_LM_Leave_History__c> getAdminLeaveHistory(String employeeName, String startDate, String endDate, List<String> typeValues, List<String> statusValues){
      List<EMS_LM_Leave_History__c> leaveHistories = new List<EMS_LM_Leave_History__c>();
      String query = 'Select Id, EMS_LM_Leave_Type_Name__c, EMS_LM_Leave_Start_Date__c, EMS_LM_Final_Approver__c, ' + 
      'EMS_LM_Leave_End_Date__c, EMS_LM_Leave_Duration__c, EMS_LM_Reason__c, EMS_LM_Status__c, EMS_LM_Approved_On__c, EMS_LM_Contact__R.Name, EMS_LM_Current_Approver__c From EMS_LM_Leave_History__c';
      system.debug(query); 
      if(startDate != '' && startDate != null){
         Date startDateValue = Date.valueOf(startDate);
         query = query + ' WHERE EMS_LM_Leave_Start_Date__c >= :startDateValue';    
      }
      system.debug(query); 
      if(endDate != '' && endDate != null){
         Date endDateValue = Date.valueOf(endDate);
          if (query.contains('WHERE')) {
            query = query + ' AND EMS_LM_Leave_End_Date__c <= :endDateValue';  
          }else {
            query = query + ' WHERE EMS_LM_Leave_End_Date__c <= :endDateValue';  
          }   
      }
       
       system.debug(query);
       Set<String> allowedStatusValues = new Set<String>{'Pending', 'Approver 1 pending', 'Approver 2 Pending', 'Approved', 'Rejected', 'Cancelled', 'Auto Approved'};
    	if (!allowedStatusValues.containsAll(statusValues)) {
        query = query;
        System.debug('### statusValues null' + statusValues);
    	} else if (query.contains('WHERE')) {
        query += ' AND EMS_LM_Status__c IN :statusValues';
        System.debug('## here statusValues ' + query);
    }else {
       query += ' WHERE EMS_LM_Status__c IN :statusValues'; 
    }

    Set<String> allowedTypeValues = new Set<String>{'Annual Leave', 'Work from Home', 'Loss of Pay', 'Paternity Leave', 'Bereavement Leave', 'Maternity Leave', 'Compensatory Off'};
    if (!allowedTypeValues.containsAll(typeValues)) {
        query = query;
    } else if(query.contains('WHERE')) {
        query += ' AND EMS_LM_Leave_Type_Name__c IN :typeValues ';
        System.debug('## here typeValues ' + query);
    }else {
       query += ' WHERE EMS_LM_Leave_Type_Name__c IN :typeValues'; 
    }
      system.debug(query); 

           if (employeeName != null && employeeName != '') {  
        String employeeNameWithWildcards = '%' + employeeName + '%';
        if (query.contains('WHERE')) {
            query += ' AND EMS_LM_Contact__R.Name LIKE :employeeNameWithWildcards';
        }else {
           	query += ' WHERE EMS_LM_Contact__R.Name LIKE :employeeNameWithWildcards'; 
        }
    }
      query = query + ' ORDER BY CreatedDate DESC';
      system.debug(query);      
      try{ 
         leaveHistories = Database.query(query);
         system.debug(leaveHistories);
      }
      catch(Exception e){
         system.debug(e.getMessage());
      }    
      return leaveHistories;  
}
    

    @AuraEnabled(Cacheable=true)
    public static List<EMS_LM_Leave_History__c> defaultAdminViewData () {
        List<EMS_LM_Leave_History__c> adminViewData = [Select Id, 
                                                       		  EMS_LM_Leave_Type_Name__c,
                                                              EMS_LM_Leave_Start_Date__c,
                                                              EMS_LM_Final_Approver__c, 
      														  EMS_LM_Leave_End_Date__c,
                                                       		  EMS_LM_Leave_Duration__c,
                                                              EMS_LM_Reason__c,EMS_LM_Status__c,
                                                              EMS_LM_Approved_On__c,
                                                              EMS_LM_Contact__R.Name 
                                                       From EMS_LM_Leave_History__c
                                                       WHERE (EMS_LM_Status__c =: LeaveRequestConstant.PENDING
                                                       OR EMS_LM_Status__c =: LeaveRequestConstant.APPROVER_2_WAITING)
                                                       ORDER BY CreatedDate DESC Limit 5
                                                       ];
        System.debug('### adminViewData ' + adminViewData);
        return adminViewData;
    }

// this methodis used to create leave history record when employee submits the leave request
@AuraEnabled
    Public static Id createLHRecord(String cId, Decimal duration, String stDate, String edDate, String type, String reason , String day)  
    {       
     // EMS_LM_Leave__c el = new EMS_LM_Leave__c();
      EMS_LM_Leave__c el = [select Id from EMS_LM_Leave__c where EMS_LM_Leave_Type__c = :type LIMIT 1];
      EMS_LM_Leave_History__c e = new EMS_LM_Leave_History__c();
      Date sd = date.valueOf(stDate);
      Date ed = date.valueOf(edDate);
      e.EMS_LM_Contact__c = cId ;
      e.EMS_LM_Leave_Duration__c = duration;
      e.EMS_LM_Leave_End_Date__c = ed;
      e.EMS_LM_Leave_Start_Date__c = sd;
      e.EMS_LM_Leave_Type_Name__c = type;
      e.EMS_LM_Status__c=LeaveRequestConstant.PENDING;
      e.EMS_LM_Reason__c = reason;
      e.EMS_LM_Day__c = day;
      if(el != null){
         e.EMS_LM_Leave_Type__c = el.Id ;
      }
      Database.insert(e);
      Id i = e.Id;
      system.debug(i);
      return i;      
    } 
    
    // this methodis used to create leave history(for work from home) record when employee submits the leave request
@AuraEnabled
    Public static Id createwfhRecord(String cId, Decimal duration, String stDate, String edDate, String reason )  
    {
        
      EMS_LM_Leave__c el = new EMS_LM_Leave__c();
      el = [select Id from EMS_LM_Leave__c where EMS_LM_Leave_Type__c = :LeaveRequestConstant.WORK_FROM_HOME LIMIT 1];
      EMS_LM_Leave_History__c e = new EMS_LM_Leave_History__c();
      Date sd = date.valueOf(stDate);
      Date ed = date.valueOf(edDate);
        
      e.EMS_LM_Contact__c = cId ;
      e.EMS_LM_Leave_Duration__c = duration;
      e.EMS_LM_Leave_End_Date__c = ed;
      e.EMS_LM_Leave_Start_Date__c = sd;
      e.EMS_LM_Leave_Type_Name__c = LeaveRequestConstant.WORK_FROM_HOME;
      e.EMS_LM_Status__c=LeaveRequestConstant.PENDING;
      e.EMS_LM_Reason__c = reason;
      e.EMS_LM_Day__c = 'Full Day';
      if(el != null){
         e.EMS_LM_Leave_Type__c = el.Id ;
      }
      Database.insert(e);
      Id i = e.Id;
      system.debug(i);
      return i;      
    } 
    
    @AuraEnabled
   public static String uploadFile(String base64, String filename, String recordId) {
         system.debug(base64 + filename + recordId);
         ContentVersion cv = createContentVersion(base64, filename);   
         ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
         if (cv == null || cdl == null) { return null; }
         return cdl.Id;
   }
   /*
    * @method createContentVersion() [private]
    * @desc Creates a content version from a given file's base64 and name
    * 
    * @param {String} base64 - base64 string that represents the file
    * @param {String} filename - full file name with extension, i.e. 'products.csv'
    * 
    * @return {ContentVersion} - returns the newly created ContentVersion, or null
    *   if there was an error inserting the record
    */
   @testVisible
   private static ContentVersion createContentVersion(String base64, String filename) {
     system.debug(base64 + filename);
     ContentVersion cv = new ContentVersion();
     cv.VersionData = EncodingUtil.base64Decode(base64);
     cv.Title = filename;
     cv.PathOnClient = filename;
     try {
       insert cv;
       return cv;
     } catch(DMLException e) {
       System.debug(e);
       return null;
     }
   }
 
    /*
    * @method createContentLink() [private]
    * @desc Creates a content link for a given ContentVersion and record
    * 
    * @param {String} contentVersionId - Id of the ContentVersion of the file
    * @param {String} recordId - Id of the record you want to attach this file to
    * 
    * @return {ContentDocumentLink} - returns the newly created ContentDocumentLink, 
    *   or null if there was an error inserting the record
    */
    @testVisible
   private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
      system.debug(contentVersionId + recordId);
               if (contentVersionId == null || recordId == null) { return null; }
               
     ContentDocumentLink cdl = new ContentDocumentLink();
     cdl.ContentDocumentId = [SELECT ContentDocumentId 
       FROM ContentVersion 
       WHERE Id =: contentVersionId
     ].ContentDocumentId;
     cdl.LinkedEntityId = recordId;
     // ShareType is either 'V', 'C', or 'I'
     // V = Viewer, C = Collaborator, I = Inferred
     cdl.ShareType = 'V';
     try {
       insert cdl;
       return cdl;
     } catch(DMLException e) {
       System.debug(e);
       return null;
     }
}
}