use std::{
    fs::{self, File},
    process::Command,
};

mod wait_for_blocks;
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
struct MyData {
    hash: String,
    transactionType: String,
    contractName: String,
    contractAddress: String,
    function: Option<String>,
    arguments: Option<String>,
    rpc: String,
    transaction: TransactionData,
    additionalContracts: Vec<String>,
    isFixedGasLimit: bool,
}

#[derive(Debug, Deserialize, Serialize)]
struct TransactionData {
    r#type: String,
    from: String,
    gas: String,
    value: String,
    data: String,
    nonce: String,
    accessList: Vec<String>,
}

fn main() {
    /* Deploy round and everything  using forge script */
    let output = Command::new("forge")
        .arg("script")
        .arg("scripts/Deploy.s.sol")
        .arg("--broadcast")
        .arg("-rpc-url http://localhost:8545")
        .arg("-ffi")
        .arg("--via-ir")
        .output();

    let data = fs::read_to_string("./broadcast/run-latest.json").expect("Unable to read file");

    let json: Vec<MyData> =
        serde_json::from_str(&data).expect("JSON does not have correct format.");

    dbg!(json);

    /* Read round address from latest broadcast, read times from chain */

    /* Apply to Round using script */

    /* Approve/Reject using script */

    /* Vote using script */

    /* Finalize and payout using script */
}
