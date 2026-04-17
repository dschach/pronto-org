import { track } from 'lwc';
import LightningModal from 'lightning/modal';
import getDataGraphData from '@salesforce/apex/GetDataFromRTDatagraph.parseDataGraphResponse';

export default class ApiCalloutTool extends LightningModal {
	@track dataGraphEntityName = 'Real_Time_Engagements';
	@track lookupKeys = '';
	@track isLoading = false;
	@track error = '';
	@track response = null;

	get formattedResponse() {
		if (!this.response) {
			return '';
		}
		try {
			return JSON.stringify(this.response, null, 2);
		} catch {
			return this.response;
		}
	}

	handleEntityChange(event) {
		this.dataGraphEntityName = event.target.value;
		this.clearError();
	}

	handleLookupKeysChange(event) {
		this.lookupKeys = event.target.value;
		this.clearError();
	}

	clearError() {
		this.error = '';
		this.response = null;
	}

	handleClose() {
		this.close('okay');
	}

	async handleApiCallout() {
		if (!this.dataGraphEntityName.trim()) {
			this.error = 'Please enter a Data Graph Entity Name';
			return;
		}

		if (!this.lookupKeys.trim()) {
			this.error = 'Please enter Lookup Keys';
			return;
		}

		this.isLoading = true;
		this.clearError();

		getDataGraphData({
			dataGraphEntityName: this.dataGraphEntityName.trim(),
			lookupKeys: this.lookupKeys.trim()
		})
			.then((result) => {
				this.error = undefined;
				this.response = result;
			})
			.catch((error) => {
				this.error = error.message || 'An error occurred while making the API callout';
			})
			.finally(() => {
				this.isLoading = false;
			});
	}
}
