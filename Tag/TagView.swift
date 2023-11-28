//
//  TagView.swift
//  waterfall_design
//
//  Created by kidstyo on 2023/11/27.
//

import SwiftUI

let CONTENT_PADDING: CGFloat = 8
let ROW_RADIUS: CGFloat = 10
let ROW_PADDING_LEADING: CGFloat = 20

struct TagView: View {
    @State private var firstTags: [Tag] = []
    @State private var allTags: [Tag] = []
    @State private var currentDragging: Tag?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(pinnedViews: [.sectionHeaders], content: {
                HStack(content: {
                    Text("Tag")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .fontDesign(.serif)
                    Spacer()
                })
                .padding(.top, 10)
                .padding(.bottom, 32)
                .padding(.horizontal, 20)

                Section {
                    ForEach(firstTags) {firstTag in
                        TagGroup(tag: firstTag, currentDragging: $currentDragging, allTags: allTags, replaceItem: replaceItem)
                    }
                } header: {
                    HStack(content: {
                        Text("一级标签数量: \(firstTags.count)")
//                            .fontDesign(.rounded)
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                        Spacer()
                    })
                    .padding(.horizontal, CONTENT_PADDING)
                    .padding(.bottom, 7)
//                            .background(.background)
                } footer: {
                    HStack(content: {
                        Text("标签总数量: \(allTags.count)")
                            .font(.footnote)
                            .fontWeight(.medium)
//                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                        Spacer()
                    })
                    .padding(.top, 7)
                    .padding(.horizontal, CONTENT_PADDING)
                }
                // 不放最外面是为了 长按没有一开始被挡住的
                .padding(.horizontal, 20)
            })
        }
        .dropDestination(for: String.self) { items, location in
            print("dropDestination: background")
            withAnimation {
                currentDragging = nil
            }
            return false
        }
        .onAppear{
            if firstTags.isEmpty{
                for index_1 in 0..<3{
                    let tagLayer_1 = Tag(id: UUID(), tag_name: "tagLayer_1_\(index_1)", sort_index: index_1, parent: nil, childs: [])
                    for index_2 in 0..<3{
                        let tagLayer_2 = Tag(id: UUID(), tag_name: "tagLayer_2_\(index_2)", sort_index: index_2, parent: tagLayer_1, childs: [])
                        for index_3 in 0..<2{
                            let tagLayer_3 = Tag(id: UUID(), tag_name: "tagLayer_3_\(index_3)", sort_index: index_3, parent: tagLayer_2, childs: [])
                            tagLayer_2.childs.append(tagLayer_3)
                            allTags.append(tagLayer_3)
                        }
                        tagLayer_1.childs.append(tagLayer_2)
                        allTags.append(tagLayer_2)
                    }
                    
                    firstTags.append(tagLayer_1)
                    allTags.append(tagLayer_1)
                }
            }
        }
    }
  
    func replaceItem(_ droppingTag: Tag){
        if let currentDragging{
            withAnimation(.snappy) {
                if currentDragging.parent == droppingTag.parent{
                    onSameParent(currentDragging, droppingTag)
                }
                else{
                    // 先修改 parent
                    if currentDragging.parent == nil{
                        firstTags.removeAll(where: {$0 == currentDragging})
                    }
                    else{
                        currentDragging.parent?.childs.removeAll(where: {$0 == currentDragging})
                    }
                    
                    let newParent = droppingTag.parent
                    currentDragging.parent = newParent
                    if newParent == nil{
                        firstTags.append(currentDragging)
                    }
                    else{
                        newParent?.childs.append(currentDragging)
                    }
                    onSameParent(currentDragging, droppingTag)
                }
            }
        }
    }
    
    private func onSameParent(_ currentDragging: Tag, _ droppingTag: Tag){
        if droppingTag.parent == nil{
            if let sourceIndex = firstTags.firstIndex(where: {$0 == currentDragging}),
               let destinationIndex = firstTags.firstIndex(where: {$0 == droppingTag}){
                let sourceItem = firstTags.remove(at: sourceIndex)
                firstTags.insert(sourceItem, at: destinationIndex)
                
                for sort_index in 0..<firstTags.count {
                    firstTags[sort_index].sort_index = sort_index
                }
            }
        }
        else if let childs = droppingTag.parent?.childs{
            if let sourceIndex = childs.firstIndex(where: {$0 == currentDragging}),
               let destinationIndex = childs.firstIndex(where: {$0 == droppingTag}){
                if let sourceItem = droppingTag.parent?.childs.remove(at: sourceIndex){
                    droppingTag.parent?.childs.insert(sourceItem, at: destinationIndex)
                    
                    for sort_index in 0..<(droppingTag.parent?.childs.count ?? 0) {
                        droppingTag.parent?.childs[sort_index].sort_index = sort_index
                    }
                }
            }
        }
    }
    
    //                            replaceItem(tags: &firstTags, droppingTag: droppingTag, currentDragging: dragTag)

    /// Replaing Items Within the List
    func replaceItem(tags: inout [Tag], droppingTag: Tag, currentDragging: Tag){
        if let sourceIndex = tags.firstIndex(where: {$0.id == currentDragging.id}),
           let destinationIndex = tags.firstIndex(where: {$0.id == droppingTag.id}){
            let sourceItem = tags.remove(at: sourceIndex)
            tags.insert(sourceItem, at: destinationIndex)
        }
    }
}

#Preview {
    TagView()
}

class Tag: ObservableObject, Equatable, Identifiable{
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id
    }
    
    @Published var id: UUID
    @Published var tag_name: String
    @Published var sort_index: Int
    
    @Published var parent: Tag?
    @Published var childs: [Tag]
    
    init(id: UUID, tag_name: String, sort_index: Int, parent: Tag? = nil, childs: [Tag]) {
        self.id = id
        self.tag_name = tag_name
        self.sort_index = sort_index
        self.parent = parent
        self.childs = childs
    }
}
