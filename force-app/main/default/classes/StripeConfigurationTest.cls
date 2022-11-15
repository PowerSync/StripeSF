/**
 * @description       : 
 * @author            : horobei
 * @group             : 
 * @last modified on  : 08-04-2022
 * @last modified by  : horobei
**/
@IsTest
public class StripeConfigurationTest {

    /**
    * @description 
    * @author horobei | 08-04-2022 
    **/
    @TestSetup
    static void makeData(){
        Stripe_Configurations__c configs = new Stripe_Configurations__c();
        configs.Base_URL__c = 'https://api.stripe.com/';
        configs.Secret_key__c = 'sk_test_51KqHmeAFCeEkMgycsn2PmKTZ8KcZzOMoWDvWMoSuTyxUCdvESdt6vzhBl1CjrYROKufARhZVfoSwkdrfrrrGMwXw00yfHopR7k';
        insert configs;
    }
   
    /**
    * @description 
    * @author horobei | 08-04-2022 
    **/
    @IsTest
    public static void getCustomSettingsTest(){
        StripeConfiguration.Configuration config = StripeConfiguration.getCustomSettings();
        System.assertEquals('https://api.stripe.com/', config.baseUrl, 'Success');
    }

    /**
    * @description 
    * @author Chorobei | 08-04-2022 
    **/
    @IsTest
    public static void saveCustomSettingsTest(){
        StripeConfiguration.Configuration getConfigs = StripeConfiguration.getCustomSettings();
        String newConfig  = '{"id":"'+getConfigs.id+'","baseUrl":"https://api.stripe.com/","secretKey":"secretKey"}';
        StripeConfiguration.Configuration updatedConfig = StripeConfiguration.saveCustomSettings(newConfig);
        System.assertEquals('secretKey', updatedConfig.secretKey, 'Success');
    }

    /**
    * @description 
    * @author horobei | 08-04-2022 
    **/
    @IsTest
    public static void checkConnectionTest() {
        Test.setMock(HttpCalloutMock.class, new checkConnectionMock());
        Test.startTest();
            Boolean isConnection = StripeConfiguration.checkConnection();
            System.assertEquals(true, isConnection, 'Success');
        Test.stopTest();
    }

    /**
    * @description 
    * @author horobei | 08-04-2022 
    **/
    @IsTest
    public static void checkConnectionTestFail() {
        Test.setMock(HttpCalloutMock.class, new checkConnectionMockFail());
        Test.startTest();
            Boolean isConnection = StripeConfiguration.checkConnection();
            System.assertEquals(false, isConnection, 'Fail');
        Test.stopTest();
    }

    /**
     * @description CheckConnectionMock
     **/
    public class CheckConnectionMock implements HttpCalloutMock {
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
            resp.setBody('{"id":"pi_3LJDBEAFCeEkMgyc0lce8Z1U"}');
            return resp;
        }
    }

    /**
     * @description CheckConnectionMockFail
     **/
    public class CheckConnectionMockFail implements HttpCalloutMock {
        /**
        * @description 
        * @author horobei | 08-04-2022 
        * @param req 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest req){ 
            HTTPResponse resp = new HTTPResponse();
            resp.setStatusCode(400);
            resp.setStatus('Bad Request');
            resp.setBody('{"id":"pi_3LJDBEAFCeEkMgyc0lce8Z1U"}');
            return resp;
        }
    }
}