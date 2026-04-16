/**
 * AgentCaseCreateActions
 *
 * Creates a new Case for a verified customer and returns a DTO/JSON response that
 * serializes reliably in Agentforce/Flow action contexts.
 *
 * Bulk model:
 * This is intentionally a "singleton" action: we only consider requests[0] and return
 * a single Response row.
 */
public with sharing class AgentCaseCreateActions {
  public class Request {
    @InvocableVariable(
      label='Verified Customer Id'
      description='The Contact Id for the verified customer. This value is stored on the Case as Case.ContactId.'
      required=true
    )
    public Id verifiedCustomerId;

    @InvocableVariable(
      label='Subject'
      description='Case subject (Case.Subject). If blank, this action defaults to "Customer Support Request".'
      required=false
    )
    public String subject;

    @InvocableVariable(
      label='Description'
      description='Case description (Case.Description). Free-form problem statement and context.'
      required=false
    )
    public String description;

    @InvocableVariable(
      label='Origin'
      description='Case origin (Case.Origin), for example "Phone", "Email", "Web", or "Agentforce". If blank, defaults to "Agentforce".'
      required=false
    )
    public String origin;

    @InvocableVariable(
      label='Status'
      description='Case status (Case.Status). If blank, defaults to "New" (or the org default if "New" is invalid).'
      required=false
    )
    public String status;

    @InvocableVariable(
      label='Priority'
      description='Case priority (Case.Priority), for example "Low", "Medium", "High". If blank, no priority is set.'
      required=false
    )
    public String priority;

    @InvocableVariable(label='Type' description='Case type (Case.Type). If blank, no type is set.' required=false)
    public String type;

    @InvocableVariable(
      label='Reason'
      description='Case reason (Case.Reason). If blank, no reason is set.'
      required=false
    )
    public String reason;

    @InvocableVariable(
      label='Business Account Id'
      description='Optional merchant/business account (Case.Business_Account__c) if that custom field exists in the org.'
      required=false
    )
    public Id businessAccountId;

    @InvocableVariable(
      label='Storefront Id'
      description='Optional storefront/restaurant (Case.Storefront__c) if that custom field exists in the org.'
      required=false
    )
    public Id storefrontId;

    @InvocableVariable(
      label='Record Type Id'
      description='Optional Case RecordTypeId. Provide when your org requires specific record types for support processes.'
      required=false
    )
    public Id recordTypeId;

    @InvocableVariable(
      label='Owner Id'
      description='Optional Case owner (Case.OwnerId). If blank, the org default assignment rules apply (or ownership defaults to the running user depending on org settings).'
      required=false
    )
    public Id ownerId;
  }

  public class CaseSummary {
    @InvocableVariable(label='Case Id' description='The created Case Id.')
    public Id id;

    @InvocableVariable(label='Case Number' description='The created CaseNumber (human-friendly number).')
    public String caseNumber;

    @InvocableVariable(label='Subject' description='Case.Subject.')
    public String subject;

    @InvocableVariable(label='Status' description='Case.Status.')
    public String status;

    @InvocableVariable(label='Origin' description='Case.Origin.')
    public String origin;

    @InvocableVariable(label='Priority' description='Case.Priority.')
    public String priority;

    @InvocableVariable(label='Type' description='Case.Type.')
    public String type;

    @InvocableVariable(label='Reason' description='Case.Reason.')
    public String reason;

    @InvocableVariable(label='Customer Id' description='Case.ContactId (verified customer Contact Id).')
    public Id customerId;

    @InvocableVariable(
      label='Business Account Id'
      description='Case.Business_Account__c when the field exists and was set; otherwise null.'
    )
    public Id businessAccountId;

    @InvocableVariable(
      label='Storefront Id'
      description='Case.Storefront__c when the field exists and was set; otherwise null.'
    )
    public Id storefrontId;
  }

  public class Response {
    @InvocableVariable(
      label='Success'
      description='True when the case was created successfully. False when inputs are missing/invalid or when creation fails.'
    )
    public Boolean success;

    @InvocableVariable(
      label='Message'
      description='User-readable status message. On errors, explains what was missing or what failed.'
    )
    public String message;

    @InvocableVariable(label='Case' description='Summary of the created case. Null when success=false.')
    public CaseSummary createdCase;

    @InvocableVariable(
      label='Case JSON'
      description='JSON-serialized version of createdCase for clients that prefer JSON parsing. This is "null" when createdCase is null.'
    )
    public String createdCaseJson;
  }

  @InvocableMethod(
    label='Create Case'
    description='Create a new Case for a verified customer (Contact) and return the created case details as a DTO/JSON.'
  )
  public static List<Response> invoke(List<Request> requests) {
    Response out = new Response();
    out.success = false;
    out.message = null;
    out.createdCase = null;
    out.createdCaseJson = null;

    Request req = (requests != null && !requests.isEmpty()) ? requests[0] : null;
    try {
      if (req == null || req.verifiedCustomerId == null) {
        out.message = 'verifiedCustomerId is required.';
        return new List<Response>{ out };
      }

      Map<String, Schema.SObjectField> fields = Case.SObjectType.getDescribe().fields.getMap();

      Case c = new Case();
      c.ContactId = req.verifiedCustomerId;
      c.Subject = String.isBlank(req.subject) ? 'Customer Support Request' : req.subject;
      if (!String.isBlank(req.description))
        c.Description = req.description;
      c.Origin = String.isBlank(req.origin) ? 'Agentforce' : req.origin;

      if (!String.isBlank(req.status))
        c.Status = req.status;
      else {
        // Common default; if org doesn't support "New" this may throw and we fall back below.
        c.Status = 'New';
      }

      if (!String.isBlank(req.priority))
        c.Priority = req.priority;
      if (!String.isBlank(req.type))
        c.Type = req.type;
      if (!String.isBlank(req.reason))
        c.Reason = req.reason;
      // RecordTypeId only exists when record types are enabled for Case in the org.
      if (req.recordTypeId != null && fields.containsKey('RecordTypeId')) {
        c.put('RecordTypeId', req.recordTypeId);
      }
      if (req.ownerId != null)
        c.OwnerId = req.ownerId;

      // Optional custom fields: only set when they exist in the org.
      if (req.businessAccountId != null && fields.containsKey('Business_Account__c')) {
        c.put('Business_Account__c', req.businessAccountId);
      }
      if (req.storefrontId != null && fields.containsKey('Storefront__c')) {
        c.put('Storefront__c', req.storefrontId);
      }

      try {
        insert c;
      } catch (DmlException dmle) {
        // If Status="New" isn't valid for the org, retry without status so the org default applies.
        if (req.status == null && dmle.getMessage() != null && dmle.getMessage().toLowerCase().contains('status')) {
          c.Status = null;
          insert c;
        } else {
          throw dmle;
        }
      }

      // Query back for CaseNumber + populated fields.
      List<String> queryFields = new List<String>{
        'Id',
        'CaseNumber',
        'Subject',
        'Status',
        'Origin',
        'Priority',
        'Type',
        'Reason',
        'ContactId'
      };
      if (fields.containsKey('Business_Account__c'))
        queryFields.add('Business_Account__c');
      if (fields.containsKey('Storefront__c'))
        queryFields.add('Storefront__c');

      String soql = 'SELECT ' + String.join(queryFields, ',') + ' FROM Case WHERE Id = :caseId LIMIT 1';
      Case created = (Case) Database.query(soql.replace(':caseId', '\'' + String.valueOf(c.Id) + '\''));

      CaseSummary s = new CaseSummary();
      s.id = created.Id;
      s.caseNumber = created.CaseNumber;
      s.subject = created.Subject;
      s.status = created.Status;
      s.origin = created.Origin;
      s.priority = created.Priority;
      s.type = created.Type;
      s.reason = created.Reason;
      s.customerId = created.ContactId;
      if (fields.containsKey('Business_Account__c'))
        s.businessAccountId = (Id) created.get('Business_Account__c');
      if (fields.containsKey('Storefront__c'))
        s.storefrontId = (Id) created.get('Storefront__c');

      out.createdCase = s;
      out.createdCaseJson = JSON.serialize(s);
      out.success = true;
      out.message = 'OK';
    } catch (Exception e) {
      out.success = false;
      out.message = e.getMessage();
    }

    return new List<Response>{ out };
  }
}