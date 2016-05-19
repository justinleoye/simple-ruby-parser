UIClass X
  def a
    b = (1..100).to_a
    b.inject(0, &:+)
  end
end

****XXXX****
UIClass Y
  def self.b
    a = (5..100).to_a
    a.inject(0, &:+)
  end
end

****freewheel*****
UIClass Z
  def Z.c
    a = (5..99).to_a
    a.inject(0, &:+)
  end
****hello*****
  def d
  a = (5..99).to_a
  a.inject(0, &:+)
  end
end

puts X.new.a

