# Release Notes for Capistrano Craft

## 0.3.5 - 2021-10-28

- Use `db/backup` instead of deprecated `backup/db` command

## 0.3.4 - 2021-10-28

- Separate out asset sync into two sub-commands push and pull.

## 0.3.0 - 2020-08-13

- Better compatibility with Craft 3.5
- Project config automatically applied after deployment. A backup command is executed first as an insurance against database corruption
