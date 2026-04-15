/**
 * AgentReviewActions
 *
 * Creates Review__c records and returns DTOs/JSON to avoid partial serialization of
 * SObject collection outputs in some clients.
 *
 * Bulk model:
 * This is intentionally a "singleton" action: we only consider requests[0] and return
 * a single Response row.
 */
public with sharing class AgentReviewActions {
    public class Request {
        @InvocableVariable(
            label='Verified Customer Id'
            description='The Contact Id for the verified customer that will be set as Review__c.Customer__c.'
            required=true
        )
        public Id verifiedCustomerId;

        @InvocableVariable(
            label='Storefront Id'
            description='The Storefront__c Id that will be set as Review__c.Storefront__c.'
            required=true
        )
        public Id storefrontId;

        @InvocableVariable(
            label='Rating'
            description='Numeric rating (typically 1–5) stored in Review__c.Rating__c.'
            required=true
        )
        public Integer rating;

        @InvocableVariable(
            label='Review Comment'
            description='Free-form review comment stored in Review__c.Comments__c.'
            required=false
        )
        public String reviewComment;

        @InvocableVariable(
            label='Case Id'
            description='Optional case context. Included as input for parity with the Flow, but not stored by default unless your org has automation.'
            required=false
        )
        public Id caseId;
    }

    public class ReviewSummary {
        @InvocableVariable(label='Review Id' description='The created Review__c Id.')
        public Id id;

        @InvocableVariable(label='Record Number' description='Review__c.Name (auto-number).')
        public String recordNumber;

        @InvocableVariable(label='Storefront Id' description='Review__c.Storefront__c.')
        public Id storefrontId;

        @InvocableVariable(label='Customer Id' description='Review__c.Customer__c.')
        public Id customerId;

        @InvocableVariable(label='Rating' description='Review__c.Rating__c.')
        public Integer rating;

        @InvocableVariable(label='Comments' description='Review__c.Comments__c.')
        public String comments;

        @InvocableVariable(label='Status' description='Review__c.Status__c.')
        public String status;
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
            label='Reviews'
            description='A list of review summaries created by this action.'
        )
        public List<ReviewSummary> reviews;

        @InvocableVariable(
            label='Reviews JSON'
            description='JSON-serialized version of reviews for clients that prefer JSON parsing.'
        )
        public String reviewsJson;
    }

    @InvocableMethod(
        label='Leave Review'
        description='Create a Review__c record and return a DTO/JSON for reliable serialization.'
    )
    public static List<Response> invoke(List<Request> requests) {
        Response out = new Response();
        out.reviews = new List<ReviewSummary>();
        out.success = false;
        out.message = null;

        Request req = (requests != null && !requests.isEmpty()) ? requests[0] : null;

        try {
            if (req == null || req.verifiedCustomerId == null) {
                out.message = 'verifiedCustomerId is required.';
                out.reviewsJson = JSON.serialize(out.reviews);
                return new List<Response>{ out };
            }
            if (req.storefrontId == null) {
                out.message = 'storefrontId is required.';
                out.reviewsJson = JSON.serialize(out.reviews);
                return new List<Response>{ out };
            }
            if (req.rating == null) {
                out.message = 'rating is required.';
                out.reviewsJson = JSON.serialize(out.reviews);
                return new List<Response>{ out };
            }

            Review__c r = new Review__c();
            r.Customer__c = req.verifiedCustomerId;
            r.Storefront__c = req.storefrontId;
            r.Rating__c = Decimal.valueOf(req.rating);
            r.Comments__c = req.reviewComment;

            // Mirror the Flow default.
            r.Status__c = 'Submitted';

            insert r;

            r = [
                SELECT Id, Name, Storefront__c, Customer__c, Rating__c, Comments__c, Status__c
                FROM Review__c
                WHERE Id = :r.Id
                LIMIT 1
            ];

            ReviewSummary s = new ReviewSummary();
            s.id = r.Id;
            s.recordNumber = r.Name;
            s.storefrontId = r.Storefront__c;
            s.customerId = r.Customer__c;
            s.rating = (r.Rating__c == null) ? null : Integer.valueOf(r.Rating__c);
            s.comments = r.Comments__c;
            s.status = r.Status__c;
            out.reviews.add(s);

            out.success = true;
            out.message = 'OK';
        } catch (Exception e) {
            out.success = false;
            out.message = e.getMessage();
        }

        out.reviewsJson = JSON.serialize(out.reviews);
        return new List<Response>{ out };
    }
}