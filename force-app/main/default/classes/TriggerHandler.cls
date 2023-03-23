/**
Class Name     : TriggerHandler
Author		 : Cloud Peritus Inc
Created Date   :
Description   	 : This is a trigger framework class which is use by all trigger
service class. ByPassing trigger and loop count can be controlled in this
framework.
*/
public
virtual class TriggerHandler {
  // static map of handlername, times run() was invoked
 private
  static Map<String, LoopCount> loopCountMap;
 private
  static Set<String> bypassedHandlers;
  // the current context of the trigger, overridable in tests
  @TestVisible private TriggerContext context;
  // the current context of the trigger, overridable in tests
  @TestVisible private Boolean isTriggerExecuting;
  // static initialization
  static {
    loopCountMap = new Map<String, LoopCount>();
    bypassedHandlers = new Set<String>();
  }

  // constructor
 public
  TriggerHandler() { this.setTriggerContext(); }

  /**
   * @description : Main method that will be called during execution
   * @param
   * @return void
   */
 public
  void run() {
    if (!validateRun()) {
      return;
    }
    addToLoopCount();
    // dispatch to the correct handler method
    switch
      on this.context {
        when BEFORE_INSERT { this.beforeInsert(); }
        when BEFORE_UPDATE { this.beforeUpdate(); }
        when BEFORE_DELETE { this.beforeDelete(); }
        when AFTER_INSERT { this.afterInsert(); }
        when AFTER_UPDATE { this.afterUpdate(); }
        when AFTER_DELETE { this.afterDelete(); }
        when AFTER_UNDELETE { this.afterUndelete(); }
      }
  }

  /**
   * @description Set maximum loop to execute in a transcation
   * @param Integer
   * @return void
   */
 public
  void setMaxLoopCount(Integer max) {
    String handlerName = getHandlerName();
    if (!TriggerHandler.loopCountMap.containsKey(handlerName)) {
      TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
    } else {
      TriggerHandler.loopCountMap.get(handlerName).setMax(max);
    }
  }

  /**
   * @description Reset/clear the loop count in the transaction
   * @param
   * @return void
   */
 public
  void clearMaxLoopCount() { this.setMaxLoopCount(-1); }

  /***
   * @description Bypass any trigger within a transaction
   * @param String
   * @return void
   */
 public
  static void bypass(String handlerName) {
    TriggerHandler.bypassedHandlers.add(handlerName);
  }

  /***
   * @description Removes a trigger from bypass list
   * @param String
   * @return void
   */
 public
  static void clearBypass(String handlerName) {
    TriggerHandler.bypassedHandlers.remove(handlerName);
  }

  /**
   * @description Checks if the provided trigger is bypassed or not
   * @param String
   * @return Boolean
   */
 public
  static Boolean isBypassed(String handlerName) {
    return TriggerHandler.bypassedHandlers.contains(handlerName);
  }

  /**
   * @description Removes/clears all the bypass triggers in a transaction
   * @param
   * @return void
   */
 public
  static void clearAllBypasses() { TriggerHandler.bypassedHandlers.clear(); }

  /**
   * @description Sets the trigger context variables
   * @param
   * @return void
   */
  @TestVisible private void setTriggerContext() {
    this.setTriggerContext(null, false);
  }

  /**
   * @description Set maximum loop to execute in a transcation
   * @param String, Boolean
   * @return void
   */
  @TestVisible private void setTriggerContext(String ctx, Boolean testMode) {
    if (!Trigger.isExecuting && !testMode) {
      this.isTriggerExecuting = false;
      return;
    } else {
      this.isTriggerExecuting = true;
    }

    if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
        (ctx != null && ctx == 'before insert')) {
      this.context = TriggerContext.BEFORE_INSERT;
    } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
               (ctx != null && ctx == 'before update')) {
      this.context = TriggerContext.BEFORE_UPDATE;
    } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
               (ctx != null && ctx == 'before delete')) {
      this.context = TriggerContext.BEFORE_DELETE;
    } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
               (ctx != null && ctx == 'after insert')) {
      this.context = TriggerContext.AFTER_INSERT;
    } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
               (ctx != null && ctx == 'after update')) {
      this.context = TriggerContext.AFTER_UPDATE;
    } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
               (ctx != null && ctx == 'after delete')) {
      this.context = TriggerContext.AFTER_DELETE;
    } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
               (ctx != null && ctx == 'after undelete')) {
      this.context = TriggerContext.AFTER_UNDELETE;
    }
  }

  /**
   * @description Increment the loop count
   * @param
   * @return void
   */
  @TestVisible private void addToLoopCount() {
    String handlerName = getHandlerName();
    if (TriggerHandler.loopCountMap.containsKey(handlerName)) {
      Boolean exceeded =
          TriggerHandler.loopCountMap.get(handlerName).increment();
      if (exceeded) {
        Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
        throw new TriggerHandlerException('Maximum loop count of ' +
                                          String.valueOf(max) + ' reached in ' +
                                          handlerName);
      }
    }
  }

  /**
   * @description Validates if the methods are called from trigger or outside
   * the trigger.
   * @param
   * @return Boolean
   */
  @TestVisible private Boolean validateRun() {
    if (!this.isTriggerExecuting || this.context == null) {
      throw new TriggerHandlerException(
          'Trigger handler called outside of Trigger execution');
    }
    return !TriggerHandler.bypassedHandlers.contains(getHandlerName());
  }

  /**
   * @description returns the handler name
   * @param
   * @return String
   */
  @TestVisible private String getHandlerName() {
    return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
  }

  /**
   * context methods
   */

  // context-specific methods for override
  @TestVisible protected virtual void beforeInsert() {
  }
  @TestVisible protected virtual void beforeUpdate() {
  }
  @TestVisible protected virtual void beforeDelete() {
  }
  @TestVisible protected virtual void afterInsert() {
  }
  @TestVisible protected virtual void afterUpdate() {
  }
  @TestVisible protected virtual void afterDelete() {
  }
  @TestVisible protected virtual void afterUndelete() {
  }

  /**
   * inner classes
   */

  // inner class for managing the loop count per handler
  @TestVisible private class LoopCount {
   private
    Integer max;
   private
    Integer count;

   public
    LoopCount() {
      this.max = 5;
      this.count = 0;
    }

   public
    LoopCount(Integer max) {
      this.max = max;
      this.count = 0;
    }

   public
    Boolean increment() {
      this.count++;
      return this.exceeded();
    }

   public
    Boolean exceeded() { return this.max >= 0 && this.count > this.max; }

   public
    Integer getMax() { return this.max; }

   public
    Integer getCount() { return this.count; }

   public
    void setMax(Integer max) { this.max = max; }
  }

  // possible trigger contexts
  @TestVisible private enum TriggerContext {
    BEFORE_INSERT,
    BEFORE_UPDATE,
    BEFORE_DELETE,
    AFTER_INSERT,
    AFTER_UPDATE,
    AFTER_DELETE,
    AFTER_UNDELETE
  }
  // exception class
  public class TriggerHandlerException extends Exception {
  }
}