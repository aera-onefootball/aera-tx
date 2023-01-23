import AeraNFT from 0x30cf5dcf6ea8d379
import AeraPack from 0x30cf5dcf6ea8d379
import AeraPanel2 from 0x30cf5dcf6ea8d379
import AeraReward2 from 0x30cf5dcf6ea8d379
import NonFungibleToken from 0x1d7e57aa55817448
import MetadataViews from 0x1d7e57aa55817448
import FLOAT from 0x2d4c3caffbeab845

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

        //run the buy without init first
        let aeraCapCorrect= account.getCapability<&AeraNFT.Collection{NonFungibleToken.CollectionPublic}>(AeraNFT.CollectionPublicPath)
        if !aeraCapCorrect.check() {
            account.unlink(AeraNFT.CollectionPublicPath)
            account.unlink(AeraNFT.CollectionPrivatePath)

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
        // if account.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil
        if !floatCap.check() {
            // cannot cast to <@NonFungibleToken.Collection>
            account.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
            account.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>(
                FLOAT.FLOATCollectionPublicPath,
                target: FLOAT.FLOATCollectionStoragePath
            )
        }

        let panelCap= account.getCapability<&{NonFungibleToken.CollectionPublic}>(AeraPanel2.CollectionPublicPath)
        if !panelCap.check() {
            // cannot cast to <@NonFungibleToken.Collection>
            account.save(<- AeraPanel2.createEmptyCollection(), to: AeraPanel2.CollectionStoragePath)
            account.link<&AeraPanel2.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, AeraPanel2.CollectionPublic}>(
                AeraPanel2.CollectionPublicPath,
                target: AeraPanel2.CollectionStoragePath
            )
        }

        let rewardCap= account.getCapability<&{NonFungibleToken.CollectionPublic}>(AeraReward2.CollectionPublicPath)
        if !rewardCap.check() {
            // cannot cast to <@NonFungibleToken.Collection>
            account.save(<- AeraReward2.createEmptyCollection(), to: AeraReward2.CollectionStoragePath)
            account.link<&AeraReward2.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>(
                AeraReward2.CollectionPublicPath,
                target: AeraReward2.CollectionStoragePath
            )
        }

    }
}
