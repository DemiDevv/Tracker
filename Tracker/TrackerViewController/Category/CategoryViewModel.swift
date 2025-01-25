import Foundation

final class CategoryViewModel {
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private var selectedCategory: TrackerCategory?
    private var categories: [TrackerCategory] = [TrackerCategory]() {
        didSet {
            onCategoriesChanged?(categories)
        }
    }
    private(set) var selectedIndexPath: IndexPath?
    
    var onCategoriesChanged: (([TrackerCategory]) -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    
    func loadCategories() {
        categories = trackerCategoryStore.fetchAllCategories()
    }
    
    func numberOfCategories() -> Int {
        categories.count
    }
    
    func categoryBy(index: Int) -> TrackerCategory {
        categories[index]
    }
    
    func saveSelected(indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    func selectCategoryBy(indexPath: IndexPath) {
        saveSelected(indexPath: indexPath)
        let selectedCategory = categories[indexPath.row]
        onCategorySelected?(selectedCategory)
    }
    
    func deleteCategory(_ category: TrackerCategory) {
        trackerCategoryStore.deleteCategory(category)
        loadCategories()
    }
}
