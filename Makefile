
.PHONY: vendor

vendor: 
	npm install
	cp node_modules/jquery/dist/jquery.min.js www/lib/
	cp node_modules/lunr/lunr.min.js www/lib/
	cp node_modules/react-dom-factories/index.js www/lib/react-dom-factories.js
	cp node_modules/react-dom/umd/react-dom.production.min.js www/lib/
	cp node_modules/react/umd/react.production.min.js www/lib/

