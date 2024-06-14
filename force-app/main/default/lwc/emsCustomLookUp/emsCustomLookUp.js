import { api, LightningElement, track, wire } from 'lwc';
import lookUp from '@salesforce/apex/EMS_TM_GenericController.search';


export default class EmsCustomLookUp extends LightningElement {

    @api objName;
    @api iconName;
    @api filter;
    @api searchPlaceholder='Search';
    @api name;
    @api indexId;
    @api value;
    @api users;
    // @api recordName;
    @track _selectedName;
    @track records = [];
    @track isValueSelected;
    @track blurTimeout;
    searchTerm;
    @track isLoading =true;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    @api isprojectnull = false;

    connectedCallback() {
        //console.log('CONNECTED CALL BACK');
    }
    @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName', filter : '$filter', fullName : '$users'})
    wiredRecords({ error, data }) {
        if (data) {
           /* console.log('searchTerm'+this.searchTerm);
            console.log('filetr     '+this.filter);
            console.log('myObject'+this.objName);
            console.log('filetrusres'+this.users);
            console.log("DATA" + JSON.stringify(data));*/
            this.error = undefined;
            //console.log('this.users...'+this.users);
            this.records = []; // clear the records array
            if (this.users) {
                       
                for (let i = 0; i < data.length; i++) {
                    let item = {Id: data[i].Id,displayName: '', FirstName: data[i].FirstName, LastName: data[i].LastName}
                    this.records.push(item);
                }
                this.records.forEach(record => {
                    record.displayName = '';
                    if (record.FirstName) {
                        record.displayName = record.FirstName;
                    }
                    if (record.LastName) {
                        record.displayName = record.displayName+' '+ record.LastName;
                    }
                    if (record.FirstName && record.LastName) {
                        record.displayName = record.FirstName + ' ' + record.LastName;
                    }
                });
                //console.log('records '+JSON.stringify(this.records));

            } else {
                //this.records = data;
                for (let i = 0; i < data.length; i++) {
                    let item = {Id: data[i].Id,displayName: data[i].Name, FirstName: data[i].FirstName, LastName: data[i].LastName}
                    this.records.push(item);
                }
                  

                //console.log('PRojectData'+JSON.stringify(this.records));                 
            }

        } else if (error) {
           
            console.log('ERROR'+JSON.stringify(error));
            this.error = error;
            this.records = undefined;
        }
         
    }

    @api
    get selectedName() {
        return this._selectedName;
    }

    set selectedName(val) {
        if (val) {
            this._selectedName = val;
            this.isValueSelected = true;
        } else {
            this._selectedName = '';
            this.isValueSelected = false;
        }
    }

    // renderedCallback() {
    //     if (this.recordName) {
    //         this.selectedName = this.recordName
    //         this.isValueSelected = true
    //     }
    // }

    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

    onSelect(event) {
       // console.log('PROJECTONSELECT');
        //event.preventdefault();
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        let returnValue = {};
        returnValue.value = selectedId;
        returnValue.name = this.name;
        returnValue.index = this.indexId;
        returnValue.recordName = selectedName;
       //  console.log('selectedId'+selectedId);
         //console.log('selectedName'+selectedName+'name-------->>>>>>>'+this.name);
        this.dispatchEvent( new CustomEvent('lookupselected', {detail:  returnValue }) );
        this.isValueSelected = true;
        this.selectedName = selectedName;
       if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    @api
    handleRemovePill() {
        this.isValueSelected = false;
        let remove = {};
        remove.name = this.name;
        remove.index = this.indexId;
        this.dispatchEvent(new CustomEvent('remove', {detail: remove }))
    }

    @api
    reportValidation() {
        let inputFields = this.template.querySelectorAll("lightning-input");
        let elements = [...inputFields];
        const allValid = elements.reduce((validSoFar, inputCmp) => {
            var fieldValidation = inputCmp.checkValidity();
            inputCmp.reportValidity();
            return validSoFar && fieldValidation;
        }, true);
        return allValid;
    }

    @api
    hasErrors() {
        return this.template.querySelector(".slds-has-error");
    }

    onChange(event) {
        this.searchTerm = event.target.value;
    }

}