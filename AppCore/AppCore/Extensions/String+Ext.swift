
import Foundation
import UIKit

func * (lhs: Character, rhs: Int) -> String {
    return String(repeating: String(lhs), count: rhs)
}

public extension Dictionary where Value: Any {
    
    public func isEqual(to otherDict: [Key: Any], 
                        allPossibleValueTypesAreKnown: Bool = false) -> Bool? {
        guard allPossibleValueTypesAreKnown else { return nil }
        guard self.count == otherDict.count else { return false }
        for (k1,v1) in self {
            guard let v2 = otherDict[k1] else { return false }
            switch (v1, v2) {
            case (let v1 as Double, let v2 as Double) : if !(v1.isEqual(to: v2)) { return false }
            case (let v1 as Int, let v2 as Int) : if !(v1==v2) { return false }
            case (let v1 as String, let v2 as String): if !(v1==v2) { return false }
            // ... 
            case (_ as Double, let v2): if !(v2 is Double) { return false }
            case (_, _ as Double): return false
            case (_ as Int, let v2): if !(v2 is Int) { return false }
            case (_, _ as Int): return false
            case (_ as String, let v2): if !(v2 is String) { return false }
            case (_, _ as String): return false
            default: return nil
            }
        }
        return true
    }
}

public extension String {
    
    public func tokenizeToWord() -> [String] {
        return self.tokenize(option: kCFStringTokenizerUnitWord)
    }
    
    public func tokenizeToWordRanges() -> [CountableRange<Int>] {
        return self.tokenizeRanges(option: kCFStringTokenizerUnitWord)
    }
    
    public func tokenizeToWordIndexRanges() -> [Range<String.Index>] {
        return self.tokenizeIndexRanges(option: kCFStringTokenizerUnitWord)
    }
    
    /// Splits the string to sentences.
    public func tokenizeToSentences() -> [String] {
        return self.tokenize(option: kCFStringTokenizerUnitSentence)
    }
    /// Splits the string to paragraphs.    
    public func tokenizeToParagraphs() -> [String] {
        return self.tokenize(option: kCFStringTokenizerUnitParagraph)
    }
    
    /// Splits the string to words based on potential line-breaks.    
    public func tokenizeToLineBreaks() -> [String] {
        return self.tokenize(option: kCFStringTokenizerUnitLineBreak)
    }
    
    private func tokenize(option: CFOptionFlags) -> [String] {
        return self.tokenizeRanges(option: option).map { self.substring(with: $0) }
    }
    
    private func tokenizeRanges(option: CFOptionFlags) -> [CountableRange<Int>] {
        let inputRange = CFRangeMake(0, self.utf16.count)        
        let flag = UInt(option)
        let locale = CFLocaleCopyCurrent() 
        let cfString : CFString = self as CFString
        let tokenizer = CFStringTokenizerCreate( kCFAllocatorDefault, cfString, inputRange, flag, locale)
        var tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)        
        var tokenRanges : [CountableRange<Int>] = []
        let tokenTypeOptionSet : CFStringTokenizerTokenType = []
        while tokenType != tokenTypeOptionSet {
            let currentTokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let lower = Int(currentTokenRange.location)
            let upper = Int(currentTokenRange.location + currentTokenRange.length)
            let range = lower ..< upper 
            tokenRanges.append(range)            
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        return tokenRanges
    }
    
    private func tokenizeIndexRanges(option: CFOptionFlags) -> [Range<String.Index>] {
        
        return tokenizeRanges(option: option).flatMap { self.range(fromCountableRange: $0) }
    }
    
    func toWords() -> [String] {
        
        let range = self.range(of: self)!
        var words = [String]()
        
        self.enumerateSubstrings(in: range, options: .byWords) { (substring, _, _, _) -> Void in
            words.append(substring!)
        }
        
        return words
    }
    
    public func toWordsFromRegex() -> [String] {
        return self["(\\b[^\\s]+\\b)"].matches()
    }
    
    public func toWordNSRangesFromRegex() -> [NSRange] {
        return self["(\\b[^\\s]+\\b)"].ranges()
    }
    
    public func toWordRangesFromRegex() -> [Range<Int>] {
        return self["(\\b[^\\s]+\\b)"]
            .ranges()
            .map { $0.location ..< ($0.location + $0.length) }
    }
    
    func toWordRanges() -> [Range<String.Index>] {
        
        let wordRange = self.range(of: self)!
        var ranges = [Range<String.Index>]()
        
        self.enumerateSubstrings(in: wordRange, options: .byWords) { (_, range, _, _) -> Void in
            ranges.append(range)
        }
        
        return ranges
    }
    
