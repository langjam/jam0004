<script lang="ts">
    import {MouseSimple} from "phosphor-svelte";
</script>

<div class="container">
    <MouseSimple size={60} weight="duotone"/>
    <div class="indicator"></div>
</div>

<style>
  .container {
    position: absolute;
    bottom: 0;
    left: 50%;
    transform: translate(-50%, -50%);
  }

  .indicator {
    height: 30px;
    width: 2px;
    margin: auto;
    animation: 2.5s mouse-down-anim infinite linear;
    background: linear-gradient(180deg, transparent, transparent, transparent, transparent, transparent, transparent, transparent, transparent, transparent, transparent, var(--text), transparent, transparent);
    background-size: 100% 1300%;
    border-radius: 2px
  }

  @keyframes mouse-down-anim {
    0% {
      background-position: 0 100%
    }
    100% {
      background-position: 0 0
    }
  }
</style>
