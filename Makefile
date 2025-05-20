PANDOC = pandoc
SITE_URL = https://abbatia.aquinas.lol
SECTIONS = scriptorium bibliotheca hortus refectorium oratorium
SRC_DIR = _tabellae
TPL_DIR = _exemplaria
SITE_DIR= docs
METADATA=--metadata-file=$(TPL_DIR)/metadata.yaml

.PHONY: munda exscribe itinerarium publica

munda:
	@echo "Documenta generata eliminantur …"
	@for section in $(SECTIONS); do \
		rm -fr $(SITE_DIR)/$$section; \
	done

exscribe: munda
	@for section in $(SECTIONS); do \
		echo "Conficitur pars $$section …"; \
		mkdir -p $(SITE_DIR)/$$section/opera; \
		find $(SRC_DIR)/$$section -name '*.md' | sort | while read file; do \
			base=$$(basename $$file .md); \
			$(PANDOC) $$file --from markdown --to html5 --template=$(TPL_DIR)/$$section/scriptum.html $(METADATA) --output=$(SITE_DIR)/$$section/opera/$$base.html; \
		done; \
		echo "---" > $(SITE_DIR)/$$section/index-tmp.md; \
		echo "years:" >> $(SITE_DIR)/$$section/index-tmp.md; \
		for year in $$(find $(SRC_DIR)/$$section -type f -name '*.md' | sed -E 's#.*/([0-9]{4})/.*#\1#' | sort -u); do \
			ad=$$(roman $$year); \
			echo "  - roman_year: \"$$ad\"" >> $(SITE_DIR)/$$section/index-tmp.md; \
			echo "    entries:" >> $(SITE_DIR)/$$section/index-tmp.md; \
			find $(SRC_DIR)/$$section/$$year -name '*.md' | sort | while read file; do \
				base=$$(basename $$file .md); \
				title=$$(grep '^title:' $$file | sed 's/title:[[:space:]]*//'); \
				title2=$$(grep '^subtitle:' $$file | sed 's/subtitle:[[:space:]]*//'); \
				date=$$(grep '^monastic_date:' $$file | sed 's/monastic_date:[[:space:]]*//'); \
				echo "      - title: \"$$title\"" >> $(SITE_DIR)/$$section/index-tmp.md; \
				echo "        title2: \"$$title2\"" >> $(SITE_DIR)/$$section/index-tmp.md; \
				echo "        url: \"$$base.html\"" >> $(SITE_DIR)/$$section/index-tmp.md; \
				echo "        monastic_date: \"$$date\"" >> $(SITE_DIR)/$$section/index-tmp.md; \
			done; \
		done; \
		echo "---" >> $(SITE_DIR)/$$section/index-tmp.md; \
		$(PANDOC) $(SITE_DIR)/$$section/index-tmp.md --template=$(TPL_DIR)/$$section/index.html $(METADATA) --output=$(SITE_DIR)/$$section/index.html; \
		rm $(SITE_DIR)/$$section/index-tmp.md; \
	done

itinerarium:
	@echo "Generatur sitemap.xml …"
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(SITE_DIR)/sitemap.xml
	@echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' >> $(SITE_DIR)/sitemap.xml
	@echo '  <url><loc>$(SITE_URL)/</loc><changefreq>monthly</changefreq><priority>1.0</priority></url>' >> $(SITE_DIR)/sitemap.xml
	@find $(SITE_DIR) -name '*.html' | sort | while read file; do \
		rel_path=$${file#$(SITE_DIR)/}; \
		if echo "$$rel_path" | grep -q '/index.html$$'; then \
			url=$(SITE_URL)/$$(dirname $$rel_path)/; \
		else \
			url=$(SITE_URL)/$$rel_path; \
		fi; \
		filename=$$(basename $$file); \
		if echo $$filename | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}'; then \
			date=$$(echo $$filename | sed -E 's/^([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1/'); \
			if echo $$file | grep -q '/index.html$$'; then \
				priority=1.0; \
			else \
				priority=0.7; \
			fi; \
			if echo $$file | grep -q '/index.html$$'; then \
			  echo "  <url><loc>$$url</loc><lastmod>$$date</lastmod><changefreq>monthly</changefreq><priority>$$priority</priority></url>" >> $(SITE_DIR)/sitemap.xml; \
			else \
			  echo "  <url><loc>$$url</loc><lastmod>$$date</lastmod><priority>$$priority</priority></url>" >> $(SITE_DIR)/sitemap.xml; \
			fi; \
		else \
			if echo $$file | grep -q '/index.html$$'; then \
				priority=1.0; \
			else \
				priority=0.7; \
			fi; \
			if echo $$file | grep -q '/index.html$$'; then \
			  echo "  <url><loc>$$url</loc><changefreq>monthly</changefreq><priority>$$priority</priority></url>" >> $(SITE_DIR)/sitemap.xml; \
			else \
			  echo "  <url><loc>$$url</loc><priority>$$priority</priority></url>" >> $(SITE_DIR)/sitemap.xml; \
			fi; \
		fi; \
	done
	@echo '</urlset>' >> $(SITE_DIR)/sitemap.xml

publica: exscribe itinerarium
