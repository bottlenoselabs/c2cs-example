# Bindgen

## Getting started

1. Install CAstFfi and C2CS:
    - `dotnet tool install bottlenoselabs.castffi.tool --global`
    - `dotnet tool install bottlenoselabs.c2cs.tool --global`

2. Change the `config-linux.json`, `config-macos.json`, `config-windows.json`, `config-cs.json` to suit your needs.

3. Run the `extract.sh` script on each build platform (Windows, macOS, Linux). If you run the script only for one platform, then the bindings are only garanteed to be correct for that platform.
   
4. Copy the outpt `./ast/` files from the previous step into one and then run the `merge.sh` script.

5. With the output of the previous step, run the `generate.sh` script.

## Debugging CAstFfi and/or C2CS

To have CAstFfi and/or C2CS print all logs which are useful for debugging, change the `appsettings.json` file in this directory so that the log level looks like the following:
```json
        "LogLevel": {
          "Default": "Debug",
          "CAstFfi": "Debug",
          "C2CS": "Debug"
        },
```

