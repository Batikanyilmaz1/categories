import SwiftUI



struct Category: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    var entries: [Entry] = []
    
}

struct Entry: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let income: Double
    let expense: Double
    var date: Date
}

class DataStore: ObservableObject {
    @Published var categories: [Category] = []
    static let shared = DataStore()
    
    init() {
        load()
    }
    
    func save() {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(categories)
            UserDefaults.standard.set(encoded, forKey: "categories")
        } catch {
            print(error.localizedDescription)
        }
    }

    func load() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "categories") {
            do {
                let decoded = try decoder.decode([Category].self, from: data)
                categories = decoded
            } catch {
                print(error.localizedDescription)
            }
        }
    }

}


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Create the SwiftUI view and set the context as the value for the environment keyPath
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: ContentView().environmentObject(DataStore.shared))
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        DataStore.shared.save()
    }
}
struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var newCategoryName: String = ""
    @State private var isEditing = false

    var body: some View {
        NavigationView {
            List {
                ForEach(dataStore.categories) { category in
                    NavigationLink(destination: CategoryView(category: binding(for: category))) {
                        Text(category.name)
                    }
                }
                .onMove { indices, newOffset in
                    dataStore.categories.move(fromOffsets: indices, toOffset: newOffset)
                    do {
                        try dataStore.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                .onDelete { indexSet in
                   
                        dataStore.categories.remove(atOffsets: indexSet)
                        do {
                            try dataStore.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    
                }
            }


            .navigationBarTitle("Categories")
            .navigationBarItems(leading: EditButton(), trailing:
                HStack {
                    TextField("New Category Name", text: $newCategoryName)
                    Button(action: {
                        let category = Category(name: newCategoryName)
                        dataStore.categories.append(category)
                        do {
                            try dataStore.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                        newCategoryName = ""
                    }) {
                        Image(systemName: "plus")
                    }
                    .disabled(newCategoryName.isEmpty)
                }
            )
            .environment(\.editMode, Binding(get: {
                self.isEditing ? .active : .inactive
            }, set: { newValue in
                self.isEditing = (newValue == .active)
            }))

        }
    }
    
    func binding(for category: Category) -> Binding<Category> {
        guard let index = dataStore.categories.firstIndex(of: category) else {
            fatalError("Can't find category in data store")
        }
        return $dataStore.categories[index]
    }
}

enum SortOption: String, CaseIterable {
    case name
    case income
    case expense
    case date
}


struct CategoryView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var category: Category
    @State var newName = ""
    @State var newIncome = ""
    @State var newExpense = ""
    @State var selectedDate = Date()
    @State var selectedEntry: Entry?
    @State var sortOption: SortOption = .name
    var dataPoints: [Double] {
        category.entries.map { $0.income - $0.expense }
    }

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    var totalIncome: Double {
        category.entries.reduce(0, { $0 + $1.income })
    }

    var totalExpense: Double {
        category.entries.reduce(0, { $0 + $1.expense })
    }

    var totalProfit: Double {
        totalIncome - totalExpense
    }
    
    

    var sortedEntries: [Entry] {
        switch sortOption {
        case .name:
            return category.entries.sorted { $0.name < $1.name }
        case .income:
            return category.entries.sorted { $0.income > $1.income }
        case .expense:
            return category.entries.sorted { $0.expense > $1.expense }
        case .date:
            return category.entries.sorted { $0.date > $1.date }
        }
    }

    var body: some View {
        List {
            Section(header: Text("Add a new entry")) {
                TextField("Name", text: $newName)
                TextField("Income", text: $newIncome)
                    .keyboardType(.numberPad)
                TextField("Expense", text: $newExpense)
                    .keyboardType(.numberPad)
                DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                Button(action: {
                    guard let income = Double(newIncome),
                          let expense = Double(newExpense) else {
                        return
                    }
                    let entry = Entry(name: newName, income: income, expense: expense, date: selectedDate)
                    category.entries.append(entry)
                    do {
                        try dataStore.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    selectedEntry = entry
                    newName = ""
                    newIncome = ""
                    newExpense = ""
                }) {
                    Text("Add Entry")
                }
            }

            Section(header: Text("Entries")) {
                Picker("Sort By", selection: $sortOption) {
                    Text("Name").tag(SortOption.name)
                    Text("Income").tag(SortOption.income)
                    Text("Expense").tag(SortOption.expense)
                    Text("Date").tag(SortOption.date)
                }
                .pickerStyle(.segmented)

                ForEach(sortedEntries, id: \.name) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.date, formatter: dateFormatter)
                        Text(entry.name)
                        Text("Income: \(entry.income, specifier: "%.2f")")
                        Text("Expense: \(entry.expense, specifier: "%.2f")")
                    }
                }
                .onDelete { indexSet in
                    category.entries.remove(atOffsets: indexSet)
                    do {
                        try dataStore.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }

            Section {
                HStack {
                    Spacer()
                    VStack {
                        Text("Total Income")
                        Text("\(totalIncome, specifier: "%.2f")")
                    }
                    Spacer()
                    VStack {
                        Text("Total Expense")
                        Text("\(totalExpense, specifier: "%.2f")")
                    }
                    Spacer()
                    VStack {
                        Text("Total Profit")
                        Text("\(totalProfit, specifier: "%.2f")")
                    }
                    Spacer()
                }
            }
            
        }
        .navigationBarTitle(category.name)
        .onDisappear {
            do {
                try dataStore.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataStore())
    }
}

