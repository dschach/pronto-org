/**
 * Apex DTOs for the "Menu Upload" Custom Lightning Type (LightningTypeBundle).
 *
 * The LightningTypeBundle schema references:
 *   @apexClassType/c__MenuUploadTypes$MenuUploadValue
 */
global with sharing class MenuUploadTypes {
  global class UploadedFile {
    @InvocableVariable(label='Document Id' description='ContentDocumentId of the uploaded file.' required=false)
    global String documentId;

    @InvocableVariable(label='File Name' description='Original filename including extension.' required=false)
    global String name;

    @InvocableVariable(label='File Size' description='File size in bytes.' required=false)
    global Integer size;

    @InvocableVariable(
      label='MIME Type'
      description='MIME type of the file (e.g. application/pdf, image/png).'
      required=false
    )
    global String mimeType;
  }

  global class MenuUploadValue {
    @InvocableVariable(
      label='Storefront Id'
      description='The Storefront__c record Id that files are being uploaded to.'
      required=true
    )
    global Id storefrontId;

    @InvocableVariable(
      label='Uploaded Files'
      description='List of files uploaded by the user via the Menu Upload component.'
      required=false
    )
    global List<UploadedFile> files;
  }
}