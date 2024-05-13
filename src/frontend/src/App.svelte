<script>
  import Nav from './components/Nav.svelte';
  import Orders from './components/Orders.svelte';
  import { library } from '@fortawesome/fontawesome-svg-core';
  import { faMinus, faPlus, faCheck, faTimes, faCopy, faArrowRight, faArrowLeft } from '@fortawesome/free-solid-svg-icons';
  import { auth, plugWallet } from './store/auth';
  import BalanceInfo from './components/BalanceInfo.svelte';
  import Mint from './components/Mint.svelte';

 // Add fontawesome icons
   const icons = [faMinus, faPlus, faCheck, faTimes, faCopy, faArrowRight, faArrowLeft];
   library.add(icons);
</script>

<main>
  <Nav />

  <div class="main-container">
    {#if $auth.loggedIn || $plugWallet.isConnected}
     <BalanceInfo />
    {/if}

      <Mint/>
  </div>
  <div class="footer">
    <img src="images/logo.png" alt="DFINITY logo" />
    <div class="right">
      Crato liquidity protocol.co
    </div>
  </div>
</main>

<style>


  .main-container {
    align-items: left;
  }

  main {
    text-align: left;
    padding: 1em;
  }

  h1 {
    text-transform: uppercase;
    font-size: 3em;
    font-weight: 400;
    line-height: 1.09;
  }

  .footer {
    width: 1000px;
    padding: 20px;
    display: flex;
    margin:  0 auto;
    justify-content: space-between;
  }
  .footer img{
    height: 50px;
  }
  .footer .right{
    width: 277px;
    height: 28px;
    font-family: Roboto, Roboto;
    font-weight: 500;
    font-size: 24px;
    color: #999999;
  }

  .ic-badge-link {
    cursor: pointer;
  }

  @media (max-width: 640px) {
    main {
      max-width: 800px;
      margin: 0 auto;
    }
    h1 {
      font-size: 2em;
    }
  }
</style>
