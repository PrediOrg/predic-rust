<script>
    import {onMount} from 'svelte';
    import {FontAwesomeIcon} from 'fontawesome-svelte';
    import {Principal} from '@dfinity/principal';
    import {canisters, userBalances, createCanisterActor} from '../store/store';
    import {auth, plugWallet} from '../store/auth';
    // import { idlFactory as akitaIDL } from "../../declarations/AkitaDIP20/AkitaDIP20.did.js";
    // import { idlFactory as goldenIDL } from "../../declarations/GoldenDIP20/GoldenDIP20.did.js";
    import {idlFactory as backendIDL} from "../../declarations/predic/predic.did.js";
    import {idlFactory as ledgerIDL} from "../../declarations/ledger/ledger.did.js";
    import {toHexString, hexToBytes, principalToAccountDefaultIdentifier} from '../utils/helpers'
    import {AuthClient} from '@dfinity/auth-client';
    import {HttpAgent} from '@dfinity/agent/lib/cjs/agent';
    import axios from 'axios';
    import {Null} from '@dfinity/candid/lib/cjs/idl';
    import {messageBox, BeOption, BeSelect, showNotice,} from '@brewer/beerui'
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
    let remaing = 0;
    let symbol = "ICP";
    let ownerNfs = [];
    let ownerNFTArr = [];
    // UI Variables
    let currentToken;
    let withdrawAmount = 0;
    // TODO: Use an input box for this value, too
    let depositAmount = 100000;
    let withdrawAddress = '';

    // Subscribe to plug wallet value should a user authenticate with Plug Wallet
    plugWallet.subscribe(async (value) => {
        if (value.plugActor) {
            const pr = Principal.fromText($canisters[0].canisterId);
            const deposit = await value.plugActor.deposit(pr);
        }
    });

    onMount(async () => {
        // Use II as actor
        if ($auth.loggedIn) {
            console.log("Using II for DEX actor");
            authType = "II";

            // II must display principle, since it is unique.
            iiPrincipal = $auth.principal;
            console.log(iiPrincipal)
            // TODO: When using II, display a note on how to deposit.
            // e.g.
            //
            // To transfer tokens, use the DIP canister to transfer tokens to <iiPrincipal>, and the balance will be reflected here.
            // To transfer ICP, use the ledger to transfer ICP to <depositAddress>, and the balance will be reflected here.
            //
            // This can replace the COPY we have at the bottom, as this is not needed when using Plug

            // Create canister actors

            const authClient = await AuthClient.create();
            const identity = authClient.getIdentity();
            const agent = new HttpAgent({identity, host});
            if (process.env.DFX_NETWORK === 'local')
                agent.fetchRootKey();

            backendActor = createCanisterActor(agent, backendIDL, process.env.PREDIC_CANISTER_ID);
            // akitaActor = createCanisterActor(agent, akitaIDL, process.env.AKITADIP20_CANISTER_ID);
            // goldenActor = createCanisterActor(agent, goldenIDL, process.env.GOLDENDIP20_CANISTER_ID);
            ledgerActor = createCanisterActor(agent, ledgerIDL, process.env.LEDGER_CANISTER_ID);
            console.log(backendActor, ledgerActor)

            // Fetch initial balances
            // const goldenBalance = await goldenActor.balanceOf($auth.principal);
            // const akitaBalance = await akitaActor.balanceOf($auth.principal);

            depositAddressBlob = await backendActor.getDepositAddress();
            getData()

        } else if ($plugWallet.isConnected) {
            // TODO: Support Plug wallet

        }
        const authClient = await AuthClient.create();
        const identity = authClient.getIdentity();
        const agent = new HttpAgent({identity, host});
        if (process.env.DFX_NETWORK === 'local')
            agent.fetchRootKey();
        backendActor = createCanisterActor(agent, backendIDL, process.env.PREDIC_CANISTER_ID);
        ledgerActor = createCanisterActor(agent, ledgerIDL, process.env.LEDGER_CANISTER_ID);
        priceArr = await backendActor.getPrices();
        const remaingArr = await backendActor.getRemaing();
        remaing = remaingArr[0]
        fetchingAddress = false;
    });

    async function getData() {
        priceArr = await backendActor.getPrices();
        const remaingArr = await backendActor.getRemaing();
        remaing = remaingArr[0]

        // symbol = await ledgerActor.symbol();
        const approved = await ledgerActor.account_balance({account: hexToBytes(principalToAccountDefaultIdentifier(iiPrincipal))});
        if (approved.e8s) {
            accountBalance = approved.e8s
        }
        getNftArr()
    }

    async function getNftArr() {
        const ownerNfsRes = await backendActor.ownerNfs(iiPrincipal);
        const tempArr = [];
        if (ownerNfsRes.Ok) {
            ownerNfs = ownerNfsRes.Ok
            for (let i = 0; i < ownerNfs.length; i++) {
                const id = ownerNfs[i]
                try {
                    const level = await backendActor.level(id);
                    tempArr.push({
                        id,
                        level
                    })
                } catch (error) {
                    console.error('Error fetching data:', error);
                }
            }

        }
        ownerNFTArr = tempArr
    }

    async function placeOrder() {

        if ($auth.loggedIn) {
            try {
                if (remaing <= 0) {

                    showNotice({
                        toast: true,
                        message: 'No remaining credit limit!',
                        duration: 3000,
                        type: "warning"
                    });
                    return
                }
                if (accountBalance < choosePrice) {
                    showNotice({
                        toast: true,
                        message: 'Insufficient balance!',
                        duration: 3000,
                        type: "warning"
                    });
                    return
                }
                // if (!choosePrice) {
                //     showNotice({
                //         toast: true,
                //         message: 'Please choose nft price!',
                //         duration: 3000,
                //         type: "error"
                //     });
                // }
                choosePrice = priceArr[0].toString()
                let depositAddressBlob = await backendActor.getDepositAddress();
                btnDisable = true
                const fee = 0;
                const transferResult = await ledgerActor.transfer({
                    memo: BigInt(0x1),
                    amount: {e8s: (parseInt(choosePrice) + fee)},
                    fee: {e8s: 10000},
                    to: depositAddressBlob,
                    from_subaccount: [],
                    created_at_time: [],
                })
                btnDisable = false
                if (transferResult.Ok) {
                    btnDisable = true
                    let chooseIndex = 0
                    if (choosePrice == priceArr[1]) {
                        chooseIndex = 1
                    }
                    if (choosePrice == priceArr[2]) {
                        chooseIndex = 2
                    }
                    setTimeout(async () => {
                        getData()
                    }, 3000)
                    const result = await backendActor.buy(chooseIndex);
                    btnDisable = false
                    if (result.Ok) {
                        showNotice({
                            toast: true,
                            message: 'Mint success!!!',
                            duration: 3000,
                            type: "success"
                        });
                        getData()
                    } else {
                        console.log("transfer failed2",result.Err)
                        messageBox({
                            type: "warning",
                            title: 'Buy Failed',
                            message: Object.keys(result.Err)[0]
                        })
                    }
                } else {
                    console.log("transfer failed1")
                    messageBox({
                        type: "warning",
                        title: 'Buy Failed',
                        message: Object.keys(transferResult.Err)[0]
                    })
                }
            } catch (e) {
                btnDisable = false

                console.log(e)

            }

        } else {
            messageBox({
                toast: true,
                type: "warning",
                message: 'Please login'
            })
        }


    };

    function setBalances(canisterName, canisterBalance, dexBalance) {
        const balanceObj = $userBalances.find((b) => {
            return b.name === canisterName
        })
        if (balanceObj) {
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
        if (window.isSecureContext) {
            didCopyDepositAddress = true;
            navigator.clipboard.writeText(text);
        }
        setTimeout(() => {
            didCopyDepositAddress = false
        }, 1000)
    };

    function copyPrincipal(text) {
        if (window.isSecureContext) {
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
        License NFT
    </div>
    <div class="mint-content">
        <div class="nft-info-box">
            <img class="nft-img" src="images/nft_logo.png" alt="Predic"/>
            <div class="nft-content">
                <div class="nft-name">
                    PPL
                </div>


                <div class="account-balance">
                    <div class="name">NFT remaining</div>
                    <div class="value">
                        {remaing}
                    </div>
                </div>

                <div class="account-balance">
                    <div class="name">Your {symbol} balance</div>
                    <div class="value">
                        {accountBalance.toString() / 1e8}
                    </div>
                </div>
            </div>
        </div>
        <div class="nft-price">
            <div class="flex-box" style="display: flex;justify-content: space-between;align-items: center">
                <div class="name">
                    NFT Price
                </div>
                <div class="price" style="font-size: 23px;">
                    10 ICP
                </div>
            </div>
            <!--            <div class="name" style="margin-bottom: 10px">-->
            <!--                Choose Price {symbolDip721 ? "(" + symbolDip721 + ")" : symbolDip721}-->
            <!--            </div>-->
            <!--                    <select class="input-style" bind:value={choosePrice}>-->
            <!--                        {#each priceArr as price}-->
            <!--                            <option value={price}>-->
            <!--                                {price.toString()/1e8}-->
            <!--                            </option>-->
            <!--                        {/each}-->
            <!--                    </select>-->

            <!--            <BeSelect class="choose-price" placeholder="Choose Price" bind:value={choosePrice} maxHeight='180px'>-->
            <!--                {#each priceArr as price}-->
            <!--                    <BeOption value={price} label={price.toString()/1e8}/>-->
            <!--                {/each}-->
            <!--            </BeSelect>-->

        </div>
        <button class="mint-btn" disabled={btnDisable} on:click={placeOrder}>
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
        {#each ownerNFTArr as nftItem}
            <div class="nft-item">
                <img class="nft-logo" src="images/nft_logo.png" alt="">
                <div class="id-tip">
                    #{nftItem.id}
                </div>
                <div style="display: flex;justify-content: space-between">
                    <div class="nft-id">
                        NFT #{nftItem.id}
                    </div>
                    <div class="nft-id">
                        Level {nftItem.level + 1}
                    </div>
                </div>
            </div>
        {/each}
    </div>
</div>

<style>
    .nfts {
        width: 1200px;
        margin: 50px auto;
    }

    .nfts .title {
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
        font-family: OrelegaOne, serif;
    }

    .my-nfts {
        font-family: OrelegaOne, serif;
        margin-top: 30px;
        display: flex;
        flex-wrap: wrap;
        justify-content: flex-start;
    }

    .my-nfts .nft-item {
        width: calc(20% - 20px);
        margin-left: 20px;
        margin-bottom: 10px;
        padding: 10px;
        box-sizing: border-box;
        background: #191032;
        box-shadow: 0px 2px 3px 0px rgba(41, 72, 152, 0.01), 0px 9px 7px 0px rgba(41, 72, 152, 0.02), 0px 22px 14px 0px rgba(41, 72, 152, 0.03), 0px 42px 28px 0px rgba(41, 72, 152, 0.03), 0px 71px 51px 0px rgba(41, 72, 152, 0.04), 0px 109px 87px 0px rgba(41, 72, 152, 0.05);
        border-radius: 11px 11px 11px 11px;
        font-size: 20px;
        position: relative;
    }
    .id-tip{
        width: 100px;
        text-align: center;
        position: absolute;
        left:calc(50% - 50px);
        top: 22%;
        font-size: 26px;
        font-style: normal;
        font-weight: bold;
        color: #fff;
    }

    .my-nfts .nft-item:nth-child(5n+1) {
        margin-left: 0;
    }

    .my-nfts .nft-logo {
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

    .mint-container .mint-content .nft-info-box {
        display: flex;
    }

    .mint-container .mint-content .nft-info-box .nft-img {
        width: 300px;
        height: 300px;
        border-radius: 20px;
    }

    .mint-container .mint-content .nft-info-box .nft-content {
        padding-left: 20px;
    }

    .nft-name {
        font-size: 30px;
        text-align: left;
        font-style: normal;
        color: #fff;
    }

    .nft-price {
        width: 96%;
        margin-left: 2%;
        margin-top: 30px;
        font-size: 18px;

    }

    .nft-price .name {
        color: #999;
    }

    .choose-price {
        margin-top: 10px;
        background: rgba(255, 255, 255, 0.1) !important;
        border: 1px solid rgba(255, 255, 255, 0.1);
    }

    .account-balance {
        margin-top: 20px;
        font-size: 18px;
    }

    .account-balance .name {
        margin-right: 10px;
        color: #999;
    }

    .account-balance .value {
        margin-top: 10px;
    }

    .nft-price {

    }

    .mint-btn {
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

    .mint-btn:active {
        transform: translate(3px, 3px);
    }

    .mint-btn:after {
        content: "";
        width: 490px;
        height: 29px;
        background: #AD3589;
        border-radius: 0px 0px 0px 0px;
        filter: blur(20px);
        position: absolute;
        top: -10px;
        left: 0;
    }

    .mint-btn span {
        position: relative;
        z-index: 1;
    }

    @media screen and (max-width: 1000px) {
        .mint-container, .mint-content {
            width: 100% !important;
            padding: 20px;
        }

        .nft-content {
            padding: 0 !important;
        }

        .nft-info-box {
            display: block !important;
        }

        .nft-img {
            width: 100% !important;
        }

        .mint-btn {
            width: 100% !important;
        }

        .nft-name {
            display: none;
        }

        .account-balance {
            display: flex;
            justify-content: space-between;
        }

        .my-nfts .nft-item {
            width: calc(50% - 20px);
            margin-left: 20px;
            margin-bottom: 10px;
            padding: 10px;
            box-sizing: border-box;
            background: #191032;
            box-shadow: 0px 2px 3px 0px rgba(41, 72, 152, 0.01), 0px 9px 7px 0px rgba(41, 72, 152, 0.02), 0px 22px 14px 0px rgba(41, 72, 152, 0.03), 0px 42px 28px 0px rgba(41, 72, 152, 0.03), 0px 71px 51px 0px rgba(41, 72, 152, 0.04), 0px 109px 87px 0px rgba(41, 72, 152, 0.05);
            border-radius: 11px 11px 11px 11px;
            font-size: 20px;
        }

        .my-nfts .nft-item:nth-child(2n+1) {
            margin-left: 0;
        }
        .nfts {
            width: 100%!important;
        }
    }

</style>
