import NonFungibleToken from 0x631e88ae7f1d7c20
import FindAirdropper from 0x35717efbbce11c74
import AeraPack from 0x46625f59708ec2f8
import Admin from 0x46625f59708ec2f8

transaction(receiverAddrs: [Address], ids: [UInt64],  messages: [String]) {

    let pathIdentifier : String
    let adminRef : &Admin.AdminProxy

    prepare(account: AuthAccount) {

        self.pathIdentifier = "AeraPackCollection"
        self.adminRef = account.borrow<&Admin.AdminProxy>(from: Admin.AdminProxyStoragePath) ?? panic("Cannot borrow Admin Reference.")

    }

    execute{
        for i, user in receiverAddrs {
            let id = ids[i]

            let uAccount = getAccount(user)
            let userPacks=uAccount.getCapability<&AeraPack.Collection{NonFungibleToken.Receiver}>(AeraPack.CollectionPublicPath).borrow() ?? panic("Could not find userPacks for ".concat(user.toString()))
            let pointer = self.adminRef.getAuthPointer(pathIdentifier: self.pathIdentifier, id: id)
            FindAirdropper.airdrop(pointer: pointer, receiver: user, path: AeraPack.CollectionPublicPath, context: {"message" : messages[i]})
        }
    }
}
