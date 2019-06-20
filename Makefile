.DEFAULT_GOAL := help

.PHONY: build-js build-js-min test lint check install-linters format fix-skycoin-dep help
.PHONY: test-js

build-js: ## Build /skycoin/skycoin.go. The result is saved in the repo root
	go build -o gopherjs-tool vendor/github.com/gopherjs/gopherjs/tool.go
	GOOS=linux ./gopherjs-tool build skycoin/skycoin.go

build-js-min: ## Build /skycoin/skycoin.go. The result is minified and saved in the repo root
	go build -o gopherjs-tool vendor/github.com/gopherjs/gopherjs/tool.go
	GOOS=linux ./gopherjs-tool build skycoin/skycoin.go -m

build-wasm: ## Build /wasm/skycoin.go. The result is saved in the repo root as skycoin-lite.wasm
	GOOS=js GOARCH=wasm go build -o skycoin-lite.wasm ./wasm/skycoin.go

test-js: ## Run the Go tests using JavaScript
	go build -o gopherjs-tool vendor/github.com/gopherjs/gopherjs/tool.go
	./gopherjs-tool test ./skycoin/ -v

test-suite-ts: ## Run the ts version of the cipher test suite for GopherJS. Use a small number of test cases
	npm run test

test-suite-ts-extensive: ## Run the ts version of the cipher test suite for GopherJS. All the test cases
	npm run test-extensive

test-suite-ts-wasm: ## Run the ts version of the cipher test suite for wasm
	npm run test-wasm

test:
	go test ./... -timeout=10m -cover

lint: ## Run linters. Use make install-linters first.
	vendorcheck ./...
	gometalinter --disable-all -E goimports --tests --vendor ./...

check: lint test ## Run tests and linters

install-linters: ## Install linters
	go get -u github.com/FiloSottile/vendorcheck
	go get -u github.com/alecthomas/gometalinter
	gometalinter --vendored-linters --install

format: ## Formats the code. Must have goimports installed (use make install-linters).
	goimports -w ./skycoin
	goimports -w ./liteclient
	goimports -w ./mobile

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
