task(
    "claim-ad",
    "post a migration ad of data that you would like to put a storage bounty on."
  )
    .addParam("contract", "The address of the MigrationAd contract")
    .addParam("authurl","authurl for google drive oauth2")
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
        
        
        //send a transaction to call createMigrationAd() method
        transaction1 = await two2Three.get_ad(1)
        console.log(transaction1);

        transaction = await two2Three.claim_ad(5,123,taskArgs.authurl)
        transaction.wait()
        console.log(transaction);

        transaction2 = await two2Three.get_dealDetails(775);
        console.log(transaction2)
       
        console.log("Complete!")
    })