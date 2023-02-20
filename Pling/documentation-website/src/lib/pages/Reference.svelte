<script>
    import audioDoc from "../../assets/docs/audio.txt";
    import fsDoc from "../../assets/docs/fs.txt";
    import httpDoc from "../../assets/docs/http.txt";
    import internalDoc from "../../assets/docs/internal.txt";
    import ioDoc from "../../assets/docs/io.txt";
    import mathDoc from "../../assets/docs/math.txt";
    import noteDoc from "../../assets/docs/note.txt";
    import osDoc from "../../assets/docs/os.txt";
    import stringDoc from "../../assets/docs/string.txt";
    import timeDoc from "../../assets/docs/time.txt";
    import DocElementWrapper from "../DocElementWrapper.svelte";
    import Footer from "../../Footer.svelte";

    function scrollToElement(id) {
        // scroll to element with id (but offset by 100px)
        const element = document.getElementById(id);
        const offset = 100;
        const bodyRect = document.body.getBoundingClientRect().top;
        const elementRect = element.getBoundingClientRect().top;
        const elementPosition = elementRect - bodyRect;
        const offsetPosition = elementPosition - offset;

        window.scrollTo({
            top: offsetPosition,
            behavior: "smooth"
        });
    }
</script>

<div class="other">
    <div style="height: 100px"></div>
    <article style="width: 100%">
        <fieldset style="width: 100%">
            <legend>Table Of Contents</legend>

            <ul>
                <li>
                    <a on:click={() => scrollToElement("audio")}>Audio API</a>
                </li>
                <li>
                    <a on:click={() => scrollToElement("file")}>File System API</a>
                </li>
                <li>
                    <a on:click={() => scrollToElement("http")}>HTTP API</a>
                </li>
                <li>
                    <a on:click={() => scrollToElement("internal")}>Builtin API</a>
                </li>
                <li>
                    <a on:click={() => scrollToElement("io")}>IO API</a>
                </li>
                <li>
                    <a on:click={() => scrollToElement("math")}>Math API</a>
                </li>
                <li>
                    <a on:click={() => scrollToElement("note")}>Note API</a>
                </li>
                <li>
                    <a on:click={() => scrollToElement("os")}>OS API</a>
                </li>
                <li>
                    <a on:click={() => scrollToElement("string")}>String API</a>
                </li>
                <li>
                    <a on:click={() => scrollToElement("time")}>Time API</a>
                </li>
            </ul>
        </fieldset>

        <DocElementWrapper doc={audioDoc} title="audio"/>
        <DocElementWrapper doc={fsDoc} title="file"/>
        <DocElementWrapper doc={httpDoc} title="http"/>
        <DocElementWrapper doc={internalDoc} title="internal"/>
        <DocElementWrapper doc={ioDoc} title="io"/>
        <DocElementWrapper doc={mathDoc} title="math"/>
        <DocElementWrapper doc={noteDoc} title="note"/>
        <DocElementWrapper doc={osDoc} title="os"/>
        <DocElementWrapper doc={stringDoc} title="string"/>
        <DocElementWrapper doc={timeDoc} nohr={true} title="time"/>
    </article>

    <Footer/>
</div>