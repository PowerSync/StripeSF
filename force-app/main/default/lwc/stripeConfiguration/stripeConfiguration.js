import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import config  from '@salesforce/apex/StripeConfiguration.getCustomSettings';
import saveConfig  from '@salesforce/apex/StripeConfiguration.saveCustomSettings';
import testConnection from '@salesforce/apex/StripeConfiguration.checkConnection';

export default class StripeConfiguration extends LightningElement {
    configSettings;
    baseUrl;
    secretKey;
    loader = false;

    async connectedCallback(){
        this.configSettings = await config();
        this.setConfigSettings();
    }

    setConfigSettings(){
        this.baseUrl = this.configSettings.baseUrl;
        if(!this.baseUrl){
            this.baseUrl = 'https://api.stripe.com/';
        }
        this.secretKey = this.configSettings.secretKey;
    }

    async handleSave(){
        this.loader = true;
        try{
            let configs = {};
            configs.id = this.configSettings.id;
            configs.baseUrl = this.template.querySelector('[data-id="baseUrl"]').value;
            configs.secretKey = this.template.querySelector('[data-id="secKey"]').value;
            console.info('configs1: '+JSON.stringify(configs));
            let strRequest = JSON.stringify(configs);
            this.configSettings = await saveConfig({configs: strRequest});
            this.setConfigSettings();
            this.showSuccessToast('Save sucessful');
        }catch(er){
            this.showWarningToast('Save problem');
console.log(er);
        }
        this.loader = false;
    }

    async handleConnection(){
        this.loader = true;
        let isConnect = await testConnection();
        if(isConnect){
                this.showSuccessToast('Successes connection to Stripe');
        } else {
            this.showWarningToast('Fail connection to Stripe');
        }
        this.loader = false;
    }

    showSuccessToast(message) {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showWarningToast(message) {
        const evt = new ShowToastEvent({
            title: 'Warning',
            message: message,
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}