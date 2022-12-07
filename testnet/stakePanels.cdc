<<<<<<< HEAD
import AeraPanel1 from 0x46625f59708ec2f8
=======
import AeraPanel2 from 0x46625f59708ec2f8
>>>>>>> da74f7b (rename)

//Initialize a users storage slots for OneFootball
transaction(chapterId: UInt64, nftIds:[UInt64]){

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
        self.panelCol.stake(chapterId: chapterId, nftIds:nftIds)
    }
}
