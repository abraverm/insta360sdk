{
  outputs = {
    self,
    nixpkgs,
  }: {
    # Declare some local packages be available via self.packages
    packages.x86_64-linux = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in {
      insta360sdk = pkgs.callPackage ./insta360sdk.nix {};
    };
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.insta360sdk;
  };
}
