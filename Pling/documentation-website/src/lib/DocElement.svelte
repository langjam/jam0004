<script>
    export let title;
    export let doc;
</script>

<h1>{title}</h1>
<div class="doc" id={title}>
    {#await fetch(doc).then((response) => response.text())}
    <div class="loading">Loading...</div>
    {:then response}
        <p>
            {response.split('\n')[1]}
        </p>

        <div class="content">
            {#each response.split('\n').slice(2) as line}
                {#if line.startsWith('#')}
                    <h3>{line.slice(1)}</h3>
                {:else}
                    <p>{line}</p>
                {/if}
            {/each}
        </div>
    {:catch error}
        <div class="error">{error.message}</div>
    {/await}
</div>