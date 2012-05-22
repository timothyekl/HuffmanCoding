class HuffmanCoder

  def self.encode(text = "")
    return HuffmanString::from_plaintext(text)
  end

  def self.decode(text = "")
    return HuffmanString::from_ciphertext(text)
  end

end

class HuffmanString

  attr_accessor :plaintext
  attr_accessor :tree
  attr_accessor :ciphertext

  def self.from_plaintext(text = "")
    s = HuffmanString.new
    s.plaintext = text
    return s
  end

  def self.from_ciphertext(ciphertext = "")
    s = HuffmanString.new
    s.ciphertext = ciphertext
    return s
  end

  def plaintext=(text)
    @plaintext = text
    @tree = HuffmanTree::build(self.plaintext)
    @ciphertext = self.tree.encode(self.plaintext)
  end

  def ciphertext=(text)
    @tree, @ciphertext = HuffmanTree::parse(text)
    @plaintext = self.tree.decode(self.ciphertext.clone)
  end

  # Overridden to return the completely encoded bit string
  def to_s
    return self.tree.to_binary_string + self.ciphertext
  end

  def inspect
    str = "Huffman String\n"
    str += "    Plaintext: #{self.plaintext}\n"
    str += "    Binary plain: #{self.plaintext.encode("UTF-8").bytes.to_a.map{|c| c.to_s(2)}.join}\n"
    str += "    Tree: #{self.tree}\n"
    str += "    Binary tree: #{self.tree.to_binary_string}\n"
    str += "    Ciphertext: #{self.ciphertext}\n"

    return str
  end

end

class HuffmanTree
  
  attr_accessor :root

  def initialize(root = nil)
    self.root = root
  end
  
  def self.build(str = "")
    pq = PriorityQueue.new

    str.split("").each do |c|
      pq.put(c, pq.get(c) + 1)
    end

    while pq.length > 1
      v1 = pq.pop_with_prio
      v2 = pq.pop_with_prio
      prio = v1[1] + v2[1]

      node = HuffmanNode.new(nil)

      if v1[0].is_a? HuffmanNode
        node.left = v1[0]
        node.left.parent = node
      else
        node.left = HuffmanNode.new(node, v1[0])
      end

      if v2[0].is_a? HuffmanNode
        node.right = v2[0]
        node.right.parent = node
      else
        node.right = HuffmanNode.new(node, v2[0])
      end

      pq.put(node, prio)
    end

    return HuffmanTree.new(pq.pop)
  end

  def self.parse(str)
    input = str.clone
    root = HuffmanNode.new(nil)
    current = root

    while true
      code = input.slice!(0, 1)
      if code == "0"
        # node has two children
        current.left = HuffmanNode.new(nil)
        current.left.parent = current
        current.right = HuffmanNode.new(nil)
        current.right.parent = current

        current = current.left
      elsif code == "1"
        # node has a value
        val = input.slice!(0, 8)
        current.value = Integer("0b" + val).chr

        while current != nil and (current.right.nil? or current.right.full_subtree?)
          current = current.parent
        end

        if current.nil? or (current == root and !current.right.value.nil?)
          break
        end

        current = current.right
      end
    end

    tree = HuffmanTree.new(root)
    return [tree, input]
  end

  def to_s
    return "#<HuffmanTree:root=#{self.root}>"
  end

  def encode(text = "")
    return text.split("").map{|c|self.binary_path_to(c)}.join("")
  end

  def decode(ciphertext = "")
    current = self.root
    s = ""

    while ciphertext.length > 0
      val = ciphertext.slice!(0, 1)
      current = current.left if val == "0"
      current = current.right if val == "1"

      if !current.value.nil?
        s += current.value
        current = self.root
      end
    end

    return s
  end

  def binary_path_to(char = "")
    return "" if char.length != 1

    ans = []
    visited = {}
    current = self.root
    return "" if current.nil?

    while true
      visited[current] = true
      if current.value == char
        break
      end

      if !current.left.nil? and current.left.is_a? HuffmanNode and !visited[current.left]
        ans << 0
        current = current.left
        next
      end

      if !current.right.nil? and current.right.is_a? HuffmanNode and !visited[current.right]
        ans << 1
        current = current.right
        next
      end

      if (current.right.nil? or visited[current.right]) and (current.left.nil? or visited[current.left])
        ans.pop
        current = current.parent
        next
      end

      break
    end

    return ans.map{|x| x.to_s}.join("")
  end

  def to_binary_string
    return self.root.to_binary_string
  end

end

class HuffmanNode

  attr_accessor :left
  attr_accessor :right
  attr_accessor :parent
  attr_accessor :value

  def initialize(parent, v = nil)
    self.parent = parent
    self.value = v
  end

  def to_s
    if self.value.nil?
      if self.left.nil? and self.right.nil?
        return "nil"
      else
        return "#<HuffmanNode:value=#{self.value},left=#{self.left},right=#{self.right}>"
      end
    else
      return self.value
    end
  end

  def to_binary_string
    if self.value.nil?
      return "0" + self.left.to_binary_string + self.right.to_binary_string
    else
      bs = self.value.encode("UTF-8").bytes.to_a[0].to_s(2)
      s = "1" + ("0" * (8 - bs.length) + bs)
      raise Exception.new("Failed assertion: encoded value string is not nine bits long") if s.length != 9
      return s
    end
  end

  def full_subtree?
    if self.left.nil? and self.right.nil?
      return !self.value.nil?
    end

    return (self.left.full_subtree? and self.right.full_subtree?)
  end

end

class PriorityQueue

  attr_accessor :data

  def initialize
    self.data = {}
    self.data.default = 0
  end

  # Insert the given key at the given priority. Replaces the matching key's priority, if it exists.
  def put(k, v)
    self.data[k] = v
  end

  # Read the priority for the given key without removing it
  def get(k)
    return self.data[k]
  end

  # Get the next key according to priority. Does not remove the key.
  def peek
    return nil if self.length == 0

    frequencies = self.data.sort_by{|k,v| v}
    val = frequencies.select{|x| x[1] == frequencies[0][1]}.map{|x| x[0]}.sort_by{|x| x.to_s}[0]
    return val
  end

  # Get the next key according to priority. Does not remove the key.
  # Returns an array of the form [value, priority].
  def peek_with_prio
    return nil if self.length == 0
    
    val = self.peek
    return [val, self.get(val)]
  end

  # Get the next key according to priority. Removes the key.
  def pop
    val = self.peek
    self.delete(val) if !val.nil?
    return val
  end

  # Get the next key according to priority. Removes the key.
  # Returns an array of the form [value, priority].
  def pop_with_prio
    val = self.peek_with_prio
    return nil if val.nil?

    self.delete(val[0])
    return val
  end
  
  # Remove the given key from the queue, regardless of its priority
  def delete(k)
    self.data.delete(k)
  end

  # Get the number of keys currently in the queue.
  def length
    return self.data.length
  end

end
