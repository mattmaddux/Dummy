
//
//  SwiftUIView.swift
//
//
//  Created by Matt Maddux on 11/9/20.
//

import SwiftUI
import AVKit


public struct DummyPicker: View {
    
    @State private var tab: Int = 3
    
    @State private var editMode: EditMode = EditMode.inactive
    
    public var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack {
                    Picker("", selection: $tab) {
                        Image(systemName: "person").tag(0)
                        Image(systemName: "text.alignleft").tag(1)
                        Image(systemName: "photo").tag(2)
                        Image(systemName: "video").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    ZStack {
                        UserList()
                            .offset(x: tab > 0 ? -geo.size.width : 0)
                            .animation(.easeOut)
                        SnippetList()
                            .offset(x: tab > 1 ? -geo.size.width : tab < 1 ? geo.size.width : 0)
                            .animation(.easeOut)
                        PhotoList()
                            .offset(x: tab > 2 ? -geo.size.width : tab < 2 ? geo.size.width : 0)
                            .animation(.easeOut)
                        VideoList()
                            .offset(x: tab < 3 ? geo.size.width : 0)
                            .animation(.easeOut)
                    }
                }
                .navigationBarItems(trailing: EditButton())
                .navigationTitle("Dummy Picker")
                .environment(\.editMode, $editMode)
            }
        }
    }
    
    public init() { }
}

fileprivate struct LoadButton: View {

    var dummy: Dummy
    
    var body: some View {
        Section {
            Button("Load More", action: dummy.loadNextPage)
        }
    }
    
}

// ======================================================= //
// MARK: - Videos
// ======================================================= //

fileprivate struct VideoList: View {
    
    @StateObject var dummy = Dummy(loadElements: [.video], showSaved: false)
    
    @Environment(\.editMode) var editMode
    
    var body: some View {
        Form {
            Section(header: Text("Saved Videos")) {
                ForEach(dummy.savedVideos) { savedVideo in
                    VideoCell(video: savedVideo, dummy: dummy, saved: true)
                }
                .onMove { indexSet, dest in
                    dummy.moveSaved(dummyType: .video, fromIndex: indexSet, toIndex: dest)
                }
                .onDelete(perform: { indexSet in
                    dummy.remove(dummyType: .video, atIndexSet: indexSet)
                })
            }
            if editMode!.wrappedValue == EditMode.inactive {
                Section(header: Text("Fetch Settings")) {
                    TextField("Search Queries", text: $dummy.searchQuery, onCommit: dummy.reload)
                    Button("Reload", action: dummy.reload)
                }
                Section(header: Text("Fetched Videos")) {
                    ForEach(dummy.items) { item in
                        VideoCell(video: item.video, dummy: dummy, saved: false)
                    }
                    if dummy.loading {
                        ProgressView()
                    }
                }
                if !dummy.loading {
                    LoadButton(dummy: dummy)
                }
            }
        }
    }
}



fileprivate struct VideoCell: View {
    
    var video: DummyVideo
    var dummy: Dummy
    var saved: Bool
    
    var body: some View {
        VStack {
            ZStack {
                video.screenshot
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: 0, maxWidth: .infinity)
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.white)
                    .opacity(0.6)
            }
            if !saved {
                Button("Save") {
                    self.dummy.save(dummyData: self.video)
                }
                .foregroundColor(.white)
                .font(.title2)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(15)
            }
        }
        .padding(.vertical)
    }
}

// ======================================================= //
// MARK: - Photos
// ======================================================= //

fileprivate struct PhotoList: View {
    
    @StateObject var dummy: Dummy = Dummy(loadElements: [.photo], showSaved: false)
    
    @Environment(\.editMode) var editMode
    
    var body: some View {
        Form {
            Section(header: Text("Saved Photos")) {
                ForEach(dummy.savedPhotos) { savedPhoto in
                    PhotoCell(photo: savedPhoto, dummy: dummy, saved: true)
                }
                .onMove { indexSet, dest in
                    dummy.moveSaved(dummyType: .photo, fromIndex: indexSet, toIndex: dest)
                }
                .onDelete(perform: { indexSet in
                    dummy.remove(dummyType: .photo, atIndexSet: indexSet)
                })
            }
            if editMode!.wrappedValue == EditMode.inactive {
                Section(header: Text("Fetch Settings")) {
                    TextField("Search Queries", text: $dummy.searchQuery, onCommit: dummy.reload)
                    Button("Reload", action: dummy.reload)
                }
                Section(header: Text("Fetched Photos")) {
                    ForEach(dummy.items) { item in
                        PhotoCell(photo: item.photo, dummy: dummy, saved: false)
                    }
                    if dummy.loading {
                        ProgressView()
                    }
                }
                if !dummy.loading {
                    LoadButton(dummy: dummy)
                }
            }
        }
    }
}



fileprivate struct PhotoCell: View {
    
    var photo: DummyPhoto
    var dummy: Dummy
    var saved: Bool
    
    var body: some View {
        VStack {
            photo.image
                .resizable()
                .scaledToFit()
                .frame(minWidth: 0, maxWidth: .infinity)
            if !saved {
                Button("Save") {
                    self.dummy.save(dummyData: self.photo)
                }
                .foregroundColor(.white)
                .font(.title2)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(15)
            }
        }
        .padding(.vertical)
    }
}


// ======================================================= //
// MARK: - Snippets
// ======================================================= //

