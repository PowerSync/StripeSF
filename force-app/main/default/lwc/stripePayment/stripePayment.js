import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createPayment from '@salesforce/apex/StripeCheckout.createPayment';
import getTransactionPayment from '@salesforce/apex/TransactionController.getTransaction';
import getRecord from '@salesforce/apex/StripePaymentController.getRecord';

import { labels } from "c/customLabelUtility";

export default class StripePayment extends LightningElement {
    @api paymentAmountField;
    @api bankPayerField;
    @api creditCardPayerFied;

    @api recordId;
    record;

    payerId;
    paymentAmount;

    paymentCard = {};
    url;
    isPayment;
    loader = false;
    transactionRecord = {};
    labels = labels;

    @api get checkField() {
       
    }

    async connectedCallback(){
        console.log('Amount field: ', this.paymentAmountField);
        console.log('Holder field: ', this.bankPayerField);
        this.record = await getRecord({recordId: this.recordId, amountField: this.paymentAmountField, payerField: this.bankPayerField });

        console.log('record: ', this.record);

        this.payerId = this.record[this.bankPayerField];
        this.paymentAmount = this.record[this.paymentAmountField];
        console.log('payerId: ', this.payerId);
        console.log('amount: ', this.paymentAmount);

        this.getTransaction();
    }
 
    async getTransaction(){
        this.transactionRecord = await getTransactionPayment({recordId: this.recordId});
        if(this.transactionRecord) {
            this.url = this.transactionRecord.receipt;
            this.isPayment = this.transactionRecord.status == 'Succeeded';
        }
    }

    async handlerPayment(){
        this.loader = true;
        if(this.validateConfiguration()){
            let paymentCard = JSON.parse(JSON.stringify(this.paymentCard));
            if(paymentCard){
                let payment = JSON.stringify(paymentCard.value);
                try{
                    let response = await createPayment({recordId: this.recordId, paymentField: this.paymentField, paymentCard: payment});
                    this.getTransaction();
                    if(response){
                        this.showSuccessToast();
                    } else {
                        this.showWarningToast();
                    }
                    
                    console.log(response);
                } catch(e){
                    this.showWarningToast();
                }
            }
        }
        this.loader = false;
    }

    validateConfiguration(){
        if(!this.paymentField) {
            this.showWarningToastValidation('Payment field can not be empty');
            return false;
        }
        return true;
    }

    handlerReceipt(){
        window.open(this.url, "_blank", "resizable=yes,top=250,left=500,width=700,height=1100");
    }

    showWarningToastValidation(message) {
        const evt = new ShowToastEvent({
            title: 'Warning',
            message: message,
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: this.labels.StripeSuccessPaymentMessage,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showWarningToast() {
        const evt = new ShowToastEvent({
            title: 'Warning',
            message: this.labels.StripeErrorPaymentMessage,
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    paymentComplite(event){
        this.paymentCard = event.detail;
    }

    paymentInComplite(event){
        this.paymentCard = event.detail;
    }

    bankPaymentComplite(event) {
        console.log('bank payment completed: ', event);
        this.showNotification('Success', `Bank payment succesfully completed. PaymentId: ${event.detail}`, 'success');
    }

    bankPaymentIncomplite(event){
        console.log('bank payment incomplete: ', event);
        this.showNotification('Error', `Something went wrong... ${event.detail}`, 'error');
    }

    showNotification(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }
}