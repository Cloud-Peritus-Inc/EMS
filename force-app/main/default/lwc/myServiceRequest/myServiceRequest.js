import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import u_Id from '@salesforce/user/Id';
import getPendingCases from '@salesforce/apex/MyServiceRequest.getCaseData';
import updateApproveStatusAndComments from '@salesforce/apex/MyServiceRequest.updateRequestAndComments';
import updateRejecteStatusAndComments from '@salesforce/apex/MyServiceRequest.updateReqRejectComments';
export default class MyServiceRequest extends NavigationMixin(LightningElement) {

  isShowModalApprove = false;
  showdata =false;
  disableButton = false;
  isLoading = false;
  isShowModalReject = false;
  errorMessage;
   @api recordId;
   @track datahistory = [];
   approveComments;
   rejectComments;
   approveLastWorkDate;
   selectedRecordApproveId;
   selectedRecordRejectId;
   lastWorkingDate;

   @wire(getPendingCases) caseData(caseResult){
       const { data, error } = caseResult; 
    this._wiredRefreshData = caseResult;
    if (data) {
      this.isLoading = false;
      this.showdata = true;
      console.log('### DATA BEFORE: ', data, this.showdata);
      if (data.length > 0) {
        console.log('### DATA AFTER: ', data);
        this.showdata = true;
        this.nodata = false;
        this.datahistory = JSON.parse(JSON.stringify(data));
      
         this.disableButton = false;
   }

}
   }
   showModalApprovalBox(event) {
    console.log('BUTTON CLICKED : ');
    console.log('### event : ', JSON.stringify(event.currentTarget.dataset));
    this.selectedRecordApproveId = event.currentTarget.dataset.id;
    console.log('### selectedRecordApproveId : ', this.selectedRecordApproveId);
    const filtered = this.datahistory.find( (obj) => {
  return ( obj.Id === this.selectedRecordApproveId) 
 
});
 console.log('(filtered);'+filtered);
     /*  var workdata = this.datahistory.map(item => return(item.id === this.selectedRecordApproveId) );
       console.log('workdata'+workdata);*/
    this.isShowModalApprove = true;
  
      
  }
   showModalRejectBox(event) {
    console.log('BUTTON CLICKED Reject: ');
    console.log('### event : ', JSON.stringify(event.currentTarget.dataset));
    console.log('### event id: ', JSON.stringify(event.currentTarget.dataset.id));
    this.selectedRecordRejectId = event.currentTarget.dataset.id;
    console.log('### selectedRecordRejectId : ', this.selectedRecordRejectId);
    this.isShowModalReject = true;

  }
    handleCloseAll() {
    this.isShowModalApproveAll = false;
    this.isShowModalRejectAll = false;
    this.isShowModalApprove = false;
    this.isShowModalReject = false;
  }
   handleApproveComments(event) {
    this.approveComments = event.target.value;
    console.log('approveComments'+this.approveComments);
  }

  approveLastWorkingDate(event){
      this.approveLastWorkDate =event.target.value;
     console.log('approveLastWorkDate'+this.approveLastWorkDate);
  }

  handleApproveSave(event) {
    updateApproveStatusAndComments({ serviceRequestId: this.selectedRecordApproveId, approveComments: this.approveComments, lasworkingDate:this.approveLastWorkDate})
      .then((result) => {
        console.log('Leave Request: ', result);
        this.isShowModalApprove = false;
        const evt = new ShowToastEvent({
          message: 'Service Request was updated successfully',
          variant: 'success',
        });
        this.dispatchEvent(evt);
        return refreshApex(this._wiredRefreshData)
      }).catch((err) => {
        console.log('ERROR : ', err);
      });
  }

   handleRejectComments(event) {
    if (event.target.value) {
      this.errorMessage = '';
      this.rejectComments = event.target.value;
       console.log('rejectComments'+this.rejectComments);
    } else {
      this.errorMessage = 'Please enter the comments';
    }

  }
  handleRejectSave(event) {
    console.log('### selectedRecordRejectId : ', this.selectedRecordRejectId);

    if (this.template.querySelector('lightning-textarea').reportValidity()) {
      updateRejecteStatusAndComments({ serviceRequestId: this.selectedRecordRejectId, approveComments: this.rejectComments })
        .then((result) => {
          console.log('Service Request: ', result);
          this.isShowModalReject = false;
          const evt = new ShowToastEvent({
            message: 'Leave Request was rejected successfully',
            variant: 'success',
          });
          this.dispatchEvent(evt);
          return refreshApex(this._wiredRefreshData)
        }).catch((err) => {
          console.log('ERROR : ', err);
        });
    }
  }

  handlConClick(event) {
    let selectCon = event.currentTarget.dataset.id;
    console.log('### selectCon : ', selectCon);
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: selectCon,
        objectApiName: 'Case',
        actionName: 'view',
      },
    });
  }

}