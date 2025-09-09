# Makefile for HiraganaMatchingGame
# Swift/iOS development automation

# Variables
PROJECT_PATH = app/HiraganaMatchingGame.xcodeproj
SCHEME = HiraganaMatchingGame
DEVICE = 'platform=iOS Simulator,name=iPhone 15,OS=18.5'

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m  
YELLOW = \033[1;33m
NC = \033[0m # No Color

.PHONY: help setup format lint build test clean install-tools

# Default target
help: ## Show this help message
	@echo "$(GREEN)HiraganaMatchingGame Development Commands$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: install-tools ## Setup development environment
	@echo "$(GREEN)Setting up development environment...$(NC)"
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit install; \
		echo "$(GREEN)✅ Pre-commit hooks installed$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  pre-commit not found. Install with: brew install pre-commit$(NC)"; \
	fi

install-tools: ## Install required development tools
	@echo "$(GREEN)Installing development tools...$(NC)"
	@echo "Checking Homebrew..."
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "$(RED)❌ Homebrew not found. Please install from https://brew.sh$(NC)"; \
		exit 1; \
	fi
	@echo "Installing SwiftLint..."
	@if ! command -v swiftlint >/dev/null 2>&1; then \
		brew install swiftlint; \
	else \
		echo "$(GREEN)✅ SwiftLint already installed$(NC)"; \
	fi
	@echo "Installing SwiftFormat..."
	@if ! command -v swiftformat >/dev/null 2>&1; then \
		brew install swiftformat; \
	else \
		echo "$(GREEN)✅ SwiftFormat already installed$(NC)"; \
	fi
	@echo "$(GREEN)✅ All tools installed$(NC)"

format: ## Format code with SwiftFormat
	@echo "$(GREEN)Formatting Swift code...$(NC)"
	@if command -v swiftformat >/dev/null 2>&1; then \
		swiftformat .; \
		echo "$(GREEN)✅ Code formatted$(NC)"; \
	else \
		echo "$(RED)❌ SwiftFormat not found. Run 'make install-tools'$(NC)"; \
		exit 1; \
	fi

lint: ## Run SwiftLint
	@echo "$(GREEN)Running SwiftLint...$(NC)"
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint; \
		echo "$(GREEN)✅ Linting completed$(NC)"; \
	else \
		echo "$(RED)❌ SwiftLint not found. Run 'make install-tools'$(NC)"; \
		exit 1; \
	fi

lint-fix: ## Auto-fix SwiftLint violations where possible
	@echo "$(GREEN)Auto-fixing SwiftLint violations...$(NC)"
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint --fix; \
		echo "$(GREEN)✅ Auto-fix completed$(NC)"; \
	else \
		echo "$(RED)❌ SwiftLint not found. Run 'make install-tools'$(NC)"; \
		exit 1; \
	fi

format-check: ## Check formatting without making changes
	@echo "$(GREEN)Checking code formatting...$(NC)"
	@if command -v swiftformat >/dev/null 2>&1; then \
		swiftformat --lint .; \
		echo "$(GREEN)✅ Format check completed$(NC)"; \
	else \
		echo "$(RED)❌ SwiftFormat not found. Run 'make install-tools'$(NC)"; \
		exit 1; \
	fi

quality: format lint ## Run all code quality checks and fixes

build: ## Build the project
	@echo "$(GREEN)Building project...$(NC)"
	@cd app && xcodebuild clean build \
		-scheme $(SCHEME) \
		-destination $(DEVICE) \
		-quiet
	@echo "$(GREEN)✅ Build completed$(NC)"

test: ## Run unit tests
	@echo "$(GREEN)Running tests...$(NC)"
	@cd app && xcodebuild test \
		-scheme $(SCHEME) \
		-destination $(DEVICE) \
		-quiet
	@echo "$(GREEN)✅ Tests completed$(NC)"

build-release: ## Build for release
	@echo "$(GREEN)Building release version...$(NC)"
	@cd app && xcodebuild clean build \
		-scheme $(SCHEME) \
		-configuration Release \
		-destination $(DEVICE) \
		-quiet
	@echo "$(GREEN)✅ Release build completed$(NC)"

clean: ## Clean build artifacts
	@echo "$(GREEN)Cleaning build artifacts...$(NC)"
	@cd app && xcodebuild clean \
		-scheme $(SCHEME) \
		-quiet
	@rm -rf app/build
	@echo "$(GREEN)✅ Clean completed$(NC)"

archive: ## Create archive for distribution
	@echo "$(GREEN)Creating archive...$(NC)"
	@cd app && xcodebuild archive \
		-scheme $(SCHEME) \
		-archivePath build/HiraganaMatchingGame.xcarchive \
		-quiet
	@echo "$(GREEN)✅ Archive created$(NC)"

ci-check: format-check lint build test ## Run all CI checks locally

pre-commit: ## Run pre-commit hooks manually
	@echo "$(GREEN)Running pre-commit hooks...$(NC)"
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit run --all-files; \
		echo "$(GREEN)✅ Pre-commit checks completed$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  pre-commit not found. Running manual checks...$(NC)"; \
		make quality build; \
	fi

dev-check: ## Quick development check (format + lint only)
	@make format lint

# Git helpers
git-clean: ## Remove untracked files (use with caution)
	@echo "$(YELLOW)⚠️  This will remove all untracked files. Continue? [y/N]$(NC)" && read ans && [ $${ans:-N} = y ]
	git clean -fdx --exclude=.env*

# Version and info
version: ## Show tool versions
	@echo "$(GREEN)Development Tool Versions:$(NC)"
	@echo "Xcode: $$(xcode-select -p 2>/dev/null && xcodebuild -version | head -1 || echo 'Not found')"
	@echo "SwiftLint: $$(swiftlint version 2>/dev/null || echo 'Not installed')"  
	@echo "SwiftFormat: $$(swiftformat --version 2>/dev/null || echo 'Not installed')"
	@echo "Pre-commit: $$(pre-commit --version 2>/dev/null || echo 'Not installed')"

# Documentation
docs: ## Generate documentation
	@echo "$(GREEN)This project uses inline documentation.$(NC)"
	@echo "See XCODE_INTEGRATION.md for setup instructions."
	@echo "See .swiftlint.yml for linting rules."
	@echo "See .swiftformat for formatting rules."

# Quick shortcuts
f: format ## Shortcut for format
l: lint ## Shortcut for lint  
b: build ## Shortcut for build
t: test ## Shortcut for test
q: quality ## Shortcut for quality