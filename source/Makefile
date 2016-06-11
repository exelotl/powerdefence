.PHONY: tags lint run
.PHONY: always-rebuild

run:
	love source/

tags: always-rebuild
	ctags -R --extra=+q --languages=lua

lint:
	luacheck .
