task(
    "get-myad",
    "post a migration ad of data that you would like to put a storage bounty on."
  )
    .addParam("contract", "The address of the MigrationAd contract")
    .setAction(async (taskArgs) => {
        //store taskargs as useable variables
        const contractAddr = taskArgs.contract
 

        //create a new wallet instance
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)
        
        //create a DealRewarder contract factory
        const Two2Three = await ethers.getContractFactory("Two2Three", wallet)
        //create a DealRewarder contract instance 
        //this is what you will call to interact with the deployed contract
        const two2Three = await Two2Three.attach(contractAddr)
        
        transaction = await two2Three.get_myAds()
        console.log(transaction);

        console.log("Complete!")
    })