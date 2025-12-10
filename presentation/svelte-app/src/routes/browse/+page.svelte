<script>
  import { user } from '$lib/authStore.js';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import ReportListingModal from '$components/ReportListingModal.svelte';

  let listings = [];
  let loading = true;
  let error = '';
  let selectedListing = null;
  let selectedTab = 'all';
  let showReportModal = false;
  let listingToReport = null;

  const conditionNames = {
    0: 'Mint',
    1: 'Near Mint',
    2: 'Worn',
    3: 'Damaged'
  };

  // Redirect to login if not authenticated
  if (!$user) {
    goto('/login');
  }

  onMount(async () => {
    try {
      const response = await fetch('http://localhost:8080/api/listings');
      if (!response.ok) {
        error = 'Failed to load listings';
        loading = false;
        return;
      }
      listings = await response.json();
      loading = false;
    } catch (e) {
      error = 'Failed to connect to server';
      loading = false;
    }
  });

  function getConditionClass(condition) {
    const classes = {
      0: 'condition-mint',
      1: 'condition-nearmint',
      2: 'condition-worn',
      3: 'condition-damaged'
    };
    return classes[condition] || '';
  }

  function openListing(listing) {
    selectedListing = listing;
  }

  function closeListing() {
    selectedListing = null;
  }

  function openReportModal(listing) {
    listingToReport = listing;
    showReportModal = true;
    closeListing();
  }

  function closeReportModal() {
    showReportModal = false;
    listingToReport = null;
  }

  function onReportSubmitted() {
    // Could refresh warnings count here if needed
  }
</script>

