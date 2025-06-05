//
//  ManagedFeedImage.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/5/25.
//

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    static func images(from feed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        let array = feed.map {
            let managed = ManagedFeedImage(context: context)
            managed.id = $0.id
            managed.imageDescription = $0.description
            managed.location = $0.location
            managed.url = $0.url
            return managed
        }
        return NSOrderedSet(array: array)
    }
    
    var local: LocalFeedImage {
        LocalFeedImage(
            id: id,
            description: imageDescription,
            location: location,
            url: url
        )
    }
}
