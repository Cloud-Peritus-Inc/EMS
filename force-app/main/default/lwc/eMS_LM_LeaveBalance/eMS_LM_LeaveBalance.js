import { LightningElement, wire, api, track } from 'lwc';
  import u_Id from '@salesforce/user/Id';
  import getLeaveBalance from '@salesforce/apex/EMS_LM_LeaveBalance.getLeaveBalance';

  import { refreshApex } from '@salesforce/apex';
  import { createMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
  import MY_REFRESH_CHANNEL from '@salesforce/messageChannel/refreshothercomponent__c';
  export default class EMS_LM_LeaveBalance extends LightningElement {

    uId = u_Id;
    @track areDetailsVisible=false;
    @track workid;
    @track worklocation;
    foruspaidtimeofftemplate=false;
    @track allLeaves;
    @track No_of_Avilable_floatLeaves__c;
    @track MaternityAvailable;
    @track MaternityUtilized;
    @track PaternityAvailable;
    @track PaternityUtilized;
    @track AnnualAvailable;
    @track AnnualUtilized;
    @track BereavementAvailable;
    @track BereavementUtilized;
    @track CompensatoryAvailable;
    @track CompensatoryUtilized;
    @track UtlizedFloatLeaves__c;
    @track lossOfPayAvailable;
    @track lossOfPayUtilized;
    @track EmployeeType;
     @track contractEmployees;
    LossofPaydetailsVisible=false;
    PaidTimeOffLeaveContent='Paid time-off  (also known as Annual leave) permits an employee to take time off from work for personal reasons. Every month, 1.25 Annual leaves get credited to the leave balance.';
    @track annualLeaveContent = 'Annual leave (also known as Paid time-off) permits an employee to take time off from work for personal reasons. Every month, 1.67 Annual leaves get credited to the leave balance.';
    @track compensatoryLeaveContent = 'If an employee has to work on a weekend or a holiday due to the priority of the deliverables, they are offered a Compensatory Off on any other workday.';
    @track bereavementLeaveContent = 'Bereavement leave permits employees to take time off from work when there is a death in the family or losing a loved one.';
    @track maternityLeaveContent = 'Maternity Leave permits female employees to take time off from work for birthing employees. In order to utilize and enable Maternity Leave,  the female applicant should drop an email to the Human Resource (HR) department. It is suggested to apply for leave 8 weeks prior to the Leave Start Date.';
    @track paternityLeaveContent = 'Paternity Leave permits male employees to take time off from work for expectant fathers. It is suggested to apply for leave 2 Days prior to the Leave Start Date.';
    @track lossOfPayLeaveContent = 'There are cases when an employee has exhausted all leave balance but still requires time-off for some exigency. In such situations, companies allow them to go on leave without pay (LWP).';
    @track floatleavecontent= 'A floating holiday is a paid day off that each employee can decide when to take.';
    leavebalanceResult;

    @wire(getLeaveBalance, { userid: '$uId' }) wiredltype(result) {
      this.leavebalanceResult = result;
      if (result.data) {
              console.log('result.data=========================================================: ',result.data);

        //$uId '0058M000000niaWQAQ'
        this.MaternityAvailable = result.data.EMS_LM_No_Of_Available_Maternity_Leave__c;
        this.MaternityUtilized = result.data.EMS_LM_No_Of_Utilized_Maternity_Leaves__c;
        this.PaternityAvailable = result.data.EMS_LM_No_Of_Available_Paternity_Leave__c;
        this.PaternityUtilized = result.data.No_Of_Utilized_Paternity_Leaves__c;
        this.AnnualAvailable = result.data.EMS_LM_No_Of_Availble_Leaves__c;
        this.AnnualUtilized = result.data.EMS_LM_No_Of_Utilized_Leaves__c;
        this.BereavementAvailable = result.data.EMS_LM_No_Of_Available_Bereavement_Leave__c;
        this.BereavementUtilized = result.data.EMS_LM_No_Of_Utilized_Bereavement_Leaves__c;
        this.CompensatoryAvailable = result.data.EMS_LM_No_Of_Available_Compensatory_Off__c;
        this.CompensatoryUtilized = result.data.EMS_LM_No_OF_Utilized_Compensatory_Off__c;
        this.No_of_Avilable_floatLeaves__c=result.data.No_of_Avilable_floatLeaves__c;
        //this.lossOfPayAvailable = result.data.EMS_LM_No_Of_Available_Compensatory_Off__c;
        this.lossOfPayUtilized = result.data.EMS_LM_No_Of_Utilized_Loss_Of_Pay__c;
        this.UtlizedFloatLeaves__c=result.data.UtlizedFloatLeaves__c;
        this.worklocation=result.data.Work_Location__r.Name;
        this.workid=result.data.Work_Location__c;
        this.EmployeeType=result.data.EMS_Employee_Type__c;
                  console.log('      this.workid=========================================================: ',this.workid);

            console.log('this.worklocation=========================================================: ',this.worklocation);
            console.log('this employee type is*****',this.EmployeeType);
            if(this.worklocation==='California - USA'){
            
            this.areDetailsVisible=true;
            this.foruspaidtimeofftemplate=true;
            this.forUsunpaidtimeofftemplate=true;
           
            }else{
             this.areDetailsVisible=false;
             this.foruspaidtimeofftemplate=false;
             this.forUsunpaidtimeofftemplate=false;
             }
             if(this.lossOfPayUtilized >0){
               this.LossofPaydetailsVisible=true;
             }else{
               this.LossofPaydetailsVisible=false;
             }
              if(this.EmployeeType=='Contract'){
               this.contractEmployees=true;
               
             }else{
               this.contractEmployees=false;
               
             }
             
        //console.log('this.allLeaves: ',this.allLeaves);
        this.error = undefined;
        this.handleRefresh();
      } else if (result.error) {
        this.error = result.error;
        this.lOptions = undefined;
      }
    }
    


    handleRefresh() {
      const refreshEvent = new CustomEvent('refresh', {
        bubbles: true
      });
      this.dispatchEvent(refreshEvent);
    }

    // for refresh using LMS
    subscription = null;

    connectedCallback() {
      const messageContext = createMessageContext();
      this.subscription = subscribe(messageContext, MY_REFRESH_CHANNEL, (message) => {
        this.handleRefreshMessage(message);
      });
    }

    disconnectedCallback() {
      unsubscribe(this.subscription);
      this.subscription = null;
    }

    handleRefreshMessage(message) {
      if (message.refresh) {
        refreshApex(this.leavebalanceResult);
      }
    }

  }