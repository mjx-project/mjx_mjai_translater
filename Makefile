clear:
	echo "clear"

build:
	echo "build"

tests:
	echo "tests"

protos:
	grpc_tools_ruby_protoc -I mjx --ruby_out=lib/mjxproto --grpc_out=lib/mjxproto mjx/mjx.proto

.PHONY: clear build tests protos