    func toLinguisticWordRanges() -> [(word: String, range: Range<String.Index>)] {
        var wordRanges = [(String, Range<String.Index>)]()
        let nsString = NSString(string: self)
        let range = NSRange(location: 0, length: self.count)
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        tagger.string = self
        tagger.enumerateTags(
        in: range, scheme: .tokenType, options: .omitOther) { (tag, nsRange, _, _) in
            guard let tag = tag else { return }
            switch tag.rawValue {
            case "Word":
                let word = nsString.substring(with: nsRange)
                if let range = self.range(fromNSRange: nsRange) {
                    wordRanges.append((word, range))
                }
            default: break
            }
        }
        return wordRanges
    }

    public func indexAt(from: Int) -> String.Index {
        return self.index(startIndex, offsetBy: from)
    }

    public func getCharacterAt(pos: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: pos)]
    }
    public static func getRandomCharacter() -> Character {
        let characters = "ABCDEFGHIJKLKMNOPQRSTUVWXYZ"
        let len = UInt32(characters.count)
        let randomPosition = Int(arc4random_uniform(len))
        return characters[characters.index(characters.startIndex, offsetBy: randomPosition)]
    }

    private func substring(with range : CFRange) -> String {
        let nsrange = NSRange.init(location: range.location, length: range.length)
        let substring = (self as NSString).substring(with: nsrange)
        return substring
    }
    
    private func substring(with range : CountableRange<Int>) -> String {
        let nsrange = NSRange.init(location: range.lowerBound, length: range.count)
        let substring = (self as NSString).substring(with: nsrange)
        return substring
    }
    
    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        get {
            return self[..<index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeThrough<Int>) -> Substring {
        get {
            return self[...index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeFrom<Int>) -> Substring {
        get {
            return self[index(startIndex, offsetBy: value.lowerBound)...]
        }
    }
    
    subscript (index: Int) -> Character {
        let charIndex = self.index(self.startIndex,offsetBy:index)
        return self[charIndex]
    }
    
    subscript (range: Range<Int>) -> String {
        let startIndex = self.index(self.startIndex,offsetBy: range.lowerBound) 
        let endIndex = self.index(self.startIndex,offsetBy: range.count) 
        return String(self[startIndex..<endIndex])
    }
    
    public func substring(from: Int) -> String {
        let fromIndex = self.indexAt(from: from)
        return String(self[fromIndex...])
    }

    public func substring(to toIndex: Int) -> String {
        let index = self.indexAt(from: toIndex)
        return String(self[..<index]) // Swift 4
    }

    public func substring(from: Int, to: Int) -> String {
        let start = index(startIndex, offsetBy: from)
        let end = index(start, offsetBy: to - from)
        return String(self[start ..< end])
    }
    
    public func substring(withRange range: Range<Int>) -> String {
        let range = self.range(fromRangeInt: range)
        return String(self[range])
    }
    
    public func substring(withNSRange range: NSRange) -> String {
        return substring(from: range.lowerBound, to: range.upperBound)
    }
    
    public static func replaceAt(str: String, index: Int, newCharac: String) -> String {
        return str.substring(to: index - 1)  + newCharac + str.substring(from: index)
    }
    
    func nsRange(fromStringIndex range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }

    func nsRange(fromRangeInt rangeInt : Range<Int>) -> NSRange {
        return NSRange.init(location: rangeInt.lowerBound,
                         length: rangeInt.count)
    }
    
    public func range(fromNSRange nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
    
    public func range(fromStringIndex stringIndex: Range<String.Index>?) -> Range<Int> {
        guard let start = stringIndex?.lowerBound.encodedOffset,
            let end = stringIndex?.upperBound.encodedOffset else { return 0..<0 }
        return start..<end
    }
    
    /*
    public func range(fromNSRange nsRange : NSRange) -> Range<String.Index> {
        let startIndex = indexAt(from: nsRange.location)
        let endIndex = indexAt(from: nsRange.location + nsRange.length)
        return startIndex..<endIndex
    }
    */
    public func range(fromRangeInt rangeInt: Range<Int>) -> Range<String.Index> {
        let startIndex = self.indexAt(from: rangeInt.lowerBound)
        let endIndex = self.indexAt(from: rangeInt.upperBound)
        return startIndex..<endIndex
    }

    public func range(fromRange range: Range<Int>) -> Range<String.Index>
    {
        let from = self.index(self.startIndex, offsetBy: range.lowerBound)
        let to = self.index(self.startIndex, offsetBy: range.upperBound)
        return from..<to
    }
    
    public func range(fromCountableRange countableRange: CountableRange<Int>) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(
                utf16.startIndex, 
                offsetBy: countableRange.lowerBound, 
                limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: countableRange.count, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
    
    public func ranges(from string: String) -> [NSRange] {
        let wordRangesInt = self.toWordRangesFromRegex()
        var ranges:[NSRange] = []
        for range in wordRangesInt {
            let wordToHighlight = self.substring(withRange: range)
            
            if string == wordToHighlight {
                let stringIndexRange = self.range(fromRangeInt: range) 
                let nsRange = self.nsRange(fromStringIndex: stringIndexRange)
                ranges.append(nsRange)
            }
        }
        return ranges
    }
    
    // FIXME: Remove this as it is not complete and misleading.
    // Correctly implement a shrink to fit on NSAttributedString
    public func getFontSize(inFrame: CGRect, desiredFontSize : Int, reduceBy: CGFloat) -> CGFloat {
        let text = self
        var tempHeight : CGFloat = 0.0
        for i in 0..<desiredFontSize {

            let font = UIFont.systemFont(ofSize: CGFloat(i))
            let labelSizeWidth = inFrame.size.width
            let labelSizeHeight = inFrame.size.height
            let textAttributedFont = [NSAttributedStringKey.font: font]
            let textNSString : NSString = (text as NSString)
            let size = textNSString.boundingRect(
                with: CGSize(width: labelSizeWidth, height: CGFloat.greatestFiniteMagnitude),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: textAttributedFont, context: nil).size

            let sizeHeight = size.height
            if (sizeHeight > labelSizeHeight) {
                tempHeight = CGFloat(i)
                break
            } else {
                tempHeight = CGFloat(desiredFontSize)
            }
        }

        return tempHeight - reduceBy
    }
    
    public func replaceHypthensWithNonBreakingHyphens() -> String {
        let nonBreakingHyphen = "\u{2011}"
        let hyphen = "\u{2010}"
        let hyphenMinus = "\u{002D}"
        let otherHyphens = [hyphen, hyphenMinus]
        return otherHyphens.reduce(self) { string ,hyphen  in
            return string.replacingOccurrences(of: hyphen, with: nonBreakingHyphen)
        }
    }

    public func swapTwoWords(first: String, last: String) -> String {
        let temp = "---79123923--"
        let change1 = self.replacingOccurrences(of: first, with: temp)
        let change2 = change1.replacingOccurrences(of: last, with: first)
        let change3 = change2.replacingOccurrences(of: temp, with: last)
        return change3
    }

    public func changesWordColor (_ wordsToColor : [String], _ color: UIColor) -> NSAttributedString {
        let text = self
        let attribute = NSMutableAttributedString.init(string: text)

        for word in wordsToColor {
            let range = (text as NSString).range(of: word)
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        }

        return attribute
    }
    
    public func changeWord(withInitialCharacter : Character) -> String {
        let word = self.flatMap { _ -> Character in
            return withInitialCharacter
        }
        return String(word)
    }

    func highlight(word words: [String], this color: UIColor) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for word in words {
            let ranges = self.ranges(from: word)
            for range in ranges {
                attributedString.addAttributes([NSAttributedStringKey.foregroundColor: color], range: range)
            }
        }
        return attributedString
    }

    public func changeColorAndLineSpacing(lineSpacing: CGFloat,
                                          font: UIFont,
                                          textAlignment: NSTextAlignment,
                                          wordsToColor : [String],
                                          color: UIColor) -> NSAttributedString {
        let text = self
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        //paragraphStyle.lineHeightMultiple = 2
        paragraphStyle.alignment = textAlignment

        let attribute = NSMutableAttributedString(string: text)
        attribute.addAttribute(NSAttributedStringKey.font,
                               value: font,
                               range: NSRange.init(location: 0, length:attribute.length))
        attribute.addAttribute(NSAttributedStringKey.paragraphStyle,
                               value: paragraphStyle,
                               range: NSRange.init(location: 0,length: attribute.length))

        for word in wordsToColor {
            let ranges = text.ranges(from: word)
            for range in ranges {
                attribute.addAttributes([NSAttributedStringKey.foregroundColor: color], range: range)
            }
        }

        return attribute
    }

    public func getNonDuplicatedWords( _ minCount: Int, _ maxCount: Int) -> [String] {

        let originalWords = self
            .replaceHypthensWithNonBreakingHyphens()
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\t", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "!", with: "")
            .replacingOccurrences(of: "?", with: "")
            .replacingOccurrences(of: ";", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "“", with: "")
            .replacingOccurrences(of: "”", with: "")
            .components(separatedBy: " ").removeExtras()

        let wordsWithoutApostrophe = originalWords.removeApostropheWords()
        let wordsWithoutPlural = wordsWithoutApostrophe.removePluralWords(with: minCount)
        let wordsWithoutDuplicates = wordsWithoutPlural.skipDuplicates()
        let wordsWithoutEmpties = wordsWithoutDuplicates.filter { ( $0 != "" ) }

        return wordsWithoutEmpties.flatMap {  word -> String?  in
            return (word.count > minCount && word.count < maxCount) ? word : nil
        }

    }
    
    public func wordsInOrderOfAppearance(using words: [String]) -> [String] {
        if (words.isEmpty) {
            return words
        }
        var wordsInOrderofAppearance = [String]()
        let wordRanges = self.toWordRangesFromRegex()
        for range in wordRanges {
            let wordInRange = self.substring(withRange: range)
            if (words.contains(wordInRange)) {
                wordsInOrderofAppearance.append(wordInRange)
            }
        }
        return wordsInOrderofAppearance
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constrainedSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constrainedSize,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedStringKey.font: font],
            context: nil)
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constrainedSize = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(
            with: constrainedSize,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedStringKey.font: font],
            context: nil)
        return ceil(boundingBox.width)
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let text: String = self
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = (text as NSString).size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let text: String = self
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = (text as NSString).size(withAttributes: fontAttributes)
        return size.height
    }

    
    //emoji 
    
    public func toUIImage(with fontSize: CGFloat) -> UIImage {
        let size = CGSize(width: 30, height: 35)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.white.set()
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        
        (self as NSString).draw(in: rect, withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize)]) 
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let im = image else {
            print("problem")
            return UIImage()
        }
        return im
    }
    
    
    public func showEmojiDetail () -> String {
        return self.reduce("") { // loop through str individual characters
            var item = "\($1)" // string with the current char
            let isEmoji = item.containsEmoji // true or false
            
            if isEmoji {
                item = item.applyingTransform(StringTransform.toUnicodeName, reverse: false)!
            }
            return $0 + item
            }.replacingOccurrences(of:"\\N", with:"") // strips "\N"
        
    }
    
    public var containsEmoji: Bool {
        
        for scalar in self.unicodeScalars {
            switch scalar.value {
                
            case 0x2600...0x1F9FF:
                return true
            default:
                continue
            }
        }
        return false
    }
    
    public func removeSpecialCharsFromString() -> String {
        let validCharacters = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_")
        return String(self.filter { validCharacters.contains($0) })
    }
    
    public func removingEmoji () -> String {
        
        return self.reduce("") 
        { 
            let item = "\($1)" // string with the current char
            let isEmoji = item.containsEmoji // true or false
            
            if isEmoji {
                
                print("Found emoji", item)
                return ""
            }else {
                print("No emoji", item)
                return item
            }
        }
    }
    
    
    public static func getItemUrlFromBundle (bundleID: String, itemName:String, extention: String, subDirectory:String = "") -> URL? {
        guard let bundle = Bundle(identifier: bundleID) else { 
            print("Bundle ID is not valid")
            return nil 
        }
        let url = bundle.url(forResource: itemName, withExtension: extention, subdirectory: subDirectory)
        return url
    }
    
    public static func getItemPathFromBundle (bundleID: String, itemName:String, type: String, inDirectory:String = "") -> String? {
        guard let bundle = Bundle(identifier: bundleID) else { 
            print("Bundle ID is not valid")
            return nil 
        }
        let path = bundle.path(forResource: itemName, ofType: type, inDirectory: inDirectory)
        return path
    }
    
    // create a function for estimated string...
    public func estimatedStringFrame (with font :UIFont) -> CGRect {
        
        let size = CGSize(width: UIScreen.main.bounds.size.width - 20, height: 1000)
        
        let nsstring = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: self).boundingRect(with: size, options: nsstring, attributes: [NSAttributedStringKey.font : font], context: nil)
    }

}

