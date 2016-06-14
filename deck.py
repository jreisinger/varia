#!/usr/bin/env python3

import random
import argparse

class Deck:
    suit_names = ["Clubs", "Diamonds", "Hearts", "Spades"]
    rank_names = [None, "Ace", "2", "3", "4", "5", "6", "7",
            "8", "9", "10", "Jack", "Queen", "King"]

    def __init__(self, n_cards = 52):
        self.deck = []
        while len(self.deck) < n_cards:
            for suit in range(4):
                for rank in range(1, 14):
                    self.deck.append(Deck.rank_names[rank] + Deck.suit_names[suit])
            self.deck.append

    def show(self):
        for card in self.deck:
            print(card)

    def shuffle(self):
        random.shuffle(self.deck)

    def deal_old(self, n_cards = 5, hands = 1):
        for i in range(hands):
            hand = []
            while len(hand) < n_cards:
                hand.append(self.deck.pop())
            print()
            for card in hand:
                print(card)

    def _deal_one_hand(self, n_cards = 5):
        return [self.deck[x] for x in range(min(len(self.deck)), n_cards)]

    def deal(self, n_cards = 5, hands = 1):
        for i in range(hands):
            print()
            for card in Deck._deal_one_hand(n_cards):
                print(card)

if __name__ == '__main__':


    parser = argparse.ArgumentParser(description="Deal card from deck of 52 cards")
    parser.add_argument('--hands', type=int, help='number of hands to deal [1]', default = 1)
    parser.add_argument('--cards', type=int, help='cards per hand [5]', default = 5)

    cmdargs = parser.parse_args()
    hands = cmdargs.hands
    cards = cmdargs.cards

    deck = Deck()
    deck.shuffle()
    deck.deal(n_cards = cards, hands = hands)
