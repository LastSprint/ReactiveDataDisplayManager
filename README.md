[![Build Status](https://travis-ci.org/surfstudio/ReactiveDataDisplayManager.svg?branch=master)](https://travis-ci.org/surfstudio/ReactiveDataDisplayManager)
[![codebeat badge](https://codebeat.co/badges/30f4100b-ee0e-4bc6-8aad-c2128544c0c6)](https://codebeat.co/projects/github-com-surfstudio-reactivedatadisplaymanager-master) [![codecov](https://codecov.io/gh/surfstudio/ReactiveDataDisplayManager/branch/master/graph/badge.svg)](https://codecov.io/gh/surfstudio/ReactiveDataDisplayManager)

# ReactiveDataDisplayManager
It is the whole approach to working with UITableView.
The main idea of RDDM is to make development of table screen faster and clearly. So it provide reuse DDM and reuse cells both within a project and beetween projects.

# Entites
RDDM contains next entites:        
 - **TableDataDisplayManager**: This is something like adapter. This entity responses for add, remove, swap cells in `UITableView`. Also for fill table, reload data and other functionality, provided with `UITableViewDelegate` and `UITableViewDataSource`.
 - **ViewGenerator**: This entity is aspect of more difficult object. But exactly this entity provide interface to **TableDataDisplayManager** for store each similar objects in collection and get `UIView` for create SectionHeader.
 - **TableCellGenerator**: This entity is something like **ViewGenerator**. It reponse for create `UITableViewCell` for **TableDataDisplayManager**. In this way this **Generator** hide the concretate cell type from **TDDM** and show it only the abstract cell - `UITableViewCell`.
 - **ViewBuilder<ViewType>**: This object incapsulate logicks for fill view with model that needs to display. This object together with **TableCellGenerator** (or **ViewGenerator**) is a part of more difficult object.

Object which implement **ViewBuilder** and **TableCellGenerator** (or **ViewGenerator**), I called just **Generator**.
And this object also response for events (notify listners) and response for store model. Usually view create generators, subscribe on events and send them to **TDDM**.

```swift
class SubscriptionServiceGenerator {

    // MARK: - Events

    public var buyEvent: BaseEvent<PaidService>

    // MARK: - Stored properties

    fileprivate let model: PaidService?

    // MARK: - Initializer

    public init(model: PaidService?) { <#code#> }
}

// MARK: - TableCellGenerator

extension SubscriptionServiceGenerator: TableCellGenerator {
    var identifier: UITableViewCell.Type {
        return SubscriptionServiceCell.self // it cocnreate cell
    }

    func generate(tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier.nameOfClass, for: indexPath) as? SubscriptionServiceCell else { return UITableViewCell() }

        self.build(view: cell)

        return cell
    }
}

// MARK: - ViewBuilder

extension SubscriptionServiceGenerator: ViewBuilder {

    func build(view: SubscriptionServiceCell) {
        view.delegate = self
        <# some logics #>
    }
}

// MARK: - SubscriptionServiceCellDelegate

extension SubscriptionServiceGenerator: SubscriptionServiceCellDelegate {

    func subscribtionButtonTouchid(in cell: SubscriptionServiceCell) {
        guard let service = self.model else { return }
        self.buyEvent.invoke(with: service)
    }
}
```
 - **Event**: is custom object, that may store closures, which have the same signatures, object that store an avent may call all stored closures for send objects, that provide this closures about event.

View wants to recive a message about user tap on button:
```swift
 var generator = SubscriptionServiceGenerator(model: service)
 generator.buyEvent += { (service: PaidService) -> Void in
    <# do something #>
 }
```

## How to install

`pod 'ReactiveDataDisplayManager' ~> 6.0.0`

## Errors

- `Could not load NIB in bundle ... with name 'YourCellName'`
This error appears because you are using class based cells (not UINib), but inside RDDM cells registering via UINib.

  **Your should override default registering in generator**
```swift
extension YourCellGenerator: TableCellGenerator {
  // ...

  func registerCell(in tableView: UITableView) {
      tableView.register(identifier, forCellReuseIdentifier: String(describing: identifier))
  }

  // ...
}
```

## Versioning

Version format is `x.y.z` where
- x is major version number. Bumped only in major updates (implementaion changes, adding new functionality)
- y is minor version number. Bumped only in minor updates (interface changes)
- z is minor version number. Bumped in case of bug fixes and e.t.c.

# How to start

In 99% of situations you don't need to create your own generators. There are plenty of generators that covers almost all you needs.

- each cell in generator could be registered in two ways: as a nib or as a class

## UITableView

### BaseCellGenerator & BaseNonReusableCellGenerator

Generators with selection event. They build `Configurable` cell and work with automatic demension. But the second one, as you can guess, doesn't reuse cell in tableView, so you can update your cell in any time.

**To work with it you should:**

- create `UITableViewCell`
- realize `Configurable` protocol
- initialize generator `let generator = BaseCellGenerator<YourTableViewCell>(with: YourTableViewCellModel())` or `let nonReusableGenerator = BaseNonReusableCellGenerator<YourTableViewCell>(with: YourTableViewCellModel())`
- if you have non-reusable generator, you can update cell `nonReusableGenerator.update(model: YourTableViewCellModel())`

### CalculatableHeightCellGenerator & CalculatableHeightNonReusableCellGenerator

Generators with selection event. They build `Configurable & CalculatableHeight` cell and work with cell that could calculate it's height. The second one, as you can guess, doesen't reuse cell in tableView, so you can update your cell in any time.

**To work with it you should:**

- create `UITableViewCell`
- realize `Configurable` and `CalculatableHeight` protocols
- initialize generator `let generator = CalculatableHeightCellGenerator<YourTableViewCell>(with: YourTableViewCellModel())` or `let nonReusableGenerator = CalculatableHeightNonReusableCellGenerator<YourTableViewCell>(with: YourTableViewCellModel())`
- if you have non-reusable generator, you can update cell `nonReusableGenerator.update(model: YourTableViewCellModel())`

### Which to choose

||Reusable|Non-reusable|
|---|---|---|
|AutomaticDimension|`BaseCellGenerator`|`BaseNonReusableCellGenerator`|
|Calculated height|`CalculatableHeightCellGenerator`|`CalculatableHeightNonReusableCellGenerator`|

## UICollectionView

### BaseCollectionCellGenerator

Base generator with selection event. It builds `Configurable` cell.

If you choose this generator, you should insert `itemSize` in `collectionViewFlowLayout` manually.

**To work with it you should:**

- create `UICollectionViewCell`
- realize `Configurable` protocol
- initialize generator `let generator = BaseCollectionCellGenerator<YourCollectionViewCell>(with: YourCollectionViewCellModel())`

### SizableCollectionDataDisplayManager & CalculatableHeightCollectionCellGenerator/CalculatableWidthCollectionCellGenerator

Manager and generators to work with different sizes (in one dimension - only different heights/widths).

**To work with it you should:**

- assign type of adapter - `SizableCollectionDataDisplayManager`
- create `UICollectionViewCell`
- realize `Configurable & CalculatableHeight/CalculatableWidth` protocols
- initialize generator `let generator = CalculatableHeightCollectionCellGenerator<YourCollectionViewCell>(with: YourCollectionViewCellModel(), width: 100) or let generator = CalculatableWidthCollectionCellGenerator<YourCollectionViewCell>(with: YourCollectionViewCellModel(), height: 100)`

### Which to choose

If you have cells with equal sizes, you should choose `BaseCollectionCellGenerator`.

But if you cell's should have different sizes in **one dimension**, you should use `SizableCollectionCollectionDataDisplayManager` and calculatable collection generators.

Otherwise you should provide your own adapter with collectionView delegate.

### Contributions

You can find the roadmap in file `ROADMAP.md`.
If you'd like to contribute, please feel free to create a PR.

Before you commit and push, make sure that you do it according to the rules:

* Your commit message really describes what it does
* At the beginning of the commit message there is a bug ID for example:

    `#42 Example commit message`

* You can push only in `feature|bug|hotfix/<branch-name>`

Install `githooks` before contributing:

```bash
git clone --depth=1 https://github.com/surfstudio/githooks.git ~/.githooks
echo "export PATH=~/.githooks:\$PATH" >> ~/.bashrc
```