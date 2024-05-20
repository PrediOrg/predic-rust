<script>
    import {AuthClient} from "@dfinity/auth-client";
    import {onMount} from "svelte";
    import {
        auth, createActor, plugWallet, whitelist, host,
        PREDIC_CANISTER_ID, LEDGER_CANISTER_ID
    } from "../store/auth";
    // import { idlFactory as akitaIDL } from "../../declarations/AkitaDIP20/AkitaDIP20.did.js";
    // import { idlFactory as goldenIDL } from "../../declarations/GoldenDIP20/GoldenDIP20.did.js";
    import {idlFactory as backendIDL} from "../../declarations/predic/predic.did.js";
    import {idlFactory as ledgerIDL} from "../../declarations/ledger/ledger.did.js";
    import {FontAwesomeIcon} from 'fontawesome-svelte';
    import {showNotice,} from '@brewer/beerui'

    /** @type {AuthClient} */
    let client;
    let didCopyDepositAddress;
    let iiPrincipal;
    // Plug wallet connection request
    onMount(async () => {
        // Internet Identity:q
        client = await AuthClient.create();
        const id = client.getIdentity();
        if (await client.isAuthenticated()) {
            handleAuth();
        }
        if ($auth.loggedIn) {
            iiPrincipal = $auth.principal.toString();

        }
        // TODO: Support Plug wallet
        // if(!await window.ic.plug.isConnected()){
        //     console.log("connect to plug");
        //     await requestPlugConnection();
        //     console.log("finished connect to plug");
        // }
    });

    // TODO: Support Plug wallet
    async function requestPlugConnection() {
        try {
            // Request to connect plug wallet. This request permission from user to interact with backend
            // Local deployment whitelist will not get added correctly since Plug check with canisters deployed on IC
            // https://github.com/Psychedelic/plug/blob/3ce6b32e9d081b90f6b5ebd2926236b8d38ecfd2/source/Background/Controller.js#L180
            console.log(host)
            await window.ic.plug.requestConnect({whitelist: whitelist, host: host});

            if (process.env.DFX_NETWORK === 'local') {

                await window.ic.plug.createAgent({whitelist: whitelist, host: host})
                await window.ic.plug.agent.fetchRootKey();
            }
            const principal = await window.ic.plug.agent.getPrincipal();
            const plugActor = await window.ic.plug.createActor({
                canisterId: PREDIC_CANISTER_ID,
                interfaceFactory: backendIDL
            });
            // const plugAkitaActor = await window.ic.plug.createActor({
            //     canisterId: AKITA_CANISTER_ID,
            //     interfaceFactory: akitaIDL
            // });
            // const plugGoldenActor = await window.ic.plug.createActor({
            //     canisterId: GOLDENDIP20_CANISTER_ID,
            //     interfaceFactory: goldenIDL
            // });
            const plugLedgerActor = await window.ic.plug.createActor({
                canisterId: LEDGER_CANISTER_ID,
                interfaceFactory: ledgerIDL
            });
            plugWallet.set({
                ...$plugWallet,
                principal,
                plugActor,
                plugAkitaActor,
                plugGoldenActor,
                plugLedgerActor,
                isConnected: true
            });
            // console.log("akita name:" , await plugAkitaActor.name());
            // console.log("golden name:" , await plugGoldenActor.name());       
            // console.log("defi balances:" , await plugActor.getBalances());       
        } catch (e) {
            console.log(e);
        }
    };

    function handleAuth() {
        console.log('in handle auth');
        console.log(client.getIdentity())
        // Update Auth Store
        auth.update(() => ({
            loggedIn: true,
            principal: client.getIdentity().getPrincipal(),
            actor: createActor({
                agentOptions: {
                    identity: client.getIdentity(),
                },
            }),
        }));
        iiPrincipal = $auth.principal.toString();
        // Create Canister Actors with II
    }

    function copyDepositAddress(text) {
        if (window.isSecureContext) {
            didCopyDepositAddress = true;
            navigator.clipboard.writeText(text);
            showNotice({
                toast: true,
                message: iiPrincipal + ' Copied!',
                duration: 3000,
                type: "success"
            });

        }
        setTimeout(() => {
            didCopyDepositAddress = false
        }, 1000)
    };

    function login() {
        client.login({
            identityProvider:
                process.env.DFX_NETWORK === "ic"
                    ? "https://identity.ic0.app/#authorize"
                    : `http://${process.env.INTERNET_IDENTITY_CANISTER_ID}.localhost:4943/#authorize`,
            onSuccess: handleAuth,
        });


    }

    async function onBuilding() {
        showNotice({
            toast: true,
            message: 'Coming soon!',
            duration: 300000,
            type: "warning"
        });
    }

    async function logout() {
        await client.logout();
        auth.update(() => ({
            loggedIn: false,
            principal: '',
            actor: createActor(),
        }));
    }
