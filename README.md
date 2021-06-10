# KeyWindow

This package provides a way to share values from the `key` window to all other parts of your application.  (the `key` window in macOS/iPadOS is the window that currently responds to keyboard shortcuts).



The main use-case of this package is to make it possible to pass values from the `key` window to views in the `commands` section of a SwiftUI lifecycle application.


```swift
import KeyWindow

@main
struct ExampleWindowReaderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().observeWindow()
        }.commands {
            CommandMenu("MyMenue") {
                MenuButton()
            }
        }
    }
}
```
**Notice** it is important to wrap the `ContentView` of your app with the `.observeWindow()` modifier, this enables `KeyWindow` to observe this window and the values it publishes.

Within our `ContentView` and its children we can publish values in a similar way to publishing [Preferences](https://developer.apple.com/documentation/swiftui/preferencekey).

First create a struct that conforms to `KeyWindowValueKey` and declare the value type.

```swift
struct SelectedProjectWindowValueKey: KeyWindowValueKey {
    typealias Value = Binding<UUID>
}

struct SelectedProjectTitleWindowValueKey: KeyWindowValueKey {
    typealias Value = String
}
```

Then to provide these within our views we can set these using `.keyWindow(SelectedProjectWindowValueKey.self, $projectSelection)`.  This will bubble up and when the window becomes `key` then we can read these values within our `MenuButton`.

```swift

struct MenuButton: View {
    @KeyWindowValue(SelectedProjectTitleWindowValueKey.self)
    var title: String
    
    @KeyWindowValueBinding(SelectedProjectWindowValueKey.self)
    var selectedProject: UUID?

    var body: some View {
        Button(action: {
            // Delete the selectedProject
            self.selectedProject = // some other project
        }, label: {
            Text("Delete \(title)")
        })
    }
}
```

**NOTE** you can't use `@KeyWindowValue` or `@KeyWindowValueBinding` in a `struct MyCommands: Commands` type. You need to extract the `Buttons` from the `Commands` body into their own Views so that you can use these property wrappers (this is a limitations of SwiftUI). 

For a little more detail on  common pattern is to share the document from the key window so that is it accessible within the commands section [this blog post](https://lostmoa.com/blog/KeyWindowABetterWayOfExposingValuesFromTheKeyWindow/) covers this use-case. 

You can also use `@KeyWindowValue` and `@KeyWindowValueBinding` in your other views but be **careful to ensure they do not result in `.keyWindow` modifiers being re-called otherwise it is possible to get into a loop.** The best way to do this is to set all your `.keyWindow` high up in your view hierarchy and only use `@KeyWindowValue` and `@KeyWindowValueBinding` on deeply nested child views.

In addition this package also provides a `EnvironmentValues.isKeyWindow` that can be read to detect if the view is in the `key` window. (you might use this to change the style of rendering). Note this is not the same as `scenePhase`,  `scenePhase` indicates if the scene is `active` not if the window for the view is in the Key Window. On iPadOS and macOS you can have multiple scenes active and on macOS each Scene can have many windows but only one of them will be key at any given time.

## Finding the correct property wrapper for your value type

Depending on the data type you are trying to share from your key window there are a few different property wrappers you can use to read the value:

| Type                           |      Property Wrapper          |  Comment                                                                                                          |
|--------------------------------|:------------------------------:|------------------------------------------------------------------------------------------------------------------:|
|`"String"` , `42` or  `MyStruct`|`@KeyWindowValue`               | For performance reasons it is best if these value types conform to equatable |
|`Binding<MyStruct>`             |`@KeyWindowValueBinding`        |  -                                                                                                                |
|`Binding<Optional<MyStruct>>`   |`@KeyWindowOptionalValueBinding`|  -                                                                                                                |
|`Observable` Object             | `@KeyWindowObservableObject`   | The `Key` in this case needs to conform to `KeyWindowObservableObjectKey` and provide a `defaultValue`     |
