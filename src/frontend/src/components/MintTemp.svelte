<script>
    import {onMount} from 'svelte';
    import {Principal} from '@dfinity/principal';
    import {orders, currentOrder} from '../store/order';
    import {auth, plugWallet, anonymous} from '../store/auth';
    import {canisters} from '../store/store';
    import {FontAwesomeIcon} from 'fontawesome-svelte';
    import {AuthClient} from '@dfinity/auth-client';
    import {hexToBytes, principalToAccountDefaultIdentifier} from "../utils/helpers";

    let ledgerActor;
    let backendActor;
    let authClient;
    let priceArr = [];
    let depositAddress;
    let balance;
    let showOrderForm = false;
    let addingOrder = false;
    let cancelingOrder = false;
    let buyingOrder = false;
    let choosePrice;
    const newOrder = {
        fromCanister: "",
        fromAmount: 0,
        toCanister: "",
        toAmount: 0
    };

    plugWallet.subscribe((value) => {
        if (value.plugActor) {
            console.log('Plug connected, using plug actor')
            backendActor = value.plugActor;
        }
    })

    auth.subscribe(async (value) => {
        if (value.loggedIn) {
            backendActor = value.actor
            authClient = await AuthClient.create();
        }
    })

    onMount(async () => {
        // Use II as actor
        if ($auth.loggedIn) {
            console.log("In orders, using II");
            backendActor = $auth.actor;
        } else if ($plugWallet.isConnected) {
            console.log("Using Plug for DEX actor");
            backendActor = $plugWallet.plugActor;
            console.log(backendActor)
        } else {
            console.log('Using anonymous actor');
            backendActor = $anonymous.actor;
        }

        priceArr = await backendActor.getPrices();
        depositAddress = await backendActor.getDepositAddress();

        balance = await backendActor.balanceOfDip721(depositAddress);

        console.log({
            depositAddress,balance
        })
    });

    async function placeOrder() {
        addingOrder = true;
        console.log($canisters,backendActor)
        //
        // // (principal, principal, nat64)
        // let depositAddressBlob = await backendActor.getDepositAddress();
        // console.log(depositAddressBlob,Principal)
        //
        // let principal = Principal.fromUint8Array(depositAddressBlob);
        //
        // // let principal = hexToBytes(principalToAccountDefaultIdentifier(depositAddressBlob))
        // const transferResult  = await backendActor.transferFromDip721(principal, choosePrice);
        // console.log(transferResult)
        //
        // if (transferResult.Ok) {
        //     const result  = await backendActor.buy(0);
        //     console.log(result)
        // }
        const result  = await backendActor.buy(0);
        console.log(result)

    };

    async function buyOrder(order) {
        buyingOrder = true;
        // Create an order opposite of the one being bought
        currentOrder.set(order);
        const newOrder = {
            fromCanister: order.to,
            fromAmount: order.toAmount,
            toCanister: order.from,
            toAmount: order.fromAmount
        };
        const result = await backendActor.placeOrder(
            newOrder.fromCanister,
            newOrder.fromAmount,
            newOrder.toCanister,
            newOrder.toAmount
        )
        if (result && result.Ok) {
            // const orderList = await backendActor.getOrders();
            // orders.set([]);
            // orders.set(orderList.reverse());
        }
        currentOrder.set({});
        buyingOrder = false;

        // TODO: Better way to handle balance updates on UI
        // get the balance of the to, get the balance of the from
        window.location.reload();
    };

    function closeOrderForm() {
        showOrderForm = false;
        addingOrder = false;
    };

    async function cancelOrder(id) {
        cancelingOrder = true;
        const order = $orders.find((o) => o.id === id);
        currentOrder.set(order);
        const result = await backendActor.cancelOrder(id);
        if (result && result.Ok) {
            // const orderList = await backendActor.getOrders();
            // orders.set([]);
            // orders.set(orderList.reverse());
        }
        currentOrder.set({});
        cancelingOrder = false;
    };

    async function getTokenSymbol(principal) {
        const item = $canisters.find((canister) => canister.canisterId === principal.toString())
        if (item) {
            return item.symbol;
        }
    };
</script>

<div class="mint-container">
    <div class="title">
        NFT License
    </div>
    <div class="mint-content">
        <div class="nft-info-box">
            <img class="nft-img"/>
            <div class="nft-content">
                <div class="nft-name">
                    Name #1
                </div>
                <div class="nft-price">
                    <select class="input-style" bind:value={choosePrice}>
                        {#each priceArr as price}
                            <option value={price}>
                                {price}
                            </option>
                        {/each}
                    </select>
                </div>
            </div>
        </div>
        <button class="mint-btn" on:click={placeOrder} >
            <span>
                Mint
            </span>
        </button>
    </div>
</div>

<style>
    .mint-container {
        width: 556px;
        margin: 0 auto;
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
