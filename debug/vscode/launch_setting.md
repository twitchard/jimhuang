# vscode lauch.json 

## Example

1. nfs-ganesha

```sh
  "configurations": [
    {
      "name": "(gdb) Launch",
      "type": "cppdbg",
      "request": "launch",
      "program": "${workspaceFolder}/build/MainNFSD/ganesha.nfsd",
      "args": [
        "-f",
        "/etc/ganesha.conf",
        "-p",
        "/run/ganesha.pid",
        "-L",
        "/tmp/log/nfs-ganesha.log",
        "-N",
        "NIV_FULL_DEBUG"
      ],
      "stopAtEntry": true,
      "cwd": "${workspaceFolder}",
      "environment": [],
      "externalConsole": true,
      "MIMode": "gdb",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        },
        {
          "description": "Enable gdb follow fork mode",
          "text": "-gdb-set follow-fork-mode child",
          "ignoreFailures": true
        },
        {
          "description": "Enable gdb detach on fork",
          "text": "-gdb-set detach-on-fork on",
          "ignoreFailures": true
        }
      ]
    }
  ]
```

## Setup Commonds

### c/c++

- enable gdb follow fork and detach-on-fork

```sh
        {
          "description": "Enable gdb follow fork mode",
          "text": "-gdb-set follow-fork-mode child",
          "ignoreFailures": true
        },
        {
          "description": "Enable gdb detach on fork",
          "text": "-gdb-set detach-on-fork on",
          "ignoreFailures": true
        }
```