extension Collection where Iterator.Element == String {

    public func take (_ amount: Int, with minCharacterCount: Int) -> [String] {
        let words =  self.filter({ $0.count >= minCharacterCount})
        return words.takeRandom(amount)
    }

    public func removeFirstEmptySpace () -> [String] {
        return self.flatMap { sentence -> String in
            if (sentence.first == " ") {
                return String.replaceAt(str: sentence, index: 1, newCharac: "")
            } else {
                return sentence
            }
        }
    }

    public func removeExtras () -> [String] {
        return self.flatMap { str -> [String] in
            return str.components(separatedBy: ["—", "*", "/"])
        }
    }

    ///remove Apostrophe words and its original word 
    public func removeApostropheWords() -> [String] {
        guard let originalWords = self as? [String] else { return [] }

        var words = originalWords
        for (ind,word) in originalWords.enumerated() {
            if (originalWords.contains("\(word)\'s") ) {
                words.remove(at: ind)
                if let removeApostropheWordAtIndex = words.index(of: "\(word)\'s") {
                    words.remove(at: removeApostropheWordAtIndex)
                }
            }
        }

        return words
    }

    ///remove plural words and its original word 
    public func removePluralWords(with minCharacterCount: Int) -> [String] {

        guard let originalWords = self as? [String] else { return [] }

        var wordsToRemove = [String]()
        for w in originalWords {
            if (originalWords.contains("\(w)s") && w.count > minCharacterCount) {
                wordsToRemove.append("\(w)s")
                wordsToRemove.append(w)
            }
        }
        return originalWords.filter { wordsToRemove.contains($0) == false }

    }

