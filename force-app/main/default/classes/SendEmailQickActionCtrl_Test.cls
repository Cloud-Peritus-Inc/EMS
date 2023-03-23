@istest
public class SendEmailQickActionCtrl_Test {
    @istest
    public static void  testmethod1(){
        SendEmailQickActionCtrl s= new SendEmailQickActionCtrl();
        if(Test.isRunningTest()){
            s.email='example@cp.com';
            s.fullName = 'Test user';
            s.ccEmail = 'example@cp.com';
            s.bccEmail = 'example@cp.com';
        }
        s.sendOnBoardingEmail();
    }
}