public class EMS_EM_Additional_Details_Handler {
    public static void updateOnboardObjectFromAdditionalDetails(List<ems_EM_Additional_Detail__c>addioanalList){
        Set<Id> additionalId  =  new Set<Id>();
        Set<Id> onboardingId  =   new Set<Id>();
        For(ems_EM_Additional_Detail__c addionalDetail:addioanalList)
        {
            additionalId.add(addionalDetail.Id);
            onboardingId.add(addionalDetail.Onboarding_Request__c);
            
        }
        
          List<ems_EM_Additional_Detail__c>additionalDetailsList=[Select Id,Onboarding_Request__c,EMS_EM_Education__c,EMS_EM_Education1__c,EMS_EM_Education2__c,EMS_EM_Education3__c,
                                                                  EMS_EM_Education4__c,EMS_EM_Education5__c,EMS_EM_Degree__c,EMS_EM_Degree1__c,EMS_EM_Degree2__c,EMS_EM_Degree3__c,EMS_EM_Degree4__c,EMS_EM_Degree5__c,
                                                                  EMS_EM_IName__c,EMS_EM_IName1__c,EMS_EM_IName2__c,EMS_EM_IName3__c,EMS_EM_IName4__c,EMS_EM_IName5__c,
                                                                  EMS_EM_Field_of_Study__c,EMS_EM_Field_of_Study1__c,EMS_EM_Field_of_Study2__c,EMS_EM_Field_of_Study3__c,EMS_EM_Field_of_Study4__c,EMS_EM_Field_of_Study5__c,
                                                                  EMS_EM_GDate__c,EMS_EM_GDate1__c,EMS_EM_GDate2__c,EMS_EM_GDate3__c,EMS_EM_GDate4__c,EMS_EM_GDate5__c,
                                                                  EMS_EM_Job_Title__c,EMS_EM_Job_Title1__c,EMS_EM_Job_Title2__c,EMS_EM_Job_Title3__c,EMS_EM_Job_Title4__c,EMS_EM_Job_Title5__c,
                                                                  EMS_EM_Previous_Company_Name__c,EMS_EM_Previous_Company_Name1__c,EMS_EM_Previous_Company_Name2__c,EMS_EM_Previous_Company_Name3__c,EMS_EM_Previous_Company_Name4__c,EMS_EM_Previous_Company_Name5__c,
                                                                  EMS_EM_From_Date__c,EMS_EM_From_Date1__c,EMS_EM_From_Date2__c,EMS_EM_From_Date3__c,EMS_EM_From_Date4__c,EMS_EM_From_Date5__c,
                                                                  EMS_EM_To_Date__c,EMS_EM_To_Date1__c,EMS_EM_To_Date2__c,EMS_EM_To_Date3__c,EMS_EM_To_Date4__c,EMS_EM_To_Date5__c,
                                                                  EMS_EM_Previous_Company_HR_EmailId__c
                                                                  FROM ems_EM_Additional_Detail__c 
                                                                  WHERE Id=:additionalId 
                                                                  AND Onboarding_Request__c=:onboardingId];
        
        System.debug('additionalDetailsList'+additionalDetailsList);
        
        List<EMS_EM_Onboarding_Request__c>onboardList=new List<EMS_EM_Onboarding_Request__c>();
        
        For(ems_EM_Additional_Detail__c addionalDetail:additionalDetailsList)
        {
           EMS_EM_Onboarding_Request__c onboardRequst=new EMS_EM_Onboarding_Request__c();
           onboardRequst.Id                    =    addionalDetail.Onboarding_Request__c;
           System.debug('onboardRequst.Id'+onboardRequst.Id);
           onboardRequst.EMS_EM_Education__c                     =  addionalDetail.EMS_EM_Education__c;
           onboardRequst.EMS_EM_Education1__c                    =  addionalDetail.EMS_EM_Education1__c;
           onboardRequst.EMS_EM_Education2__c                    =  addionalDetail.EMS_EM_Education2__c;
           onboardRequst.EMS_EM_Education3__c                    =  addionalDetail.EMS_EM_Education3__c;
           onboardRequst.EMS_EM_Education4__c                    =  addionalDetail.EMS_EM_Education4__c;
           onboardRequst.EMS_EM_Education5__c                    =  addionalDetail.EMS_EM_Education5__c;
           onboardRequst.EMS_EM_IName__c                         =  addionalDetail.EMS_EM_IName__c;
           onboardRequst.EMS_EM_IName1__c                        =  addionalDetail.EMS_EM_IName1__c;
           onboardRequst.EMS_EM_IName2__c                        =  addionalDetail.EMS_EM_IName2__c;
           onboardRequst.EMS_EM_IName3__c                        =  addionalDetail.EMS_EM_IName3__c;
           onboardRequst.EMS_EM_IName4__c                        =  addionalDetail.EMS_EM_IName4__c;
           onboardRequst.EMS_EM_IName5__c                        =  addionalDetail.EMS_EM_IName5__c;
           onboardRequst.EMS_EM_Field_of_Study__c                =  addionalDetail.EMS_EM_Field_of_Study__c;
           onboardRequst.EMS_EM_Field_of_Study1__c               =  addionalDetail.EMS_EM_Field_of_Study1__c;
           onboardRequst.EMS_EM_Field_of_Study2__c               =  addionalDetail.EMS_EM_Field_of_Study2__c;
           onboardRequst.EMS_EM_Field_of_Study3__c               =  addionalDetail.EMS_EM_Field_of_Study3__c;
           onboardRequst.EMS_EM_Field_of_Study4__c               =  addionalDetail.EMS_EM_Field_of_Study4__c;
           onboardRequst.EMS_EM_Field_of_Study5__c               =  addionalDetail.EMS_EM_Field_of_Study5__c;
           onboardRequst.EMS_EM_Degree__c                        =  addionalDetail.EMS_EM_Degree__c;
           onboardRequst.EMS_EM_Degree1__c                       =  addionalDetail.EMS_EM_Degree1__c;
           onboardRequst.EMS_EM_Degree2__c                       =  addionalDetail.EMS_EM_Degree2__c;
           onboardRequst.EMS_EM_Degree3__c                       =  addionalDetail.EMS_EM_Degree3__c;
           onboardRequst.EMS_EM_Degree4__c                       =  addionalDetail.EMS_EM_Degree4__c;
           onboardRequst.EMS_EM_Degree5__c                       =  addionalDetail.EMS_EM_Degree5__c;
           onboardRequst.EMS_EM_GDate__c                         =  addionalDetail.EMS_EM_GDate__c;
           onboardRequst.EMS_EM_GDate1__c                        =  addionalDetail.EMS_EM_GDate1__c;
           onboardRequst.EMS_EM_GDate2__c                        =  addionalDetail.EMS_EM_GDate2__c;
           onboardRequst.EMS_EM_GDate3__c                        =  addionalDetail.EMS_EM_GDate3__c;
           onboardRequst.EMS_EM_GDate4__c                        =  addionalDetail.EMS_EM_GDate4__c;
           onboardRequst.EMS_EM_GDate5__c                        =  addionalDetail.EMS_EM_GDate5__c;
           onboardRequst.EMS_EM_Job_Title__c                     =  addionalDetail.EMS_EM_Job_Title__c;
           onboardRequst.EMS_EM_Job_Title1__c                    =  addionalDetail.EMS_EM_Job_Title1__c;
           onboardRequst.EMS_EM_Job_Title2__c                    =  addionalDetail.EMS_EM_Job_Title2__c;
           onboardRequst.EMS_EM_Job_Title3__c                    =  addionalDetail.EMS_EM_Job_Title3__c;
           onboardRequst.EMS_EM_Job_Title4__c                    =  addionalDetail.EMS_EM_Job_Title4__c;
           onboardRequst.EMS_EM_Job_Title5__c                    =  addionalDetail.EMS_EM_Job_Title5__c;
           onboardRequst.EMS_EM_Previous_Company_Name__c         =  addionalDetail.EMS_EM_Previous_Company_Name__c;
           onboardRequst.EMS_EM_Previous_Company_Name1__c        =  addionalDetail.EMS_EM_Previous_Company_Name1__c;
           onboardRequst.EMS_EM_Previous_Company_Name2__c        =  addionalDetail.EMS_EM_Previous_Company_Name2__c;
           onboardRequst.EMS_EM_Previous_Company_Name3__c        =  addionalDetail.EMS_EM_Previous_Company_Name3__c;
           onboardRequst.EMS_EM_Previous_Company_Name4__c        =  addionalDetail.EMS_EM_Previous_Company_Name4__c;
           onboardRequst.EMS_EM_Previous_Company_Name5__c        =  addionalDetail.EMS_EM_Previous_Company_Name5__c;
           onboardRequst.EMS_EM_Previous_Company_HR_EmailId__c   =  addionalDetail.EMS_EM_Previous_Company_HR_EmailId__c;
           onboardRequst.EMS_EM_From_Date__c                     =  addionalDetail.EMS_EM_From_Date__c;
           onboardRequst.EMS_EM_From_Date1__c                    =  addionalDetail.EMS_EM_From_Date1__c;
           onboardRequst.EMS_EM_From_Date2__c                    =  addionalDetail.EMS_EM_From_Date2__c;
           onboardRequst.EMS_EM_From_Date3__c                    =  addionalDetail.EMS_EM_From_Date3__c;
           onboardRequst.EMS_EM_From_Date4__c                    =  addionalDetail.EMS_EM_From_Date4__c;
           onboardRequst.EMS_EM_From_Date5__c                    =  addionalDetail.EMS_EM_From_Date5__c;
           onboardRequst.EMS_EM_To_Date__c                       =  addionalDetail.EMS_EM_To_Date__c;
           onboardRequst.EMS_EM_To_Date1__c                      =  addionalDetail.EMS_EM_To_Date1__c;
           onboardRequst.EMS_EM_To_Date2__c                      =  addionalDetail.EMS_EM_To_Date2__c;
           onboardRequst.EMS_EM_To_Date3__c                      =  addionalDetail.EMS_EM_To_Date3__c;
           onboardRequst.EMS_EM_To_Date4__c                      =  addionalDetail.EMS_EM_To_Date4__c;
           onboardRequst.EMS_EM_To_Date5__c                      =  addionalDetail.EMS_EM_To_Date5__c;

           onboardList.add(onboardRequst);

            
        }
        
        if(onboardList.size()>0)
        {
            update onboardList;
        }
    }

}