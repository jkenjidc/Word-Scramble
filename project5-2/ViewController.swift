//
//  ViewController.swift
//  project5-2
//
//  Created by Justine kenji Dela Cruz on 20/11/2022.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordUrl) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["error"]
        }
        
        startGame()
    }
    
    @objc func startGame(){
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer(){
        let ac =  UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submittedAction = UIAlertAction(title: "Submit", style: .default){
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submittedAction)
        present(ac, animated: true)
    }
    
    func submit (_ answer: String){
        let lowerAnswer = answer.lowercased()
        
        
        if isPossible(word: lowerAnswer){
            if isOriginal(word: lowerAnswer){
                if isReal(word: lowerAnswer){
                    if isLongEnough(word: lowerAnswer){
                        if isNotTitle(word: lowerAnswer){
                            usedWords.insert(lowerAnswer, at: 0)
                            
                            let indexPath = IndexPath(row: 0, section: 0)
                            tableView.insertRows(at: [indexPath], with: .automatic)
                            
                            return
                        } else{
                            showErrorMessage("notTitle")
                        }
                    } else {
                        showErrorMessage("notLongEnough")
                    }
                } else {
                    showErrorMessage("notReal")
                }
            }else {
                showErrorMessage("notOriginal")
            }
        }else{
            showErrorMessage("notPossible")
        }
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord =  title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter){
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range =  NSRange(location: 0, length: word.utf16.count)
        let misspelledRange =  checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isLongEnough(word: String) -> Bool {
        return word.count >= 3
    }
    
    func isNotTitle(word: String) -> Bool {
        return !(title == word)
    }
    
    func showErrorMessage(_ errorType: String){
        let errorTitle: String
        let errorMessage: String
        switch errorType{
        case "notPossible":
            guard let title = title else { return }
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title.lowercased())."
        case "notOriginal":
            errorTitle = "Word already used"
            errorMessage = "already submitted that word"
        case "notReal":
            errorTitle = "Word not recognized"
            errorMessage = "Enter a valid english word"
        case "notLongEnough":
            errorTitle = "Word is too short"
            errorMessage = "Enter a word with more than 2 letters"
        case "notTitle":
            errorTitle = "Can't use main word"
            errorMessage = "Use a word that is not just the title itself"
        default:
            errorTitle = "Unrecognized Error"
            errorMessage = "not recognized error"
        }
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        
    }


}

