---
title: 문자열이 여러개의 패턴에 일치하는지 여부 검사하기
tags: []
date: 2016-12-15
---

지그재그에서는 현재 하루에 수천만개의 사용자 로그가 쌓이고 있습니다.
그리고 이 로그를 분석해 사용자가 얼마나 쇼핑몰에 가입을 하는지,
주문을 얼마나 하는지 살피고 있습니다.

그런데 지그재그가 지원하는 수많은 쇼핑몰은 다양한 솔루션을 사용하고 있고,
그에 따라 패턴도 전부 제각각입니다.
따라서 어떤 로그가 가입 페이지인지, 주문 페이지인지 확인하기 위해서
모든 솔루션의 패턴과 대조를 해야 합니다.

오늘은 이러한 대조를 어떻게 하고 있는지 살펴보겠습니다.
분석은 여러가지 언어로 하고 있지만, 여기서는 JavaScript를 살펴보겠습니다.

JavaScript에서 어떤 문자열이 패턴을 포함하고 있는지 검사하는 방법은 다음과 같은 것들이 있습니다.
[String.prototype.indexOf](https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Global_Objects/String/indexOf),
[String.prototype.includes](https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Global_Objects/String/includes),
[String.prototype.match](https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Global_Objects/String/match),
[RegExp.prototype.test](https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Global_Objects/RegExp/test).

우선 10만개짜리 로그들을 놓고 간단한 문자열 포함 여부 검사를 각 방법으로 해서 시간을 비교해봤습니다.

{{< highlight coffeescript >}}
fs = require 'fs'
logs = fs.readFileSync('logs', 'utf-8').split('\n')

run = (name, fn) ->
  start = Date.now()
  for i in [0...1000]
    fn()
  console.log "#{name} - #{Date.now()-start}ms"

run 'indexOf', ->
  count = 0
  for log in logs
    if log.indexOf('o') > 0
      count++

run 'includes', ->
  count = 0
  for log in logs
    if log.includes 'o'
      count++

run 'test', ->
  count = 0
  for log in logs
    if /o/.test log
      count++

run 'match', ->
  count = 0
  for log in logs
    if log.match /o/
      count++
{{< /highlight >}}

다음은 그 결과입니다.

```
indexOf - 6517ms
includes - 7247ms
test - 13539ms
match - 14369ms
```

속도 차이가 많아보입니다.

이번에는 검색 패턴을 좀더 실제에 가깝게 해봤습니다.

{{< highlight coffeescript >}}
run 'indexOf', ->
  count = 0
  for log in logs
    if log.indexOf('join.html') > 0
      count++

run 'includes', ->
  count = 0
  for log in logs
    if log.includes 'join.html'
      count++

run 'test', ->
  count = 0
  for log in logs
    if /join\.html/.test log
      count++

run 'match', ->
  count = 0
  for log in logs
    if log.match /join\.html/
      count++
{{< /highlight >}}

다음은 그 결과입니다.

```
indexOf - 6812ms
includes - 7947ms
test - 10420ms
match - 10943ms
```

indexOf, includes에 대해서 시간이 증가하는 것은 예상된 것이지만,
정규식을 쓰는 경우 오히려 시간이 감소했습니다.
혹시 이유를 아시는 분은 알려주시면 감사하겠습니다.

그래도 indexOf가 가장 빠르지만, 우리가 원하는 패턴은 하나가 아닙니다.
패턴을 두개로 늘려봤습니다.

{{< highlight coffeescript >}}
run 'indexOf', ->
  count = 0
  for log in logs
    if log.indexOf('join.html') > 0 or log.indexOf('join_contract.html') > 0
      count++

run 'includes', ->
  count = 0
  for log in logs
    if log.includes('join.html') or log.includes('join_contract.html')
      count++

run 'test', ->
  count = 0
  for log in logs
    if /join\.html|join_contract\.html/.test log
      count++

run 'match', ->
  count = 0
  for log in logs
    if log.match /join\.html|join_contract\.html/
      count++
{{< /highlight >}}

다음은 그 결과입니다.

```
indexOf - 12686ms
includes - 13864ms
test - 11690ms
match - 12089ms
```

패턴이 두개만 되도 정규식이 빠릅니다. 심지어 저희는 패턴이 일단 10개는 넘습니다.
그래서 정규식의 test를 쓰는 것으로 결정을 했습니다.
그리고 알려진 패턴을 추가했습니다.

{{< highlight coffeescript >}}
PATTERN = /join\.html|join_contract\.html|member\/register|register_form\.php|..../
{{< /highlight >}}

10개미만일때는 그래도 괜찮은데 길어지니까 어디까지가 하나의 패턴인지 눈에 안 들어옵니다.
거기에 일일이 기억하기 어려워서 각 패턴이 어떤 솔루션의 것인지 주석을 달고 싶어졌습니다.
그래서 정규식을 여러 줄로 나눠서 쓸 수 있는지 찾아봤습니다.
몇몇언어(예. Perl)는 정규식 자체를 여러 줄로 나눌 수 있지만 JavaScript는 그런 문법은 없는 것 같습니다.

방법을 찾아보니 [regex - How to split a long regular expression into multiple lines in JavaScript? - Stack Overflow](http://stackoverflow.com/q/12317049)를 찾을 수 있었습니다.
그 중에서도 단순히 문자열을 합친 후 RegExp 생성자를 이용하는 것은 문자열 escape에 신경을 써야 해서,
최종적으로는 [두번째 답변](http://stackoverflow.com/a/34755045)의 방법을 이용하기로 했습니다.

{{< highlight coffeescript >}}
PATTERNS = [
    /join\.html/, # 솔루션 A
    /join_contract\.html/, # 솔루션 B
    /member\/register/, # 솔루션 C
    /register_form\.php/, # 솔루션 D
    ...
]
PATTERN_RE = new RegExp PATTERNS.map((p) -> p.source).join('|')
{{< /highlight >}}

이상 패턴 일치 여부 검사 방법이였습니다.
(원래는 JavaScript에서 정규식을 여러 줄로 쓰는 방법에 대해서 쓰려던 건데 사족이 붙어서 길어졌네요)
