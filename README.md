This project is a very simple proof-of-concept implementation of Huffman coding,
as described by Sebastian Plesciuc [here][huffman]. It supports both encoding
and decoding simple UTF-8 strings. Execute by running:

    $ ruby huffman.rb --mode {encode|decode} "your string here"

## Usage

In **encode** mode, the script will return a string of 0 and 1 characters; this
string is the binary representation of the Huffman-encoded tree and ciphertext.
In **decode** mode, the script will return the decoded string parsed as UTF-8
characters. This means you can do:

    $ ruby huffman.rb --mode encode "your string here" > encoded.txt
    $ ruby huffman.rb --mode decode `cat encoded.txt`
    your string here

## Technical details

The encoded string is the concatenation of two things: the **binary-encoded
Huffman tree** and the **encoded ciphertext**.

### Huffman tree

The tree is encoded following a simple algorithm. Starting at the root, the
algorithm recurses in preorder and converts as follows:

* If the current node has children, a 0 is appended to the binary string
* If the current node has a value, a 1 is appended to the binary string,
  followed by the eight-bit UTF-8-encoded value for the node's value

Note that these two are mutually exclusive, and so we can encode the entire tree
following these two simple rules. For example, a three-node tree containing the
characters 'A' and 'Z' in the (balanced) leaves would encode as (with spaces
added for clarity):

    0 1 01000001 1 01011010

### Encoded ciphertext

The ciphertext is then encoded by locating each plaintext character in the
Huffman tree and writing the path to that character. In path representations, a
0 is a move to the left and a 1 is a move to the right. Using the above tree as
an example, the string 'AZA' would encode as (again with spaces):

    0 1 0

More extensive trees will obviously lead to longer paths in the encoded
ciphertext.

### Code interface

The primary programmatic interface is through the HuffmanCoder class, defined in
the coder.rb file. In irb, you can do:

    > require './coder.rb'
    > encoded = HuffmanCoder.encode("your string here")
    > HuffmanCoder.decode(encoded.to_s)

Both methods will return an instance of `HuffmanString`, which can be queried
for its various forms (using the `plaintext`, `tree`, and `ciphertext` methods).

[huffman]: http://en.nerdaholyc.com/huffman-coding-on-a-string/
