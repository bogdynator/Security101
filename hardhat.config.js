require('@nomicfoundation/hardhat-toolbox');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        version: '0.8.15',
        settings: {
            metadata: {
                // Not including the metadata hash
                bytecodeHash: 'none',
            },
            optimizer: {
                enabled: true,
                runs: 400,
            },
        },
    },
    mocha: {
        timeout: 40000,
    },
};
