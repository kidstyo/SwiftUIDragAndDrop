//
//  TagRow.swift
//  waterfall_design
//
//  Created by kidstyo on 2023/11/27.
//

import SwiftUI

struct TagRow: View {
    var tag: Tag
    @Binding var currentDragging: Tag?
    
    var replaceItem: (_ droppingTag: Tag) -> ()
    
    var isShowExpend: Bool
    @Binding var isExpend: Bool

    var body: some View {
        Label(
            title: {
                HStack(content: {
                    Text(tag.tag_name)
                        .onTapGesture {
                            
                        }
                    Spacer(minLength: 0)
                    Text("\(tag.sort_index)")
                        .foregroundStyle(tag.childs.isEmpty ? Color.secondary : .red)
                    
                    if isShowExpend{
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.accent)
                            .rotationEffect(.degrees(isExpend ? 90 : 0))
                    }
                })
                .fontDesign(.rounded)
            },
            icon: {
                Image(systemName: "number")
            }
        )
        .font(.callout)
        .padding(CONTENT_PADDING)
//        .background(.ultraThinMaterial)
        .background{
            if currentDragging != tag{
                RoundedRectangle(cornerRadius: ROW_RADIUS, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
            else{
                RoundedRectangle(cornerRadius: ROW_RADIUS, style: .continuous)
                    .fill(.green)
            }
        }
        .onTapGesture {
            withAnimation {
                isExpend.toggle()
            }
        }
        .allowsHitTesting(currentDragging != tag)
//        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: ROW_RADIUS, style: .continuous))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: ROW_RADIUS, style: .continuous))
//        .clipShape(RoundedRectangle(cornerRadius: ROW_RADIUS, style: .continuous))
        .draggable(tag.id.uuidString){
            Text(tag.tag_name)
                .font(.callout)
                .padding(CONTENT_PADDING)
                .contentShape(.dragPreview, RoundedRectangle(cornerRadius: ROW_RADIUS, style: .continuous))
                .clipShape(RoundedRectangle(cornerRadius: ROW_RADIUS, style: .continuous))
                .onAppear(perform: {
                    print("onAppear Drag")
                    isExpend = false
                    withAnimation {
                        currentDragging = tag
                    }
                })
                .onDisappear {
                    print("onDisappear Drag")
                }
        }
        .dropDestination(for: String.self) { items, location in
            print("dropDestination: \(tag.tag_name) - \(items.first ?? "nil")")
            withAnimation {
                currentDragging = nil
            }
            return true
        } isTargeted: { status in
            print("isTargeted?  \(status ? "Y" : "N")")
            if let currentDragging, status, currentDragging != tag{
                print("isTargeted✅")
                replaceItem(tag)
            }
        }
        .contextMenu(ContextMenu(menuItems: {
            Text("Menu Item 1")
            Text("Menu Item 2")
            Text("Menu Item 3")
        }))
    }
}
//
//#Preview {
//    TagRow()
//}
