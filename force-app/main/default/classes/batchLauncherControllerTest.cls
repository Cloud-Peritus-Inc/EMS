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
        Test.startTest();
          String jobId =  batchLauncherController.executeBatch('populateApproverDetails',200);
        batchLauncherController.getJobDetails(userinfo.getUserId());
        batchLauncherController.getExistingBatchDetails();
         
        Test.stopTest();
    }
    
}