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
    import DocElement from "../DocElement.svelte";
</script>

<div class="other">
    <div style="height: 100px"></div>
    <article style="width: 100%">
        <fieldset style="width: 100%">
            <legend>Table Of Contents</legend>

            <ul>
                <li>
                    <a href="#">
                        <b>Standard built-in modules</b>
                    </a>
                    <ul>
                        <li>
                            <a>Audio API</a>
                        </li>
                        <li>
                            <a>File System API</a>
                        </li>
                        <li>
                            <a>HTTP API</a>
                        </li>
                        <li>
                            <a>Internal API</a>
                        </li>
                        <li>
                            <a>IO API</a>
                        </li>
                        <li>
                            <a>Math API</a>
                        </li>
                        <li>
                            <a>Note API</a>
                        </li>
                        <li>
                            <a>OS API</a>
                        </li>
                        <li>
                            <a>String API</a>
                        </li>
                        <li>
                            <a>Time API</a>
                        </li>
                    </ul>
            </ul>
        </fieldset>

        <DocElement title="Audio API" doc={audioDoc} />
        <DocElement title="File System API" doc={fsDoc} />
        <DocElement title="HTTP API" doc={httpDoc} />
        <DocElement title="Internal API" doc={internalDoc} />
        <DocElement title="IO API" doc={ioDoc} />
        <DocElement title="Math API" doc={mathDoc} />
        <DocElement title="Note API" doc={noteDoc} />
        <DocElement title="OS API" doc={osDoc} />
        <DocElement title="String API" doc={stringDoc} />
        <DocElement title="Time API" doc={timeDoc} />
    </article>
</div>