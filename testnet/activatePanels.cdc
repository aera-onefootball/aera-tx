import AeraPanel2 from 0x46625f59708ec2f8
import AeraReward2 from 0x46625f59708ec2f8

//Initialize a users storage slots for OneFootball
transaction(chapterId: UInt64, nftIds:[UInt64]){

    let panelCol : &AeraPanel2.Collection
    let rewardCol : &AeraReward2.Collection

    prepare(account: AuthAccount) {
        self.panelCol= account.borrow<&AeraPanel2.Collection>(from: AeraPanel2.CollectionStoragePath) ?? panic("Cannot borrow panel collection reference from path")
        self.rewardCol= account.borrow<&AeraReward2.Collection>(from: AeraReward2.CollectionStoragePath) ?? panic("Cannot borrow reward collection reference from path")
    }

    execute{
        self.panelCol.activate(chapterId: chapterId, nftIds:nftIds, receiver: self.rewardCol)
    }
}
