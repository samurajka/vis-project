<script>
  import { user } from '$lib/authStore.js';
  import { goto } from '$app/navigation';

  // Redirect to login if not authenticated
  if (!$user) {
    goto('/login');
  }

  let price = "";
  let cards = [];
  let loading = false;
  let error = '';
  let success = false;
  let successId = null;

  const conditionMap = {
    mint: 0,
    nearmint: 1,
    worn: 2,
    damaged: 3
  };

  function addCard() {
    cards = [...cards, { cid: "", cond: "mint", foil: false }];
  }

  function removeCard(index) {
    cards = cards.filter((_, i) => i !== index);
  }

  async function submitForm() {
    error = '';
    loading = true;

    // Validation
    if (!price || Number(price) <= 0) {
      error = 'Please enter a valid price';
      loading = false;
      return;
    }

    if (cards.length === 0) {
      error = 'Please add at least one card';
      loading = false;
      return;
    }

    const payload = {
      price: Number(price),
      cards: cards.map((c) => ({
        cid: Number(c.cid),
        cond: conditionMap[c.cond],
        foil: c.foil ? 1 : 0
      }))
    };

    try {
      const response = await fetch("http://localhost:8080/api/marketlisting", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
      });

      if (response.ok) {
        success = true;
        successId = Date.now(); // Use timestamp as fallback ID
        price = '';
        cards = [];
        setTimeout(() => {
          success = false;
          goto('/browse');
        }, 2000);
      } else {
        const data = await response.json();
        error = data.error || 'Failed to create listing';
      }
    } catch (e) {
      error = 'Failed to connect to server';
    }

    loading = false;
  }
</script>

