/**
 * @description       : 
 * @author            : horobei
 * @group             : 
 * @last modified on  : 08-08-2022
 * @last modified by  : horobei
**/
public without sharing class StripeCheckout {
    private static String baseUrl;
    private static String secretKey;
    public static String lastResponse;
    /**
    * @description 
    * @author horobei| 08-04-2022 
    **/
    public class CustomException extends Exception {} 
    

    /**
    * @description 
    * @author horobei| 08-04-2022 
    * @param recordId 
    * @param paymentField 
    * @param paymentCard 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean createPayment(String recordId, String paymentField, String paymentCard){
        PaymentCard paymentCardObj = (PaymentCard) JSON.deserialize(paymentCard, PaymentCard.class);
        setConfiguration();
        String objApiName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();  
        Transaction__c t = setPaymentObject(objApiName, recordId);
        try {
            String query = 'Select Name, '+String.escapeSingleQuotes(paymentField)+' From '+String.escapeSingleQuotes(objApiName)+' WHERE Id = :recordId limit 1';
            SObject obj = Database.query(query);
            //create transaction code object
            t.Status__c = 'Draft';
            PaymentIntents pi = createPaymentIntents(obj, paymentField);
            //update code object
            t.Status__c = 'Incomplete';
            t.Payment_Intent_ID__c = pi.id;
            PaymentMethod pm = createPaymentMethod(paymentCardObj);
            
            //update code object
            t.Payment_Method_ID__c = pm.id;
            HttpResponse confirmPaymentIntens = confirmPaymentIntens(pi, pm);
            PaymentIntents piConfirm = (PaymentIntents) JSON.deserialize(confirmPaymentIntens.getBody(), PaymentIntents.class);
            // System.debug('piConfirm--> '+piConfirm);
            t.Confirm_Payment_Intens__c = confirmPaymentIntens.getBody();
            if (confirmPaymentIntens.getStatus() == 'OK') {
                if(piConfirm.charges.data.size()>0 && !String.isBlank(piConfirm.charges.data[0].receipt_url)){
                    t.Status__c = 'Succeeded';
                    t.Amount__c = piConfirm.amount / 100;
                    t.Receipt__c = piConfirm.charges.data[0].receipt_url;
                }
                
            } else {
                t.Status__c = 'Error';
            }
            return true;

        } catch (Exception e) {
            t.Apex_Class__c = 'StripeCheckout';
            t.Line_Number__c = e.getLineNumber();
            t.Exception__c = e.getMessage();
            t.Last_Stripe_Response__c = lastResponse;
            return false;
        } finally {
            if(Transaction__c.SObjectType.getDescribe().isAccessible() && 
            Transaction__c.SObjectType.getDescribe().isCreateable() && 
                Schema.SObjectType.Transaction__c.fields.Case__c.isCreateable() && 
                Schema.SObjectType.Transaction__c.fields.Opportunity__c.isCreateable() && 
                Schema.SObjectType.Transaction__c.fields.Order__c.isCreateable() && 
                Schema.SObjectType.Transaction__c.fields.Status__c.isCreateable() && 
                Schema.SObjectType.Transaction__c.fields.Payment_Intent_ID__c.isCreateable() && 
                Schema.SObjectType.Transaction__c.fields.Payment_Method_ID__c.isCreateable() && 
                Schema.SObjectType.Transaction__c.fields.Receipt__c.isCreateable() && 
                Schema.SObjectType.Transaction__c.fields.Apex_Class__c.isCreateable() && 
                Schema.SObjectType.Transaction__c.fields.Line_Number__c.isCreateable() && 
                Schema.SObjectType.Transaction__c.fields.Exception__c.isCreateable() && 
                Schema.SObjectType.Transaction__c.fields.Last_Stripe_Response__c.isCreateable() && 
                Schema.SObjectType.Transaction__c.fields.Amount__c.isCreateable() ){
                insert t;
            }
        }
    }

    /**
    * @description 
    * @author horobei | 08-04-2022 
    **/
    private static void setConfiguration(){
        Stripe_Configurations__c configs = Stripe_Configurations__c.getInstance();
        baseUrl = configs.Base_URL__c;
        secretKey = configs.Secret_key__c;
    }

    /**
    * @description 
    * @author horobei | 08-04-2022 
    * @param objApiName 
    * @param recordId 
    * @return Transaction__c 
    **/
    private static Transaction__c setPaymentObject(String objApiName, String recordId){
        Transaction__c t = new Transaction__c();
        switch on objApiName {
            when 'Case' {
                t.Case__c = recordId;
            }
            when 'Opportunity' {
                t.Opportunity__c = recordId;
            }
            when 'Order' {
                t.Order__c = recordId;
            }
        }
        return t;
    }

   
    /**
    * @description 
    * @author horobei | 08-04-2022 
    * @param obj 
    * @param paymentFieldj 
    * @return PaymentIntents 
    **/
    public static PaymentIntents createPaymentIntents(SObject obj, String paymentFieldj) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(baseUrl+'v1/payment_intents');
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + secretKey);
            Decimal dValue = (Decimal) obj.get(paymentFieldj) * 100;
            Integer intConvertedValue = dValue.intValue();
            String payLoad =    'amount='+intConvertedValue + 
                                '&currency=usd';
            request.setBody(payLoad);
            HttpResponse response = http.send(request);
            // System.debug('pi--> '+response.getBody());
            if (response.getStatus() == 'OK') {
                return (PaymentIntents) JSON.deserialize(response.getBody(), PaymentIntents.class);
            }else {
                lastResponse = 'PaymentIntents: '+response.getBody();
                return null;
            }
    }
    
    
    /**
    * @description 
    * @author horobei | 08-04-2022 
    * @param paymentCard 
    * @return PaymentMethod 
    **/
    public static PaymentMethod createPaymentMethod(PaymentCard paymentCard) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(baseUrl+'v1/payment_methods');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + secretKey);
        String numberCard = paymentCard.cardNumber.replaceAll( '\\s+', '');
        List<String> exp = paymentCard.cardExpiry.split(' / ');
        String year = exp[1].length() == 2 ? exp[1] : exp[1].right(2);
        String payLoad =    'type=card'
                        +   '&card[exp_month]='+exp[0]
                        +   '&card[exp_year]='+year
                        +   '&card[number]='+numberCard
                        +   '&card[cvc]='+paymentCard.cardCVV;
        request.setBody(payLoad);
        HttpResponse response = http.send(request);
        if (response.getStatus() == 'OK') {
            // System.debug('pm--> '+response);
            return (PaymentMethod) JSON.deserialize(response.getBody(), PaymentMethod.class);
        } else {
            lastResponse = 'PaymentMethod: '+response.getBody();
            return null;
        }
    }

    
    /**
    * @description 
    * @author horobei| 08-04-2022 
    * @param pi 
    * @param pm 
    * @return HttpResponse 
    **/
    public static HttpResponse confirmPaymentIntens(PaymentIntents pi, PaymentMethod pm) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(baseUrl+'v1/payment_intents/'+pi.id+'/confirm');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + secretKey);
        String payLoad = 'payment_method='+pm.id;
        request.setBody(payLoad);
        HttpResponse response = http.send(request);
        // System.debug('response.getBody()' +response.getBody());
        if (response.getStatus() == 'OK') {
            return response;
        }else {
            lastResponse = 'PaymentIntens:' +response.getBody();
            return null;
        }
    }

    
    /** @description PaymentCard **/
    public class PaymentCard{
        /** @description cardNumber **/
        @AuraEnabled
        public String cardNumber {get;set;}
         /** @description cardHolderName **/
        @AuraEnabled
        public String cardHolderName {get;set;}
         /** @description cardCVV **/
        @AuraEnabled
        public String cardCVV {get;set;}
         /** @description cardExpiry **/
        @AuraEnabled
        public String cardExpiry {get;set;}
         /** @description cardType **/
        @AuraEnabled
        public String cardType {get;set;}
    }
    /** @description PaymentIntents **/
    public class PaymentIntents {
        /** @description id **/
        public String id {get;set;}
         /** @description client_secret **/
        public String client_secret {get;set;}
         /** @description amount **/
        public Decimal amount {get;set;}
         /** @description charges **/
        public Changes charges {get;set;}
         /** @description type **/
        public String type {get;set;}
    }
    /** @description PaymentMethod **/
    public class PaymentMethod {
        /** @description id **/
        public String id {get;set;}
    }
    /** @description Changes **/
    public class Changes {
        /** @description data **/
        public List<Data> data {get;set;}
    }
    /** @description Data **/
    public class Data {
        /** @description id  **/
        public String id {get;set;}
        /** @description receipt_url **/
        public String receipt_url {get;set;}
    }
}