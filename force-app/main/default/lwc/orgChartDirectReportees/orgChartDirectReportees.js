import { LightningElement, api, wire, track } from 'lwc';

export default class OrgChartDirectReportees extends LightningElement {
  @api employee = null;
  expandedReportees = false;
  resourceId;
  @track iconName = 'action:new';
  @track altText = 'Expand';
  @track title = 'Expand';


  get hasDirectReports() {
      return this.employee.directReportesUnderme && this.employee.directReportesUnderme.length > 0;
  }

  get hasReportsTo() {
      return this.employee != null && this.employee.meReportsToList;
  }

  get hasHierarchy() {
      return this.employee != null && this.employee.directReportesUnderme;
  }

  get hasEmployeeURL() {
      return this.employee != null && this.employee.resourcePhotoURL;
  }

  handleButtonClick(event) {
      const { target } = event;
      const currentIconName = target.iconName || '';
      this.resourceId = event.target.dataset.resourceId;
      console.log('ResourceId->' ,this.resourceId);

      this.template.querySelectorAll('[data-name="' + this.resourceId + '"]').forEach(ele => {
          //console.log('eleId' + ele.id);
          ele.style.display = '';
      });

      if (currentIconName === 'action:new') {
          this.iconName = 'action:remove';
          event.target.iconName='action:remove'
          this.altText = 'Close';
          this.title = 'Close';
          this.template.querySelectorAll('[data-name="' + this.resourceId + '"]').forEach(ele => {
              ele.style.display = 'block';
          });
      } else {
          this.iconName = 'action:new';
          event.target.iconName='action:new'
          this.altText = 'Expand';
          this.title = 'Expand';
          this.template.querySelectorAll('[data-name="' + this.resourceId + '"]').forEach(ele => {
              ele.style.display = 'none';
          });
      }
  }
}