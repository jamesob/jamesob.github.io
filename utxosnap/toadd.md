 
<!--

### Concurrency model > `init.cpp`

1. `AppInitBasicSetup()`: Register SIGTERM/INT handler, Windows-specific networking config
   - Handler sets `fShutdownRequested = true`
     - grep `ShutdownRequested()` for details
2. `AppInitParameterInteraction()`: ensure CLI parameters make sense
   - See `ArgsManager gArgs`
3. `AppInitSanityChecks()`: crypto sanity checks, lock datadir
4. `AppInitMain()`:
   - Set up `signatureCache`, `scriptExecutionCache`
   - Spawn script verification threads (`ThreadScriptCheck`)
   - Start the `CScheduler scheduler` service loop
   - Register RPC commands
   - `AppInitServers()`: start RPC-HTTP server.
   - Register ZMQ validation interface.

???

-->
