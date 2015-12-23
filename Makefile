# the bnfc-generated output dir
GEN_DIR=gen-hs
# the bnfc-generated haskell files prepended namespace
GEN_NS=BNFC_Gen

# regenerates the Haskell-written ABS-lexer&ABS-parser 
generate:
	-mkdir gen-hs
	bnfc --haskell ABS.cf -p ${GEN_NS} -o ${GEN_DIR}
	happy -gca ${GEN_DIR}/${GEN_NS}/ParABS.y
	alex -g ${GEN_DIR}/${GEN_NS}/LexABS.x
	-rm ${GEN_DIR}/${GEN_NS}/{LexABS.x,ParABS.y,TestABS.hs,SkelABS.hs,*.bak}
	-mkdir doc
	mv ${GEN_DIR}/${GEN_NS}/DocABS.txt doc/
	sed -i -e 's/deriving (Eq, Ord, /deriving (/' ${GEN_DIR}/${GEN_NS}/AbsABS.hs # remove Eq,Ord generated instances

doc:
	txt2tags -t html --toc doc/DocABS.txt

clean:
	-rm -r gen-hs doc dist

.PHONY: generate clean doc
