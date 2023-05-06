# metacalls.mo
Stable class adding support for metacalls in Motoko.

The following features are supported:
- Generate t-ecdsa keys
- Create & Sign a message using a generated key
- Send signed message to IC via `http_request`
- List messages and keys
- Cleanup expired messages based on TTL

The documentation can be found at https://darkdrag00nv2.github.io/metacalls.mo/

### Dependencies
- [Stable Hash Map](https://github.com/ZhenyaUsenko/motoko-hash-map)
- [Stable Buffer](https://github.com/canscale/StableBuffer)
- [Encoding](https://github.com/aviate-labs/encoding.mo)
- [UUID](https://github.com/aviate-labs/uuid.mo)
- [SHA-256](https://github.com/enzoh/motoko-sha)

### Development
You just need a dfx development environment.

To run the tests locally, execute the following command

```bash
./test.sh
```

### License

This library is distributed under the terms of the Apache License (Version 2.0). See LICENSE for details.

### Funding

This library was initially incentivized by [ICDevs](https://icdevs.org/). You can view more about
the bounty on the
[forum](https://forum.dfinity.org/t/open-icdevs-org-bounty-23a-metacalls-motoko-up-to-10k/15422).
If you use this library and gain value from it, please consider a donation to ICDevs.
