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
	sed -i -e 's/deriving (Eq, Ord, /deriving (/' ${GEN_DIR}/${GEN_NS}/AbsABS.hs # remove Eq,Ord generated instances

doc:
	txt2tags -t html --toc ${GEN_DIR}/${GEN_NS}/DocABS.txt
	@echo "BNF documentation generated at ${GEN_DIR}/${GEN_NS}/DocABS.html"

clean:
	-rm -r gen-hs dist

.PHONY: generate clean doc
