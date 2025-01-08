//
//  Untitled.swift
//  Eteration-Case
//
//  Created by 4os on 7.01.2025.
//

import Foundation

class FilterViewModel {

    // MARK: - Properties
    let sortOptions: [SortModel] = [.date(.asc), .date(.desc), .price(.desc), .price(.asc)]
    let brandOptions = [
        "Lamborghini", "Smart", "Ferrari", "Volkswagen", "Mercedes Benz",
        "Tesla", "Fiat", "Land Rover", "Aston Martin", "Maserati",
        "Bugatti", "Nissan", "Audi", "Rolls Royce", "Mini",
        "BMW", "Jeep", "Kia", "Mazda", "Dodge", "Toyota"
    ]
    let modelOptions = [
        "CTS", "Roadster", "Taurus", "Jetta", "Fortwo",
        "A4", "XC90", "Expedition", "Focus", "Model S",
        "F-150", "Corvette", "Ranchero", "Colorado", "911",
        "El Camino", "Grand Cherokee", "Alpine", "Beetle", "Model T",
        "Mustang", "Malibu", "Accord", "Spyder", "Camry",
        "Explorer", "Element", "Charger", "Silverado", "LeBaron",
        "Challenger", "XTS", "Volt", "Altima", "Golf"
    ]
    private(set) var filteredBrandOptions: [String]
    private(set) var filteredModelOptions: [String]
    private(set) var selectedSortOption: SortModel?
    private(set) var selectedBrands: Set<String> = []
    private(set) var selectedModels: Set<String> = []
    var onUpdate: (() -> Void)?

    // MARK: - Initialization
    init() {
        filteredBrandOptions = brandOptions
        filteredModelOptions = modelOptions
    }

    // MARK: - Logic
    func searchBrands(with query: String) {
        filteredBrandOptions = query.isEmpty ? brandOptions : brandOptions.filter { $0.localizedCaseInsensitiveContains(query) }
        onUpdate?()
    }

    func searchModels(with query: String) {
        filteredModelOptions = query.isEmpty ? modelOptions : modelOptions.filter { $0.localizedCaseInsensitiveContains(query) }
        onUpdate?()
    }

    func toggleBrandSelection(_ brand: String) {
        if selectedBrands.contains(brand) {
            selectedBrands.remove(brand)
        } else {
            selectedBrands.insert(brand)
        }
        onUpdate?()
    }

    func toggleModelSelection(_ model: String) {
        if selectedModels.contains(model) {
            selectedModels.remove(model)
        } else {
            selectedModels.insert(model)
        }
        onUpdate?()
    }

    func selectSortOption(_ option: String) {
        selectedSortOption = sortOptions.first(where: { $0.getDescription() == option })
        onUpdate?()
    }
}

// MARK: - Helpers (Eklenebilir)
extension FilterViewModel {
    func resetFilters() {
        selectedBrands.removeAll()
        selectedModels.removeAll()
        selectedSortOption = nil
        onUpdate?()
    }
}
