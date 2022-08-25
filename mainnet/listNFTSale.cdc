import FindMarket from 0x097bafa4e0b48eef
import Profile from 0x097bafa4e0b48eef
import FindMarketSale from 0x097bafa4e0b48eef
import NFTCatalog from 0x49a7cda3a1eecc29
import FINDNFTCatalog from 0x097bafa4e0b48eef
import FTRegistry from 0x097bafa4e0b48eef
import FindViews from 0x097bafa4e0b48eef

import FungibleToken from 0xf233dcee88fe0abe
import DapperUtilityCoin from 0xead892083b3e2c6c
import TokenForwarding from 0xe544175ee0461c4b
import NonFungibleToken from 0x1d7e57aa55817448
import MetadataViews from 0x1d7e57aa55817448

transaction(dapperAddress:Address, marketplace:Address, nftAliasOrIdentifier: String, id: UInt64, directSellPrice:UFix64, validUntil: UFix64?) {
    
    let saleItems : &FindMarketSale.SaleItemCollection?
    let pointer : FindViews.AuthNFTPointer
    let vaultType : Type
    
    prepare(account: AuthAccount) {

        let name = account.address.toString()
        let ducReceiver = account.getCapability<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver)
        if !ducReceiver.check() {
            let dapper = getAccount(dapperAddress)
            let ducForwarder <- TokenForwarding.createNewForwarder(recipient: dapper.getCapability<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver))
            account.save(<-ducForwarder, to: /storage/dapperUtilityCoinReceiver)
            account.link<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver,target: /storage/dapperUtilityCoinReceiver)
        }

        var created=false
        var updated=false
        let profileCap = account.getCapability<&{Profile.Public}>(Profile.publicPath)
        if !profileCap.check() {
            created=true
            let profile <-Profile.createUser(name:name, createdAt: "onefootball")
            account.save(<-profile, to: Profile.storagePath)
            account.link<&Profile.User{Profile.Public}>(Profile.publicPath, target: Profile.storagePath)
            account.link<&{FungibleToken.Receiver}>(Profile.publicReceiverPath, target: Profile.storagePath)
        }

        let profile=account.borrow<&Profile.User>(from: Profile.storagePath)!

        if !profile.hasWallet("DUC") {
            profile.addWallet(Profile.Wallet( name:"DUC", receiver:ducReceiver, balance:account.getCapability<&{FungibleToken.Balance}>(/public/dapperUtilityCoinBalance), accept: Type<@DapperUtilityCoin.Vault>(), tags: ["duc", "dapperUtilityCoin","dapper"]))
            updated=true
        }

        if created {
            profile.emitCreatedEvent()
        } else if updated {
            profile.emitUpdatedEvent()
        }

        let receiverCap=account.getCapability<&{FungibleToken.Receiver}>(Profile.publicReceiverPath)
        let saleItemType= Type<@FindMarketSale.SaleItemCollection>()
        let tenantCapability= FindMarket.getTenantCapability(marketplace)!

        let tenant = tenantCapability.borrow()!
        let publicPath=FindMarket.getPublicPath(saleItemType, name: tenant.name)
        let storagePath= FindMarket.getStoragePath(saleItemType, name:tenant.name)

        let saleItemCap= account.getCapability<&FindMarketSale.SaleItemCollection{FindMarketSale.SaleItemCollectionPublic, FindMarket.SaleItemCollectionPublic}>(publicPath) 
        if !saleItemCap.check() {
            //The link here has to be a capability not a tenant, because it can change.
            account.save<@FindMarketSale.SaleItemCollection>(<- FindMarketSale.createEmptySaleItemCollection(tenantCapability), to: storagePath)
            account.link<&FindMarketSale.SaleItemCollection{FindMarketSale.SaleItemCollectionPublic, FindMarket.SaleItemCollectionPublic}>(publicPath, target: storagePath)
        }
        //end initializtion

        // Get supported NFT and FT Information from Registries from input alias
        let collectionIdentifier = FINDNFTCatalog.getCollectionsForType(nftTypeIdentifier: nftAliasOrIdentifier)?.keys ?? panic("This NFT is not supported by the NFT Catalog yet. Type : ".concat(nftAliasOrIdentifier)) 
        let collection = FINDNFTCatalog.getCatalogEntry(collectionIdentifier : collectionIdentifier[0])! 
        let nft = collection.collectionData

        let ft = FTRegistry.getFTInfo(Type<@DapperUtilityCoin.Vault>().identifier) ?? panic("This FT is not supported by the Find Market yet. Type : ".concat(Type<@DapperUtilityCoin.Vault>().identifier))

        let providerCap=account.getCapability<&{NonFungibleToken.Provider, MetadataViews.ResolverCollection, NonFungibleToken.CollectionPublic}>(nft.privatePath)

        if !providerCap.check() {
            account.link<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(
                nft.privatePath,
                target: nft.storagePath
            )
        }
        // Get the salesItemRef from tenant
        self.saleItems= account.borrow<&FindMarketSale.SaleItemCollection>(from: tenant.getStoragePath(Type<@FindMarketSale.SaleItemCollection>()))
        self.pointer= FindViews.AuthNFTPointer(cap: providerCap, id: id)
        self.vaultType= ft.type
    }

    pre{
        self.saleItems != nil : "Cannot borrow reference to saleItem"
    }

    execute{
        self.saleItems!.listForSale(pointer: self.pointer, vaultType: self.vaultType, directSellPrice: directSellPrice, validUntil: validUntil, extraField: {})

    }
}
