// Start - Support direct Mocha run & debug
import 'hardhat'
import '@nomiclabs/hardhat-ethers'
// End - Support direct Mocha run & debug

import chai, {expect} from 'chai'
import {before, beforeEach} from 'mocha'
import {solidity} from 'ethereum-waffle'
import {deployContract, signer} from './framework/contracts'
import {SignerWithAddress} from '@nomiclabs/hardhat-ethers/signers'
import {successfulTransaction} from './framework/transaction'
import {ERC20, SpeeDrive} from '../typechain-types'
import {ethers} from 'ethers'

chai.use(solidity)

describe('SpeeDrive test suite', () => {
    let contract: SpeeDrive
    let spd: ERC20
    let s0: SignerWithAddress, s1: SignerWithAddress, s2: SignerWithAddress

    before(async () => {
        s0 = await signer(0)
        s1 = await signer(1)
        s2 = await signer(2)
    })

    beforeEach(async () => {
        contract = await deployContract<SpeeDrive>('SpeeDrive')
        // spd = await deployContract<ERC20>('ERC20')
    })

    describe('3) Functional Tests 2%', () => {
        const onRampName1 = 'on ramp 1'
        const offRampName1 = 'off ramp 1'
        const feeOn1Off1 = 5
        it('SpeeDrive normal walkthrough', async () => {
            /*
             *  set contract spd address
             * await contract.connect(s0).setSPD(spd.address);
             *  create a ramp pair
             */
            /*
             *await contract
             *  .connect(s0)
             *  .createRampPair(onRampName1, offRampName1, feeOn1Off1)
             *const rampPairId = await contract.getRampPairId(
             *  onRampName1,
             *  offRampName1
             *)
             *const rampPair = await contract.getRampPair(rampPairId)
             *expect(rampPair.isAlive).to.be.true
             *expect(rampPair.exists).to.be.true
             *expect(rampPair.fee).to.equal(feeOn1Off1)
             *
             * // enter ramp
             *var tx = await contract.connect(s1).enterRamp(onRampName1)
             *await expect(tx)
             *  .to.emit(contract, 'RampEntered')
             *  .withArgs(onRampName1, s1.address)
             *
             * // exit ramp
             *tx = await contract.connect(s1).exitRamp(offRampName1)
             *await expect(tx)
             *  .to.emit(contract, 'RampExited')
             *  .withArgs(offRampName1, s1.address, feeOn1Off1)
             *
             * // close ramp
             *await contract.connect(s0).turnOffRampPair(onRampName1, offRampName1)
             *const rampPairAfterClose = await contract.getRampPair(rampPairId)
             *expect(rampPair.isAlive).to.be.false
             */
        })
    })
})
