require './parse_file.rb'

# source code path to exc
code_file_path = ARGV[0]

# parse source code to target ruby code
code_parsed = parse_file code_file_path

# just show the target ruby code
puts "**************START:code parsed**************"
puts "#{code_parsed}"
puts "**************END:code parsed**************"

# exc ruby code
# TODO: exc code in sandbox(protected scope)
eval code_parsed
