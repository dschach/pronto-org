import { LightningElement, api } from 'lwc';
//import getPageEngagements from '@salesforce/apex/GetEngagements.getPageEngagements';

export default class RealTimeEngagements extends LightningElement {
    @api recordId;
    allEngagements = [];
    error;
    isLoading = true;
    showModal = false;

    // Pagination
    currentPage = 1;
    pageSize = 5;

    /*


    connectedCallback() {
        this.loadEngagements();
    }

    async loadEngagements() {
        if (!this.recordId) {
            this.isLoading = false;
            return;
        }

        try {
            this.isLoading = true;
            this.currentPage = 1; // Reset to first page
            const result = await getPageEngagements({ recordId: this.recordId });

            // Transform the API data to match the component's expected format
            this.allEngagements = result.map(engagement => ({
                id: engagement.engagementId,
                title: this.getEngagementTitle(engagement),
                timestamp: this.formatTimestamp(engagement.engagementDateTime || engagement.createdDate),
                engagementType: engagement.engagementType,
                deviceType: engagement.deviceType,
                browserName: engagement.browserName,
                description: engagement.description,
                sourcePageType: engagement.sourcePageType,
                cta: engagement.cta,
                dataSource: engagement.dataSource,
                icon: this.getEngagementIcon(engagement)
            }));

            this.error = undefined;
        } catch (error) {
            console.error('Error loading engagements:', error);
            this.error = error.body?.message || error.message || 'Unknown error occurred';
            this.allEngagements = [];
        } finally {
            this.isLoading = false;
        }
    }

    // Modal event handlers
    handleViewUnifiedProfiles() {
        this.showModal = true;
    }

    handleModalClose() {
        this.showModal = false;
    }

    getEngagementTitle(engagement) {
        if (engagement.engagementType) {
            return `${engagement.engagementType} Engagement`;
        }
        return 'Page Engagement';
    }

    getEngagementIcon(engagement) {
        const type = (engagement.engagementType || '').toLowerCase();

        // Use more specific SLDS icons based on engagement type
        if (type.includes('form') || type.includes('submit')) return 'standard:form';
        if (type.includes('download')) return 'standard:document';
        if (type.includes('click') || type.includes('button')) return 'utility:touch_action';
        if (type.includes('video') || type.includes('play')) return 'standard:video';
        if (type.includes('page') || type.includes('view')) return 'standard:page';
        if (type.includes('search')) return 'utility:search';
        if (type.includes('email')) return 'standard:email';
        if (type.includes('call') || type.includes('phone')) return 'standard:call';
        if (type.includes('chat') || type.includes('message')) return 'standard:live_chat';
        if (type.includes('social')) return 'standard:social';
        if (type.includes('link') || type.includes('url')) return 'utility:link';
        if (type.includes('tier') || type.includes('partner')) return 'standard:partner_fund_allocation';

        // Default icon for general engagements
        return 'standard:marketing_actions';
    }

    formatTimestamp(dateString) {
        if (!dateString) return '';

        try {
            const date = new Date(dateString);
            return date.toLocaleString();
        } catch (error) {
            return dateString; // Return original string if parsing fails
        }
    }

    // --- Pagination Logic ---
    get paginatedEngagements() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = startIndex + this.pageSize;
        const result = this.allEngagements.slice(startIndex, endIndex);

        return result;
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage >= Math.ceil(this.allEngagements.length / this.pageSize);
    }

    get paginationSummary() {
        if (!this.hasEngagements) return '';
        const first = (this.currentPage - 1) * this.pageSize + 1;
        const last = Math.min(this.currentPage * this.pageSize, this.allEngagements.length);
        return `${first}-${last} of ${this.allEngagements.length}`;
    }

    handlePreviousPage() {
        if (!this.isFirstPage) {
            this.currentPage--;
        }
    }

    handleNextPage() {
        if (!this.isLastPage) {
            this.currentPage++;
        }
    }

    // Getter for computed properties
    get hasEngagements() {
        return this.allEngagements && this.allEngagements.length > 0;
    }

    get hasError() {
        return this.error;
    }

    // Getter for engagement statistics
    get engagementStats() {
        if (!this.allEngagements || this.allEngagements.length === 0) {
            return null;
        }

        const stats = {
            total: this.allEngagements.length,
            uniqueTypes: 0
        };

        // Count unique engagement types
        const uniqueTypes = new Set();
        this.allEngagements.forEach(engagement => {
            const type = engagement.engagementType || 'Unknown';
            uniqueTypes.add(type);
        });

        stats.uniqueTypes = uniqueTypes.size;

        return stats;
    }

    */

}