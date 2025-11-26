<script>
  let price = "";
  let cards = [];

  const conditionMap = {
    mint: 0,
    nearmint: 1,
    worn: 2,
    damaged: 3
  };

  function addCard() {
    cards = [...cards, { cid: "", cond: "mint", foil: false }];
  }

  async function submitForm() {
    const payload = {
      price: Number(price),
      cards: cards.map((c) => ({
        cid: Number(c.cid),
        cond: conditionMap[c.cond],
        foil: c.foil ? 1 : 0
      }))
    };

    console.log(payload)

    await fetch("http://localhost:8080/api/marketlisting", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
  }
</script>

<form on:submit|preventDefault={submitForm} class="form">
  <label>
    Price:
    <input type="number" bind:value={price} />
  </label>

  <h3>Cards</h3>
  {#each cards as card, i}
    <div class="card-item">
      <label>
        Card ID:
        <input type="number" bind:value={card.id} />
      </label>

      <label>
        Condition:
        <select bind:value={card.condition}>
          <option value="mint">Mint</option>
          <option value="nearmint">Near Mint</option>
          <option value="worn">Worn</option>
          <option value="damaged">Damaged</option>
        </select>
      </label>

      <label>
        Foil:
        <input type="checkbox" bind:checked={card.foil} />
      </label>
    </div>
  {/each}

  <button type="button" on:click={addCard}>Add Card</button>
  <button type="submit">Submit Listing</button>
</form>

<style>
  .form {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }
  .card-item {
    padding: 0.5rem;
    border: 1px solid #ccc;
    border-radius: 6px;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }
</style>
