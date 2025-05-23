# Ref: https://www.digitalocean.com/community/tutorials/using-ldflags-to-set-version-information-for-go-applications

BUILD_FLAGS=-X 'main.GitCommitHash=`git rev-parse --short HEAD`' -X 'main.BuiltAt=`date +%FT%T%z`' -X 'main.Version=`git describe --tags`'
BUILD_WIN=@env GOOS=windows GOARCH=amd64 go build -o privateer-windows.exe
BUILD_LINUX=@env GOOS=linux GOARCH=amd64 go build -o privateer-linux
BUILD_MAC=@env GOOS=darwin GOARCH=amd64 go build -o privateer-darwin

binary: tidy test build
quick: build
testcov: test test-cov
release: tidy test release-nix release-win release-mac

build:
	@echo "  >  Building binary ..."
	go build -o privateer -ldflags="$(BUILD_FLAGS)"

test:
	@echo "  >  Validating code ..."
	@go vet ./...
	@go test ./...

tidy:
	@echo "  >  Tidying go.mod ..."
	@go mod tidy

test-cov:
	@echo "Running tests and generating coverage output ..."
	@go test ./... -coverprofile coverage.out -covermode count
	@sleep 2 # Sleeping to allow for coverage.out file to get generated
	@echo "Current test coverage : $(shell go tool cover -func=coverage.out | grep total | grep -Eo '[0-9]+\.[0-9]+') %"

release-candidate: tidy test
	@echo "  >  Building release candidate for Linux..."
	$(BUILD_LINUX) -ldflags="$(BUILD_FLAGS) -X 'main.VersionPostfix=nix-rc'"
	@echo "  >  Building release candidate for Windows..."
	$(BUILD_WIN) -ldflags="$(BUILD_FLAGS) -X 'main.VersionPostfix=win-rc'"
	@echo "  >  Building release for Darwin..."
	$(BUILD_MAC) -ldflags="$(BUILD_FLAGS) -X 'main.VersionPostfix=darwin'"

release-nix:
	@echo "  >  Building release for Linux..."
	$(BUILD_LINUX) -ldflags="$(BUILD_FLAGS) -X 'main.VersionPostfix=linux'"

release-win:
	@echo "  >  Building release for Windows..."
	$(BUILD_WIN) -ldflags="$(BUILD_FLAGS) -X 'main.VersionPostfix=windows'"

release-mac:
	@echo "  >  Building release for Darwin..."
	$(BUILD_MAC) -ldflags="$(BUILD_FLAGS) -X 'main.VersionPostfix=darwin'"

todo:
	@read -p "Write your todo here: " TODO; \
	echo "- [ ] $$TODO" >> TODO.md
