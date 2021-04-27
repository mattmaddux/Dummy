////
////  UserView.swift
////  TheLoop
////
////  Created by Matt Maddux on 10/22/20.
////
//
//import SwiftUI
//import Dummy
//
//
//// ======================================================= //
//// MARK: - Feed
//// ======================================================= //
//
//struct FeedExample: View {
//    
//    @StateObject var dummy = Dummy(itemCount: 10,                                   // Number of items to load at a time
//                                   minSnippetParagraphs: 3,                         // Minimum number of paragraphs in each snippet (ignored in previews)
//                                   maxTextParagraphs: 4,                            // Maximum number of paragraphs in each snippet (ignored in previews)
//                                   snippetParagraphLengths: [.short, .medium],      // Possible paragraph lengths for each snippet (ignored in previews)
//                                   searchQueries: ["travel", "nature"],             // Queries to search for when fetching photos and videos (ignroed in previews)
//                                   loadElements: [.user, .snippet, .photo])         // Which elements to load dynaimcally from the web. Excluded elements show preview placeholder
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                ForEach(dummy.items) { item in
//                    PostView(item: item)
//                }
//            }.navigationTitle("Feed")
//        }
//    }
//    
//    init() {
//        Dummy.pexelsAPIKey = "563492ad6f91700001000001968ef37ceca6463f8ffe9af71beacabb"
//    }
//}
//
//fileprivate struct PostView: View {
//    
//    var item: DummyItem
//    
//    var body: some View {
//        VStack {
//            HStack {
//                item.user.profilePicture
//                    .resizable()
//                    .scaledToFit()
//                    .clipShape(Circle())
//                    .frame(width: 100)
//                Text(item.user.name.full)
//                    .font(.title)
//                Spacer()
//            }
//            Text(item.snippet)
//                .font(.body)
//            if Bool.random() {
//                item.photo.image
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 350, height: 350)
//                    .clipped()
//            } else {
//                ZStack {
//                    item.video.screenshot
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 350, height: 200)
//                        .clipped()
//                    Image(systemName: "play.circle.fill")
//                        .font(.system(size: 100))
//                        .foregroundColor(.white)
//                        .opacity(0.4)
//                }
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(10)
//        .shadow(radius: 10)
//        .padding()
//    }
//}
//
//struct FeedExample_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
//
//// ======================================================= //
//// MARK: - User
//// ======================================================= //
//
//struct UserInfoView: View {
//    
//    @StateObject var dummy = Dummy()
//    
//    var body: some View {
//        List {
//            ForEach(dummy.items) { item in
//                VStack {
//                    Text(item.user.name.full)
//                    Text(item.user.email)
//                    Text(item.user.dob.date.description)
//                    Text(item.user.cell.description)
//                    item.user.profilePicture
//                }
//            }
//        }
//        
//    }
//}
//
//struct UserView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserInfoView()
//    }
//}
//
//// ======================================================= //
//// MARK: - Snippet
//// ======================================================= //
//
//struct SnippetView: View {
//    
//    @StateObject var dummy = Dummy()
//    
//    var body: some View {
//        List {
//            ForEach(dummy.items) { item in
//                Text(item.snippet)
//            }
//        }
//    }
//    
//}
//
//struct SnippetView_Previews: PreviewProvider {
//    static var previews: some View {
//        SnippetView()
//    }
//}
//
//// ======================================================= //
//// MARK: - Photo
//// ======================================================= //
//
//struct PhotoView: View {
//    
//    @StateObject var dummy = Dummy()
//    
//    var body: some View {
//        List {
//            ForEach(dummy.items) { item in
//                item.photo.image
//                    .resizable()
//                    .scaledToFit()
//                    .frame(maxHeight: 200)
//            }
//        }
//    }
//    
//    init() {
//        Dummy.pexelsAPIKey = "YOUR_KEY_HERE"
//    }
//}
//
//struct PhotoView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoView()
//    }
//}
//
//// ======================================================= //
//// MARK: - Video
//// ======================================================= //
//
//struct VideoView: View {
//    
//    @StateObject var dummy = Dummy()
//    
//    var body: some View {
//        List {
//            ForEach(dummy.items) { item in
//                VStack {
//                    Text(item.video.url.absoluteString)
//                    item.video.screenshot
//                        .resizable()
//                        .scaledToFit()
//                        .frame(maxHeight: 150)
//                }
//            }
//        }
//    }
//    
//    init() {
//        Dummy.pexelsAPIKey = "YOUR_KEY_HERE"
//    }
//}
//
//struct VideoView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoView()
//    }
//}
