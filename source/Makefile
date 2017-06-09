.PHONY: tags lint run
.PHONY: always-rebuild

run:
	love .

tags: always-rebuild
	ctags -R --extra=+q --languages=lua

lint:
	luacheck .
