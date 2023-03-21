# 📔 PlaceDiary

## 🪧 목차
- [📜 프로젝트 및 개발자 소개](#-프로젝트-및-개발자-소개)
- [🕹️ 주요 기능](#%EF%B8%8F-주요-기능)
- [💡 키워드](#-키워드)
- [📱 구현 화면](#-구현-화면)
- [🚀 트러블슈팅](#-트러블슈팅)
- [📁 폴더 구조](#-폴더-구조)
<br>

## 📜 프로젝트 및 개발자 소개
> **소개** : 장소들을 한 곳에 모아두고 기록하는 나만의 장소 다이어리 앱<br> **프로젝트 기간** : 2021.05 ~ 2021.10 / 2022.12 ~ 리팩토링 진행 중<br> **설명**: 독학으로 진행했던 프로젝트를 아카데미 학습 이후 다시 리팩토링하는 프로젝트입니다.

|[Judy](https://github.com/Judy-999)|
|:---:|
|<img src = "https://i.imgur.com/n304TQO.jpg" width="250" height="250"> | 

<br>

## 🕹️ 주요 기능
### 1. 장소 리스트
장소에 대한 이미지와 정보(이름, 위치 날짜, 점수, 누구와, 분류, 코멘트)를 기록하여 저장할 수 있습니다.

- 저장된 장소를 정렬할 수 있습니다. (`최근 날짜 순, 별점 높은 순, 방문 횟수 순, 가나다 순`) 
- `그룹별`/`카테고리별` 로 볼 수 있습니다.

### 2. 장소 검색
이름, 위치, 코멘트에 대한 키워드로 장소를 검색할 수 있습니다.

### 3. 캘린더
날짜 별로 방문했던 장소를 표시해 한 눈에 볼 수 있습니다.

### 4. 지도
저장된 장소를 지도에 마커로 표시하고 특정 `그룹`과 `카테고리`로 장소를 필터링하여 표시할 수 있습니다.

### 5. 설정
- 분류와 카테고리를 편집 및 추가, 삭제할 수 있습니다.
- 분류와 카테고리의 통계를 확인할 수 있습니다.

<br>

## 💡 키워드
- [x] **Storyboard UI**
- [x] **Firebase-Firestore**
- [x] **Firebase-Storage**
- [x] **Tab Bar**
<br>

## 📱 구현 화면
### UI in Storyboard
<img src="https://i.imgur.com/e72us09.png" width="500" />

<br>

### 실행 예시
	
#### 메인화면
|장소 리스트 보기|장소 추가|장소 상세 보기|
|:---:|:---:|:---:|
|![](https://i.imgur.com/fYCGF11.gif)|![추가](https://user-images.githubusercontent.com/102353787/226535496-4f669a27-86b3-4a67-af6b-2af9e6ba684e.gif)|![](https://i.imgur.com/cPYDBNm.gif)|


#### 탭 화면
|지도 | 캘린더 |
|:---:|:---:|
|<img src="https://user-images.githubusercontent.com/102353787/226535599-bd03d821-d32f-4c4d-a20c-cf47d1b157cb.gif" width="450" />|![](https://i.imgur.com/vcjJPKJ.gif)|


|검색 | 설정 |
|:---:|:---:|
|![](https://i.imgur.com/foU6SUV.gif) |![](https://i.imgur.com/H5zrOQU.gif)|
<br>

## 🚀 트러블슈팅
### 1. 데이터 전달을 위한 델리게이트 패턴

<br>

## 📁 폴더 구조
❕일부 파일은 생략되어 있습니다.
```swift
.
├── Application
│	├── AppDelegate.swift
│	└── SceneDelegate.swift
├── Common
│	└── Namespace
├── Controller
│	├── Calendar
│	│	└── CalendarController.swift
│	├── Main
│	│	├── Add
│	│	│	└── AddPlaceTableViewController.swift
│	│	├── Detail
│	│	│	├── ImageViewController.swift
│	│	│	└── PlaceInfoTableViewController.swift
│	│	└── MainViewController.swift
│	├── Map
│	│	└── MapViewController.swift
│	├── Search
│	│	└── SearchViewController.swift
│	└── Setting
│	    ├── EditClassificationController.swift
│	    ├── SettingTableController.swift
│	    └── StatisticsTableViewController.swift
├── Extension
│	├── Date+.swift
│	├── UIImage+.swift
│	└── UIViewController+.swift
├── GoogleService-Info.plist
├── Info.plist
├── Model
│	└── Place.swift
├── Resources
│	└── Assets.xcassets
├── Util
│	├── Firebase
│	│	├── FirebaseError.swift
│	│	├── FirestoreManager.swift
│	│	└── StorageManager.swift
│	├── ImageCacheManager.swift
│	├── PlaceDataManager.swift
│	└── RatingManager.swift
└── View
	├── Base.lproj
	│	├── LaunchScreen.storyboard
	│	└── Main.storyboard
	├── PlaceCell.swift
	└── SearchResultCell.swift
```
<br>

## 🔮 개선하고 싶은 점
### RxSwif를 사용한 비동기 처리

### MVVM 패턴 및 Clean Archtecture 적용

### 다크모드 전환

<br><br> 

