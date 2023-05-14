////
// Copyright (c) whirlun <whirlun@yahoo.co.jp>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//
//

import Foundation
import CoreData


extension Folder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Folder> {
        return NSFetchRequest<Folder>(entityName: "Folder")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var articles: NSSet?

}

// MARK: Generated accessors for articles
extension Folder {

    @objc(addArticlesObject:)
    @NSManaged public func addToArticles(_ value: Article)

    @objc(removeArticlesObject:)
    @NSManaged public func removeFromArticles(_ value: Article)

    @objc(addArticles:)
    @NSManaged public func addToArticles(_ values: NSSet)

    @objc(removeArticles:)
    @NSManaged public func removeFromArticles(_ values: NSSet)

}

extension Folder : Identifiable {

}
