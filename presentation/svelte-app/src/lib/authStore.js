import { writable } from 'svelte/store';

function createAuthStore() {
  // Try to load user from localStorage
  const stored = typeof window !== 'undefined' ? localStorage.getItem('user') : null;
  const initial = stored ? JSON.parse(stored) : null;

  const { subscribe, set, update } = writable(initial);

  return {
    subscribe,
    login: (user) => {
      if (typeof window !== 'undefined') {
        localStorage.setItem('user', JSON.stringify(user));
      }
      set(user);
    },
    logout: () => {
      if (typeof window !== 'undefined') {
        localStorage.removeItem('user');
      }
      set(null);
    },
    set
  };
}

export const user = createAuthStore();
