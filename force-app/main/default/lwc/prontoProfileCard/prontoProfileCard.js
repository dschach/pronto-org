import { LightningElement, api, wire } from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import ACCOUNT_ANNUAL_SALES_FIELD from '@salesforce/schema/Account.Annual_Sales_Total__c';
import ACCOUNT_BILLING_CITY_FIELD from '@salesforce/schema/Account.BillingCity';
import ACCOUNT_BILLING_STATE_FIELD from '@salesforce/schema/Account.BillingState';
import ACCOUNT_EMPLOYEES_FIELD from '@salesforce/schema/Account.NumberOfEmployees';
import ACCOUNT_LOCATIONS_FIELD from '@salesforce/schema/Account.NumberofLocations__c';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';
import ACCOUNT_NUMBER_FIELD from '@salesforce/schema/Account.AccountNumber';
import ACCOUNT_ORDERS_FIELD from '@salesforce/schema/Account.Total_Orders__c';
import ACCOUNT_PHONE_FIELD from '@salesforce/schema/Account.Phone';
import ACCOUNT_REVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';
import ACCOUNT_SLA_FIELD from '@salesforce/schema/Account.SLA__c';
import ACCOUNT_TYPE_FIELD from '@salesforce/schema/Account.Type';
import CONTACT_ACCOUNT_NAME_FIELD from '@salesforce/schema/Contact.Account.Name';
import CONTACT_CUISINE_FIELD from '@salesforce/schema/Contact.Favorite_Cuisine__c';
import CONTACT_EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import CONTACT_LEAD_SOURCE from '@salesforce/schema/Contact.LeadSource';
import CONTACT_MAILING_CITY_FIELD from '@salesforce/schema/Contact.MailingCity';
import CONTACT_MAILING_STATE_FIELD from '@salesforce/schema/Contact.MailingState';
import CONTACT_MOBILE_FIELD from '@salesforce/schema/Contact.MobilePhone';
import CONTACT_NAME_FIELD from '@salesforce/schema/Contact.Name';
import CONTACT_PHONE_FIELD from '@salesforce/schema/Contact.Phone';
import CONTACT_STATUS_FIELD from '@salesforce/schema/Contact.Contact_Status__c';
import CONTACT_TITLE from '@salesforce/schema/Contact.Title';
import LEAD_CITY_FIELD from '@salesforce/schema/Lead.City';
import LEAD_COMPANY_FIELD from '@salesforce/schema/Lead.Company';
import LEAD_CONVERSION_PROBABILITY_FIELD from '@salesforce/schema/Lead.Lead_Conversion_Probability__c';
import LEAD_COUNTRY_FIELD from '@salesforce/schema/Lead.Country';
import LEAD_CUISINE_TYPE_FIELD from '@salesforce/schema/Lead.Cuisine_Type__c';
import LEAD_EMAIL_FIELD from '@salesforce/schema/Lead.Email';
import LEAD_NAME_FIELD from '@salesforce/schema/Lead.Name';
import LEAD_PHONE_FIELD from '@salesforce/schema/Lead.Phone';
import LEAD_POSTAL_CODE_FIELD from '@salesforce/schema/Lead.PostalCode';
import LEAD_STATE_FIELD from '@salesforce/schema/Lead.State';
import LEAD_STATUS_FIELD from '@salesforce/schema/Lead.Status';
import LEAD_STREET_FIELD from '@salesforce/schema/Lead.Street';
import LEAD_WEBSITE_FIELD from '@salesforce/schema/Lead.Website';
import PRONTO_IMAGES from '@salesforce/resourceUrl/pronto_org_images';

