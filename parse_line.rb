# UIClass -> class
def parse_ui_class(line)
  line.gsub(/^UIClass(?=\b.*)/, "class")
end

# **** -> #
def parse_comments(line)
  line.sub(/\*{4}(?=.*)/, "#")
end

RUBY_SYNTAX_PIPELINES = [ # define the extended ruby syntax
   :parse_ui_class, 
   :parse_comments 
]

def parse_line(line)
  RUBY_SYNTAX_PIPELINES.each do |parser|
    line = send parser, line
  end
  line
end
