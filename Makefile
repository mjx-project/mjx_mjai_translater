clear:
	rm -rf mjx_mjai_translater/lib/*

build:
	echo "build"

tests:
	echo "tests"

protos:
	grpc_tools_ruby_protoc -I mjx --ruby_out=mjx_mjai_translater/lib --grpc_out=mjx_mjai_translater/lib mjx/mjx.proto

.PHONY: clear build tests protos
