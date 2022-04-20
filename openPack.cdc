import HatttricksNFT from 0x4ff956c78244911b
import FindPack from 0x4ff956c78244911b
import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20

/// A transaction to open a pack with a given id
/// @param packId: The id of the pack to open
transaction(packId:UInt64) {

	let packs: &FindPack.Collection
	let receiver: Capability<&{NonFungibleToken.Receiver}>

	prepare(account: AuthAccount) {
		self.packs=account.borrow<&FindPack.Collection>(from: FindPack.CollectionStoragePath)!
		self.receiver = account.getCapability<&{NonFungibleToken.Receiver}>(HatttricksNFT.CollectionPublicPath)
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
