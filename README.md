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
TODO
