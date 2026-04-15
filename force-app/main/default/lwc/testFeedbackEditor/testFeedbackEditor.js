import { LightningElement, api } from 'lwc';

export default class TestFeedbackEditor extends LightningElement {
    _value = {};
    comment = '';

    @api
    get value() {
        return this._value;
    }
    set value(v) {
        this._value = v && typeof v === 'object' ? v : {};
        this.comment = this._value.comment || '';
    }

    handleChange(event) {
        event.stopPropagation();
        this.comment = event.target.value;
        this.dispatchEvent(
            new CustomEvent('valuechange', {
                detail: {
                    value: { comment: this.comment }
                }
            })
        );
    }
}