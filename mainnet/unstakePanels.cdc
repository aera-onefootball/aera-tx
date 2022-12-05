import AeraPanel1 from 0x30cf5dcf6ea8d379

//Initialize a users storage slots for OneFootball
transaction(nftIds:[UInt64]){

    let panelCol : &AeraPanel1.Collection

    prepare(account: AuthAccount) {
        self.panelCol= account.borrow<&AeraPanel1.Collection>(from: AeraPanel1.CollectionStoragePath) ?? panic("Cannot borrow panel collection reference from path")
    }

    execute{
        self.panelCol.unstake(nftIds:nftIds)
    }
}
