import AeraNFT from 0x30cf5dcf6ea8d379
import Admin from 0x30cf5dcf6ea8d379
import FindAirdropper from 0x097bafa4e0b48eef
import NonFungibleToken from 0x1d7e57aa55817448

transaction(receiverAddrs: [Address], ids: [UInt64],  messages: [String]) {

    let pathIdentifier : String
    let adminRef : &Admin.AdminProxy

    prepare(account: AuthAccount) {

        self.pathIdentifier = "aeraNFTs"
        self.adminRef = account.borrow<&Admin.AdminProxy>(from: Admin.AdminProxyStoragePath) ?? panic("Cannot borrow Admin Reference.")

    }

    execute{
        for i, user in receiverAddrs {
            let id = ids[i]

            let uAccount = getAccount(user)
            let userPacks=uAccount.getCapability<&AeraNFT.Collection{NonFungibleToken.Receiver}>(AeraNFT.CollectionPublicPath).borrow() ?? panic("Could not find user collection for ".concat(user.toString()))
            let pointer = self.adminRef.getAuthPointer(pathIdentifier: self.pathIdentifier, id: id)
            FindAirdropper.airdrop(pointer: pointer, receiver: user, path: AeraNFT.CollectionPublicPath, context: {"message" : messages[i]})
        }
    }
}
