.PHONY: build clean

SKILL_NAME := graphql-federation
SKILL_FILE := $(SKILL_NAME).skill
BUILD_DIR := .build/$(SKILL_NAME)

# Source files
SKILL_SOURCES := \
	SKILL.md \
	references/directives.md \
	references/composition-rules.md \
	references/patterns.md

build: $(SKILL_FILE)

$(SKILL_FILE): $(SKILL_SOURCES)
	@echo "Building $(SKILL_FILE)..."
	@rm -rf .build $(SKILL_FILE)
	@mkdir -p $(BUILD_DIR)/references
	@cp SKILL.md $(BUILD_DIR)/
	@cp references/*.md $(BUILD_DIR)/references/
	@cd .build && zip -r ../$(SKILL_FILE) $(SKILL_NAME)
	@rm -rf .build
	@echo "Done: $(SKILL_FILE)"

clean:
	@rm -rf .build $(SKILL_FILE)
	@echo "Cleaned $(SKILL_FILE)"