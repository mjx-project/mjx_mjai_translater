clear:
	echo "clear"

build:
	echo "build"

tests:
	echo "tests"

protos:
	grpc_tools_ruby_protoc -I mjx --ruby_out=lib --grpc_out=lib mjx/mjx.proto

.PHONY: clear build tests protos
