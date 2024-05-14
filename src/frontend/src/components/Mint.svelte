<script>
    import { onMount } from 'svelte';
    import { FontAwesomeIcon } from 'fontawesome-svelte';
    import { Principal } from '@dfinity/principal';
    import { canisters, userBalances, createCanisterActor } from '../store/store';
    import { auth, plugWallet } from '../store/auth';
    // import { idlFactory as akitaIDL } from "../../declarations/AkitaDIP20/AkitaDIP20.did.js";
    // import { idlFactory as goldenIDL } from "../../declarations/GoldenDIP20/GoldenDIP20.did.js";
    import { idlFactory as backendIDL} from "../../declarations/predic/predic.did.js";
    import { idlFactory as ledgerIDL} from "../../declarations/ledger/ledger.did.js";
    import { toHexString, hexToBytes, principalToAccountDefaultIdentifier } from '../utils/helpers'
    import { AuthClient } from '@dfinity/auth-client';
    import { HttpAgent } from '@dfinity/agent/lib/cjs/agent';
    import { Null } from '@dfinity/candid/lib/cjs/idl';
    import { messageBox,BeOption,BeSelect,showNotice, } from '@brewer/beerui'
    import {orders} from "../store/order";
    // Global variables
    const host = process.env.DFX_NETWORK === "local"
        ? `http://localhost:4943`
        : "ic0.app";

    let depositAddressBlob;
    let iiPrincipal = '';
    let authType = "anonymous";

    // Actors for corresponding canisters
    // TDOD: Move to a store
    let backendActor;
    let akitaActor;
    let goldenActor;
    let ledgerActor;
    let accountBalance = 0;
    let btnDisable = false;
    // UI Flags
    let withdrawing = false;
    let depositing = false;
    let didCopyDepositAddress = false;
    let didCopyPrincipal = false;
    let withdrawingAmount = false;
    let fetchingAddress = true;

    let choosePrice;
    let priceArr = [];
    let remaing ;
    let ownerNfs = [];
    // UI Variables
    let currentToken;
    let withdrawAmount = 0;
    // TODO: Use an input box for this value, too
    let depositAmount = 100000;
    let withdrawAddress = '';

    // Subscribe to plug wallet value should a user authenticate with Plug Wallet
    plugWallet.subscribe(async (value) => {
        if(value.plugActor) {
            const pr = Principal.fromText($canisters[0].canisterId);
            const deposit = await value.plugActor.deposit(pr);
        }
    });

    onMount(async () => {
        // Use II as actor
        if($auth.loggedIn) {
            console.log("Using II for DEX actor");
            authType = "II";

            // II must display principle, since it is unique.
            iiPrincipal = $auth.principal;

            // TODO: When using II, display a note on how to deposit.
            // e.g.
            //
            // To transfer tokens, use the DIP canister to transfer tokens to <iiPrincipal>, and the balance will be reflected here.
            // To transfer ICP, use the ledger to transfer ICP to <depositAddress>, and the balance will be reflected here.
            //
            // This can replace the COPY we have at the bottom, as this is not needed when using Plug

            // Create canister actors
            console.log(111111111111)

            const authClient = await AuthClient.create();
            const identity = authClient.getIdentity();
            const agent = new HttpAgent({identity, host});
            if(process.env.DFX_NETWORK === 'local')
                agent.fetchRootKey();

            backendActor = createCanisterActor(agent, backendIDL, process.env.PREDIC_CANISTER_ID);
            // akitaActor = createCanisterActor(agent, akitaIDL, process.env.AKITADIP20_CANISTER_ID);
            // goldenActor = createCanisterActor(agent, goldenIDL, process.env.GOLDENDIP20_CANISTER_ID);
            ledgerActor = createCanisterActor(agent, ledgerIDL, process.env.LEDGER_CANISTER_ID);
            console.log(backendActor,ledgerActor)

            // Fetch initial balances
            // const goldenBalance = await goldenActor.balanceOf($auth.principal);
            // const akitaBalance = await akitaActor.balanceOf($auth.principal);
            let ledgerBalance = 0;

            depositAddressBlob = await backendActor.getDepositAddress();
            priceArr = await backendActor.getPrices();
            remaing= await backendActor.getRemaing();
            const ownerNfsRes= await backendActor.ownerNfs(iiPrincipal);
            console.log(ownerNfsRes)
            if(ownerNfsRes.Ok){
                ownerNfs = ownerNfsRes.Ok
            }
            const approved = await ledgerActor.account_balance({account: hexToBytes(principalToAccountDefaultIdentifier(iiPrincipal))});
            if(approved.e8s) {
                accountBalance = approved.e8s
            }
        }
        else if ($plugWallet.isConnected) {
            // TODO: Support Plug wallet
            // console.log("Using Plug for DEX actor");
            // authType = "Plug";
            // const principalId = await window.ic.plug.agent.getPrincipal();


            // // Fetch initial balances
            // const goldenBalance = await $plugWallet.plugGoldenActor.balanceOf(principalId);
            // const akitaBalance = await $plugWallet.plugAkitaActor.balanceOf(principalId);
            // let ledgerBalance = 0;


            // // When using Plug, the balance displayed should be of the Plug principal
            // const balance = await $plugWallet.plugLedgerActor.account_balance({account: XXX});
            // if(balance.e8s) {
            //     ledgerBalance = balance.e8s;
            // }

            // // Create a balances array and set the userBalance store object
            // const balances = []
            // for(let i = 0; i < $canisters.length; i++) {
            //     const principal = Principal.fromText($canisters[i].canisterId);
            //     const dexBalance = await $plugWallet.plugLedgerActor.getBalance(principal);

            //     balances.push({
            //         name: $canisters[i].canisterName,
            //         symbol: $canisters[i].symbol,
            //         canisterBalance: i === 0 ? akitaBalance : i === 1 ? goldenBalance : ledgerBalance,
            //         dexBalance: dexBalance,
            //         principal: principal
            //     })
            // };

            // // Update the store values
            // userBalances.set([...balances]);

            // // Don't forget to set `depositAddressBlob`, which we will use later
            // depositAddressBlob = await $plugWallet.plugLedgerActor.getDepositAddress();
        }

        fetchingAddress = false;
    });
    async function placeOrder() {
        try {

            if(!choosePrice){
                showNotice({
                    toast: true,
                    message: 'Please choose price',
                    duration: 3000,
                    type:"error"
                });
            }
            console.log($canisters,backendActor)
            let depositAddressBlob = await backendActor.getDepositAddress();
            btnDisable=true

            const transferResult  = await ledgerActor.transfer({
                memo: BigInt(0x1),
                amount: { e8s:  (parseInt(choosePrice) + 10000)},
                fee: { e8s: 10000},
                to: depositAddressBlob,
                from_subaccount: [],
                created_at_time: [],
            })
            console.log(transferResult)
            console.log(transferResult.Err)

            btnDisable =false
            if (transferResult.Ok) {
                btnDisable= true
                const result  = await backendActor.buy(0);
                btnDisable= false
                console.log(result)

                if(result.Ok){
                    showNotice({
                        toast: true,
                        message: 'Mint success!!!',
                        duration: 3000,
                        type:"success"
                    });
                }
                const ownerNfsRes= await backendActor.ownerNfs(iiPrincipal);
                if(ownerNfsRes.Ok){
                    ownerNfs = ownerNfsRes.Ok
                }
            }else{
                messageBox({
                    type :"warning",
                    title: 'Buy Failed',
                    message: Object.keys(transferResult.Err)[0]
                })
            }
        }catch (e) {
            btnDisable = false
        }


    };
    async function depositT(principal) {
        // explicitly set these here to prevent
        // withdraw form from showing
        withdrawing = false;
        withdrawAmount = 0;
        currentToken = undefined;
        // END withdraw

        depositing = true;
        currentToken = principal;

        const canister = $canisters.find((canister) => {
            return canister.canisterId === principal.toString();
        })
        if(canister && canister.canisterName === 'ICP') {
            if (authType === "Plug") {
                // TODO: Support Plug wallet
                // await ledgerActor.transfer(...)
            }
            // transfer ICP correct subaccount on DEX
            await ledgerActor.transfer({
                memo: BigInt(0x1),
                amount: { e8s: depositAmount },
                fee: { e8s: 10000},
                to: depositAddressBlob,
                from_subaccount: [],
                created_at_time: [],
            });

            const result = await backendActor.deposit(principal);
            if(result.Ok) {
                const dexBalance = await backendActor.getBalance(principal);

                let ledgerBalance = 0;
                let response;
                if(authType === "II") {
                    // Update user ICP balance
                    response = await ledgerActor.account_balance({account: hexToBytes(principalToAccountDefaultIdentifier($auth.principal))});
                } else if (authType === "Plug") {
                    // TODO: Support Plug wallett
                    // response = await ledgerActor.account_balance({account: XXX});
                }
                if(response.e8s) {
                    ledgerBalance = response.e8s
                }
                setBalances(canister.canisterName, ledgerBalance, dexBalance);
            }
        }
        // else if(canister && canister.canisterName === 'AkitaDIP20') {
        //     await akitaActor.approve(Principal.fromText(process.env.PREDIC_CANISTER_ID), depositAmount);

        //     const result = await backendActor.deposit(principal);
        //     if(result.Ok) {
        //         const dexBalance = await backendActor.getBalance(principal);
        //         const akitaBalance = await akitaActor.balanceOf($auth.principal);

        //         setBalances(canister.canisterName, akitaBalance, dexBalance);
        //     }
        // }
        // else if(canister && canister.canisterName === 'GoldenDIP20') {
        //     await goldenActor.approve(Principal.fromText(process.env.PREDIC_CANISTER_ID), depositAmount);

        //     const result = await backendActor.deposit(principal);
        //     if(result.Ok) {
        //         const dexBalance = await backendActor.getBalance(principal);
        //         const goldenBalance = await goldenActor.balanceOf($auth.principal);

        //         setBalances(canister.canisterName, goldenBalance, dexBalance);
        //     }
        // }

        depositing = false;
        currentToken = undefined;
    }

    async function withdrawT(principal) {
        withdrawingAmount = true;
        currentToken = principal;
        const withdrawPrincipal = Principal.fromText(withdrawAddress);

        const canister = $canisters.find((canister) => {
            return canister.canisterId === principal.toString();
        })
        if(canister && canister.canisterName === 'ICP') {
            const result = await backendActor.withdraw(currentToken, withdrawAmount, withdrawPrincipal)
            if(result.Ok) {
                const dexBalance = await backendActor.getBalance(principal);
                let ledgerBalance = 0;
                let response;
                if(authType === "II") {
                    // When using II, display the balance in the target account
                    response = await ledgerActor.account_balance({account: hexToBytes(principalToAccountDefaultIdentifier($auth.principal))});
                } else if (authType === "Plug") {
                    // TODO: Support Plug wallet
                    // response = await ledgerActor.account_balance({account: XXX});
                }
                if(response.e8s) {
                    ledgerBalance = response.e8s
                }
                setBalances(canister.canisterName, ledgerBalance, dexBalance);
            }
        }
        else if(canister && canister.canisterName === 'AkitaDIP20') {
            const result = await backendActor.withdraw(currentToken, withdrawAmount, withdrawPrincipal)
            if(result.Ok) {
                const dexBalance = await backendActor.getBalance(principal);
                const akitaBalance = await akitaActor.balanceOf($auth.principal);

                setBalances(canister.canisterName, akitaBalance, dexBalance);
            }
        }
        else if(canister && canister.canisterName === 'GoldenDIP20') {
            const result = await backendActor.withdraw(currentToken, withdrawAmount, withdrawPrincipal)
            if(result.Ok) {
                const dexBalance = await backendActor.getBalance(principal);
                const goldenBalance = await goldenActor.balanceOf($auth.principal);

                setBalances(canister.canisterName, goldenBalance, dexBalance);
            }
        }

        withdrawAmount = 0;
        withdrawAddress = '';
        currentToken = undefined;
        withdrawingAmount = false;
    };

    function setBalances(canisterName, canisterBalance, dexBalance) {
        const balanceObj = $userBalances.find((b) => {
            return b.name === canisterName
        })
        if(balanceObj) {
            balanceObj.canisterBalance = canisterBalance;
            balanceObj.dexBalance = dexBalance;
        }
        userBalances.set([...$userBalances]);
    }

    function beginWithdrawProcess(token) {
        currentToken = token;
        withdrawing = true;
    }

    function cancelWithdrawProcess(e) {
        e.stopPropagation();
        withdrawing = false;
        withdrawAmount = 0;
        withdrawAddress = '';
        currentToken = undefined;
    }

    function copyDepositAddress(text) {
        if(window.isSecureContext) {
            didCopyDepositAddress = true;
            navigator.clipboard.writeText(text);
        }
        setTimeout(() => {
            didCopyDepositAddress = false
        }, 1000)
    };

    function copyPrincipal(text) {
        if(window.isSecureContext) {
            didCopyPrincipal = true;
            navigator.clipboard.writeText(text);
        }
        setTimeout(() => {
            didCopyPrincipal = false
        }, 1000)
    };
