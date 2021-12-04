{ pkgs ? import <nixpkgs> {} }:
## we default to importing <nixpkgs> here, so that you can use
## a simple shell command to insert new sha256's into this file
## e.g. with emacs C-u M-x shell-command
##
##     nix-prefetch-url sources.nix -A {stable{,.mono,.gecko64,.gecko32}, unstable, staging, winetricks}

# here we wrap fetchurl and fetchFromGitHub, in order to be able to pass additional args around it
let fetchurl = args@{url, sha256, ...}:
  pkgs.fetchurl { inherit url sha256; } // args;
    fetchFromGitHub = args@{owner, repo, rev, sha256, ...}:
  pkgs.fetchFromGitHub { inherit owner repo rev sha256; } // args;
in rec {

  stable = fetchurl rec {
    version = "6.0.2";
    url = "https://dl.winehq.org/wine/source/6.0/wine-${version}.tar.xz";
    sha256 = "sha256-3+PFiseFwHIg4o8VtiKZ12wk0lametm//Yrvpns9u3A=";

    ## see http://wiki.winehq.org/Gecko
    gecko32 = fetchurl rec {
      version = "2.47.2";
      url = "https://dl.winehq.org/wine/wine-gecko/${version}/wine-gecko-${version}-x86.msi";
      sha256 = "07d6nrk2g0614kvwdjym1wq21d2bwy3pscwikk80qhnd6rrww875";
    };
    gecko64 = fetchurl rec {
      version = "2.47.2";
      url = "https://dl.winehq.org/wine/wine-gecko/${version}/wine-gecko-${version}-x86_64.msi";
      sha256 = "0iffhvdawc499nbn4k99k33cr7g8sdfcvq8k3z1g6gw24h87d5h5";
    };

    ## see http://wiki.winehq.org/Mono
    mono = fetchurl rec {
      version = "5.1.1";
      url = "https://dl.winehq.org/wine/wine-mono/${version}/wine-mono-${version}-x86.msi";
      sha256 = "09wjrfxbw0072iv6d2vqnkc3y7dzj15vp8mv4ay44n1qp5ji4m3l";
    };

    patches = [
      # Also look for root certificates at $NIX_SSL_CERT_FILE
      ./cert-path.patch
    ];
  };

  unstable = fetchurl rec {
    # NOTE: Don't forget to change the SHA256 for staging as well.
    version = "6.23";
    url = "https://dl.winehq.org/wine/source/6.x/wine-${version}.tar.xz";
    sha256 = "sha256-2Wx/MXQeQlH7UPkZMJxgRmUmfPrO4T+PRQowyVNiDg0=";
    inherit (stable) gecko32 gecko64;

    ## see http://wiki.winehq.org/Mono
    mono = fetchurl rec {
      version = "7.0.0";
      url = "https://dl.winehq.org/wine/wine-mono/${version}/wine-mono-${version}-x86.msi";
      sha256 = "sha256-s35vyeWQ5YIkPcJdcqX8wzDDp5cN/cmKeoHSOEW6iQA=";
    };

    patches = [
      # Also look for root certificates at $NIX_SSL_CERT_FILE
      ./cert-path-6.21.patch
     ];
  };

  staging = fetchFromGitHub rec {
    # https://github.com/wine-staging/wine-staging/releases
    inherit (unstable) version;
    sha256 = "sha256-ml4dPdkKFxeWf/hAFw64Xg9kppe2Az0vyx7WFr/ZhR0=";
    owner = "wine-staging";
    repo = "wine-staging";
    rev = "v${version}";

    disabledPatchsets = [ ];
  };

  winetricks = fetchFromGitHub rec {
    # https://github.com/Winetricks/winetricks/releases
    version = "20210825";
    sha256 = "sha256-exMhj3dS8uXCEgOaWbftaq94mBOmtZIXsXb9xNX5ha8=";
    owner = "Winetricks";
    repo = "winetricks";
    rev = version;
  };
}
