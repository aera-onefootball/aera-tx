import AeraNFT from 0x30cf5dcf6ea8d379
import NonFungibleToken from 0x1d7e57aa55817448
import FLOAT from 0x2d4c3caffbeab845
import MetadataViews from 0x1d7e57aa55817448
import GrantedAccountAccess from 0x2d4c3caffbeab845
import FindFurnace from 0x097bafa4e0b48eef
import FindViews from 0x097bafa4e0b48eef

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

    let pointers : [FindViews.AuthNFTPointer] 

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


        self.pointers = []
        var cap = account.getCapability<&AeraNFT.Collection{MetadataViews.ResolverCollection, NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(AeraNFT.CollectionPrivatePath)
        if !cap.check() {
        account.getCapability(AeraNFT.CollectionPrivatePath)
            account.link<&AeraNFT.Collection{MetadataViews.ResolverCollection, NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(AeraNFT.CollectionPrivatePath , target: AeraNFT.CollectionStoragePath)
            cap = account.getCapability<&AeraNFT.Collection{MetadataViews.ResolverCollection, NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(AeraNFT.CollectionPrivatePath)
        }

        for id in ids {
            self.pointers.append(FindViews.AuthNFTPointer(cap: cap, id: id))
        }

    }

    pre {
        // Confirm that moment id's were submitted with this transaction
        ids.length != 0: "No moment id's were submitted with this transaction"
    }

    execute {

        let ctx : {String : String} = {} 
        ctx["tenant"] = "onefootball"
        for i , pointer in self.pointers {
            FindFurnace.burn(pointer: pointer, context: ctx)
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
