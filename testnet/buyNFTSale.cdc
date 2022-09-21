import FindMarket from 0x35717efbbce11c74
import AeraNFT from 0x46625f59708ec2f8
import Profile from 0x35717efbbce11c74
import FindMarketSale from 0x35717efbbce11c74
import NFTCatalog from 0x324c34e1c517e4db
import FINDNFTCatalog from 0x35717efbbce11c74
import FTRegistry from 0x35717efbbce11c74
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20
import FungibleToken from 0x9a0766d93b6608b7
import TokenForwarding from 0x51ea0e37c27a1f1a
import DapperUtilityCoin from 0x82ec283f88a62e65

//first argument is the address to the merchant that gets the funds
transaction(merchantAddress: Address, marketplace:Address, address: Address, id: UInt64, amount: UFix64) {

    let targetCapability : Capability<&{NonFungibleToken.Receiver}>
    let walletReference : &FungibleToken.Vault

    let saleItemsCap: Capability<&FindMarketSale.SaleItemCollection{FindMarketSale.SaleItemCollectionPublic}> 
    let balanceBeforeTransfer: UFix64
    prepare(dapper: AuthAccount, account: AuthAccount) {

        let name = account.address.toString()
        let ducReceiver = account.getCapability<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver)
        if !ducReceiver.check() {
            // Create a new Forwarder resource for DUC and store it in the new account's storage
            let ducForwarder <- TokenForwarding.createNewForwarder(recipient: dapper.getCapability<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver))
            account.save(<-ducForwarder, to: /storage/dapperUtilityCoinReceiver)
            // Publish a Receiver capability for the new account, which is linked to the DUC Forwarder
            account.link<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver,target: /storage/dapperUtilityCoinReceiver)
        }
        
        var created=false
        var updated=false
        let profileCap = account.getCapability<&{Profile.Public}>(Profile.publicPath)
        if !profileCap.check() {
            let profile <-Profile.createUser(name:name, createdAt: "onefootball")
            account.save(<-profile, to: Profile.storagePath)
            account.link<&Profile.User{Profile.Public}>(Profile.publicPath, target: Profile.storagePath)
            account.link<&{FungibleToken.Receiver}>(Profile.publicReceiverPath, target: Profile.storagePath)
            created=true
        }

        let profile=account.borrow<&Profile.User>(from: Profile.storagePath)!

        if !profile.hasWallet("DUC") {
            profile.addWallet(Profile.Wallet( name:"DUC", receiver:ducReceiver, balance:account.getCapability<&{FungibleToken.Balance}>(/public/dapperUtilityCoinBalance), accept: Type<@DapperUtilityCoin.Vault>(), tags: ["duc", "dapperUtilityCoin","dapper"]))
            updated=true
        }

        if created {
            profile.emitCreatedEvent()
        } else {
                    if updated {
            profile.emitUpdatedEvent()
                    }
        }

        let receiverCap=account.getCapability<&{FungibleToken.Receiver}>(Profile.publicReceiverPath)
        let saleItemType= Type<@FindMarketSale.SaleItemCollection>()
        let tenantCapability= FindMarket.getTenantCapability(marketplace)!

        let tenant = tenantCapability.borrow()!
        let publicPath=FindMarket.getPublicPath(saleItemType, name: tenant.name)
        let storagePath= FindMarket.getStoragePath(saleItemType, name:tenant.name)

        let saleItemCap= account.getCapability<&FindMarketSale.SaleItemCollection{FindMarketSale.SaleItemCollectionPublic, FindMarket.SaleItemCollectionPublic}>(publicPath) 
        if !saleItemCap.check() {
            account.save<@FindMarketSale.SaleItemCollection>(<- FindMarketSale.createEmptySaleItemCollection(tenantCapability), to: storagePath)
            account.link<&FindMarketSale.SaleItemCollection{FindMarketSale.SaleItemCollectionPublic, FindMarket.SaleItemCollectionPublic}>(publicPath, target: storagePath)
        }

        self.saleItemsCap= FindMarketSale.getSaleItemCapability(marketplace: marketplace, user:address) ?? panic("cannot find sale item cap")
        let marketOption = FindMarket.getMarketOptionFromType(Type<@FindMarketSale.SaleItemCollection>())
    
        //we do some security check to verify that this tenant can do this operation. This will ensure that the onefootball tenant can only sell using DUC and not some other token. But we can change this with transactions later and not have to modify code/transactions
        let item= FindMarket.assertOperationValid(tenant: marketplace, address: address, marketOption: marketOption, id: id)
   let collectionIdentifier = FINDNFTCatalog.getCollectionsForType(nftTypeIdentifier: item.getItemType().identifier)?.keys ?? panic("This NFT is not supported by the NFT Catalog yet. Type : ".concat(item.getItemType().identifier))
        let collection = FINDNFTCatalog.getCatalogEntry(collectionIdentifier : collectionIdentifier[0])! 
        let nft = collection.collectionData

        let ft = FTRegistry.getFTInfoByTypeIdentifier(item.getFtType().identifier) ?? panic("This FT is not supported by the Find Market yet. Type : ".concat(item.getFtType().identifier))
    
        if ft.type != Type<@DapperUtilityCoin.Vault>() {
            panic("This item is not listed for Dapper Wallets. Please buy in with other wallets.")
        }


        self.targetCapability= account.getCapability<&{NonFungibleToken.Receiver}>(nft.publicPath)

        if !self.targetCapability.check() {
            let cd = item.getNFTCollectionData()
            if account.borrow<&AnyResource>(from: cd.storagePath) != nil {
                panic("This collection public link is not set up properly.")
            }
            account.save(<- cd.createEmptyCollection(), to: cd.storagePath)
           account.link<&AeraNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection,AeraNFT.CollectionPublic}>(cd.publicPath, target: cd.storagePath)
            account.link<&AeraNFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection,AeraNFT.CollectionPublic}>(cd.providerPath, target: cd.storagePath)
        }

        self.walletReference = dapper.borrow<&FungibleToken.Vault>(from: ft.vaultPath) ?? panic("No suitable wallet linked for this account")
        self.balanceBeforeTransfer = self.walletReference.balance
    }

    pre {
        self.walletReference.balance > amount : "Your wallet does not have enough funds to pay for this item"
    }

    execute {
        let vault <- self.walletReference.withdraw(amount: amount) 
        self.saleItemsCap.borrow()!.buy(id:id, vault: <- vault, nftCap: self.targetCapability)
    }

    // Check that all dapperUtilityCoin was routed back to Dapper
    post {
        self.walletReference.balance == self.balanceBeforeTransfer: "DapperUtilityCoin leakage"
    }
}
