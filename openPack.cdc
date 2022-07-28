import AeraNFT from 0xd35de4da00fb3511
import AeraPack from 0xd35de4da00fb3511
import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20

/// A transaction to open a pack with a given id
/// @param packId: The id of the pack to open
transaction(packId:UInt64) {

    let packs: &AeraPack.Collection
    let receiver: Capability<&{NonFungibleToken.Receiver}>

    prepare(account: AuthAccount) {
        self.packs=account.borrow<&AeraPack.Collection>(from: AeraPack.CollectionStoragePath)!
        self.receiver = account.getCapability<&{NonFungibleToken.Receiver}>(AeraNFT.CollectionPublicPath)
    }

    pre {
        self.receiver.check() : "The receiver collection for the packs is not present"
    }
    execute {
        self.packs.open(packId: packId, receiverCap:self.receiver)
    }

    post {
        !self.packs.getIDs().contains(packId) : "The pack is still present in the users collection"
    }
}
