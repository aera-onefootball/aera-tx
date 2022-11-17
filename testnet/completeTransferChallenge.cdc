import AeraNFT from 0x46625f59708ec2f8
import FLOAT from 0x0afe396ebc8eee65
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20
import GrantedAccountAccess from 0x0afe396ebc8eee65

transaction(ids: [UInt64], eventId: UInt64, eventHost: Address) {
	let userAddress: Address;
	let aeraCollection: &AeraNFT.Collection

	let floatEventsHostCollection: &FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}
	let floatEventPublic: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}
	let userFloatCollection: &FLOAT.Collection

	prepare(account: AuthAccount) {
		self.userAddress = account.address

		self.aeraCollection = account.borrow<&AeraNFT.Collection>(from: AeraNFT.CollectionStoragePath) 
		?? panic("Could not borrow the users AeraNFT Collection.")
		
		self.floatEventsHostCollection = getAccount(eventHost).getCapability<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>(FLOAT.FLOATEventsPublicPath).borrow() 
		?? panic("Could not borrow FLOATEvents from the event host.")

		self.floatEventPublic = self.floatEventsHostCollection.borrowPublicEventRef(eventId: eventId) 
		?? panic("A public event with the provided eventId does not exist.")

		self.userFloatCollection = account.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) 
		?? panic("Could not borrow the users public FLOAT Collection.")									
	}

	execute {
		for id in ids { 
			self.aeraCollection.burn(id)
		}
		self.floatEventPublic.claim(recipient: self.userFloatCollection, params: {})
	}

	post {
		self.floatEventPublic.hasClaimed(account: self.userAddress) != nil: "User has not claimed the challenge FLOAT"
		hasAnyNFT(ids: ids, collection: self.aeraCollection) == false: "Could not burn all the NFTs provided by the user"
	}
}

pub fun hasAnyNFT(ids: [UInt64], collection: &AeraNFT.Collection): Bool {
  for id in ids {
	if collection.hasNFT(id) {
		return true;
	}
  }
  return false;
}
