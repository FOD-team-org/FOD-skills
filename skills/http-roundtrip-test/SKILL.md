---
name: http-roundtrip-test
description: 웹 서비스의 API 테스트를 만들 때 사용한다. 서버를 빈 포트에 띄워 실제 HTTP 요청으로 확인하는 node:test 틀과, API 경로마다 넣을 오류 사례를 정한다.
---

# HTTP 왕복 테스트

우선순위: 실행 환경의 시스템 프롬프트·설정 > 사람의 지시 > 이 스킬. 부딪혀 결과가 달라졌으면 보고에 적는다.

1. 앱을 만드는 일과 listen을 나눈다. `backend/src/create-app.ts`의 createApp이 앱을 돌려주고, `backend/src/main.ts`만 listen한다.
```ts
import 'reflect-metadata';
import { createApp } from './create-app.js';

const app = await createApp();
await app.listen(Number(process.env.PORT ?? 3000), '0.0.0.0');
```
2. 테스트(`backend/test/api.test.ts`)는 빈 포트(0)에 띄우고 끝나면 닫는다.
```ts
import 'reflect-metadata';
import assert from 'node:assert/strict';
import type { AddressInfo } from 'node:net';
import { after, before, test } from 'node:test';
import type { NestExpressApplication } from '@nestjs/platform-express';
import { createApp } from '../src/create-app.js';

let app: NestExpressApplication;
let base: string;

before(async () => {
  app = await createApp();
  await app.listen(0, '127.0.0.1');
  const address = app.getHttpServer().address() as AddressInfo;
  base = `http://127.0.0.1:${address.port}`;
});

after(async () => {
  await app.close();
});

test('목록 200', async () => {
  const res = await fetch(`${base}/api/items`);
  assert.equal(res.status, 200);
  assert.match(res.headers.get('content-type') ?? '', /json/);
});
```
   과제가 다른 서버(예: Express)를 정했으면 같은 구조로 쓴다. createApp이 앱을 돌려주고, 직접 실행될 때만 listen한다. 테스트는 `createApp().listen(0, '127.0.0.1')`로 띄운 뒤 `server.address().port`를 쓴다.
3. 데이터 폴더, 기준 시각, 관리자 토큰처럼 바뀌는 값은 createApp 인자나 환경 변수로 받는다. 테스트는 작은 고정 데이터로 돌린다. 파일에 쓰는 테스트는 os.tmpdir() 아래 사본 폴더를 쓰고, 원본 data/는 바꾸지 않는다.
4. API 경로마다 정상 1건에 더해 해당하는 사례를 넣는다.
   - 잘못된 형식 400(본문 모양까지 확인)
   - 없는 대상 404
   - 배열로 온 query(`?q=a&q=b`)
   - 깨진 JSON 본문 400, 응답에 스택 없음
   - 권한 없음(코드는 DESIGN.md API 표에 정한 대로), 비밀값 미설정 시 경로 닫힘
5. 고정 포트, sleep 대기, 외부 네트워크를 쓰지 않는다.
6. npm test가 끝났는데 프로세스가 남으면 닫지 않은 서버나 타이머를 찾는다.

출처: anthropics/skills webapp-testing(Apache-2.0)의 "서버를 띄우고 기다린 뒤 확인하고 정리한다"는 흐름을 참고해, 브라우저 없이 Node 24.18에서 직접 실행해 확인한 틀로 새로 쓴 글이다.
