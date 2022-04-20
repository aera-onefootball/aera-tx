import FindPack from 0x4ff956c78244911b
import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20
import DapperUtilityCoin from 0x82ec283f88a62e65

/// A transaction to buy a pack using a signed message from the backend
/// @param marketplace: The account of the marketplace
/// @param packId: The pack id to buy
/// @param amount: the expected amount to be paid for this pack
/// @param signature: A message signed by the solution AuthAccount to verify that this packId and this message is the same.
transaction(marketplace:Address, packId:UInt64, amount: UFix64, signature:String) {
	let packs: &FindPack.Collection{FindPack.CollectionPublic}

	let userPacks: Capability<&FindPack.Collection{NonFungibleToken.Receiver}>
	let salePrice: UFix64

	let mainDapperUtilityCoinVault: &DapperUtilityCoin.Vault
	let paymentVault: @FungibleToken.Vault
	let balanceBeforeTransfer:UFix64

	//TODO: How does dapper sign this transaction? Does this happen automatically or does the dapp have to ask dapper via an api for an authorizer to co-sign?
	prepare(dapper:AuthAccount, account: AuthAccount) {

		//We do not init the users storage here since it is important that a user has both a Pack and the collection to receive the content initialized.
		//If we did both here the transaction template would be tied to a specific packed NFT and that is not desireable
		self.userPacks=account.getCapability<&FindPack.Collection{NonFungibleToken.Receiver}>(FindPack.CollectionPublicPath)

		// We fetch the packs from chain and check that the pack is still there and fetches the price
		self.packs=FindPack.getPacksCollection()
		let pack=self.packs.borrowFindPack(id: packId) ?? panic("Pack is not available")
		self.salePrice= pack.getMetadata().price

		// Get a DUC vault from Dapper's account, code copied from template repo
		self.mainDapperUtilityCoinVault = dapper.borrow<&DapperUtilityCoin.Vault>(from: /storage/dapperUtilityCoinVault) ?? panic("Cannot borrow DapperUtilityCoin vault from account storage")
		self.balanceBeforeTransfer = self.mainDapperUtilityCoinVault.balance
		self.paymentVault <- self.mainDapperUtilityCoinVault.withdraw(amount: self.salePrice)

	}

	//verify in pre that the price is the same and that the user has a collection
	pre {
		self.salePrice == amount: "unexpected price"
		self.userPacks.check() : "User need a receiver to put the pack in"
	}

	execute {
		self.packs.buyWithSignature(packId:packId, signature: signature, vault: <- self.paymentVault, collectionCapability: self.userPacks)
	}

	// Check that all dapperUtilityCoin was routed back to Dapper
	post {
		self.mainDapperUtilityCoinVault.balance == self.balanceBeforeTransfer: "DapperUtilityCoin leakage"
	}
}
