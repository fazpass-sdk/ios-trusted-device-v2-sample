//
//  ContentView.swift
//  ios-trusted-device-v2-sample
//
//  Created by Andri nova riswanto on 23/10/24.
//

import SwiftUI

struct ContentView: View {
    
    let fazpassService = FazpassService()
    let seamlessService = SeamlessService()
    
    @ObservedObject private var viewModel = ListViewModel()
    
    @ViewBuilder
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List(viewModel.items, id: \.id) { item in
                switch (item.data) {
                case .text(let data):
                    VStack {
                        Text(data.title)
                            .bold()
                            .font(.headline)
                            .padding(EdgeInsets(top: 4.0, leading: 0.0, bottom: 8.0, trailing: 0.0))
                        Text(data.value)
                            .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 8.0, trailing: 0.0))
                    }
                case .button(let data):
                    Button(data.text, action: data.onClick)
                }
            }
            Button {
                viewModel.removeAll()
                fazpassService.generateMeta(onError: onError) {
                    let meta = fazpassService.meta
                    viewModel.addText(title: "Generated Meta", value: meta)
                    
                    viewModel.addButton(text: "Check") {
                        viewModel.removeLast(count: 1)
                        seamlessService.check(meta: meta, onError: onError) { cResponse in
                            viewModel.addText(title: "Check Response", value: cResponse)
                            
                            viewModel.addButton(text: "Enroll") {
                                viewModel.removeLast(count: 3)
                                seamlessService.enroll(meta: meta, onError: onError) { eResponse in
                                    viewModel.addText(title: "Enroll Response", value: eResponse)
                                    viewModel.addText(title: "End", value: "Generate new meta to restart")
                                }
                            }
                            
                            viewModel.addButton(text: "Validate") {
                                viewModel.removeLast(count: 3)
                                seamlessService.validate(meta: meta, onError: onError) { vResponse in
                                    viewModel.addText(title: "Validate Response", value: vResponse)
                                    viewModel.addText(title: "End", value: "Generate new meta to restart")
                                }
                            }
                            
                            viewModel.addButton(text: "Remove") {
                                viewModel.removeLast(count: 3)
                                seamlessService.remove(meta: meta, onError: onError) { rResponse in
                                    viewModel.addText(title: "Remove Response", value: rResponse)
                                    viewModel.addText(title: "End", value: "Generate new meta to restart")
                                }
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title.weight(.semibold))
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .shadow(radius: 4, x: 0, y: 4)
            }
            .padding()
        }
    }
    
    func onError(e: Error) {
        viewModel.addText(
            title: "Error",
            value: e.localizedDescription
        )
    }
}

#Preview {
    ContentView()
}

private class ListViewModel: ObservableObject {
    private var idIncrementer = 0
    @Published var items: [ViewData] = []
    
    func addText(title: String, value: String) {
        DispatchQueue.main.sync {
            self.items.append(
                ViewData(
                    id: self.idIncrementer,
                    data: .text(
                        TextData(
                            title: title,
                            value: value
                        )
                    )
                )
            )
        }
        idIncrementer += 1
    }
    
    func addButton(text: String, onClick: @escaping () -> Void) {
        DispatchQueue.main.sync {
            self.items.append(
                ViewData(
                    id: self.idIncrementer,
                    data: .button(
                        ButtonData(
                            text: text,
                            onClick: onClick
                        )
                    )
                )
            )
        }
        idIncrementer += 1
    }
    
    func removeLast(count: Int) {
        for _ in 0..<count {
            items.removeLast()
        }
    }
    
    func removeAll() {
        items.removeAll()
    }
}

private enum DataType {
    case text (TextData)
    case button (ButtonData)
}

private class ViewData: Identifiable {
    var id: Int
    var data: DataType
    
    init(id: Int, data: DataType) {
        self.id = id
        self.data = data
    }
}

private struct TextData {
    var title: String
    var value: String
}

private struct ButtonData {
    var text: String
    var onClick: () -> Void
}
