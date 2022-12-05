import AeraPanel1 from 0x46625f59708ec2f8
import AeraReward1 from 0x46625f59708ec2f8

//Initialize a users storage slots for OneFootball
transaction(chapterId: UInt64, nftIds:[UInt64]){

    let panelCol : &AeraPanel1.Collection
    let rewardCol : &AeraReward1.Collection

    prepare(account: AuthAccount) {
        self.panelCol= account.borrow<&AeraPanel1.Collection>(from: AeraPanel1.CollectionStoragePath) ?? panic("Cannot borrow panel collection reference from path")
        self.rewardCol= account.borrow<&AeraReward1.Collection>(from: AeraReward1.CollectionStoragePath) ?? panic("Cannot borrow reward collection reference from path")
    }

    execute{
        self.panelCol.activate(chapterId: chapterId, nftIds:nftIds, receiver: self.rewardCol)
    }
}
