import { LightningElement, api } from 'lwc';
import userId from '@salesforce/user/Id';

export default class MenuUpload extends LightningElement {
	_value = {};
	_files = [];
	uploadRecordId = userId;

	acceptedFormats = ['.pdf', '.png', '.jpg', '.jpeg'];

	@api
	get value() {
		return this._value;
	}
	set value(v) {
		this._value = v && typeof v === 'object' ? v : {};
	}

	get storefrontId() {
		return this._value.storefrontId || null;
	}

	get hasFiles() {
		return this._files.length > 0;
	}

	get fileCount() {
		return this._files.length;
	}

	handleUploadFinished(event) {
		event.stopPropagation();
		const uploaded = event.detail.files || [];
		for (const f of uploaded) {
			this._files.push({
				documentId: f.documentId,
				name: f.name,
				size: null,
				mimeType: null
			});
		}
		this.dispatchEvent(
			new CustomEvent('valuechange', {
				detail: {
					value: {
						...this._value,
						files: [...this._files]
					}
				}
			})
		);
	}
}
