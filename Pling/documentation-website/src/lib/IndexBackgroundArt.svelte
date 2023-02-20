<script lang="ts">
    import {onDestroy, onMount} from "svelte";

    let blob: HTMLDivElement

    function mouseMove(e) {
        const x = e.clientX - 125;
        let y = e.clientY - 125 + window.scrollY;

        // Stop going off the bottom of the screen
        if (y > window.innerHeight - 250) {
            y = window.innerHeight
        }

        blob.animate({
            left: x + 'px',
            top: y + 'px'
        }, {
            duration: 3000,
            fill: 'forwards'
        })
    }

    onMount(() => {
        document.addEventListener('mousemove', mouseMove)
    })

    onDestroy(() => {
        document.removeEventListener('mousemove', mouseMove)
    })

</script>

<div
        bind:this={blob}
        id="blob"
></div>

<div class="blur"></div>

<style>
  #blob {
    width: 250px;
    height: 250px;
    background: linear-gradient(45deg, var(--secondary) 0%, var(--primary) 100%);
    position: absolute;

    border-radius: 50%;
    animation: rotate 20s linear infinite;

    top: 50%;
    left: 50%;
  }

  @keyframes rotate {
    0% {
      rotate: 0deg;
    }

    50% {
      scale: 1 1.6;
    }

    100% {
      rotate: 360deg;
    }
  }

  .blur {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    backdrop-filter: blur(100px);
  }
</style>