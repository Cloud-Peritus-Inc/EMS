import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import holidayimage from '@salesforce/resourceUrl/holidayimage';
export default class Calenderpto extends NavigationMixin(LightningElement) {
@api heading
imagelogo = holidayimage;

    handleClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/pto-calender'
            }
        });
}

}