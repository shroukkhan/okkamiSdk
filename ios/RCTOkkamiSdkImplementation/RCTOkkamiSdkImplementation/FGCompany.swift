//
//  FGCompany.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/9/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift


class FGCompany: FGEntity {
    var companyFullTree: FGCompany!
    
    var brands : [FGBrand]?
    
    override var description: String {
        var desc: String = super.description
        for b: FGBrand in self.brands! {
            desc = desc.appendingFormat("\n ╚═%@", b.description)
        }
        return desc
    }
    convenience required init(identifier: NSString) {
        self.init()
        self.identifier = identifier
        self.brands = [FGBrand]()
    }
    
    convenience required init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        self.name = dictionary["name"] as! NSString
        self.identifier = dictionary["id"] as? NSString
    }
    
    func brand(withIdentifier identifier: Int) -> FGBrand? {
        for b: FGBrand in self.brands! {
            if (b.identifier as! String) == identifier.description {
                return b
            }
        }
        return nil
    }
    // MARK: - parent and children
    
    /*func addNewEntities(from line: FGEntityLine) {
        // Check Company
        if line.companyId == FGEntityId_invalid || self.identifier != line.companyId {
            //FGLogErrorWithClsAndFuncName("line company id (%lu) is different from receiver's identifier (%lu)", UInt(line.companyId), UInt(self.identifier))
            return
        }
        // Check Brand
        if line.brandId == FGEntityId_invalid {
            return
        }
        var matchedBrand: FGBrand?
        for sb: FGBrand in self.brands {
            if sb.identifier == line.brandId {
                matchedBrand = sb
                break
            }
        }
        if matchedBrand == nil {
            matchedBrand = FGBrand(identifier: line.brandId)
            self.add(matchedBrand)
        }
        // Check Property
        if line.propertyId == FGEntityId_invalid {
            return
        }
        var matchedProperty: FGProperty?
        for sp: FGProperty in matchedBrand?.properties {
            if sp.identifier == line.propertyId {
                matchedProperty = sp
                break
            }
        }
        if matchedProperty == nil {
            matchedProperty = FGProperty(identifier: line.propertyId)
            matchedBrand?.add(matchedProperty)
        }
    }*/
    
    func add(_ brand: FGBrand) {
        brand.company = self
        self.brands?.append(brand)
    }
    
    var children: [Any]? {
        return self.brands
    }
    
    /*func getEndingEntityOf(_ line: FGEntityLine) -> FGEntity {
        var result: FGEntity? = nil
        if line.companyId == self.identifier {
            result = self
            var b: FGBrand? = self.brand(withIdentifier: line.brandId)
            if b != nil {
                result = b
                var p: FGProperty? = b?.property(withIdentifier: line.propertyId)
                if p != nil {
                    result = p
                }
            }
        }
        return result!
    }*/
    
    // MARK: - connect
    
    public override func connectWithObject(connect: FGConnect) {
        
    }
    
    
    /*public override func loadFromRealm() -> FGCompany{
        var realm = try! Realm()
        var company = realm.object(ofType: FGCompany.self, forPrimaryKey: 0)!
        return company
    }
    
    public override func saveToRealm(){
        
        // Insert from NSData containing JSON
        var realm = try! Realm()
        try! realm.write {
            var check = realm.objects(FGCompany.self).count
            if check > 0{
                
            }else{
                realm.add(self, update: true)
            }
        }
        print("*** Saved Company to Database ***")
    }
    
    public override func clearFromRealm(){
        var realm = try! Realm()
        try! realm.write {
            let deletedObject = realm.objects(FGCompany.self).first
            realm.delete(deletedObject!)
        }
        print("*** Clear Company from Database ***")
    }*/
    
}
