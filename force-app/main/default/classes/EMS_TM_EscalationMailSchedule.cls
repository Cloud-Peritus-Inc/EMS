public class EMS_TM_EscalationMailSchedule implements Schedulable {
     public void execute(SchedulableContext ctx){
        
        EMS_TM_notifyManger nM = new EMS_TM_notifyManger();
        Database.executeBatch(nM);        
        
    }

}