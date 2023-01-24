import { LightningElement, wire, track, api } from 'lwc';
import getLeaveReqData from '@salesforce/apex/LeaveRequestApexController.getLeaveReqData';
import bulkLeaveReqApproval from '@salesforce/apex/LeaveRequestApproveHandler.bulkLeaveReqApproval';
import bulkLeaveReqReject from '@salesforce/apex/LeaveRequestRejectHandler.bulkLeaveReqReject';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class EMS_LM_LeaveApproveRejectScreen extends NavigationMixin(LightningElement) {

  approveAllComments;
  rejectAllComments;
  isShowModalApproveAll = false;
  isShowModalRejectAll = false;
  isViewAll = true;
  leaveReqPendingList;
  leaveReqApprover2List;
  leaveReqApprover3List;
  @track section;
  @api multipleApprovals = []
  @api recordId;
  @track removeDuplicates;
  entireData;


  //ACCORDION
  handleSectionToggle(event) {
    const openSections = event.detail.openSections;
    //this.section = event.detail.openSections;
    console.log('print section : ' + openSections);
    this.activeSections = 'Approver 1';
    if (openSections.length === 0) {
      this.activeSectionsMessage = 'All sections are closed';
    } else {
      this.activeSectionsMessage =
        'Open sections: ' + openSections.join(' ');
    }
  }

  @track currentPageReference;
  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    this.currentPageReference = currentPageReference;
  }
  @wire(getLeaveReqData)
  getLeaveReqDataWiredData({ error, data }) {
    if (data) {
      console.log('### GetLeaveReqData', data);
      if (data.pendingList.length > 0)
        this.leaveReqPendingList = data.pendingList;
      console.log('### leaveReqPendingList', this.leaveReqPendingList);

      if (data.approver2List.length > 0)
        this.leaveReqApprover2List = data.approver2List;
      console.log('### leaveReqApprover2List', this.leaveReqApprover2List);

      if (data.approver3List.length > 0)
        this.leaveReqApprover3List = data.approver3List
      console.log('###  leaveReqApprover3List: ', this.leaveReqApprover3List);

    } else if (error) {
      console.error('Error:', error);
    }
  }

  //EVENT HANDLING
  handlemultipleApprovals(event) {
    //console.log('Event Fired  : ',event);
    //console.log('### Event called : ',+ event.detail);
    this.multipleApprovals = [...this.multipleApprovals, event.detail];
    console.log('### multipleApprovals : ', JSON.stringify(this.multipleApprovals));
    let flattenedApprovals = [].concat(...this.multipleApprovals);
    console.log('### flattenedApprovals : ', JSON.stringify(flattenedApprovals));
    this.removeDuplicates = [...new Set(flattenedApprovals)];
    console.log("### removeDuplicates", JSON.stringify(this.removeDuplicates));
  }

  /* handleMultipleApprovals(event) {
     this.multipleApprovals = [...this.multipleApprovals, event.detail];
     let removeDuplicates = [...new Set(this.multipleApprovals)].filter((item, index, self) => self.indexOf(item) === index);
     submitHandler(removeDuplicates);
     console.log('OUTPUT : ',removeDuplicates);
   }*/


  /* submitHandler(multipleApprovals) {
     this.entireData = [...this.entireData, multipleApprovals];
     console.log("### entireData", JSON.stringify(this.entireData));
   }*/

  //Approve All
  handleApproveAllComments(event) {
    this.approveAllComments = event.target.value
  }

  handleApproveAll() {
    this.isShowModalApproveAll = true;
    console.log(' APPROVE MODAL OPEN : ');
  }

  handleApproveAllSave() {
    console.log('OUTPUT : ',);
    console.log('OUTPUT removeDuplicates: ', JSON.stringify(this.removeDuplicates));
    if (this.removeDuplicates.length === 0) {
      alert('Please select at least one record');
    } else {
      //bulkLeaveReqApproval({ bulkleaveReqId: this.multipleApprovals, comments: this.approveAllComments })
      bulkLeaveReqApproval({ bulkleaveReqId: this.removeDuplicates, comments: this.approveAllComments })
        .then((result) => {
          console.log('Leave Request: ', result);
          window.location.reload();
        }).catch((err) => {
          console.log('ERROR : ', err);
        });
    }
  }




  //Reject All
  handleRejectAllComments(event) {
    this.rejectAllComments = event.target.value
  }

  handleRejectAll() {
    this.isShowModalApproveAll = true;
    console.log(' REJECT MODAL OPEN : ');
  }

  handleRejectAllSave() {
    console.log('REJECT SAVE : ');
    if (this.multipleApprovals.length === 0) {
      alert('Please select at least one record');
    } else {
      bulkLeaveReqReject({ bulkRejectId: this.multipleApprovals, comments: this.rejectAllComments })
        .then((result) => {
          console.log('Leave Request: ', result);
          window.location.reload();
        }).catch((err) => {
          console.log('ERROR : ', err);
        });
    }
  }

  //Approve All page navigation
  handleApproveAllNavigation(event) {
    var url = new URL("https://cpprd--dev.sandbox.my.site.com/CpLink/s/all-approvals");
    var params = new URLSearchParams();
    params.append("bulkupdate", "value");
    url.search += "&" + params.toString();
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: url.href
      }
    });
  }
  connectedCallback() {
    var params = new URLSearchParams(location.search);
    if (params.has('bulkupdate')) {
      console.log("Hello");
      this.isViewAll = false;
      console.log('Bye : ');
    }
  }

  //Modal Pop-up Close
  handleCloseAll() {
    this.isShowModalApproveAll = false;
    this.isShowModalRejectAll = false;
  }
}