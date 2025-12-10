<script>
  import { user } from '$lib/authStore.js';

  export let listing = null;
  export let isOpen = false;
  export let onClose = () => {};
  export let onSubmit = () => {};

  let reason = '';
  let loading = false;
  let error = '';
  let success = false;

  const reasonOptions = [
    { value: 'incorrect_price', label: 'Incorrect Price' },
    { value: 'wrong_condition', label: 'Wrong Condition' },
    { value: 'missing_cards', label: 'Missing Cards' },
    { value: 'counterfeit', label: 'Counterfeit/Fake' },
    { value: 'damaged_shipping', label: 'Damaged During Shipping' },
    { value: 'not_as_described', label: 'Not As Described' },
    { value: 'other', label: 'Other Reason' }
  ];

  async function handleSubmit() {
    if (!reason.trim()) {
      error = 'Please select or enter a reason';
      return;
    }

    loading = true;
    error = '';

    try {
      const response = await fetch('http://localhost:8080/api/warning', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          marketListingId: listing.id,
          userId: $user.id,
          reason: reason
        })
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Failed to report listing');
      }

      success = true;
      onSubmit();
      setTimeout(() => {
        resetForm();
        onClose();
      }, 1500);
    } catch (e) {
      error = e.message || 'Failed to report listing';
    } finally {
      loading = false;
    }
  }

  function resetForm() {
    reason = '';
    error = '';
    success = false;
  }

  function handleClose() {
    resetForm();
    onClose();
  }

  function handleBackdropClick(e) {
    if (e.target === e.currentTarget) {
      handleClose();
    }
  }
</script>

{#if isOpen && listing}
  <div class="modal-backdrop" role="presentation" onclick={handleBackdropClick}>
    <div class="modal-content" role="dialog" aria-labelledby="report-title" aria-modal="true">
      <div class="modal-header">
        <h2 id="report-title">Report Listing</h2>
        <button
          class="close-btn"
          onclick={handleClose}
          aria-label="Close report modal"
        >
          ×
        </button>
      </div>

      {#if success}
        <div class="success-message">
          ✓ Thank you for reporting this listing. Our team will review it shortly.
        </div>
      {:else}
        <div class="modal-body">
          <div class="listing-info">
            <h3>Listing #{listing.id}</h3>
            <p class="price">${listing.price.toFixed(2)}</p>
          </div>

          <div class="form-group">
            <label for="reason-select">What's wrong with this listing?</label>
            <select
              id="reason-select"
              bind:value={reason}
              disabled={loading}
              class="reason-select"
            >
              <option value="">-- Select a reason --</option>
              {#each reasonOptions as option}
                <option value={option.label}>{option.label}</option>
              {/each}
            </select>
          </div>

          {#if reason === 'Other Reason' || reason === 'Other'}
            <div class="form-group">
              <label for="custom-reason">Please describe the issue:</label>
              <textarea
                id="custom-reason"
                bind:value={reason}
                placeholder="Describe what's wrong with this listing..."
                disabled={loading}
                class="custom-reason"
                rows="4"
              ></textarea>
            </div>
          {/if}

          {#if error}
            <div class="error-message">{error}</div>
          {/if}

          <div class="modal-actions">
            <button
              class="btn btn-secondary"
              onclick={handleClose}
              disabled={loading}
            >
              Cancel
            </button>
            <button
              class="btn btn-primary"
              onclick={handleSubmit}
              disabled={loading || !reason.trim()}
            >
              {loading ? 'Reporting...' : 'Report Listing'}
            </button>
          </div>
        </div>
      {/if}
    </div>
  </div>
{/if}

<style>
  .modal-backdrop {
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
    padding: 20px;
  }

  .modal-content {
    background: white;
    border-radius: 12px;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    max-width: 500px;
    width: 100%;
    max-height: 90vh;
    overflow-y: auto;
    animation: slideUp 0.3s ease-out;
  }

  @keyframes slideUp {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px;
    border-bottom: 1px solid #e5e7eb;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
  }

  .modal-header h2 {
    margin: 0;
    font-size: 1.5rem;
  }

  .close-btn {
    background: none;
    border: none;
    color: white;
    font-size: 28px;
    cursor: pointer;
    padding: 0;
    width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 4px;
    transition: background 0.2s;
  }

  .close-btn:hover {
    background: rgba(255, 255, 255, 0.1);
  }

  .modal-body {
    padding: 20px;
  }

  .listing-info {
    background: #f3f4f6;
    padding: 15px;
    border-radius: 8px;
    margin-bottom: 20px;
  }

  .listing-info h3 {
    margin: 0 0 8px 0;
    color: #333;
  }

  .listing-info .price {
    margin: 0;
    font-size: 1.25rem;
    font-weight: 600;
    color: #667eea;
  }

  .form-group {
    margin-bottom: 20px;
  }

  .form-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
    color: #333;
    font-size: 0.95rem;
  }

  .reason-select,
  .custom-reason {
    width: 100%;
    padding: 10px;
    border: 2px solid #e5e7eb;
    border-radius: 6px;
    font-size: 1rem;
    font-family: inherit;
    transition: border-color 0.3s;
  }

  .reason-select:focus,
  .custom-reason:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
  }

  .reason-select:disabled,
  .custom-reason:disabled {
    background: #f3f4f6;
    cursor: not-allowed;
    opacity: 0.6;
  }

  .custom-reason {
    resize: vertical;
  }

  .error-message {
    background: #fee2e2;
    border: 1px solid #fca5a5;
    color: #dc2626;
    padding: 12px;
    border-radius: 6px;
    margin-bottom: 20px;
    font-size: 0.95rem;
  }

  .success-message {
    background: #dcfce7;
    border: 1px solid #86efac;
    color: #16a34a;
    padding: 20px;
    border-radius: 6px;
    text-align: center;
    font-weight: 500;
  }

  .modal-actions {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
    padding-top: 20px;
    border-top: 1px solid #e5e7eb;
  }

  .btn {
    padding: 10px 20px;
    border: none;
    border-radius: 6px;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-size: 0.9rem;
  }

  .btn-primary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
  }

  .btn-primary:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
  }

  .btn-primary:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .btn-secondary {
    background: #e5e7eb;
    color: #333;
  }

  .btn-secondary:hover:not(:disabled) {
    background: #d1d5db;
  }

  .btn-secondary:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  @media (max-width: 640px) {
    .modal-content {
      max-width: 95vw;
      max-height: 95vh;
    }

    .modal-header {
      padding: 16px;
    }

    .modal-header h2 {
      font-size: 1.25rem;
    }

    .modal-body {
      padding: 16px;
    }

    .modal-actions {
      flex-direction: column-reverse;
    }

    .btn {
      width: 100%;
    }
  }
</style>
