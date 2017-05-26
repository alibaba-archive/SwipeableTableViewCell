# SwipeableTableViewCell
SwipeableTableViewCell is a quite easy-to-use UITableViewCell subclass which allows you to add multiple highly customizable swipe actions.

![Example](Gif/SwipeableTableViewCellExample.gif "SwipeableTableViewCellExample")

## How To Get Started
### Carthage
Specify "SwipeableTableViewCell" in your ```Cartfile```:
```ogdl 
github "teambition/SwipeableTableViewCell"
```

### Usage
#### 1. TableViewController
Import "SwipeableTableViewCell":
```swift
import SwipeableTableViewCell
```
Configure cell in the data source like this:
```swift
override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? SwipeableTableViewCell
    if cell == nil {
        cell = SwipeableTableViewCell(style: .default, reuseIdentifier: "Cell")
    }

    // assign delegate if needed
    cell!.delegate = self

    // configure cell swipe actions
    let deleteTitle = NSAttributedString(string: "删除", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
    var deleteAction = SwipeableCellAction(title: deleteTitle, image: UIImage(named: "delete-icon"), backgroundColor: UIColor.red) { _ in
        // do something when "deleteAction" is selected
    }
    let laterTitle = NSAttributedString(string: "稍后处理", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
    var laterAction = SwipeableCellAction(title: laterTitle, image: UIImage(named: "later-icon"), backgroundColor: UIColor.blue) { _ in
        // do something when "laterAction" is selected
    }
    deleteAction.width = 100
    deleteAction.verticalSpace = 6
    laterAction.width = 100
    laterAction.verticalSpace = 6
    cell!.actions = [deleteAction, laterAction]

    // other configurations
    cell!.textLabel?.text = "Cell"

    return cell!
}
```

#### 2.  Implement delegate if needed
```swift
func swipeableCell(_ cell: SwipeableTableViewCell, isScrollingToState state: SwipeableCellState) {
    // do something
}

func swipeableCellSwipeEnabled(_ cell: SwipeableTableViewCell) -> Bool {
    // cell swipe enabled or not, default value is true
}

func allowMultipleCellsSwipedSimultaneously() -> Bool {
    // allow multiple cells swiped simultaneously or not, default value is false
}

func swipeableCellDidEndScroll(_ cell: SwipeableTableViewCell) {
    // do something
}
```

## Minimum Requirement
iOS 8.0

## Release Notes
* [Release Notes](https://github.com/teambition/SwipeableTableViewCell/releases)

## License
SwipeableTableViewCell is released under the MIT license. See [LICENSE](https://github.com/teambition/SwipeableTableViewCell/blob/master/LICENSE.md) for details.

## More Info
Have a question? Please [open an issue](https://github.com/teambition/SwipeableTableViewCell/issues/new)!
