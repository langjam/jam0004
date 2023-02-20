<script>
    import Footer from "../../Footer.svelte";
    import idea1 from "../../assets/idea_1.png";
    import idea2 from "../../assets/idea_2.png";
</script>

<div class="other">
    <div style="height: 100px"></div>

    <article>
        <h1>IDE Support</h1>

        <p>
            Pling is usable with any IDE or Text Editor. However, we recommend using IntelliJ IDEA with the Pling plugin.
            This plugin provides syntax highlighting and other features to make your life easier.
        </p>

        <p>
            You can download the plugin from <a href="https://github.com/Sync-Private/jam0004/releases/download/1.0.0/pling-idea.jar">here</a>.
            After downloading, open IntelliJ IDEA and go to <code>File > Settings > Plugins</code>. Click the <code>Install Plugin from Disk</code> button and select the downloaded file.
        </p>

        <img src={idea1} alt="IntelliJ IDEA Plugin" style="width: 100%; max-width: 600px; margin: 0 auto; display: block;"/><br />
        <img src={idea2} alt="IntelliJ IDEA Plugin" style="width: 100%; max-width: 600px; margin: 0 auto; display: block;"/>

        <p>
            After installing the plugin, you can create a new Pling file by using the right-click menu.
            You can also use the <code>.pling</code> file extension to open a Pling file.
            Also, you should be able to see the syntax highlighting in the editor.
        </p>
    </article>
    <Footer/>
</div>

