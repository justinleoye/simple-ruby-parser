
# load code by file path
def load_code(file_name)
  begin
    code = []
    file = File.new(file_name, "r") 
    while (line = file.gets)
      code.push line
    end
    file.close
    code
  rescue => err
    puts "Exception: #{err}"
    err
  end
end
