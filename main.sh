#!/bin/sh

version="<VERSION>"

# Arguments

config_file=$(pwd)/.codecover
language=""
test_dir=""
filter=""
exclude_files=""
skip_build=false # only for csharp

usage() {
    echo "Usage: sh $0 (--csharp|--python) --test-dir <directory> [--filter <filter>] [--exclude-files <file1,file2,...>] [--skip-build] [-h|--help] [-v|--version]"
    echo "    --csharp           Use for csharp projects"
    echo "    --python           Use for python projects"
    echo "    --test-dir         Directory containing the test files"
    echo "    --filter           Filter for the test files (optional)"
    echo "    --exclude-files    Comma separated list of files to exclude (optional)"
    echo "    --skip-build       Skip building the project (only for csharp)"
    echo "    -h, --help         Display this help and exit"
    echo "    -v, --version      Display version information and exit"
}

# Check if the config file exists and source it
if [ -f "$config_file" ]; then
    source "$config_file"
fi

rel_test_dir=$test_dir

if [ $# -gt 0 ]; then
    # Parse arguments
    while (( "$#" )); do
    case "$1" in
        --csharp)
            language="csharp"
            shift
            ;;
        --python)
            language="python"
            shift
            ;;
        --test-dir)
            test_dir="$2"
            rel_test_dir="$2"
            shift 2
            ;;
        --filter)
            filter="$2"
            shift 2
            ;;
        --exclude-files)
            exclude_files="$2"
            shift 2
            ;;
        --skip-build)
            skip_build=true
            shift
            ;;
        --help | -h)
            usage
            exit 0
            ;;
        --version | -v)
            echo "v$version"
            exit 0
            ;;
        *)
            # Print invalid argument
            echo "\033[31mInvalid argument\033[0m: $1"
            usage
            exit 1
            ;;
    esac
    done
fi

# Validate required arguments

if [ "$language" = "" ]; then
    echo "\033[31mNo language specified\033[0m"
    usage
    exit 1
fi

if [ "$test_dir" = "" ]; then
    echo "\033[31mNo test directory specified\033[0m"
    usage
    exit 1
fi

# Make test_dir absolute
test_dir=$(realpath $test_dir 2> /dev/null)

# Check if the test directory exists
if [ ! -d "$test_dir" ]; then
    echo "\033[31mTest directory not found\033[0m"
    exit 1
fi

# Save the parameters to lcov.config
echo "language=\"$language\"" > "$config_file"
echo "test_dir=\"$rel_test_dir\"" >> "$config_file"
echo "filter=\"$filter\"" >> "$config_file"
echo "exclude_files=\"$exclude_files\"" >> "$config_file"
if [ "$language" = "csharp" ]; then
    echo "skip_build=$skip_build" >> "$config_file"
fi

# Print arguments
echo "Language\t\033[34m$language\033[0m"
echo "Test Directory\t\033[34m$test_dir\033[0m"
echo "Filter\t\t\033[34m$filter\033[0m"
echo "Exclude Files\t\033[34m$exclude_files\033[0m"
if [ "$language" = "csharp" ]; then
    echo "Skip Build\t\033[34m$skip_build\033[0m"
fi

