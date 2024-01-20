use ethers::{
    contract::abigen,
    middleware::SignerMiddleware,
    providers::{Http, Provider},
    signers::{LocalWallet, Signer},
    types::{H160, U256},
    utils::parse_units,
};
use serde::Deserialize;
use std::{sync::Arc, time::Duration};
use tokio::time;

#[allow(non_snake_case)]
#[derive(Deserialize, Debug)]
struct LatestPrices {
    BTC: f64,
    EUR: f64,
    USD: f64,
}

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    dotenv::dotenv().ok();
    let mut interval = time::interval(Duration::from_secs(5));

    loop {
        interval.tick().await;
        let latest_prices = get_latest_prices().await?;
        update_oracle(latest_prices).await?;
    }
}

async fn get_latest_prices() -> Result<LatestPrices, reqwest::Error> {
    let response =
        reqwest::get("https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=BTC,USD,EUR")
            .await?
            .json::<LatestPrices>()
            .await?;

    println!("Resposta da API: {:?}", response);
    Ok(response)
}

async fn update_oracle(latest_prices: LatestPrices) -> Result<(), anyhow::Error> {
    abigen!(
        Oracle,
        "./abis/Oracle.json",
        event_derives(serde::Deserialize, serde::Serialize)
    );

    let contract_addr: H160 = std::env::var("CONTRACT_ADDR").unwrap().parse()?;
    let provider_rpc = std::env::var("PROVIDER_RPC").unwrap();

    let provider = Provider::<Http>::try_from(provider_rpc.as_str())?;
    let chain_id: u64 = std::env::var("CHAIN_ID").unwrap().parse()?;

    let wallet: LocalWallet = std::env::var("PRIVATE_KEY")
        .unwrap()
        .parse::<LocalWallet>()?
        .with_chain_id(chain_id);

    let client = SignerMiddleware::new(provider.clone(), wallet.clone());
    let contract = Oracle::new(contract_addr, Arc::new(client.clone()));

    if let Ok(updated_prices) = contract
        .update_prices(
            U256::from(parse_units(format!("{}", latest_prices.USD), 2)?),
            U256::from(parse_units(format!("{}", latest_prices.EUR), 2)?),
            U256::from(parse_units(format!("{}", latest_prices.BTC), 2)?),
        )
        .send()
        .await
    {
        println!("\nTransaction sent: {:?}", updated_prices);

        // Wait for the transaction to be mined, then print the receipt

        let receipt = updated_prices.await?;
        println!("\nUpdated prices: {:?}\n", receipt);

        println!(
            "Updated USD price: {:?}",
            contract.eth_usd_price().call().await
        );
        println!(
            "Updated EUR price: {:?}",
            contract.eth_eur_price().call().await
        );
        println!(
            "Updated BTC price: {:?}",
            contract.eth_btc_price().call().await
        );
    } else {
        println!("Failed to update prices");
    }

    Ok(())
}