<div class="browse-container">
  <div class="header">
    <h1>Browse Marketplace Listings</h1>
    <p class="subtitle">Discover cards for sale</p>
  </div>

  {#if error}
    <div class="error-message">{error}</div>
  {/if}

  {#if loading}
    <div class="loading">Loading listings...</div>
  {:else if listings.length === 0}
    <div class="no-listings">
      <p>No listings available yet.</p>
      <a href="/listing" class="cta-button">Create a Listing</a>
    </div>
  {:else}
    <div class="listings-grid">
      {#each listings as listing (listing.id)}
        <div class="listing-card" role="button" tabindex="0" onkeydown={(e) => e.key === 'Enter' && openListing(listing)} onclick={() => openListing(listing)}>
          <div class="listing-header">
            <h3>Listing #{listing.id}</h3>
            <span class="price">${listing.price.toFixed(2)}</span>
          </div>

          <div class="cards-preview">
            {#if listing.cards && listing.cards.length > 0}
              <div class="card-count">
                {listing.cards.length} card{listing.cards.length !== 1 ? 's' : ''}
              </div>
              <div class="cards-list">
                {#each listing.cards.slice(0, 3) as card}
                  <div class="card-tag">
                    Card #{card.cid}
                    {#if card.foil}
                      <span class="foil-badge">✨</span>
                    {/if}
                  </div>
                {/each}
                {#if listing.cards.length > 3}
                  <div class="card-tag more">
                    +{listing.cards.length - 3} more
                  </div>
                {/if}
              </div>
            {/if}
          </div>

          <button class="view-button">View Details</button>
        </div>
      {/each}
    </div>
  {/if}

  {#if selectedListing}
    <div class="modal-overlay" role="presentation" onclick={closeListing}>
      <div class="modal" role="dialog" tabindex="-1" onclick={(e) => e.stopPropagation()} onkeydown={(e) => e.key === 'Escape' && closeListing()}>
        <div class="modal-header">
          <h2>Listing #{selectedListing.id}</h2>
          <button class="close-button" onclick={closeListing}>×</button>
        </div>

        <div class="modal-content">
          <div class="listing-price">
            <span class="label">Total Price:</span>
            <span class="price">${selectedListing.price.toFixed(2)}</span>
          </div>

          {#if selectedListing.cards && selectedListing.cards.length > 0}
            <div class="cards-section">
              <h3>Cards in Listing ({selectedListing.cards.length})</h3>
              <div class="cards-detailed">
                {#each selectedListing.cards as card (card.id)}
                  <div class="card-detail">
                    <div class="card-number">Card #{card.cid}</div>
                    <div class="card-attributes">
                      <span class="attribute">
                        <strong>Condition:</strong>
                        <span class={getConditionClass(card.cond)}>
                          {conditionNames[card.cond] || 'Unknown'}
                        </span>
                      </span>
                      {#if card.foil}
                        <span class="attribute foil">
                          <strong>Special:</strong> Foil
                        </span>
                      {/if}
                    </div>
                  </div>
                {/each}
              </div>
            </div>
          {/if}

          <div class="modal-actions">
            <button class="btn-secondary" onclick={() => openReportModal(selectedListing)}>⚠️ Report Listing</button>
            <button class="btn-primary" onclick={() => alert('Feature coming soon!')}>Contact Seller</button>
            <button class="btn-secondary" onclick={closeListing}>Close</button>
          </div>
        </div>
      </div>
    </div>
  {/if}

  <ReportListingModal
    listing={listingToReport}
    isOpen={showReportModal}
    onClose={closeReportModal}
    onSubmit={onReportSubmitted}
  />
</div>

<style>
  .browse-container {
    padding: 2rem;
    max-width: 1200px;
    margin: 0 auto;
  }

  .header {
    text-align: center;
    margin-bottom: 3rem;
  }

  .header h1 {
    font-size: 2.5rem;
    color: #333;
    margin: 0 0 0.5rem 0;
  }

  .subtitle {
    color: #666;
    font-size: 1.1rem;
    margin: 0;
  }

  .error-message {
    background: #fee;
    color: #c33;
    padding: 1rem;
    border-radius: 8px;
    margin-bottom: 2rem;
    border-left: 4px solid #c33;
  }

  .loading {
    text-align: center;
    padding: 3rem;
    color: #666;
    font-size: 1.1rem;
  }

  .no-listings {
    text-align: center;
    padding: 3rem;
    background: #f9f9f9;
    border-radius: 8px;
  }

  .no-listings p {
    color: #666;
    margin-bottom: 1.5rem;
  }

  .cta-button {
    display: inline-block;
    padding: 0.75rem 1.5rem;
    background: #667eea;
    color: white;
    text-decoration: none;
    border-radius: 4px;
    transition: background-color 0.3s;
  }

  .cta-button:hover {
    background-color: #5568d3;
  }

  .listings-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 1.5rem;
  }

  .listing-card {
    background: white;
    border: 1px solid #ddd;
    border-radius: 8px;
    padding: 1.5rem;
    transition: all 0.3s;
    cursor: pointer;
    display: flex;
    flex-direction: column;
  }

  .listing-card:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    border-color: #667eea;
  }

  .listing-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
  }

  .listing-header h3 {
    margin: 0;
    color: #333;
    font-size: 1.2rem;
  }

  .price {
    font-size: 1.5rem;
    font-weight: bold;
    color: #667eea;
  }

  .cards-preview {
    flex-grow: 1;
    margin-bottom: 1rem;
  }

  .card-count {
    font-size: 0.9rem;
    color: #666;
    margin-bottom: 0.5rem;
  }

  .cards-list {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
  }

  .card-tag {
    background: #f0f0f0;
    padding: 0.4rem 0.8rem;
    border-radius: 4px;
    font-size: 0.85rem;
    color: #555;
    display: flex;
    align-items: center;
    gap: 0.3rem;
  }

  .card-tag.more {
    background: #e8e8e8;
    color: #666;
    font-style: italic;
  }

  .foil-badge {
    margin-left: 0.2rem;
  }

  .view-button {
    padding: 0.75rem;
    background: #667eea;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-weight: 600;
    transition: background-color 0.3s;
  }

  .view-button:hover {
    background-color: #5568d3;
  }

  /* Modal Styles */
  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
  }

  .modal {
    background: white;
    border-radius: 8px;
    max-width: 600px;
    width: 90%;
    max-height: 80vh;
    overflow-y: auto;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  }

  .modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 2rem;
    border-bottom: 1px solid #eee;
  }

  .modal-header h2 {
    margin: 0;
    color: #333;
  }

  .close-button {
    background: none;
    border: none;
    font-size: 2rem;
    cursor: pointer;
    color: #999;
    transition: color 0.3s;
  }

  .close-button:hover {
    color: #333;
  }

  .modal-content {
    padding: 2rem;
  }

  .listing-price {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem;
    background: #f9f9f9;
    border-radius: 4px;
    margin-bottom: 2rem;
  }

  .listing-price .label {
    color: #666;
    font-weight: 600;
  }

  .listing-price .price {
    font-size: 1.8rem;
    font-weight: bold;
    color: #667eea;
  }

  .cards-section h3 {
    margin-top: 0;
    color: #333;
    border-bottom: 2px solid #667eea;
    padding-bottom: 0.5rem;
  }

  .cards-detailed {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .card-detail {
    padding: 1rem;
    border: 1px solid #eee;
    border-radius: 4px;
    background: #fafafa;
  }

  .card-number {
    font-weight: bold;
    color: #333;
    margin-bottom: 0.5rem;
  }

  .card-attributes {
    display: flex;
    flex-wrap: wrap;
    gap: 1rem;
  }

  .attribute {
    font-size: 0.9rem;
  }

  .attribute strong {
    color: #555;
  }

  .condition-mint {
    color: #27ae60;
    font-weight: bold;
  }

  .condition-nearmint {
    color: #2ecc71;
    font-weight: bold;
  }

  .condition-worn {
    color: #f39c12;
    font-weight: bold;
  }

  .condition-damaged {
    color: #e74c3c;
    font-weight: bold;
  }

  .attribute.foil {
    color: #667eea;
  }

  .modal-actions {
    display: flex;
    gap: 1rem;
    margin-top: 2rem;
    padding-top: 2rem;
    border-top: 1px solid #eee;
  }

  .btn-primary,
  .btn-secondary {
    flex: 1;
    padding: 0.75rem;
    border: none;
    border-radius: 4px;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
  }

  .btn-primary {
    background: #667eea;
    color: white;
  }

  .btn-primary:hover {
    background-color: #5568d3;
  }

  .btn-secondary {
    background: #f0f0f0;
    color: #333;
  }

  .btn-secondary:hover {
    background: #e0e0e0;
  }

  @media (max-width: 768px) {
    .browse-container {
      padding: 1rem;
    }

    .header h1 {
      font-size: 1.8rem;
    }

    .listings-grid {
      grid-template-columns: 1fr;
    }

    .modal {
      width: 95%;
    }
  }
</style>