</script>

<div class="mint-container">
    <div class="title">
        NFT License
    </div>
    <div class="mint-content" >
        <div class="nft-info-box">
            <img class="nft-img" src="images/nft_logo.png"/>
            <div class="nft-content">
                <div class="nft-name">
                    Name #1
                </div>

                <div class="account-balance">
                    <div class="name">Balance </div>
                    {accountBalance.toString()/1000000}
                </div>
                <div class="account-balance">
                    <div class="name">Remaing </div>
                    {remaing}
                </div>
            </div>
        </div>
        <div class="nft-price">
            Choose Price
            <!--                    <select class="input-style" bind:value={choosePrice}>-->
            <!--                        {#each priceArr as price}-->
            <!--                            <option value={price}>-->
            <!--                                {price.toString()/1000000}-->
            <!--                            </option>-->
            <!--                        {/each}-->
            <!--                    </select>-->
            <BeSelect class="choose-price" placeholder="Choose Price" bind:value={choosePrice} maxHeight='180px'>
                {#each priceArr as price}
                    <BeOption value={price} label={price.toString()/1000000} />
                {/each}
            </BeSelect>
        </div>
        <button class="mint-btn" disabled={btnDisable} on:click={placeOrder} >
            {#if btnDisable}
                 <span>
                    Loading
                 </span>
            {:else}
                 <span>
                    Mint
                </span>
            {/if}
        </button>
    </div>

</div>
<div class="nfts">
    <div class="title">
        My NFT
    </div>
    <div class="my-nfts">
        {#each ownerNfs as nftItem}
            <div class="nft-item">
                <img class="nft-logo" src="images/nft_logo.png" alt="">
                <div class="nft-id">
                    # {nftItem}
                </div>
            </div>
        {/each}
    </div>
</div>

<style>
    .nfts{
        width: 1200px;
        margin: 50px auto;
    }
    .nfts .title{
        font-family: Roboto, Roboto;
        font-weight: bold;
        font-size: 30px;
        margin-top: 10vh;
        color: #FFFFFF;
        line-height: 35px;
        text-align: left;
    }
    .mint-container {
        width: 556px;
        margin: 0 auto;
    }
    .my-nfts{
        margin-top: 30px;
        display: flex;
        flex-wrap: wrap;
        justify-content: space-between;
    }
    .my-nfts .nft-item{
        width: calc(20% - 20px);
        margin-bottom: 10px;
        padding: 10px;
        box-sizing: border-box;
        background: #191032;
        box-shadow: 0px 2px 3px 0px rgba(41,72,152,0.01), 0px 9px 7px 0px rgba(41,72,152,0.02), 0px 22px 14px 0px rgba(41,72,152,0.03), 0px 42px 28px 0px rgba(41,72,152,0.03), 0px 71px 51px 0px rgba(41,72,152,0.04), 0px 109px 87px 0px rgba(41,72,152,0.05);
        border-radius: 11px 11px 11px 11px;
        font-size: 20px;
    }
    .my-nfts .nft-logo{
        margin-bottom: 20px;
        width: 100%;
    }

    .mint-container .mint-content {
        width: 556px;
        background: #191032;
        box-shadow: 0px 2px 3px 0px rgba(41, 72, 152, 0.01), 0px 9px 7px 0px rgba(41, 72, 152, 0.02), 0px 22px 14px 0px rgba(41, 72, 152, 0.03), 0px 42px 28px 0px rgba(41, 72, 152, 0.03), 0px 71px 51px 0px rgba(41, 72, 152, 0.04), 0px 109px 87px 0px rgba(41, 72, 152, 0.05);
        border-radius: 11px 11px 11px 11px;
        padding: 20px;
        margin-top: 28px;
    }

    .mint-container .title {
        font-family: Roboto, Roboto;
        font-weight: bold;
        font-size: 30px;
        margin-top: 10vh;
        color: #FFFFFF;
        line-height: 35px;
        text-align: left;
    }
    .mint-container .mint-content .nft-info-box{
        display: flex;
    }
    .mint-container .mint-content .nft-info-box .nft-img{
        width: 300px;
        height: 300px;
        border-radius: 20px;
    }
    .mint-container .mint-content .nft-info-box .nft-content{
        padding-left: 20px;
    }
    .nft-name{
        font-size: 30px;
        color: #FFFFFF;
        text-align: left;
        font-style: normal;
    }
    .nft-price{
        width: 96%;
        margin-left: 2%;
        margin-top: 20px;

    }

    .choose-price{
        margin-top: 10px;
        background: rgba(255,255,255,0.1) !important;
        border: 1px solid rgba(255,255,255,0.1);
    }
    .account-balance{
        display: flex;
        margin-top: 20px;
    }
    .account-balance .name{
        margin-right: 10px;
    }
    .mint-btn{
        width: 96%;
        margin-left: 2%;
        height: 50px;
        border-radius: 10px 10px 10px 10px;
        text-align: center;
        font-weight: 500;
        font-size: 18px;
        color: #F6F7FC;
        position: relative;
        overflow: hidden;
        cursor: pointer;
        margin-top: 30px;
        margin-bottom: 20px;
    }
    .mint-btn:active{
        transform: translate(3px, 3px);
    }
    .mint-btn:after{
        content:"";
        width: 490px;
        height: 29px;
        background: #AD3589;
        border-radius: 0px 0px 0px 0px;
        filter: blur(20px);
        position: absolute;
        top: -10px;
        left: 0;
    }
    .mint-btn span{
        position: relative;
        z-index: 1;
    }
</style>
