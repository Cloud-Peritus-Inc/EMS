@isTest
public class batchLauncherControllerTest {
    
    public static testMethod void mytestmethod(){
        Test.startTest();
        String jobId =  batchLauncherController.executeBatch('BatchToCalculateTheAvailableLeaves',200);
        batchLauncherController.getJobDetails(jobId);
        batchLauncherController.getExistingBatchDetails();
        Test.stopTest();
    }
    
     public static testMethod void mytestmethod2(){
         try{
        Test.startTest();
          String jobId =  batchLauncherController.executeBatch('populateApproverDetails',200);
        batchLauncherController.getJobDetails(userinfo.getUserId());
        batchLauncherController.getExistingBatchDetails();
         }catch(exception ex){
             
         }
         
        Test.stopTest();
    }
    
}