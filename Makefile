FIG = docker-compose
RAILS = $(FIG) exec app bin/rails

# コンテナ操作コマンド等
build:
	@$(FIG) build
up:
	@$(FIG) up -d
down:
	@$(FIG) down
restart:
	@$(FIG) stop
	@$(FIG) start
clean:
	@docker image prune
	@docker volume prune

# Shellに入るやつ
sh:
	@$(FIG) exec app ash

# ログ確認
log:
	@$(FIG) logs app
logf:
	@$(FIG) logs -f app

# railsコマンド
rc:
	@$(RAILS) console
rr:
	@$(RAILS) routes
rs:
	@$(RAILS) spec

# rails dbコマンド
dbc:
	@$(RAILS) db:create
dbm:
	@$(RAILS) db:migrate
dbs:
	@$(RAILS) db:seed
dbd:
	@$(RAILS) db:drop

# Bundleコマンド
bi:
	@$(FIG) exec app bundle install -j3 --path vendor/bundle
br:
	@$(FIG) exec app gem uninstall -aIx
	@make bi

# Permission変更(*DANGER*)
chown:
	@chown -R $(SUDO_USER):$(SUDO_USER) .