const ACCOUNT_FIELDS = [
	ACCOUNT_NAME_FIELD,
	ACCOUNT_TYPE_FIELD,
	ACCOUNT_PHONE_FIELD,
	ACCOUNT_EMPLOYEES_FIELD,
	ACCOUNT_REVENUE_FIELD,
	ACCOUNT_NUMBER_FIELD,
	ACCOUNT_SLA_FIELD,
	ACCOUNT_LOCATIONS_FIELD,
	ACCOUNT_ORDERS_FIELD,
	ACCOUNT_ANNUAL_SALES_FIELD,
	ACCOUNT_BILLING_CITY_FIELD,
	ACCOUNT_BILLING_STATE_FIELD
];
const CONTACT_FIELDS = [
	CONTACT_NAME_FIELD,
	CONTACT_EMAIL_FIELD,
	CONTACT_PHONE_FIELD,
	CONTACT_MOBILE_FIELD,
	CONTACT_ACCOUNT_NAME_FIELD,
	CONTACT_STATUS_FIELD,
	CONTACT_CUISINE_FIELD,
	CONTACT_TITLE,
	CONTACT_LEAD_SOURCE,
	CONTACT_MAILING_CITY_FIELD,
	CONTACT_MAILING_STATE_FIELD
];
const LEAD_FIELDS = [
	LEAD_NAME_FIELD,
	LEAD_COMPANY_FIELD,
	LEAD_STATUS_FIELD,
	LEAD_EMAIL_FIELD,
	LEAD_PHONE_FIELD,
	LEAD_STREET_FIELD,
	LEAD_CITY_FIELD,
	LEAD_STATE_FIELD,
	LEAD_POSTAL_CODE_FIELD,
	LEAD_COUNTRY_FIELD,
	LEAD_CUISINE_TYPE_FIELD,
	LEAD_WEBSITE_FIELD,
	LEAD_CONVERSION_PROBABILITY_FIELD
];

export default class ProntoProfileCard extends LightningElement {
	@api recordId;
	@api objectApiName;

	// Loading and error states
	isLoading = true;
	hasError = false;

	// Data containers
	_acct;
	_ct;
	_ld;

	// Only fetch Account when on an Account page
	get accountRecordId() {
		return this.isAccount ? this.recordId : null;
	}

	@wire(getRecord, { recordId: '$accountRecordId', fields: ACCOUNT_FIELDS })
	wiredAccount({ error, data }) {
		this.isLoading = false;
		if (data) {
			this._acct = data;
		}
		if (error) {
			this.hasError = true;
		}
	}

	@wire(getRecord, { recordId: '$contactRecordId', fields: CONTACT_FIELDS })
	wiredContact({ error: _error, data }) {
		if (data) {
			this._ct = data;
		}
	}

	@wire(getRecord, { recordId: '$leadRecordId', fields: LEAD_FIELDS })
	wiredLead({ error: _error, data }) {
		if (data) {
			this._ld = data;
		}
	}

	// STATE HELPERS
	get isAccount() {
		return this.objectApiName === 'Account';
	}
	get isContact() {
		return this.objectApiName === 'Contact';
	}
	get isLead() {
		return this.objectApiName === 'Lead';
	}

	get contactRecordId() {
		return this.isContact ? this.recordId : null;
	}
	get leadRecordId() {
		return this.isLead ? this.recordId : null;
	}

	get hasData() {
		return (this.isAccount && this._acct) || (this.isContact && this._ct) || (this.isLead && this._ld);
	}

	// THEME AND HERO
	get themeClass() {
		if (this.isPartnerAccount || this.isBusinessContact) {
			return 'profile-card partner-account-theme';
		}
		if (this.isCustomerAccount || this.isCustomerContact) {
			return 'profile-card customer-account-theme';
		}
		// Fallback theme
		return 'profile-card default-theme';
	}

	get heroImageUrl() {
		if (this.isPartnerAccount) {
			return `${PRONTO_IMAGES}/pronto-org-images/pronto-business-account-hero.png`;
		}
		if (this.isCustomerAccountType) {
			return `${PRONTO_IMAGES}/pronto-org-images/pronto-customer-account-hero.png`;
		}
		if (this.isContact) {
			return `${PRONTO_IMAGES}/pronto-org-images/pronto-customer-hero.png`;
		}
		if (this.isLead) {
			return `${PRONTO_IMAGES}/pronto-org-images/pronto-lead-hero.png`;
		}
		return '';
	}

