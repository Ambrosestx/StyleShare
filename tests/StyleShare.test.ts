import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.7.1/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure contract is deployed",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        // Simple test to verify deployment
        const deployer = accounts.get('deployer')!;
        assertEquals(typeof deployer.address, 'string');
    },
});

Clarinet.test({
    name: "Can list a single fashion item",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        let block = chain.mineBlock([
            Tx.contractCall(
                'StyleShare',
                'list-fashion-item',
                [
                    types.ascii("Designer Dress"),
                    types.ascii("Beautiful evening gown"),
                    types.ascii("Dress"),
                    types.ascii("M"),
                    types.uint(50),
                    types.uint(100)
                ],
                deployer.address
            )
        ]);
        
        assertEquals(block.receipts.length, 1);
        assertEquals(block.height, 2);
        
        // Check that the transaction succeeded
        block.receipts[0].result.expectOk().expectUint(1);
    },
});