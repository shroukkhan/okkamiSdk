//
//  FGTVGenre.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit

class FGTVGenre: NSObject {
    var property: FGProperty!
    /** Genre name */
    var name: String = ""
    /** FGTVChannel objects */
    var channels = [FGTVChannel]()
    /** Initializes genres from an array of dictionary.
     @param array Array of genre data dictionary from json.
     @return Array of FGTVGenre objects.
     */
    init(name: String) {
        super.init()
        self.name = name
        self.channels = [FGTVChannel]()
    }
    
    func genresOf(_ property: FGProperty, fromArray array: [Any], error err: Error?) -> [Any] {
        var genres = [Any]()
        let gAll = FGTVGenre(name: "All")
        genres.append(gAll)
        //array = array.filteredArrayForKind(ofClass: [AnyHashable: Any].self)
        for d in array {
            let genreName: String = (d as! Dictionary<String,Any>)["category"] as! String
            let ch: FGTVChannel? = FGTVChannel(dictionary: d as! [AnyHashable : Any])
            var g = FGTVGenre(name: genreName, andCheckExistingFromArray: genres as! [FGTVGenre])
            if g == nil {
                g = FGTVGenre(name: genreName)
                genres.append(g)
            }
            g.property = property
            ch?.genre = g
            // insert at sorted index
            g.addChannel(inSortedOrder: ch!)
            // insert at the end
            //[g.channels addObject:ch];
            // also add to "All" genre
            gAll.addChannel(inSortedOrder: ch!)
        }
        return [Any](arrayLiteral: genres)
    }
    // The result will look like [a3,a4,1,1a,1b,2,2a,3,4].
    func addChannel(inSortedOrder ch: FGTVChannel) {
        // avoid inserting nil
        if (ch is FGTVChannel) == false {
            return
        }
        var array: [Any] = self.channels
        var newObject: Any? = ch
        /*var comparator: Comparator = {(_ obj1: FGTVChannel, _ obj2: FGTVChannel) -> Void in
            // .intValue on non number string will return 0
            // so first use int compare and try string compare if it's equal (both 0)
            if CInt(obj1.chNo) < CInt(obj2.chNo) {
                return .orderedAscending
            }
            else if CInt(obj1.chNo) > CInt(obj2.chNo) {
                return .orderedDescending
            }
            else {
                return obj1.chNo.localizedCaseInsensitiveCompare(obj2.chNo)
            }
            
        }
        var newIndex: Int = (array as NSArray).indexOfObject(newObject, inSortedRange: [0, array.count], options: NSBinarySearchingInsertionIndex, comparator: comparator)
        array.insert(newObject!, at: newIndex)*/
    }
    
    convenience init(name: String, andCheckExistingFromArray genres: [FGTVGenre]) {
        var x : String?
        for g: FGTVGenre in genres {
            if (g.name == name) {
                x = g.name
            }
        }
        self.init(name: x!)
    }
    
    func firstChannelNo() -> String? {
        if self.channels.count > 0 {
            let ch: FGTVChannel? = self.channels[0]
            return ch?.chNo
        }
        return nil
    }
    
    override var description : String {
        return "[<\(NSStringFromClass(self.self as! AnyClass))> name:\(self.name)"
    }
}
