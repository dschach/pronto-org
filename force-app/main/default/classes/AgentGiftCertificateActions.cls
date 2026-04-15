/**
 * AgentGiftCertificateActions
 *
 * Creates Gift_Certificate__c records and returns a DTO (and JSON) instead of an SObject
 * collection to avoid partial serialization issues in some clients.
 *
 * Bulk model:
 * This is intentionally a "singleton" action: we only consider requests[0] and return
 * a single Response row.
 */
public with sharing class AgentGiftCertificateActions {
    public class Request {
        @InvocableVariable(
            label='Verified Customer Id'
            description='The Contact Id for the verified customer that will be set as Gift_Certificate__c.Recipient__c.'
            required=true
        )
        public Id verifiedCustomerId;

        @InvocableVariable(
            label='Gift Value'
            description='The gift certificate monetary value (Gift_Certificate__c.Value__c / Original_Value__c / Remaining_Value__c).'
            required=true
        )
        public Decimal giftValue;

        @InvocableVariable(
            label='Gift Type'
            description='Gift_Certificate__c.Type__c picklist value (for example: Promotion, Recovery, Purchased).'
            required=true
        )
        public String giftType;

        @InvocableVariable(
            label='Source Channel'
            description='Gift_Certificate__c.Source_Channel__c value (for example: Agentforce).'
            required=false
        )
        public String sourceChannel;

        @InvocableVariable(
            label='Case Id'
            description='Optional Case Id to associate with the gift certificate (Gift_Certificate__c.Issued_For_Case__c).'
            required=false
        )
        public Id caseId;

        @InvocableVariable(
            label='Business Account Id'
            description='Optional merchant/business account (Gift_Certificate__c.Business_Account__c).'
            required=false
        )
        public Id businessAccountId;

        @InvocableVariable(
            label='Storefront Id'
            description='Optional storefront/restaurant (Gift_Certificate__c.Storefront__c).'
            required=false
        )
        public Id storefrontId;
    }

    public class GiftCertificateSummary {
        @InvocableVariable(label='Gift Certificate Id' description='The created Gift_Certificate__c Id.')
        public Id id;

        @InvocableVariable(label='Record Number' description='Gift_Certificate__c.Name (auto-number).')
        public String recordNumber;

        @InvocableVariable(label='Recipient Id' description='Gift_Certificate__c.Recipient__c.')
        public Id recipientId;

        @InvocableVariable(label='Value' description='Gift_Certificate__c.Value__c.')
        public Decimal value;

        @InvocableVariable(label='Type' description='Gift_Certificate__c.Type__c.')
        public String type;

        @InvocableVariable(label='Status' description='Gift_Certificate__c.Status__c.')
        public String status;

        @InvocableVariable(label='Source Channel' description='Gift_Certificate__c.Source_Channel__c.')
        public String sourceChannel;
    }

    public class Response {
        @InvocableVariable(
            label='Success'
            description='True when the action executed successfully. False when inputs are missing/invalid or an unexpected error occurred.'
        )
        public Boolean success;

        @InvocableVariable(
            label='Message'
            description='User-readable status message. On errors, explains what was missing or what failed.'
        )
        public String message;

        @InvocableVariable(
            label='Gift Certificate'
            description='The created Gift_Certificate__c record. Display this as a clickable record link.'
        )
        public Gift_Certificate__c giftCertificate;

        @InvocableVariable(
            label='Gift Certificates'
            description='A list of gift certificate summaries created by this action.'
        )
        public List<GiftCertificateSummary> giftCertificates;

        @InvocableVariable(
            label='Gift Certificates JSON'
            description='JSON-serialized version of giftCertificates for clients that prefer JSON parsing.'
        )
        public String giftCertificatesJson;
    }

    @InvocableMethod(
        label='Create Gift Certificate'
        description='Create a Gift_Certificate__c record and return a DTO/JSON for reliable serialization.'
    )
    public static List<Response> invoke(List<Request> requests) {
        Response out = new Response();
        out.giftCertificates = new List<GiftCertificateSummary>();
        out.success = false;
        out.message = null;

        Request req = (requests != null && !requests.isEmpty()) ? requests[0] : null;
        try {
            if (req == null || req.verifiedCustomerId == null) {
                out.message = 'verifiedCustomerId is required.';
                out.giftCertificatesJson = JSON.serialize(out.giftCertificates);
                return new List<Response>{ out };
            }
            if (req.giftValue == null) {
                out.message = 'giftValue is required.';
                out.giftCertificatesJson = JSON.serialize(out.giftCertificates);
                return new List<Response>{ out };
            }
            if (String.isBlank(req.giftType)) {
                out.message = 'giftType is required.';
                out.giftCertificatesJson = JSON.serialize(out.giftCertificates);
                return new List<Response>{ out };
            }

            Gift_Certificate__c gc = new Gift_Certificate__c();
            gc.Recipient__c = req.verifiedCustomerId;
            gc.Value__c = req.giftValue;
            gc.Original_Value__c = req.giftValue;
            gc.Remaining_Value__c = req.giftValue;
            gc.Type__c = req.giftType;
            gc.Source_Channel__c = String.isBlank(req.sourceChannel) ? 'Agentforce' : req.sourceChannel;
            gc.Issued_For_Case__c = req.caseId;
            gc.Business_Account__c = req.businessAccountId;
            gc.Storefront__c = req.storefrontId;

            // Default status for demo friendliness if not set by automation.
            if (gc.Status__c == null) {
                gc.Status__c = 'Active';
            }

            insert gc;

            // Re-query Name (auto-number) + ensure fields are populated as expected.
            gc = [
                SELECT Id, Name, Recipient__c, Value__c, Type__c, Status__c, Source_Channel__c
                FROM Gift_Certificate__c
                WHERE Id = :gc.Id
                LIMIT 1
            ];

            GiftCertificateSummary s = new GiftCertificateSummary();
            s.id = gc.Id;
            s.recordNumber = gc.Name;
            s.recipientId = gc.Recipient__c;
            s.value = gc.Value__c;
            s.type = gc.Type__c;
            s.status = gc.Status__c;
            s.sourceChannel = gc.Source_Channel__c;
            out.giftCertificates.add(s);

            out.giftCertificate = gc;
            out.success = true;
            out.message = 'Created $' + gc.Value__c.setScale(2) + ' ' + gc.Type__c
                + ' gift certificate "' + gc.Name + '". Status: ' + gc.Status__c + '.';
        } catch (Exception e) {
            out.success = false;
            out.message = e.getMessage();
        }

        out.giftCertificatesJson = JSON.serialize(out.giftCertificates);
        return new List<Response>{ out };
    }
}