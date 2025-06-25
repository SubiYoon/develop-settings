## JVM 환경 셋팅 방법
### application profile 설정
```bash
-Dspring.profiles.active=dev
```

### jasypy password 설정
```bash
-Djasypt.encryptor.password=ENCRYPT_PASSWORD
```

### maven repository 위치 설정
```bash
-Dmaven.settings.file=/custom/path/to/settings.xml # settings.xml 찾기
-Dmaven.repo.local=/custom/path/to/m2/repository # m2 repository 찾기
```
