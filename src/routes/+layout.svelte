<script lang="ts">
	import './layout.css';

	let { children } = $props();
</script>

<div class="app">
	<main>{@render children()}</main>
	<footer>
		<p>footer</p>
	</footer>
</div>

<style>
</style>
