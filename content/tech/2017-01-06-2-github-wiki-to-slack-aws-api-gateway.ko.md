---
title: GitHub 위키 이벤트를 슬랙으로 받기 - 3. AWS API Gateway 생성하기
tags: ['GitHub','Slack','AWS','AWS Lambda','AWS API Gateway']
date: 2017-01-06T02:00:00
---

GitHub 이벤트를 받으려면 GitHub에서 접근가능한 URL이 필요합니다.
<a href='{{< relref "/tech/2017-01-06-1-github-wiki-to-slack-protect-secret-using-kms.ko.md" >}}'>이전 글</a>에서
만든 Lambda 함수를 외부에서 접근가능하게 하려면 AWS API Gateway를 사용하면 됩니다.

API Gateway 콘솔에서 새 API를 생성합니다.

![Create API](/img/ko/tech/2017-01-06-2-01.jpg)

생성된 직후에는 어떤 메소드도 없습니다.
GitHub 이벤트는 POST 메소드로 전달되므로 Resources에서 POST 메소드를 하나 생성합니다.

Actions 메뉴에서 Create Method를 누른 후 POST를 선택하면 메소드가 생성됩니다.

![Created POST Method](/img/ko/tech/2017-01-06-2-02.jpg)

이 메소드에 우리가 생성한 Lambda 함수를 연결할 수 있습니다.

![Integration with Lambda Function](/img/ko/tech/2017-01-06-2-03.jpg)

테스트 버튼을 누르면 API 테스트를 할 수 있습니다.
슬랙에 메시지가 오는지 확인해보세요.

이제 이 API를 활성화할 차례입니다.
Actions에서 Deploy API를 선택합니다.
현재 stage가 없으므로 '[New State]'를 선택하고 prod라고 이름을 줍니다.

![Setup deploy](/img/ko/tech/2017-01-06-2-04.jpg)

이제 외부에서 접근가능한 URL이 생성됐습니다.
해당 URL에 POST 메소드로 접근할 수 있습니다.

{{< highlight bash >}}
$ curl -X POST https://<your-invoke-url>/prod
null
{{< /highlight >}}

이번에도 역시 슬랙에 메시지가 표시되면 제대로 설정된 것입니다.
