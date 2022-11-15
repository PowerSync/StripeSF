/**
 * @description       : 
 * @author            : horobei
 * @group             : 
 * @last modified on  : 08-04-2022
 * @last modified by  : horobei
**/
@IsTest
public class TransactionControllerTest {
    @TestSetup
    static void makeData(){
        Case c = new Case();
        c.Status = 'New';
        c.Origin = 'Phone';
        insert c;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.CloseDate = System.today();
        opp.StageName = 'Qualification';
        insert opp;

        Account acc = new Account();
        acc.Name = 'test ACCOUNT';
        insert acc;

        Contract con = new Contract();
        con.AccountId = acc.Id;
        con.Status = 'Draft';
        con.StartDate = System.today();
        con.ContractTerm = 12;
        insert con;

        Order o = new Order();
        o.AccountId = acc.Id;
        o.ContractId = con.Id;
        o.Status = 'Draft';
        o.EffectiveDate = System.today();
        insert o;


        Transaction__c t = new Transaction__c();
        t.Receipt__c = 'link on receipt';
        t.Status__c = 'Succeeded';
        t.Case__c = c.Id;
        t.Opportunity__c = opp.Id;
        t.Order__c = o.Id;
        insert t;
    }

    /**
    * @description 
    * @author horobei| 08-04-2022 
    **/
    @IsTest
    public static void getTransactionCase(){
        String recordId = [Select Id From Case limit 1].Id;
        TransactionController.TransactionWrapper t = TransactionController.getTransaction(recordId);
        System.assertEquals('Succeeded', t.status, 'Succeeded');
    }

    /**
    * @description 
    * @author horobei| 08-04-2022 
    **/
    @IsTest
    public static void getTransactionOpportunity(){
        String recordId = [Select Id From Opportunity limit 1].Id;
        TransactionController.TransactionWrapper  t = TransactionController.getTransaction(recordId);
        System.assertEquals('Succeeded', t.status, 'Succeeded');
    }

    /**
    * @description 
    * @author horobei | 08-04-2022 
    **/
    @IsTest
    public static void getTransactionOrder(){
        String recordId = [Select Id From Order limit 1].Id;
        TransactionController.TransactionWrapper  t = TransactionController.getTransaction(recordId);
        System.assertEquals('Succeeded', t.status, 'Succeeded');
    }

    /**
    * @description 
    * @author horobei| 08-04-2022 
    **/
    @IsTest
    public static void getTransactionNull(){
        String recordId = [Select Id From Contract limit 1].Id;
        TransactionController.TransactionWrapper  t = TransactionController.getTransaction(recordId);
        System.assertEquals(null, t, 'null');
    }
}