	// RECORD TYPE GETTERS
	get accountRecordType() {
		// Some org templates do not include RecordTypeId/RecordType on standard objects.
		// Avoid relying on record types and instead infer from Account.Type when possible.
		return null;
	}

	get isCustomerAccount() {
		const typeVal = (getFieldValue(this._acct, ACCOUNT_TYPE_FIELD) || '').toLowerCase();
		return this.isAccount && typeVal.includes('customer');
	}

	get isBusinessAccount() {
		const typeVal = (getFieldValue(this._acct, ACCOUNT_TYPE_FIELD) || '').toLowerCase();
		return this.isAccount && (typeVal.includes('partner') || typeVal.includes('business'));
	}

	get isPartnerAccount() {
		return this.isBusinessAccount;
	}

	get isCustomerAccountType() {
		return this.isCustomerAccount;
	}

	get contactType() {
		if (!this.isContact) {
			return null;
		}

		const accountName = getFieldValue(this._ct, CONTACT_ACCOUNT_NAME_FIELD);
		const leadSource = getFieldValue(this._ct, CONTACT_LEAD_SOURCE);

		if (!accountName || leadSource === 'Customer Referral' || leadSource === 'Web') {
			return 'customer';
		}

		if (accountName && leadSource && leadSource !== 'Customer Referral' && leadSource !== 'Web') {
			return 'business';
		}

		return 'customer';
	}

	get isCustomerContact() {
		return this.contactType === 'customer';
	}

	get isBusinessContact() {
		return this.contactType === 'business';
	}

	// HELPER METHODS
	formatFieldValue(value) {
		return value || '—';
	}

	// SHARED GETTERS
	get displayName() {
		if (this.isAccount) {
			return getFieldValue(this._acct, ACCOUNT_NAME_FIELD);
		}
		if (this.isContact) {
			return getFieldValue(this._ct, CONTACT_NAME_FIELD);
		}
		if (this.isLead) {
			return getFieldValue(this._ld, LEAD_NAME_FIELD);
		}
		return 'N/A';
	}

	get headlineSubtitle() {
		let city = null;
		let state = null;
		if (this.isAccount && this._acct) {
			city = getFieldValue(this._acct, ACCOUNT_BILLING_CITY_FIELD);
			state = getFieldValue(this._acct, ACCOUNT_BILLING_STATE_FIELD);
		} else if (this.isContact && this._ct) {
			city = getFieldValue(this._ct, CONTACT_MAILING_CITY_FIELD);
			state = getFieldValue(this._ct, CONTACT_MAILING_STATE_FIELD);
		} else if (this.isLead && this._ld) {
			city = getFieldValue(this._ld, LEAD_CITY_FIELD);
			state = getFieldValue(this._ld, LEAD_STATE_FIELD);
		}

		const locationParts = [];
		if (city) {
			locationParts.push(city);
		}
		if (state) {
			locationParts.push(state);
		}

		return locationParts.join(', ');
	}

	get recordTypeLabel() {
		if (this.isAccount) {
			if (this.isPartnerAccount) {
				return 'Partner Account';
			}
			if (this.isCustomerAccount) {
				return 'Customer Account';
			}
			return 'Account';
		}
		if (this.isContact) {
			if (this.isCustomerContact) {
				return 'Customer Contact';
			}
			if (this.isBusinessContact) {
				return 'Business Contact';
			}
			return 'Contact';
		}
		if (this.isLead) {
			return 'Lead';
		}
		return 'Record';
	}

	// FORMATTERS
	get formattedAccountRevenue() {
		const revenue = getFieldValue(this._acct, ACCOUNT_REVENUE_FIELD);
		if (revenue === null || revenue === undefined) {
			return 'N/A';
		}
		return `$${parseInt(revenue, 10).toLocaleString()}`;
	}