fileprivate struct SnippetList: View {
    
    @StateObject var dummy: Dummy = Dummy(loadElements: [.snippet], showSaved: false)
    
    @Environment(\.editMode) var editMode
    
    var body: some View {
        Form {
            Section(header: Text("Saved Snippets")) {
                ForEach(dummy.savedSnippets, id: \.self) { savedSnippet in
                    SnippetCell(snippet: savedSnippet, dummy: dummy, saved: true)
                }
                .onMove { indexSet, dest in
                    dummy.moveSaved(dummyType: .snippet, fromIndex: indexSet, toIndex: dest)
                }
                .onDelete(perform: { indexSet in
                    dummy.remove(dummyType: .snippet, atIndexSet: indexSet)
                })
            }
            if editMode!.wrappedValue == EditMode.inactive {
                Section(header: Text("Fetch Settings")) {
                    Stepper(value: $dummy.minPara, in: 1...10) {
                        Text("Para. Count Minimum: \(dummy.minPara)")
                    }
                    Stepper(value: $dummy.maxPara, in: 1...10) {
                        Text("Para. Count Maximum: \(dummy.maxPara)")
                    }
                    LengthToggler(dummy: dummy)
                    Button("Reload", action: dummy.reload)
                }
                Section(header: Text("Fetched Snippets")) {
                    ForEach(dummy.items) { item in
                        SnippetCell(snippet: item.snippet, dummy: dummy, saved: false)
                    }
                    if dummy.loading {
                        ProgressView()
                    }
                }
                if !dummy.loading {
                    LoadButton(dummy: dummy)
                }
            }
        }
    }
    
}

fileprivate struct LengthToggler: View {
    
    var dummy: Dummy
    
    func binding(for length: SnippetParagraphLength) -> Binding<Bool> {
        Binding(get: {
            self.dummy.lengths.contains(length)
        },
        set: { shouldInclude in
            if shouldInclude {
                self.dummy.lengths.insert(length)
            } else {
                self.dummy.lengths.remove(length)
            }
        })
    }
    
    var body: some View {
        ForEach(SnippetParagraphLength.allCases, id: \.hashValue) { length in
            Toggle("\(length.rawValue.capitalized) Paragraphs", isOn: self.binding(for: length))
        }
    }
    
}

fileprivate struct SnippetCell: View {
    
    var snippet: String
    var dummy: Dummy
    var saved: Bool
    
    
    var body: some View {
        VStack {
            Text(snippet)
            if !saved {
                Button("Save") {
                    self.dummy.save(dummyData: self.snippet)
                }
                .foregroundColor(.white)
                .font(.title2)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(15)
            }
        }
        .padding(.vertical)
    }
    
}

// ======================================================= //
// MARK: - Users
// ======================================================= //

fileprivate struct UserList: View {
    
    @StateObject var dummy = Dummy(loadElements: [.user], showSaved: false)
    
    @Environment(\.editMode) var editMode
    
    var body: some View {
        Form {
            Section(header: Text("Saved Users")) {
                ForEach(dummy.savedUsers) { savedUser in
                    UserCell(user: savedUser, dummy: dummy, saved: true)
                        
                }
                .onMove { indexSet, dest in
                    dummy.moveSaved(dummyType: .user, fromIndex: indexSet, toIndex: dest)
                }
                .onDelete(perform: { indexSet in
                    dummy.remove(dummyType: .user, atIndexSet: indexSet)
                })
            }
            if editMode!.wrappedValue == EditMode.inactive {
                Section(header: Text("Fetch Settings")) {
                    NationalityToggler(dummy: self.dummy)
                    Button("Reload", action: dummy.reload)
                }
                Section(header: Text("Fetched Users")) {
                    ForEach(dummy.items) { item in
                        UserCell(user: item.user, dummy: dummy, saved: false)
                    }
                    if dummy.loading {
                        ProgressView()
                    }
                }
                if !dummy.loading {
                    LoadButton(dummy: dummy)
                }
            }
        }
    }
}

fileprivate struct UserCell: View {
    
    var user: DummyUser
    var dummy: Dummy
    var saved: Bool
    
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    user.profilePicture
                        .resizable()
                        .scaledToFit()
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        .frame(width: 100)
                    Spacer()
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text(user.name.full)
                        .font(.headline)
                    Text(user.gender.rawValue.capitalized)
                        .font(.footnote)
                    Text(user.location.address)
                        .font(.footnote)
                    Text(user.dob.date.simple)
                        .font(.footnote)
                    
                }
                Spacer()
            }
            if !saved {
                Button("Save") {
                    self.dummy.save(dummyData: self.user)
                }
                .foregroundColor(.white)
                .font(.title2)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(15)
                .padding(.top)
            }
        }
        .padding(.vertical)
    }
    
}

fileprivate struct NationalityToggler: View {
    
    var dummy: Dummy
    
    func binding(for nationality: DummyUser.Nationality) -> Binding<Bool> {
        Binding(get: {
            self.dummy.userNationalities.contains(nationality)
        },
        set: { shouldInclude in
            if shouldInclude {
                self.dummy.userNationalities.insert(nationality)
            } else {
                self.dummy.userNationalities.remove(nationality)
            }
        })
    }
    
    var body: some View {
        ForEach(DummyUser.Nationality.allCases, id: \.hashValue) { nationality in
            Toggle("Include Nationality: \(nationality.rawValue)", isOn: self.binding(for: nationality))
        }
    }
    
}

//
//struct DummyPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        DummyPicker().environmentObject(Dummy())
//    }
//}
