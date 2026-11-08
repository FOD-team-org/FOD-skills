---
name: default-stack
description: 과제가 스택을 정하지 않았을 때 코드를 쓰기 전에 읽는다. React·NestJS·PostgreSQL 기본 스택의 폴더 구조, 빌드 설정, DB 연결, 배포 파일, 쓰지 않을 의존성을 정한다.
---

# 기본 스택

화면은 React, 서버는 NestJS, DB는 PostgreSQL, 언어는 TypeScript다. 웹 서비스는 배포할 수 있는 구조로 만들고, 화면·서버·DB를 폴더로 나눈다. package.json은 루트에 하나만 둔다. 화면은 Vite로 빌드해 서버가 정적 파일로 함께 내보내고, 포트는 하나만 쓴다. API는 `/api` 아래에 둔다.

## 폴더
- `frontend/`: `index.html`, `tsconfig.json`, `src/`의 React 컴포넌트. 조건을 읽어 API를 부르고 결과를 그린다. 계산하거나 자료 파일을 직접 읽지 않는다.
- `backend/src/<기능>/`: 기능마다 모듈 하나. `*.controller.ts`는 입력 검사(작은 함수와 BadRequestException)와 응답 모양, `*.service.ts`는 계산·판정(req·res를 받지 않는다), `*.repository.ts`는 DB 읽기·쓰기. DB를 부르는 코드는 저장소와 `backend/src/db/`에만 둔다.
- `backend/src/db/`: 마이그레이션 적용과 자료 적재. 테이블은 `backend/db/migrations/`의 번호 붙은 SQL 파일(001_init.sql …)로 만든다. 서버가 시작할 때 적용하지 않은 마이그레이션만 차례로 적용하고 적용한 번호를 DB 표에 남긴 뒤, 자료 폴더의 파일로 자료 표를 비우고 한 트랜잭션으로 다시 채운다. 화면에서 저장하는 기능이 요구되면 그 내용은 자료 표와 다른 표에 두어, 다시 채울 때 지워지지 않게 한다. 자료 표는 열마다 타입이 있는 열로 만들고, 행 전체를 json 한 칸에 넣지 않는다. 값 정리, 이상 행, 빈칸은 data-edge-tests를 따른다.