	// ACCOUNT GETTERS
	get accountNumber() {
		return this.formatFieldValue(getFieldValue(this._acct, ACCOUNT_NUMBER_FIELD));
	}
	get accountType() {
		return this.formatFieldValue(getFieldValue(this._acct, ACCOUNT_TYPE_FIELD));
	}
	get accountPhone() {
		return this.formatFieldValue(getFieldValue(this._acct, ACCOUNT_PHONE_FIELD));
	}
	get accountEmployees() {
		return this.formatFieldValue(getFieldValue(this._acct, ACCOUNT_EMPLOYEES_FIELD));
	}
	get accountLocations() {
		return this.formatFieldValue(getFieldValue(this._acct, ACCOUNT_LOCATIONS_FIELD));
	}
	get accountTotalOrders() {
		return this.formatFieldValue(getFieldValue(this._acct, ACCOUNT_ORDERS_FIELD));
	}
	get accountAnnualSalesTotal() {
		return this.formatFieldValue(getFieldValue(this._acct, ACCOUNT_ANNUAL_SALES_FIELD));
	}

	// CONTACT GETTERS
	get contactName() {
		return this.formatFieldValue(getFieldValue(this._ct, CONTACT_NAME_FIELD));
	}
	get contactEmail() {
		return this.formatFieldValue(getFieldValue(this._ct, CONTACT_EMAIL_FIELD));
	}
	get contactPhone() {
		return this.formatFieldValue(getFieldValue(this._ct, CONTACT_PHONE_FIELD));
	}
	get contactMobile() {
		return this.formatFieldValue(getFieldValue(this._ct, CONTACT_MOBILE_FIELD));
	}
	get contactAccountName() {
		return this.formatFieldValue(getFieldValue(this._ct, CONTACT_ACCOUNT_NAME_FIELD));
	}
	get contactStatus() {
		return this.formatFieldValue(getFieldValue(this._ct, CONTACT_STATUS_FIELD));
	}
	get contactFavoriteCuisine() {
		return this.formatFieldValue(getFieldValue(this._ct, CONTACT_CUISINE_FIELD));
	}
	get contactTitle() {
		return this.formatFieldValue(getFieldValue(this._ct, CONTACT_TITLE));
	}
	get contactLeadSource() {
		return this.formatFieldValue(getFieldValue(this._ct, CONTACT_LEAD_SOURCE));
	}

	// LEAD GETTERS
	get leadName() {
		return this.formatFieldValue(getFieldValue(this._ld, LEAD_NAME_FIELD));
	}
	get leadCompany() {
		return this.formatFieldValue(getFieldValue(this._ld, LEAD_COMPANY_FIELD));
	}
	get leadStatus() {
		return this.formatFieldValue(getFieldValue(this._ld, LEAD_STATUS_FIELD));
	}
	get leadEmail() {
		return this.formatFieldValue(getFieldValue(this._ld, LEAD_EMAIL_FIELD));
	}
	get leadPhone() {
		return this.formatFieldValue(getFieldValue(this._ld, LEAD_PHONE_FIELD));
	}
	get leadCuisineType() {
		return this.formatFieldValue(getFieldValue(this._ld, LEAD_CUISINE_TYPE_FIELD));
	}
	get leadWebsite() {
		return this.formatFieldValue(getFieldValue(this._ld, LEAD_WEBSITE_FIELD));
	}
	get leadConversionProbability() {
		return this.formatFieldValue(getFieldValue(this._ld, LEAD_CONVERSION_PROBABILITY_FIELD));
	}
	get leadAddress() {
		const street = getFieldValue(this._ld, LEAD_STREET_FIELD);
		const city = getFieldValue(this._ld, LEAD_CITY_FIELD);
		const state = getFieldValue(this._ld, LEAD_STATE_FIELD);
		const postal = getFieldValue(this._ld, LEAD_POSTAL_CODE_FIELD);
		return [street, city, state, postal].filter(Boolean).join(', ');
	}
}
