# SPLS Exp

WebRTC Scalable Peer to Peer Live Streaming Experimentation

## Getting started

```
cp .env.dev.sample .env.dev
docker-compose build
docker-compose run --rm app bundle install
docker-compose run --rm app bundle exec rails db:setup
docker-compose run --rm web yarn
docker-compose up -d
```

- `http://localhost:8080/login` : Login Page

```
Default Account
mail: hoge@example.jp
pass: hogehogeunko
```

- `http://localhost:8080/live` : Live Streaming Page
    - Login required
    - Video Start -> Live Start

- `http://localhost:8080/watch/{username}` : Watch Streaming Page
    - e.g. `/watch/hoge`