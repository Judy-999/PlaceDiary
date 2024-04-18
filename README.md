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
> **소개** : 장소들을 기록해 달력, 지도에서 한 눈에 볼 수 있는 나만의 장소 다이어리 앱<br> **프로젝트 기간** : 2021.05 ~ 2021.10 / 2022.12 ~ 리팩토링 진행 중<br> **설명**: 독학으로 진행했던 프로젝트를 아카데미 학습 이후 다시 리팩토링하는 프로젝트입니다.

|[Judy](https://github.com/Judy-999)|
|:---:|
|<img src = "https://github.com/Judy-999/ios-BoxOffice/assets/102353787/ebd9c08c-c5ac-4b51-8dd5-795a4282e31a" width="250" height="250">  | 

<br>

## 🕹️ 주요 기능
- **장소 리스트**
	- 장소에 대한 이미지와 정보(이름, 위치 날짜, 점수, 누구와, 분류, 코멘트)를 기록하여 저장할 수 있습니다.
	- 저장된 장소를 정렬할 수 있습니다. (`최근 날짜 순, 별점 높은 순, 방문 횟수 순, 가나다 순`) 
	- `그룹별`/`카테고리별` 로 볼 수 있습니다.
- **검색**
	- 이름, 위치, 코멘트에 대한 키워드로 장소를 검색할 수 있습니다.
- **캘린더**
	- 달력에 날짜 별로 방문했던 장소를 표시해 한 눈에 볼 수 있습니다.
- **지도**
	- 저장된 장소를 지도에 마커로 표시하고 특정 `그룹`과 `카테고리`로 장소를 필터링하여 표시할 수 있습니다.
- **설정**
	- 분류와 카테고리를 편집 및 추가, 삭제할 수 있습니다.
	- 분류와 카테고리의 통계를 확인할 수 있습니다.

<br>

## 💡 키워드
- [x] **Storyboard UI**
- [x] **Firebase-Firestore**
- [x] **Firebase-Storage**
- [x] **FSCalendar**
- [x] **GoogleMaps** 
- [x] **GooglePlaces**
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
|지도 | 캘린더 |검색 | 설정 |
|:---:|:---:|:---:|:---:|
|![](https://user-images.githubusercontent.com/102353787/226535599-bd03d821-d32f-4c4d-a20c-cf47d1b157cb.gif)|![](https://i.imgur.com/vcjJPKJ.gif)|![](https://i.imgur.com/foU6SUV.gif) |![](https://i.imgur.com/H5zrOQU.gif)|

<br>

## 🚀 트러블슈팅
### 1. 스파케티 코드 해결하기
이 프로젝트는 iOS와 Swift를 처음 접하고 독학으로 작업했던 앱입니다. 당시에는 코드를 구현하는 것만도 쉽지 않아 기능 구현에만 급급했습니다. `야곰 아카데미 커리어 스타터`에서 다양한 프로젝트의 협업을 진행하며 다른 사람의 코드를 관찰하고, 좋은 코드가 무엇인지 학습한 경험을 바탕으로 수료한 이후 지난 코드를 꼭 다시 리팩토링하고자 했습니다.

결합도가 높은 상태여서 한 부분을 건드리면 많은 코드를 수정하게 되어 수정 방향을 잡기 어려웠습니다. 리팩토링하는 기준이 필요하다고 생각해 다음과 같이 가이드라인을 정한 후 시작했습니다.

> - **가독성 향상**
> 	- 불필요한 코드 및 중복코드 제거하기
> 	- 여러 기능을 하거나 반복되는 코드는 함수로 분리하기
> - **명확한 네이밍**
> 	- 길더라도 줄여쓰지 않기
> 	- 네이밍 형식 통일하기
> - **기능을 객체로 분리**
> 	- 모든 코드를 뷰컨트롤러에 적지 않고 특정 기능을 하는 객체로 분리하기
> - **오토레이아웃** 
> 	- 임의의 숫자로 지정하지 않고 모든 기종에 대응할 수 있도록 하기
> 	- 의미없는 빈 뷰를 사용하지 않고 `constraint`와 `priority`로 해결하기
> - **강제 언래핑(!)하지 않기**
> 	- 불필요한 옵셔널 제거
> 	- `if let`, `guard let` 으로 언래핑하기
> - **파일 분리하기**
> 	- 파일 의미에 따라 그룹으로 분류하기
> - **네임스페이스 분리**
>	- `""` 형태의 문자열로 표현하지 않고 enum으로 분리

<br>좋은 코드가 무엇인지 고민하면서 위와 같은 기준을 세울 수 있었고 실제로 나쁜 코드를 리팩토링하면서 좋은 코드를 작성하는 것이 얼마나 중요한지 다시금 깨달았습니다.
<br><br>

### 2. 데이터 전달을 위한 Delegate 패턴
장소를 편집할 때는 다음과 같은 뷰의 흐름을 가집니다. `장소 상세 -> 장소 편집 -> 장소 상세` 편집할 장소 데이터를 전달할 때는 `장소 상세 -> 장소 편집`으로 이동하는 Segue 방식을 이용해 데이터를 전달할 수 있지만, 수정 후 다시 장소 상세 화면으로 돌아온 경우에는 두 화면의 직접적인 연관이 없어 수정된 데이터를 전달할 수 없습니다.

데이터베이스에 업로드한 수정된 장소를 다시 `load` 하는 방법도 가능하지만 불필요한 요청을 최소화하고 싶어 두 가지 방법을 고려했습니다.

**1. Notification**
- **Notification** 객체를 사용
- ✅ 다수 객체들에게 동시에 알려줄 수 있다.
- ✅ 객체끼리 직접적인 연관이 생기지 않는다.
- ❎ 데이터의 흐름(로직)을 파악하거나 추적이 어려울 수 있다.

**2. Delegate**
- 주로 프로토콜로 직접 구현
- ✅ 제 3의 객체가 필요하지 않다.
- ❎ 많은 객체에게 이벤트를 알리기에는 비효율적이다.
- ❎ delegate로 지정하며 객체 간 연관이 발생한다.

<br>현재 상황에서는 여러 객체에게 전달할 필요가 없고, 수정된 데이터를 상세 화면에 다시 세팅한다는 흐름을 명확하게 하고자 **Delegate** 패턴을 적용했습니다. 이 과정에서 순환 참조가 발생하지 않도록 프로토콜이 `AnyObject`를 채택하게 하여 클래스로 제한하고, delegate는 `weak`로 설정했습니다.
<br><br>

### 3. Tab Bar 뷰컨트롤러의 데이터 전달 - Singleton 패턴
`메인(장소 리스트), 검색, 캘린더, 지도, 설정`으로 이루어진 탭바에서 대부분의 뷰컨트롤러(이하 VC)는 전체 장소 리스트(이하 places)가 필요합니다. 탭바를 통한 화면 전환 시에는 컨트롤러끼리 직접적인 연관이 없어 데이터를 전달할 수 없었습니다. 

```swift
private func passData() {
    let searchNav = tabBarController?.viewControllers![1] as! UINavigationController
    let searchController = searchNav.topViewController as! SearchTableViewController
    let calendarNav = tabBarController?.viewControllers![2] as! UINavigationController
    let calendarController = calendarNav.topViewController as! CalendarController
    let mapNav = tabBarController?.viewControllers![3] as! UINavigationController
    let mapController = mapNav.topViewController as! MapViewController
    let settingNav = tabBarController?.viewControllers![4] as! UINavigationController
    let settingController = settingNav.topViewController as! SettingTableController
    
    searchController.setData(places)
    mapController.getPlace(places)
    calendarController.getDate(places)
    settingController.getPlaces(places)
}
```

<br>처음에는 위와 같이 각 VC의 인스턴스를 생성해 메서드를 통해 데이터를 전달하는 방식을 이용했습니다. 하지만 코드도 길고 가독성이 좋지 않을 뿐더러 장소 데이터가 변경되면 모든 VC에게 새로운 places를 다시 전달해야하는 문제가 있었습니다. `검색, 캘린더, 지도` 모두 장소 상세 화면으로 이동할 수 있어 장소 데이터가 변경이 가능한 까닭에 모든 VC가 위와 같은 코드를 가져야 했습니다. 

이후 places에 변경이 있을 때만 적용할 수 있도록 **Notification**를 같이 활용해봤지만 어디서 데이터가 변경되어, 어디로 전달되었는지 파악하기 어려워 더 복잡한 코드가 되었습니다.

결국 앱 전체에서 하나의 데이터를 관리하고 공유하고자 하는 목적이므로 **Singleton** 패턴의 장점과 알맞다고 생각했습니다. `PlaceDataManager`라는 **Singleton** 객체에 데이터베이스에서 `load`하는 메서드와 현재 places를 변경하는 메서드를 구현해 모든 VC에서 최신 places를 가져와 사용할 수 있습니다. places와 비슷하게 여러 VC에서 사용되는 분류(`classification`) 역시 `PlaceDataManager`에서 관리하도록 하여 데이터베이스 요청을 최소화하고 쉽게 데이터를 사용할 수 있게 되었습니다.
<br><br>

### 4. DB에 기기정보 유지를 위한 KeyChain 및 UserDefaults 사용 

remote DB로 Firebase를 사용하며 컬렉션(collection)에 장소의 리스트(=document)를 저장하는데 모든 사용자가 같은 저장소를 사용하게 되므로 사용자마다 다른 컬렉션을 가져야 합니다. 

![](https://i.imgur.com/HaO2Ay8.png)


```swift
let id = UIDevice.current.identifierForVendor!.uuidString
````

고유번호로 사용자(=기기)를 구분하기 위해 **UUID**인 [identifierForVendor](https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor)를 사용했습니다. 벤더는 App Store에서 제공하는 데이터에 따라 결정되며 동일한 장치에서 실행되는 동일한 공급업체의 앱에 대해서는 동일한 값을 가집니다. 문제는 앱을 삭제하더라고 동일한 공급업체의 앱이 있다면 유지될 수 있지만 그렇지 않은 경우에는 재생성됩니다. 따라서 Vendor UUID를 이용하더라도 앱을 재설치할 경우에는 동일한 값을 유지할 수 없어 이전 장소 데이터를 가져올 수 없었습니다. 

사용자에게 앱을 삭제할 경우 리셋됨을 고지하고 새로운 장소리스트를 시작하도록 할 수도 있지만 삭제하면 사라진다면 remote로써 역할을 하지 못한다고 생각했고, Firebase에 이전 데이터가 누적되어 남아있는 문제도 있습니다.

UUID를 사용하되 앱을 삭제해도 값이 유지되어야 하므로 **KeyChain**에 저장하고 재설치 시  **KeyChain**에 저장된 값을 사용하도록 변경했습니다. 이때 UUID를 **KeyChain**에 저장하는 시점에 대한 새로운 문제가 발생했습니다. 앱을 처음 실행했을 때만 저장하고 그 이후에는 저장된 값을 불러와서 사용해야 하는데 첫 실행 시점을 구분해야 했습니다. 

앱이 실행될 준비를 알리는 `AppDelegate`의 `application(_:didFinishLaunchingWithOptions:)` 메서드에서 **UserDefaults**를 활용해 첫 실행을 확인했습니다. 특정 키 값으로 `UserDefaults에 저장된 값이 없고 && KeyChain에 저장된 값이 없을 때`를 첫 실행으로 간주하여 현재 Vendor UUID를 저장하도록 했습니다. 
<br><br>

### 5. API key 보호
<img src="https://i.imgur.com/69t14rN.png" width="500" />

<br>Git에서 현재 프로젝트의 Google API key가 노출되어 있다는 메일을 받았습니다. `AppDelegate`에서 Google Maps SDK와 Google Places SDK에 API key를 전달하기 때문에 key가 그대로 remote에 push되어 있는 상태였습니다. 아무래도 도용 시 비용이 발생할 수 있고 앱이 동작에 중요한 key이기 때문에 보호가 필요하다고 생각했습니다.

`PropertyList` 파일을 생성해 String 타입의 key를 추가하고 gitIgnore에 해당 파일을 추가해 추척하지 않도록 했습니다. 또한 `Bundle`을 extension하여 해당 키를 가져올 수 있도록 변경해 remote에 key가 노출되지 않도록 변경했습니다.
<br><br>

### 6. 탭바 투명화
iOS 15 이후 Tab Bar와 Navigation Bard의 배경이 투명해지고 구분선이 없어졌습니다. 장소 리스트를 스크롤하면 탭바에 비치듯 보이게 되어 UI가 깔끔하지 않았고, 어느 버전이든 같은 UI를 갖게 하고자 배경색이 있도록 통일시켰습니다.



| 변경 전 | 변경 후 | 
| :--------: | :--------: | 
|![](https://i.imgur.com/AygGfel.png)|  ![](https://i.imgur.com/zNyt7QJ.png)|

<br>`AppDelegate`의 `application(_:didFinishLaunchingWithOptions:)` 메서드에서 iOS 15 이상인 경우 `UITabBarAppearance`의 `backgroundColor`를 지정하도록 구현해 해결했습니다.
<br><br>

### 7. 장소 이미지 ZOOM 기능 
장소 이미지를 두 손가락으로 확대 및 축소해서 볼 수 있는 기능을 제공하고자 이미지만 갖는 `ImageViewController`를 구현했습니다.

처음에는 `UIPinchGestureRecognizer`를 추가해 pinch의 scale 만큼 이미지뷰의 `transform`을 변경하는 방식으로 구현했습니다. 확대와 축소는 가능했지만 가운데를 기준으로만 확대 및 축소되어 사진을 움직이거나 특정 위치에서 줌 동작은 불가능했습니다. 

자연스럽게 줌을 하는 방법을 찾던 중 `UIScrollViewDelegate`의 [viewForZooming](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619426-viewforzooming)의 메서드를 알게 되었습니다. `viewForZooming`은 스크롤뷰에서 확대/축소가 발생할 때 보기의 배율을 대리자에게 요청하는 메서드로 이미지뷰를 스크롤뷰에 넣고 해당 메서드에서 크기가 조정되는 `UIView` 개체로 장소 이미지뷰를 반환하니 자연스러운 줌 동작이 가능했습니다.
<br><br>

### 8. 화면 터치로 키보드 내리기
새로운 장소를 추가할 때 이름, 위치, 별점, 코멘트 등 입력하는 여러 항목과 각각의 입력 방식이 있습니다. 이름을 입력하는 TextField를 터치하면 키보드가 올라오는데 이후 Picker 또는 Slider를 동작해도 키보드가 사라지지 않는 문제가 있었습니다. 
<br>
```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
}
```
이전 프로젝트에서 이런 문제를 해결한 경험이 있어 뷰의 비어있는 부분을 터치하면 editing을 중단하도록, 즉 키보드가 내려가도록 `touchesBegan` 메서드를 override 했습니다. 하지만 이전과 달리 터치를 인식하지 못해 동작하지 않았습니다.

이전 프로젝트와 차이점은 장소 추가 화면은 `UITableView`로 구현되어 있다는 것입니다. `UITableView`는 `UIScrollView`를 상속하고 있어 스크롤 동작이 가능하기 때문에 한 번의 터치로 `touchesBegan`가 호출되지 않았습니다. `UITapGestureRecognizer`를 TableView에 직접 추가하여 원하는 동작을 구현할 수 있었습니다. 
<br><br>

### 9. 사용자 친화 UI

| 라이트모드 | 다크모드 | 글자 크기 최대 | 글자 크기 최소 |
| :--------: | :--------: |:--------: | :--------: |  
|<img src="https://i.imgur.com/qsli4j2.jpg" width="200" />|<img src="https://i.imgur.com/lTcTAZf.jpg" width="200" />|<img src="https://i.imgur.com/UwkJ6VU.jpg" width="200" />|<img src="https://i.imgur.com/ZET1wuS.jpg" width="200" />|

iOS 13 이후부터는 다크모드 적용이 가능합니다. 다크모드 전환 시에도 가려지거나 어색하지 않도록 textColor는 `UIColor.label`로 지정하고, 배경은 `UIColor.systemBackground`로 지정해 다크모드에 대응하도록 했습니다.

또한 사용자마다 다른 글씨 크기를 설정할 수 있으므로 dynamic type을 적용해 글씨 크기가 변동가능하도록 설정했습니다.
<br><br>

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
- RxSwif를 사용한 비동기 처리
- MVVM 패턴 및 Clean Archtecture 적용

<br><br> 



