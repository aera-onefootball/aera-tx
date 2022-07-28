import AeraNFT from 0xd35de4da00fb3511
import AeraPack from 0xd35de4da00fb3511
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

        let aeraCap= account.getCapability<&{NonFungibleToken.CollectionPublic}>(AeraNFT.CollectionPublicPath)
        if !aeraCap.check() {
            account.save<@NonFungibleToken.Collection>(<- AeraNFT.createEmptyCollection(), to: AeraNFT.CollectionStoragePath)
            account.link<&AeraNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection, AeraNFT.CollectionPublic}>(
                AeraNFT.CollectionPublicPath,
                target: AeraNFT.CollectionStoragePath
            )
            account.link<&AeraNFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection, AeraNFT.CollectionPublic}>(
                AeraNFT.CollectionPrivatePath,
                target: AeraNFT.CollectionStoragePath
            )
        }
    }
}
