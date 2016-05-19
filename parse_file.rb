require './parse_line.rb'

# parse file by file path
def parse_file(file_name)
  begin
    # TODO: store parsed code into transitional files, not into memory
    code_parsed = ""
    file = File.new(file_name, "r") 
    while (line = file.gets)
      line_parsed = parse_line line
      code_parsed += line_parsed
    end
    file.close
    code_parsed
  rescue => err
    puts "Exception: #{err}"
    err
  end
end
