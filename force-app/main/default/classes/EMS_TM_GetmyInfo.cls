public class EMS_TM_GetmyInfo {
        @AuraEnabled(cacheable=true)
public static contact getUserContactInfo(Id userId){
    //  id userid = userinfo.getUserId();
   // System.debug(userId+'uuuseerrid');
    user u =[Select id,name,Contactid from user where id =: userId  AND Contactid != null];
    System.debug('userid'+U);
    contact contactDetails =[SELECT  LastName, FirstName, Name, EMS_RM_Industry__c, EMS_RM_Employee_Id__c,visiable_to_edit__c,
                                                EMS_RM_Domain_Technology__c,EMS_Domain_Technology__c, EMS_RM_Current_Job_Role__c,
                                            EMS_Phone_Number__c,EMS_RM_Resource_Email_id__c  FROM Contact where id =: u.contactid];

      return contactDetails;

}
    
     @AuraEnabled(cacheable=true)
    public static ems_EM_Additional_Detail__c getContactAdditionalInfo(String getContactid){     
       
        if(getContactid!=Null){
            ems_EM_Additional_Detail__c onboardAdditionallist=[SELECT Id,EMS_EM_Job_Title5__c, EMS_EM_Degree__c, EMS_EM_Degree1__c, 
                                                           EMS_EM_Degree2__c, EMS_EM_Degree3__c, EMS_EM_Degree4__c, EMS_EM_Degree5__c,
                                                           EMS_EM_Education1__c, EMS_EM_Education2__c, EMS_EM_Education3__c, 
                                                           EMS_EM_Education4__c, EMS_EM_Education5__c, EMS_EM_Education__c, 
                                                           EMS_EM_Field_of_Study1__c, EMS_EM_Field_of_Study2__c, EMS_EM_Field_of_Study3__c, 
                                                           EMS_EM_Field_of_Study4__c, EMS_EM_Field_of_Study5__c, EMS_EM_Field_of_Study__c, 
                                                           EMS_EM_GDate2__c, EMS_EM_GDate1__c, EMS_EM_GDate3__c, EMS_EM_GDate4__c, 
                                                           EMS_EM_GDate5__c, EMS_EM_GDate__c, EMS_EM_IName1__c, EMS_EM_IName2__c, 
                                                           EMS_EM_IName3__c, EMS_EM_IName4__c, EMS_EM_IName5__c, EMS_EM_IName__c, 
                                                           EMS_EM_From_Date1__c, EMS_EM_From_Date2__c, EMS_EM_From_Date3__c, 
                                                           EMS_EM_From_Date4__c, EMS_EM_From_Date5__c, EMS_EM_From_Date__c, 
                                                           EMS_EM_Job_Title1__c, EMS_EM_Job_Title2__c, EMS_EM_Job_Title3__c, 
                                                           EMS_EM_Job_Title4__c, EMS_EM_Job_Title__c, EMS_EM_To_Date1__c, 
                                                           EMS_EM_To_Date3__c, EMS_EM_To_Date2__c, EMS_EM_To_Date4__c, EMS_EM_To_Date5__c, 
                                                           EMS_EM_To_Date__c, EMS_EM_Previous_Company_HR_EmailId__c, 
                                                           EMS_EM_Previous_Company_Name1__c, EMS_EM_Previous_Company_Name2__c,
                                                           EMS_EM_Previous_Company_Name3__c, EMS_EM_Previous_Company_Name4__c,
                                                           EMS_EM_Previous_Company_Name5__c, EMS_EM_Previous_Company_Name__c, 
                                                           Onboarding_Request__c, ContactId__c FROM ems_EM_Additional_Detail__c 
                                                           where ContactId__c=:getContactid];
            
            return onboardAdditionallist;
        }else{
            return null;
        }
        
        
    }
    
      @AuraEnabled(cacheable=true)
   public static void getUserInfo(String conId,String phone){
       list<Contact>conl=[Select Name,EMS_Phone_Number__c from Contact];
       List<Contact>conlist=new List<Contact>();
       For(Contact c:conl){
            c.Id=conId;
       c.EMS_Phone_Number__c=phone;
   
       conlist.add(c);
       }
     Contact c=new Contact();
     
     
      
       update conlist;
        
   }
    
 
}