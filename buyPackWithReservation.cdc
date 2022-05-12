import AeraPack from 0x9b6ec56eec94507b
import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20
import DapperUtilityCoin from 0x82ec283f88a62e65

/// A transaction to buy a pack using a signed message from the backend
/// @param marketplace: The account of the marketplace
/// @param packIds: An array of pack ids to buy
/// @param totalAmount: the total amount to withdraw from the wallet
/// @param signatures: An array of messages signed by the solution AuthAccount to verify that this packId and this message is the same.
/// @param prices: An array of prices for the different packs, since in theory you can buy from different types
transaction(marketplace:Address, packIds:[UInt64], totalAmount: UFix64, signatures:[String], prices:[UFix64]) {
    let packs: &AeraPack.Collection{AeraPack.CollectionPublic}

    let userPacks: Capability<&AeraPack.Collection{NonFungibleToken.Receiver}>
    let salePrice: UFix64

    let mainDapperUtilityCoinVault: &DapperUtilityCoin.Vault
    let balanceBeforeTransfer:UFix64

    prepare(dapper:AuthAccount, account: AuthAccount) {

        //We do not init the users storage here since it is important that a user has both a Pack and the collection to receive the content initialized.
        //If we did both here the transaction template would be tied to a specific packed NFT and that is not desireable
        self.userPacks=account.getCapability<&AeraPack.Collection{NonFungibleToken.Receiver}>(AeraPack.CollectionPublicPath)

        // We fetch the packs from chain and check that the pack is still there and fetches the price
        self.packs=AeraPack.getPacksCollection()

        var salePrice=0.0
        for id in packIds {
            let pack=self.packs.borrowAeraPack(id: id) ?? panic("Pack is not available")
            salePrice= salePrice+pack.getMetadata().price
        }
        self.salePrice=salePrice


        // Get a DUC vault from Dapper's account, code copied from template repo
        self.mainDapperUtilityCoinVault = dapper.borrow<&DapperUtilityCoin.Vault>(from: /storage/dapperUtilityCoinVault) ?? panic("Cannot borrow DapperUtilityCoin vault from account storage")
        self.balanceBeforeTransfer = self.mainDapperUtilityCoinVault.balance

    }

    //verify in pre that the price is the same and that the user has a collection
    pre {
        self.salePrice == totalAmount: "unexpected price"
        self.userPacks.check() : "User need a receiver to put the pack in for account ".concat(self.userPacks.address.toString())
    }

    execute {
        var a = 0
        while a < packIds.length {
            let packId= packIds[a]
            let signature= signatures[a]
            let price= prices[a]
            let paymentVault <- self.mainDapperUtilityCoinVault.withdraw(amount: price)
            self.packs.buyWithSignature(packId:packId, signature: signature, vault: <- paymentVault, collectionCapability: self.userPacks)
            a = a + 1
        }
    }

    // Check that all dapperUtilityCoin was routed back to Dapper
    post {
        self.mainDapperUtilityCoinVault.balance == self.balanceBeforeTransfer: "DapperUtilityCoin leakage"
    }
}
