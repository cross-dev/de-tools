all :
	@echo Everything is built already. Proceed with check or install

check :
	@find tests -name '*.bats' | xargs bats

install :
	@install -dm755 ${DESTDIR}/usr/bin
	@install -m755 env2h ${DESTDIR}/usr/bin/env2h
