# 🧊 냉장고 정리 도우미 – Fridge Helper (CLIENT)

> 1인 가구를 위한 스마트 냉장고 정리 도우미  
> 유통기한 관리, 가족 단위 공유, 알림 기능까지 지원하는 냉장고 관리 앱입니다.

---

## 🔗 관련 링크

- 🔙 백엔드 Spring Boot 서버 GitHub: [https://github.com/pushow/fridge-server](https://github.com/pushow/fridge-server)

---

## 📱 주요 기능

### 사용자
- 이메일 기반 회원가입 및 로그인 (JWT 인증)
- 사용자 정보 확인 및 이름/비밀번호 수정
- AccessToken/RefreshToken 기반 인증 유지

### 가족 그룹
- 가족 생성 및 구성원 목록 조회
- 가족 초대/수락/거절을 통한 이동
- 구성원이 모두 나가면 자동 삭제 처리

### 냉장고 & 음식 관리
- 냉장고 추가/수정/삭제
- 냉장고별 음식 등록/조회/수정/삭제
- 유통기한 임박 음식에 대한 알림 설정
- 가족 전체 냉장고에 대한 통합 음식 조회 가능

### 알림 설정
- 알림 ON/OFF 및 알림 시간 설정
- 유통기한 임박 시 로컬 알림 전송

---

## ⚙️ 기술 스택

| 항목 | 내용 |
|------|------|
| Language | Dart |
| Framework | Flutter 3.x |
| 상태관리 | 기본 StatefulWidget 사용 |
| 저장소 | SharedPreferences (로컬 설정 저장용) |
| 알림 | flutter_local_notifications |
| 통신 | http 패키지를 활용한 REST API 연동 |
| UI 리소스 | NotoSansKR 폰트, 프리 소스 아이콘/이미지 포함 |

---

## 🗃️ 프로젝트 구조

📦FridgeHelper  
 ┣ 📂assets                  
 ┃ ┣ 📂fonts                 
 ┃ ┣ 📂icon                  
 ┃ ┗ 📂images                
 ┣ 📂controller              
 ┣ 📂model                   
 ┣ 📂page                    
 ┣ 📂theme                   
 ┗ 📜main.dart                 
 
---

## 🚀 실행 방법

1. Flutter 의존성 설치

```
flutter pub get
```

2. 에뮬레이터 또는 디바이스에서 실행

```
flutter run
```

---

## 📌 참고 사항

- 본 앱은 백엔드 API와 통신하기 때문에 `controller/global.dart` 파일의 `BASE_URL`을 자신의 환경에 맞게 수정해야 합니다.

```
const String BASE_URL = '';
```

- API 요청 시 JWT 토큰이 자동으로 헤더에 포함되며, 형식은 다음과 같습니다:

```
Authorization: Bearer {JWT_TOKEN}
```
