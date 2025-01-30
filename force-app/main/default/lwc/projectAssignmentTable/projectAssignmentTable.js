import { LightningElement, track, api, wire } from 'lwc';
import getTmenteeproject from '@salesforce/apex/myMetricsController.getMenteeProjectAssigne';
import createPMAnswerConfigureForManager from '@salesforce/apex/myMetricsController.createPMAnswerConfigureForManager';
import allowSendingKraRequestToOtherPm from '@salesforce/apex/myMetricsController.allowSendingKraRequestToOtherPm';
import getRRRdata from '@salesforce/apex/myMetricsController.getRRRdata';

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
    @track otherManagerIds;
    otherProjectId;
    otherProjectAssgnId;

    BE_PR_RR = {
        Resource__c: null,
    };
    wiregetTmenteeproject
    RRRData;
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

    //smaske : [30-Oct-2024] : PM_Def_214 : GetRRRData
    @wire(getRRRdata, { contactId: '$optionarray', tab: '$tab' })
    wiredRRRData(result) {
        if (result.data) {
            this.RRRData = result.data;
            console.log('this.RRRData Data',  JSON.stringify(this.RRRData) );
            console.log('this.RRRData menteeContact',  JSON.stringify(this.RRRData.menteeContact) );
            console.log('this.RRRData mentorContact',  JSON.stringify(this.RRRData.mentorContact) );
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            console.log('##error-->', result.error);
            this.ShowToast(' ', 'Error Fetching Resource Relationship data!', 'error', 'dismissable');
        }
    }

selectedLabel
    handleChangeCombobox(event) {
        const projectId = event.currentTarget.dataset.projectid;
        const selectedManagerId = event.detail.value;
        const projectassgnId = event.currentTarget.dataset.projectassigmentid;
       console.log('Project assgn Id-----'+projectassgnId);
        console.log(`Project ID: ${projectId}, Selected Manager ID: ${selectedManagerId}`);
        console.log('OUTPUT : ', JSON.parse(JSON.stringify(this.menteeList)));
        if (selectedManagerId == 'Other') {
            this.isShowModal = true;
            this.otherProjectId = projectId;
            this.otherProjectAssgnId = projectassgnId;
            console.log('Project assgn Id 2-----'+this.otherProjectAssgnId);
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

            //smaske : [30-Oct-2024] : PM_Def_214 : adding validation when selecting other contac for KRA request
            if (this.tab === 'My Metric' && this.otherManagerIds === this.RRRData.mentorContact) {
                this.ShowToast(' ', 'Please choose resource other than your mentor', 'error', 'dismissable');
                return;
            }
            
            if (this.tab === 'My Team' && this.otherManagerIds === this.RRRData.menteeContact) {
                this.ShowToast(' ', 'Please choose resource other than your mentee', 'error', 'dismissable');
                return;
            }
            
            /*this.menteeList = this.menteeList.map(mentee => {
                if (mentee.projectid === mentee.value) {
                    return {
                        ...mentee,                                              
                        value: this.otherManagerIds
                    };
                }
                return mentee;
            });*/
            console.log('otherProjectId----' + this.otherProjectId);
            console.log('projectassigmentid----' + this.otherProjectAssgnId);
            console.log('Conatct Id---' + this.optionarray);
            console.log('manager Id---' + this.otherManagerIds);
            //smaske : PM_Def_158 : Calling apex method to check of the selected OTHER contact is the On/Off Shore Manager for the Project.
            let allowKRARequest = false;
            allowSendingKraRequestToOtherPm({ managerContact: this.otherManagerIds, projectId: this.otherProjectId })
                .then((result) => {
                    
                    console.log('allowSendingKraRequestToOtherPm ' + result);
                    allowKRARequest = result;
                    console.log('allowKRARequest-->', allowKRARequest);
                    //smaske : PM_Def_158 : When on/off shore manager is not same as selected other contact
                    if (allowKRARequest) {
                        this.isLoaded = true;
                        this.isShowModal = false;
                        createPMAnswerConfigureForManager({ contactId: this.optionarray, managerContact: this.otherManagerIds, projectId: this.otherProjectId, projectassigmentid: this.otherProjectAssgnId })
                            .then((result) => {
                                refreshApex(this.wiregetTmenteeproject);
                                this.ShowToast(' ', 'KRA request sent successfully', 'success', 'dismissable');
                                this.isLoaded = false;
                            })
                            .catch((error) => {
                                console.log('error-->', error);
                                this.ShowToast(' ', 'Something went wrong!', 'error', 'dismissable');
                                this.isLoaded = false;
                            });
                    } else {
                        //smaske : PM_Def_158 : When on/off shore manager is same as selected other contact
                        this.ShowToast(' ', 'Please choose resource other than onshore/offshore manager', 'error', 'dismissable');
                    }
                })
                .catch((error) => {
                    console.log('error-->', error);
                    this.isLoaded = false;
                    this.isShowModal = false;
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
        this.otherManagerIds = null;
        console.log('this.menteeList-->' + this.menteeList);
    }


    async HandlementeeRowAction(event) {
        const projectId = event.currentTarget.dataset.projectid;
        const managerId = event.currentTarget.dataset.managerid;
        const projectassigmentid = event.currentTarget.dataset.projectassigmentid;

        console.log('projectassigmentid-->', projectassigmentid);
        console.log('projectId-->', projectId);
        console.log('this.optionarray-->', this.optionarray);

        /*const result = await LightningConfirm.open({
            message: 'Click on OK to Confirm Send KRA Request.',
            variant: 'header',
            label: 'Confirm KRA Submission',
            theme:'info'
            // setting theme would have no effect
        });*/
       // if (result === true) {
            this.isLoaded = true;
            console.log('managerId-->', managerId);
            console.log('projectId-->', projectId);

            createPMAnswerConfigureForManager({ contactId: this.optionarray, managerContact: managerId, projectId: projectId, projectassigmentid: projectassigmentid })
                .then((result) => {
                    refreshApex(this.wiregetTmenteeproject);
                    this.ShowToast(' ', 'KRA request sent successfully', 'success', 'dismissable');
                    this.isLoaded = false;
                })
                .catch((error) => {
                    console.log('error-->', error);
                    this.ShowToast(' ', 'Something went wrong!', 'error', 'dismissable');
                    this.isLoaded = false;
                });
       // }
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