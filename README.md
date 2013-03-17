# Capistrano Recipes

Simple capistrano recipes for single server deployment.

Add capistrano_recipes as git submodule

    $ git submodule add git://github.com/steverandy/capistrano_recipes.git vendor/capistrano_recipes

Load recipes from Capfile

    load "vendor/capistrano_recipes/base"
    load "vendor/capistrano_recipes/unicorn"
    load "vendor/capistrano_recipes/remote"
