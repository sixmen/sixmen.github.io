---
title: GitHub 위키 이벤트를 슬랙으로 받기 - 2. AWS KMS를 이용해 키 보호
tags: ['GitHub','Slack','AWS','Lambda','KMS']
date: 2017-01-06
---

<a href='{{< relref "tech/2017-01-05-1-github-wiki-to-slack-setting-aws-lambda" >}}'>이전 글</a>에서는
AWS Lambda 함수를 생성해서 슬랙에 메시지를 보내는데 성공했습니다.
그런데 이때 사용하는 훅 URL이 그대로 코드에 들어가 있는게 마음에 걸립니다.
이 URL을 알면 외부에서 우리 슬랙 채널에 스팸을 보낼 수 있습니다.

이번 글에서는 AWS KMS(Key Management Service)를 이용해서 이 URL을 보호하는 방법에 대해서 얘기합니다.

AWS Lambda 생성시 blueprint에 slack-echo-command를 선택하면 이미 URL을 보호하는 절차에 대해서 설명하고 있습니다.

> To encrypt your secrets use the following steps:
>
> 1. Create or use an existing KMS Key - http://docs.aws.amazon.com/kms/latest/developerguide/create-keys.html
>
> 2. Click the "Enable Encryption Helpers" checkbox
>
> 3. Paste <COMMAND_TOKEN> into the kmsEncryptedToken environment variable and click encrypt

하나씩 따라해 봅시다.

AWS IAM 화면에 들어가면 Encryption keys 메뉴가 있습니다.
다른 메뉴와는 달리 여기는 지역 선택이 필터 부분에 있습니다. 여기서 원하는 지역을 선택하고 'Create Key'를 선택합니다.

![Create key](/img/ko/tech/2017-01-06-1-01.jpg)

Alias만 입력하고 나머지는 특별히 선택하지 않아도 됩니다.

키가 생성되면 생성한 Lambda 함수로 이동합니다.
코드 섹션 밑에 보면 'Enable encryption helpers' 체크박스가 있습니다.
활성화하고 'Encryption key'에 생성한 키를 설정합니다.

'Environment variables'에 훅 URL을 넣고 'Encrypt'를 누르면 URL이 암호화됩니다.

![Before encrypt](/img/ko/tech/2017-01-06-1-02.jpg)

![After encrypt](/img/ko/tech/2017-01-06-1-03.jpg)

변경사항을 저장하면 암호화된 URL이 표시됩니다.

![Encrypted URL](/img/ko/tech/2017-01-06-1-04.jpg)

이제 이 값을 이용하도록 Lambda 코드를 수정합니다.

{{< highlight javascript >}}
'use strict';

const AWS = require('aws-sdk');
const url = require('url');
const https = require('https');

let hookUrl;

function sendMessage(message) {
  // ... 이전과 같음
}

function decryptHookUrl() {
  if (hookUrl) {
    return Promise.resolve(hookUrl);
  } else {
    const kms = new AWS.KMS();
    return new Promise((resolve, reject) => {
      const blob = new Buffer(process.env.encryptedHookUrl, 'base64');
      kms.decrypt({ CiphertextBlob: blob }, (error, data) => {
        if (error) {
          return reject(error);
        }
        hookUrl = data.Plaintext.toString('ascii');
        resolve(hookUrl);
      });
    });
  }
}

exports.handler = (event, context, callback) => {
  decryptHookUrl()
  .then(() => {
    const message = {
      channel: '#auto-github',
      text: 'This is a test message'
    };
    sendMessage(message)
    .then((response) => {
      callback(null, response);
    });
  });
};
{{< /highlight >}}

저장하고 테스트를 실행하면 이전과 같이 슬랙 채널에서 메시지를 볼 수 있습니다.
