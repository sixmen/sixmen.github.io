---
title: 스크립트 보호 - 모바일에서 AES 해독화 하기
tags: []
date: 2016-12-27
---

이번에는 <a href='{{< relref "/tech/2016-12-27-1-protect-script-decrypt-aes-mobile.ko.md" >}}'>전편</a>에서
암호화한 파일을 모바일 환경(iOS, 안드로이드)에서 해독화 해보겠습니다.

---

iOS에서 AES 해독화를 하기 위해서는 CommonCrypto 라이브러리를 사용합니다.
Swift에서 사용하기 위해서 Bridging-Header.h에 다음을 포함하면 됩니다.

{{< highlight objective-c >}}
#import <CommonCrypto/CommonCryptor.h>
{{< /highlight >}}

암호화/해독화는 CCCrypt 함수를 사용하면 됩니다.
그런데 함수 원형을 보면 key와 iv(Initialization vector)란 인자가 보입니다.
OpenSSL을 써서 암호화 할때는 보지 못한 것입니다.
여기에 어떤 값을 넣어줘야 할까요?

찾아보니 OpenSSL은 암호에서 key와 iv를 유도해서 사용한다고 합니다
([PBKDF2](https://en.wikipedia.org/wiki/PBKDF2) 참고).
-p 옵션을 사용하면 이 정보를 볼 수 있습니다.

{{< highlight bash >}}
$ openssl aes-256-cbc -d -in encrypted.dat -out restored.txt -k 1234 -p
salt=FBA42868201CC0ED
key=A8C174B6F635A7770CE3AE18FCB7290E7E09F289D1187CE0E28A842E07057EDA
iv =7B3E50E41A9F2A33A568F4C34D2C129C
{{< /highlight >}}

이제 해독화를 해봅니다.

{{< highlight swift >}}
// 암호화된 데이터 준비
let url = Bundle.main.url(forResource: "encrypted", withExtension: "dat")
let encrypted_data = try? Data(contentsOf: url!)

// key, iv 준비
// hexadecimal 메소드는 http://stackoverflow.com/a/26502285 참고
let key = "A8C174B6F635A7770CE3AE18FCB7290E7E09F289D1187CE0E28A842E07057EDA".hexadecimal()
let iv = "7B3E50E41A9F2A33A568F4C34D2C129C".hexadecimal()

// 해독화된 데이터를 받을 공간 준비
var output = Data(count: encrypted_data!.count + kCCBlockSizeAES128)
var dataOutMoved = 0

// 해독화
let result = output.withUnsafeMutableBytes { outputPtr in
    return CCCrypt(CCOperation(kCCDecrypt), CCAlgorithm(kCCAlgorithmAES),
            CCOptions(kCCOptionPKCS7Padding),
            [UInt8](key!), kCCKeySizeAES256, [UInt8](iv!),
            [UInt8](encrypted_data!), encrypted_data!.count,
            outputPtr, output.count, &dataOutMoved)
}
output.count = dataOutMoved

// 해독화된 데이터를 문자열로 변환
let outputStr = String(data: output, encoding: .utf8)
{{< /highlight >}}

실제로 나온 결과를 보면 원본과 다릅니다.
그것은 OpenSSL이 암호화한 파일 앞에 16 바이트의 소금(salt)가 추가되어 있기 때문입니다.
16 바이트를 제거한 파일을 입력으로 주면 제대로 해독화가 됩니다.

그런데 원본 파일을 변경한 후 다시 암호화를 해보면 key와 iv가 다른 값으로 바뀝니다.
이렇게 되면 이 값을 하드코딩할 수는 없습니다.
정식으로는 암호와 소금으로 부터 key와 iv를 유도해야 겠지만, 귀찮으니 다른 방법을 찾아봅니다.
다행히 OpenSSL에는 소금을 사용하지 않는 옵셥이 있습니다.

{{< highlight bash >}}
$ openssl aes-256-cbc -in original.txt -out encrypted.dat -nosalt -k 1234
$ openssl aes-256-cbc -d -in encrypted.dat -out restored.txt -nosalt -k 1234 -p
key=81DC9BDB52D04DC20036DBD8313ED055CC5776D16A1FB6E4AFA34B18395DA656
iv =6305309076F3AB48FF8FEF0F3B70A434
{{< /highlight >}}

이렇게 하면 key와 iv가 항상 일정합니다. 그리고 암호화된 파일에서 소금 부분을 삭제하는 작업을 하지 않아도 됩니다.

물론 보통의 경우 이렇게 하면 안 되겠지만, 이번 작업에서는 이 정도로 충분하다는 판단을 했습니다.
실제로는 암호도 사용하지 않고 key와 iv를 직접 주어서 암호화를 했습니다.

{{< highlight bash >}}
$ openssl aes-256-cbc -in original.txt -out encrypted.dat -K 01020304 -iv 0a0b0c0d -nosalt
$ openssl aes-256-cbc -d -in encrypted.dat -out restored.txt -K 01020304 -iv 0a0b0c0d -nosalt -p
key=0102030400000000000000000000000000000000000000000000000000000000
iv =0A0B0C0D000000000000000000000000
{{< /highlight >}}

---

똑같은 동작을 Java(안드로이드)에서도 할 수 있습니다.
Java에서는 javax.crypto 패키지를 사용합니다.

{{< highlight java >}}
// 암호화된 데이터 준비
byte[] encrypted_data = Files.readAllBytes(Paths.get("encrypted.dat"));

// key, iv 준비
byte[] key = new BigInteger("0102030400000000000000000000000000000000000000000000000000000000", 16).toByteArray();
byte[] iv = new BigInteger("0A0B0C0D000000000000000000000000", 16).toByteArray();

// 해독화 준비
Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
SecretKeySpec keySpec = new SecretKeySpec(key, "AES");
IvParameterSpec ivSpec = new IvParameterSpec(iv);
cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec);

// 해독화
byte[] output = cipher.doFinal(encrypted_data);
String outputStr = new String(output, "UTF-8");
{{< /highlight >}}

JVM 위에서 위 코드를 실행하면 `java.security.InvalidKeyException: Illegal key size` 에러가 발생할 수 있습니다.
그것은 기본 배포되는 JRE가 256 비트의 키를 허용하지 않기 때문입니다. 
aes-128-cbc로 암호화하고 key에 16 바이트(=128 비트)의 키를 주면 잘 동작합니다.
제가 목표로 한 안드로이드 환경에서는 256 비트의 키도 사용할 수 있었습니다.

---

여기까지의 내용을 기반으로 AES 알고리즘을 써서 단순한 스크립트 보호를 해봤습니다.
더 깊게 들어갈 부분도 있겠지만, AES를 다루는데 도움이 되었으면 합니다.
