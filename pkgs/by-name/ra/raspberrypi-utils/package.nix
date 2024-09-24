{ lib
, stdenv
, fetchFromGitHub
, cmake
, python3
}:

stdenv.mkDerivation {
  pname = "raspberrypi-utils";
  version = "unstable-2024-09-20";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "utils";
    rev = "193d1bec1c6db7e29b7ac4732e7bb396fbdd843d";
    hash = "sha256-SJuiNIIoB7qmK0vrKHt9uAcmYWNybzYnJDR5UDIA09s=";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    (python3.withPackages (ps: [ ps.libfdt ]))
  ];

  meta = with lib; {
    description = "A collection of scripts and simple applications";
    homepage = "https://github.com/raspberrypi/utils";
    license = licenses.bsd3;
    platforms = [ "armv6l-linux" "armv7l-linux" "aarch64-linux" "x86_64-linux" ];
    maintainers = with maintainers; [ minersebas ];
  };
}
