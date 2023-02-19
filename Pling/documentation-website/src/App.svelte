<script lang="ts">
    import Router from 'svelte-spa-router';
    import routes from "./routes";
    import Nav from "./lib/Nav.svelte";
</script>

<Nav />
<Router {routes} />
