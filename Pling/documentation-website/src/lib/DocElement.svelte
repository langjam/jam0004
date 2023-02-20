<script lang="ts">
    import {parseDoc} from "../docParser.js";

    export let doc: String

    let parsedDoc
    $: parsedDoc = parseDoc(doc)

    function capitalizeFirstLetter(string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
    }
</script>

<!-- preamble -->
<h1>{ capitalizeFirstLetter(parsedDoc.name) }</h1>
<p>{ parsedDoc.description }</p>
<em>Include with <code>use {parsedDoc.name};</code></em>

<br>
<br>

<!-- Function -->
{#each parsedDoc.functions as fn}
    <h3>{ fn.name }</h3>
    Usage: <code>{ fn.usage }</code>
    <p>{ fn.description }</p>
    <br />
{/each}

<!-- Variable -->
<ul>
    {#each parsedDoc.variables as variable}
        <li><code>{ variable.name }</code> = { variable.value }</li>
    {/each}
</ul>
