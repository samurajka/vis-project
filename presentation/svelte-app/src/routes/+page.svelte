<script>
  import { user } from '$lib/authStore.js';
  import { goto } from '$app/navigation';

  // Redirect to login if not authenticated
  if (!$user) {
    goto('/login');
  }
</script>

<div class="home-container">
  <h1>Welcome to VIS Marketplace</h1>
  <p>Your premier card trading platform</p>

  {#if $user}
    <div class="welcome-message">
      <h2>Hello, {$user.name}!</h2>
      <p>You are logged in with ID: {$user.id}</p>
    </div>

    <div class="nav-links">
      <a href="/listing" class="nav-link">Create Listing</a>
      <a href="/browse" class="nav-link">Browse Listings</a>
    </div>
  {/if}
</div>

<style>
  .home-container {
    text-align: center;
    padding: 2rem;
  }

  h1 {
    color: #333;
    margin-bottom: 0.5rem;
  }

  .welcome-message {
    background-color: #f0f0f0;
    padding: 2rem;
    border-radius: 8px;
    margin: 2rem 0;
  }

  .nav-links {
    display: flex;
    gap: 1rem;
    justify-content: center;
    margin-top: 2rem;
    flex-wrap: wrap;
  }

  .nav-link {
    display: inline-block;
    padding: 0.75rem 1.5rem;
    background-color: #667eea;
    color: white;
    text-decoration: none;
    border-radius: 4px;
    transition: background-color 0.3s;
  }

  .nav-link:hover {
    background-color: #5568d3;
  }
</style>
