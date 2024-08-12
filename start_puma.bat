@echo off
cd /d C:\Users\tchib\vscode\GushikawaDomeRes
set RAILS_ENV=production
bundle exec puma -C config/puma.rb
