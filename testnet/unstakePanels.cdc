import AeraPanel2 from 0x46625f59708ec2f8

//Initialize a users storage slots for OneFootball
transaction(nftIds:[UInt64]){

    let panelCol : &AeraPanel2.Collection

    prepare(account: AuthAccount) {
        self.panelCol= account.borrow<&AeraPanel2.Collection>(from: AeraPanel2.CollectionStoragePath) ?? panic("Cannot borrow panel collection reference from path")
    }

    execute{
        self.panelCol.unstake(nftIds:nftIds)
    }
}
