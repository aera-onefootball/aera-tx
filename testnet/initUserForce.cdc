import AeraNFT from 0x46625f59708ec2f8
import AeraPack from 0x46625f59708ec2f8
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20
import FLOAT from 0x0afe396ebc8eee65

transaction {
    prepare(account: AuthAccount) {

        let aeraPackCap= account.getCapability<&{NonFungibleToken.CollectionPublic}>(AeraPack.CollectionPublicPath)
        let aeraPackCapFull= account.getCapability<&AeraPack.Collection{NonFungibleToken.CollectionPublic}>(AeraPack.CollectionPublicPath)

        if !aeraPackCapFull.check() {
            if aeraPackCap.check() {
                account.unlink(AeraPack.CollectionPublicPath)
                destroy <- account.load<@AnyResource>(from: AeraPack.CollectionStoragePath)
            }
            account.save<@NonFungibleToken.Collection>( <- AeraPack.createEmptyCollection(), to: AeraPack.CollectionStoragePath)
            account.link<&AeraPack.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, AeraPack.CollectionPublic, MetadataViews.ResolverCollection}>(
                AeraPack.CollectionPublicPath,
                target: AeraPack.CollectionStoragePath
            )
        }

        let aeraCap= account.getCapability<&{NonFungibleToken.CollectionPublic}>(AeraNFT.CollectionPublicPath)
        let aeraCapFull= account.getCapability<&AeraNFT.Collection{NonFungibleToken.CollectionPublic}>(AeraNFT.CollectionPublicPath)
        if !aeraCapFull.check() {
            if aeraCap.check() {
                account.unlink(AeraNFT.CollectionPublicPath)
                destroy <- account.load<@AnyResource>(from: AeraNFT.CollectionStoragePath)
            }
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

        let floatCap= account.getCapability<&{NonFungibleToken.CollectionPublic}>(FLOAT.FLOATCollectionPublicPath)
        let floatCapFull= account.getCapability<&FLOAT.Collection{NonFungibleToken.CollectionPublic}>(FLOAT.FLOATCollectionPublicPath)
        if !floatCapFull.check() {
            if floatCap.check() {
                account.unlink(FLOAT.FLOATCollectionPublicPath)
                destroy <- account.load<@AnyResource>(from: FLOAT.FLOATCollectionStoragePath)
            }
            account.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
            account.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>(
                FLOAT.FLOATCollectionPublicPath,
                target: FLOAT.FLOATCollectionStoragePath
            )
        }
    }
}
