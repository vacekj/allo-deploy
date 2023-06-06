use std::{
    fs::{self, File},
    process::Command,
};

mod wait_for_blocks;

use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
struct Report {
    transactions: Vec<Transaction>,
}

#[derive(Debug, Deserialize, Serialize)]
struct Transaction {
    hash: String,
    transactionType: String,
    contractName: String,
    contractAddress: String,
    function: Option<String>,
    arguments: Option<Vec<String>>,
    rpc: String,
    transaction: TransactionData,
    isFixedGasLimit: bool,
    additionalContracts: Vec<AdditionalContracts>,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AdditionalContracts {
    pub transaction_type: String,
    pub address: String,
    pub init_code: String,
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
    Command::new("forge")
        .arg("script")
        .arg("scripts/Deploy.s.sol")
        .arg("--broadcast")
        .arg("-rpc-url")
        .arg("http://localhost:8545")
        .arg("-ffi")
        .arg("--via-ir")
        .output()
        .expect("Failed deploy script");

    /* Read round address from latest broadcast, read times from chain */
    let data = fs::read_to_string("broadcast/Deploy.s.sol/31337/run-latest.json")
        .expect("Unable to read file");

    let json: Report = serde_json::from_str(&data).expect("JSON does not have correct format.");

    let round_tx = json
        .transactions
        .iter()
        .find(|tx| !tx.additionalContracts.is_empty())
        .expect("Didn't find addio");
    let round_address = &round_tx.additionalContracts[0].address;

    /* Pass round address to script */
    std::env::set_var("ROUND_ADDRESS", round_address);

    /* Apply to Round using script */
    Command::new("forge")
        .arg("script")
        .arg("scripts/Apply.s.sol")
        .arg("--broadcast")
        .arg("-rpc-url")
        .arg("http://localhost:8545")
        .arg("-ffi")
        .arg("--via-ir")
        .output()
        .expect("Failed apply script");

    /* Approve/Reject using script */

    /* Vote using script */

    /* Finalize and payout using script */
}
