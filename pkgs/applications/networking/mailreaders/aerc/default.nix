{ lib
, buildGoModule
, fetchFromSourcehut
, ncurses
, notmuch
, scdoc
, python3
, w3m
, dante
}:

buildGoModule rec {
  pname = "aerc";
  version = "0.9.0";

  src = fetchFromSourcehut {
    owner = "~rjarry";
    repo = pname;
    rev = version;
    sha256 = "sha256-D4cZVNh3YFaVRHGFn5Nt6kMSRCShj0w5n7pTxgYik2s=";
  };

  proxyVendor = true;
  vendorSha256 = "sha256-fGQ15i3mWNmmfypRt5A7SAVYSEg9m4so4FYlUY+7mW8=";

  doCheck = false;

  nativeBuildInputs = [
    scdoc
    python3.pkgs.wrapPython
  ];

  patches = [
    ./runtime-sharedir.patch
  ];

  postPatch = ''
    substituteAllInPlace config/aerc.conf
    substituteAllInPlace config/config.go
    substituteAllInPlace doc/aerc-config.5.scd
  '';

  pythonPath = [
    python3.pkgs.colorama
  ];

  buildInputs = [ python3 notmuch ];

  buildPhase = "
    runHook preBuild
    # we use make instead of go build
    runHook postBuild
  ";

  installPhase = ''
    runHook preInstall
    make PREFIX=$out GOFLAGS="$GOFLAGS -tags=notmuch" install
    wrapPythonProgramsIn $out/share/aerc/filters "$out $pythonPath"
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/aerc --prefix PATH ":" \
      "$out/share/aerc/filters:${lib.makeBinPath [ ncurses ]}"
    wrapProgram $out/share/aerc/filters/html --prefix PATH ":" \
      ${lib.makeBinPath [ w3m dante ]}
  '';

  meta = with lib; {
    description = "An email client for your terminal";
    homepage = "https://aerc-mail.org/";
    maintainers = with maintainers; [ tadeokondrak ];
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
