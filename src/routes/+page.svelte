<script lang="ts">
	import { createToolbar, melt } from '@melt-ui/svelte';
  import { Omega } from '@lucide/svelte';

  const {
    elements: { root, button, link, separator },
    builders: { createToolbarGroup }
  } = createToolbar();
  const {
    elements: { group: typeGroup, item: typeItem },
  } = createToolbarGroup({
    type: 'single'
  })
</script>

<svelte:head>
	<title>Executive Volt</title>
	<meta name="description" content="Personal electronic component inventory and project-allocation tool" />
</svelte:head>

<div class="max-w-7xl mx-auto my-4 p-4 bg-gray-100">
  <section>
	<h1>Executive Volt</h1>
</section>

<section>
  <div
    use:melt={$root}
    class="flex min-w-max items-center gap-4 rounded-md bg-white px-3 py-3 text-neutral-700 shadow-sm lg:w-140"
  >
    <div class="flex items-center gap-1" use:melt={$typeGroup}>
      <button class="item" aria-label="component type" use:melt={$typeItem('resistor')}>
        <span class="sr-only">resistor</span>
        <Omega />
      </button>
      <button class="item" aria-label="component type" use:melt={$typeItem('capacitor')}>
        C
      </button>
      <button class="item" aria-label="component type" use:melt={$typeItem('potentiometer')}>
        P
      </button>
      <button class="item" aria-label="component type" use:melt={$typeItem('switch')}>
        S
      </button>
      <button class="item" aria-label="component type" use:melt={$typeItem('transistor')}>
        T
      </button>
      <button class="item" aria-label="component type" use:melt={$typeItem('opamp')}>
        O
      </button>
      <button class="item" aria-label="component type" use:melt={$typeItem('jack')}>
        J
      </button>
      <button class="item" aria-label="component type" use:melt={$typeItem('valve')}>
        V
      </button>
      <button class="item" aria-label="component type" use:melt={$typeItem('inductor')}>
        I
      </button>
      <button class="item" aria-label="component type" use:melt={$typeItem('wire')}>
        W
      </button>
    </div>
  </div>
</section>
</div>


<style>
	section {
		display: flex;
		flex-direction: column;
	}

</style>
