import NotFound from "./lib/pages/NotFound.svelte";
import Index from "./lib/pages/Index.svelte";
import Intro from "./lib/pages/Intro.svelte";

export default {
    '/': Index,
    '/intro': Intro,
    '*': NotFound,
}