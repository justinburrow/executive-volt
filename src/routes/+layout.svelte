<script lang="ts">
	import './layout.css';

	let { children } = $props();
</script>

<div class="app">
  <header></header>
	<main>
    {@render children()}
  </main>
  <footer></footer>
</div>

<style>
</style>