if [ "$language" = "python" ]; then
    
    # Check if virtual env exists
    if [ ! -d "venv" ]; then
        echo "\033[31mVirtual environment not found\033[0m"
        exit 1
    fi

    source venv/bin/activate > /dev/null

    pip install coverage > /dev/null

    coverage run --omit $test_dir/*,*__init__.py,$exclude_files -m unittest discover -s $test_dir -v

    # Run reports only if tests pass
    if [ $? -eq 0 ]; then
        echo "\033[32mTests passed\033[0m"
        coverage lcov -o lcov.info
        coverage report
    else
        echo "\033[31mTests failed\033[0m"
    fi

    pip uninstall --yes coverage > /dev/null

elif [ "$language" = "csharp" ]; then

############################################################
# VALIDATE .NET PROJECT

    # Check if it is a csharp solution
    solution=$(find . -name "*.sln")

    if [ "$solution" = "" ]; then
        echo "\033[31mSolution file not found\033[0m"
        exit 1
    fi

    # Check if it is csharp and the project folder exists
    if [ "$language" = "csharp" ]; then
        if [ "$test_dir" = "" ]; then
            echo "\033[31mProject folder not found\033[0m"
            exit 1
        fi
    fi

############################################################
# INSTALL DEPENDENCIES

    # Check if reportgenerator is installed (using dotnet tool list -g)

    if ! dotnet tool list -g | grep -q "reportgenerator"; then
        # Install reportgenerator (used to merge coverage reports) 

        dotnet tool install -g dotnet-reportgenerator-globaltool

        # Check if installation was successful
        if [ $? -ne 0 ]; then
            echo "\033[31mError installing reportgenerator\033[0m"
            exit 1
        fi
    fi

    # Get all test projects and install coverlet.collector and coverlet.msbuild if not installed on each project
    test_prj=$(find $test_dir -name "*.csproj")
    
    dotnet restore

    # Check if restore failed
    if [ $? -ne 0 ]; then
        echo "\033[31mError restoring packages\033[0m"
        exit 1
    fi

    collector=0
    msbuild=0
    idx=1
    for prj in $test_prj; do
        nugetList=$(dotnet list $prj package)

        if echo "$nugetList" | grep -q "coverlet.collector"; then
            collector=$((collector | idx))
            echo "\033[32mcoverlet.collector\033[0m already installed in \033[32m$prj\033[0m."
        else
            echo "Installing \033[34mcoverlet.collector\033[0m in \033[34m$prj\033[0m. It will be removed after the report is generated."
            dotnet add $prj package coverlet.collector > /dev/null

            # Check if the package is installed and retry with --interactive if it fails
            if [ $? -ne 0 ]; then
                dotnet add $prj package coverlet.collector --interactive

                # Exit if the package is not installed
                if [ $? -ne 0 ]; then
                    echo "\033[31mError installing coverlet.collector\033[0m"
                    exit 1
                fi
            fi
        fi

        if echo "$nugetList" | grep -q "coverlet.msbuild"; then
            msbuild=$((msbuild | idx))
            echo "\033[32mcoverlet.msbuild\033[0m already installed in \033[32m$prj\033[0m."
        else
            echo "Installing \033[34mcoverlet.msbuild\033[0m in \033[34m$prj\033[0m. It will be removed after the report is generated."
            dotnet add $prj package coverlet.msbuild > /dev/null

            # Check if the package is installed and retry with --interactive if it fails
            if [ $? -ne 0 ]; then
                dotnet add $prj package coverlet.msbuild --interactive

                # Exit if the package is not installed
                if [ $? -ne 0 ]; then
                    echo "\033[31mError installing coverlet.msbuild\033[0m"
                    exit 1
                fi
            fi
        fi

        idx=$((idx << 1))
        
    done

############################################################
# BUILD AND TEST
    build_pass=1

    if [ "$skip_build" = false ]; then
        dotnet clean --configuration Release --verbosity quiet # --verbosity can be quiet, minimal, normal, detailed, and diagnostic
        dotnet build $solution --configuration Release --verbosity quiet

        # Exit if the build failed
        if [ $? -ne 0 ]; then
            echo "\033[31mBuild failed\033[0m"
            build_pass=0
        fi
    fi

    if [ $build_pass -eq 1 ]; then

        test_reports="tmp_cov/report.xml"

        test_pass=1

        dotnet test --no-build $solution --filter "$filter" --configuration Release --verbosity minimal /p:CollectCoverage=true /p:CoverletOutputFormat=opencover /p:CoverletOutput="./$test_reports" /p:ExcludeByFile=\"$exclude_files\"

        # Check if the tests fail and print the reason
        if [ $? -ne 0 ]; then
            echo "\033[31mTests failed\033[0m"
            test_pass=0
        fi

    ############################################################
    # GENERATE REPORT IN LCOV FORMAT

        if [ $test_pass -eq 1 ]; then
            # Merge all coverage reports with reportgenerator

            reportgenerator -reports:"**/$test_reports" -targetdir:. -reporttypes:lcov

            # Check if the report is generated
            if [ $? -ne 0 ]; then
                echo "\033[31mError generating report\033[0m"
            else
                echo "\033[32mCoverage report generated\033[0m"
            fi
        fi
    fi

    ############################################################
    # CLEAN UP

    idx=1
    for prj in $test_prj; do
        if [ $((collector & idx)) -eq 0 ]; then
            echo "Removing \033[34mcoverlet.collector\033[0m from \033[34m$prj\033[0m"
            dotnet remove $prj package coverlet.collector > /dev/null
        fi

        if [ $((msbuild & idx)) -eq 0 ]; then
            echo "Removing \033[34mcoverlet.msbuild\033[0m from \033[34m$prj\033[0m"
            dotnet remove $prj package coverlet.msbuild > /dev/null
        fi

        idx=$((idx << 1))
    done

    find . -type d -name 'tmp_cov' -exec rm -rf {} +

fi