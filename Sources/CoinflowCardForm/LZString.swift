import Foundation

enum LZString {
    private static let keyStrUriSafe = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-$"

    static func compressToEncodedURIComponent(_ input: String) -> String {
        if input.isEmpty { return "" }
        let compressed = compress(input)
        return baseEncode(compressed, alphabet: keyStrUriSafe)
    }

    private static func compress(_ uncompressed: String) -> [Int] {
        var dictionary = [String: Int]()
        var dictionaryToCreate = Set<String>()
        var dictSize = 3
        var numBits = 2
        var enlargeIn = 2
        var w = ""
        var result = [Int]()

        func emitLiteral(_ s: String) {
            let charCode = Int(s.unicodeScalars.first!.value)
            if charCode < 256 {
                for _ in 0..<numBits { result.append(0) }
                result.append(contentsOf: bits(charCode, count: 8))
            } else {
                result.append(contentsOf: bits(1, count: numBits))
                result.append(contentsOf: bits(charCode, count: 16))
            }
            enlargeIn -= 1
            if enlargeIn == 0 {
                enlargeIn = 1 << numBits
                numBits += 1
            }
            dictionaryToCreate.remove(s)
        }

        func emitW() {
            if dictionaryToCreate.contains(w) {
                emitLiteral(w)
            } else {
                result.append(contentsOf: bits(dictionary[w]!, count: numBits))
            }
            enlargeIn -= 1
            if enlargeIn == 0 {
                enlargeIn = 1 << numBits
                numBits += 1
            }
        }

        for c in uncompressed {
            let sc = String(c)
            if dictionary[sc] == nil {
                dictionary[sc] = dictSize
                dictSize += 1
                dictionaryToCreate.insert(sc)
            }
            let wc = w + sc
            if dictionary[wc] != nil {
                w = wc
            } else {
                emitW()
                dictionary[wc] = dictSize
                dictSize += 1
                w = sc
            }
        }

        if !w.isEmpty {
            emitW()
        }

        result.append(contentsOf: bits(2, count: numBits))
        return result
    }

    private static func bits(_ value: Int, count: Int) -> [Int] {
        (0..<count).map { (value >> $0) & 1 }
    }

    private static func baseEncode(_ data: [Int], alphabet: String) -> String {
        let chars = Array(alphabet)
        var result = ""
        var val = 0
        var position = 0

        for bit in data {
            val = (val << 1) | bit
            position += 1
            if position == 6 {
                result.append(chars[val])
                val = 0
                position = 0
            }
        }

        if position > 0 {
            val <<= (6 - position)
            result.append(chars[val])
        }

        return result
    }
}
