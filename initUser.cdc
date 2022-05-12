import HatttricksNFT from 0x9b6ec56eec94507b
import AeraPack from 0x9b6ec56eec94507b
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20

//Initialize a users storage slots for OneFootball
transaction {
    prepare(account: AuthAccount) {

        let aeraPackCap= account.getCapability<&{NonFungibleToken.CollectionPublic}>(AeraPack.CollectionPublicPath)
        if !aeraPackCap.check() {
            account.save<@NonFungibleToken.Collection>( <- AeraPack.createEmptyCollection(), to: AeraPack.CollectionStoragePath)
            account.link<&AeraPack.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, AeraPack.CollectionPublic, MetadataViews.ResolverCollection}>(
                AeraPack.CollectionPublicPath,
                target: AeraPack.CollectionStoragePath
            )
        }

        let hatttricksCap= account.getCapability<&{NonFungibleToken.CollectionPublic}>(HatttricksNFT.CollectionPublicPath)
        if !hatttricksCap.check() {
            account.save<@NonFungibleToken.Collection>(<- HatttricksNFT.createEmptyCollection(), to: HatttricksNFT.CollectionStoragePath)
            account.link<&HatttricksNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(
                HatttricksNFT.CollectionPublicPath,
                target: HatttricksNFT.CollectionStoragePath
            )
            account.link<&HatttricksNFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(
                HatttricksNFT.CollectionPrivatePath,
                target: HatttricksNFT.CollectionStoragePath
            )
        }
    }
}
