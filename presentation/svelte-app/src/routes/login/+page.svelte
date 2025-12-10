<script>
  import { user } from '$lib/authStore.js';
  import { goto } from '$app/navigation';

  let username = '';
  let password = '';
  let error = '';
  let loading = false;

  async function handleLogin() {
    error = '';
    loading = true;

    try {
      const response = await fetch('http://localhost:8080/api/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: username, password })
      });

      const data = await response.json();

      if (!response.ok) {
        error = data.error || 'Login failed';
        loading = false;
        return;
      }

      // Store user and redirect
      user.login({ id: data.id, name: data.name });
      goto('/');
    } catch (e) {
      error = 'Failed to connect to server. Make sure backend is running on http://localhost:8080';
      loading = false;
    }
  }

  function handleKeydown(e) {
    if (e.key === 'Enter') {
      handleLogin();
    }
  }
</script>

<div class="login-container">
  <div class="login-box">
    <h1>VIS Login</h1>
    <p class="subtitle">Card Trading Marketplace</p>

    {#if error}
      <div class="error-message">{error}</div>
    {/if}

    <form on:submit|preventDefault={handleLogin}>
      <div class="form-group">
        <label for="username">Username</label>
        <input
          id="username"
          type="text"
          bind:value={username}
          placeholder="Enter username"
          on:keydown={handleKeydown}
          disabled={loading}
        />
      </div>

      <div class="form-group">
        <label for="password">Password</label>
        <input
          id="password"
          type="password"
          bind:value={password}
          placeholder="Enter password"
          on:keydown={handleKeydown}
          disabled={loading}
        />
      </div>

      <button type="submit" disabled={loading}>
        {#if loading}
          Logging in...
        {:else}
          Login
        {/if}
      </button>
    </form>

    <p class="demo-note">Demo login: Pepa password123</p>
  </div>
</div>

<style>
  .login-container {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 100vh;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  }

  .login-box {
    background: white;
    padding: 2rem;
    border-radius: 10px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
    width: 100%;
    max-width: 400px;
  }

  h1 {
    margin: 0 0 0.5rem 0;
    color: #333;
    text-align: center;
    font-size: 2rem;
  }

  .subtitle {
    text-align: center;
    color: #666;
    margin: 0 0 2rem 0;
  }

  .error-message {
    background: #fee;
    color: #c33;
    padding: 1rem;
    border-radius: 5px;
    margin-bottom: 1.5rem;
    border-left: 4px solid #c33;
  }

  form {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  .form-group {
    display: flex;
    flex-direction: column;
  }

  label {
    margin-bottom: 0.5rem;
    color: #333;
    font-weight: 500;
  }

  input {
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 5px;
    font-size: 1rem;
    transition: border-color 0.3s;
  }

  input:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
  }

  input:disabled {
    background-color: #f5f5f5;
    cursor: not-allowed;
  }

  button {
    padding: 0.75rem;
    background: #667eea;
    color: white;
    border: none;
    border-radius: 5px;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    transition: background-color 0.3s;
  }

  button:hover:not(:disabled) {
    background-color: #5568d3;
  }

  button:disabled {
    background-color: #ccc;
    cursor: not-allowed;
  }

  .demo-note {
    text-align: center;
    color: #999;
    font-size: 0.85rem;
    margin-top: 1.5rem;
  }
</style>