## 빌드 설정
아래대로 둔다. 어긋나면 tsc는 통과하고 실행이나 요청에서 실패한다.
- package.json: `"type": "module"`. 스크립트는 `build`=`tsc && tsc -p frontend && vite build frontend`, `serve`=`node backend/dist/src/main.js`, `start`=`npm run build && npm run serve`, `test`=`tsc && node --test "backend/dist/test/**/*.test.js"`. 실행 때 부르는 패키지(@nestjs/common·core·platform-express, reflect-metadata, rxjs, pg, @electric-sql/pglite)는 `dependencies`, 빌드에만 쓰는 패키지(typescript, vite, react, react-dom, @types/*)는 `devDependencies`에 적는다. react와 react-dom은 같은 버전으로 적고, 버전은 설치본과 맞춘다(`npm ls --depth=0`). `vite.config.ts`와 `@vitejs/plugin-react`는 두지 않는다. 없어도 Vite가 tsx를 빌드한다.
- 루트 tsconfig.json: `module` nodenext, `rootDir` backend, `outDir` backend/dist, `experimentalDecorators`, `emitDecoratorMetadata`, `skipLibCheck`, `include`는 backend/src·backend/test. 서버 빌드는 tsc만 쓴다. esbuild와 strip-types는 데코레이터 정보를 잃는다.
- frontend/tsconfig.json: `target` es2023, `module` esnext, `moduleResolution` bundler, `jsx` react-jsx, `lib` es2023·dom·dom.iterable, `noEmit`, `skipLibCheck`, `types` vite/client, `include` src.
- 서버 코드: import 경로에 `.js`를 붙인다. 주입받는 클래스는 `import type`으로 가져오지 않는다. 파일끼리 순환 import를 만들지 않는다. SQL 파일, 화면 빌드 결과, 자료 폴더는 `process.cwd()`가 아니라 `import.meta.dirname`을 기준으로 찾는다. 자료 폴더는 `DATA_DIR` 환경 변수로 바꿀 수 있게 한다. tsc는 .sql을 복사하지 않으므로 `backend/db/migrations/`를 그 자리에서 읽는다.
- 앱 조립: `backend/src/create-app.ts`의 `createApp()`이 `setGlobalPrefix('api')`, `useStaticAssets(화면 빌드 폴더)`, 마이그레이션·적재까지 마친 앱을 돌려준다. `main.ts`와 테스트는 맨 위에서 `reflect-metadata`를 import하고 createApp을 불러 listen한다.
- 서버는 0.0.0.0에 바인딩한다. 포트는 PORT 환경 변수(없으면 3000), DB 접속은 DATABASE_URL 환경 변수를 쓴다. `npm start` 한 명령으로 빌드·마이그레이션·적재·서버 시작이 끝나게 한다.

## DB
- 저장 기능이 없는 과제도 자료 파일은 DB 표에 적재해 저장소로 읽는다. 서비스가 자료 파일을 직접 읽는 구조로 줄이지 않는다. 외부 API 응답처럼 요청마다 새로 받는 값은 적재하지 않는다.
- `DATABASE_URL`이 있으면 `pg` 패키지로 그 서버에 붙고, 없으면(서버가 없는 실행·테스트 환경) 같은 SQL을 `@electric-sql/pglite`로 메모리에서 돌린다. 어느 쪽인지는 `DATABASE_URL`이 있는지로만 가르고, 저장소는 `query(sql, params)` 하나만 부른다.
- 두 드라이버는 값 모양이 다르므로 SQL에서 맞춘다. 정수 집계는 `::int`, 소수 집계와 numeric 열은 `::float8`, 날짜는 `::text`로 받는다. 값이 없는 호출(여러 문장 포함)은 PGlite `exec`, 값이 있는 호출은 `query`로 보낸다. `pg`가 여러 문장에 돌려주는 배열은 마지막 결과를 쓴다.
- 마이그레이션은 파일마다 `BEGIN; 본문; 기록 INSERT; COMMIT;`을 한 문자열로 보낸다. 자료 적재처럼 여러 호출로 이뤄진 트랜잭션은 `pg`에서 `pool.connect()`로 받은 클라이언트 하나로 BEGIN부터 COMMIT까지 보내고 끝나면 release한다. `pool.query`를 따로 부르면 호출마다 다른 연결로 가서 트랜잭션이 되지 않는다. SQL에 값을 넣을 때는 자리표시자(`$1`, `$2` …)만 쓴다.
- 마이그레이션을 같은 DB에 두 번 돌려도 오류 없이 한 번만 적용되는지 보는 테스트를 둔다. 테스트는 PGlite로 돌려 PostgreSQL 서버 없이 통과하게 한다.
- PostgreSQL 서버에 실제로 붙여 보지 못했으면 마지막 보고 미완에 "PostgreSQL 서버 연결 미확인"으로 적는다.

## 배포 파일
- `Dockerfile`: 두 단계. 앞 단계는 node 22 이상 slim 이미지에서 전체 의존성을 설치하고 `npm run build`, 뒤 단계는 운영 의존성만 설치하고 `backend/dist`·`frontend/dist`·`backend/db`를 복사해 `npm run serve`로 시작한다.
- `.dockerignore`: node_modules·dist·.env 제외.
- `docker-compose.yml`: 앱과 postgres 두 서비스. postgres는 버전을 고정한 공식 이미지에 healthcheck를 두고 앱은 그것이 통과한 뒤 뜬다. DB 자료는 볼륨, 앱에는 DATABASE_URL, 자료 폴더는 마운트, 비밀번호는 `${POSTGRES_PASSWORD}`처럼 .env에서 읽는다.
- `.env.example`: 변수 이름과 자리표시 값만 적고 실제 비밀번호는 적지 않는다.
- README 실행 방법에 `docker compose up` 명령도 적는다. docker가 이미 있으면 한 번 띄워 보고, 없으면 설치하지 말고 마지막 보고 미완에 "이미지 빌드 미확인"으로 적는다.

## 쓰지 않는 것
요구사항에 없으면 ORM(TypeORM·Prisma), class-validator, Swagger, jest·supertest, @nestjs/serve-static, 상태 관리·라우터·UI 라이브러리, 코드 분할(React.lazy), 로그인을 쓰지 않는다. @nestjs/cli와 생성기(`nest new`, `npm create vite`)도 쓰지 않고 파일을 직접 쓴다. 위의 층 말고 계층을 더 만들지 않는다(Guard·Interceptor·Pipe 포함). 의존성은 최소로 하고, 쓰는 패키지는 이미 설치돼 있어도 package.json에 적는다.

## 역할
담당자가 역할(예: 관리자와 구성원)을 나누면 역할마다 화면을 나누고, 역할에 허용한 API인지 컨트롤러에서 검사한다. 역할을 무엇으로 구분할지가 요구사항에 없으면 judgment 스킬을 따른다. 비밀번호 로그인과 회원 관리는 요구될 때만 만든다.

출처: 직접 작성. Node 24.18, NestJS 12, TypeScript 7, Vite 8, PGlite 0.5에서 직접 실행해 확인했다.
