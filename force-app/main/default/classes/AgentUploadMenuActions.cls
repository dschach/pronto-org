/**
 * AgentUploadMenuActions
 *
 * Validates and summarizes menu files uploaded to a target Storefront record.
 * Uses the Menu Upload Custom Lightning Type to collect files from the user.
 *
 * Bulk model:
 * Processes each request independently; returns one Response per Request.
 */
public with sharing class AgentUploadMenuActions {
    @InvocableMethod(
        label='Upload Menu'
        description='Validates and summarizes menu files uploaded to a target Storefront record.'
    )
    public static List<Response> execute(List<Request> requests) {
        List<Response> out = new List<Response>();
        if (requests == null) return out;

        for (Request req : requests) {
            Response r = new Response();
            r.success = false;
            r.message = null;
            r.storefrontId = req == null ? null : req.storefrontId;
            r.files = new List<MenuUploadTypes.UploadedFile>();

            if (req == null || req.storefrontId == null) {
                r.message = 'A storefrontId is required.';
                out.add(r);
                continue;
            }

            try {
                Storefront__c sf = [
                    SELECT Id, Name
                    FROM Storefront__c
                    WHERE Id = :req.storefrontId
                    LIMIT 1
                ];

                Set<Id> docIds = new Set<Id>();
                if (req.menuUpload != null && req.menuUpload.files != null) {
                    for (MenuUploadTypes.UploadedFile f : req.menuUpload.files) {
                        if (f != null && String.isNotBlank(f.documentId)) {
                            try {
                                docIds.add((Id)f.documentId);
                            } catch (Exception ignored) {
                            }
                        }
                    }
                }

                if (docIds.isEmpty()) {
                    for (ContentDocumentLink cdl : [
                        SELECT ContentDocumentId
                        FROM ContentDocumentLink
                        WHERE LinkedEntityId = :sf.Id
                        ORDER BY SystemModstamp DESC
                        LIMIT 20
                    ]) {
                        docIds.add(cdl.ContentDocumentId);
                    }
                }

                Map<Id, ContentDocument> docsById = new Map<Id, ContentDocument>();
                if (!docIds.isEmpty()) {
                    docsById = new Map<Id, ContentDocument>([
                        SELECT Id, Title, FileType, ContentSize
                        FROM ContentDocument
                        WHERE Id IN :docIds
                    ]);
                }

                for (Id did : docIds) {
                    ContentDocument d = docsById.get(did);
                    if (d == null) continue;

                    MenuUploadTypes.UploadedFile f = new MenuUploadTypes.UploadedFile();
                    f.documentId = String.valueOf(d.Id);
                    f.name = d.Title + (String.isBlank(d.FileType) ? '' : ('.' + d.FileType.toLowerCase()));
                    f.size = d.ContentSize == null ? null : Integer.valueOf(d.ContentSize);
                    f.mimeType = null;
                    r.files.add(f);
                }

                r.success = true;
                if (r.files.isEmpty()) {
                    r.message = 'No files found on storefront "' + sf.Name + '".';
                } else {
                    r.message = 'Found ' + r.files.size() + ' menu file(s) on storefront "' + sf.Name + '".';
                }
            } catch (QueryException qe) {
                r.message = 'Storefront not found or not accessible.';
            } catch (Exception e) {
                r.message = 'Failed to upload menu: ' + e.getMessage();
            }

            out.add(r);
        }

        return out;
    }

    public class Request {
        @InvocableVariable(
            label='Storefront Id'
            description='The Storefront__c record Id to attach menu files to.'
            required=true
        )
        public Id storefrontId;

        @InvocableVariable(
            label='Menu Upload'
            description='Structured upload payload from the Menu Upload Custom Lightning Type, containing the list of uploaded files.'
        )
        public MenuUploadTypes.MenuUploadValue menuUpload;
    }

    public class Response {
        @InvocableVariable(
            label='Success'
            description='True if the upload completed without errors.'
        )
        public Boolean success;

        @InvocableVariable(
            label='Message'
            description='Human-readable summary of the result, including file count and storefront name.'
        )
        public String message;

        @InvocableVariable(
            label='Storefront Id'
            description='The Storefront__c record Id that files were uploaded to.'
        )
        public Id storefrontId;

        @InvocableVariable(
            label='Uploaded Files'
            description='List of finalized file records with document Ids, names, and sizes.'
        )
        public List<MenuUploadTypes.UploadedFile> files;
    }
}