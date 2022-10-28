import AeraPack from 0x46625f59708ec2f8
import NonFungibleToken from 0x631e88ae7f1d7c20

transaction(marketplace:Address, packIds:[UInt64], signatures:[String]) {
    let packs: &AeraPack.Collection{AeraPack.CollectionPublic}

    let userPacks: Capability<&AeraPack.Collection{NonFungibleToken.Receiver}>

    prepare(account: AuthAccount) {

        //We do not init the users storage here since it is important that a user has both a Pack and the collection to receive the content initialized.
        //If we did both here the transaction template would be tied to a specific packed NFT and that is not desireable
        self.userPacks=account.getCapability<&AeraPack.Collection{NonFungibleToken.Receiver}>(AeraPack.CollectionPublicPath)

        // We fetch the packs from chain and check that the pack is still there and fetches the price
        self.packs=AeraPack.getPacksCollection()
    }

    //verify in pre that the price is the same and that the user has a collection
    pre {
        self.userPacks.check() : "User need a receiver to put the pack in for account ".concat(self.userPacks.address.toString())
    }

    execute {
        var a = 0
        while a < packIds.length {
            let packId= packIds[a]
            let signature= signatures[a]
            self.packs.claimFreePackWithReservation(packId:packId, signature: signature, collectionCapability: self.userPacks)
            a = a + 1
        }
    }
}
