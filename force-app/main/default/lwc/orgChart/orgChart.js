import { LightningElement,api } from 'lwc';

export default class OrgChart extends LightningElement {
 @api employee = null;
   get hasDirectReports() {
        return this.employee.directReportesUnderme && this.employee.directReportesUnderme.length > 0;
    }

    get hasReportsTo() {
            return this.employee != null  && this.employee.meReportsToList;    
    }

    get hasHierarchy() {
        return this.employee != null  && this.employee.directReportesUnderme;
    }

    get hasEmployeeURL() {
        return this.employee != null  && this.employee.resourcePhotoURL;
    }

}