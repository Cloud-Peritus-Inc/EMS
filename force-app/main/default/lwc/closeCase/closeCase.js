import { LightningElement,api,wire,track } from 'lwc';
import getTheCaseDetails from '@salesforce/apex/newServiceRequestController.getTheCaseDetails';
import processTheCaseUpdate from '@salesforce/apex/newServiceRequestController.processTheCaseUpdate';
import processTheCaseTransfer from '@salesforce/apex/newServiceRequestController.processTheCaseTransfer';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
export default class CloseCase extends NavigationMixin(LightningElement) {
@api recordId;
@track disableescalte = false;
@track disableclose = false;
showescaltepopup = false;
showclosepopup = false;
showtransfer = false;
escaltereason;
closereason;
disabletransfer;
caseid;
selectedConId;

connectedCallback() {  
}

@wire(getTheCaseDetails, {caseid:'$recordId'})
    wiredCase({data, error}){
        if(data){
           this.disableclose = data.enableClose;
           this.disableescalte = data.enableEscalate; 
           this.caseid = data.caseid;
           this.disabletransfer = data.enableTransfer;
        }
        else if (error) {
            console.log('===error====='+JSON.stringify(error));
        }
}

hanldeTransgerClose(){
   this.showtransfer = false; 
}

 handleEscCancel(event) {
      this.showescaltepopup = false;
      
      this.escaltereason = '';
    }
handleCaseCancel(event) {
      this.showclosepopup = false;
      this.closereason = '';
    }

handleTransfer(){
    this.showescaltepopup = false;
   this.showclosepopup = false;
   this.showtransfer = true;

}

handleEscalte(){
   this.showescaltepopup = true;
   this.showclosepopup = false;
   this.showtransfer = false;
}

processEscalte(){
    console.log('==sss==='+this.escaltereason);
    processTheCaseUpdate({ 
            caseid : this.recordId, 
            comments : this.escaltereason, 
            isEsacalted : true
        })
        .then(result => {
            this.disableclose = result.enableClose;
           this.disableescalte = result.enableEscalate; 
           this.caseid = result.caseid;
            this.showescaltepopup = false;
             this.disabletransfer = result.enableTransfer;
            const event = new ShowToastEvent({
                title: 'Service Request Escalated',
                message: 'Escalated the case to next level support.',
                variant: 'success'
            });
            this.dispatchEvent(event);
             this.handleNaClick();
             refreshApex(this.disableclose);
             refreshApex(this.disableescalte);
        })
        .catch(error => {
            const event = new ShowToastEvent({
                title : 'Error',
                message : 'Error updating service request. Please Contact System Admin',
                variant : 'error'
            });
            this.dispatchEvent(event);
        });
}

processcaseclose(){
    console.log('==sss=closereason=='+this.closereason);
    processTheCaseUpdate({ 
            caseid : this.recordId, 
            comments : this.closereason, 
            isEsacalted : false
        })
        .then(result => {
           this.disableclose = result.enableClose;
           this.disableescalte = result.enableEscalate; 
           this.caseid = result.caseid;
            this.disabletransfer = result.enableTransfer;
            this.showclosepopup = false;
            const event = new ShowToastEvent({
                title: 'Service Request Closed',
                message: 'Succesfully Closed Service Request. Please provide the feedback on request on following email.',
                variant: 'success'
            });
            this.dispatchEvent(event);
             this.handleNaClick();
             refreshApex(this.disableclose);
             refreshApex(this.disableescalte);
        })
        .catch(error => {
            const event = new ShowToastEvent({
                title : 'Error',
                message : 'Error updating service request. Please Contact System Admin',
                variant : 'error'
            });
            this.dispatchEvent(event);
        });
}

processTransfer(){
console.log("The selected Contact id is"+this.selectedConId);
processTheCaseTransfer({ 
            caseid : this.recordId, 
            conId : this.selectedConId
        })
        .then(result => {
          
            const event = new ShowToastEvent({
                title: 'Service Request Closed',
                message: 'Succesfully Closed Service Request. Please provide the feedback on request on following email.',
                variant: 'success'
            });
            this.dispatchEvent(event);
             this.handleHomeClick();
        })
        .catch(error => {
            console.log('========ERROR===='+JSON.stringify(error));
            const event = new ShowToastEvent({
                title : 'Error',
                message : 'Error in transferring service request. Please Contact System Admin',
                variant : 'error'
            });
            this.dispatchEvent(event);
        });
}

escChange(event){
    this.escaltereason = event.target.value;
}

closeChange(event){
    this.closereason = event.target.value;
}

handleClose(){
   this.showclosepopup = true;
   this.showescaltepopup = false;
   this.showtransfer = false;
}

handleNaClick(event){
this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Case',
                actionName: 'view'
            },
         });
}

handleHomeClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/'
            }
        });
}

handleContactSelection(event){
        this.selectedConId = event.target.value;
}

}