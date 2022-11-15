import StripeCardNumber from '@salesforce/label/c.Stripe_Card_Number';
import StripeCardNumberError from '@salesforce/label/c.Stripe_Card_Number_Error';
import StripeCvc from '@salesforce/label/c.Stripe_cvc';
import StripeCVCError from '@salesforce/label/c.Stripe_CVC_Error';
import StripeCVChelpText from '@salesforce/label/c.Stripe_CVC_help_text';
import StripeExpiry from '@salesforce/label/c.Stripe_Expiry';
import StripeExpiryError from '@salesforce/label/c.Stripe_Expiry_Error';
import StripeFullName from '@salesforce/label/c.Stripe_Full_Name';
import StripeFullNameError from '@salesforce/label/c.Stripe_Full_Name_Error';
import StripePaymentHeader from '@salesforce/label/c.Stripe_payment';
import StripePaymentButton from '@salesforce/label/c.Stripe_Payment_button';
import StripeReceiptButton from '@salesforce/label/c.Stripe_Receipt_button';
import StripeSuccessPaymentMessage from '@salesforce/label/c.Stripe_Success_Payment_Message';
import StripeErrorPaymentMessage from '@salesforce/label/c.Stripe_Error_Payment_Message';

const labels = {
    StripeCardNumber,
    StripeCardNumberError,
    StripeCvc,
    StripeCVCError,
    StripeCVChelpText,
    StripeExpiry,
    StripeExpiryError,
    StripeFullName,
    StripeFullNameError,
    StripePaymentHeader,
    StripePaymentButton,   
    StripeReceiptButton,
    StripeSuccessPaymentMessage,
    StripeErrorPaymentMessage
};

export {labels};