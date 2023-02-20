<script>
    import DocElement from "./DocElement.svelte";

    export let title;
    export let doc;
    export let nohr = false;
</script>

<div class="doc" id={title}>
    {#await fetch(doc).then((response) => response.text())}
    <div class="loading">Loading...</div>
    {:then response}
        <DocElement doc={response} />
    {:catch error}
        <div class="error">{error.message}</div>
    {/await}
</div>

{#if !nohr}
    <hr />
{/if}