import AeraPanel from 0x30cf5dcf6ea8d379
import AeraReward from 0x30cf5dcf6ea8d379

//Initialize a users storage slots for OneFootball
transaction(chapterId: UInt64, nftIds:[UInt64]){

    let panelCol : &AeraPanel.Collection
    let rewardCol : &AeraReward.Collection

    prepare(account: AuthAccount) {
        self.panelCol= account.borrow<&AeraPanel.Collection>(from: AeraPanel.CollectionStoragePath) ?? panic("Cannot borrow panel collection reference from path")
        self.rewardCol= account.borrow<&AeraReward.Collection>(from: AeraReward.CollectionStoragePath) ?? panic("Cannot borrow reward collection reference from path")
    }

    execute{
        self.panelCol.activate(chapterId: chapterId, nftIds:nftIds, receiver: self.rewardCol)
    }
}
