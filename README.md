Docker binaries for torcx
=========================

This provides some pre-built Docker torcx images that can be used with
[CoreOS Container Linux](https://coreos.com/).

Images are extracted from official Container Linux builds, and provided as this repository.
That way they can be fetched directly from GitHub and included into an initrd or through
ignition.

Sample ignition configuration
-----------------------------

A sample configuration is provided: [ignition/latest.json](ignition/latest.json)

You can use this configuration from the kernel cmdline:
```
... coreos.config.url=https://raw.githubusercontent.com/CoRfr/torcx-docker-binaries/master/ignition/latest.json ...
```
On PXE, you will also need `coreos.first_boot=1`, according to the (documentation)[https://coreos.com/ignition/docs/latest/boot-process.html).

It also allows you to select a version in particular:
```
... coreos.config.url=https://raw.githubusercontent.com/CoRfr/torcx-docker-binaries/master/ignition/17.06.1.json ...
```

This configuration uses sample torcx files contained in a `torcx/` directory in this repository.
