import NotFound from "./lib/pages/NotFound.svelte";
import Index from "./lib/pages/Index.svelte";
import Reference from "./lib/pages/Reference.svelte";
import Intro from "./lib/pages/Intro.svelte";
import IDE from "./lib/pages/IDE.svelte";

export default {
    '/': Index,
    '/reference': Reference,
    '/intro': Intro,
    '/ide': IDE,
    '*': NotFound,
}