import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createTheGoals from '@salesforce/apex/myGoalsController.createTheGoals';
export default class Kratable extends NavigationMixin(LightningElement) {
@api tab;
@api tabledata = [];
@api resourceid = '';
selectedKraQuaterly;
@track mode;
  @track iconName = "utility:chevrondown";
     @track iconParentName = "utility:chevronright";
connectedCallback() {
   console.log('====resourceid==='+JSON.stringify(this.resourceid));
   console.log('====tab==='+ this.tab);
}
 @track showKRAViewModal = false;
 @track showKRAEditModal = false;
@track showGoalModal = false;
@track showGoalCreationModal = false;
myVal = '';

 hideKRAViewModalBox() {  
        this.showKRAViewModal = false;
        
    }

    showKRAViewModalBox() { 
         this.showKRAViewModal = true; 
    }

    hideKRAEditModalBox() {  
        this.showKRAEditModal = false;
        
    }

    showKRAEditModalBox() { 
         this.showKRAEditModal = true; 
    }

    hideGoalModalBox() {  
        this.showGoalModal = false;
        
    }

    showGoalModalBox() { 
         this.showGoalModal = true; 
    }

    hideGoalCreateModalBox() {  
        this.showGoalCreationModal = false;
        this.myVal = '';
        this.goalname = '';
        this.descri = '';
        this.goalstartdate = null;
        this.goalenddate = null;
        
    }

    showGoalCreateModalBox() { 
         this.showGoalCreationModal = true; 
    }


 // display/hide the nested content
    handleContactChild(event){
        let node = event.currentTarget.dataset.id;
        let childNode = this.template.querySelector(`tr[data-parentid="${node}"]`);
        if(childNode.classList.contains('hideContent')){
            childNode.classList.remove('hideContent');
            this.template.querySelector(`lightning-icon[data-id="${node}"]`).iconName = this.iconName;

        }else{
            childNode.classList.add('hideContent');
            this.template.querySelector(`lightning-icon[data-id="${node}"]`).iconName = this.iconParentName;
        }    
    }

handleGaolClick(event){
     let node = event.currentTarget.dataset.id; 
     this.selectedKraQuaterly = node;
     console.log('==node===='+node);
     this.showGoalModalBox();
}
selectedFulfilment = '';
handleGoalCreateClick(event){
     let node = event.currentTarget.dataset.id;
     this.selectedFulfilment = node;
     this.showGoalCreateModalBox();
}

handleConNavClick(event){
     let node = event.currentTarget.dataset.id; 
     this.selectedKraQuaterly = node;
     this.mode = 'View';
       console.log('==node===='+node);
       this.showKRAViewModalBox();
}

    handleConNavEditClick(event){
     let node = event.currentTarget.dataset.id; 
     this.selectedKraQuaterly = node;
     this.mode = 'Edit';
       console.log('==node===='+node);
       this.showKRAEditModalBox();
    }

    handleNavClick(event){
       let node = event.currentTarget.dataset.id; 
       console.log('==node===='+node);
       this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: node,
                        objectApiName: 'Fulfillment__c',
                        actionName: 'view'
                    }
     });
    }


      handlegoalview(event){
        console.log('===event.currentTarget.dataset.id====='+event.currentTarget.dataset.id);
      }

      handleNavTozoomClick(event){
       let node = event.currentTarget.dataset.id; 
       var url = new URL( 'https://app.zoominfo.com/#/apps/profile/company/' + node +'/overview');
      this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url.href

            },
        });
       
    }


handledescChange(event) {
        this.myVal = event.target.value;
    }
goalstartdate;
goalenddate;
goalname;

handleGoalNameChange(event){
this.goalname = event.target.value;
}
handleGoalStartChange(event){
this.goalstartdate = event.target.value;
}
handleGoalEndChange(event){
this.goalenddate = event.target.value;
}
    createTheGoal(){
     
     var todaysDate = new Date();
     var givenDate = new Date(this.goalstartdate);
     if(!this.goalname){
       const evt = new ShowToastEvent({
            //title: 'Toast Error',
            message: 'Goal Name is required',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
     }else if(!this.goalstartdate){
       const evt = new ShowToastEvent({
            //title: 'Toast Error',
            message: 'Goal Start Date is required',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
     }else if(!this.goalenddate){
       const evt = new ShowToastEvent({
            //title: 'Toast Error',
            message: 'Goal End Date is required',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
     }else if(!this.myVal){
       const evt = new ShowToastEvent({
            //title: 'Toast Error',
            message: 'Description is required',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
     }else if(this.goalstartdate > this.goalenddate) {
        const evt = new ShowToastEvent({
            //title: 'Toast Error',
            message: 'Start date should be less than end date',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

     } else if(givenDate < todaysDate) {
         const evt = new ShowToastEvent({
            //title: 'Toast Error',
            message: 'Start Date should be in future.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt); 
     } else {
        console.log('selectedFulfilment ' + this.selectedFulfilment);
        console.log('resourceRTId ' + this.resourceid);
        console.log('name ' + this.goalname);
        console.log('startdate ' + this.goalstartdate);
        console.log('enddate ' + this.goalenddate);
        console.log('descri ' + this.myVal);
      createTheGoals({
            fulfilmentId : this.selectedFulfilment,
            resourceRTId: this.resourceid,
            name: this.goalname,
            startdate : this.goalstartdate,
            enddate : this.goalenddate,
            descri:this.myVal
        }).then(res => {
            const evt = new ShowToastEvent({
            //title: 'success',
            message: 'Successfully logged the goal. Make sure to finish the goal with in-time.',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        this.showGoalCreationModal = false;
        this.myVal = '';
        this.goalname = '';
        this.descri = '';
        this.goalstartdate = null;
        this.goalenddate = null;
        }).catch(err => {
             const evt = new ShowToastEvent({
            //title: 'Toast Error',
            message: 'Some thing went wrong...'+JSON.stringify(err.message),
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

        }); 
     }


    }

}