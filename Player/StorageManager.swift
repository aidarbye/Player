import Foundation
import CoreData

class StorageManager {
    static let shared = StorageManager()
    let container = NSPersistentContainer(name: "AudioFile")
    init() {
        container.loadPersistentStores { _, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
