#!/bin/bash

# Laravel 12 Project Crawler - LLM Ingestible Format Generator
# Modular approach with functions for each component type

# Configuration
PROJECT_ROOT="${1:-.}"
OUTPUT_FILE="${2:-laravel_components_llm.json}"
VERBOSE="${3:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    if [ "$VERBOSE" = "true" ]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Utility function to clean content for JSON
clean_content() {
    local content="$1"
    # Remove control characters and escape special JSON characters
    echo "$content" | tr -d '\000-\031' | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\//\\\//g'
}

# Validation functions
validate_project_root() {
    if [ ! -d "$PROJECT_ROOT" ]; then
        log_error "Project root directory '$PROJECT_ROOT' does not exist"
        exit 1
    fi
    
    if [ ! -f "$PROJECT_ROOT/artisan" ]; then
        log_error "Directory '$PROJECT_ROOT' does not appear to be a Laravel project (artisan not found)"
        exit 1
    fi
    
    log_info "Validated Laravel project at: $PROJECT_ROOT"
}

# Component extraction functions
extract_models() {
    local models_dir="$PROJECT_ROOT/app/Models"
    local models=()
    
    if [ -d "$models_dir" ]; then
        while IFS= read -r -d '' file; do
            local model_name=$(basename "$file" .php)
            local content=$(sed -n '/class /,/^}$/p' "$file" 2>/dev/null | head -50)
            local clean_content=$(clean_content "$content")
            
            models+=("{\"type\":\"Model\",\"name\":\"$model_name\",\"file\":\"$file\",\"content\":\"$clean_content\"}")
        done < <(find "$models_dir" -name "*.php" -type f -print0 2>/dev/null)
    else
        log_warning "Models directory not found: $models_dir"
    fi
    
    printf '%s\n' "${models[@]}"
}

extract_controllers() {
    local controllers_dir="$PROJECT_ROOT/app/Http/Controllers"
    local controllers=()
    
    if [ -d "$controllers_dir" ]; then
        while IFS= read -r -d '' file; do
            local controller_name=$(basename "$file" .php)
            local content=$(sed -n '/class /,/^}$/p' "$file" 2>/dev/null | head -50)
            local clean_content=$(clean_content "$content")
            
            controllers+=("{\"type\":\"Controller\",\"name\":\"$controller_name\",\"file\":\"$file\",\"content\":\"$clean_content\"}")
        done < <(find "$controllers_dir" -name "*.php" -type f -print0 2>/dev/null)
    else
        log_warning "Controllers directory not found: $controllers_dir"
    fi
    
    printf '%s\n' "${controllers[@]}"
}

extract_migrations() {
    local migrations_dir="$PROJECT_ROOT/database/migrations"
    local migrations=()
    
    if [ -d "$migrations_dir" ]; then
        while IFS= read -r -d '' file; do
            local migration_name=$(basename "$file" .php)
            local content=$(sed -n '/class /,/^}$/p' "$file" 2>/dev/null | head -30)
            local clean_content=$(clean_content "$content")
            
            migrations+=("{\"type\":\"Migration\",\"name\":\"$migration_name\",\"file\":\"$file\",\"content\":\"$clean_content\"}")
        done < <(find "$migrations_dir" -name "*.php" -type f -print0 2>/dev/null)
    else
        log_warning "Migrations directory not found: $migrations_dir"
    fi
    
    printf '%s\n' "${migrations[@]}"
}

extract_routes() {
    local routes_file="$PROJECT_ROOT/routes/web.php"
    local api_routes_file="$PROJECT_ROOT/routes/api.php"
    local console_routes_file="$PROJECT_ROOT/routes/console.php"
    local routes=()
    
    extract_route_file() {
        local file="$1"
        local route_type="$2"
        
        if [ -f "$file" ]; then
            local content=$(head -100 "$file" 2>/dev/null)
            local clean_content=$(clean_content "$content")
            
            routes+=("{\"type\":\"Route\",\"name\":\"$route_type\",\"file\":\"$file\",\"content\":\"$clean_content\"}")
        else
            log_warning "Routes file not found: $file"
        fi
    }
    
    extract_route_file "$routes_file" "web"
    extract_route_file "$api_routes_file" "api"
    extract_route_file "$console_routes_file" "console"
    
    printf '%s\n' "${routes[@]}"
}

extract_views() {
    local views_dir="$PROJECT_ROOT/resources/views"
    local views=()
    
    if [ -d "$views_dir" ]; then
        while IFS= read -r -d '' file; do
            local view_name=$(basename "$file")
            local extension="${view_name##*.}"
            local content=$(head -50 "$file" 2>/dev/null)
            local clean_content=$(clean_content "$content")
            
            views+=("{\"type\":\"View\",\"name\":\"$view_name\",\"file\":\"$file\",\"extension\":\"$extension\",\"content\":\"$clean_content\"}")
        done < <(find "$views_dir" -type f \( -name "*.blade.php" -o -name "*.php" -o -name "*.js" -o -name "*.vue" \) -print0 2>/dev/null)
    else
        log_warning "Views directory not found: $views_dir"
    fi
    
    printf '%s\n' "${views[@]}"
}

