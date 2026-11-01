#!/usr/bin/env python3
"""Grammarian, Starter stage (about A1): new unit "Parts of speech" (8 lessons), placed first in the stage.

Phase 11 (2026-10-26). Original wording. The British Council-EAQUALS Core Inventory and the CEFR Companion Volume
supply only topic order and level. Run from the project root:
python3 tools/curriculum/stages/grammarian_words_starter.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, M, E, YOUR, add_units  # noqa: E402

SOURCES = [
    "British Council-EAQUALS Core Inventory for General English (topic order and level)",
    "CEFR Companion Volume (A1 descriptors)",
]

UNITS = [{"id": "parts-of-speech", "title": "Parts of speech"}]

LESSONS = [
    ("gram-s-nouns", "parts-of-speech", "Nouns: common and proper", "GRAM-S-11",
     "A noun names a person, place, thing or idea: teacher, city, phone, love. A common noun is a general name and starts with a small letter: city, river, day. A proper noun is the name of one particular person, place or thing and always starts with a capital letter: Paris, the Nile, Monday, Maria.",
     [
         C("Which word is a noun?", "garden", "quickly", "beautiful", "run"),
         C("Which word is a proper noun?", "London", "city", "street", "country"),
         C("Which words need a capital letter? “we met ana in madrid on friday.”", "we, ana, madrid, friday", "only we", "met, in, on", "only ana and madrid"),
         C("How many nouns are in this sentence? “The boy gave his dog a ball.”", "Three", "One", "Two", "Four"),
         TF("True or false: Days of the week are proper nouns, so they start with a capital letter.", "True"),
         TF("True or false: “happiness” is a noun.", "True"),
         M("Match each noun with what it names.", [["Tokyo", "one particular city"], ["mountain", "any mountain"], ["Tuesday", "one day of the week"]]),
         C("Which word needs a capital letter? “My friend lives in canada.”", "canada", "friend", "lives", "in"),
         F("Type the noun in this sentence: “She loves music.”", "music"),
         W("Build the sentence.", "Maria works in a big hospital.", "quickly", "works"),
         LISTEN("Tom and his sister visited Rome in July.", "Which city did they visit?", "Rome", "Tom", "July", "Paris"),
         YOUR("Write two sentences. Use one common noun and one proper noun in each."),
     ]),
    ("gram-s-plurals", "parts-of-speech", "Singular and plural", "GRAM-S-12",
     "Singular means one; plural means more than one. Most nouns add -s: book, books. Nouns ending in -s, -sh, -ch, -x or -z add -es: bus, buses; box, boxes. A consonant + y changes to -ies: city, cities. Some plurals are irregular: man, men; woman, women; child, children; foot, feet; tooth, teeth; mouse, mice; person, people.",
     [
         C("Choose the plural of “box”.", "boxes", "boxs", "boxies", "box"),
         C("Choose the plural of “city”.", "cities", "citys", "cityes", "cityies"),
         C("Choose the plural of “child”.", "children", "childs", "childes", "childrens"),
         C("Choose the plural of “person”.", "people", "persons people", "peoples", "personies"),
         C("Which sentence is correct?", "I brushed my teeth.", "I brushed my tooths.", "I brushed my teeths.", "I brushed my toothes."),
         E("There are three womans in the room.", "There are three women in the room."),
         E("I bought two new dress.", "I bought two new dresses."),
         M("Match each noun with its plural.", [["foot", "feet"], ["mouse", "mice"], ["bus", "buses"]]),
         TF("True or false: The plural of “baby” is “babies”.", "True"),
         F("Type the plural of “watch”.", "watches"),
         W("Build the sentence.", "The children have new shoes.", "childs", "has"),
         YOUR("Write about things in your room. Use at least three plural nouns."),
     ]),
    ("gram-s-pronouns", "parts-of-speech", "Personal pronouns", "GRAM-S-13",
     "A pronoun takes the place of a noun so we don't repeat it. Subject pronouns do the action: I, you, he, she, it, we, they. Object pronouns receive the action: me, you, him, her, it, us, them. “Anna called Ben” becomes “She called him.” Use “it” for things and animals you don't know well.",
     [
         C("Replace the noun: “Maria is a nurse.”", "She is a nurse.", "Her is a nurse.", "He is a nurse.", "It is a nurse."),
         C("Choose the object pronoun: “I saw Tom and Lisa. I saw ___.”", "them", "they", "their", "theirs"),
         C("Choose the correct sentence.", "She helped me.", "Her helped me.", "She helped I.", "Her helped I."),
         C("Which pronoun replaces “the car”?", "it", "he", "they", "him"),
         C("Choose the correct sentence.", "We invited him to the party.", "Us invited him to the party.", "We invited he to the party.", "Us invited he to the party."),
         E("Me and my brother play tennis.", "My brother and I play tennis."),
         E("Can you help we?", "Can you help us?"),
         M("Match each subject pronoun with its object pronoun.", [["I", "me"], ["she", "her"], ["they", "them"]]),
         TF("True or false: “him” can be the subject of a sentence.", "False"),
         F("Type the missing pronoun: “This is my sister. ___ is a teacher.”", "She"),
         LISTEN("My parents live in a small town. They visit us every summer.", "Who visits the speaker every summer?", "The parents", "The town", "The speaker", "Nobody"),
         YOUR("Write three sentences about your family using he, she, they or we."),
     ]),
    ("gram-s-possessives", "parts-of-speech", "Possessives", "GRAM-S-14",
     "Possessives show who has something. Possessive adjectives go before a noun: my, your, his, her, its, our, their. “This is my bag.” Add 's to a person or animal to show ownership: “Sara's phone”, “the dog's bed.” For a plural noun ending in s, add only the apostrophe: “my parents' house.” Note: “its” (owning) has no apostrophe; “it's” means “it is”.",
     [
         C("Choose the correct word: “Ben and Lucy love ___ dog.”", "their", "there", "they're", "them"),
         C("The bag belongs to Sara. How do you write it?", "Add an apostrophe and s after Sara", "Add only s after Sara", "Put Sara after bag", "Add s and then an apostrophe after Sara"),
         C("“The cat is licking ___ paw.” Which word fits?", "its, with no apostrophe", "it's, with an apostrophe", "it is", "it"),
         C("Two boys share one room. Where does the apostrophe go in “the boys room”?", "After the s of boys", "Before the s of boys", "After room", "Nowhere"),
         C("Choose the correct word: “Is this ___ coat, Tom?”", "your", "you're", "you", "yours'"),
         E("This is my brother car.", "This is my brother's car."),
         E("We love are new flat.", "We love our new flat."),
         M("Match each pronoun with its possessive adjective.", [["I", "my"], ["we", "our"], ["he", "his"]]),
         TF("True or false: “it's” means “it is”.", "True"),
         F("Type the possessive word for “we”: “This is ___ house.”", "our"),
         W("Build the sentence.", "My parents' house is near the sea.", "parent", "are"),
         YOUR("Describe three things that belong to people you know, using 's or my, his, her, our, their."),
     ]),
    ("gram-s-articles", "parts-of-speech", "Articles: a, an, the", "GRAM-S-15",
     "Use a or an with one thing that is not specific: “I need a pen.” Use an before a vowel sound: an apple, an hour. Use a before a consonant sound: a car, a university. Use the when both people know which one: “Close the door.” Also use the with things that are the only one: the sun, the sea. Don't use an article with most plural or uncountable nouns in general: “Dogs are friendly.” “I like music.”",
     [
         C("Choose the correct article: “She is ___ engineer.”", "an", "a", "the", "no article"),
         C("Choose the correct article: “We waited for ___ hour.”", "an", "a", "the", "no article"),
         C("Choose the correct article: “He studies at ___ university.”", "a", "an", "the", "no article"),
         C("Choose the best sentence.", "The sun is very bright today.", "A sun is very bright today.", "Sun is very bright today.", "An sun is very bright today."),
         C("Choose the best sentence for a general idea.", "I like music.", "I like the music in general.", "I like a music.", "I like an music."),
         E("I bought a apple and a orange.", "I bought an apple and an orange."),
         E("Can you open a window next to you?", "Can you open the window next to you?"),
         M("Match each noun with its article.", [["umbrella", "an"], ["dog", "a"], ["moon", "the"]]),
         TF("True or false: We say “an hour” because “hour” starts with a vowel sound.", "True"),
         F("Type the missing article: “I saw ___ elephant at the zoo.”", "an"),
         W("Build the sentence.", "I have a cat and an old dog.", "the", "an"),
         YOUR("Write three sentences about your town using a, an and the."),
     ]),
    ("gram-s-adjectives", "parts-of-speech", "Adjectives", "GRAM-S-16",
     "An adjective describes a noun: a red car, a happy child, a long day. In English the adjective usually comes before the noun, or after be, look, feel and seem: “The soup is hot.” “You look tired.” Adjectives never change for plural nouns: “two big dogs”, not “two bigs dogs.”",
     [
         C("Which word is an adjective?", "tall", "slowly", "table", "jump"),
         C("Choose the correct order.", "a small house", "a house small", "small a house", "a smalls house"),
         C("Choose the correct sentence.", "They have three young children.", "They have three youngs children.", "They have children youngs three.", "They have three children youngs."),
         C("Find the adjective: “The old man smiled.”", "old", "man", "smiled", "the"),
         C("Choose the correct sentence.", "This coffee tastes bitter.", "This coffee tastes bitterly.", "This coffee bitter tastes.", "This coffee tastes bitters."),
         E("She has a dress beautiful.", "She has a beautiful dress."),
         E("We saw two bigs elephants.", "We saw two big elephants."),
         M("Match each adjective with its opposite.", [["hot", "cold"], ["full", "empty"], ["early", "late"]]),
         TF("True or false: An adjective can come after “feel”, as in “I feel tired.”", "True"),
         F("Type the adjective: “It was a quiet evening.”", "quiet"),
         W("Build the sentence.", "My grandmother has a friendly cat.", "friendly", "cats"),
         YOUR("Describe your favourite place with at least four adjectives."),
     ]),
    ("gram-s-adverbs", "parts-of-speech", "Adverbs", "GRAM-S-17",
     "An adverb describes a verb, an adjective or another adverb. Adverbs tell us how, when, where or how often. Many adverbs of manner are adjective + -ly: slow, slowly; careful, carefully. Some are irregular: good, well; fast, fast; hard, hard. “She drives carefully.” “He speaks English well.” Other common adverbs: very, too, here, there, now, always, often.",
     [
         C("Choose the adverb form of “quick”.", "quickly", "quickful", "quickness", "quicker"),
         C("Choose the correct sentence.", "She sings beautifully.", "She sings beautiful.", "She beautiful sings.", "She sings beautifulness."),
         C("Choose the correct sentence.", "He plays the piano well.", "He plays the piano good.", "He plays good the piano.", "He good plays the piano."),
         C("Which word is an adverb?", "yesterday", "yellow", "yard", "young"),
         C("Choose the correct sentence.", "The train arrived late.", "The train arrived lately.", "The train late arrived lately.", "The train arrived latefully."),
         E("Please speak slow.", "Please speak slowly."),
         E("She works very hardly.", "She works very hard."),
         M("Match each adjective with its adverb.", [["easy", "easily"], ["good", "well"], ["happy", "happily"]]),
         TF("True or false: In “It is very cold”, the word “very” is an adverb.", "True"),
         F("Type the adverb form of “careful”.", "carefully"),
         W("Build the sentence.", "They always walk to school.", "walks", "never"),
         YOUR("Write three sentences about how you do things, using adverbs like slowly, carefully or well."),
     ]),
    ("gram-s-joiners", "parts-of-speech", "Conjunctions and interjections", "GRAM-S-18",
     "A conjunction joins words or ideas. And adds: “tea and cake.” But shows a contrast: “small but fast.” Or gives a choice: “now or later.” So shows a result: “It rained, so we stayed in.” Because gives a reason: “I left because I was tired.” An interjection is a short word that shows a feeling: Oh! Wow! Ouch! Oops! It often stands alone with an exclamation mark.",
     [
         C("Choose the conjunction for a reason: “I stayed home ___ I was ill.”", "because", "but", "or", "so"),
         C("Choose the conjunction for a result: “It was late, ___ we took a taxi.”", "so", "because", "or", "but"),
         C("Choose the conjunction for a contrast: “The flat is small ___ cheap.”", "but", "or", "so", "because"),
         C("Which word is an interjection?", "Ouch", "Over", "Only", "Open"),
         C("Choose the best sentence.", "Do you want tea or coffee?", "Do you want tea so coffee?", "Do you want tea because coffee?", "Do you want tea but coffee?"),
         E("I like apples because bananas.", "I like apples and bananas."),
         E("She was tired, because she went to bed.", "She was tired, so she went to bed."),
         M("Match each conjunction with its job.", [["and", "adds"], ["but", "contrasts"], ["or", "gives a choice"]]),
         TF("True or false: “Wow!” is an interjection.", "True"),
         F("Type the missing conjunction: “We can walk ___ take the bus.”", "or"),
         READ("Lina wanted to swim, but the pool was closed. She was disappointed, so she went for a walk instead.", "Why couldn't Lina swim?", "The pool was not open.", "She was too tired.", "It was raining hard.", "She lost her bag."),
         YOUR("Write one sentence with because and one sentence with so."),
     ]),
]

if __name__ == "__main__":
    add_units("grammarian", "starter", UNITS, LESSONS, "A1", SOURCES, position="start")
