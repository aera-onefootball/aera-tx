import AeraPanel from 0x46625f59708ec2f8

//Initialize a users storage slots for OneFootball
transaction(nftIds:[UInt64]){

    let panelCol : &AeraPanel.Collection

    prepare(account: AuthAccount) {
        self.panelCol= account.borrow<&AeraPanel.Collection>(from: AeraPanel.CollectionStoragePath) ?? panic("Cannot borrow panel collection reference from path")
    }

    execute{
        self.panelCol.unstake(nftIds:nftIds)
    }
}
