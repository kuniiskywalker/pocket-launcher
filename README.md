
# docker-compose.yml�ɋL�q����Ă�菇�ŃR���e�i�[���r���h����
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
# Dockerfile�ɋL�q����Ă�菇�ŃR���e�i�[���r���h����
# docker-compose.yml�̐ݒ�͂����ł͊֌W�Ȃ�
docker-compose build
```
