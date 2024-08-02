---
layout: post
title: "Using Ruby's #.extend on instances to avoid modifying a base class"
image: /assets/img/posts/ruby-frequency-hash.png
description: >
  Making a Scrabble word-finder by adding subtraction and overloading the subset operator on #.tally supplied frequency hashes
redirect_from:
  - /posts/ruby-frequency-hash/
category: ruby
---

I choked a bit on a tech screen today (at least by my own standards), by rushing to a solution too quickly, instead of working out a proper tested class. So after dinner I thought I'd revisit it and see what a cleaner solution might look like.

Problem: Given a supplied scrabble dictionary (text file of words per line - in the test I swap in a small array for speed) write a method that gives all possible words for any hand/set of tiles.

```ruby
@dict = Scrabble::Dictionary.new ["AA", "AD", "ADD", "DAD", "BAD"]
assert_equal ["AD", "ADD", "DAD"], @dict.possible_words("ADD")
```
* toc
{:toc}

I got most of the way there off right off the bat by just taking the [\#tally](https://ruby-doc.org/3.2.2/Enumerable.html#method-i-tally) of the the characters of the dictionary and the selected hand. Always learn as much of your language's stdlib/builtins as you can. It's endlessly helpful and saves you a lot of effort re-inventing the wheel. It was very nice to be able to skip half the work by just tacking on a method here or there.

```ruby
"foobar".chars.tally
=> {"f"=>1, "o"=>2, "b"=>1, "a"=>1, "r"=>1}
```

From there the exact \#select criteria against the dictionary of words got into some longer method-chaining that wasn't so easy to debug.  Upon later reconsideration, just extending the returned hash with a few methods makes for an easier testing interface. And by extending the hashes directly you don't have to bother with a wrapping class, delegation, or including the methods into Hash and messing with every other hash in your project. If you do this upon intake of the dictionary, it's even a one time performance hit.

So the logic is I need to come up with a subset that is only true if the rhs has not only the keys, or the exact keys and values, but greater or equal values at all keys for a given word. This seemed logically cleanest to me as two operations, a new subtraction operator that subtracts the values of hashes at corresponding keys and then if that returns an empty hash, it's a match. Well, if by "subtracts the values" we mean "and deletes if the rhs has more of an individual tile than needed" but that's fine for our usage, even if it's not how I'd normally implement subtraction. I guess it's "whole numbers only" subtraction, since a negative frequency count, in this usage, doesn't make sense.

You could also do something clever like \#transform_value the rhs by negative 1, zipping them togethe, taking the sum, of each, then selecting the value <= 0 entries, but that gets a little complicated, and is a lot of passes compared to just iterating the list and doing the subtraction and delete if, imo.

```ruby
#tests for the subtraction that the subset relies on
hash = { foo: 5, bar: 3}.extend(Scrabble::FreqHash)
assert_equal ({foo: 2}), (hash - {foo: 3, bar: 3, baz: 3})
assert_equal ({ foo: 5, bar: 3}), hash #make sure you didn't mutate the actual dict

module Scrabble
  module FreqHash
    def self.extended(mod)
    	#avoids the need for constant nil checks
      mod.default = 0
    end

    def <=(rhs)
      (self - rhs).empty?
    end

    def -(rhs)
      newh = self.clone
      rhs.each do |k, v|
        newh.delete(k) if (newh[k] -= v) <= 0
      end
      newh
    end
  end

  class Dictionary < Hash
    def self.from_file(file_path)
      self.new(File.open(file_path).readlines.map(&:strip))
    end

    def initialize(lines)
      lines.each do |line|
        self[line] = line.chars.tally.extend(FreqHash)
      end
    end

    def possible_words(hand)
      self.select { |k, v| v <= hand.chars.tally }.keys
    end
  end
end
```

Later I saw how to get my select logic for the subset down to a clean(ish) single line. But I got there faster by just getting a working implementation first and working down from there, which is what I should have done in the screen. I have made the final shorter solution in this posts open graph preview tile, and header image, I'm sure that will cause no confusion. 😇