#!/usr/bin/ruby1.9
# frozen_string_literal: true

# 初期化
# wdef* を読んで、隣同士のcelのリストを作る。
# データを読み込む配列 box[][]は、縦横＋２のサイズにする
#  cellのあるところは番号を入れる
#
# 計算
# box[][]を左上から右、下へ順に、
# 番号がある同士だったら、リストする
#
# v1.2
#   dataの空白無に変更する
#

require 'English'
while gets && ($LAST_READ_LINE =~ /^\s*#/ || $LAST_READ_LINE =~ /^\s*$/); end
(n, m, x, y) = split
n.to_i
m.to_i
x = x.to_i
y = y.to_i
box = []
(0..x + 1).each do |i|
  d = []
  (0..x + 1).each { |_j| d << 0 }
  box[i] = d
end

cel = 0

(1..y).each  do |j|
  while gets =~ /^\s*#/; end
  # print $_
  p = chop.split('').unshift(1)

  (1..x).each do |i|
    a = p[i]
    if ['@', '*'].include?(a)
      cel += 1
      box[i][j] = cel
    end
    (box[i][j]).zero? && next
    printf "%-2d %-2d\n", box[i][j], box[i + 1][j] if (box[i + 1][j]).positive?
    printf "%-2d %-2d\n", box[i][j], box[i][j + 1] if (box[i][j + 1]).positive?
  end
end

## 計算