<div class="listing-container">
  <div class="header">
    <h1>Create a Listing</h1>
    <p class="subtitle">Sell your cards on VIS Marketplace</p>
  </div>

  {#if error}
    <div class="error-message">{error}</div>
  {/if}

  {#if success}
    <div class="success-message">
      ✓ Listing created successfully! Redirecting...
    </div>
  {/if}

  <form onsubmit={(e) => { e.preventDefault(); submitForm(); }} class="form">
    <div class="form-group">
      <label for="price">
        Total Price: <span class="required">*</span>
      </label>
      <input
        id="price"
        type="number"
        step="0.01"
        min="0"
        bind:value={price}
        placeholder="Enter total price (e.g., 49.99)"
        disabled={loading}
      />
    </div>

    <div class="form-group">
      <h3>Cards in Listing</h3>
      <p class="helper-text">Add the cards you want to sell</p>

      {#if cards.length === 0}
        <div class="no-cards">No cards added yet</div>
      {/if}

      {#each cards as card, i (i)}
        <div class="card-item">
          <div class="card-index">Card {i + 1}</div>

          <div class="card-inputs">
            <div class="input-group">
              <label for="card-{i}-id">
                Card ID: <span class="required">*</span>
              </label>
              <input
                id="card-{i}-id"
                type="number"
                min="1"
                bind:value={card.cid}
                placeholder="Card ID"
                disabled={loading}
              />
            </div>

            <div class="input-group">
              <label for="card-{i}-cond">
                Condition: <span class="required">*</span>
              </label>
              <select bind:value={card.cond} disabled={loading}>
                <option value="mint">Mint</option>
                <option value="nearmint">Near Mint</option>
                <option value="worn">Worn</option>
                <option value="damaged">Damaged</option>
              </select>
            </div>

            <div class="input-group checkbox-group">
              <label for="card-{i}-foil">
                <input
                  id="card-{i}-foil"
                  type="checkbox"
                  bind:checked={card.foil}
                  disabled={loading}
                />
                Foil ✨
              </label>
            </div>

            <button
              type="button"
              class="btn-remove"
              onclick={() => removeCard(i)}
              disabled={loading}
            >
              Remove
            </button>
          </div>
        </div>
      {/each}

      <button
        type="button"
        class="btn-add-card"
        onclick={addCard}
        disabled={loading}
      >
        + Add Another Card
      </button>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn-primary" disabled={loading}>
        {#if loading}
          Creating Listing...
        {:else}
          Create Listing
        {/if}
      </button>
      <a href="/" class="btn-secondary">Cancel</a>
    </div>
  </form>
</div>

<style>
  .listing-container {
    max-width: 700px;
    margin: 0 auto;
    padding: 2rem;
  }

  .header {
    text-align: center;
    margin-bottom: 2rem;
  }

  .header h1 {
    font-size: 2rem;
    color: #333;
    margin: 0 0 0.5rem 0;
  }

  .subtitle {
    color: #666;
    margin: 0;
  }

  .error-message {
    background: #fee;
    color: #c33;
    padding: 1rem;
    border-radius: 8px;
    margin-bottom: 1.5rem;
    border-left: 4px solid #c33;
  }

  .success-message {
    background: #efe;
    color: #3c3;
    padding: 1rem;
    border-radius: 8px;
    margin-bottom: 1.5rem;
    border-left: 4px solid #3c3;
  }

  .form {
    background: white;
    padding: 2rem;
    border-radius: 8px;
    border: 1px solid #ddd;
  }

  .form-group {
    margin-bottom: 2rem;
  }

  .form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 600;
    color: #333;
  }

  .required {
    color: #e74c3c;
  }

  .helper-text {
    color: #666;
    font-size: 0.9rem;
    margin-bottom: 1rem;
  }

  .form-group input,
  .form-group select {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 1rem;
    box-sizing: border-box;
  }

  .form-group input:focus,
  .form-group select:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
  }

  .form-group input:disabled,
  .form-group select:disabled {
    background-color: #f5f5f5;
    cursor: not-allowed;
  }

  .no-cards {
    padding: 2rem;
    text-align: center;
    background: #f9f9f9;
    border-radius: 4px;
    color: #999;
  }

  .card-item {
    background: #f9f9f9;
    padding: 1.5rem;
    border-radius: 8px;
    border: 1px solid #eee;
    margin-bottom: 1rem;
  }

  .card-index {
    font-weight: bold;
    color: #667eea;
    margin-bottom: 1rem;
    font-size: 0.95rem;
  }

  .card-inputs {
    display: grid;
    grid-template-columns: 1fr 1fr auto auto;
    gap: 1rem;
    align-items: flex-end;
  }

  .input-group {
    display: flex;
    flex-direction: column;
  }

  .input-group label {
    font-size: 0.85rem;
    margin-bottom: 0.4rem;
  }

  .input-group input,
  .input-group select {
    margin: 0 !important;
  }

  .checkbox-group {
    flex-direction: row;
    align-items: center;
  }

  .checkbox-group label {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin: 0;
  }

  .checkbox-group input {
    margin: 0;
  }

  .btn-remove {
    padding: 0.75rem 1rem;
    background: #e74c3c;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-weight: 600;
    transition: background-color 0.3s;
  }

  .btn-remove:hover:not(:disabled) {
    background-color: #c0392b;
  }

  .btn-remove:disabled {
    background-color: #ccc;
    cursor: not-allowed;
  }

  .btn-add-card {
    display: block;
    width: 100%;
    padding: 0.75rem;
    background: #ecf0f1;
    color: #333;
    border: 2px dashed #bdc3c7;
    border-radius: 4px;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.3s;
  }

  .btn-add-card:hover:not(:disabled) {
    background: #e8e8e8;
    border-color: #667eea;
  }

  .btn-add-card:disabled {
    cursor: not-allowed;
    opacity: 0.6;
  }

  .form-actions {
    display: flex;
    gap: 1rem;
    margin-top: 2rem;
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
    text-decoration: none;
    text-align: center;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .btn-primary {
    background: #667eea;
    color: white;
  }

  .btn-primary:hover:not(:disabled) {
    background-color: #5568d3;
  }

  .btn-primary:disabled {
    background-color: #ccc;
    cursor: not-allowed;
  }

  .btn-secondary {
    background: #ecf0f1;
    color: #333;
  }

  .btn-secondary:hover {
    background: #e0e0e0;
  }

  @media (max-width: 768px) {
    .listing-container {
      padding: 1rem;
    }

    .header h1 {
      font-size: 1.5rem;
    }

    .form {
      padding: 1.5rem;
    }

    .card-inputs {
      grid-template-columns: 1fr;
    }

    .btn-remove {
      width: 100%;
    }
  }
</style>
