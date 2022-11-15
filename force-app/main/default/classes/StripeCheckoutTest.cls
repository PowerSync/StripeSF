/**
 * @description       : 
 * @author            : horobei
 * @group             : 
 * @last modified on  : 08-04-2022
 * @last modified by  : horobei
**/
@IsTest
public class StripeCheckoutTest {

    /**
    * @description 
    * @author horobei| 08-04-2022 
    **/
    @TestSetup
    static void makeData(){
        Opportunity opp = new Opportunity();
        opp.Name = 'Opp test';
        opp.CloseDate = System.today();
        opp.StageName = 'Qualification';
        opp.Amount = 123.34;
        insert opp;
    }

    /**
    * @description 
    * @author horobei | 08-04-2022 
    **/
    @IsTest
    public static void createPaymentTest(){
        String  recordId = [Select Id FROM Opportunity limit 1].Id;
        String paymentCard = '{"cardNumber":"4242424242424242","cardHolderName":"Test test","cardCVV":"235","cardExpiry":"02 / 29","cardType":"visa"}';//
        Test.setMock(HttpCalloutMock.class, new ConfirmPaymentIntentsMock());
        Test.startTest();
            Boolean isPayment = StripeCheckout.createPayment(recordId, 'Amount', paymentCard);
            System.assertEquals(true, isPayment, 'Success');
        Test.stopTest();
       
    }

    /**
    * @description 
    * @author horobei| 08-04-2022 
    **/
    @IsTest
    public static void createPaymentWrongTest(){
        String  recordId = [Select Id FROM Opportunity limit 1].Id;
        String paymentCard = '{"cardNumber":"4242424242424242","cardHolderName":"Test test","cardCVV":"235","cardExpiry":"02 / 29","cardType":"visa"}';
        Test.setMock(HttpCalloutMock.class, new ConfirmPaymentIntentsWrongMock());
        Test.startTest();
            Boolean isPayment = StripeCheckout.createPayment(recordId, 'Amount', paymentCard);
            System.assertEquals(false, isPayment, 'Wrong');
        Test.stopTest();
       
    }