extract_config() {
    local config_dir="$PROJECT_ROOT/config"
    local configs=()
    
    if [ -d "$config_dir" ]; then
        while IFS= read -r -d '' file; do
            local config_name=$(basename "$file" .php)
            local content=$(head -30 "$file" 2>/dev/null)
            local clean_content=$(clean_content "$content")
            
            configs+=("{\"type\":\"Config\",\"name\":\"$config_name\",\"file\":\"$file\",\"content\":\"$clean_content\"}")
        done < <(find "$config_dir" -name "*.php" -type f -print0 2>/dev/null)
    else
        log_warning "Config directory not found: $config_dir"
    fi
    
    printf '%s\n' "${configs[@]}"
}

extract_env() {
    local env_file="$PROJECT_ROOT/.env"
    local env_example_file="$PROJECT_ROOT/.env.example"
    local envs=()
    
    extract_env_file() {
        local file="$1"
        local env_type="$2"
        
        if [ -f "$file" ]; then
            local content=$(head -50 "$file" 2>/dev/null)
            local clean_content=$(clean_content "$content")
            
            envs+=("{\"type\":\"Environment\",\"name\":\"$env_type\",\"file\":\"$file\",\"content\":\"$clean_content\"}")
        else
            log_warning "Environment file not found: $file"
        fi
    }
    
    extract_env_file "$env_file" "env"
    extract_env_file "$env_example_file" "env_example"
    
    printf '%s\n' "${envs[@]}"
}

# Main extraction function
extract_all_components() {
    log_info "Starting component extraction..."
    
    local components=()
    
    # Extract all component types
    log_info "Extracting models..."
    while IFS= read -r line; do
        [ -n "$line" ] && components+=("$line")
    done < <(extract_models)
    
    log_info "Extracting controllers..."
    while IFS= read -r line; do
        [ -n "$line" ] && components+=("$line")
    done < <(extract_controllers)
    
    log_info "Extracting migrations..."
    while IFS= read -r line; do
        [ -n "$line" ] && components+=("$line")
    done < <(extract_migrations)
    
    log_info "Extracting routes..."
    while IFS= read -r line; do
        [ -n "$line" ] && components+=("$line")
    done < <(extract_routes)
    
    log_info "Extracting views..."
    while IFS= read -r line; do
        [ -n "$line" ] && components+=("$line")
    done < <(extract_views)
    
    log_info "Extracting config files..."
    while IFS= read -r line; do
        [ -n "$line" ] && components+=("$line")
    done < <(extract_config)
    
    log_info "Extracting environment files..."
    while IFS= read -r line; do
        [ -n "$line" ] && components+=("$line")
    done < <(extract_env)
    
    # Create final JSON structure
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local project_name=$(basename "$(realpath "$PROJECT_ROOT")")
    
    # Build the JSON manually to avoid jq parsing issues
    echo "{"
    echo "  \"project\": \"$project_name\","
    echo "  \"timestamp\": \"$timestamp\","
    echo "  \"components\": ["
    
    # Add components with proper formatting
    local first=true
    for component in "${components[@]}"; do
        if [ "$first" = true ]; then
            echo "    $component"
            first=false
        else
            echo "    ,$component"
        fi
    done
    
    echo "  ]"
    echo "}"
}

# Output handling
save_output() {
    local json_data="$1"
    echo "$json_data" > "$OUTPUT_FILE"
    log_success "Output saved to: $OUTPUT_FILE"
}

show_summary() {
    local json_data="$1"
    local project_name=$(echo "$json_data" | grep '"project":' | head -1 | cut -d'"' -f4)
    local component_count=$(echo "$json_data" | grep -o '"type":' | wc -l)
    
    echo ""
    echo "=== EXTRACTION SUMMARY ==="
    echo "Project: $project_name"
    echo "Total components: $component_count"
    echo "Output file: $OUTPUT_FILE"
    echo "=========================="
}

# Main execution flow
main() {
    log_info "Laravel 12 Project Crawler started"
    
    # Validate project structure
    validate_project_root
    
    # Extract all components and capture output
    local json_output=$(extract_all_components)
    
    # Save output
    save_output "$json_output"
    
    # Show summary
    show_summary "$json_output"
    
    log_success "Extraction completed successfully!"
}

# Handle script arguments
show_help() {
    echo "Usage: $0 [PROJECT_ROOT] [OUTPUT_FILE] [VERBOSE]"
    echo ""
    echo "PROJECT_ROOT  : Path to Laravel project (default: current directory)"
    echo "OUTPUT_FILE   : Output JSON file (default: laravel_components_llm.json)"
    echo "VERBOSE       : Show verbose output (true/false, default: false)"
    echo ""
    echo "Example: $0 /path/to/laravel-project project_analysis.json true"
}

# Check for help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# Run main function
main

exit 0