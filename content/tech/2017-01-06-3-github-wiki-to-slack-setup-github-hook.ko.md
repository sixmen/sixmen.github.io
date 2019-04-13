---
title: GitHub 위키 이벤트를 슬랙으로 받기 - 4. GitHub 웹훅 연결하기
tags: ['GitHub','Slack','AWS','AWS Lambda','AWS API Gateway']
date: 2017-01-06T03:00:00
---

이제 GitHub 웹훅을 처리할 수 있게 됐습니다.
<a href='{{< relref "/tech/2017-01-06-2-github-wiki-to-slack-aws-api-gateway.ko.md" >}}'>이전 글</a>에서
생성한 URL을 GitHub에 설정해줍니다.

GitHub 저장소의 Settings 탭에 가면 Webhooks 메뉴가 있습니다. 여기서 웹훅을 추가할 수 있습니다.

![Add webhook](/img/ko/tech/2017-01-06-3-01.jpg)

아래 부분에서 웹훅을 통해 받을 이벤트를 설정할 수 있습니다.
다른 이벤트는 이미 받고 있으므로 여기서는 Gollum(GitHub 위키 엔진) 이벤트만 체크해줍니다.

![Select events](/img/ko/tech/2017-01-06-3-02.jpg)

위키에 변경을 가하면 'Recent Deliveries' 섹션에 그 내용이 보여집니다.
Lambda 함수가 GitHub 위키 이벤트를 의도한대로 처리하는지 테스트하기 위해
이 내용을 사용할 있습니다.
AWS Lambda 편집화면에서 Actions -> Configure test event 에서 입력할 수 있습니다.

다음은 최종 Lambda 코드입니다.

{{< highlight javascript >}}
'use strict';

const AWS = require('aws-sdk');
const url = require('url');
const https = require('https');

let hookUrl;

function sendMessage(message) {
  const body = JSON.stringify(message);
  const options = url.parse(hookUrl);
  options.method = 'POST';
  options.headers = {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(body)
  };
  return new Promise((resolve) => {
    const req = https.request(options, (res) => {
      res.on('end', () => {
        resolve({
          statusCode: res.statusCode
        });
      });
    });
    req.write(body);
    req.end();
  });
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

function processGithubPayload(payload) {
  const page = payload.pages[0];
  const repo = payload.repository.full_name;
  const page_link = page.html_url + '|' + page.title;
  const sender_link = payload.sender.html_url + '|' + payload.sender.login;
  return {
    username: 'github wiki',
    text: `[${repo}] <${page_link}> is ${page.action} by <${sender_link}>`
  }
}

exports.handler = (event, context, callback) => {
  decryptHookUrl()
  .then(() => {
    const message = processGithubPayload(event);
    message.channel = '#auto-github';
    sendMessage(message)
    .then((response) => {
      callback(null, 'success');
    });
  }).catch((error) => {
    callback(error);
  });
};
{{< /highlight >}}

이제 위키를 수정하고 슬랙에 메시지가 표시되는 것을 확인하면 끝입니다.
수정내역이나 커밋 메시지를 표시해주면 좋은데 아쉽게도 해당 데이터는 없는 것 같습니다.
