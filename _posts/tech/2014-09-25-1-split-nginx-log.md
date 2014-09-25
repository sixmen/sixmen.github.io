---
layout: post.ko
category: ko/tech
title: 쉘에서 Nginx(Apache) 로그를 시간별로 분리하기
tags: []
---

Nginx 로그 분석을 위해 시간별로 나누고 싶었습니다.
스크립트를 짜도 오래 걸리는 일은 아니겠지만, 쉘에서 하는 방법을 한번 찾아봤습니다.

Nginx 로그는 다음과 같은 형태를 가집니다.

```
xx.xx.xx.xx - - [25/Sep/2014:06:54:29 +0000] "GET /blahblah HTTP/1.1" 200 130 "-" "User-Agent"
```

다음 명령은 공백으로 나눠진 토큰 중 4번째, 즉 시간을 표시합니다.

```
awk '{ print $4 }' access.log
awk '{ print substr($4,2) }' access.log # 앞의 [ 제거
```

여기에 split 함수를 써서 날짜와 시간을 얻을 수 있습니다.

```
awk '{ split(substr($4,2),array,"[/:]"); print array[1], array[4] }' access.log
```

필요한 정보를 알았으니 각 줄을 적절한 파일에 쓰도록 하면 됩니다.

```
awk '{ split(substr($4,2),array,"[/:]"); print > (array[1] "-" array[4] ".log") }' access.log
```

갱신:

좀 더 큰 데이터에 해보니 too many open files 에러가 발생합니다.
awk가 좀 오래된 도구다 보니 열린 파일 수 제한이 낮은 듯 합니다. (MacOSX 기준으로 채 20개를 넘지 못하네요.)

이 경우 파일을 계속 닫아주면 됩니다. 대신 '>>'를 써줘야 정상적으로 추출됩니다.

```
awk '{ split(substr($4,2),array,"[/:]"); fn = array[1] "-" array[4] ".log"; print >> fn; close(fn) }' access.log
```

### 참고
* [How to split existing apache logfile by month?](http://stackoverflow.com/questions/11713978/how-to-split-existing-apache-logfile-by-month/11714105#11714105)
