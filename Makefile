PANDOC = pandoc
SECTIONS = scriptorium bibliotheca hortus refectorium oratorium
SRC_DIR = _tabellae
TPL_DIR = _exemplaria
SITE_DIR= docs

.PHONY: site clean

site: clean
	@for section in $(SECTIONS); do \
		echo "Conficitur pars $$section …"; \
		mkdir -p $(SITE_DIR)/$$section/opera; \
		find $(SRC_DIR)/$$section -name '*.md' | sort | while read file; do \
			base=$$(basename $$file .md); \
			$(PANDOC) $$file --from markdown --to html5 --template=$(TPL_DIR)/$$section/scriptum.html --output=$(SITE_DIR)/$$section/opera/$$base.html; \
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
		$(PANDOC) $(SITE_DIR)/$$section/index-tmp.md --template=$(TPL_DIR)/$$section/index.html --output=$(SITE_DIR)/$$section/index.html; \
		rm $(SITE_DIR)/$$section/index-tmp.md; \
	done

clean:
	@echo "Documenta generata eliminantur …"
	@for section in $(SECTIONS); do \
		rm -fr $(SITE_DIR)/$$section; \
	done
