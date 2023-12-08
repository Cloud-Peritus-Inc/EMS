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
    public static List<String> getLeaveType(Id userid, decimal annualavailable) {
        system.debug('the annualavailabe leave are:-'+annualavailable);
        system.debug('the userid  is:-'+userid);
        List<String> s = new List<String>();
        
        
        if(userid !=null){
            user u =[Select id, ContactId, contact.EMS_RM_ApplicantStatus_Update__c, Email,contact.Work_Location__c,contact.UtlizedFloatLeaves__c from user where id =: userid];
            try{         
                if(u.ContactId !=null){ // if contact Id is not null we will retrieve the data using User contact Id
                     set<String> i = new set<String>();
                    List<EMS_LM_Leave_Credit__c> i1 = new List<EMS_LM_Leave_Credit__c>();
                    if(annualavailable>=-4){
                        if(u.contact.EMS_RM_ApplicantStatus_Update__c == 'Notice Period'){
                            i1 = [SELECT Leave_Type_Name__c
                          FROM EMS_LM_Leave_Credit__c
                          WHERE Leave_Type_Name__c !=: LeaveRequestConstant.WORK_FROM_HOME AND Leave_Available__c!=0 
                          		AND EMS_LM_Leave_Credited_Date__c = THIS_YEAR AND EMS_LM_Employee__c = :u.ContactId 
                          ORDER BY Leave_Type_Name__c ASC];
                        }else{
                            i1 = [SELECT Leave_Type_Name__c
                          FROM EMS_LM_Leave_Credit__c
                          WHERE Leave_Type_Name__c !=: LeaveRequestConstant.WORK_FROM_HOME AND Leave_Type_Name__c !=: LeaveRequestConstant.LOSS_OF_PAY AND Leave_Available__c!=0 
                          		AND EMS_LM_Leave_Credited_Date__c = THIS_YEAR AND EMS_LM_Employee__c = :u.ContactId 
                          ORDER BY Leave_Type_Name__c ASC];
                        }
                        
                    }else{
                        i1 = [SELECT Leave_Type_Name__c
                          FROM EMS_LM_Leave_Credit__c
                          WHERE Leave_Type_Name__c !=: LeaveRequestConstant.WORK_FROM_HOME AND Leave_Available__c!=0 
                          		AND EMS_LM_Leave_Credited_Date__c = THIS_YEAR AND EMS_LM_Employee__c = :u.ContactId 
                          ORDER BY Leave_Type_Name__c ASC];
                    }
                   
                    
                    for(EMS_LM_Leave_Credit__c i2:i1){
                        i.add(i2.Leave_Type_Name__c);
                    }
                    for(String s1 : i){
                        s.add(s1);
                    }
                    Id WORKLOCATION_USA_ID =[select Id, Name From Office_Location__c WHERE Name='California - USA' LIMIT 1].Id;
                    
                    if(u.contact.Work_Location__c == WORKLOCATION_USA_ID){
                        s.add('UnPaid time off');
                        s.add('Floating Holiday');
                    }
                       Integer indexToRemove = s.indexOf('Floating Holiday');
                        if (indexToRemove != -1 && u.contact.UtlizedFloatLeaves__c >= 1) {
                                 s.remove(indexToRemove);
                            }
                    
                    /*Integer indexToRemove1 = s.indexOf('Annual Leave');
                        if (indexToRemove1 != -1 && u.contact.EMS_RM_ApplicantStatus_Update__c =='Active - Probation') {
                                 s.remove(indexToRemove1);
                            } */
                    
                    
                }
                else{ //if contact Id is null(For Org Users(Like Sys Admin Profiles)) we will retrieve the data using User Email which is mapped to contact as Official Email
                    set<String> i = new set<String>();
                    List<EMS_LM_Leave_Credit__c> i1 = new List<EMS_LM_Leave_Credit__c>();
                    contact c = [Select Id from contact where Email=:u.Email AND EMS_TM_User__c = :userid];
                    i1 = [SELECT Leave_Type_Name__c
                          FROM EMS_LM_Leave_Credit__c
                          WHERE Leave_Type_Name__c !=: LeaveRequestConstant.WORK_FROM_HOME AND Leave_Available__c!=0 
                          AND EMS_LM_Leave_Credited_Date__c = THIS_YEAR AND EMS_LM_Employee__c = :c.Id ORDER BY Leave_Type_Name__c ASC];
                    for(EMS_LM_Leave_Credit__c i2:i1){
                        i.add(i2.Leave_Type_Name__c);
                    }
                    for(String s1 : i){
                        s.add(s1);
                    }
                }   
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
        }
        return s;       
    }
    
    // This method is used to get the leave type
    @AuraEnabled(Cacheable=true)
    public static EMS_LM_Leave__c getLeaveTypeid(string leavetype){
        EMS_LM_Leave__c el = [select Id,EMS_LM_Leave_Type__c from EMS_LM_Leave__c where EMS_LM_Leave_Type__c = :leavetype LIMIT 1];
        return el;
    }
    

    
    
    // this method is used get the location of that current logged in employee to check the Organization wide holidays of that Location   
    @AuraEnabled(Cacheable=true)
    public static Contact getbilling(Id userid){
        Contact cnt = new Contact();
        
        if(userid !=null){
            user u =[Select id, ContactId, Email from user where id = :userid];
            try{
                if(u.ContactId !=null){
                    cnt = [select Id,EMS_Employee_Type__c, EMS_TM_In_Billing__c,Work_Location__r.Country__c from Contact where Id = :u.ContactId Limit 1];       
                }
                else{
                    cnt = [select Id,EMS_TM_In_Billing__c,EMS_Employee_Type__c,Work_Location__r.Country__c from Contact  where Email=:u.Email AND EMS_TM_User__c = :userid Limit 1];
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
                           EMS_LM_No_Of_Available_Maternity_Leave__c,EMS_LM_No_of_Available_Marriage_Leave__c, EMS_LM_No_Of_Available_Paternity_Leave__c,UtlizedFloatLeaves__c,
                           EMS_LM_No_Of_Availble_Leaves__c from Contact where Id = :u.ContactId Limit 1];         
                }
                else{
                    cnt = [select Id, EMS_LM_No_Of_Available_Bereavement_Leave__c,Email, UtlizedFloatLeaves__c,EMS_LM_No_Of_Available_Compensatory_Off__c,
                           EMS_LM_No_Of_Available_Maternity_Leave__c,EMS_LM_No_of_Available_Marriage_Leave__c, EMS_LM_No_Of_Available_Paternity_Leave__c,
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
        Database.insert(e,true);
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
   
    @AuraEnabled(Cacheable=true)
    public static Decimal getExperienceOfUser(Id userId) {
    Decimal monthsSinceJoin = 0; 
    
    User userDetails = [SELECT Id, ContactId FROM User WHERE Id = :userId];
    system.debug('userDetails=============================='+userDetails);
    if (userDetails != null && userDetails.ContactId != null) {
        Contact conDetails = [SELECT Id, EMS_EM_JD__c FROM Contact WHERE Id = :userDetails.ContactId AND Work_Location_Country__c = 'United States of America' LIMIT 1];
        system.debug('conDetails=============================='+conDetails);
        
            Date startDate = conDetails.EMS_EM_JD__c;
            //Date currentDate = Date.today();
            
            monthsSinceJoin = startDate.monthsBetween(system.today());
        
    }
    
    return monthsSinceJoin;
}


}