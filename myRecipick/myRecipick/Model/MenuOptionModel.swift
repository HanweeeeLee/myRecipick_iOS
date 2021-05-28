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
    let title: String
    let isSingleSelection: Bool
    var isExpanded = false
    var items: [OptionItem] = []

    private let uuid = UUID()
    
    public func hash(into hasher: inout Hasher) {
         hasher.combine(ObjectIdentifier(self).hashValue)
    }
    
    init(title: String, isSingleSelection: Bool = false, items: [OptionItem]) {
        self.title = title
        self.isSingleSelection = isSingleSelection
        self.items = items
    }
    
    static func == (lhs: OptionSection, rhs: OptionSection) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

class OptionItem: Hashable {
    let title: String
    var isSelected = false
    var type: Options
    private let uuid = UUID()
    
    public func hash(into hasher: inout Hasher) {
         hasher.combine(ObjectIdentifier(self).hashValue)
    }
    
    init(title: String, type: Options = .option) {
        self.title = title
        self.type = type
    }
    
    static func == (lhs: OptionItem, rhs: OptionItem) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

enum Options: Hashable {
    case option
    case additional
}
