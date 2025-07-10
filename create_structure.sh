#!/bin/bash

# Create the complete directory structure for Flutter Enterprise App

# Core directories
mkdir -p lib/core/dependency_injection
mkdir -p lib/core/errors
mkdir -p lib/core/routing
mkdir -p lib/core/services
mkdir -p lib/core/utils
mkdir -p lib/core/widgets

# Features directories
mkdir -p lib/features/auth/{models,repository,view/{screens,widgets},view_model/{api_config_cubit,login}}
mkdir -p lib/features/chargement/{models,repository,view/{screens,widgets},view_model/chargement}
mkdir -p lib/features/home/{models,repositories,view/{screens,widgets},view_model}
mkdir -p lib/features/movement/{model,repository,view/{screens,widgets},view_model/movement}
mkdir -p lib/features/packing/{functions,models,repository,view/{screens,widgets},view_model/{packing,printing_cubit}}
mkdir -p lib/features/printing/view/{screens,widgets}
mkdir -p lib/features/rh/{model,repository,view/{screens,widgets},view_model/affectation}

# Leansoft Flutter Core directories
mkdir -p lib/leansoft_flutter_core/{crashlytics,functions,helpers,utils,widgets}

echo "Directory structure created successfully!"
echo "Run this script from your Flutter project root directory."
echo "After running this script, you'll need to create the individual Dart files."
