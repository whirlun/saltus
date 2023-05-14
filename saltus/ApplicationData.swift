////
// Copyright (c) whirlun <whirlun@yahoo.co.jp>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import SwiftUI
import CoreData
import WebView

class ApplicationData: ObservableObject {
    static var applicationData = ApplicationData()
    let container: NSPersistentContainer
    @Environment(\.dismiss) private var dismiss
    @Published var selected_article: Article.ID?
    @Published var selected_folder: Folder.ID?
    @Published var webViewStore: WebViewStore
    @Published var content_observer: ArticleContentObserver = ArticleContentObserver()
    @Published var refreshingID = UUID()
    @Published var right_bar: Bool
    @Published var preview_mode: Bool
    @Published var plugin_host: PluginHost
    init() {
        container = NSPersistentContainer(name: "ApplicationModel")
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { _, error in
            print("\(String(describing: error))")
        })
        let webViewWrapper = WebViewWrapper()
        webViewStore = WebViewStore(webView: webViewWrapper.webView)
        selected_article = nil
        selected_folder = nil
        right_bar = true
        preview_mode = false
        plugin_host = PluginHost()
    }
    
    
    //TODO: Change to generic function
    func getArticleById(id: Article.ID) -> Article?{
        do {
            let fetch_request: NSFetchRequest<Article> = NSFetchRequest(entityName: "Article")
            fetch_request.predicate = NSPredicate(format: "id = %@", id! as CVarArg)
            let fetched_article = try container.viewContext.fetch(fetch_request)
            if let article = fetched_article.first {
                return article
            }
        } catch {
            print("\(error)")
        }
        return nil
    }
    
    func getFolderById(id: Folder.ID?) -> Folder?{
        guard let id = id else {return nil}
        do {
            let fetch_request: NSFetchRequest<Folder> = NSFetchRequest(entityName: "Folder")
            fetch_request.predicate = NSPredicate(format: "id = %@", id! as CVarArg)
            let fetched_folder = try container.viewContext.fetch(fetch_request)
            if let folder = fetched_folder.first {
                return folder
            }
        } catch {
            print("\(error)")
        }
        return nil
    }
    
    func getArticlesByFolder(id: Folder.ID?) -> [Article]? {
        guard let id = id else {return nil}
        do {
            let fetch_request: NSFetchRequest<Folder> = NSFetchRequest(entityName: "Folder")
            fetch_request.predicate = NSPredicate(format: "id = %@", id! as CVarArg)
            let fetched_folder = try container.viewContext.fetch(fetch_request)
            if let folder = fetched_folder.first {
                return folder.articles?.map {$0 as! Article}
            }
        } catch {
            print("\(error)")
        }
        return nil
    }
    
    func storeArticle(title: String, content: String) async{
        guard let folder = getFolderById(id: selected_folder) else {return}
        await container.viewContext.perform {
            let newArticle = Article(context: self.container.viewContext)
            newArticle.id = UUID()
            newArticle.title = title
            newArticle.content = content
            newArticle.folder = folder
            do {
                try self.container.viewContext.save()
            } catch {
                print("error \(error)")
            }
        }
    }
    
    func storeFolder(name: String) async {
        await container.viewContext.perform {
            let newFolder = Folder(context: self.container.viewContext)
            newFolder.id = UUID()
            newFolder.name = name
            do {
                try self.container.viewContext.save()
            } catch {
                print("error \(error)")
            }
        }
    }
    
    func updateArticle(id: String, title: String, content: String) {
        do {
            let fetch_request: NSFetchRequest<Article> = NSFetchRequest(entityName: "Article")
            fetch_request.predicate = NSPredicate(format: "id = %@", id as CVarArg)
            let fetched_article = try container.viewContext.fetch(fetch_request)
            if let article = fetched_article.first {
                article.setValue(title, forKey: "title")
                article.setValue(content, forKey: "content")
                try self.container.viewContext.save()
            }
        } catch {
            print(error)
        }
    }
    
    func deleteAllArticle() {
        do {
            let fetch_request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Article")
            let delete_all = NSBatchDeleteRequest(fetchRequest: fetch_request)
            try self.container.viewContext.execute(delete_all)
        } catch {
            print(error)
        }
    }
}
