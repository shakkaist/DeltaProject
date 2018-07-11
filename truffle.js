var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "enter judge armor smooth inmate olympic oval flower upset cluster walnut lab";

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
    },
    rinkeby: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/HXqhYu4Qf8kqVi0GcVBj")
      },
      network_id: 4
    }

  }
};

