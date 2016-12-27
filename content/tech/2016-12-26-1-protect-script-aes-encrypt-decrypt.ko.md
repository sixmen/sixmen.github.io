---
title: 스크립트 보호 - AES 암호화/해독화 하기
tags: []
date: 2016-12-26
---

<a href='{{< relref "tech/2016-12-23-1-protect-script-encryption-types.ko.md" >}}'>전편</a>에 이어
실제로 파일을 암호화/해독화 해보겠습니다.

OpenSSL 커맨드 라인 도구를 사용하면 프로그램을 따로 작성하지 않아도 암호화를 할 수 있습니다.

우선 원본 파일을 준비합니다.

{{< highlight bash >}}
$ cat original.txt
Hello World
{{< /highlight >}}

`openssl list-cipher-commands`를 실행하면 사용가능한 알고리즘을 보여줍니다.
그중 AES 알고리즘은 다음과 같습니다.

{{< highlight bash >}}
$ openssl list-cipher-commands | grep aes
aes-128-cbc
aes-128-ecb
aes-192-cbc
aes-192-ecb
aes-256-cbc
aes-256-ecb
{{< /highlight >}}

128, 192, 256은 키의 크기입니다. CBC, ECB는 [블록 암호 운용 방식](https://ko.wikipedia.org/wiki/%EB%B8%94%EB%A1%9D_%EC%95%94%ED%98%B8_%EC%9A%B4%EC%9A%A9_%EB%B0%A9%EC%8B%9D)을 나타냅니다. 여기서는 aes-256-cbc로 암호화를 해보겠습니다.

{{< highlight bash >}}
$ openssl aes-256-cbc -in original.txt -out encrypted.dat
enter aes-256-cbc encryption password:
Verifying - enter aes-256-cbc encryption password:
{{< /highlight >}}

해독화는 -d 옵션을 사용합니다.

{{< highlight bash >}}
$ openssl aes-256-cbc -d -in encrypted.dat -out restored.txt
enter aes-256-cbc decryption password:
{{< /highlight >}}

암호화를 자동화하려면 암호를 명령에 포함시켜야 합니다. 이를 위해서는 -k 나 -pass 옵션을 사용합니다.

{{< highlight bash >}}
$ openssl aes-256-cbc -in original.txt -out encrypted.dat -k 1234
{{< /highlight >}}

또는

{{< highlight bash >}}
$ openssl aes-256-cbc -in original.txt -out encrypted.dat -pass pass:1234
{{< /highlight >}}

암호를 파일에서 읽도록 하려면 -kfile 이나 -pass 옵션을 사용합니다.

{{< highlight bash >}}
$ openssl aes-256-cbc -in original.txt -out encrypted.dat -kfile password_file
{{< /highlight >}}

또는

{{< highlight bash >}}
$ openssl aes-256-cbc -in original.txt -out encrypted.dat -pass file:password_file
{{< /highlight >}}

다음에는 암호화한 파일을 iOS나 Android에서 해독화하는 방법에 대해서 알아보겠습니다.
