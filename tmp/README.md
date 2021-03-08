# mjx-mjai-translater

## `RandomAgent` の実行の仕方

必要なprotocol bufferのファイルを生成して、ランダムなエージェントのgRPCサーバをruby側で起動する

```
$ make protos
$ ruby mjx_mjai-translater/random_agent.rb
```

mjxをコンパイルして、ゲームを実行するgRPCクライアントをC++側で実行する（これは速度ベンチマーク用のスクリプト）

```
$ cd mjx && make build
$ ./mjx/build/scripts/speed_benchmark -client 256 16
```
