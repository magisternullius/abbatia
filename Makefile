PANDOC = pandoc
SECTIONS = scriptorium bibliotheca hortus refectorium oratorium
SRC_DIR = _tabellae
TPL_DIR = _exemplaria

.PHONY: site clean

site:
	@for section in $(SECTIONS); do \
		echo "Conficitur pars $$section …"; \
		mkdir -p $$section/opera; \
		find $(SRC_DIR)/$$section -name '*.md' | sort | while read file; do \
			base=$$(basename $$file .md); \
			$(PANDOC) $$file --from markdown --to html5 --template=$(TPL_DIR)/$$section/scriptum.html --output=$$section/opera/$$base.html; \
		done; \
		echo "---" > $$section/index-tmp.md; \
		echo "years:" >> $$section/index-tmp.md; \
		for year in $$(find $(SRC_DIR)/$$section -type f -name '*.md' | sed -E 's#.*/([0-9]{4})/.*#\1#' | sort -u); do \
			ad=$$(roman $$year); \
			echo "  - roman_year: \"$$ad\"" >> $$section/index-tmp.md; \
			echo "    entries:" >> $$section/index-tmp.md; \
			find $(SRC_DIR)/$$section/$$year -name '*.md' | sort | while read file; do \
				base=$$(basename $$file .md); \
				title=$$(head -n 1 $$file | sed 's/^% //'); \
				date=$$(head -n 3 $$file | tail -n 1 | sed 's/^% //'); \
				echo "      - title: \"$$title\"" >> $$section/index-tmp.md; \
				echo "        url: \"$$year/$$base.html\"" >> $$section/index-tmp.md; \
				echo "        monastic_date: \"$$date\"" >> $$section/index-tmp.md; \
			done; \
		done; \
		echo "---" >> $$section/index-tmp.md; \
		$(PANDOC) $$section/index-tmp.md --template=$(TPL_DIR)/$$section/index.html --output=$$section/index.html; \
		rm $$section/index-tmp.md; \
	done

clean:
	@echo "Documenta generata eliminantur …"
	@for section in $(SECTIONS); do \
		rm -fr $$section; \
	done
