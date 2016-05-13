// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Match.swift instead.

import Foundation
import CoreData

public enum MatchAttributes: String {
    case matchesImage = "matchesImage"
}

public class _Match: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Match"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Match.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var matchesImage: NSData?

    // MARK: - Relationships

}

