/**
 * AgentCaseActions
 *
 * Returns Case collections as Apex-defined DTOs (and JSON) to avoid flaky/partial
 * serialization of SObject collection outputs in some invocation surfaces.
 *
 * Bulk model:
 * This is intentionally a "singleton" action: we only consider requests[0] and return
 * a single Response row.
 */
public with sharing class AgentCaseActions {
    public class Request {
        @InvocableVariable(
            label='Verified Customer Id'
            description='The Contact Id for the verified customer whose related cases should be returned (Case.ContactId).'
            required=true
        )
        public Id verifiedCustomerId;

        @InvocableVariable(
            label='Case Status'
            description='Case status filter. Use "All" (case-insensitive) to return all statuses; otherwise filters to exact match (Case.Status).'
            required=true
        )
        public String caseStatus;
    }

    public class CaseSummary {
        @InvocableVariable(label='Case Id' description='The Case record Id.')
        public Id id;

        @InvocableVariable(label='Subject' description='Case subject (Case.Subject).')
        public String subject;

        @InvocableVariable(label='Description' description='Case description (Case.Description).')
        public String description;

        @InvocableVariable(label='Status' description='Case status (Case.Status).')
        public String status;

        @InvocableVariable(label='Created Date' description='Case created date/time (Case.CreatedDate).')
        public Datetime createdDate;
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
            label='Cases'
            description='A list of case summaries for the given contact and status filter.'
        )
        public List<CaseSummary> cases;

        @InvocableVariable(
            label='Cases JSON'
            description='JSON-serialized version of cases for clients that prefer to parse JSON.'
        )
        public String casesJson;
    }

    @InvocableMethod(
        label='Get Related Cases'
        description='Query Case records for a contact with an optional status filter and return results as DTOs/JSON for reliable serialization.'
    )
    public static List<Response> invoke(List<Request> requests) {
        Response out = new Response();
        out.cases = new List<CaseSummary>();
        out.success = false;
        out.message = null;

        Request req = (requests != null && !requests.isEmpty()) ? requests[0] : null;
        try {
            if (req == null || req.verifiedCustomerId == null) {
                out.message = 'verifiedCustomerId is required.';
                out.casesJson = JSON.serialize(out.cases);
                return new List<Response>{ out };
            }
            if (String.isBlank(req.caseStatus)) {
                out.message = 'caseStatus is required.';
                out.casesJson = JSON.serialize(out.cases);
                return new List<Response>{ out };
            }

            Boolean returnAll = 'all'.equalsIgnoreCase(req.caseStatus);

            List<Case> cases;
            if (returnAll) {
                cases = [
                    SELECT Id, Subject, Description, Status, CreatedDate
                    FROM Case
                    WHERE ContactId = :req.verifiedCustomerId
                    ORDER BY CreatedDate DESC
                    LIMIT 200
                ];
            } else {
                cases = [
                    SELECT Id, Subject, Description, Status, CreatedDate
                    FROM Case
                    WHERE ContactId = :req.verifiedCustomerId
                    AND Status = :req.caseStatus
                    ORDER BY CreatedDate DESC
                    LIMIT 200
                ];
            }

            for (Case c : cases) {
                CaseSummary s = new CaseSummary();
                s.id = c.Id;
                s.subject = c.Subject;
                s.description = c.Description;
                s.status = c.Status;
                s.createdDate = c.CreatedDate;
                out.cases.add(s);
            }

            out.success = true;
            out.message = 'OK';
        } catch (Exception e) {
            out.success = false;
            out.message = e.getMessage();
        }

        out.casesJson = JSON.serialize(out.cases);
        return new List<Response>{ out };
    }
}