import { LightningElement,api,wire } from 'lwc';
import getTheCaseViewDetails from '@salesforce/apex/newServiceRequestController.getTheCaseViewDetails';
export default class CustomCaseView extends LightningElement {
@api recordId;
datareturned;
specialleaves = false;
others = false;
techs = false;
resign = false;
changeOfDetails = false;
@wire(getTheCaseViewDetails, {caseid:'$recordId'})
    wiredCase({data, error}){
        if(data){
       this.specialleaves = data.isSpecialLeaves;
       this.others = data.isOtherType;
       this.techs = data.isTechProblemType;
       this.resign = data.isResign;
       this.changeOfDetails = data.isChangeOfDetails;
        }
        else if (error) {
            console.log('===error====='+JSON.stringify(error));
        }
}
}