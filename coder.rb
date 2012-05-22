class HuffmanCoder

  def self.encode(text = "")
    return HuffmanString.new(text)
  end

  def self.decode(text = "")
    raise Exception.new("Unimplemented")
  end

end

class HuffmanString

  attr_accessor :plaintext
  attr_accessor :tree
  attr_accessor :ciphertext

  def initialize(text = "")
    self.plaintext = text

    self.tree = HuffmanTree::build(self.plaintext)

    self.ciphertext = self.tree.encode(self.plaintext)
  end

  def to_s
    str = "Huffman String\n"
    str += "    Plaintext: #{self.plaintext}\n"
    str += "    Tree: #{self.tree}\n"
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
    raise Exception.new("Unimplemented")
  end

  def to_s
    return "#<HuffmanTree:root=#{self.root}>"
  end

  def encode(text = "")
    return text.split("").map{|c|self.binary_path_to(c)}.join("")
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
    return "#<HuffmanNode:value=#{self.value},left=#{self.left},right=#{self.right}>"
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
