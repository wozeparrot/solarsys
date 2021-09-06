{ ... }: {
  networking.wg-quick.interfaces.wg0 = {
    address = [ "fdbe:ef11:2358:1321::99/64" ];
    
    privateKeyFile = "/home/woze/projects/nix/solarsys/satellites/desktops/woztop/wg_private";

    peers = [
      {
        publicKey = "W0yvMPgWIS/qKWKPg2x+7xkHNlmvJ1Ze4iFhTS1BkXk=";
        allowedIPs = [ "fdbe:ef11:2358:1321::/64" ];
        endpoint = "192.168.0.249:5553";
        persistentKeepalive = 25;
      }
    ];
  };
}
