import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class EMS_TM_monthlyreport extends NavigationMixin(LightningElement){
    viewReport( event ) {
     //   console.log('event'+event);
        this[ NavigationMixin.Navigate ]({
            type: 'standard__recordPage',
            attributes: {
                recordId: '00O5e000008dhCOEAY',
                objectApiName: 'Report',
                actionName: 'view'
            }
        });

        console.log('report id'+'00O3C000000IYibUAG');
}
}