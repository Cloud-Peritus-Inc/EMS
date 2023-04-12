@isTest
public class batchLauncherControllerTest {
    
     public static testMethod void mytestmethod(){
        Test.startTest();
       String jobId =  batchLauncherController.executeBatch('BatchToCalculateTheAvailableLeaves',200);
       batchLauncherController.getJobDetails(jobId);
       batchLauncherController.getExistingBatchDetails();
        Test.stopTest();
    }

}