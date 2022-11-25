import AeraNFT from 0x46625f59708ec2f8
import Admin from 0x46625f59708ec2f8
import FindAirdropper from 0x35717efbbce11c74
import NonFungibleToken from 0x631e88ae7f1d7c20

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
