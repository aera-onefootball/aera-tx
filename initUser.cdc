import HatttricksNFT from 0x4ff956c78244911b
import FindPack from 0x4ff956c78244911b
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20

//Initialize a users storage slots for OneFootball
transaction {
    prepare(account: AuthAccount) {

        let findPackCap= account.getCapability<&{NonFungibleToken.CollectionPublic}>(FindPack.CollectionPublicPath)
        if !findPackCap.check() {
            account.save<@NonFungibleToken.Collection>( <- FindPack.createEmptyCollection(), to: FindPack.CollectionStoragePath)
            account.link<&FindPack.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, FindPack.CollectionPublic, MetadataViews.ResolverCollection}>(
                FindPack.CollectionPublicPath, 
                target: FindPack.CollectionStoragePath
            )
        }

        let hatttricksCap= account.getCapability<&{NonFungibleToken.CollectionPublic}>(HatttricksNFT.CollectionPublicPath)
        if !hatttricksCap.check() {
            account.save<@NonFungibleToken.Collection>(<- HatttricksNFT.createEmptyCollection(), to: HatttricksNFT.CollectionStoragePath)
            account.link<&HatttricksNFT.Collection{HatttricksNFT.CollectionPublic, NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(
                HatttricksNFT.CollectionPublicPath,
                target: HatttricksNFT.CollectionStoragePath
            )
            account.link<&HatttricksNFT.Collection{NonFungibleToken.Provider, HatttricksNFT.CollectionPublic, NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(
                HatttricksNFT.CollectionPrivatePath,
                target: HatttricksNFT.CollectionStoragePath
            )
        }
    }
}
