import Foundation

/**
 * AnyCodable Type
 * 
 * Provides type-erased Codable wrapper for dynamic JSON content
 * Essential for challenge submissions and API responses with varying structures
 * 
 * SOLID Principles Applied:
 * - SRP: Only handles type-erased encoding/decoding
 * - OCP: Extensible for new value types
 * - LSP: Conforms to Codable protocol consistently
 * - ISP: Focused interface for any-type coding operations
 * - DIP: Depends on Codable abstractions
 */

@frozen
public struct AnyCodable: Codable {
    public let value: Any
    
    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }
}

// MARK: - Encoding

extension AnyCodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let int8 as Int8:
            try container.encode(int8)
        case let int16 as Int16:
            try container.encode(int16)
        case let int32 as Int32:
            try container.encode(int32)
        case let int64 as Int64:
            try container.encode(int64)
        case let uint as UInt:
            try container.encode(uint)
        case let uint8 as UInt8:
            try container.encode(uint8)
        case let uint16 as UInt16:
            try container.encode(uint16)
        case let uint32 as UInt32:
            try container.encode(uint32)
        case let uint64 as UInt64:
            try container.encode(uint64)
        case let float as Float:
            try container.encode(float)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let date as Date:
            try container.encode(date)
        case let url as URL:
            try container.encode(url)
        case let array as [Any?]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any?]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        case let encodable as Encodable:
            try encodable.encode(to: encoder)
        default:
            let context = EncodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "AnyCodable value cannot be encoded"
            )
            throw EncodingError.invalidValue(value, context)
        }
    }
}

// MARK: - Decoding

extension AnyCodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.init(Optional<Any>.none)
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let uint = try? container.decode(UInt.self) {
            self.init(uint)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self.init(array.map(\.value))
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.init(dictionary.mapValues(\.value))
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyCodable value cannot be decoded"
            )
        }
    }
}

// MARK: - Convenience Methods

extension AnyCodable {
    /// Returns the value as the specified type, or nil if conversion fails
    public func value<T>(as type: T.Type) -> T? {
        return value as? T
    }
    
    /// Returns the value as a String, with automatic conversion for basic types
    public var stringValue: String? {
        switch value {
        case let string as String:
            return string
        case let number as NSNumber:
            return number.stringValue
        case let bool as Bool:
            return bool ? "true" : "false"
        default:
            return nil
        }
    }
    
    /// Returns the value as an Int, with automatic conversion when possible
    public var intValue: Int? {
        switch value {
        case let int as Int:
            return int
        case let double as Double:
            return Int(double)
        case let string as String:
            return Int(string)
        default:
            return nil
        }
    }
    
    /// Returns the value as a Double, with automatic conversion when possible
    public var doubleValue: Double? {
        switch value {
        case let double as Double:
            return double
        case let int as Int:
            return Double(int)
        case let string as String:
            return Double(string)
        default:
            return nil
        }
    }
    
    /// Returns the value as a Bool, with automatic conversion when possible
    public var boolValue: Bool? {
        switch value {
        case let bool as Bool:
            return bool
        case let string as String:
            return ["true", "1", "yes"].contains(string.lowercased())
        case let number as NSNumber:
            return number.boolValue
        default:
            return nil
        }
    }
    
    /// Returns the value as an Array, or nil if not an array
    public var arrayValue: [Any]? {
        return value as? [Any]
    }
    
    /// Returns the value as a Dictionary, or nil if not a dictionary
    public var dictionaryValue: [String: Any]? {
        return value as? [String: Any]
    }
}

// MARK: - Equatable

extension AnyCodable: Equatable {
    public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case is (Void, Void):
            return true
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as Int8, rhs as Int8):
            return lhs == rhs
        case let (lhs as Int16, rhs as Int16):
            return lhs == rhs
        case let (lhs as Int32, rhs as Int32):
            return lhs == rhs
        case let (lhs as Int64, rhs as Int64):
            return lhs == rhs
        case let (lhs as UInt, rhs as UInt):
            return lhs == rhs
        case let (lhs as UInt8, rhs as UInt8):
            return lhs == rhs
        case let (lhs as UInt16, rhs as UInt16):
            return lhs == rhs
        case let (lhs as UInt32, rhs as UInt32):
            return lhs == rhs
        case let (lhs as UInt64, rhs as UInt64):
            return lhs == rhs
        case let (lhs as Float, rhs as Float):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        case let (lhs as [String: AnyCodable], rhs as [String: AnyCodable]):
            return lhs == rhs
        case let (lhs as [AnyCodable], rhs as [AnyCodable]):
            return lhs == rhs
        default:
            return false
        }
    }
}

// MARK: - CustomStringConvertible

extension AnyCodable: CustomStringConvertible {
    public var description: String {
        switch value {
        case is Void:
            return String(describing: nil as Any?)
        case let value as CustomStringConvertible:
            return value.description
        default:
            return String(describing: value)
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension AnyCodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch value {
        case let value as CustomDebugStringConvertible:
            return "AnyCodable(\(value.debugDescription))"
        default:
            return "AnyCodable(\(description))"
        }
    }
}

// MARK: - ExpressibleBy Literal Protocols

extension AnyCodable: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(Optional<Any>.none)
    }
}

extension AnyCodable: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
}

extension AnyCodable: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension AnyCodable: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}

extension AnyCodable: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension AnyCodable: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}

extension AnyCodable: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (AnyHashable, Any)...) {
        let dictionary = [AnyHashable: Any](elements, uniquingKeysWith: { first, _ in first })
        self.init(dictionary)
    }
} 