import { LightningElement, api, wire, track } from 'lwc';
//import getRelatedIndividuals from '@salesforce/apex/GetRelatedIndividuals.getRelatedIndividuals';

export default class RelatedIndividualsModal extends LightningElement {
	@api isOpen = false;
	@api recordId; // Contact or Lead Id
	@api debugMode = false; // Changed from true to false to comply with LWC standards

	@track data = [];
	@track columns = [
		{ label: 'Source ID', fieldName: 'sourceId', type: 'text' },
		{ label: 'Source Type', fieldName: 'sourceType', type: 'text', initialWidth: 130 },
		{ label: 'First Name', fieldName: 'firstName', type: 'text', initialWidth: 130 },
		{ label: 'Last Name', fieldName: 'lastName', type: 'text', initialWidth: 130 },
		{ label: 'Email', fieldName: 'email', type: 'email', initialWidth: 230 },
		{ label: 'Phone', fieldName: 'phone', type: 'phone' },
		{ label: 'Created Date', fieldName: 'createdDate', type: 'date' },
		{ label: 'Unified ID', fieldName: 'unifiedId', type: 'text', initialWidth: 300 },
		{
			label: 'View Record',
			fieldName: 'recordUrl',
			type: 'url',
			typeAttributes: {
				label: 'View',
				target: '_blank'
			}
		}
	];
	@track error;
	@track isLoading = false;
	@track rawData;

	/*
    // Internal debug mode - can be enabled for testing
    get isDebugMode() {
        return this.debugMode || false; // You can change this to true for debugging
    }

    @wire(getRelatedIndividuals, { recordId: '$recordId' })
    wiredRelatedIndividuals({ error, data }) {
        this.isLoading = false;

        console.log('🔍 WIRE METHOD CALLED - recordId:', this.recordId);
        console.log('🔍 WIRE DATA (stringified):', JSON.stringify(data, null, 2));
        console.log('🔍 WIRE ERROR (stringified):', JSON.stringify(error, null, 2));

        if (data) {
            console.log('✅ Modal received data (stringified):', JSON.stringify(data, null, 2));
            console.log('🔍 DATA TYPE:', typeof data);
            console.log('🔍 DATA IS ARRAY:', Array.isArray(data));
            console.log('🔍 DATA LENGTH:', data ? data.length : 'undefined');

            this.rawData = data;
            this.processData(data);
            this.error = undefined;
        } else if (error) {
            console.error('❌ Modal error (stringified):', JSON.stringify(error, null, 2));
            this.error = this.getErrorMessage(error);
            this.data = [];
            this.rawData = null;
        } else {
            console.log('⚠️ No data and no error received');
        }
    }

    connectedCallback() {
        if (this.recordId) {
            this.isLoading = true;
        }
    }

    processData(rawData) {
        try {
            // Debug: Log the raw data structure to browser console
            console.log('🔍 RAW DATA STRUCTURE:', JSON.stringify(rawData, null, 2));

            // Handle different data formats
            let processedData = [];

            if (Array.isArray(rawData)) {
                rawData.forEach((item, index) => {
                    console.log(`🔍 ITEM ${index} FIELDS:`, Object.keys(item));
                    console.log(`🔍 ITEM ${index} DATA:`, JSON.stringify(item, null, 2));
                });
                processedData = rawData.map(item => this.normalizeDataItem(item));
            } else if (rawData && typeof rawData === 'object') {
                console.log('🔍 SINGLE ITEM FIELDS:', Object.keys(rawData));
                console.log('🔍 SINGLE ITEM DATA:', JSON.stringify(rawData, null, 2));
                processedData = [this.normalizeDataItem(rawData)];
            } else {
                console.warn('Unexpected data format:', rawData);
                processedData = [];
            }

            this.data = processedData;
            console.log('✅ Processed data for modal:', this.data);

        } catch (e) {
            console.error('Error processing data:', e);
            this.error = 'Error processing data: ' + e.message;
            this.data = [];
        }
    }

    normalizeDataItem(item) {
        console.log('🔍 NORMALIZE ITEM:', JSON.stringify(item, null, 2));
        console.log('🔍 NORMALIZE ITEM KEYS:', Object.keys(item));

        // Handle both direct properties and nested object properties
        const sourceId = item.sourceId || item.Id || item.id || 'N/A';
        const createdDate = item.createdDate || item.CreatedDate || item.created_date || null;
        const rawSourceType = item.sourceType || item.Type || item.type || 'N/A';

        const normalized = {
            sourceId: sourceId,
            sourceType: this.formatSourceType(rawSourceType),
            firstName: item.firstName || item.FirstName || item.first_name || 'N/A',
            lastName: item.lastName || item.LastName || item.last_name || 'N/A',
            email: item.email || item.Email || item.email_address || 'N/A',
            phone: item.phone || item.Phone || item.phone_number || 'N/A',
            createdDate: createdDate ? new Date(createdDate) : null,
            unifiedId: item.unifiedId || item.UnifiedId || item.unified_id || 'N/A',
            recordUrl: this.createRecordUrl(sourceId)
        };

        console.log('🔍 NORMALIZED RESULT:', normalized);
        return normalized;
    }

    createRecordUrl(sourceId) {
        // Create a Salesforce record URL if sourceId is valid
        if (sourceId && sourceId !== 'N/A' && typeof sourceId === 'string' && sourceId.length >= 15) {
            // Check if it looks like a Salesforce ID (15 or 18 characters)
            return `/${sourceId}`;
        }
        return null;
    }

    formatSourceType(sourceType) {
        // Transform source type values for better display
        if (sourceType && typeof sourceType === 'string') {
            if (sourceType.includes('Pronto_Site')) {
                return 'Pronto App';
            }
        }
        return sourceType;
    }

    getErrorMessage(error) {
        if (error.body) {
            if (error.body.message) {
                return error.body.message;
            }
            if (error.body.pageErrors && error.body.pageErrors.length > 0) {
                return error.body.pageErrors[0].message;
            }
        }
        return error.message || 'Unknown error occurred';
    }

    closeModal() {
        this.isOpen = false;
        this.dispatchEvent(new CustomEvent('close'));
    }

    // Getter for template conditionals
    get hasData() {
        return this.data && this.data.length > 0;
    }

    get dataLength() {
        return this.data ? this.data.length : 0;
    }

    get rawDataString() {
        try {
            return this.rawData ? JSON.stringify(this.rawData, null, 2) : 'No data';
        } catch (e) {
            return 'Error stringifying data: ' + e.message;
        }
    }

    */
}