</script>

<div id="nav-container">
    <a
            href="https://www.predi.org"
            rel="noopener noreferrer"
            target="_blank"
            class="logo"
    >

        <img src="images/logo.png" alt="DFINITY logo"/>


    </a>
    <div class="nav-list">
        <div class="nav-item active">
            Product License
        </div>
        <div class="nav-item" on:click={()=>{onBuilding()}}>
            Markets
        </div>
        <div class="nav-item" on:click={()=>{onBuilding()}}>
            Portfolio
        </div>
    </div>
    <div class="btn-box">
        <div>
            {#if $auth.loggedIn}
                <button on:click={copyDepositAddress(iiPrincipal)} style="margin-right: 20px">
                    <span>{iiPrincipal ? (iiPrincipal.substring(0, 3) + "..." + iiPrincipal.substring((iiPrincipal.length - 5), iiPrincipal.length)) : ""}
                        <FontAwesomeIcon icon="copy"/></span>

                </button>
                <button class="logout" on:click={logout}>
                    <span>Log out</span>
                </button>
            {:else}
                <button on:click={login}>
                    <span>
                        Login
                    </span>
                </button>

            {/if}
        </div>
        <!--Due to lack of support for local testing Plug wallet, Plug wallet auth button
        will be commented out. This dapp has the foundation for plug integration within the code-->
        <!--
            <li>
                  {#if !$plugWallet.isConnected}
                      <button class="top-round-rainbow" on:click={requestPlugConnection}>
                          <span>
                              <img class="plug-logo" src="images/plug_logo.png" alt="Plug logo" />
                          </span>
                          Plug
                      </button>
                  {:else}
                      <button class="top-round-rainbow">
                          <span>
                              <img class="plug-logo" src="images/plug_logo.png" alt="Plug logo" />
                          </span>
                          {$plugWallet.principal}
                      </button>
                  {/if}
            </li>
        -->
    </div>
</div>

<style>
    .btn-box {
        display: flex;
        align-items: center;
    }

    .nav-list {
        display: flex;
        flex-grow: 1;
        justify-content: flex-end;
        margin-right: 30px;
    }

    .nav-item {
        font-family: Orelega One, Orelega One;
        font-size: 20px;
        font-weight: bold;
        margin-left: 20px;
        cursor: pointer;
    }

    .nav-item.active {
        color: #ffcf76;
    }

    #nav-container {
        width: 90%;
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin: 20px auto;
    }

    li {
        display: inline-flex;
        padding: 10px
    }

    ul {
        margin-left: auto;
        margin-top: -15px;
        padding: 0;
    }

    img {
        height: 22px;
    }

    .logo {
        display: inline-block;
    }

    .logo img {
        height: 50px;
    }


    button:after {
        content: "";
        width: 100%;
        height: 30px;
        background: #AD3589;
        border-radius: 0px 0px 0px 0px;
        filter: blur(10px);
        position: absolute;
        top: -15px;
        left: 0;
    }
    @media screen and (max-width: 1000px){

        .logo img {
            height: 30px;
        }

        .nav-list{
            display: none;
        }
        .logout{
            display: none;
        }
        #nav-container {
            width: 100%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 20px auto;
        }


    }
</style>
