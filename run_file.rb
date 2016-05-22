require './load_code.rb'
require './ast_tree.rb'

# source code path to exc
code_file_path = ARGV[0]

# parse source code to target ruby code
code = load_code code_file_path

# binding
def get_binding
  binding
end

# create extend ruby AST
ast_tree = to_ast_tree code
exc_ast_tree ast_tree, get_binding
