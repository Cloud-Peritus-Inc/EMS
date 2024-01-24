import { LightningElement, api, wire, track } from 'lwc';
import getActiveAssignments from '@salesforce/apex/ProjectAllocationTabController.getActiveAssignments';
import { refreshApex } from '@salesforce/apex';
import getAssignmentWrapperWithProjectOptions from '@salesforce/apex/ProjectAllocationTabController.getAssignmentWrapperWithProjectOptions';
import fetchAssignmentRecordsData from '@salesforce/apex/ChangeProjectActionButtonController.fetchAssignmentRecordsData';
import fetchActiveProjectsList from '@salesforce/apex/ChangeProjectActionButtonController.fetchActiveProjectsList';
import getPicklistValues from '@salesforce/apex/ChangeProjectActionButtonController.getPicklistValues';
import saveAssignmentRecords from '@salesforce/apex/ChangeProjectActionButtonController.saveAssignmentRecords';
import getTotalProjectAllocationOfSingleContact from '@salesforce/apex/ChangeProjectActionButtonController.getTotalProjectAllocationOfSingleContact';
import updateOldProjectAllocationOfSingleContact from '@salesforce/apex/ChangeProjectActionButtonController.updateOldProjectAllocationOfSingleContact';
//Shubham : Close Project Controller Method
import closeProjectForSingleContact from '@salesforce/apex/ChangeProjectActionButtonController.closeProjectForSingleContact';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProjectAllocationTab extends NavigationMixin(LightningElement) {
    @track assignments;
    //Shubham : Created below vairable for refreshApex
    wiredAssignmentsResult;
    searchTerm = '';
    searchProject = '';
    projectOptions = [];
    selectedContactIdList = [];
    @track changeprojectpopup = false;
    @track changeAllproject = false;
    assignmentId;
    @track resultRecords = [];
    error;
    @track projectsList;
    @track activeProjectsList;
    @track picklistValues = [];
    @track showLoading = false;
    @track showCloseProjectModal = false;
    @track showEditProjectModal = false;

    //dropdown menu items 
    @track dropdownOptions = [
        { label: 'Change Project', value: 'changeProject', id:'changeProject'},
        { label: 'Close Project', value: 'closeProject', id:'closeProject'},
        { label: 'Edit Details', value: 'editProject', id:'editProject'},
    ];

    handleMenuSelect(event) {
        const selectedValue = event.target.value;
        console.log('Selected Value:', selectedValue);
    }
    

    @wire(getActiveAssignments, { searchTerm: '$searchTerm', searchProject: '$searchProject' })
    wiredAssignments(value) {
        this.wiredAssignmentsResult = value;
        const { data, error } = value;
        if (data) {
            let assignmentsData = data.map((assignment, index) => ({
                ...assignment,
                serialNumber: index + 1
            }));
            if (assignmentsData.length > 0) {
                this.assignments = assignmentsData;
            } else {
                this.assignments = '';
            }
            //console.log('Final data == > ' + JSON.stringify(this.assignments));
        } else if (error) {
            console.log('Error retrieving assignments:', error);
        }
    }

    @wire(getAssignmentWrapperWithProjectOptions)
    wiredProjectOptions({ data, error }) {
        if (data) {
            this.projectOptions = data.projectOptions.map(option => ({
                label: option,
                value: option
            }));
        } else if (error) {
            console.log('Error retrieving project options:', error);
        }
    }


    handleSearchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    handleProjectSearchTermChange(event) {
        this.searchProject = event.target.value;
    }

    clearProjectSelection() {
        this.searchProject = '';
    }

    employeeName; //stores contactId
    employee_Name;//stores Contact Name(String)
    totalProjectAllocationForSingleContact;
    selectedAssignmentProjectAllocation;
    selectOldProjectName;
    oldProjectStatusValue;
    oldProjectAllocationValue;
    oldassignedAs;
    OldProjectId;
    name;

    //Shubham : Function to Open modal and assign variable values.
    handleClickCloseProject(event) {
        console.log(' ### Close Project Button Clicked ');
        this.assignmentId = event.target.dataset.id;
        this.employeeName = event.target.dataset.employeename;
        this.employee_Name = event.target.dataset.employee_name;
        this.oldassignedAs = event.target.dataset.assignedas;
        this.selectedAssignmentProjectAllocation = event.target.dataset.projectallocation;
        this.oldProjectAllocationValue = event.target.dataset.projectallocation;
        this.selectOldProjectName = event.target.dataset.oldprojectname;
        this.OldProjectId = event.target.dataset.oldprojectid;
        //making modal visible
        this.showCloseProjectModal = true;
        //calling GENERIC fun to calculate "totalProjectAllocationForSingleContact"
        this.getTotalProjectAllocationOfSingleContactGlobal(this.employeeName);
    }

    //Shubham : This method will update the assignment record and will refresh the cmp
    handleCloseProjectRecord(event) {
        //Calling the closeProjectForSingleContact  APEX Controller Method
        closeProjectForSingleContact({ assignmentId: this.assignmentId, OldProjectId: this.OldProjectId, contactId: this.employeeName })
            .then(result => {
                this.totalProjectAllocationForSingleContact = this.totalProjectAllocationForSingleContact - this.oldProjectAllocationValue;
                console.log('totalProjectAllocationForSingleContact After Close => ' + this.totalProjectAllocationForSingleContact);

                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Assignments closed successfully.',
                        variant: 'success',
                    })
                );
                this.CloseProjectModal();
                return refreshApex(this.wiredAssignmentsResult);
            })
            .catch(error => {
                console.log('error ERROR ==> ', error);
                this.error = error;
                console.log('closeProjectForSingleContact ERROR ==> ' + this.error);
            });
    }

    handleClickEditProject(event) {
        console.log(' ### Edit Project Button Clicked ');
        this.name = event.target.dataset.name;
        this.assignmentId = event.target.dataset.id;
        this.employeeName = event.target.dataset.employeename;
        this.employee_Name = event.target.dataset.employee_name;
        this.oldassignedAs = event.target.dataset.assignedas;
        this.selectedAssignmentProjectAllocation = event.target.dataset.projectallocation;
        this.oldProjectAllocationValue = event.target.dataset.projectallocation;
        this.selectOldProjectName = event.target.dataset.oldprojectname;
        this.OldProjectId = event.target.dataset.oldprojectid;
        //making modal visible
        this.showEditProjectModal = true;
        //calling GENERIC fun to calculate "totalProjectAllocationForSingleContact"
        this.getTotalProjectAllocationOfSingleContactGlobal(this.employeeName);
    }

    handleEditProjectRecord(event) {
        console.log('handleEditProjectRecord');
        event.preventDefault();
        const editForm = this.template.querySelector('lightning-record-edit-form[data-id="editForm"]');
        editForm.addEventListener('submit', this.handleFormSubmit.bind(this, editForm));

        if (this.totalProjectAllocationForSingleContact <= 100) {
            this.existingProjectAllocation = this.totalProjectAllocationForSingleContact - this.oldProjectAllocationValue;
            this.ableToAllocate = 100 - (this.totalProjectAllocationForSingleContact - this.oldProjectAllocationValue);

            if (this.newProjectAllocation <= 100 && (this.newProjectAllocation <= (100 - (this.totalProjectAllocationForSingleContact - this.oldProjectAllocationValue)))) {
                editForm.submit();
            }
            else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Already assigned with ' + this.existingProjectAllocation + '%, so you can allocate upto ' + this.ableToAllocate + '%',
                        variant: 'error',
                    })
                );
            }
        }
        else {
            console.log(this.employee_Name);//data-employee_name
            this.dispatchEvent(
                new ShowToastEvent({
                    message: `You are allocating ${this.employee_Name} more than 100%, the current Total Allocation is ${this.totalProjectAllocationForSingleContact}%`,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            editForm.submit();
        }
    }

    handleClickChangeproject(event) {
        this.assignmentId = event.target.dataset.id;
        this.employeeName = event.target.dataset.employeename;
        //Storing the Name label of contact record selected
        this.employee_Name = event.target.dataset.employee_name;
        this.oldassignedAs = event.target.dataset.assignedas;
        this.selectedAssignmentProjectAllocation = event.target.dataset.projectallocation;
        this.oldProjectAllocationValue = event.target.dataset.projectallocation;
        this.selectOldProjectName = event.target.dataset.oldprojectname;
        this.OldProjectId = event.target.dataset.oldprojectid;

        console.log('OldProjectId --->', this.OldProjectId);
        console.log('oldassignedAs --->', this.oldassignedAs);
        // console.log('Select Assignment Project Allocation Value --->', this.selectedAssignmentProjectAllocation);
        this.changeprojectpopup = true;

        // calling GENERIC fun to calculate "totalProjectAllocationForSingleContact" 
        this.getTotalProjectAllocationOfSingleContactGlobal(this.employeeName);
       /* getTotalProjectAllocationOfSingleContact({ contactId: this.employeeName })
            .then(result => {
                this.totalProjectAllocationForSingleContact = result;
                console.log('totalProjectAllocationForSingleContact in result => ' + this.totalProjectAllocationForSingleContact);
            })
            .catch(error => {
                console.log('error ERROR ==> ', error);
                this.error = error;
                console.log('totalProjectAllocationForSingleContact ERROR ==> ' + this.error);
            }); */
    }

    @track newProjectName;
    @track newAssignedAS;
    newOnchange(event){
        const field = event.target.fieldName;
        console.log('field' ,field);
        if(field == 'EMS_TM_ProjectName_Asgn__c'){
            this.newProjectName = event.target.value;
            console.log('this.newProjectName' ,this.newProjectName);
        }
        if(field == 'EMS_TM_AssignedAs__c'){
            this.newAssignedAS = event.target.value;
            console.log('this.newAssignedAS' ,this.newAssignedAS);
        }

    }

    hideModalBox() {
        this.newProjectAllocation = '';
        this.changeprojectpopup = false;
    }

    hideModal() {
        this.changeAllproject = false;
    }

    //custom Modal for CloseProject button
    CloseProjectModal() {  
        this.showCloseProjectModal = false;
    }

    //custom Modal for CloseProject button
    CloseEditModal() {  
        this.showEditProjectModal = false;
    }

    //--------------CheckBox---------

    handleAllSelected(event) {
        this.checkBox = event.target.checked;
        if (this.checkBox) {
            const checkboxElements = this.template.querySelectorAll('lightning-input[data-key="firstColumnCheckbox"]');
            const selectedRecordIds = [];
            checkboxElements.forEach(element => {
                if (!element.disabled) {
                    element.checked = true;
                    const dataId = element.dataset.id;
                    selectedRecordIds.push(dataId);
                }
            });
            console.log('Selected Record Ids:', selectedRecordIds);
            this.selectedContactIdList = selectedRecordIds;
            console.log('### selectedContactIdList', this.selectedContactIdList);
        } else if (!this.checkBox) {
            const checkboxElements = this.template.querySelectorAll('lightning-input[data-key="firstColumnCheckbox"]');
            checkboxElements.forEach(element => {
                element.checked = false;
            });
            this.selectedContactIdList = [];
        }
    }


    handleCheckboxSelect(event) {
        console.log('assgnmentIds ==>  ' + event.target.dataset.id);
        const assignmentId = event.target.dataset.id;
        const index = this.selectedContactIdList.indexOf(assignmentId);

        if (event.target.checked) {
            if (index === -1) {
                this.selectedContactIdList.push(assignmentId);
            }
        } else {
            if (index !== -1) {
                this.selectedContactIdList.splice(index, 1);
            }
        }
        console.log('assignmentIds list -> ' + this.selectedContactIdList);
        const selectedRows = this.template.querySelectorAll('lightning-input[data-key="firstColumnCheckbox"]');
        let allSelected = true;
        selectedRows.forEach((currentItem) => {
            if (!currentItem.checked) {
                allSelected = false;
            }
        });
        const selectedRow = this.template.querySelector('lightning-input[data-key="allCheckbox"]');
        selectedRow.checked = allSelected;
    }

    selectedAssignmentIdList = [];

    handleCheckboxInnerCmp(event) {
        const assignmentId = event.target.dataset.ids;

        if (event.target.checked) {
            this.selectedAssignmentIdList.push(assignmentId);
        } else {
            const index = this.selectedAssignmentIdList.indexOf(assignmentId);
            if (index !== -1) {
                this.selectedAssignmentIdList.splice(index, 1);
            }
        }

        console.log('selectedAssignmentIdList list -> ', this.selectedAssignmentIdList);
    }
    // Helper function to check if an assignment ID is selected
    get isAssignmentSelected() {
        return (assignmentId) => this.selectedAssignmentIdList.includes(assignmentId);
    }



    handleChangeprojectForAll() {
        if (this.selectedContactIdList.length > 0) {
            console.log('selectedContactIdList', this.selectedContactIdList);
            this.changeAllproject = true;
            this.showLoading = true;
            fetchAssignmentRecordsData({ assignmenyIdList: this.selectedContactIdList })
                .then(result => {
                    this.resultRecords = result;
                    this.selectedAssignmentIdList = this.selectedContactIdList;
                    console.log('Project details => ' + JSON.stringify(this.resultRecords));
                    this.showLoading = false;
                })
                .catch(error => {
                    console.log('error ==>', error);
                    this.showLoading = false;
                });


        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    message: 'Please select atleast one row',
                    variant: 'error',
                }),
            );
        }
    }


    @wire(fetchActiveProjectsList)
    activeProjectsList({ data, error }) {
        if (data) {
            try {
                this.activeProjectsList = data;
                let options = [];
                for (var key in data) {
                    options.push({ label: data[key].Name, value: data[key].Id });
                }
                this.projectsList = options;
            } catch (error) {
                console.error('check error here', error);
            }
        } else {
            this.error = error;
            console.log('Error2 ==> ' + JSON.stringify(this.error));
        }
    }

    @wire(getPicklistValues, { objectName: 'EMS_TM_Assignment__c', fieldName: 'EMS_TM_Status_Asgn__c' })
    retrievePicklistValues({ error, data }) {
        if (data) {
            this.picklistValues = data.map((value) => ({
                label: value,
                value: value
            }));
        } else if (error) {
            console.error('Error retrieving picklist values:', error);
        }
    }

    @track assignedAsList = [];
    @wire(getPicklistValues, { objectName: 'EMS_TM_Assignment__c', fieldName: 'EMS_TM_AssignedAs__c' })
    retrieveAssignedAsList({ error, data }) {
        if (data) {
            this.assignedAsList = data.map((value) => ({
                label: value,
                value: value
            }));
        } else if (error) {
            console.error('Error retrieving picklist values:', error);
        }
    }


    //To get the new project allocation value
    @track newProjectAllocation;
    newProjectAllocationFuncion(event) {
        this.newProjectAllocation = event.target.value;
        console.log('newProjectAllocation ==> ' + this.newProjectAllocation);

        let x = this.template.querySelector('lightning-input[data-id="oldProjectAllocation"]');
        console.log('value 292 => ' + x.value);
        console.log('this.oldProjectAllocationValue :' + this.oldProjectAllocationValue);
        if (this.newProjectAllocation == this.selectedAssignmentProjectAllocation /* || this.newProjectAllocation >= this.oldProjectAllocationValue */ ) {
            console.log("IF");
            x.value = 0;
            this.selectedAssignmentProjectAllocation = x.value;
            this.oldProjectStatusValue = 'Closed';
        } else {
            console.log("ELSE");
            //this.selectedAssignmentProjectAllocation = (this.oldProjectAllocationValue - this.newProjectAllocation); //(this.newProjectAllocation - this.oldProjectAllocationValue);
            //smaske : commented direct allocation of selectedAssignmentProjectAllocation for avoiding negative value
            let calculatedValue = (this.oldProjectAllocationValue - this.newProjectAllocation);
            console.log("calculatedValue " + calculatedValue);
            this.selectedAssignmentProjectAllocation = calculatedValue > 0 ? calculatedValue : 0;
            if(this.selectedAssignmentProjectAllocation == 0){
                //smaske : setting the value of x to 0 , else the previous record will not close and the submit functionality wont work.
                x.value = 0;
                this.oldProjectStatusValue = 'Closed';
            }else{
                console.log('el  2' + this.selectedAssignmentProjectAllocation);
                this.oldProjectStatusValue = 'Active';
            }
            
        }

    }

    editProjectAllocationFuncion(event){
        this.newProjectAllocation = event.target.value;
        console.log('newProjectAllocation ==> ' + this.newProjectAllocation);
    }

    existingProjectAllocation;
    ableToAllocate;


    handleSubmit(event) {
        console.log('Enter submit');
        event.preventDefault();
        console.log('Fields 239 => ' + event.detail.fields);
        const newForm = this.template.querySelector('lightning-record-edit-form[data-id="newForm"]');

        console.log('Select Assignment Project Allocation Value 2 --->', this.selectedAssignmentProjectAllocation);
        console.log('totalProjectAllocationForSingleContact in result 2 => ' + this.totalProjectAllocationForSingleContact);
        console.log('newProjectAllocation 2 ==> ' + this.newProjectAllocation);

        newForm.addEventListener('submit', this.handleFormSubmit.bind(this, newForm));
        console.log('save button ==> ');
        console.log('NewAssignAs ==> '+ this.NewAssignAs);

        if((this.OldProjectId === this.newProjectName) && (this.oldassignedAs === this.newAssignedAS)){ //&& (this.oldassignedAs === this.newAssignedAS)
            this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Already assigned as ' + this.newAssignedAS + ' for the ' + this.selectOldProjectName + ' project.',
                        variant: 'error',
                    })
                );
        }else{
            if (this.totalProjectAllocationForSingleContact <= 100) {
            this.existingProjectAllocation = this.totalProjectAllocationForSingleContact - this.oldProjectAllocationValue;
            this.ableToAllocate = 100 - (this.totalProjectAllocationForSingleContact - this.oldProjectAllocationValue);

            if (this.newProjectAllocation <= 100 && (this.newProjectAllocation <= (100 - (this.totalProjectAllocationForSingleContact - this.oldProjectAllocationValue)))) {
                console.log('inside else condition');
                newForm.submit();
            }
            else {
                console.log('***** ELSE *****');
                /*this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Already assigned with ' + this.existingProjectAllocation + '%, so you can allocate upto ' + this.ableToAllocate + '%',
                        variant: 'error',
                    })
                );*/
                //Adding new Toast Msg
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: `You are allocating ${this.employee_Name} more than 100%, the current Total Allocation is ${this.totalProjectAllocationForSingleContact}%`,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                newForm.submit();
            }
        }
        else {
            /*this.dispatchEvent(
                new ShowToastEvent({
                    message: 'Project Allocation Should be Less Than 100% and Current Total Allocation is ' + this.totalProjectAllocationForSingleContact + '%',
                    variant: 'error',
                })
            );*/
            console.log(this.employee_Name);//data-employee_name
            this.dispatchEvent(
                new ShowToastEvent({
                    message: `You are allocating ${this.employee_Name} more than 100%, the current Total Allocation is ${this.totalProjectAllocationForSingleContact}%`,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            newForm.submit();
        }
        }

        console.log('Condition 1 => '+ (this.OldProjectId != this.newProjectName));
        console.log('Condition 2 => '+ (this.oldassignedAs != this.NewAssignAs));
        console.log('Condition 3 => '+ (this.OldProjectId == this.newProjectName));

        /*if((this.OldProjectId != this.newProjectName && this.oldassignedAs != this.NewAssignAs) 
        || (this.OldProjectId == this.newProjectName && this.oldassignedAs != this.NewAssignAs)){
           if (this.totalProjectAllocationForSingleContact <= 100) {
            this.existingProjectAllocation = this.totalProjectAllocationForSingleContact - this.oldProjectAllocationValue;
            this.ableToAllocate = 100 - (this.totalProjectAllocationForSingleContact - this.oldProjectAllocationValue);

            if (this.newProjectAllocation <= 100 && (this.newProjectAllocation <= (100 - (this.totalProjectAllocationForSingleContact - this.oldProjectAllocationValue)))) {
                console.log('inside else condition');
                newForm.submit();
            }
            else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Already assigned with ' + this.existingProjectAllocation + '%, so you can allocate upto ' + this.ableToAllocate + '%',
                        variant: 'error',
                    })
                );
            }
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    message: 'Project Allocation Should be Less Than 100% and Current Total Allocation is ' + this.totalProjectAllocationForSingleContact + '%',
                    variant: 'error',
                })
            );
        }
        
        }else{
            this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Already assigned as ' + this.NewAssignAs + 'for the ' + this.selectOldProjectName + '.',
                        variant: 'error',
                    })
                );
        }*/
        
    }

    handleFormSubmit(form, event) {
        event.preventDefault();
        if (form.checkValidity()) {
            form.submit();
        } else {
            console.error('Form validation failed');
        }
    }

    handleAssignmentSuccess(event) {
        updateOldProjectAllocationOfSingleContact({ assignmentId: this.assignmentId, oldProjectAllocationUpdatedValue: this.selectedAssignmentProjectAllocation, oldProjectStatus: this.oldProjectStatusValue })
            .then(result => {
                console.log('result==>', result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Assignments added successfully.',
                        variant: 'success',
                    })
                );
                this.hideModalBox();
                return refreshApex(this.wiredAssignmentsResult);
            })
            .catch(error => {
                console.log('error', error);
                this.error = error;
                console.log('ERROR in updating old project data ==> ' + JSON.stringify(this.error));
            });
    }

    //Shubham : function for handling onsuccess of record EDIT
    handleEditAssignmentSuccess(event) {
        console.log("handleEditAssignmentSuccess");
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Record updated successfully.',
                        variant: 'success',
                    })
                );
                this.showEditProjectModal = false;
                return refreshApex(this.wiredAssignmentsResult);
    }
        
        //window.location.reload();
        /* setTimeout(function () {
            window.location.reload();
        }, 2000); */
        
    handleAssignmenterror(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                message: event.detail.detail,
                variant: 'error',
            }),
        );
    }
    //-----------------------------------------------------------------------------------------------------------------------------------
    oldprojectAllocationValue;
    updateValues(event) {
        let index = event.target.dataset.id;
        console.log('index', index);

        if (event.target.name == 'EMS_TM_ProjectName_Asgn__c') {
            console.log('enter in onchange', event.target.value);
            this.resultRecords[index].NewProjectName = event.target.value;
            console.log('resultrecords', this.resultRecords);
        }
        if (event.target.name == 'EMS_TM_AssignedAs__c') {
            this.resultRecords[index].NewAssignAs = event.target.value;
            console.log('NewAssignAs', this.resultRecords);
        }
        if (event.target.name == 'EMS_TM_Status_Asgn__c') {
            this.resultRecords[index].NewStatus = event.target.value;
            console.log('NewStatus', this.resultRecords);
        }
        if (event.target.name == 'EMS_TM_StartDate_Asgn__c') {
            this.resultRecords[index].NewStartDate = event.target.value;
            if (this.resultRecords[index].NewCloseDate <= this.resultRecords[index].NewStartDate) {
                this.resultRecords[index].NewStartDate = null;
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Please enter a valid to date.',
                        variant: 'error',
                    })
                );//this.resultRecords[index].NewCloseDate = null;
                event.target.value = null;
            }
            console.log('NewStartDate', this.resultRecords);
        }
        if (event.target.name == 'EMS_TM_EndDate_Asgn__c') {
            this.resultRecords[index].NewCloseDate = event.target.value;
            if (this.resultRecords[index].NewCloseDate <= this.resultRecords[index].NewStartDate) {
                this.resultRecords[index].NewCloseDate = null;
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Please enter a valid to date.',
                        variant: 'error',
                    })
                );//this.resultRecords[index].NewCloseDate = null;
                event.target.value = null;
            }
            console.log('NewCloseDate', this.resultRecords);
        }
        if (event.target.name == 'EMS_TM_Billable__c') {
            this.resultRecords[index].NewBillable = event.target.checked;
            console.log('NewBillable', this.resultRecords);
        }
        if (event.target.name == 'Project_Allocation__c') {
            this.resultRecords[index].NewProjectAllocation = event.target.value;
            let oldprojectAllocationValue = this.resultRecords[index].OldProjectAllocation;
            console.log('oldprojectAllocationValue', oldprojectAllocationValue);
            if (this.resultRecords[index].NewProjectAllocation >= oldprojectAllocationValue) {
                this.resultRecords[index].ProjectAllocation = 0;
                this.resultRecords[index].Status = 'Closed';
            } else {
                this.resultRecords[index].ProjectAllocation = oldprojectAllocationValue - this.resultRecords[index].NewProjectAllocation;
                this.resultRecords[index].Status = 'Active';
            }
            console.log('NewProjectAllocation', this.resultRecords);
        }
        this.selectedAssignmentIdList = this.resultRecords.map(item => item.Id);
    }

    handleSaveAssignment() {
        if (this.selectedAssignmentIdList.length > 0) {
            const selectedRows = this.resultRecords.filter(item => this.selectedAssignmentIdList.includes(item.Id));
            const isInputsCorrect = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
                .reduce((validSoFar, inputField) => {
                    inputField.reportValidity();
                    return validSoFar && inputField.checkValidity();
                }, true)
                if (isInputsCorrect) {
            selectedRows.forEach(row => {
                if (row.TotalProjectAllocation <= 100) {
                    if (row.NewProjectAllocation <= 100 && (row.NewProjectAllocation <= (100 - (row.TotalProjectAllocation - row.OldProjectAllocation)))) {
                        console.log('inside else condition');
                        this.showLoading = true;
                        //Shubham : commented for code reusability,calling common function "saveAllAssignmentRecords" 
                        this.saveAllAssignmentRecords(selectedRows);
                        /*saveAssignmentRecords({ assignmentData: JSON.stringify(selectedRows) })
                            .then((result) => {
                                console.log('result==>', result);
                                this.showLoading = false;
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        message: 'Details saved successfully',
                                        variant: 'success',
                                    })
                                );
                                refreshApex(this.wiredAssignments);
                                this.hideModal();
                                console.log('Records saved successfully!');
                            })
                            .catch(error => {
                                console.log('error==>', error);
                                this.showLoading = false;
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        message: 'An error occurred while saving the details',
                                        variant: 'error',
                                    })
                                );
                                console.error('Error saving records:', error);
                            }); */
                    } else {
                        console.log('row.TotalProjectAllocation' ,row.TotalProjectAllocation);
                        console.log('row.OldProjectAllocation' ,row.OldProjectAllocation);
                        const existingProjectAllocation = row.TotalProjectAllocation - row.OldProjectAllocation;
                        const ableToAllocate = 100 - (row.TotalProjectAllocation - row.OldProjectAllocation);
                        console.log('existingProjectAllocation', existingProjectAllocation);
                        console.log('ableToAllocate', ableToAllocate);
                        const errorMessage = `For ${row.EmployeeName}, already assigned with ${existingProjectAllocation}%, so you can allocate up to ${ableToAllocate}%`;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                message: errorMessage,
                                variant: 'error',
                            })
                        );
                    }
                } else {
                    /*const errorMessage = `For ${row.EmployeeName}, Project Allocation should be less than 100% and the current Total Allocation is ${row.TotalProjectAllocation}%.`;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message: errorMessage,
                            variant: 'error',
                        })
                    );*/
                    //Sahubham : commented above toast msg for PMUS015, Created saveAllAssignmentRecords for Saving record
                    console.log(this.employee_Name);//data-employee_name
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message: `You are allocating ${row.EmployeeName} more than 100%, the current Total Allocation is ${row.TotalProjectAllocation}%`,
                            variant: 'error'
                        })
                    );
                    //console.log('#selectedRows ' + JSON.stringify(selectedRows));
                    //console.log('#ROW ' + JSON.stringify(row));
                    this.saveAllAssignmentRecords(selectedRows);
                }
            });
        }
        else {
                const even = new ShowToastEvent({
                    message: 'Please complete the required field and avoid invalid data.',
                    variant: 'error'
                });
                this.dispatchEvent(even);
            }
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    message: 'Please select at least one row.',
                    variant: 'error',
                })
            );
        }
    }l

    //Shubham : created a common function for Saving assignment records
    saveAllAssignmentRecords(selectedRowsData){
        console.log(' IN saveAllAssignmentRecords ');
        this.showLoading = true;
        saveAssignmentRecords({ assignmentData: JSON.stringify(selectedRowsData) })
            .then((result) => {
                console.log('result==>', result);
                this.showLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Details saved successfully',
                        variant: 'success',
                    })
                );
                refreshApex(this.wiredAssignmentsResult);
                this.hideModal();
                console.log('Records saved successfully!');
            })
            .catch(error => {
                console.log('error==>', error);
                this.showLoading = false;

                let errorMessage = 'An error occurred while saving the details';

                if (error.body && error.body.pageErrors && error.body.pageErrors.length > 0) {
                    errorMessage = error.body.pageErrors[0].message;
                }

                this.dispatchEvent(
                    new ShowToastEvent({
                        message: errorMessage,
                        variant: 'error',
                    })
                );
                console.log('Error saving records:', JSON.stringify(error));
            });
    }

    //Shubham : created a common function for Calculating "TotalProjectAllocationOfSingleContact"
    getTotalProjectAllocationOfSingleContactGlobal(conId) {
        //Get the totalProjectAllocation for Single Contact Record for whome we are closing the Project
        getTotalProjectAllocationOfSingleContact({ contactId: conId })
            .then(result => {
                this.totalProjectAllocationForSingleContact = result;
                console.log('totalProjectAllocationForSingleContact in result => ' + this.totalProjectAllocationForSingleContact);
            })
            .catch(error => {
                console.log('error ERROR ==> ', error);
                this.error = error;
                console.log('totalProjectAllocationForSingleContact ERROR ==> ' + this.error);
            });
    }


}