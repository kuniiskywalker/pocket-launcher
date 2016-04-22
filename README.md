
# docker-compose.ymlに記述されてる手順でコンテナーをビルドする
# on VM
```
docker-compose up -d
```

# on Production
```
docker-compose -f docker-compose.yml -f production.yml up -d
```


# application retart
```
docker-compose restart
```

# container rebuild
```
# Dockerfileに記述されてる手順でコンテナーをビルドする
# docker-compose.ymlの設定はここでは関係ない
docker-compose build
```
