//
//  SessionDetail.swift
//  Workout Scheduler
//
//  Created by Kevin Olmats on 2021-07-07.
//

import SwiftUI

struct SessionDetail: View {
    @AppStorage("schedules") var schedules: [Schedule] = []
    @Environment(\.editMode) var editMode
    @ObservedObject var session: Session
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if editMode?.wrappedValue == .active {
                    Picker("Session Type", selection: $session.type) {
                        ForEach(SessionType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized)
                                .id(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    DatePicker("Date", selection: $session.startDate)
                        .labelsHidden()
                } else {
                    HStack {
                        Text(session.type.rawValue.capitalized)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(session.type.tint)
                        Spacer()
                    }
                    
                    Text("\(session.startDate.formatted(date: .long, time: .shortened))")
                        .font(.title2)
                }

                Divider()
                    .padding(.bottom)
                
                ForEach($session.blocks) { $block in
                    HStack(alignment: .top) {
                        Image(systemName: "\((session.blocks.firstIndex(of: block) ?? -1) + 1).circle.fill")
                            .imageScale(.large)
                            .font(.title3)
                            .foregroundColor(tint(for: block.type))
                        
                        VStack(alignment: .leading) {
                            if editMode?.wrappedValue == .active {
                                TextField("Block Title", text: $block.title)
                                    .textFieldStyle(.roundedBorder)
                                    .foregroundColor(tint(for: block.type))
                            } else {
                                Text(block.title)
                                    .bold()
                                    .font(.title3)
                                    .foregroundColor(tint(for: block.type))
                            }

                            if editMode?.wrappedValue == .active {
                                Stepper("\(Int(block.duration / 60)) min.", value: $block.duration, in: 0...3600, step: 300)
                            } else {
                                Text("\(Int(block.duration / 60)) min.")
                            }
                            
                            if editMode?.wrappedValue == .active {
                                TextField("URL", text: $block.url)
                                    .autocapitalization(.none)
                                    .keyboardType(.URL)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        
                        Spacer()
                        
                        if editMode?.wrappedValue == .inactive, let urlString = block.url, let url = URL(string: urlString) {
                            Button("Link") {
                                UIApplication.shared.open(url)
                            }
                            .buttonStyle(.bordered)
                            .tint(tint(for: block.type))
                        }
                        
                    }
                    .padding(.bottom)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: EditButton())
        .onChange(of: editMode?.wrappedValue, perform: editModeChanged)
    }
    
    func tint(for type: BlockType) -> Color {
        switch type {
        case .strength:
            return session.type.tint
        case .cardio:
            return .red
        case .core:
            return .orange
        }
    }
    
    func editModeChanged(_: EditMode?) {
        guard let index = schedules.firstIndex(where: { $0.sessions.contains(session) }) else { return }
        schedules[index].objectWillChange.send()
    }
}

struct SessionDetail_Previews: PreviewProvider {
    static var previews: some View {
        let session = Session(type: .legs)
        session.populateBlocks(strength: Block(title: "Legs", type: .strength))
        
        for block in session.blocks where block.type != .strength {
            block.url = "www.google.ca"
        }
        
        return Group {
            NavigationView { SessionDetail(session: session) }
            NavigationView { SessionDetail(session: session).environment(\.editMode, .constant(.active)) }
        }
    }
}
