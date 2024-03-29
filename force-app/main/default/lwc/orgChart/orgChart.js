import { LightningElement,api } from 'lwc';

export default class OrgChart extends LightningElement {
 @api employee;
   get hasDirectReports() {
        return this.employee.directReportesUnderme && this.employee.directReportesUnderme.length > 0;
    }

    get hasReportsTo() {
        return this.employee.meReportsToList;
    }

    get hasHierarchy() {
        return this.hasDirectReports || this.hasReportsTo;
    }
}