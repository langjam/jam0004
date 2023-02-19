import NotFound from "./lib/pages/NotFound.svelte";
import Index from "./lib/pages/Index.svelte";
import Wild from "./lib/pages/Wild.svelte";

export default {
    '/': Index,
    '/wild': Wild,
    '*': NotFound,
}