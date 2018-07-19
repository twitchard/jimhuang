# Debug qfs-fuse

1. add following to User_Settings

    "go.testEnvVars": {
        "GOPATH":"${workspaceRoot}"
    },
    "go.gopath": "${workspaceRoot}"

2. mkdir ${workspaceRoot}/src

3. ln -s {all_depe_repo + qfs-fuse} src/{all_dep_repo + qfs-fuse}

4. launch.json
   "program": "${workspaceFolder}",


# Debug qfs-meta

1. cd ${workspaceRoot}/thirdparty/src
   ln -s qfs-meta

2. launch.json
   "program": "${workspaceFolder}/thirdparty/src/qfs_meta/",

3. User_Settings.json
    "go.testEnvVars": {
        "GOPATH":"${workspaceRoot}/thirdparty"
    },
    "go.gopath": "${workspaceRoot}/thirdparty"

# Debug qfs-io (run test)

1. mkdir ${workspaceRoot}/src

2. cd src && ln -s
建立软链接,包含vendor 下所有依赖项目,以及build下面的项目; 最后将qfs-io本身的软连接建立为文件夹qfs_io

3. luanch.json
    {
      "name": "Launch test function",
      "type": "go",
      "request": "launch",
      "mode": "test",
      "program": "${workspaceRoot}/src/qfs_io/lib/assert_test.go",
      "args": [
        "-test.run",
        "-test.v",
        "TestAssert"
      ]
    },

4. User settings.json

    "go.testEnvVars": {
        "GOPATH":"${workspaceRoot}"
    },
    "go.gopath": "${workspaceRoot}"