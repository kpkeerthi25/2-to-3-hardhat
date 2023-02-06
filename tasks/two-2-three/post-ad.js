const CID = require('cids')

task(
    "post-ad",
    "post a migration ad of data that you would like to put a storage bounty on."
  )
    .addParam("contract", "The address of the MigrationAd contract")
    .addParam("size", "Size of the data you are putting a bounty on")
    .addParam("reward","bounty filcoin placed on the ad")
    .setAction(async (taskArgs) => {
        //store taskargs as useable variables
        const contractAddr = taskArgs.contract
        const size = taskArgs.size
        const networkId = network.name

        //create a new wallet instance
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)
        
        //create a DealRewarder contract factory
        const Two2Three = await ethers.getContractFactory("Two2Three", wallet)
        //create a DealRewarder contract instance 
        //this is what you will call to interact with the deployed contract
        const two2Three = await Two2Three.attach(contractAddr)
        
        
        //send a transaction to call createMigrationAd() method
        transaction = await two2Three.createMigrationAd(size,{value: ethers.utils.parseEther("0.5")})
        transaction.wait()
        
        console.log("Complete!")

        transaction1 = await two2Three.get_dealDetails(775);
        console.log(transaction1)
 
    })