    ///remove plural words and its original word 
    public func removeDuplicatedString() -> [String] {
        guard let originalWords = self as? [String] else { return [] }

        let makeAllLowercased = originalWords.map { $0.lowercased() }
        return Array( Set(makeAllLowercased) )
    }

    public func removeHyphenatedWords() -> [String] {
        return self.flatMap { word -> String? in
            return ( word.contains("-") || word.contains("‐") || word.contains("‑") ) ? nil : word
        }
    }

}

public protocol StringExtensions : RangeReplaceableCollection {}

extension Array : StringExtensions { }

public extension StringExtensions where Self.Iterator.Element: Hashable {
    public typealias Element = Self.Iterator.Element

    public func removeDuplicates() -> [Element] {
        guard let list = (self as? [Element]) else { return [] }

        // Convert array into a set to get unique values.
        let uniques = Set<Element>(list)
        // Convert set back into an Array of Ints.
        let result = [Self.Element](uniques)
        return result
    }

    public func skipDuplicates() -> [Element] {

        guard var list = (self as? [Element]) else { return [] }

        //do not take duplicated words
        var tempList = [Self.Element]()
        var elementsRemoved = [Self.Element]()

        for word in list {
            if (tempList.contains(word)) {
                //found the next of the duplicated word
                if let index = tempList.index(of: word) {
                    tempList.remove(at: index)
                    list.remove(at: index)
                }
                elementsRemoved.append(word)
            } else {

                if elementsRemoved.contains(word) {
                    //do not add any word that is been removed
                } else {
                    tempList.append(word)
                }
            }
        }
        return tempList

    }

