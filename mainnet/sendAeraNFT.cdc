import AeraNFT from 0x30cf5dcf6ea8d379
import Admin from 0x30cf5dcf6ea8d379
import FindAirdropper from 0x097bafa4e0b48eef
import NonFungibleToken from 0x1d7e57aa55817448

transaction(receiverAddr: Address, id: UInt64,  message: String) {

    let pathIdentifier : String
    let adminRef : &Admin.AdminProxy

    prepare(account: AuthAccount) {

        self.pathIdentifier = "aeraNFTs"
        self.adminRef = account.borrow<&Admin.AdminProxy>(from: Admin.AdminProxyStoragePath) ?? panic("Cannot borrow Admin Reference.")

    }

    execute{
        let uAccount = getAccount(receiverAddr)
        let userPacks=uAccount.getCapability<&AeraNFT.Collection{NonFungibleToken.Receiver}>(AeraNFT.CollectionPublicPath).borrow() ?? panic("Could not find user collection for ".concat(receiverAddr.toString()))
        let pointer = self.adminRef.getAuthPointer(pathIdentifier: self.pathIdentifier, id: id)
        FindAirdropper.airdrop(pointer: pointer, receiver: receiverAddr, path: AeraNFT.CollectionPublicPath, context: {"message" : message})
    }
}
