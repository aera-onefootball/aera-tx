import AeraNFT from 0x46625f59708ec2f8
import NonFungibleToken from 0x631e88ae7f1d7c20
import FLOAT from 0x0afe396ebc8eee65
import MetadataViews from 0x631e88ae7f1d7c20
import GrantedAccountAccess from 0x0afe396ebc8eee65

/// This transaction facilitates the completion of a Transfer Challenge
///
/// It has two phases:
///   1) Burning of selected NFT's
///   2) Delivery of a receipt for challenge completion, in the form of a FLOAT
///
/// Inputs:
///
/// ids: A list of id's corresponding to NFT's that will be burned
/// eventId: The id of the Transfer Challenge event
/// eventHost: The account address of the event host
transaction(ids: [UInt64], eventId: UInt64, eventHost: Address) {
    let userAddress: Address;
    let aeraCollection: &AeraNFT.Collection
    let floatEventsHostCollection: &FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}
    let floatEventPublic: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}
    let userFloatCollection: &FLOAT.Collection

    prepare(account: AuthAccount) {
        self.userAddress = account.address

        // Borrow access to the user's NFT collection
        self.aeraCollection = account.borrow<&AeraNFT.Collection>(from: AeraNFT.CollectionStoragePath) 
        ?? panic("Could not borrow the users AeraNFT Collection.")
        
        // Borrow access to the event host's collection of FLOATEvent's
        self.floatEventsHostCollection = getAccount(eventHost).getCapability<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>(FLOAT.FLOATEventsPublicPath).borrow() 
        ?? panic("Could not borrow FLOATEvents from the event host.")

        // Borrow access to the specific Transfer Challenge event
        self.floatEventPublic = self.floatEventsHostCollection.borrowPublicEventRef(eventId: eventId) 
        ?? panic("A public event with the provided eventId does not exist.")

        // Borrow access to the user's FLOAT collection
        self.userFloatCollection = account.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) 
        ?? panic("Could not borrow the users public FLOAT Collection.")                                    
    }

    pre {
        // Confirm that moment id's were submitted with this transaction
        ids.length != 0: "No moment id's were submitted with this transaction"
    }

    execute {
        // Burn the selected NFT's from the user's NFT collection
        for id in ids { 
            self.aeraCollection.burn(id)
        }

        // Deliver the FLOAT to the user's FLOAT collection
        self.floatEventPublic.claim(recipient: self.userFloatCollection, params: {})
    }

    post {
        // Confirm that the user has claimed the FLOAT
        self.floatEventPublic.hasClaimed(account: self.userAddress) != nil: "User has not claimed the challenge FLOAT"

        // Confirm that the selected NFT's were burned successfully
        hasAnyNFT(ids: ids, collection: self.aeraCollection) == false: "Failed to burn all the NFT's selected by the user"
    }
}

/// This function takes a list of NFT id's and checks whether
/// a given NFT collection contains any of them
pub fun hasAnyNFT(ids: [UInt64], collection: &AeraNFT.Collection): Bool {
  for id in ids {
    if collection.hasNFT(id) {
        return true;
    }
  }
  return false;
}
