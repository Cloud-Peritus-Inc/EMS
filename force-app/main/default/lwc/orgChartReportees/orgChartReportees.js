import { LightningElement, api, wire, track } from 'lwc';
import getUserReportees from '@salesforce/apex/resourceTileController.getUserReportees';
export default class OrgChartReportees extends LightningElement {
reportees;
str;
@api resourceId;
 


@wire(getUserReportees, { userId: '$resourceId'})
    wiredReportees({ error, data }) {
        if (data) {
            //this.reportees = data;
            if(data.length >0){
                this.reportees = data;
            }else{
            this.reportees = '';
            }
            
            console.log('======data====='+data);
           console.log('======reporteesList====='+JSON.stringify(data));
           //console.log('======reporteesList====='+JSON.stringify(data[0].resourceName));
            
        } else if (error) {
            console.log(error);
        }
    }

}