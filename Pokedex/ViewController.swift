//
//  ViewController.swift
//  Pokedex
//
//  Created by Luis Guzman on 3/26/17.
//  Copyright © 2017 Luis Guzman. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var pokemons = [Pokemon]()
    private var filteredPokemons = [Pokemon]()
    private var inSearchMode = false
    private var musicPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.dataSource = self
        collection.delegate = self
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
        
        parsePokemonCSV()
        initAudio()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonCell", for: indexPath) as? PokemonCollectionViewCell {
            
            //let pokemon = Pokemon(name: "Pokemon", pokedexId: indexPath.row)
            //let pokemon = pokemons[indexPath.row]
            
            let pokemon: Pokemon!
            
            if inSearchMode {
            
                pokemon = filteredPokemons[indexPath.row]
                cell.configureCell(pokemon: pokemon)
                
            } else {
                
                pokemon = pokemons[indexPath.row]
                cell.configureCell(pokemon: pokemon )
            }
            
            return cell
            
        } else {
            
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var pokemonSelected: Pokemon!
        
        if inSearchMode {
            
            pokemonSelected = filteredPokemons[indexPath.row]
        
        } else {
        
            pokemonSelected = pokemons[indexPath.row]
            
        }
        
        performSegue(withIdentifier: "PokemonDetail", sender: pokemonSelected)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if inSearchMode {
            return filteredPokemons.count
        }
        
        return pokemons.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105, height: 105)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            
            inSearchMode = false
            collection.reloadData()
            view.endEditing(true)

        } else {
            
            inSearchMode = true
            
            let lower = searchBar.text!.lowercased()
            
            filteredPokemons = pokemons.filter({ $0.name.range(of: lower) != nil })
            collection.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // piramide de la muerte
        if segue.identifier == "PokemonDetail" {
            if let detailViewController = segue.destination as? PokemonDetailViewController {
                if let pokemon = sender as? Pokemon {
                    detailViewController.pokemon = pokemon
                }
            }
        }
    }
    
    @IBAction func musicButtonPressed(_ sender: UIButton) {
        
        if musicPlayer.isPlaying {
            
            musicPlayer.pause()
            sender.alpha = 0.5
            
        } else {
            
            musicPlayer.play()
            sender.alpha = 1.0
            
        }
        
       //let _ = musicPlayer.isPlaying ? musicPlayer.pause() : musicPlayer.play()
    }
    
    func initAudio() {
        
        let path = Bundle.main.path(forResource: "music", ofType: "mp3")!
        
        do {
            
            musicPlayer = try AVAudioPlayer(contentsOf: URL(string: path)!)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
            
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func parsePokemonCSV() {
        
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")!
        
        do {
            
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            //print(rows)
            
            for row in rows {
                
                let pokeId = Int(row["id"]!)!
                let name = row["identifier"]!
                
                let poke = Pokemon(name: name, pokedexId: pokeId)
                
                pokemons.append(poke)
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

