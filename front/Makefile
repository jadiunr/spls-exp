FIG = docker-compose
RUN = $(FIG) run --rm web

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
	@$(FIG) exec web  ash

# ログ確認
log:
	@$(FIG) logs web
logf:
	@$(FIG) logs -f web

# Yarnコマンド
y:
	@$(RUN) yarn

# Permission変更(*DANGER*)
chown:
	@chown -R $(SUDO_USER):$(SUDO_USER) .
