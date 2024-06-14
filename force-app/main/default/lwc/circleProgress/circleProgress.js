import { LightningElement, track, api } from 'lwc';
export default class CircleProgress extends LightningElement {
  @api percentage = 0;
  @api numberofhoursfilledthisweek = 0;
  @track canvasEl;
  @track width = 300;
  @track height = 300;

   renderedCallback(){
     this.drawCircle();  
  }



  drawCircle() {
  console.log('drawCircle called');
  console.log('percentage:', this.percentage);

  const canvas = this.template.querySelector('.canvas');
    const ctx = canvas.getContext('2d');
    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;
    const radius = 70;

    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, Math.PI / 2, Math.PI / 2 + 2 * Math.PI * this.percentage / 100, false);
    ctx.lineWidth = 15;
    ctx.strokeStyle = '#0070D2';
    ctx.stroke();

    ctx.beginPath();
     ctx.arc(centerX, centerY, radius, Math.PI / 2, Math.PI / 2 + 2 * Math.PI * this.percentage / 100, true);
    ctx.lineWidth = 15;
    ctx.strokeStyle = '#FAFAF9';
    ctx.stroke();

    ctx.fillStyle = 'black';
    ctx.font = '50px salesforce-sans';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(this.numberofhoursfilledthisweek, centerX, centerY-10);

    ctx.fillStyle = 'black';
    ctx.font = '10px salesforce-sans';
  //  ctx.textAlign = 'center';
  //  ctx.textBaseline = 'middle';
    ctx.fillText('Hours', centerX, centerY + 10);
  } 
}