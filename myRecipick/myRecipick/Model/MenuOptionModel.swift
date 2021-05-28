//
//  MenuOptionModel.swift
//  myRecipick
//
//  Created by Min on 2021/05/22.
//  Copyright © 2021 depromeet. All rights reserved.
//

import Foundation

struct MenuOptionDataModel: Decodable {
    let status: Int
    let data: [OptionKindModel]
}

struct OptionKindModel: Decodable {
    let id: String
    let type: String
    let name: String
    let image: String
    let order: Int
    let policy: PolicyModel
    let options: [OptionModel]
    let createdDate: String
    let updatedDate: String
}

struct OptionModel: Decodable {
    let type: OptionType
    let name: String
    let image: String
    let order: Int
}

struct PolicyModel: Decodable {
    let min: Int
    let max: Int
}

enum OptionType: Decodable {
    case check
    case radio
    case unknown(value: String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try? container.decode(String.self)
        switch status {
        case "CHECK": self = .check
        case "RADIO": self = .radio
        default: self = .unknown(value: status ?? "unknown")
        }
    }
}

class OptionSection: Hashable {
    let option: OptionKindModel
    let isSingleSelection: Bool
    var isExpanded = false
    var items: [OptionItem] = []
    
    public func hash(into hasher: inout Hasher) {
         hasher.combine(ObjectIdentifier(self).hashValue)
    }
    
    init(option: OptionKindModel, isSingleSelection: Bool = false, items: [OptionItem]) {
        self.option = option
        self.isSingleSelection = isSingleSelection
        self.items = items
    }
    
    static func == (lhs: OptionSection, rhs: OptionSection) -> Bool {
        lhs.hashValue == rhs.hashValue && lhs.isExpanded == rhs.isExpanded
    }
}

class OptionItem: Hashable {
    let item: OptionModel
    var isSelected = false
    var type: Options
    
    public func hash(into hasher: inout Hasher) {
         hasher.combine(ObjectIdentifier(self).hashValue)
    }
    
    init(item: OptionModel, type: Options = .option) {
        self.item = item
        self.type = type
    }
    
    static func == (lhs: OptionItem, rhs: OptionItem) -> Bool {
        lhs.hashValue == rhs.hashValue && lhs.isSelected == rhs.isSelected
    }
}

enum Options: Hashable {
    case option
    case additional
}
