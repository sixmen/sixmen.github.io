---
title: 우부투에 JDK 설치하기
tags: []
date: 2016-12-28
---

우분투에는 기본적으로 `default-jdk`라는 패키지를 제공합니다.
이 패키지를 설치하면 OpenJDK(`openjdk-8-jdk`)가 설치됩니다.

{{< highlight bash >}}
$ sudo apt-get install default-jdk
{{< /highlight >}}

그런데 저 같은 경우 Java가 주력이 아니다 보니 OpenJDK를 써도 되는지 확신이 없었습니다.
그래서 Oracle JDK를 설치하기로 했습니다.

Oracle JDK는 우분투 패키지에는 존재하지 않습니다.
하지만 [우분투 Personal Package Archives](https://launchpad.net/ubuntu/+ppas)에
[Oracle JDK 패키지를 제공하는 PPA](https://launchpad.net/~webupd8team/+archive/ubuntu/java)가 있습니다.  
이를 이용해 Oracle JDK를 패키지로 설치할 수 있습니다.

{{< highlight bash >}}
$ sudo add-apt-repository ppa:webupd8team/java
$ sudo apt-get update
$ sudo apt-get install oracle-java8-installer
{{< /highlight >}}

# 참고
* https://www.digitalocean.com/community/tutorials/how-to-install-java-on-ubuntu-with-apt-get
