import { LightningElement, track, api, wire } from 'lwc';
import getTmenteeproject from '@salesforce/apex/myMetricsController.getMenteeProjectAssigne';
import createPMAnswerConfigureForManager from '@salesforce/apex/myMetricsController.createPMAnswerConfigureForManager';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import LightningConfirm from 'lightning/confirm';
import Id from '@salesforce/user/Id';
import contactId from '@salesforce/schema/User.ContactId';
import { refreshApex } from '@salesforce/apex';
export default class ProjectAssignmentTable extends LightningElement {
    @track menteeList;
    showDataTable = false;
    @api tab
    @api optionarray;
    userId = Id;
    isLoaded = false;
    error;
    value;
    isShowModal = false;
    otherManagerIds;
    BE_PR_RR = {
        Resource__c: null,
    };
    wiregetTmenteeproject

    @wire(getRecord, { recordId: Id, fields: [contactId] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (this.tab == 'My Metric') {
                if (data.fields.ContactId.value != null) {
                    this.optionarray = data.fields.ContactId.value;
                }
            }
        }
    }

    /*  @wire(getTmenteeproject, { contactId: '$optionarray' })
      wiredData({ error, data }) {
          if (data) {
              console.log('Data', data);
              if (data.length > 0) {
                  this.menteeList = data.map(mentee => {
                      return {
                          ...mentee,
                          disableKRAbutton: true,
                      };
                  });
                  this.showDataTable = true;
  
              } else {
                  this.showDataTable = false;
              }
              console.log('OUTPUT : ', this.menteeList);
          } else if (error) {
              console.error('Error:', error);
          }
      }*/

    @wire(getTmenteeproject, { contactId: '$optionarray' })
    wiredData(result) {
        this.wiregetTmenteeproject = result;
        if (result.data) {
            console.log('Data', result.data);
            if (result.data.length > 0) {
                this.menteeList = result.data.map(mentee => {
                    return {
                        ...mentee,
                        disableKRAbutton: true,
                    };
                });
                this.showDataTable = true;

            } else {
                this.showDataTable = false;
            }
            console.log('OUTPUT : ', this.menteeList);
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            console.log('##error-->', result.error);
        }
    }

selectedLabel
    handleChangeCombobox(event) {
        const projectId = event.currentTarget.dataset.projectid;
        const selectedManagerId = event.detail.value;
        console.log(`Project ID: ${projectId}, Selected Manager ID: ${selectedManagerId}`);
        console.log('OUTPUT : ', JSON.parse(JSON.stringify(this.menteeList)));
        if (selectedManagerId == 'Other') {
            this.isShowModal = true;
        }
        
       /*  for (const mentee of this.menteeList) {
            const selectedOption = mentee.managerOptions.find(option => option.value === selectedManagerId);
            console.log('OUTPUT : ', selectedOption);
            if (selectedOption) {
                this.selectedLabel = selectedOption.label;
                break;
            }
        }*/

        this.menteeList = this.menteeList.map(mentee => {
            if (mentee.projectid === projectId && selectedManagerId != 'Other') {
                return {
                    ...mentee,
                    value: selectedManagerId,
                    disableKRAbutton: false
                };
            }
            if (mentee.projectid === projectId && selectedManagerId == 'Other') {
                return {
                    ...mentee,
                    value: projectId,
                    disableKRAbutton: false
                };
            }
            return mentee;
        });
        console.log('OUTPUT : ', JSON.parse(JSON.stringify(this.menteeList)));
    }

    handleValueSelectedOnAccount(event) {
        const selectedLookupValue = event.detail;
        console.log(" selectedLookupValue " + JSON.stringify(selectedLookupValue));
        this.otherManagerIds = selectedLookupValue.id;

        console.log(" this.otherManagerIds " + this.otherManagerIds);
    }

    handleValueRemovedOnAccount(event) {
        console.log('# handleValueRemovedOnAccount');
        const selectedLookupValue = event.detail;
        const value = selectedLookupValue.id;
        const label = selectedLookupValue.label;
        let currentStep = this.selectedStep;
        this.otherManagerIds = null;
    }

    handleConformModalBox(event) {
        if (this.otherManagerIds != null) {
            this.isShowModal = false;
            this.menteeList = this.menteeList.map(mentee => {
                if (mentee.projectid === mentee.value) {
                    return {
                        ...mentee,                                              
                        value: this.otherManagerIds
                    };
                }
                return mentee;
            });
        } else {
            this.ShowToast(' ', 'Please select a resource', 'error', 'dismissable');
        }
    }

    hideModalBox() {
        this.isShowModal = false;
        this.menteeList = this.menteeList.map(mentee => {
            return {
                ...mentee,
                value:'',
                disableKRAbutton: true
            };
        });
        console.log('this.menteeList-->' + this.menteeList);
    }


    async HandlementeeRowAction(event) {
        const projectId = event.currentTarget.dataset.projectid;
        const managerId = event.currentTarget.dataset.managerid;
        const projectassigmentid = event.currentTarget.dataset.projectassigmentid;

        console.log('projectassigmentid-->', projectassigmentid);
        console.log('projectId-->', projectId);
        console.log('this.optionarray-->', this.optionarray);

        const result = await LightningConfirm.open({
            message: 'Click on OK to Confirm Send KRA Request.',
            variant: 'headerless',
            label: 'this is the aria-label value',
            // setting theme would have no effect
        });
        if (result === true) {
            this.isLoaded = true;
            console.log('managerId-->', managerId);
            console.log('projectId-->', projectId);

            createPMAnswerConfigureForManager({ contactId: this.optionarray, managerContact: managerId, projectId: projectId, projectassigmentid: projectassigmentid })
                .then((result) => {
                    refreshApex(this.wiregetTmenteeproject);
                    this.ShowToast(' ', 'Record(s) created Successfully!', 'success', 'dismissable');
                    this.isLoaded = false;
                })
                .catch((error) => {
                    console.log('error-->', error);
                    this.ShowToast(' ', 'Something went wrong!', 'error', 'dismissable');
                    this.isLoaded = false;
                });
        }
    }

    ShowToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}