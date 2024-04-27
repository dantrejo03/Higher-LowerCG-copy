//
//  GameVC.swift
//  Higher-LowerCG
//
//  Created by Daniel Trejo on 7/14/23.
//

import UIKit

class GameVC: UIViewController {

    @IBOutlet var TL_card: UIButton!
    @IBOutlet var TM_card: UIButton!
    @IBOutlet var TR_card: UIButton!
    
    @IBOutlet var ML_card: UIButton!
    @IBOutlet var C_card: UIButton!
    @IBOutlet var MR_card: UIButton!
    
    @IBOutlet var LL_card: UIButton!
    @IBOutlet var LM_card: UIButton!
    @IBOutlet var LR_card: UIButton!
    
    
    @IBOutlet var face_up_cards: [UIButton]!
    @IBOutlet var guess_buttons: [UIButton]!
    
    
    var card_deck: [Card] = Cards.allValues
    var num_cards = 52
    var card_selection_tag: Int? = -1
    var table_values = [1,1,1,1,1,1,1,1,1]
    var flipped_piles: Set<Int> = []
    var last_card = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var index = 0
        for slot in face_up_cards {
            let card = card_from_deck()
            slot.setBackgroundImage(card.picture, for: .normal)
            table_values[index] = card.value
            index += 1
        }
        
        change_button_status(status: false)
    }
    
    func card_from_deck () -> Card {
        let index = Int.random(in: 0..<num_cards)
        let card = card_deck[index]
        card_deck.remove(at: index)
        num_cards -= 1
        if (num_cards == 0) {
            last_card = true
        }
        return card
    }
    
    func change_button_status (status: Bool) {
        for button in guess_buttons {
            button.isEnabled = status
        }
    }
    
    func check_guess(card: Int, guess_value: Int, pile: Int) -> Bool {
        let next_card = card_from_deck()
        table_values[pile] = next_card.value
        let button = button_from_pileNum(card_pile: pile)
        button.setBackgroundImage(next_card.picture, for: .normal)
        
        let difference = next_card.value - card
        
        if (difference * guess_value > 0) {
            return true
        } else if (difference == 0 && guess_value == 0) {
            return true
        } else {
            return false
        }
    }
    
    func end_game (status: Bool) {
        //true -> win screen
        let screen = UIView(frame: UIScreen.main.bounds)
        let message = UILabel(frame: CGRect(x: 0, y: 0, width: 217.0, height: 44.33))
        message.center = self.view.center
        message.textAlignment = .center
        let time_duration: TimeInterval
        let score = UILabel(frame: CGRect(x: 0, y: 378, width: 217, height: 44.33))
        score.center.x = self.view.center.x
        score.textAlignment = .center
        score.text = "SCORE: \(num_cards)"
        score.textColor = .cyan
        
        if (!status) {
            message.text = "GAME OVER"
            message.textColor = .systemRed
            screen.backgroundColor = .black
            time_duration = 1.5
            
        } else {
            message.text = "WELL DONE"
            message.textColor = .green
            screen.backgroundColor = .white
            time_duration = 0.5
        }
        view.addSubview(screen)
        view.addSubview(message)
        view.addSubview(score)
        message.alpha = 0.0
        screen.alpha = 0.0
        score.alpha = 0.0
        UIView.animate(withDuration: time_duration, animations: {
            screen.alpha = 1.0
            message.alpha = 1.0
            score.alpha = 1.0
        })
        
        
    }
    
    func button_from_pileNum(card_pile: Int) -> UIButton {
        let target_button: UIButton
        switch card_pile {
        case 0:
            target_button = TL_card
        case 1:
            target_button = TM_card
        case 2:
            target_button = TR_card
        case 3:
            target_button = ML_card
        case 4:
            target_button = C_card
        case 5:
            target_button = MR_card
        case 6:
            target_button = LL_card
        case 7:
            target_button = LM_card
        default:
            target_button = LR_card
        }
        return target_button
    }
    
    func flip_card_stack(card_pile: Int) {
        let target_button = button_from_pileNum(card_pile: card_pile)
        target_button.setBackgroundImage(UIImage(named: "Card_backside"), for: .normal)
        flipped_piles.insert(card_pile)
        target_button.isEnabled = false
        
        if (flipped_piles.count == 9) {
            end_game(status: false)
        }
        if (last_card) {
            end_game(status: true)
        }
    }
    
    
    @IBAction func card_selected(_ sender: UIButton) {
        change_button_status(status: true)
        let old_tag = card_selection_tag
        card_selection_tag = sender.tag
        
        if (old_tag != card_selection_tag) {
            let card_button = button_from_pileNum(card_pile: card_selection_tag!)
            card_button.isEnabled = false
            if (!flipped_piles.contains(old_tag!) && old_tag! > -1) {
                button_from_pileNum(card_pile: old_tag!).isEnabled = true
            }
        }
        
    }
    
    func disable_buttons (status: Bool) {
        for i in 0..<9 {
            if (!flipped_piles.contains(i)) {
                button_from_pileNum(card_pile: i).isEnabled = status
            }
        }
    }
    
    @IBAction func guess(_ sender: UIButton) {
        
        let result = check_guess(card: table_values[card_selection_tag!], guess_value: sender.tag, pile: card_selection_tag!)
        
        if (!result) {
            disable_buttons(status: false)
            let tag = card_selection_tag
            let time = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(timer_action(num:)), userInfo: tag, repeats: false)
        } else {
            button_from_pileNum(card_pile: card_selection_tag!).isEnabled = true
                
        }
        
        change_button_status(status: false)
    }
    
    @objc func timer_action(num: Timer) {
        
        flip_card_stack(card_pile: num.userInfo! as! Int)
        disable_buttons(status: true)
    }
    
    
}
