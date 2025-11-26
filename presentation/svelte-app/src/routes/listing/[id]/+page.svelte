<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';

  let listing = null;
  let error = null;

  let id;
  $: id = $page.params.id;

  onMount(async () => {
    try {
      const res = await fetch(`http://localhost:8080/api/listing/${id}`);
      if (!res.ok) throw new Error(res.statusText);

      listing = await res.json();
    } catch (err) {
      error = err.message;
      console.error("Failed to fetch listing:", err);
    }
  });
</script>

{#if error}
  <p style="color:red">{error}</p>
{:else if !listing}
  <p>Loading...</p>
{:else}
  <h1>Listing #{listing.id}</h1>
  <p><strong>Price:</strong> ${listing.price}</p>

  <h2>Cards</h2>
  <ul>
    {#each listing.cards as card}
      <li>
        <strong>ID:</strong> {card.id} |
        <strong>Condition:</strong> {card.condition} |
        <strong>Foil:</strong> {card.foil ? "Yes" : "No"}
      </li>
    {/each}
  </ul>
{/if}
