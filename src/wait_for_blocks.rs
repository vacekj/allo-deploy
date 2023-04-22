use ethers::prelude::*;
use ethers::providers::{Http, Provider};
use ethers::abi::AbiEncode;
use std::env;
use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();
    let wait_for_blocks: u64 = args[1].parse::<u64>().unwrap();
    let block_time = 1;

    let url = "http://localhost:8545";
    let provider = Provider::<Http>::try_from(url)?;
    let mut latest_block = provider.get_block_number().await?;
    while latest_block.as_u64() <= wait_for_blocks {
        latest_block = provider.get_block_number().await?;
        sleep(Duration::from_secs(block_time)).await;
    }
    print!("{}", latest_block.as_u64().encode_hex());
    Ok(())
}
