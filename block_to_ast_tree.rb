require 'ruby_parser'

main = self

def sandbox(&code)
  proc {
    $SAFE = 2
    yield
  }.call
end

class AstNode
  def initialize(parent)
    @parent = parent
    @child_nodes = []
  end

  def push_child(node)
    @child_nodes.push node
  end

  def pop_child
    @child_nodes.pop
  end
end

class ProgAstNode < AstNode
  def initialize
    super.initialize nil
  end

  def exc
    while !@child_nodes.empty?
      node = self.pop_child
      node.exc
    end
  end
end

class UIClassAstNode < AstNode
  def initialize(parent, line)
    _first, @class_name = line.split
    super.initialize parent
  end

  def exc
    sandbox { eval "#{@class_name} = Class.new"}
    while !@child_nodes.empty?
      node = self.pop_child
      node.exc
    end
  end
end

class DefAstNode < AstNode
  def initialize(parent, line)
    _first, @method_name = line.split
    super.initialize parent
  end

  def exc
    sandbox { eval "#{@method_name} = "}
  end
end

class NormalRubyExcAstNode < AstNode
  def initialize(parent, line)
    @exc_line = line
    super.initialize parent
  end
  def exc
  end
end

class IgnoreAstNode < AstNode
  def initialize(parent, line)
    @ignore_line = line
    super.initialize parent
  end
  def exc
  end
end

def is_close(line)
  line.match(/^end(?=.*)/)
end

def is_class_node(line)
  line.match(/^UIClass(?=\b.*)/)
end

def is_def_node(line)
  line.match(/^def(?=\b.*)/)
end

def is_normal_ruby_exc_node(line)
  begin
    RubyParser.new.parse line
    return true
  rescue Racc::ParseError
    return false
  end
end

def to_ast_tree(code)
  tree = ProgAstNode.new
  curr_node = tree
  code.each do |line|
    case line
    when is_close line
      curr_node = curr_node.parent
    when is_class_node line
      node = UIClassAstNode.new curr_node,line
      curr_node.push_child node
      curr_node = node
    when is_def_node line
      node = DefAstNode.new curr_node,line
      curr_node.push_child node
      curr_node = node
    when is_normal_ruby_exc_node line
      node = NormalRubyExcAstNode.new curr_node,line
      curr_node.push_child node
    else
      node = IgnoreAstNode.new curr_node,line
      curr_node.push_child node
    end
  end
  tree
end

def exc_ast_tree(tree)
  tree.exc
end

