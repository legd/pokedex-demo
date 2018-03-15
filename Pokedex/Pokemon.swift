//
//  Pokemon.swift
//  Pokedex
//
//  Created by Luis Guzman on 3/26/17.
//  Copyright © 2017 Luis Guzman. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    
    fileprivate var _name: String!
    fileprivate var _pokedexId: Int!
    fileprivate var _description: String!
    fileprivate var _type: String!
    fileprivate var _defense: String!
    fileprivate var _height: String!
    fileprivate var _weight: String!
    fileprivate var _attack: String!
    fileprivate var _nextEvolutionText: String!
    fileprivate var _nextEvolutionName: String!
    fileprivate var _nextEvolutionId: String!
    fileprivate var _nextEvolutionLevel: String!
    fileprivate var _pokemonURL: String!
    
    var name: String {
        return _name
    }
    
    var pokedexId: Int {
        return _pokedexId
    }
    
    var description: String {
        
        if _description == nil {
            _description = ""
        }
        
        return _description
    }
    
    var type: String {
        
        if _type == nil {
            _type = ""
        }
        
        return _type
    }
    
    var defense: String {
        
        if _defense == nil {
            _defense = ""
        }
        
        return _defense
    }
    
    var height: String {
        
        if _height == nil {
            _height = ""
        }
        
        return _height
    }
    
    var weight: String {
        
        if _weight == nil {
            _weight = ""
        }
        
        return _weight
    }
    
    var attack: String {
        
        if _attack == nil {
            _attack = ""
        }
        
        return _attack
    }
    
    var nextEvolutionText: String {
        
        if _nextEvolutionText == nil {
            _nextEvolutionText = ""
        }
        
        return _nextEvolutionText
    }
    
    var nextEvolutionName: String {
        
        if _nextEvolutionName == nil {
            _nextEvolutionName = ""
        }
        
        return _nextEvolutionName
    }
    
    var nextEvolutionId: String {
        
        if _nextEvolutionId == nil {
            _nextEvolutionId = ""
        }
        
        return _nextEvolutionId
    }
    
    var nextEvolutionLevel: String {
        
        if _nextEvolutionLevel == nil {
            _nextEvolutionLevel = ""
        }
        
        return _nextEvolutionLevel
    }
    
    init(name: String, pokedexId: Int) {
        
        self._name = name
        self._pokedexId = pokedexId
        
        self._pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self.pokedexId)/"
    }
    
    func downloadPokemonDetail(completed: @escaping DownloadComplete) {
        
        Alamofire.request(_pokemonURL).responseJSON { (response) in 
            
            if let dict = response.result.value as? Dictionary<String, AnyObject> {
               
                if let weight = dict["weight"] as? String {
                
                    self._weight = weight
                }
                
                if let height = dict["height"] as? String {
                    
                    self._height = height
                }
                
                if let attack = dict["attack"] as? Int {
                    
                    self._attack = "\(attack)"
                }
                
                if let defense = dict["defense"] as? Int {
                    
                    self._defense = "\(defense)"
                }
                
                if let typesArray = dict["types"] as? [Dictionary<String, String>], typesArray.count > 0 {
                    
                    
                    if let name = typesArray[0]["name"] {
                        
                        self._type = name.capitalized
                    }
                    
                    if typesArray.count > 1 {
                        
                        for i in 1..<typesArray.count {
                            
                            if let name = typesArray[i]["name"] {
                                
                                self._type! += "/\(name.capitalized)"
                            }
                        }
                    }
                    
                } else {
                    self._type = "Undefined"
                }
                
                if let descriptionArray = dict["descriptions"] as? [Dictionary<String, String>], descriptionArray.count > 0 {
                    
                    if let uri = descriptionArray[0]["resource_uri"] {
                        
                        let url = "\(URL_BASE)\(uri)"
                        Alamofire.request(url).responseJSON(completionHandler: { (response) in
                            
                            if let descriptionDictionary = response.result.value as? Dictionary<String, AnyObject> {
                                
                                if let description = descriptionDictionary["description"] as? String {
                                    
                                    let newDescription = description.replacingOccurrences(of: "POKMON", with: "Pokemon")
                                    
                                    self._description = newDescription
                                }
                            }
                            
                            completed()
                        })
                    }
                    
                } else {
                     self._description = "N/A"
                }
                
                if let evolutions = dict["evolutions"] as? [Dictionary<String, AnyObject>], evolutions.count > 0 {
                    
                    if let nextEvo = evolutions[0]["to"] as? String {
                        
                        if nextEvo.range(of: "mega") == nil {
                            
                            self._nextEvolutionName = nextEvo
                            
                            if let uri = evolutions[0]["resource_uri"] as? String {
                                
                                let newString = uri.replacingOccurrences(of: "/api/v1/pokemon/", with: "")
                                let nextEvoId = newString.replacingOccurrences(of: "/", with: "")
                                
                                self._nextEvolutionId = nextEvoId
                                
                                if let levelExist = evolutions[0]["level"] {
                                    
                                    if let level = levelExist as? Int {
                                    
                                        self._nextEvolutionLevel = "\(level)"
                                    }
                                    
                                } else {
                                    self._nextEvolutionLevel = ""
                                }
                            }
                        }
                    }
                    
                }
                
            }
            
            completed()
        }
    }
}