    public func numberOfOccurrences() -> [Element: Int] {
        return reduce([:]) { (accu: [Element: Int], element) in
            var accu = accu
            accu[element] = accu[element]?.advanced(by: 1) ?? 1
            return accu
        }
    }

    public func chooseOne () -> Element {
        let list: [Element] = self as! [Self.Element]
        let len = UInt32(list.count)
        let random = Int(arc4random_uniform(len))
        return list[random]
    }

    public func takeRandom(_ amount: Int) -> [Element] {
        guard var list = (self as? [Self.Iterator.Element])
            , list.count > 1, amount <= list.count else { return [] }

        var temp = [Self.Element]()
        var counter = amount

        while counter > 0 {
            let index = Int(arc4random_uniform(UInt32(list.count - 1)))
            temp.append(list[index])
            list.remove(at: index)

            counter -= 1
        }

        return temp
    }

    public func randomise() -> [Element] {

        guard var list = (self as? [Self.Iterator.Element]), list.isEmpty == false else { return [] }

        var temp = [Self.Iterator.Element]()

        while list.isEmpty == false {
            let index = Int(arc4random_uniform(UInt32(list.count - 1)))
            temp.append(list[index])
            list.remove(at: index)
        }

        return temp
    }

    public func removeAfter(index: Int) -> [Element] {

        guard let list = (self as? [Self.Iterator.Element]), list.count > index else { return [] }
        return list.enumerated().flatMap { (ind, _ ) -> Element? in
            return (ind <= index) ? list[ind] : nil
        }
    }
}

public extension Array where Element: Comparable {
    public func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
