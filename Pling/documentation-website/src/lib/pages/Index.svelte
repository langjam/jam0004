<script>
    import IndexBackgroundArt from "../IndexBackgroundArt.svelte";
    import {onMount} from "svelte";
    import MouseIndicator from "../MouseIndicator.svelte";
    import AboutSection from "../AboutSection.svelte";
    import Footer from "../../Footer.svelte";

    const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    function changeWord(word) {
        let iterations = 0;
        let interval = setInterval(() => {
            word.innerText = word.innerText.split("").map((l, i) => {
                if (i < iterations) {
                    return word.dataset.value[i];
                }
                return letters[Math.floor(Math.random() * letters.length)];
            }).join("");
            iterations += 1 / 3;
            if (iterations > word.dataset.value.length) {
                clearInterval(interval);
                word.innerText = word.dataset.value;
            }
        }, 50);
    }

    let prevElem = -1;
    let imagineElem = null;
    let codeElem = null;
    let listenElem = null;

    onMount(() => {
        let elems = [imagineElem, codeElem, listenElem]

        let interval = setInterval(() => {
            if (prevElem !== -1) {
                elems[prevElem].classList.remove("primary");
            }

            prevElem += 1;
            if (prevElem >= elems.length) {
                prevElem = 0;
            }
            let elem = elems[prevElem];

            elem.classList.add("primary");

            changeWord(elem);
            console.log(elem)
        }, 3000);

        return () => {
            clearInterval(interval);
        }
    });
</script>

<IndexBackgroundArt/>

<div class="splash">
    <div class="splash__content">
        <h1
                bind:this={imagineElem}
                class="splash__title"
                data-value="Imagine"
        >Imagine</h1>
        <h1
                bind:this={codeElem}
                class="splash__title"
                data-value="Code"
        >Code</h1>
        <h1
                bind:this={listenElem}
                class="splash__title"
                data-value="Listen"
        >Listen</h1>
    </div>
    <MouseIndicator/>
</div>

<div class="other">
    <AboutSection/>
    <Footer/>
</div>

<style>
  .splash {
    position: relative;
    height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .splash__content {
    position: relative;
    z-index: 1;
    max-width: 600px;
    padding: 0 20px;
    text-align: center;
  }

  .splash__title {
    font-family: 'Space Mono', monospace;
    font-size: 3.5rem;
    font-weight: 700;
    margin: 0;
    color: var(--secondary);
    text-shadow: 0 0 20px var(--background);

    transition: color 0.3s ease;
  }

  @media (max-width: 600px) {
    .splash__title {
      font-size: 2.5rem;
    }
  }

  .other {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-direction: column;
    background: var(--background2);

    padding: 3em;
  }

  .other > * {
    max-width: 800px;
    margin: 0 auto;
  }
</style>