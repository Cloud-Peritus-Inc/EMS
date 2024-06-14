public with sharing class SessionUtil {

    @AuraEnabled(cacheable=true)
     public static String getSessionId() {
      return UserInfo.getSessionId();
    }
  }