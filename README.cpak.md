# CSPenguin cpak package

The included GitHub Actions workflow builds and publishes the `linux/amd64` OCI image, then pins its digest in `cpak.json`.

```sh
docker buildx build --platform linux/amd64 --tag ghcr.io/OWNER/cspenguin-cpak:main --push .
cpak validate cpak.json
cpak dev cpak.json --binary /usr/local/bin/cspenguin-cpak
```

The package reuses a CSPenguin Wine runtime already stored in the user's home. When none is available, it downloads Wine 11.4 from Kron4ek, verifies the SHA-256 checksum, and stores the extracted runtime in the cpak data directory.

## Install

Install cpak and the package with:

```sh
chmod +x install-cpak.sh
./install-cpak.sh
```

If cpak is already installed, use:

```sh
cpak install github.com/crowrei34/uwuawa
```

To download the standalone installer for Linux amd64:

```sh
curl -fL -o CSPenguin-amd64.cpak-installer "https://cpak.it/install/github.com/CrowRei34/Uwuawa?arch=amd64"
chmod +x CSPenguin-amd64.cpak-installer
./CSPenguin-amd64.cpak-installer
```

The `.cpak-installer` endpoint becomes available after the package is reviewed by the cpak Store.
