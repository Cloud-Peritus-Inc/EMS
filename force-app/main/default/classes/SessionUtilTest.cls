@isTest
public class SessionUtilTest {
    @isTest
    static void testGetSessionId() {
        // Call the getSessionId method from SessionUtil class
        String sessionId = SessionUtil.getSessionId();
        
        // Verify that the sessionId is not null or empty
        System.assertNotEquals(null, sessionId);
        System.assertNotEquals('', sessionId);
    }
}