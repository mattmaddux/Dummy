# Dummy
### Easy content for your mockups.
#### Users, text, and images. One line of code away. 


When you're mocking up your interface you don't want to use your time creating models, incorporating APIs, or finding placeholder data.

Dummy makes it easy to pull sample data like...

- Users - Including names, profile pictures, passwords, addresses, and more.
- Text - Get blocks of placeholder "lorem ipsum" text of varying lengths and styles.
- Media - Easily grab placeholder images and videos, either randomly or based on pre-defined search terms.

If you have needs for other data, open an issue and I'll see how I can integrate it!


## Installation

- Add the Swift package to your Xcode project
    1.`File` -> `Swift Packages` -> `Add Package Dependency`
    2. Enter `https://github.com/mattmaddux/Dummy`
- [For Photos and Videos] Get API Key
    1. Visit `https://www.pexels.com/api/` and click `Get Started`
    2. Create an account and get your API key
- [For Photos and Videos] Set Your API Key
    1. In the View or App struct that's referencing Dummy, create an init() method
    2. Add to your method: `Dummy.pexelsAPIKey = "YOUR_API_KEY"`


## Usage

When instantiated, Dummy loads placeholder data and stores it in it's `items` array. Each `DummyItem` has a `DummyUser`, `Snippet`, `DummyPhoto`, and `DummyVideo`.

It's then easy to use those when mocking up views.

#### Users

```
struct UserInfoView: View {
    
    @StateObject var dummy = Dummy()
    
    var body: some View {
        List {
            ForEach(dummy.items) { item in
                VStack {
                    Text(item.user.name.full)
                    Text(item.user.email)
                    Text(item.user.dob.date.description)
                    Text(item.user.cell.description)
                    item.user.profilePicture
                }
            }
        }
        
    }
}
```

[Preview Canvas Screenshot](https://raw.githubusercontent.com/mattmaddux/Dummy/master/Resources/Users.png)

#### Snippets

```
struct SnippetView: View {
    
    @StateObject var dummy = Dummy()
    
    var body: some View {
        List {
            ForEach(dummy.items) { item in
                Text(item.snippet)
            }
        }
    }
    
}
```

[Preview Canvas Screenshot](https://raw.githubusercontent.com/mattmaddux/Dummy/master/Resources/Snippets.png)

#### Photos

```
struct PhotoView: View {
    
    @StateObject var dummy = Dummy()
    
    var body: some View {
        List {
            ForEach(dummy.items) { item in
                item.photo.image
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
            }
        }
    }
    
    init() {
        Dummy.pexelsAPIKey = "YOUR_KEY_HERE"
    }
}
```

[Preview Canvas Screenshot](https://raw.githubusercontent.com/mattmaddux/Dummy/master/Resources/Photos.png)

#### Videos

```
struct VideoView: View {
    
    @StateObject var dummy = Dummy()
    
    var body: some View {
        List {
            ForEach(dummy.items) { item in
                VStack {
                    Text(item.video.url.absoluteString)
                    item.video.screenshot
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 150)
                }
            }
        }
    }
    
    init() {
        Dummy.pexelsAPIKey = "YOUR_KEY_HERE"
    }
}
```
[Preview Canvas Screenshot](https://raw.githubusercontent.com/mattmaddux/Dummy/master/Resources/Videos.png)

#### Custom Settings

You can easily customize the samples Dummy feteches, as well as excluding the types you don't need for faster loading. All parameters are optional

```
Dummy(itemCount: 10,                                   // Number of items to load at a time
      minSnippetParagraphs: 3,                         // Minimum number of paragraphs in each snippet (Ignored in previews)
      maxTextParagraphs: 4,                            // Maximum number of paragraphs in each snippet (Ignored in previews)
      snippetParagraphLengths: [.short, .medium],      // Possible paragraph lengths for each snippet (Ignored in previews)
      searchQueries: ["travel", "nature"],             // Queries to search for when fetching photos and videos (Ignroed in previews)
      loadElements: [.user, .snippet, .photo])         // Which elements to load dynaimcally from the web. Excluded elements show preview placeholder
```

[Preview Canvas Screenshot](https://raw.githubusercontent.com/mattmaddux/Dummy/master/Resources/Previews.png)

#### Previews

Because it's all loaded at launch, inital load can take a while, but once it's loaded it performs nicely.
Since you don't want that wait time when working in Xcode, when running previews samples are displayed instead.

// IMAGE HERE




#### Screencast

Take a look how you can design a (mediocre) social feed in minutes with Dummy!

[Imgur](https://i.imgur.com/3LOwyzw.gifv)



## Data Sources
User Data: https://randomuser.me
Text: https://loripsum.net
Photos & Videos: https://www.pexels.com
