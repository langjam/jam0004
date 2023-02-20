<script>
    import plingIcon from './../assets/pling.svg';
</script>

<nav>
    <ul>
        <li><img alt="icon" src={plingIcon}></li>
        <li><h3>Pling!</h3></li>
    </ul>
    <ul>
        <li><a href="#/">Home</a></li>
        <li><a href="#/intro">Introduction</a></li>
        <li><a href="#/reference">Reference</a></li>
        <li><a href="#/ide">IDE Support</a></li>
    </ul>
</nav>

<style>
  nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.5rem;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    background-color: var(--surface);

    z-index: 4;
  }

  nav ul {
    display: flex;
    list-style: none;
  }

  nav ul li {
    margin: 0 1rem;
  }

  nav ul li img {
    width: 2rem;
  }

  nav ul li h3 {
    margin: 0;
  }

  nav ul li a {
    text-decoration: none;
    color: var(--text);
    transition: color 0.2s ease-in-out;
  }

  nav ul li a:hover {
    color: var(--primary);
  }
</style>

