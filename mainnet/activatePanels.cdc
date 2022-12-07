<<<<<<< HEAD
import AeraPanel1 from 0x30cf5dcf6ea8d379
import AeraReward1 from 0x30cf5dcf6ea8d379
=======
import AeraPanel2 from 0x30cf5dcf6ea8d379
import AeraReward2 from 0x30cf5dcf6ea8d379
>>>>>>> da74f7b (rename)

//Initialize a users storage slots for OneFootball
transaction(chapterId: UInt64, nftIds:[UInt64]){

<<<<<<< HEAD
    let panelCol : &AeraPanel1.Collection
    let rewardCol : &AeraReward1.Collection

    prepare(account: AuthAccount) {
        self.panelCol= account.borrow<&AeraPanel1.Collection>(from: AeraPanel1.CollectionStoragePath) ?? panic("Cannot borrow panel collection reference from path")
        self.rewardCol= account.borrow<&AeraReward1.Collection>(from: AeraReward1.CollectionStoragePath) ?? panic("Cannot borrow reward collection reference from path")
=======
    let panelCol : &AeraPanel2.Collection
    let rewardCol : &AeraReward2.Collection

    prepare(account: AuthAccount) {
        self.panelCol= account.borrow<&AeraPanel2.Collection>(from: AeraPanel2.CollectionStoragePath) ?? panic("Cannot borrow panel collection reference from path")
        self.rewardCol= account.borrow<&AeraReward2.Collection>(from: AeraReward2.CollectionStoragePath) ?? panic("Cannot borrow reward collection reference from path")
>>>>>>> da74f7b (rename)
    }

    execute{
        self.panelCol.activate(chapterId: chapterId, nftIds:nftIds, receiver: self.rewardCol)
    }
}
