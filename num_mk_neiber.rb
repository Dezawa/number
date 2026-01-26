#!/usr/bin/ruby1.9
# -*- coding: UTF-8 -*-
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

while gets && ( $_ =~ /^\s*#/ || $_ =~ /^\s*$/) ; end
(n,m,x,y)=split ; n=n.to_i ; m = m.to_i ;x=x.to_i; y=y.to_i
box=[]
(0..x+1).each{|i| 
  d=[];(0..x+1).each{|j| d<<0}; box[i]=d
}

cel=0

(1..y).each{|j|
   while gets =~ /^\s*#/;end
#print $_
  p=chop.split("").unshift(1)

   (1..x).each{ |i| a=p[i]
     if a=="@" || a=="*"
	cel += 1
	box[i][j]=cel
    end
  }
}

## 計算
(1..y).each{|j|
 (1..x).each{ |i|
   box[i][j]==0 && next
   if box[i+1][j]>0 ; printf "%-2d %-2d\n",box[i][j],box[i+1][j];end
   if box[i][j+1]>0 ; printf "%-2d %-2d\n",box[i][j],box[i][j+1];end
 }
}

