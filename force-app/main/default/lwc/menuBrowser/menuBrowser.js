import { LightningElement, api, track } from 'lwc';
import getMenuCategories from '@salesforce/apex/MenuBrowserController.getMenuCategories';
import getMenuItems from '@salesforce/apex/MenuBrowserController.getMenuItems';

export default class MenuBrowser extends LightningElement {
	@api recordId;
	@track categories = [];
	@track items = [];
	@track filteredItems = [];
	@track selectedCategoryId = null;
	@track searchKeyword = '';
	@track showVegetarian = false;
	@track showSpicy = false;
	@track loading = true;
	@track error = null;

	connectedCallback() {
		if (this.recordId) {
			this.loadMenuData();
		}
	}

	loadMenuData() {
		this.loading = true;
		this.error = null;

		const menuId = this.recordId;

		getMenuCategories({ menuId })
			.then((result) => {
				this.categories = result;
				// Set first category as default selected
				if (this.categories.length > 0) {
					this.selectedCategoryId = this.categories[0].id;
				}
				return getMenuItems({ menuId });
			})
			.then((result) => {
				this.items = result;
				this.filteredItems = result;
				this.applyFilters();
			})
			.catch((error) => {
				this.error = error;
			})
			.finally(() => {
				this.loading = false;
			});
	}

	handleCategorySelect(event) {
		this.selectedCategoryId = event.detail.categoryId;
		this.applyFilters();
	}

	handleSearchInput(event) {
		this.searchKeyword = event.target.value.toLowerCase();
		this.applyFilters();
	}

	handleVegetarianFilter() {
		this.showVegetarian = !this.showVegetarian;
		this.applyFilters();
	}

	handleSpicyFilter() {
		this.showSpicy = !this.showSpicy;
		this.applyFilters();
	}

	applyFilters() {
		let filtered = this.items;

		// Apply category filter
		if (this.selectedCategoryId) {
			filtered = filtered.filter((item) => item.Menu_Category__c === this.selectedCategoryId);
		}

		// Apply search filter
		if (this.searchKeyword) {
			filtered = filtered.filter(
				(item) => item.Name.toLowerCase().includes(this.searchKeyword) || (item.Description__c && item.Description__c.toLowerCase().includes(this.searchKeyword))
			);
		}

		// Apply vegetarian filter
		if (this.showVegetarian) {
			filtered = filtered.filter(
				(item) =>
					item.Name.toLowerCase().includes('vegan') ||
					item.Name.toLowerCase().includes('vegetarian') ||
					item.Description__c?.toLowerCase().includes('vegan') ||
					item.Description__c?.toLowerCase().includes('vegetarian')
			);
		}

		// Apply spicy filter
		if (this.showSpicy) {
			filtered = filtered.filter(
				(item) =>
					item.Name.toLowerCase().includes('spicy') ||
					item.Name.toLowerCase().includes('hot') ||
					item.Description__c?.toLowerCase().includes('spicy') ||
					item.Description__c?.toLowerCase().includes('hot')
			);
		}

		this.filteredItems = filtered;
	}

	get selectedCategoryName() {
		if (!this.selectedCategoryId || this.categories.length === 0) {
			return '';
		}
		const selectedCat = this.categories.find((cat) => cat.id === this.selectedCategoryId);
		return selectedCat ? selectedCat.Name : '';
	}

	get hasError() {
		return this.error !== null;
	}

	get hasItems() {
		return this.filteredItems && this.filteredItems.length > 0;
	}

	get itemsCount() {
		return this.filteredItems ? this.filteredItems.length : 0;
	}
}
