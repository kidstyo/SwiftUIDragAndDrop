//
//  TagGroup.swift
//  waterfall_design
//
//  Created by kidstyo on 2023/11/27.
//

import SwiftUI

struct TagGroup: View {
    @ObservedObject var tag: Tag
    @Binding var currentDragging: Tag?
    var allTags: [Tag]
    var replaceItem: (_ droppingTag: Tag) -> ()

    @State private var isExpend = false
    
    var body: some View {
        if tag.childs.isEmpty{
            TagRow(tag: tag, currentDragging: $currentDragging, replaceItem: replaceItem, isShowExpend: false, isExpend: $isExpend)
        }
        else{
            TagRow(tag: tag, currentDragging: $currentDragging, replaceItem: replaceItem, isShowExpend: true, isExpend: $isExpend)
            
            if isExpend{
                VStack(alignment: .leading, spacing: 5, content: {
                    ForEach(tag.childs) {child in
                        TagGroup(tag: child, currentDragging: $currentDragging, allTags: allTags, replaceItem: replaceItem)
                    }
                })
                .padding(.leading, ROW_PADDING_LEADING)
            }
//            if currentDragging != tag{
//               
//            }
        }
    }
}

//#Preview {
//    TagGroup()
//}
