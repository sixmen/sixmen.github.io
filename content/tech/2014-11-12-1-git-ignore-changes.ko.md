---
title: Git에서 변경된 내용 무시하기
tags: []
date: 2014-11-12
---

개발을 하다보면 몇몇 설정 파일을 수정한 채로 개발을 하는 경우가 있습니다.
예를 들면 서버 주소를 개발용 서버로 변경해서 작업을 할 수 있겠죠.
만약 개발용 서버가 명확히 정해져 있다면, 디버그 모드와 출시 모드를 구분하는 식으로 고정된 설정 파일을 만들 수 있겠지만,
개발용 서버가 개발자 개인 컴퓨터인 경우는 이것도 쉽지 않습니다.

이런 용도로 변경된 파일들은 당연히 주 저장소에 올라가면 안 되겠죠.
(하지만 이 파일 자체는 주 저장소에 포함되어야 하기에 .gitignore를 쓸 수는 없습니다)
저 같이 'git commit -a'을 실행하는데 익숙한 사람은 매번 커밋시 이 파일이 포함되지 않도록 신경써주는것이 꽤 큰 비용입니다.

다행히 git는 이를 위한 해결책이 있습니다. 다음 명령을 실행하면 해당 파일에 대한 변경을 무시합니다.

```
git update-index --assume-unchanged <file>
```

다시 변경된 내역을 표시하려면 다음 명령을 실행합니다.

```
git update-index --no-assume-unchanged <file>
```

변경이 무시되고 있는 파일 목록은 다음 명령으로 확인할 수 있습니다.

```
git ls-files -v | grep '^h'
```

### 참고
* [GIT: ignoring changes in tracked files « Pagebakers](http://blog.pagebakers.nl/2009/01/29/git-ignoring-changes-in-tracked-files/)