    /**
    * @description 
    * @author horobei| 08-04-2022 
    **/
    public class PaymentIntentsMock implements HttpCalloutMock {
        /**
        * @description 
        * @author horobei | 08-04-2022 
        * @param req 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest req){ 
            HTTPResponse resp = new HTTPResponse();
            resp.setStatusCode(200);
            resp.setStatus('OK');
            resp.setBody('{"id":"pi_3LJDBEAFCeEkMgyc0lce8Z1U","object":"payment_intent","amount":24612,"amount_capturable":0,"amount_details":{"tip":{}},"amount_received":0,"application":null,"application_fee_amount":null,"automatic_payment_methods":null,"canceled_at":null,"cancellation_reason":null,"capture_method":"automatic","charges":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges?payment_intent=pi_3LJDBEAFCeEkMgyc0lce8Z1U"},"client_secret":"pi_3LJDBEAFCeEkMgyc0lce8Z1U_secret_4sHTEB6UpEMAVn5Z2vkrh8TBs","confirmation_method":"automatic","created":1657271336,"currency":"usd","customer":null,"description":null,"invoice":null,"last_payment_error":null,"livemode":false,"metadata":{},"next_action":null,"on_behalf_of":null,"payment_method":null,"payment_method_options":{"card":{"installments":null,"mandate_options":null,"network":null,"request_three_d_secure":"automatic"}},"payment_method_types":["card"],"processing":null,"receipt_email":null,"review":null,"setup_future_usage":null,"shipping":null,"source":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"status":"requires_payment_method","transfer_data":null,"transfer_group":null}');
            return resp;
        }
    }

    /**
    * @description 
    * @author horobei| 08-04-2022 
    **/
    public class PaymentMethodMock implements HttpCalloutMock {
        /**
        * @description 
        * @author horobei | 08-04-2022 
        * @param req 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest req){ 
            HTTPResponse resp = new HTTPResponse();
            resp.setStatusCode(200);
            resp.setStatus('OK');
            resp.setBody('{"id":"pm_1LJDBEAFCeEkMgycnwQxIDEB","object":"payment_method","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null},"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":null,"cvc_check":"unchecked"},"country":"US","exp_month":2,"exp_year":2023,"fingerprint":"o2vYxLrnn5zXfebi","funding":"credit","generated_from":null,"last4":"4242","networks":{"available":["visa"],"preferred":null},"three_d_secure_usage":{"supported":true},"wallet":null},"created":1657271336,"customer":null,"livemode":false,"metadata":{},"type":"card"}');
            return resp;
        }
    }

    /**
    * @description 
    * @author horobei| 08-04-2022 
    **/
    public class ConfirmPaymentIntentsMock implements HttpCalloutMock {
        /**
        * @description 
        * @author horobei | 08-04-2022 
        * @param req 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest req){ 
            HTTPResponse resp = new HTTPResponse();
            resp.setStatusCode(200);
            resp.setStatus('OK');
            resp.setBody('{"id":"pi_3LJDBEAFCeEkMgyc0lce8Z1U","object":"payment_intent","amount":24612,"amount_capturable":0,"amount_details":{"tip":{}},"amount_received":24612,"application":null,"application_fee_amount":null,"automatic_payment_methods":null,"canceled_at":null,"cancellation_reason":null,"capture_method":"automatic","charges":{"object":"list","data":[{"id":"ch_3LIXsnAFCeEkMgyc0Ye6R0Qq","object":"charge","amount":24612,"amount_captured":24612,"amount_refunded":0,"application":null,"application_fee":null,"application_fee_amount":null,"balance_transaction":"txn_3LIXsnAFCeEkMgyc0g717hHR","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null},"calculated_statement_descriptor":"Stripe","captured":true,"created":1657112591,"currency":"usd","customer":null,"description":null,"destination":null,"dispute":null,"disputed":false,"failure_balance_transaction":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"normal","risk_score":44,"seller_message":"Payment complete.","type":"authorized"},"paid":true,"payment_intent":"pi_3LIXsnAFCeEkMgyc0aFu89TZ","payment_method":"pm_1LIXsoAFCeEkMgycyxPwIkyM","payment_method_details":{"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":null,"cvc_check":"pass"},"country":"US","exp_month":2,"exp_year":2033,"fingerprint":"o2vYxLrnn5zXfebi","funding":"credit","installments":null,"last4":"4242","mandate":null,"network":"visa","three_d_secure":null,"wallet":null},"type":"card"},"receipt_email":null,"receipt_number":null,"receipt_url":"https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xS3FIbWVBRkNlRWtNZ3ljKJCQlpYGMga1Y6ftf2U6LBaIli8Tii65k8XnELrvDe_oW-gi8EXqIdveaZiq4kMv_oTtvRqrBvkS1w2v","refunded":false,"refunds":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges/ch_3LIXsnAFCeEkMgyc0Ye6R0Qq/refunds"},"review":null,"shipping":null,"source":null,"source_transfer":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"status":"succeeded","transfer_data":null,"transfer_group":null}],"has_more":false,"total_count":1,"url":"/v1/charges?payment_intent=pi_3LIXsnAFCeEkMgyc0aFu89TZ"},"client_secret":"pi_3LIXsnAFCeEkMgyc0aFu89TZ_secret_iZU6zYTwm9Cn1NntMt0tmFIrs","confirmation_method":"automatic","created":1657112589,"currency":"usd","customer":null,"description":null,"invoice":null,"last_payment_error":null,"livemode":false,"metadata":{},"next_action":null,"on_behalf_of":null,"payment_method":"pm_1LIXsoAFCeEkMgycyxPwIkyM","payment_method_options":{"card":{"installments":null,"mandate_options":null,"network":null,"request_three_d_secure":"automatic"}},"payment_method_types":["card"],"processing":null,"receipt_email":null,"review":null,"setup_future_usage":null,"shipping":null,"source":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"status":"succeeded","transfer_data":null,"transfer_group":null}');
            return resp;
        }
    }

    /**
    * @description 
    * @author horobei| 08-04-2022 
    **/
    public class ConfirmPaymentIntentsWrongMock implements HttpCalloutMock {
        /**
        * @description 
        * @author horobei | 08-04-2022 
        * @param req 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest req){ 
            HTTPResponse resp = new HTTPResponse();
            resp.setStatusCode(200);
            resp.setStatus('OK');
            resp.setBody('');
            return resp;
        }
    }
}