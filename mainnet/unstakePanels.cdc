<<<<<<< HEAD
import AeraPanel1 from 0x30cf5dcf6ea8d379
=======
import AeraPanel2 from 0x30cf5dcf6ea8d379
>>>>>>> da74f7b (rename)

//Initialize a users storage slots for OneFootball
transaction(nftIds:[UInt64]){

<<<<<<< HEAD
    let panelCol : &AeraPanel1.Collection

    prepare(account: AuthAccount) {
        self.panelCol= account.borrow<&AeraPanel1.Collection>(from: AeraPanel1.CollectionStoragePath) ?? panic("Cannot borrow panel collection reference from path")
=======
    let panelCol : &AeraPanel2.Collection

    prepare(account: AuthAccount) {
        self.panelCol= account.borrow<&AeraPanel2.Collection>(from: AeraPanel2.CollectionStoragePath) ?? panic("Cannot borrow panel collection reference from path")
>>>>>>> da74f7b (rename)
    }

    execute{
        self.panelCol.unstake(nftIds:nftIds)
    }
}
