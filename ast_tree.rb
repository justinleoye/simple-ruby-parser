require 'ruby_parser'
require 'pry-byebug'

class AstNode
  def initialize(parent)
    @parent = parent
    @child_nodes = []
  end

  def push_child(node)
    @child_nodes.push node
  end

  def shift_child
    @child_nodes.shift
  end

  def child_len
    @child_nodes.length
  end

  def parent
    @parent
  end
end

class ProgAstNode < AstNode
  def initialize
    super self
  end

  def exc(context)
    while !@child_nodes.empty?
      node = self.shift_child
      node.exc context
    end
  end
end

class UIClassAstNode < AstNode
  def initialize(parent, line)
    _first, @class_name = line.split
    @line = line
    super parent
  end

  def exc(context)
    class_def = <<-RUBY
      class #{@class_name}
      end
      #{@class_name}
    RUBY
    klass = eval class_def, context
    while !@child_nodes.empty?
      node = self.shift_child
      node.exc klass.class_eval {binding}
    end
  end
end

class DefAstNode < AstNode
  def initialize(parent, line)
    _first, @method_name = line.split
    @line = line
    super parent
  end

  def exc context
    method_body = ""
    @child_nodes.each do |node|
      method_body += node.translated_code
    end
    def_str = <<-RUBY
      def #{@method_name}
        #{method_body}
      end
    RUBY
    eval def_str, context
  end
end

class NormalRubyExcAstNode < AstNode
  def initialize(parent, line)
    @exc_line = line
    @line = line
    super parent
  end

  def exc(context)
    eval @exc_line, context
  end

  def translated_code
    @exc_line
  end
end

class IgnoreAstNode < AstNode
  def initialize(parent, line)
    @ignore_line = line
    @line = line
    super parent
  end

  def exc(context)
  end

  def translated_code
    @ignore_line
  end
end

def is_close(line)
  line.match(/^\s*end(?=.*)/)
end

def is_class_node(line)
  line.match(/^\s*UIClass(?=\b.*)/)
end

def is_def_node(line)
  line.match(/^\s*def(?=\b.*)/)
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
  line_num = 0
  code.each do |line|
    case
    when(is_close line)
      curr_node = curr_node.parent
    when(is_class_node line)
      node = UIClassAstNode.new curr_node,line
      curr_node.push_child node
      curr_node = node
    when(is_def_node line)
      node = DefAstNode.new curr_node,line
      curr_node.push_child node
      curr_node = node
    when(is_normal_ruby_exc_node line)
      node = NormalRubyExcAstNode.new curr_node,line
      curr_node.push_child node
    else
      node = IgnoreAstNode.new curr_node,line
      curr_node.push_child node
    end
    line_num += 1
  end
  tree
end

def exc_ast_tree(tree, context)
  tree.exc context
end

